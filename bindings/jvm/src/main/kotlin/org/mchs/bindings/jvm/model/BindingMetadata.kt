package org.mchs.bindings.jvm.model

data class BindingMetadata(
    val correlationId: String,
    val source: String,
    val transport: String,
)
