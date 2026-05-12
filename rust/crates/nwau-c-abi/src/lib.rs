//! Minimal C ABI scaffold for the NWAU proof of concept.
//!
//! This crate deliberately exposes wrapper-only ABI types and entrypoints.
//! It does not implement formula logic; the calculation entrypoint returns an
//! unimplemented status after validating that required pointers are present.

use core::ffi::c_char;

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct NwauAbiStringView {
    pub ptr: *const c_char,
    pub len: usize,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct NwauAbiEpisodeInput {
    pub drg: NwauAbiStringView,
    pub los: f64,
    pub icu_hours: f64,
    pub icu_other: f64,
    pub pat_sameday_flag: u8,
    pub pat_private_flag: u8,
    pub pat_covid_flag: u8,
    pub eligible_paed_flag: u8,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct NwauAbiReferenceRow {
    pub drg: NwauAbiStringView,
    pub inlier_lower_bound: f64,
    pub inlier_upper_bound: f64,
    pub paediatric_multiplier: f64,
    pub same_day_list_flag: u8,
    pub bundled_icu_flag: u8,
    pub same_day_base_weight: f64,
    pub same_day_per_diem: f64,
    pub inlier_weight: f64,
    pub long_stay_per_diem: f64,
    pub private_service_adjustment: f64,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct NwauAbiAdjustmentFactors {
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

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct NwauAbiEpisodeOutput {
    pub error_code: u32,
    pub separation_category: u32,
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

pub type NwauAbiStatus = u32;

pub const NWAU_ABI_VERSION_MAJOR: u32 = 0;
pub const NWAU_ABI_VERSION_MINOR: u32 = 1;
pub const NWAU_ABI_VERSION_PATCH: u32 = 0;
pub const NWAU_ABI_STATUS_OK: NwauAbiStatus = 0;
pub const NWAU_ABI_STATUS_INVALID_ARGUMENT: NwauAbiStatus = 1;
pub const NWAU_ABI_STATUS_UNIMPLEMENTED: NwauAbiStatus = 2;

fn static_view(text: &'static str) -> NwauAbiStringView {
    NwauAbiStringView {
        ptr: text.as_ptr() as *const c_char,
        len: text.len(),
    }
}

#[no_mangle]
pub extern "C" fn nwau_abi_version_major() -> u32 {
    NWAU_ABI_VERSION_MAJOR
}

#[no_mangle]
pub extern "C" fn nwau_abi_version_minor() -> u32 {
    NWAU_ABI_VERSION_MINOR
}

#[no_mangle]
pub extern "C" fn nwau_abi_version_patch() -> u32 {
    NWAU_ABI_VERSION_PATCH
}

#[no_mangle]
pub extern "C" fn nwau_abi_kernel_label() -> NwauAbiStringView {
    static_view("acute 2025")
}

#[no_mangle]
pub extern "C" fn nwau_abi_status_message(status: NwauAbiStatus) -> NwauAbiStringView {
    match status {
        NWAU_ABI_STATUS_OK => static_view("ok"),
        NWAU_ABI_STATUS_INVALID_ARGUMENT => static_view("invalid argument"),
        NWAU_ABI_STATUS_UNIMPLEMENTED => static_view("unimplemented"),
        _ => static_view("unknown status"),
    }
}

/// Validate the pointer-shaped acute 2025 ABI surface.
///
/// # Safety
///
/// `input`, `reference`, `adjustments`, and `out` must be valid pointers for
/// the duration of the call when they are non-null. `out` must point to writable
/// caller-owned storage for one `NwauAbiEpisodeOutput`.
#[no_mangle]
pub unsafe extern "C" fn nwau_abi_calculate_acute_2025(
    input: *const NwauAbiEpisodeInput,
    reference: *const NwauAbiReferenceRow,
    adjustments: *const NwauAbiAdjustmentFactors,
    out: *mut NwauAbiEpisodeOutput,
) -> NwauAbiStatus {
    if input.is_null() || reference.is_null() || adjustments.is_null() || out.is_null() {
        return NWAU_ABI_STATUS_INVALID_ARGUMENT;
    }

    unsafe {
        *out = NwauAbiEpisodeOutput::default();
    }

    NWAU_ABI_STATUS_UNIMPLEMENTED
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn version_queries_match_the_committed_abi_version() {
        assert_eq!(nwau_abi_version_major(), 0);
        assert_eq!(nwau_abi_version_minor(), 1);
        assert_eq!(nwau_abi_version_patch(), 0);
    }

    #[test]
    fn null_inputs_fail_closed() {
        let status = unsafe {
            nwau_abi_calculate_acute_2025(
                core::ptr::null(),
                core::ptr::null(),
                core::ptr::null(),
                core::ptr::null_mut(),
            )
        };

        assert_eq!(status, NWAU_ABI_STATUS_INVALID_ARGUMENT);
    }

    #[test]
    fn valid_pointer_shape_zeroes_output_and_returns_unimplemented() {
        let input = NwauAbiEpisodeInput::default();
        let reference = NwauAbiReferenceRow::default();
        let adjustments = NwauAbiAdjustmentFactors::default();
        let mut output = NwauAbiEpisodeOutput {
            error_code: 999,
            separation_category: 999,
            eligible_icu_hours: 999.0,
            los_icu_removed: 999.0,
            w01: 999.0,
            w02: 999.0,
            w03: 999.0,
            w04: 999.0,
            gwau: 999.0,
            private_service_deduction: 999.0,
            private_accommodation_deduction: 999.0,
            nwau25: 999.0,
        };

        let status =
            unsafe { nwau_abi_calculate_acute_2025(&input, &reference, &adjustments, &mut output) };

        assert_eq!(status, NWAU_ABI_STATUS_UNIMPLEMENTED);
        assert_eq!(output, NwauAbiEpisodeOutput::default());
    }
}
