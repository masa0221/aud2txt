#!/usr/bin/env bash
# Create short audio clips for testing
# No source: generate synthetic audio with ffmpeg (no external dependency)
# With source: extract first N seconds from existing audio/video
#
# Test data in tests/data/ is pre-created (speech) for content verification.
# Run this script only to regenerate synthetic data when needed.

set -u

# Colors (only when stdout is a TTY)
if [[ -t 1 ]]; then
  R='\033[0;31m'
  G='\033[0;32m'
  Y='\033[0;33m'
  C='\033[0;36m'
  X='\033[0m'
else
  R= G= Y= C= X=
fi

if ! command -v ffmpeg &>/dev/null; then
  echo -e "${R}Error: Required command not found: ffmpeg${X}"
  echo "  Install ffmpeg (e.g. brew install ffmpeg)"
  exit 1
fi

SRC="${1:-}"
DURATION="${2:-5}"
DATA_DIR="$(cd "$(dirname "$0")" && pwd)/data"

mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/subdir"

generate_synthetic() {
  local out="$1"
  local dur="$2"
  echo -e "${C}Creating${X}: $(basename "$out") (synthetic ${dur}s)"
  ffmpeg -nostdin -y \
    -f lavfi -i "sine=frequency=440:duration=$dur" \
    -c:a libmp3lame -b:a 128k -ar 44100 -ac 1 \
    "$out" </dev/null 2>/dev/null
}

generate_wav() {
  local out="$1"
  local dur="$2"
  echo -e "${C}Creating${X}: $(basename "$out") (synthetic ${dur}s)"
  ffmpeg -nostdin -y \
    -f lavfi -i "sine=frequency=440:duration=$dur" \
    -c:a pcm_s16le -ar 44100 -ac 1 \
    "$out" </dev/null 2>/dev/null
}

if [[ -z "$SRC" ]]; then
  echo -e "${C}Creating test data${X} (synthetic audio)..."
  echo "  Duration: ${DURATION}s"
  echo "  Output: $DATA_DIR"
  echo ""

  generate_synthetic "$DATA_DIR/sample1.mp3" "$DURATION"
  generate_synthetic "$DATA_DIR/sample2.mp3" "$DURATION"
  generate_wav "$DATA_DIR/サンプル1.wav" "$DURATION"
  generate_wav "$DATA_DIR/サンプル2.wav" "$DURATION"
  generate_synthetic "$DATA_DIR/subdir/sample3.mp3" "$DURATION"
  generate_synthetic "$DATA_DIR/subdir/sample4.mp3" "$DURATION"
  generate_wav "$DATA_DIR/subdir/サンプル3.wav" "$DURATION"

else
  if [[ ! -d "$SRC" ]]; then
    echo -e "${R}Error: Source directory does not exist: $SRC${X}"
    echo "Usage: $0 [source_directory] [seconds]"
    echo "  Omit source to generate synthetic audio (no external dependency)"
    exit 1
  fi

  echo -e "${C}Creating test data${X}..."
  echo "  Source: $SRC"
  echo "  Duration: ${DURATION}s"
  echo "  Output: $DATA_DIR"
  echo ""

  count=0
  while IFS= read -r f; do
    [[ $count -ge 6 ]] && break
    rel="${f#$SRC/}"
    rel="${rel#/}"
    if [[ "$rel" == */* ]]; then
      out="$DATA_DIR/subdir/$(basename "$f")"
    else
      out="$DATA_DIR/$(basename "$f")"
    fi
    ext="${out##*.}"
    [[ "$ext" != "mp3" && "$ext" != "wav" && "$ext" != "m4a" ]] && out="${out%.*}.mp3"

    if [[ -f "$out" ]]; then
      echo -e "${Y}Skipping${X} (exists): $(basename "$f")"
      continue
    fi

    echo -e "${C}Creating${X}: $(basename "$f") (first ${DURATION}s)"
    if ffmpeg -nostdin -y -i "$f" -t "$DURATION" -c:a libmp3lame -b:a 128k "$out" </dev/null 2>/dev/null; then
      count=$((count + 1))
    fi
  done < <(find "$SRC" -type f \( -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" -o -name "*.mov" -o -name "*.mp4" \) | head -6)
fi

echo ""
echo -e "${G}Done${X}. Test examples (from project root):"
echo "  ./tests/run-tests.sh             # Run all tests"
echo "  ./aud2txt tests/data             # Directory (recursive)"
echo "  ./aud2txt -R tests/data          # Directory (top-level only)"
echo "  ./aud2txt tests/data/sample1.mp3  # Single file"
