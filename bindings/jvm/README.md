# Kotlin/JVM binding scaffold

This directory contains a synthetic Kotlin-first JVM scaffold. It is not a
calculator implementation, not a Maven Central publication, and not a stable
runtime package.

## Boundary

- Kotlin data classes define request, response, metadata, and status envelopes.
- A file gateway preserves an inspectable JSON boundary.
- A service-client interface records the future online boundary.
- Java callers can consume the compiled JVM types later, but Kotlin is the
  primary authoring surface.

## Non-goals

- No formula logic.
- No JNI/JNA bridge.
- No embedded Rust core.
- No Maven Central or Gradle Plugin Portal publishing.

## Usage

```bash
cd bindings/jvm
./gradlew run --args="--request request.json --response response.json"
```

The scaffold acknowledges a request and preserves diagnostics/provenance
metadata. It does not calculate NWAU values.
