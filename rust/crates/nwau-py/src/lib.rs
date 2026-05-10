use pyo3::prelude::*;
use pyo3::types::PyDict;

#[pyfunction]
fn kernel_label() -> &'static str {
    nwau_core::kernel_label()
}

#[allow(clippy::too_many_arguments)]
#[pyfunction]
fn calculate_acute_2025_row(
    py: Python<'_>,
    drg: &str,
    los: f64,
    icu_hours: f64,
    icu_other: f64,
    pat_sameday_flag: bool,
    pat_private_flag: bool,
    pat_covid_flag: bool,
    eligible_paed_flag: bool,
    inlier_lower_bound: f64,
    inlier_upper_bound: f64,
    paediatric_multiplier: f64,
    same_day_list_flag: bool,
    bundled_icu_flag: bool,
    same_day_base_weight: f64,
    same_day_per_diem: f64,
    inlier_weight: f64,
    long_stay_per_diem: f64,
    private_service_adjustment: f64,
    icu_rate: f64,
    covid_adjustment: f64,
    indigenous_adjustment: f64,
    remoteness_adjustment: f64,
    treatment_remoteness_adjustment: f64,
    radiotherapy_adjustment: f64,
    dialysis_adjustment: f64,
    private_accommodation_same_day: f64,
    private_accommodation_overnight: f64,
) -> PyResult<Py<PyDict>> {
    let validation = nwau_core::AcuteValidationState::valid();
    let output = nwau_core::calculate_acute_2025(
        nwau_core::AcuteEpisodeInput {
            drg,
            los,
            icu_hours,
            icu_other,
            pat_sameday_flag,
            pat_private_flag,
            pat_covid_flag,
            eligible_paed_flag,
            validation,
        },
        nwau_core::AcuteReferenceRow {
            drg,
            inlier_lower_bound,
            inlier_upper_bound,
            paediatric_multiplier,
            same_day_list_flag,
            bundled_icu_flag,
            same_day_base_weight,
            same_day_per_diem,
            inlier_weight,
            long_stay_per_diem,
            private_service_adjustment,
        },
        nwau_core::AcuteAdjustmentFactors {
            icu_rate,
            covid_adjustment,
            indigenous_adjustment,
            remoteness_adjustment,
            treatment_remoteness_adjustment,
            radiotherapy_adjustment,
            dialysis_adjustment,
            private_accommodation_same_day,
            private_accommodation_overnight,
        },
    );

    let dict = PyDict::new_bound(py);
    dict.set_item("NWAU25", output.nwau25)?;
    dict.set_item("Error_Code", output.error_code)?;
    dict.set_item(
        "Separation_Category",
        output.separation_category.map(|cat| cat as i32).unwrap_or(0),
    )?;
    dict.set_item("kernel_label", nwau_core::kernel_label())?;
    Ok(dict.into())
}

#[pymodule]
fn _rust(_py: Python<'_>, m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(kernel_label, m)?)?;
    m.add_function(wrap_pyfunction!(calculate_acute_2025_row, m)?)?;
    Ok(())
}
