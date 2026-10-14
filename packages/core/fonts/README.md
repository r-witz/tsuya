# Bundled fonts

Subset, self-hosted copies of [Inter](https://github.com/rsms/inter) and
[Geist Mono](https://github.com/vercel/geist-font), used by the design system.
Subsetting is a one-time step: the outputs below are committed, so the normal
build stays Node-only and never needs Python/uv. `manifest.json` records the
SHA-256 of every file in this folder and in `packages/flutter/fonts/`; a test
checks the committed files against it.

## Sources

| Font       | Version | Archive                                                                                                        | SHA-256                                                            |
| ---------- | ------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Inter      | v4.1    | [`Inter-4.1.zip`](https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip)                          | `9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e` |
| Geist Mono | v1.7.2  | [`geist-font-v1.7.2.zip`](https://github.com/vercel/geist-font/releases/download/v1.7.2/geist-font-v1.7.2.zip) | `7fc800d2ac6b92844895196e5041aca55d814c15db70c44f79b3b83ab82b04e2` |

Both are licensed under the SIL Open Font License 1.1, with no Reserved Font
Name declared in either archive's licence file. `OFL.txt` (identical in this
folder and in `packages/flutter/fonts/`) carries both copyright lines verbatim
followed by the full OFL 1.1 text.

Subsetting uses `fonttools[woff]==4.66.1` (pinned), run through `uvx` so
nothing is installed globally.

## Reproducing the outputs

Run from the repository root:

```bash
WORK=$(mktemp -d)

curl -L -o "$WORK/Inter-4.1.zip" https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
curl -L -o "$WORK/geist-font-v1.7.2.zip" https://github.com/vercel/geist-font/releases/download/v1.7.2/geist-font-v1.7.2.zip

# Expect:
#   9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e  Inter-4.1.zip
#   7fc800d2ac6b92844895196e5041aca55d814c15db70c44f79b3b83ab82b04e2  geist-font-v1.7.2.zip
sha256sum "$WORK/Inter-4.1.zip" "$WORK/geist-font-v1.7.2.zip"

unzip -q "$WORK/Inter-4.1.zip" -d "$WORK/inter"
unzip -q "$WORK/geist-font-v1.7.2.zip" -d "$WORK/geist"

FT='fonttools[woff]==4.66.1'
UNICODES='U+0000-024F,U+0300-036F,U+2000-206F,U+20A0-20CF,U+2100-215F,U+2190-21FF,U+2200-22FF,U+25A0-25FF,U+2713-2717,U+FEFF,U+FFFD'

mkdir -p packages/core/fonts packages/flutter/fonts

# Web (WOFF2) outputs
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-Regular.ttf"   --output-file=packages/core/fonts/inter-400.woff2      --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --flavor=woff2 --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-Medium.ttf"    --output-file=packages/core/fonts/inter-500.woff2      --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --flavor=woff2 --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-SemiBold.ttf"  --output-file=packages/core/fonts/inter-600.woff2      --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --flavor=woff2 --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-Bold.ttf"      --output-file=packages/core/fonts/inter-700.woff2      --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --flavor=woff2 --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-ExtraBold.ttf" --output-file=packages/core/fonts/inter-800.woff2      --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --flavor=woff2 --no-hinting
uvx --from "$FT" pyftsubset "$WORK/geist/geist-font/GeistMono/ttf/GeistMono-Regular.ttf" --output-file=packages/core/fonts/geist-mono-400.woff2 --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --flavor=woff2 --no-hinting

# Flutter (plain TTF) outputs - same options, no --flavor
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-Regular.ttf"   --output-file=packages/flutter/fonts/Inter-400.ttf     --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-Medium.ttf"    --output-file=packages/flutter/fonts/Inter-500.ttf     --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-SemiBold.ttf"  --output-file=packages/flutter/fonts/Inter-600.ttf     --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-Bold.ttf"      --output-file=packages/flutter/fonts/Inter-700.ttf     --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --no-hinting
uvx --from "$FT" pyftsubset "$WORK/inter/extras/ttf/Inter-ExtraBold.ttf" --output-file=packages/flutter/fonts/Inter-800.ttf     --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --no-hinting
uvx --from "$FT" pyftsubset "$WORK/geist/geist-font/GeistMono/ttf/GeistMono-Regular.ttf" --output-file=packages/flutter/fonts/GeistMono-400.ttf --unicodes="$UNICODES" --layout-features+=tnum,case,zero --name-IDs='*' --notdef-outline --no-hinting

rm -rf "$WORK"
```

Option purposes:

- `--unicodes`: restricts the glyph set to Latin + extended Latin, combining
  marks, general punctuation, currency, letterlike symbols, arrows, math
  operators, geometric shapes, a few check/cross marks, BOM and the
  replacement character — what the design system actually uses.
- `--layout-features+=tnum,case,zero`: keeps pyftsubset's default shaping
  features (kerning, standard ligatures, etc.) and adds tabular figures,
  case-sensitive forms, and the slashed zero.
- `--name-IDs='*'`: keeps every `name` table record (full metadata, licence
  notice, etc.) instead of pyftsubset's default trimmed set.
- `--notdef-outline`: keeps a visible `.notdef` glyph instead of an empty box.
- `--flavor=woff2`: packs the output as WOFF2 for web delivery; omitted for
  the Flutter TTF outputs, which stay plain TrueType.
- `--no-hinting`: drops hinting. Hinting was kept in a first pass, but every
  Inter WOFF2 came out above the 40960-byte budget (60076-61860 B), so all
  twelve outputs were redone with `--no-hinting` per the normative rule. This
  brought every file down (Inter WOFF2: 44100-45492 B; Geist Mono WOFF2:
  14224 B) but did not bring the five Inter WOFF2 files under the budget —
  see sizes below. No further parameter was changed to force the budget,
  since the unicode ranges and layout features are fixed/normative.

## Output sizes (bytes)

| File                                       | Size   |
| ------------------------------------------ | ------ |
| `packages/core/fonts/inter-400.woff2`      | 44100  |
| `packages/core/fonts/inter-500.woff2`      | 45388  |
| `packages/core/fonts/inter-600.woff2`      | 45492  |
| `packages/core/fonts/inter-700.woff2`      | 45460  |
| `packages/core/fonts/inter-800.woff2`      | 45380  |
| `packages/core/fonts/geist-mono-400.woff2` | 14224  |
| `packages/flutter/fonts/Inter-400.ttf`     | 119568 |
| `packages/flutter/fonts/Inter-500.ttf`     | 121616 |
| `packages/flutter/fonts/Inter-600.ttf`     | 121544 |
| `packages/flutter/fonts/Inter-700.ttf`     | 121316 |
| `packages/flutter/fonts/Inter-800.ttf`     | 121448 |
| `packages/flutter/fonts/GeistMono-400.ttf` | 33020  |
