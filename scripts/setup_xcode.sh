#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="${REPO_ROOT}/TaapTaap.xcodeproj"
SPEC_FILE="${REPO_ROOT}/project.yml"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must be run on macOS with Xcode installed."
  exit 1
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XcodeGen is not installed. Install it first:"
  echo "  brew install xcodegen"
  exit 1
fi

if [[ ! -f "${SPEC_FILE}" ]]; then
  echo "Missing project spec: ${SPEC_FILE}"
  exit 1
fi

cd "${REPO_ROOT}"
xcodegen generate --spec "${SPEC_FILE}"

if [[ ! -d "${PROJECT_FILE}" ]]; then
  echo "Failed to generate ${PROJECT_FILE}"
  exit 1
fi

echo "Generated ${PROJECT_FILE}"
open "${PROJECT_FILE}"
