#!/usr/bin/env bash
# Run aud2txt tests (audio to text transcription)
# Usage: ./tests/run-tests.sh [--docker]
# Output goes to outputs/ (gitignored)

set -u

R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
X='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATA_DIR="$PROJECT_ROOT/tests/data"
OUTPUT_DIR="$PROJECT_ROOT/outputs"
USE_DOCKER=0

[[ "${1:-}" == "--docker" ]] && USE_DOCKER=1

cd "$PROJECT_ROOT"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Ensure test data exists
if [[ ! -f "$DATA_DIR/sample1.mp3" ]]; then
  echo -e "${Y}Creating test data...${X}"
  ./tests/setup-testdata.sh
fi

run_test() {
  local name="$1"
  shift
  echo -e "${Y}Test: $name${X}"
  if [[ $USE_DOCKER -eq 1 ]]; then
    docker run --rm \
      -v "$(pwd)/tests/data:/input" \
      -v "$(pwd)/outputs:/output" \
      aud2txt "$@" /input /output
  else
    ./aud2txt "$@" "$DATA_DIR" "$OUTPUT_DIR"
  fi
}

fail() {
  echo -e "${R}FAIL: $1${X}"
  exit 1
}

# Transcription (mp3/wav -> txt)
run_test "Audio to text (recursive)" || fail "Transcription failed"
test -f "$OUTPUT_DIR/sample1.txt" || fail "sample1.txt not created"
test -f "$OUTPUT_DIR/サンプル1.txt" || fail "サンプル1.txt not created"
echo -e "  ${G}OK${X} sample1.txt, サンプル1.txt"

# Top-level only
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
echo -e "${Y}Test: Top-level only (-R)${X}"
if [[ $USE_DOCKER -eq 1 ]]; then
  docker run --rm \
    -v "$(pwd)/tests/data:/input" \
    -v "$(pwd)/outputs:/output" \
    aud2txt -R /input /output
else
  ./aud2txt -R "$DATA_DIR" "$OUTPUT_DIR"
fi
test -f "$OUTPUT_DIR/sample1.txt" || fail "sample1.txt (top-level) not created"
test ! -f "$OUTPUT_DIR/subdir/sample3.txt" || fail "subdir should be skipped with -R"
echo -e "  ${G}OK${X} Top-level only"

# Single file
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
echo -e "${Y}Test: Single file${X}"
if [[ $USE_DOCKER -eq 1 ]]; then
  docker run --rm \
    -v "$(pwd)/tests/data:/input" \
    -v "$(pwd)/outputs:/output" \
    aud2txt /input/sample1.mp3 /output
else
  ./aud2txt "$DATA_DIR/sample1.mp3" "$OUTPUT_DIR"
fi
test -f "$OUTPUT_DIR/sample1.txt" || fail "sample1.txt (single file) not created"
echo -e "  ${G}OK${X} Single file"

echo ""
echo -e "${G}All tests passed${X}"
