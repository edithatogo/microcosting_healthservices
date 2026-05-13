package org.mchs.bindings.jvm.client

import org.mchs.bindings.jvm.model.BindingMetadata
import org.mchs.bindings.jvm.model.BindingRequest
import org.mchs.bindings.jvm.model.BindingResponse
import org.mchs.bindings.jvm.model.BindingStatus

class ScaffoldBindingServiceClient : BindingServiceClient {
    override fun execute(request: BindingRequest): BindingResponse =
        BindingResponse(
            status = BindingStatus.SCAFFOLD_ONLY,
            message = "Kotlin/JVM binding scaffold acknowledged the request without calculator logic.",
            diagnostics = listOf(
                "Formula logic is intentionally absent from the JVM scaffold.",
                "The Rust core or external service must own calculation behavior.",
            ),
            metadata = BindingMetadata(
                correlationId = request.metadata.correlationId,
                source = "synthetic",
                transport = "kotlin-jvm-scaffold",
            ),
        )
}
