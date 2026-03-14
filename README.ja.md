# aud2txt

[English](README.md)

音声ファイル（MP3、WAV、M4A など）をテキストに文字起こしするシェルスクリプト。[OpenAI Whisper](https://github.com/openai/whisper) が利用可能な場合はそれを使用し、なければプレースホルダーを出力して構造テスト用に動作します。

## インストール (Homebrew)

```bash
brew install masa0221/tap/aud2txt
```

必要環境:

- ffmpeg: `brew install ffmpeg`
- Whisper（実際の文字起こし用）: `pip install openai-whisper`

## 要件

- bash
- ffmpeg
- whisper（任意。文字起こしには `pip install openai-whisper` でインストール）

## Docker

Docker 上で動作（Ubuntu ベース）。イメージに Whisper が含まれない場合はプレースホルダーの .txt を出力します。

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
| `-h`, `--help` | ヘルプ表示 |

### 対応形式

- 入力: .mp3, .wav, .m4a, .flac, .ogg, .webm
- 出力: .txt（入力と同じベース名）

### 例

単一ファイル（出力先 outputs/）:

```bash
./aud2txt audio.mp3
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

`tests/data/` に短いテスト音声（setup スクリプトで生成）。英語（sample1.mp3）と日本語（サンプル1.wav）のファイル名を含みます。

テスト出力は `outputs/`（gitignore 対象）を使用。

### テスト実行

```bash
./tests/run-tests.sh
./tests/run-tests.sh --docker
```

テストデータ再生成:

```bash
./tests/setup-testdata.sh
./tests/setup-testdata.sh [ソースディレクトリ] [秒数]
```

## ライセンス

[LICENSE](LICENSE) を参照。
