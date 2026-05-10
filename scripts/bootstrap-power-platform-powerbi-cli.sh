#!/usr/bin/env bash
set -euo pipefail

readonly PAC_DOTNET_TOOL="microsoft.powerapps.cli.tool"
readonly POWERBI_NPM_PACKAGE="powerbi-cli"
readonly MIN_PAC_VERSION="1.35.0"
readonly MIN_POWERBI_VERSION="1.0.0"
readonly MIN_AZURE_CLI_VERSION="2.70.0"
readonly DOTNET_TOOLS_PATH="${HOME}/.dotnet/tools"

PAC_HELP_CHECKS=(
  "pac --help"
  "pac auth --help"
  "pac solution --help"
  "pac solution checker --help"
)

POWERBI_HELP_CHECKS=(
  "powerbi --help"
  "powerbi workspace --help"
  "powerbi dataset --help"
  "powerbi report --help"
)

AZURE_HELP_CHECKS=(
  "az --version"
  "az version"
)

log() {
  printf '[bootstrap] %s\n' "$1"
}

fail() {
  printf '[bootstrap][ERROR] %s\n' "$1" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

version_lt() {
  local lhs="$1"
  local rhs="$2"
  local ordered
  ordered="$(printf '%s\n%s\n' "$lhs" "$rhs" | sort -V | head -n 1)"
  [ "$ordered" = "$lhs" ] && [ "$lhs" != "$rhs" ]
}

extract_version() {
  local output="$1"
  printf '%s\n' "$output" | grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1
}

ensure_dotnet_tools_path() {
  if [[ ":$PATH:" != *":$DOTNET_TOOLS_PATH:"* ]]; then
    log "PATH is missing dotnet tools location for pac discovery: $DOTNET_TOOLS_PATH"
    export PATH="$PATH:$DOTNET_TOOLS_PATH"
    log "Added dotnet tools to PATH for this shell."
    log "If pac remains unavailable after bootstrap, run:"
    log "  echo 'export PATH=\"\\$PATH:$DOTNET_TOOLS_PATH\"' >> ~/.zshrc"
    log "  source ~/.zshrc"
    log "and re-run this bootstrap script."
  else
    log "PATH already includes dotnet tools path: $DOTNET_TOOLS_PATH"
  fi
}

check_command_present() {
  local command_name="$1"
  if ! command_exists "$command_name"; then
    fail "Missing required tool: $command_name"
  fi
}

run_help_smoke_check() {
  local command_to_test="$1"
  local output
  if ! output="$(bash -c "$command_to_test" 2>&1)"; then
    fail "Smoke check failed for '$command_to_test'"
  fi
  if [ -n "$output" ]; then
    log "Smoke check ok: $command_to_test => $(printf '%s\n' "$output" | head -n 1)"
  else
    log "Smoke check ok: $command_to_test"
  fi
}

ensure_command_version_floor() {
  local command_name="$1"
  local minimum_version="$2"
  local discover_command="$3"
  local output
  local version

  if ! output="$(bash -c "$discover_command" 2>&1)"; then
    fail "Unable to read $command_name version."
  fi

  version="$(extract_version "$output")"
  if [ -z "$version" ]; then
    fail "Could not parse $command_name version from: $output"
  fi

  log "$command_name version detected: $version"
  if version_lt "$version" "$minimum_version"; then
    return 1
  fi

  return 0
}

if ! command_exists dotnet; then
  fail "dotnet is required to install and manage Power Platform CLI. Install .NET SDK or use a pre-provisioned environment."
fi

ensure_dotnet_tools_path

if ! command_exists pac; then
  if [ -x "$DOTNET_TOOLS_PATH/pac" ]; then
    log "pac binary exists in dotnet tools path but was not on PATH earlier; using repaired session PATH."
  else
    log "Installing Power Platform CLI: dotnet tool install --global $PAC_DOTNET_TOOL"
    dotnet tool install --global "$PAC_DOTNET_TOOL"
  fi
fi

if ! command_exists pac; then
  fail "pac command still unavailable after install attempt."
fi

if ! ensure_command_version_floor "pac" "$MIN_PAC_VERSION" "pac --version"; then
  log "pac version is below minimum supported; attempting dotnet tool upgrade."
  dotnet tool update --global "$PAC_DOTNET_TOOL"
  ensure_command_version_floor "pac" "$MIN_PAC_VERSION" "pac --version" || fail "pac still below minimum supported version $MIN_PAC_VERSION after upgrade."
fi

if ! command_exists az; then
  fail "Missing required tool: az"
fi

ensure_command_version_floor "az" "$MIN_AZURE_CLI_VERSION" "az --version" || fail \
  "az version is below minimum supported version $MIN_AZURE_CLI_VERSION."

if ! command_exists powerbi; then
  if ! command_exists npm; then
    fail "npm is required to install powerbi CLI when it is missing."
  fi
  log "Installing Power BI CLI: npm install -g $POWERBI_NPM_PACKAGE"
  npm install -g "$POWERBI_NPM_PACKAGE"
fi

if ! command_exists powerbi; then
  fail "Missing required tool: powerbi"
fi

if ! ensure_command_version_floor "powerbi" "$MIN_POWERBI_VERSION" "powerbi --version"; then
  if ! command_exists npm; then
    fail "npm is required to upgrade powerbi CLI to minimum version $MIN_POWERBI_VERSION."
  fi
  log "powerbi version is below minimum supported; attempting npm upgrade."
  npm install -g "$POWERBI_NPM_PACKAGE"
  ensure_command_version_floor "powerbi" "$MIN_POWERBI_VERSION" "powerbi --version" || fail \
    "powerbi still below minimum supported version $MIN_POWERBI_VERSION after upgrade."
fi

check_command_present "pac"
check_command_present "powerbi"
check_command_present "az"

log "Running explicit command matrix smoke checks."
for command_to_test in "${PAC_HELP_CHECKS[@]}"; do
  run_help_smoke_check "$command_to_test"
done
for command_to_test in "${POWERBI_HELP_CHECKS[@]}"; do
  run_help_smoke_check "$command_to_test"
done
for command_to_test in "${AZURE_HELP_CHECKS[@]}"; do
  run_help_smoke_check "$command_to_test"
done

log "Command matrix:"
log "  pac: ${PAC_HELP_CHECKS[*]}"
log "  powerbi: ${POWERBI_HELP_CHECKS[*]}"
log "  az: ${AZURE_HELP_CHECKS[*]}"
log "Power BI CLI bootstrap complete."
