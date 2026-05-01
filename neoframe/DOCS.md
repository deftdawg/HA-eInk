# NeoFrame Add-on

## About

NeoFrame is an ESP32-driven 13.3" Good Display Spectra 6 e-ink photo frame. This add-on polls an image source (typically the InkyPi add-on), dithers it for the 6-color e-ink palette, and pushes the processed image to the NeoFrame display over WiFi.

## How It Works

1. The add-on periodically fetches the image at the configured URL
2. If the image has changed since the last update, it processes it:
   - Applies rotation and scaling
   - Adjusts contrast
   - Dithers to the Spectra 6 color palette (black, white, red, green, blue, yellow)
   - Optionally overlays a QR code
3. Uploads the processed image to the ESP32 via HTTP
4. The ESP32 drives the e-ink display refresh

## Requirements

- A Good Display NeoFrame 13.3" Spectra 6 e-ink display with ESP32-S3 controller
- The ESP32 must be accessible on the network from the Home Assistant host
- An image source URL (typically the InkyPi add-on running on the same Home Assistant instance)

## Typical Setup with InkyPi

1. Install and configure the **InkyPi** add-on with `display_type: mock` and your desired resolution
2. Set up plugins and playlists in the InkyPi web UI to generate images
3. Install the **NeoFrame** add-on
4. Set the `image_source_url` to point to InkyPi's image output (default: `http://homeassistant.local:8180/static/images/current_image.png`)
5. Configure the ESP32 hostname or IP address
6. Start the NeoFrame add-on — it will poll for changes and push updates automatically

## Finding Your ESP32 Hostname/IP

The ESP32 running NeoFrame firmware typically broadcasts a hostname on your network. The default hostname is `esp32s3-B049A4`. You can find the IP address by:

- Checking your router's DHCP client list
- Running `nslookup esp32s3-B049A4 <your-router-ip>` from a terminal
- Using the ESP32's default access point IP (`192.168.4.1`) if connected directly

The add-on will attempt DNS resolution automatically using the configured DNS server and fall back to the configured IP address.

## Configuration

### Connection Settings

| Option | Default | Description |
|--------|---------|-------------|
| `image_source_url` | `http://homeassistant.local:8180/static/images/current_image.png` | URL to poll for the source image |
| `resolve_url_ipv4_first` | `true` | Prefer IPv4 when resolving the source image URL hostname |
| `esp32_hostname` | `esp32s3-B049A4` | ESP32 hostname for DNS resolution |
| `esp32_ip` | `192.168.4.1` | Fallback IP if DNS fails |
| `dns_server` | `10.0.0.1` | DNS server for hostname resolution |
| `poll_interval` | `80` | Seconds between image checks |

### Image Processing

| Option | Default | Description |
|--------|---------|-------------|
| `dither_mode` | `sixColor` | `sixColor` for Spectra 6, `bw` for black/white |
| `dither_type` | `floydSteinberg` | Algorithm: `floydSteinberg`, `atkinson`, `ordered`, `none` |
| `dither_strength` | `1.0` | Dithering intensity (0.0–2.0) |
| `contrast` | `1.2` | Contrast multiplier (1.0 = no change) |
| `rotation` | `0` | Image rotation: `0`, `90`, `180`, `270` |
| `scaling` | `fit_8x10` | `fill`, `fit`, `fit_8x10`, or `custom` |
| `custom_scale` | `49` | Scale percentage when scaling is `custom` |

### QR Code

| Option | Default | Description |
|--------|---------|-------------|
| `qr_code_enabled` | `false` | Overlay a QR code on the image |
| `qr_content_type` | `custom` | `url` or `custom` |
| `qr_custom_text` | (empty) | Custom QR code content |
| `qr_position` | `bottom-right` | Corner placement |
| `qr_margin` | `20` | Pixels from edge |
| `qr_color` | `rgb(0, 0, 0)` | QR module color |
| `qr_background_color` | `rgb(255, 255, 255)` | QR background |
| `qr_border_size` | `1` | Quiet zone size |
| `autosave` | `true` | Save dithered image to disk |
| `qr_exif_labels` | `false` | Include EXIF labels in QR |
| `qr_exif_gps` | `false` | Include GPS in QR |
| `qr_exif_maps` | `false` | Include maps link in QR |

## Instant Updates with Home Assistant Automation

By default the add-on polls every `poll_interval` seconds. For instant updates when InkyPi renders a new image, add a sensor and automation to your Home Assistant configuration.

### 1. Add an image-change sensor to `configuration.yaml`

```yaml
command_line:
  - sensor:
      name: InkyPi Image Hash
      command: >-
        curl -sf http://homeassistant.local:8180/static/images/current_image.png |
        md5sum | cut -d' ' -f1
      scan_interval: 30
      value_template: "{{ value }}"
```

### 2. Add the automation

Copy the contents of `automations/neoframe_on_inkypi_update.yaml` into your `automations.yaml`, or import it via **Settings → Automations → ⋮ → Create from YAML**.

When the sensor detects a new image hash, the automation restarts the NeoFrame add-on, which immediately fetches and pushes the updated image.
