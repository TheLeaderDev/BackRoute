#!/bin/bash

# ============================================================
#   BackRoute - Easy Installer
#   Version : 1.1.0
#   GitHub  : https://github.com/TheLeaderDev/BackRoute
#   Author  : TheLeaderDev
# ============================================================

# ─── Fix CRLF issues ───────────────────────────────────────
if grep -q $'\r' "$0" 2>/dev/null; then
    sed -i 's/\r$//' "$0"
    exec bash "$0" "$@"
fi

VERSION="1.1.0"
GITHUB="github.com/TheLeaderDev/BackRoute"
INSTALL_DIR="/root/BackRoute"
PANEL_SCRIPT="$INSTALL_DIR/BackRoute.sh"
PANEL_URL="https://leaderdev.info/shell/BackRoute/core/BackRoute.sh"
FLAG_FILE="$INSTALL_DIR/.installed"
LOG_FILE="$INSTALL_DIR/backroute.log"

# ─── Colors ───────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Create log directory and file ────────────────────────
mkdir -p "$INSTALL_DIR" 2>/dev/null
touch "$LOG_FILE" 2>/dev/null
chmod 644 "$LOG_FILE" 2>/dev/null

# ─── Logging Function ──────────────────────────────────────
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[${timestamp}] [${level}] ${message}"
    
    # Write to log file
    echo "$log_entry" >> "$LOG_FILE" 2>/dev/null
    
    # Rotate log if too large (keep last 1000 lines)
    if [ -f "$LOG_FILE" ]; then
        local lines=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
        if [ "$lines" -gt 1000 ] 2>/dev/null; then
            tail -n 500 "$LOG_FILE" > "${LOG_FILE}.tmp" 2>/dev/null
            mv "${LOG_FILE}.tmp" "$LOG_FILE" 2>/dev/null
        fi
    fi
}

# ─── Helpers ──────────────────────────────────────────────
info()    { 
    local msg="$*"
    echo -e "${CYAN}  i  ${WHITE}$msg${RESET}"
    log_message "INFO" "$msg"
}
success() { 
    local msg="$*"
    echo -e "${GREEN}  v  $msg${RESET}"
    log_message "SUCCESS" "$msg"
}
warn()    { 
    local msg="$*"
    echo -e "${YELLOW}  !  $msg${RESET}"
    log_message "WARNING" "$msg"
}
error()   { 
    local msg="$*"
    echo -e "${RED}  x  $msg${RESET}"
    log_message "ERROR" "$msg"
}
step()    { 
    local msg="$*"
    echo -e "\n${BOLD}${BLUE}  --> $msg${RESET}"
    log_message "STEP" "$msg"
}
divider() { echo -e "${GRAY}  $(printf '─%.0s' $(seq 1 58))${RESET}"; }

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${WHITE}BackRoute - Easy Installer${RESET}  ${GRAY}v${VERSION}${RESET}                        ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GRAY}${GITHUB}${RESET}                              ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    log_message "INFO" "Installer started (version $VERSION)"
}

is_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root."
        error "Please use sudo or log in as root."
        log_message "ERROR" "Script must be run as root"
        exit 1
    fi
    log_message "INFO" "Root privileges confirmed"
}

prereqs_installed() {
    [ -f "$FLAG_FILE" ] && return 0
    return 1
}

mark_prereqs_installed() {
    mkdir -p "$INSTALL_DIR" 2>/dev/null
    touch "$FLAG_FILE" 2>/dev/null
    chmod 755 "$INSTALL_DIR" 2>/dev/null
    chmod 644 "$FLAG_FILE" 2>/dev/null
    log_message "INFO" "Prerequisites marked as installed"
}

set_permissions() {
    step "Setting permissions for BackRoute files and directories..."
    log_message "INFO" "Setting permissions..."
    
    # ─── Set directory permissions ────────────────────────
    chmod 755 "$INSTALL_DIR" 2>/dev/null
    success "Directory permissions set: $INSTALL_DIR"
    log_message "INFO" "Directory permissions set: $INSTALL_DIR"
    
    # ─── Set file permissions ─────────────────────────────
    if [ -f "$PANEL_SCRIPT" ]; then
        chmod 755 "$PANEL_SCRIPT"
        success "Panel script permissions set: $PANEL_SCRIPT"
        log_message "INFO" "Panel script permissions set"
    fi
    
    if [ -f "$INSTALL_DIR/backroute-start.sh" ]; then
        chmod 755 "$INSTALL_DIR/backroute-start.sh"
        success "Start script permissions set"
        log_message "INFO" "Start script permissions set"
    fi
    
    if [ -f "$INSTALL_DIR/backroute-watchdog.sh" ]; then
        chmod 755 "$INSTALL_DIR/backroute-watchdog.sh"
        success "Watchdog script permissions set"
        log_message "INFO" "Watchdog script permissions set"
    fi
    
    if [ -f "$INSTALL_DIR/backroute.info" ]; then
        chmod 644 "$INSTALL_DIR/backroute.info"
        success "Info file permissions set"
        log_message "INFO" "Info file permissions set"
    fi
    
    if [ -f "$LOG_FILE" ]; then
        chmod 644 "$LOG_FILE"
        success "Log file permissions set"
        log_message "INFO" "Log file permissions set"
    fi
    
    # ─── Set command permissions ──────────────────────────
    if [ -f "/usr/local/bin/BackRoute" ]; then
        chmod 755 "/usr/local/bin/BackRoute"
        log_message "INFO" "BackRoute command permissions set"
    fi
    
    if [ -f "/usr/local/bin/backroute" ]; then
        chmod 755 "/usr/local/bin/backroute"
        log_message "INFO" "backroute command permissions set"
    fi
    
    success "All permissions set successfully"
    log_message "SUCCESS" "All permissions set"
}

# ============================================================
#   Install Prerequisites
# ============================================================

install_prerequisites() {
    print_header
    echo -e "${BOLD}${YELLOW}  Installing BackRoute prerequisites...${RESET}"
    divider
    echo ""
    log_message "INFO" "Starting installation process"

    # ─── Set non-interactive mode ────────────────────────
    export DEBIAN_FRONTEND=noninteractive
    export DEBCONF_NONINTERACTIVE_SEEN=true
    log_message "INFO" "Non-interactive mode enabled"

    # ─── Check if prerequisites already installed ────────
    if prereqs_installed; then
        success "Prerequisites already installed. Skipping..."
        log_message "INFO" "Prerequisites already installed, skipping"
        echo ""
    else
        log_message "INFO" "Installing prerequisites for the first time"
        
        # ─── Update System Packages ────────────────────────
        step "Updating system packages"
        log_message "INFO" "Updating system packages..."
        apt-get update -y -q 2>/dev/null
        apt-get upgrade -y -q 2>/dev/null
        success "System updated successfully"
        log_message "SUCCESS" "System updated"

        # ─── Install Required Packages ────────────────────
        step "Installing netplan.io"
        log_message "INFO" "Installing netplan.io..."
        apt-get install -y -q netplan.io 2>/dev/null
        success "netplan.io installed"
        log_message "SUCCESS" "netplan.io installed"

        step "Installing iproute2"
        log_message "INFO" "Installing iproute2..."
        apt-get install -y -q iproute2 2>/dev/null
        success "iproute2 installed"
        log_message "SUCCESS" "iproute2 installed"

        step "Installing iputils-ping"
        log_message "INFO" "Installing iputils-ping..."
        apt-get install -y -q iputils-ping 2>/dev/null
        success "iputils-ping installed"
        log_message "SUCCESS" "iputils-ping installed"

        # ─── Handle openssh-server configuration ──────────
        step "Configuring openssh-server (non-interactive)..."
        log_message "INFO" "Configuring openssh-server..."
        apt-get install -y -q openssh-server 2>/dev/null || true
        success "openssh-server configured"
        log_message "SUCCESS" "openssh-server configured"

        # ─── Mark prerequisites as installed ──────────────
        mark_prereqs_installed
        success "Prerequisites installation completed"
        log_message "SUCCESS" "Prerequisites installation completed"
        echo ""
    fi

    # ─── Create Directory ─────────────────────────────────
    step "Creating BackRoute directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR" 2>/dev/null
    chmod 755 "$INSTALL_DIR" 2>/dev/null
    success "Directory created"
    log_message "INFO" "Directory created: $INSTALL_DIR"

    # ─── Download Panel ───────────────────────────────────
    step "Downloading BackRoute panel (BackRoute.sh)"
    log_message "INFO" "Downloading panel from: $PANEL_URL"
    if curl -fsSL "$PANEL_URL" -o "$PANEL_SCRIPT"; then
        sed -i 's/\r$//' "$PANEL_SCRIPT" 2>/dev/null
        chmod 755 "$PANEL_SCRIPT" 2>/dev/null
        success "BackRoute.sh downloaded and saved to $PANEL_SCRIPT"
        log_message "SUCCESS" "Panel downloaded successfully"
    else
        error "Failed to download BackRoute.sh from: $PANEL_URL"
        error "Please check your internet connection and try again."
        log_message "ERROR" "Failed to download panel from: $PANEL_URL"
        exit 1
    fi

    # ─── Register Command ─────────────────────────────────
    step "Registering 'BackRoute' command system-wide"
    log_message "INFO" "Registering BackRoute command..."
    
    cat > /usr/local/bin/BackRoute << 'CMDEOF'
#!/bin/bash
bash /root/BackRoute/BackRoute.sh
CMDEOF
    chmod 755 /usr/local/bin/BackRoute 2>/dev/null

    cat > /usr/local/bin/backroute << 'CMDEOF2'
#!/bin/bash
bash /root/BackRoute/BackRoute.sh
CMDEOF2
    chmod 755 /usr/local/bin/backroute 2>/dev/null

    success "Command 'BackRoute' registered in /usr/local/bin"
    log_message "SUCCESS" "BackRoute command registered"

    # ─── Set Permissions ──────────────────────────────────
    set_permissions

    # ─── Installation Complete ────────────────────────────
    echo ""
    divider
    echo ""
    echo -e "${GREEN}  ╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}  ║   BackRoute installed successfully!                  ║${RESET}"
    echo -e "${GREEN}  ║   Type  ${BOLD}BackRoute${RESET}${GREEN}  in terminal to open the panel.    ║${RESET}"
    echo -e "${GREEN}  ╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    log_message "SUCCESS" "Installation completed successfully"
    sleep 2
}

# ============================================================
#   Entry Point
# ============================================================

is_root
clear
install_prerequisites