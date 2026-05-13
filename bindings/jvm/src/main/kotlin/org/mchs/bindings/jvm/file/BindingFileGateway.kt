package org.mchs.bindings.jvm.file

import org.mchs.bindings.jvm.model.BindingRequest
import org.mchs.bindings.jvm.model.BindingResponse

interface BindingFileGateway {
    fun readRequest(path: String): BindingRequest
    fun writeResponse(path: String, response: BindingResponse)
}
