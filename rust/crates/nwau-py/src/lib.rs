use pyo3::prelude::*;

#[pyfunction]
fn kernel_label() -> &'static str {
    nwau_core::kernel_label()
}

#[pymodule]
fn _rust(_py: Python<'_>, m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(kernel_label, m)?)?;
    Ok(())
}
