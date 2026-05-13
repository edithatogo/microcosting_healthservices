package org.mchs.bindings.jvm.client

import org.mchs.bindings.jvm.model.BindingRequest
import org.mchs.bindings.jvm.model.BindingResponse

interface BindingServiceClient {
    fun execute(request: BindingRequest): BindingResponse
}
