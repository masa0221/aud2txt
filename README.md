# aud2txt

[日本語](README.ja.md)

Shell script to transcribe audio files (MP3, WAV, M4A, etc.) to text. Uses [Whisper](https://github.com/openai/whisper) when available; otherwise outputs placeholder files for structure testing.

## Install (Homebrew)

```bash
brew install masa0221/tap/aud2txt
```

Requires:

- ffmpeg: `brew install ffmpeg`
- Whisper (for actual transcription): `uv tool install whisper-ctranslate2` or `pip install whisper-ctranslate2`

  [whisper-ctranslate2](https://github.com/Softcatala/whisper-ctranslate2) is ~4x faster than openai-whisper (MIT license). Alternative: `uv tool install openai-whisper`

## Requirements

- bash
- ffmpeg
- whisper (optional; install via `uv tool install whisper-ctranslate2` or `pip install whisper-ctranslate2` for transcription)

## Docker

Runs on Docker (Ubuntu-based). Includes whisper-ctranslate2 for transcription.

```bash
# Build image
docker build -t aud2txt .
```

Transcribe directory (output to `outputs/`, gitignored):

```bash
docker run --rm -it -v "$(pwd)/audios:/input" -v "$(pwd)/outputs:/output" aud2txt /input /output
```

With options:

```bash
docker run --rm -it -v "$(pwd)/audios:/input" -v "$(pwd)/outputs:/output" aud2txt -R /input /output
```

## Usage

```bash
./aud2txt [options] input(file|directory) [output_directory]
```

### Options

| Option | Description |
|--------|-------------|
| `-r`, `--recursive` | Recursive search in directory (default) |
| `-R`, `--no-recursive` | Top-level only |
| `-o`, `--output DIR` | Output directory |
| `-f`, `--format FMT` | Output format: srt, txt, vtt (default: srt) |
| `-m`, `--model NAME` | Whisper model: tiny, base, small, medium, large-v3, turbo (default: turbo) |
| `--plain` | Plain text without timestamps (txt format only) |
| `-h`, `--help` | Show help |

### Model (quality vs speed)

| Model | Speed | Accuracy | RAM |
|-------|-------|----------|-----|
| tiny | Fastest | Lowest | ~1GB |
| base | Fast | Low | ~1GB |
| small | Balanced | Good | ~2GB |
| medium | Slower | Better | ~5GB |
| large-v3 | Slowest | Best | ~10GB |
| turbo | Default | Good | - |

**Default recommendation**: whisper-ctranslate2 (~4x faster). Use openai-whisper if you prefer.

### Supported formats

- Input: .mp3, .wav, .m4a, .flac, .ogg, .webm
- Output: .srt (default), .txt, or .vtt (same base name as input)

### Examples

Single file (SRT for Vrew, Premiere Pro):

```bash
./aud2txt audio.mp3
```

Best quality (slower):

```bash
./aud2txt -m large-v3 audio.mp3
```

Plain text with timestamps:

```bash
./aud2txt -f txt audio.mp3
```

Plain text without timestamps:

```bash
./aud2txt -f txt --plain audio.mp3
```

Directory (recursive):

```bash
./aud2txt ./audios
```

Top-level only, specify output:

```bash
./aud2txt -R -o ./out ./audios
```

Output defaults to `outputs/`. Logs are saved in `output/_logs/`.

## Testing

### Test Data

`tests/data/` contains short test audio files (speech). `tests/data/expected/` holds actual output samples by format (srt/, txt/, vtt/, plain/) for reference and verification.

Use `outputs/` (gitignored) for test output.

### Run Tests

```bash
./tests/run-tests.sh
./tests/run-tests.sh --docker
```

Regenerate test data (synthetic, no speech):

```bash
./tests/setup-testdata.sh
./tests/setup-testdata.sh [source_directory] [seconds]
```

## License

See [LICENSE](LICENSE).
