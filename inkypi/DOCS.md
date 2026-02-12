# InkyPi Add-on

## About

InkyPi is an open-source, customizable E-Ink display manager powered by a Raspberry Pi. This add-on packages InkyPi to run as a Home Assistant add-on.

## Features

- Web interface to configure and manage your e-ink display
- Multiple plugins: Clock, Weather, Calendar, Daily Newspaper/Comic, AI Image/Text, Image Upload
- Scheduled playlists to rotate content on your display
- Support for Pimoroni Inky and Waveshare e-Paper displays

## Requirements

- Home Assistant running on a Raspberry Pi with a connected e-ink display
- SPI and I2C interfaces must be enabled on the Raspberry Pi
- The add-on requires full hardware access to communicate with the display

## Supported Displays

### Pimoroni Inky
- Inky Impression (4", 5.7", 7.3", 13.3")
- Inky wHAT (4.2")

### Waveshare e-Paper
- Spectra 6 (E6) Full Color (4", 7.3", 13.3")
- Black and White (7.5", 13.3")
- Other Waveshare models with drivers in the [Waveshare EPD library](https://github.com/waveshareteam/e-Paper/tree/master/RaspberryPi_JetsonNano/python/lib/waveshare_epd)

## Configuration

### Display Type

- **mock** (default): Runs without physical display hardware. Rendered images are saved to disk. Useful for testing or running the web UI without a connected display.
- **inky**: Use when a Pimoroni Inky display with EEPROM is connected.

### Display Resolution

Width and height in pixels (default: 800x480). Only applies when display type is "mock" — Inky displays detect resolution automatically.

### Waveshare Device Model

If using a Waveshare display, set the `waveshare_device` option to your display model (e.g., `epd7in3f`). Leave empty for Pimoroni Inky displays.

The model name should match the driver filename (without `.py`) from the [Waveshare EPD library](https://github.com/waveshareteam/e-Paper/tree/master/RaspberryPi_JetsonNano/python/lib/waveshare_epd).

### API Keys

Certain plugins (AI Image, Weather, etc.) require API keys. These are stored in:

```
/config/inkypi/.env
```

Edit this file using the **File Editor** or **Studio Code Server** add-on. A template with all supported keys is created automatically on first run. See the [API Keys documentation](https://github.com/fatihak/InkyPi/blob/main/docs/api_keys.md) for details on obtaining keys.

### Advanced: device.json

The full InkyPi device configuration is stored at:

```
/config/inkypi/device.json
```

You can edit this file directly using the **File Editor** or **Studio Code Server** add-on. Browse to the `inkypi` folder in your Home Assistant configuration directory.

This file controls plugin settings, playlist configuration, display orientation, and other options not exposed in the add-on Configuration tab. Changes take effect after restarting the add-on.

## Usage

After starting the add-on, open the Web UI to configure your display. The InkyPi web interface allows you to:

1. Select and configure plugins
2. Set up scheduled playlists
3. Adjust display settings (orientation, refresh rate, etc.)
4. Upload custom images

## Data Persistence

Display configuration is stored at `/config/inkypi/device.json` and uploaded images are stored in the add-on's persistent data directory. Both survive add-on restarts and updates.
