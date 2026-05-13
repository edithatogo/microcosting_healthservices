package org.mchs.bindings.jvm

import org.mchs.bindings.jvm.client.ScaffoldBindingServiceClient
import org.mchs.bindings.jvm.file.JsonBindingFileGateway
import kotlin.system.exitProcess

fun main(args: Array<String>) {
    val options = BindingCliOptions.parse(args)
    if (options == null) {
        printUsage()
        exitProcess(1)
    }

    val gateway = JsonBindingFileGateway()
    val request = gateway.readRequest(options.requestPath)
    val response = ScaffoldBindingServiceClient().execute(request)
    gateway.writeResponse(options.responsePath, response)
}

private fun printUsage() {
    println(
        """
        Kotlin/JVM binding scaffold

        Usage:
          gradle run --args="--request request.json --response response.json"
        """.trimIndent()
    )
}
