#!/usr/bin/with-contenv bashio

bashio::log.info "Starting NeoFrame add-on..."

# Read configuration
IMAGE_SOURCE_URL=$(bashio::config 'image_source_url')
RESOLVE_URL_IPV4_FIRST=$(bashio::config 'resolve_url_ipv4_first')
ESP32_HOSTNAME=$(bashio::config 'esp32_hostname')
ESP32_IP=$(bashio::config 'esp32_ip')
DNS_SERVER=$(bashio::config 'dns_server')
POLL_INTERVAL=$(bashio::config 'poll_interval')

DITHER_MODE=$(bashio::config 'dither_mode')
DITHER_TYPE=$(bashio::config 'dither_type')
DITHER_STRENGTH=$(bashio::config 'dither_strength')
ROTATION=$(bashio::config 'rotation')
SCALING=$(bashio::config 'scaling')
CUSTOM_SCALE=$(bashio::config 'custom_scale')
CONTRAST=$(bashio::config 'contrast')

QR_CODE_ENABLED=$(bashio::config 'qr_code_enabled')
QR_CONTENT_TYPE=$(bashio::config 'qr_content_type')
QR_CUSTOM_TEXT=$(bashio::config 'qr_custom_text')
QR_POSITION=$(bashio::config 'qr_position')
QR_MARGIN=$(bashio::config 'qr_margin')
QR_COLOR=$(bashio::config 'qr_color')
QR_BACKGROUND_COLOR=$(bashio::config 'qr_background_color')
QR_BORDER_SIZE=$(bashio::config 'qr_border_size')
AUTOSAVE=$(bashio::config 'autosave')
QR_EXIF_LABELS=$(bashio::config 'qr_exif_labels')
QR_EXIF_GPS=$(bashio::config 'qr_exif_gps')
QR_EXIF_MAPS=$(bashio::config 'qr_exif_maps')

# Resolve ESP32 IP via DNS, fall back to configured IP
RESOLVED_IP=$(nslookup "${ESP32_HOSTNAME}" "${DNS_SERVER}" 2>/dev/null | grep 'Address' | grep -v '#' | tail -1 | awk '{print $2}')
if bashio::var.has_value "${RESOLVED_IP}"; then
    bashio::log.info "Resolved ${ESP32_HOSTNAME} to ${RESOLVED_IP}"
    ESP32_IP="${RESOLVED_IP}"
else
    bashio::log.warning "Could not resolve ${ESP32_HOSTNAME}, using fallback IP: ${ESP32_IP}"
fi

# Build JSON config matching cli.ts expected format
CONFIG_JSON=$(cat <<EOF
{
  "esp32Ip": "${ESP32_IP}",
  "resolveUrlIpv4First": ${RESOLVE_URL_IPV4_FIRST},
  "ditherMode": "${DITHER_MODE}",
  "ditherType": "${DITHER_TYPE}",
  "rotation": "${ROTATION}",
  "scaling": "${SCALING}",
  "customScale": "${CUSTOM_SCALE}",
  "ditherStrength": "${DITHER_STRENGTH}",
  "contrast": "${CONTRAST}",
  "qrCodeEnabled": ${QR_CODE_ENABLED},
  "qrContentType": "${QR_CONTENT_TYPE}",
  "qrCustomText": "${QR_CUSTOM_TEXT}",
  "qrPosition": "${QR_POSITION}",
  "qrMargin": "${QR_MARGIN}",
  "qrColor": "${QR_COLOR}",
  "qrBackgroundColor": "${QR_BACKGROUND_COLOR}",
  "qrBorderSize": "${QR_BORDER_SIZE}",
  "autosave": ${AUTOSAVE},
  "qrExifLabels": ${QR_EXIF_LABELS},
  "qrExifGps": ${QR_EXIF_GPS},
  "qrExifMaps": ${QR_EXIF_MAPS}
}
EOF
)

bashio::log.info "NeoFrame IP: ${ESP32_IP}"
bashio::log.info "Image source: ${IMAGE_SOURCE_URL}"
bashio::log.info "Poll interval: ${POLL_INTERVAL}s"

LAST_UPDATE_DATE=$(date +%s)

while true; do
    if bun /opt/neoframe/dist/cli.js "${IMAGE_SOURCE_URL}" "${CONFIG_JSON}" --if-modified-since "${LAST_UPDATE_DATE}"; then
        LAST_UPDATE_DATE=$(date +%s)
        bashio::log.info "Frame updated at $(date +"%F %T %Z")"
    fi
    sleep "${POLL_INTERVAL}"
done
