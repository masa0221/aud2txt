# aud2txt

[English](README.md)

音声ファイル（MP3、WAV、M4A など）をテキストに文字起こしするシェルスクリプト。[Whisper](https://github.com/openai/whisper) が利用可能な場合はそれを使用し、なければプレースホルダーを出力して構造テスト用に動作します。

## インストール (Homebrew)

```bash
brew install masa0221/tap/aud2txt
```

必要環境:

- ffmpeg: `brew install ffmpeg`
- Whisper（実際の文字起こし用）: `uv tool install whisper-ctranslate2` または `pip install whisper-ctranslate2`

  [whisper-ctranslate2](https://github.com/Softcatala/whisper-ctranslate2) は openai-whisper より約 4 倍高速（MIT ライセンス）。代替: `uv tool install openai-whisper`

## 要件

- bash
- ffmpeg
- whisper（任意。文字起こしには `uv tool install whisper-ctranslate2` または `pip install whisper-ctranslate2` でインストール）

## Docker

Docker 上で動作（Ubuntu ベース）。whisper-ctranslate2 を含み、文字起こし可能です。

```bash
# イメージビルド
docker build -t aud2txt .
```

ディレクトリを文字起こし（出力は `outputs/`、gitignore 対象）:

```bash
docker run --rm -it -v "$(pwd)/audios:/input" -v "$(pwd)/outputs:/output" aud2txt /input /output
```

オプション付き:

```bash
docker run --rm -it -v "$(pwd)/audios:/input" -v "$(pwd)/outputs:/output" aud2txt -R /input /output
```

## 使い方

```bash
./aud2txt [options] 入力(ファイル|ディレクトリ) [出力ディレクトリ]
```

### オプション

| オプション | 説明 |
|------------|------|
| `-r`, `--recursive` | ディレクトリを再帰検索（デフォルト） |
| `-R`, `--no-recursive` | トップレベルのみ |
| `-o`, `--output DIR` | 出力ディレクトリ |
| `-f`, `--format FMT` | 出力形式: srt, txt, vtt（デフォルト: srt） |
| `-m`, `--model NAME` | Whisper モデル: tiny, base, small, medium, large-v3, turbo（デフォルト: turbo） |
| `--plain` | タイムスタンプなしのプレーンテキスト（txt 形式のみ） |
| `-h`, `--help` | ヘルプ表示 |

### モデル（品質と速度）

| モデル | 速度 | 精度 | RAM |
|--------|------|------|-----|
| tiny | 最速 | 最低 | ~1GB |
| base | 速い | 低 | ~1GB |
| small | バランス | 良好 | ~2GB |
| medium | 遅い | 高 | ~5GB |
| large-v3 | 最遅 | 最高 | ~10GB |
| turbo | デフォルト | 良好 | - |

**デフォルト推奨**: whisper-ctranslate2（約 4 倍高速）。好みで openai-whisper も可。

### 対応形式

- 入力: .mp3, .wav, .m4a, .flac, .ogg, .webm
- 出力: .srt（デフォルト）、.txt、.vtt（入力と同じベース名）

### 例

単一ファイル（Vrew、Premiere Pro 用 SRT）:

```bash
./aud2txt audio.mp3
```

最高品質（遅い）:

```bash
./aud2txt -m large-v3 audio.mp3
```

タイムスタンプ付きプレーンテキスト:

```bash
./aud2txt -f txt audio.mp3
```

タイムスタンプなしプレーンテキスト:

```bash
./aud2txt -f txt --plain audio.mp3
```

ディレクトリ（再帰）:

```bash
./aud2txt ./audios
```

トップレベルのみ、出力先指定:

```bash
./aud2txt -R -o ./out ./audios
```

出力はデフォルトで `outputs/`。ログは `output/_logs/` に保存されます。

## テスト

### テストデータ

`tests/data/` に短いテスト音声（発話）を格納。`tests/data/expected/` に形式別（srt/, txt/, vtt/, plain/）の実際の出力サンプルを格納。

テスト出力は `outputs/`（gitignore 対象）を使用。

### テスト実行

```bash
./tests/run-tests.sh
./tests/run-tests.sh --docker
```

テストデータ再生成（合成音、発話なし）:

```bash
./tests/setup-testdata.sh
./tests/setup-testdata.sh [ソースディレクトリ] [秒数]
```

## ライセンス

[LICENSE](LICENSE) を参照。
