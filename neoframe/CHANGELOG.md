# Changelog

## 1.2.3

- Replaced the `auto → photo` fallback with `restoreFaintDetail` directly inside `graphics` mode so dim text on coloured/dark backgrounds (e.g., InkyPi Word Clock) and subtle overlapping shapes (e.g., weather clouds) remain legible while keeping deep uniform backgrounds and crisp active text.

## 1.2.2

- Improved `graphics` mode dark-tone handling (neutral Bayer spread, dark-color adaptation guard, and dark-background edge-sharpening guard).

## 1.2.1

- Force a fresh checkout of the neoframe code on every rebuild: the Docker layer cache was reusing the pre-1.2.0 clone, so 1.2.0 shipped with the old renderer.

## 1.2.0

- Updated automatic split rendering: `graphics` images split 2-way (`graphics` vs `legacy`) and `photo` images split 3-way (`vivid` vs `photo` vs `legacy`).
- Added diagonal split options (`diagonal` and `diagonal-bl-tr`) and optional `split_render_mode_c` override.
- Added high-contrast method labels oriented along each segment's longest frame edge.

## 1.1.0

- Added Spectra 6 rendering modes (`auto`, `vivid`, `photo`, `graphics`, `legacy`) with `auto` defaulting photos to `vivid` and UI/dashboards to `graphics`.
- Added `ink_saturation` setting (`0.0`–`1.0`) for measured-ink palette blending.
- Added seamless A/B split rendering controls (`split_mode`, `split_render_mode`) to compare any two rendering modes side-by-side (`left-right` or `top-bottom`) directly from Home Assistant add-on settings.

## 1.0.4

- Fixed startup crash loop: the DNS resolution step could time out and, because
  bashio runs scripts with `set -o errexit -o pipefail`, kill the whole script
  with exit 1 before the IP fallback ever ran. DNS is now skipped when
  esp32_hostname is already an IP address, and the lookup pipeline is guarded
  with `|| true`.

## 1.0.2

- Added a default-enabled option to resolve the image source URL hostname using IPv4 first.

## 1.0.0

- Initial release
- Polls InkyPi for image changes and pushes to NeoFrame display
- Configurable dithering, scaling, rotation, and QR code options
