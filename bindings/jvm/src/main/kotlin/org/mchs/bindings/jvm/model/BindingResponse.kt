package org.mchs.bindings.jvm.model

data class BindingResponse(
    val status: BindingStatus,
    val message: String,
    val diagnostics: List<String>,
    val metadata: BindingMetadata,
)
