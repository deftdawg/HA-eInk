# eInk Home Assistant Add-on Repository

This repository provides Home Assistant add-ons for e-ink displays.

## Add-ons

### InkyPi

[InkyPi](https://github.com/deftdawg/InkyPi) (a fork of [fatihak/InkyPi](https://github.com/fatihak/InkyPi)) runs directly from your Home Assistant instance to drive Raspberry Pi-connected e-ink displays.

### NeoFrame

[NeoFrame](https://github.com/deftdawg/neoframe) drives a Good Display 13.3" Spectra 6 e-ink display powered by an ESP32. The NeoFrame add-on polls InkyPi for image changes and pushes them to the display.

## Installation

[![Open your Home Assistant instance and show the add add-on repository dialog.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fdeftdawg%2FHA-eInk)

Or manually:

1. Go to **Settings → Add-ons → Add-on Store**.
2. Click the three-dot menu in the top right and select **Repositories**.
3. Paste the URL: `https://github.com/deftdawg/HA-eInk`
4. Click **Add**, then refresh the page to find the InkyPi and NeoFrame add-ons.
