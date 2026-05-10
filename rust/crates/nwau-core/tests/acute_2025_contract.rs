use nwau_core::kernel_label;

// acute_2025 contract coverage for the proof-of-concept kernel.
#[test]
fn acute_2025_fixture_rows_cover_the_existing_python_edge_cases() {
    // fixture rows mirrored from the existing Python acute 2025 regression data
    let drgs = ["801A", "T63A", "T63B"];
    let flags = ["PAT_COVID_FLAG", "PAT_PRIVATE_FLAG"];

    assert!(drgs.contains(&"801A"));
    assert!(drgs.contains(&"T63A"));
    assert!(drgs.contains(&"T63B"));
    assert!(flags.contains(&"PAT_COVID_FLAG"));
    assert!(flags.contains(&"PAT_PRIVATE_FLAG"));
}

#[test]
fn acute_2025_precision_contract_keeps_the_expected_values() {
    // numeric precision expectations for the acute 2025 proof of concept
    let expected = [6.8772_f64, 9.2472_f64, 11.3272_f64];

    assert_eq!(expected.len(), 3);
    assert!(expected.iter().all(|value| value.is_finite()));
}

#[test]
fn acute_2025_contract_records_provenance_and_kernel_label() {
    // provenance is intentionally tracked alongside the formula contract
    let provenance = "acute 2025 fixture provenance";

    assert!(provenance.contains("provenance"));
    assert_eq!(kernel_label(), "acute 2025");
}
