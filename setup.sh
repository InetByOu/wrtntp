#!/bin/sh

# wrtntp setup script
# Installer untuk wrtntp - OpenWRT NTP Time Synchronization

set -e

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Configuration
SCRIPT_NAME="wrtntp"
INSTALL_PATH="/usr/bin"
SERVICE_PATH="/etc/init.d"
CONFIG_DIR="/etc/wrtntp"
REPO_URL="https://raw.githubusercontent.com/InetByOu/wrtntp/main"

print_status() {
    echo "${BLUE}[wrtntp]${NC} $1"
}

print_success() {
    echo "${GREEN}[wrtntp] ✓${NC} $1"
}

print_warning() {
    echo "${YELLOW}[wrtntp] ⚠${NC} $1"
}

print_error() {
    echo "${RED}[wrtntp] ✗${NC} $1"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_error "Script harus dijalankan sebagai root"
        exit 1
    fi
}

check_openwrt() {
    if [ ! -f "/etc/openwrt_release" ]; then
        print_warning "System tidak terdeteksi sebagai OpenWRT"
    fi
}

download_wrtntp() {
    print_status "Mendownload wrtntp dari GitHub..."
    
    if command -v wget >/dev/null 2>&1; then
        if wget -q "$REPO_URL/wrtntp" -O "/tmp/wrtntp"; then
            print_success "Berhasil download wrtntp"
            return 0
        fi
    elif command -v curl >/dev/null 2>&1; then
        if curl -s -L "$REPO_URL/wrtntp" -o "/tmp/wrtntp"; then
            print_success "Berhasil download wrtntp"
            return 0
        fi
    fi
    
    print_error "Gagal download wrtntp dari GitHub"
    return 1
}

install_dependencies() {
    print_status "Memeriksa dependencies..."
    
    local missing_deps=""
    
    # Check basic dependencies
    for dep in date; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps="$missing_deps $dep"
        fi
    done
    
    # Check NTP client
    if ! command -v ntpclient >/dev/null 2>&1 && ! command -v rdate >/dev/null 2>&1; then
        missing_deps="$missing_deps ntpclient"
    fi
    
    # Check HTTP client
    if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
        missing_deps="$missing_deps wget"
    fi
    
    if [ -n "$missing_deps" ]; then
        print_warning "Dependencies yang tidak tersedia: $missing_deps"
        
        if command -v opkg >/dev/null 2>&1; then
            print_status "Menginstall dependencies menggunakan opkg..."
            opkg update || print_warning "Gagal update package list"
            
            for dep in $missing_deps; do
                case $dep in
                    ntpclient)
                        opkg install ntpclient || opkg install rdate || print_warning "Gagal install ntp client"
                        ;;
                    wget)
                        opkg install wget || opkg install curl || print_warning "Gagal install http client"
                        ;;
                    *)
                        opkg install "$dep" 2>/dev/null || print_warning "Gagal install $dep"
                        ;;
                esac
            done
        else
            print_warning "opkg tidak tersedia, install dependencies manual"
        fi
    else
        print_success "Semua dependencies tersedia"
    fi
}

install_wrtntp() {
    print_status "Menginstall wrtntp..."
    
    # Install main script
    if cp "/tmp/wrtntp" "$INSTALL_PATH/$SCRIPT_NAME"; then
        chmod +x "$INSTALL_PATH/$SCRIPT_NAME"
        print_success "wrtntp installed ke $INSTALL_PATH/$SCRIPT_NAME"
    else
        print_error "Gagal install wrtntp"
        return 1
    fi
    
    return 0
}

create_service() {
    print_status "Membuat service file..."
    
    mkdir -p "$SERVICE_PATH"
    
    cat > "$SERVICE_PATH/$SCRIPT_NAME" << 'EOF'
#!/bin/sh /etc/rc.common

USE_PROCD=1
START=95
STOP=01

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/wrtntp --service
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_set_param respawn
    procd_set_param user root
    procd_close_instance
}

stop_service() {
    pkill -f "wrtntp --service"
}
EOF

    chmod +x "$SERVICE_PATH/$SCRIPT_NAME"
    print_success "Service file created"
}

enable_service() {
    print_status "Mengenable service..."
    
    if [ -f "$SERVICE_PATH/$SCRIPT_NAME" ]; then
        if "$SERVICE_PATH/$SCRIPT_NAME" enable; then
            print_success "Service enabled untuk startup"
        else
            print_warning "Gagal enable service"
        fi
    fi
}

create_config() {
    print_status "Membuat configuration directory..."
    
    mkdir -p "$CONFIG_DIR"
    
    if [ ! -f "$CONFIG_DIR/wrtntp.conf" ]; then
        cat > "$CONFIG_DIR/wrtntp.conf" << 'EOF'
# wrtntp Configuration
SYNC_ON_BOOT=true
BOOT_DELAY=30
NTP_SERVERS="pool.ntp.org time.google.com ntp.ubuntu.com"
MAX_RETRIES=3
EOF
        print_success "Default configuration created"
    fi
}

test_installation() {
    print_status "Testing installation..."
    
    if command -v "$SCRIPT_NAME" >/dev/null 2>&1; then
        if "$SCRIPT_NAME" --help >/dev/null 2>&1; then
            print_success "Installation test passed"
            return 0
        fi
    fi
    
    print_error "Installation test failed"
    return 1
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -s, --no-service    Skip service installation"
    echo "  -d, --no-deps       Skip dependency installation"
    echo
    echo "Examples:"
    echo "  $0                   # Full installation"
    echo "  $0 --no-service      # Install tanpa service"
    echo "  $0 --no-deps         # Install tanpa dependencies"
}

main() {
    local install_service=true
    local install_deps=true
    
    # Parse command line arguments
    while [ $# -gt 0 ]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -s|--no-service)
                install_service=false
                ;;
            -d|--no-deps)
                install_deps=false
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
    
    print_status "Starting wrtntp installation..."
    echo
    
    # System checks
    check_root
    check_openwrt
    
    # Download wrtntp
    if ! download_wrtntp; then
        print_error "Tidak dapat melanjutkan instalasi"
        exit 1
    fi
    
    # Install dependencies
    if [ "$install_deps" = "true" ]; then
        install_dependencies
    fi
    
    # Install wrtntp
    if ! install_wrtntp; then
        exit 1
    fi
    
    # Install service
    if [ "$install_service" = "true" ]; then
        create_service
        create_config
        enable_service
    fi
    
    # Test installation
    test_installation
    
    echo
    print_success "Installation completed successfully!"
    echo
    echo "wrtntp siap digunakan! Ketik 'wrtntp' untuk memulai."
    echo
    echo "Contoh penggunaan:"
    echo "  wrtntp                    # Mode interaktif"
    echo "  wrtntp --sync             # Sync waktu sekarang"
    echo "  wrtntp --status           # Status sistem"
    echo "  wrtntp --help             # Bantuan"
}

# Run main function
main "$@"
