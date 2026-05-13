package org.mchs.bindings.jvm.model

data class BindingRequest(
    val schemaVersion: String,
    val calculatorId: String,
    val pricingYear: String,
    val inputPath: String,
    val outputPath: String,
    val metadata: BindingMetadata,
)
