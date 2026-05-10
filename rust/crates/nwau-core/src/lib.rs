//! Core acute 2025 Rust kernel.
//!
//! The formula layer is intentionally pure: reference row resolution, input
//! validation, and runtime adapters stay outside this crate's calculation
//! functions.

mod acute;

pub use acute::{
    acute_error_code, calculate_acute_2025, AcuteAdjustmentFactors, AcuteEpisodeInput,
    AcuteEpisodeOutput, AcuteReferenceRow, AcuteValidationState, SeparationCategory,
};

/// Return the kernel label used by the acute 2025 proof of concept.
pub fn kernel_label() -> &'static str {
    "acute 2025"
}
