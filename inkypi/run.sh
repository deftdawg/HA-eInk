#!/usr/bin/with-contenv bashio

bashio::log.info "Starting InkyPi add-on..."

APP_DIR="/opt/inkypi"
DATA_DIR="/data"
CONFIG_DIR="${APP_DIR}/src/config"
VENV_DIR="${APP_DIR}/venv"

# Ensure persistent data directory structure
mkdir -p "${DATA_DIR}/images/plugins"

# Initialize device.json on first run
if [ ! -f "${DATA_DIR}/device.json" ]; then
    bashio::log.info "First run: initializing device configuration..."
    cp "${APP_DIR}/config_base/device.json" "${DATA_DIR}/device.json"
fi

# Symlink persistent config into the app's expected location
ln -sf "${DATA_DIR}/device.json" "${CONFIG_DIR}/device.json"

# Symlink persistent image storage
ln -sf "${DATA_DIR}/images/plugins" "${APP_DIR}/src/static/images/plugins"
if [ -f "${DATA_DIR}/images/current_image.png" ]; then
    ln -sf "${DATA_DIR}/images/current_image.png" "${APP_DIR}/src/static/images/current_image.png"
fi

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
    jq --arg dt "${WS_DEVICE}" '.display_type = $dt' "${DATA_DIR}/device.json" > "${DATA_DIR}/device.json.tmp" \
        && mv "${DATA_DIR}/device.json.tmp" "${DATA_DIR}/device.json"
fi

bashio::log.info "Starting InkyPi web server..."

cd "${APP_DIR}"
source "${VENV_DIR}/bin/activate"
exec python -u src/inkypi.py
