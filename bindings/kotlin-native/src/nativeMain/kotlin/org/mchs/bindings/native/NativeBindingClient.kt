package org.mchs.bindings.native

interface NativeBindingClient {
    fun execute(request: BindingRequest): BindingResponse
}

class ScaffoldNativeBindingClient : NativeBindingClient {
    override fun execute(request: BindingRequest): BindingResponse =
        BindingResponse(
            status = BindingStatus.SCAFFOLD_ONLY,
            message = "Kotlin/Native scaffold acknowledged the request without calculator logic.",
            diagnostics = listOf(
                "Formula logic is intentionally absent from the Kotlin/Native scaffold.",
                "The Rust core, C ABI, service, or file contract must own calculation behavior.",
            ),
            metadata = BindingMetadata(
                correlationId = request.metadata.correlationId,
                source = "synthetic",
                transport = "kotlin-native-scaffold",
            ),
        )
}
