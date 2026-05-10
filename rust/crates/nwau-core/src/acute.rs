#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct AcuteValidationState {
    pub has_required_fields: bool,
    pub has_public_or_private_flag: bool,
    pub is_acute: bool,
    pub drg_in_scope: bool,
}

impl AcuteValidationState {
    pub const fn valid() -> Self {
        Self {
            has_required_fields: true,
            has_public_or_private_flag: true,
            is_acute: true,
            drg_in_scope: true,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct AcuteEpisodeInput<'a> {
    pub drg: &'a str,
    pub los: f64,
    pub icu_hours: f64,
    pub icu_other: f64,
    pub pat_sameday_flag: bool,
    pub pat_private_flag: bool,
    pub pat_covid_flag: bool,
    pub eligible_paed_flag: bool,
    pub validation: AcuteValidationState,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct AcuteReferenceRow<'a> {
    pub drg: &'a str,
    pub inlier_lower_bound: f64,
    pub inlier_upper_bound: f64,
    pub paediatric_multiplier: f64,
    pub same_day_list_flag: bool,
    pub bundled_icu_flag: bool,
    pub same_day_base_weight: f64,
    pub same_day_per_diem: f64,
    pub inlier_weight: f64,
    pub long_stay_per_diem: f64,
    pub private_service_adjustment: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub struct AcuteAdjustmentFactors {
    pub icu_rate: f64,
    pub covid_adjustment: f64,
    pub indigenous_adjustment: f64,
    pub remoteness_adjustment: f64,
    pub treatment_remoteness_adjustment: f64,
    pub radiotherapy_adjustment: f64,
    pub dialysis_adjustment: f64,
    pub private_accommodation_same_day: f64,
    pub private_accommodation_overnight: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SeparationCategory {
    SameDay = 1,
    BelowInlierLowerBound = 2,
    Inlier = 3,
    AboveInlierUpperBound = 4,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct AcuteEpisodeOutput {
    pub error_code: u8,
    pub separation_category: Option<SeparationCategory>,
    pub eligible_icu_hours: f64,
    pub los_icu_removed: f64,
    pub w01: f64,
    pub w02: f64,
    pub w03: f64,
    pub w04: f64,
    pub gwau: f64,
    pub private_service_deduction: f64,
    pub private_accommodation_deduction: f64,
    pub nwau25: f64,
}

pub fn acute_error_code(validation: AcuteValidationState) -> u8 {
    if !validation.has_required_fields {
        3
    } else if !validation.has_public_or_private_flag {
        2
    } else if !validation.is_acute || !validation.drg_in_scope {
        1
    } else {
        0
    }
}

fn round_to(value: f64, decimals: i32) -> f64 {
    let factor = 10f64.powi(decimals);
    (value * factor).round() / factor
}

fn separation_category(
    pat_sameday_flag: bool,
    same_day_list_flag: bool,
    los_icu_removed: f64,
    inlier_lower_bound: f64,
    inlier_upper_bound: f64,
) -> Option<SeparationCategory> {
    if pat_sameday_flag && same_day_list_flag {
        return Some(SeparationCategory::SameDay);
    }

    if los_icu_removed < inlier_lower_bound {
        Some(SeparationCategory::BelowInlierLowerBound)
    } else if los_icu_removed <= inlier_upper_bound {
        Some(SeparationCategory::Inlier)
    } else {
        Some(SeparationCategory::AboveInlierUpperBound)
    }
}

pub fn calculate_acute_2025(
    input: AcuteEpisodeInput<'_>,
    reference: AcuteReferenceRow<'_>,
    adjustments: AcuteAdjustmentFactors,
) -> AcuteEpisodeOutput {
    debug_assert_eq!(
        input.drg, reference.drg,
        "acute kernel input and reference row must share the same DRG"
    );
    let error_code = acute_error_code(input.validation);
    if error_code > 0 {
        return AcuteEpisodeOutput {
            error_code,
            separation_category: None,
            eligible_icu_hours: 0.0,
            los_icu_removed: 0.0,
            w01: 0.0,
            w02: 0.0,
            w03: 0.0,
            w04: 0.0,
            gwau: 0.0,
            private_service_deduction: 0.0,
            private_accommodation_deduction: 0.0,
            nwau25: 0.0,
        };
    }

    let eligible_icu_hours = if reference.bundled_icu_flag {
        0.0
    } else if input.pat_covid_flag {
        input.icu_hours + input.icu_other
    } else {
        input.icu_hours
    };

    let los_icu_removed = (input.los - (eligible_icu_hours / 24.0).floor()).max(1.0);
    let separation_category = separation_category(
        input.pat_sameday_flag,
        reference.same_day_list_flag,
        los_icu_removed,
        reference.inlier_lower_bound,
        reference.inlier_upper_bound,
    );

    let w01 = match separation_category {
        Some(SeparationCategory::SameDay) => reference.same_day_base_weight,
        Some(SeparationCategory::BelowInlierLowerBound) => {
            reference.same_day_base_weight + los_icu_removed * reference.same_day_per_diem
        }
        Some(SeparationCategory::Inlier) => reference.inlier_weight,
        Some(SeparationCategory::AboveInlierUpperBound) => {
            reference.inlier_weight
                + (los_icu_removed - reference.inlier_upper_bound) * reference.long_stay_per_diem
        }
        None => 0.0,
    };
    let w01 = round_to(w01, 4);

    let w02 = if input.eligible_paed_flag {
        reference.paediatric_multiplier * w01
    } else {
        w01
    };

    let w03 = w02
        * (1.0
            + adjustments.indigenous_adjustment
            + adjustments.remoteness_adjustment
            + adjustments.radiotherapy_adjustment
            + adjustments.dialysis_adjustment)
        * (1.0 + adjustments.treatment_remoteness_adjustment);

    let w04 = w03 * (1.0 + adjustments.covid_adjustment);
    let gwau = (w04 + eligible_icu_hours * adjustments.icu_rate).max(0.0);

    let private_service_deduction = if input.pat_private_flag {
        reference.private_service_adjustment * (w01 + eligible_icu_hours * adjustments.icu_rate)
    } else {
        0.0
    };
    let private_accommodation_deduction = if input.pat_private_flag {
        if input.pat_sameday_flag {
            adjustments.private_accommodation_same_day
        } else {
            input.los * adjustments.private_accommodation_overnight
        }
    } else {
        0.0
    };

    let nwau25 = (gwau - private_service_deduction - private_accommodation_deduction).max(0.0);

    AcuteEpisodeOutput {
        error_code,
        separation_category,
        eligible_icu_hours,
        los_icu_removed,
        w01,
        w02,
        w03,
        w04,
        gwau,
        private_service_deduction,
        private_accommodation_deduction,
        nwau25,
    }
}
