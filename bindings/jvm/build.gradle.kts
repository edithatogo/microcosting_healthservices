plugins {
    kotlin("jvm") version "2.2.21"
    application
}

group = "org.mchs.bindings"
version = "0.0.0-local"

kotlin {
    jvmToolchain(21)
}

application {
    mainClass.set("org.mchs.bindings.jvm.BindingApplicationKt")
}

dependencies {
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.20.1")
}
