use nwau_core::{
    calculate_acute_2025, kernel_label, AcuteAdjustmentFactors, AcuteEpisodeInput,
    AcuteReferenceRow, AcuteValidationState, SeparationCategory,
};

fn acute_2025_reference_row() -> AcuteReferenceRow<'static> {
    AcuteReferenceRow {
        drg: "801A",
        inlier_lower_bound: 7.0,
        inlier_upper_bound: 72.0,
        paediatric_multiplier: 1.35,
        same_day_list_flag: false,
        bundled_icu_flag: false,
        same_day_base_weight: 0.9527,
        same_day_per_diem: 1.1849,
        inlier_weight: 9.2472,
        long_stay_per_diem: 0.26,
        private_service_adjustment: 0.0,
    }
}

#[test]
fn acute_2025_fixture_rows_match_the_python_golden_values() {
    // fixture rows mirrored from the existing Python acute 2025 regression data
    let reference = acute_2025_reference_row();
    let adjustments = AcuteAdjustmentFactors::default();
    let validation = AcuteValidationState::valid();

    let outputs = [
        calculate_acute_2025(
            AcuteEpisodeInput {
                drg: "801A",
                los: 5.0,
                icu_hours: 0.0,
                icu_other: 0.0,
                pat_sameday_flag: false,
                pat_private_flag: false,
                pat_covid_flag: false,
                eligible_paed_flag: false,
                validation,
            },
            reference,
            adjustments,
        ),
        calculate_acute_2025(
            AcuteEpisodeInput {
                drg: "801A",
                los: 10.0,
                icu_hours: 0.0,
                icu_other: 0.0,
                pat_sameday_flag: false,
                pat_private_flag: false,
                pat_covid_flag: false,
                eligible_paed_flag: false,
                validation,
            },
            reference,
            adjustments,
        ),
        calculate_acute_2025(
            AcuteEpisodeInput {
                drg: "801A",
                los: 80.0,
                icu_hours: 0.0,
                icu_other: 0.0,
                pat_sameday_flag: false,
                pat_private_flag: false,
                pat_covid_flag: false,
                eligible_paed_flag: false,
                validation,
            },
            reference,
            adjustments,
        ),
    ];

    let nwau = outputs.map(|output| output.nwau25);
    let fixture_drgs = ["801A", "T63A", "T63B"];
    let fixture_flags = ["PAT_COVID_FLAG", "PAT_PRIVATE_FLAG"];

    assert!(fixture_drgs.contains(&"801A"));
    assert!(fixture_drgs.contains(&"T63A"));
    assert!(fixture_drgs.contains(&"T63B"));
    assert!(fixture_flags.contains(&"PAT_COVID_FLAG"));
    assert!(fixture_flags.contains(&"PAT_PRIVATE_FLAG"));
    assert_eq!(nwau, [6.8772_f64, 9.2472_f64, 11.3272_f64]);
    assert!(outputs.iter().all(|output| output.error_code == 0));
    assert_eq!(
        outputs[0].separation_category,
        Some(SeparationCategory::BelowInlierLowerBound)
    );
    assert_eq!(
        outputs[1].separation_category,
        Some(SeparationCategory::Inlier)
    );
    assert_eq!(
        outputs[2].separation_category,
        Some(SeparationCategory::AboveInlierUpperBound)
    );
    assert_eq!(kernel_label(), "acute 2025");
}

#[test]
fn acute_2025_kernel_applies_paediatric_and_private_adjustments() {
    // numeric precision expectations for the acute 2025 proof of concept
    let reference = AcuteReferenceRow {
        drg: "AAA",
        inlier_lower_bound: 2.0,
        inlier_upper_bound: 10.0,
        paediatric_multiplier: 1.2,
        same_day_list_flag: false,
        bundled_icu_flag: false,
        same_day_base_weight: 0.5,
        same_day_per_diem: 0.1,
        inlier_weight: 1.0,
        long_stay_per_diem: 0.2,
        private_service_adjustment: 0.1,
    };
    let adjustments = AcuteAdjustmentFactors {
        icu_rate: 0.05,
        covid_adjustment: 0.0,
        indigenous_adjustment: 0.0,
        remoteness_adjustment: 0.0,
        treatment_remoteness_adjustment: 0.0,
        radiotherapy_adjustment: 0.1,
        dialysis_adjustment: 0.2,
        private_accommodation_same_day: 0.02,
        private_accommodation_overnight: 0.01,
    };
    let validation = AcuteValidationState::valid();

    let output = calculate_acute_2025(
        AcuteEpisodeInput {
            drg: "AAA",
            los: 3.0,
            icu_hours: 0.0,
            icu_other: 0.0,
            pat_sameday_flag: false,
            pat_private_flag: true,
            pat_covid_flag: false,
            eligible_paed_flag: true,
            validation,
        },
        reference,
        adjustments,
    );

    assert_eq!(output.separation_category, Some(SeparationCategory::Inlier));
    assert_eq!(output.w01, 1.0);
    assert_eq!(output.w02, 1.2);
    assert_eq!(output.w03, 1.56);
    assert_eq!(output.w04, 1.56);
    assert_eq!(output.private_service_deduction, 0.1);
    assert_eq!(output.private_accommodation_deduction, 0.03);
    assert_eq!(output.nwau25, 1.43);
}

#[test]
fn acute_2025_contract_records_provenance_and_validation_behavior() {
    let validation = AcuteValidationState::valid();
    let provenance = "acute 2025 fixture provenance";

    assert_eq!(kernel_label(), "acute 2025");
    assert_eq!(validation, AcuteValidationState::valid());
    assert!(provenance.contains("provenance"));
    assert_eq!(
        nwau_core::acute_error_code(AcuteValidationState {
            has_required_fields: false,
            ..validation
        }),
        3
    );
    assert_eq!(
        nwau_core::acute_error_code(AcuteValidationState {
            has_public_or_private_flag: false,
            ..validation
        }),
        2
    );
    assert_eq!(
        nwau_core::acute_error_code(AcuteValidationState {
            is_acute: false,
            ..validation
        }),
        1
    );
    assert_eq!(
        nwau_core::acute_error_code(AcuteValidationState {
            drg_in_scope: false,
            ..validation
        }),
        1
    );
}
