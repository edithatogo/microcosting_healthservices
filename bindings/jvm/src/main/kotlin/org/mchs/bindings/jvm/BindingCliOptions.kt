package org.mchs.bindings.jvm

data class BindingCliOptions(
    val requestPath: String,
    val responsePath: String,
) {
    companion object {
        fun parse(args: Array<String>): BindingCliOptions? {
            var requestPath: String? = null
            var responsePath: String? = null
            var index = 0

            while (index < args.size) {
                when (args[index]) {
                    "--request" -> requestPath = args.getOrNull(++index)
                    "--response" -> responsePath = args.getOrNull(++index)
                    else -> return null
                }
                index += 1
            }

            return if (requestPath.isNullOrBlank() || responsePath.isNullOrBlank()) {
                null
            } else {
                BindingCliOptions(requestPath, responsePath)
            }
        }
    }
}
