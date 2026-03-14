---
name: release
description: Create release (tag + Homebrew tap). Use when user says "release", "/release", "リリース", "タグ打って", or wants to publish a new version.
---

# Release aud2txt

When the user wants to release a new version, do the following.

**Upstream**: Run earlier steps first if needed:

- Uncommitted changes or no open PR → run `pr` skill, then continue
- Open PR not merged → run `merge` skill (wait for CI, merge), then continue
- Only then run the release flow below.

**Related repo**: [masa0221/homebrew-tap](https://github.com/masa0221/homebrew-tap)

## Release flow

### 1. Create tag and Release

```bash
git checkout main && git pull
git tag v0.1.0
git push origin v0.1.0
gh release create v0.1.0 --generate-notes
```

- Determine version (e.g. v0.1.0). Ask user if unclear.
- `--generate-notes` creates release notes from merged PRs.

### 2. Create Homebrew tap PR (gh + curl only)

Use gh and curl. Do not use brew bump-formula-pr (requires `HOMEBREW_GITHUB_API_TOKEN`).

```bash
V=v0.1.0
curl -sL "https://github.com/masa0221/aud2txt/archive/refs/tags/${V}.tar.gz" -o /tmp/aud2txt.tar.gz
SHA=$(shasum -a 256 /tmp/aud2txt.tar.gz | cut -d' ' -f1)
gh repo clone masa0221/homebrew-tap /tmp/homebrew-tap
cd /tmp/homebrew-tap && git checkout -b aud2txt-${V#v}
# Create or update Formula/aud2txt.rb with url and sha256
sed -i.bak "s|/v[0-9.]*\\.tar\\.gz|/${V}.tar.gz|" Formula/aud2txt.rb
sed -i.bak "s|sha256 \"[^\"]*\"|sha256 \"${SHA}\"|" Formula/aud2txt.rb
rm -f Formula/aud2txt.rb.bak
git add Formula/aud2txt.rb && git commit -m "aud2txt ${V}"
git push -u origin aud2txt-${V#v}
gh pr create --title "aud2txt ${V}" --body "Bump aud2txt to ${V}"
```

### 3. Wait for CI

- homebrew-tap GitHub Actions runs
- Wait until PR CI passes

### 4. Add pr-pull label

- Add `pr-pull` label to the PR
- Automatically merged

## Summary

| Step | Frequency |
|------|-----------|
| Tag + push + gh release create | Each release |
| Homebrew PR (gh + curl) | Each release |
| Wait for CI | Each release |
| pr-pull label | Each release |

**Note**: aud2txt may not yet exist in homebrew-tap. First release requires creating Formula/aud2txt.rb from scratch (see mov2mp4 formula as template).
