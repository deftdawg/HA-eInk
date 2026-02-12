#!/usr/bin/with-contenv bashio

bashio::log.info "Starting InkyPi add-on..."

APP_DIR="/opt/inkypi"
DATA_DIR="/data"
HA_CONFIG_DIR="/config/inkypi"
CONFIG_DIR="${APP_DIR}/src/config"
VENV_DIR="${APP_DIR}/venv"

# Ensure persistent data directory structure
mkdir -p "${DATA_DIR}/images/plugins"
mkdir -p "${HA_CONFIG_DIR}"

# Initialize or migrate device.json
if [ ! -f "${HA_CONFIG_DIR}/device.json" ]; then
    if [ -f "${DATA_DIR}/device.json" ]; then
        bashio::log.info "Migrating device.json to HA config directory..."
        mv "${DATA_DIR}/device.json" "${HA_CONFIG_DIR}/device.json"
    else
        bashio::log.info "First run: initializing device configuration..."
        cp "${APP_DIR}/config_base/device.json" "${HA_CONFIG_DIR}/device.json"
    fi
fi

bashio::log.info "Device config at: /config/inkypi/device.json (editable via File Editor add-on)"

# Initialize .env for API keys on first run
if [ ! -f "${HA_CONFIG_DIR}/.env" ]; then
    bashio::log.info "Creating .env file for API keys..."
    cat > "${HA_CONFIG_DIR}/.env" <<'EOF'
# InkyPi API Keys
# Uncomment and fill in the keys for the plugins you want to use.
# See https://github.com/fatihak/InkyPi/blob/main/docs/api_keys.md
#OPEN_AI_SECRET=
#OPEN_WEATHER_MAP_SECRET=
#NASA_SECRET=
#UNSPLASH_ACCESS_KEY=
#GITHUB_SECRET=
#IMMICH_KEY=
EOF
fi

# Symlink persistent config into the app's expected location
ln -sf "${HA_CONFIG_DIR}/device.json" "${CONFIG_DIR}/device.json"
ln -sf "${HA_CONFIG_DIR}/.env" "${APP_DIR}/.env"

# Symlink persistent image storage
ln -sf "${DATA_DIR}/images/plugins" "${APP_DIR}/src/static/images/plugins"
if [ -f "${DATA_DIR}/images/current_image.png" ]; then
    ln -sf "${DATA_DIR}/images/current_image.png" "${APP_DIR}/src/static/images/current_image.png"
fi

# Apply display_type and resolution from add-on config
DISPLAY_TYPE=$(bashio::config 'display_type' 'mock')
RES_W=$(bashio::config 'display_width' '800')
RES_H=$(bashio::config 'display_height' '480')

jq --arg dt "${DISPLAY_TYPE}" --argjson res "[${RES_W},${RES_H}]" \
    '.display_type = $dt | .resolution = $res' \
    "${HA_CONFIG_DIR}/device.json" > "${HA_CONFIG_DIR}/device.json.tmp" \
    && mv "${HA_CONFIG_DIR}/device.json.tmp" "${HA_CONFIG_DIR}/device.json"

bashio::log.info "Display type: ${DISPLAY_TYPE}, resolution: ${RES_W}x${RES_H}"

# Read Waveshare device configuration
WS_DEVICE=$(bashio::config 'waveshare_device' '')

if bashio::var.has_value "${WS_DEVICE}"; then
    bashio::log.info "Waveshare device configured: ${WS_DEVICE}"

    # Fetch Waveshare driver if not already present
    DRIVER_DIR="${APP_DIR}/src/display/waveshare_epd"
    DRIVER_FILE="${DRIVER_DIR}/${WS_DEVICE}.py"

    if [ ! -f "${DRIVER_FILE}" ]; then
        bashio::log.info "Fetching Waveshare driver for ${WS_DEVICE}..."
        DRIVER_URL="https://raw.githubusercontent.com/waveshareteam/e-Paper/master/RaspberryPi_JetsonNano/python/lib/waveshare_epd/${WS_DEVICE}.py"
        if curl --silent --fail -o "${DRIVER_FILE}" "${DRIVER_URL}"; then
            bashio::log.info "Waveshare driver downloaded successfully"
        else
            bashio::log.error "Failed to download Waveshare driver for ${WS_DEVICE}"
        fi

        # Also fetch epdconfig.py if needed
        EPD_CONFIG="${DRIVER_DIR}/epdconfig.py"
        if [ ! -f "${EPD_CONFIG}" ]; then
            curl --silent --fail -o "${EPD_CONFIG}" \
                "https://raw.githubusercontent.com/waveshareteam/e-Paper/refs/heads/master/RaspberryPi_JetsonNano/python/lib/waveshare_epd/epdconfig.py" || true
        fi

        # Install additional Waveshare Python dependencies
        bashio::log.info "Installing Waveshare Python dependencies..."
        "${VENV_DIR}/bin/pip" install gpiozero==2.0.1 lgpio==0.2.2.0 RPi.GPIO==0.7.1 || true
    fi

    # Update device.json with display_type
    jq --arg dt "${WS_DEVICE}" '.display_type = $dt' "${HA_CONFIG_DIR}/device.json" > "${HA_CONFIG_DIR}/device.json.tmp" \
        && mv "${HA_CONFIG_DIR}/device.json.tmp" "${HA_CONFIG_DIR}/device.json"
fi

bashio::log.info "Starting InkyPi web server..."

# Use the ingress port assigned by HA supervisor
export PORT=$(bashio::addon.ingress_port)
bashio::log.info "Listening on port ${PORT} (ingress)"

cd "${APP_DIR}"
source "${VENV_DIR}/bin/activate"
exec python -u src/inkypi.py
