package org.mchs.bindings.jvm.file

import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.mchs.bindings.jvm.model.BindingRequest
import org.mchs.bindings.jvm.model.BindingResponse
import java.nio.file.Files
import java.nio.file.Path

class JsonBindingFileGateway : BindingFileGateway {
    private val mapper = jacksonObjectMapper()

    override fun readRequest(path: String): BindingRequest =
        Files.newBufferedReader(Path.of(path)).use { reader ->
            mapper.readValue(reader)
        }

    override fun writeResponse(path: String, response: BindingResponse) {
        val outputPath = Path.of(path)
        outputPath.parent?.let { Files.createDirectories(it) }
        Files.newBufferedWriter(outputPath).use { writer ->
            mapper.writerWithDefaultPrettyPrinter().writeValue(writer, response)
        }
    }
}
