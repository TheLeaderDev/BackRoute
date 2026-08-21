#!/bin/bash

# ============================================================
#   BackRoute - Panel & Tunnel Manager
#   Version : Auto-fetched from GitHub
#   GitHub  : https://github.com/TheLeaderDev/BackRoute
#   Author  : TheLeaderDev
# ============================================================

# ─── Fix CRLF issues ───────────────────────────────────────
if grep -q $'\r' "$0" 2>/dev/null; then
    sed -i 's/\r$//' "$0"
    exec bash "$0" "$@"
fi

# ============================================================
#   Version & GitHub Integration
# ============================================================

get_latest_version() {
    local latest_version
    latest_version=$(curl -s "https://api.github.com/repos/TheLeaderDev/BackRoute/releases/latest" | grep -oP '"tag_name":\s*"\K[^"]+' | head -1)
    if [ -n "$latest_version" ]; then
        echo "$latest_version"
    else
        echo "v1.1.0"
    fi
}

# ─── Version ───────────────────────────────────────────────
VERSION=$(get_latest_version)
GITHUB="github.com/TheLeaderDev/BackRoute"
INSTALL_DIR="/root/BackRoute"
NETPLAN_FILE="/etc/netplan/BackRoute.yaml"
SERVICE_FILE="/etc/systemd/system/backroute.service"
START_SCRIPT="$INSTALL_DIR/backroute-start.sh"
WATCHDOG_SCRIPT="$INSTALL_DIR/backroute-watchdog.sh"
INFO_FILE="$INSTALL_DIR/backroute.info"
LOG_FILE="$INSTALL_DIR/backroute.log"

# ─── Colors ───────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================================
#   Logging Functions
# ============================================================

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[${timestamp}] [${level}] ${message}"
    
    if [ -f "$LOG_FILE" ]; then
        if grep -Fq "$message" "$LOG_FILE"; then
            return 0
        fi
    fi
    
    echo "$log_entry" >> "$LOG_FILE"
    
    if [ -f "$LOG_FILE" ]; then
        local lines=$(wc -l < "$LOG_FILE")
        if [ "$lines" -gt 1000 ]; then
            tail -n 500 "$LOG_FILE" > "${LOG_FILE}.tmp"
            mv "${LOG_FILE}.tmp" "$LOG_FILE"
        fi
    fi
}

show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo ""
        divider
        echo -e "  ${BOLD}${WHITE}[ BackRoute Logs ]${RESET}"
        echo ""
        echo -e "  ${GRAY}Last 50 log entries:${RESET}"
        echo ""
        tail -n 50 "$LOG_FILE" | while IFS= read -r line; do
            echo -e "  ${GRAY}${line}${RESET}"
        done
        echo ""
        divider
    else
        echo ""
        info "No logs found yet."
    fi
}

# ============================================================
#   Input Validation Functions
# ============================================================

get_input() {
    local prompt="$1"
    local default="$2"
    local input=""
    
    while true; do
        if [ -n "$default" ]; then
            printf "${CYAN}  > ${WHITE}${prompt} ${GRAY}[default: ${YELLOW}${default}${GRAY}]${RESET}: "
        else
            printf "${CYAN}  > ${WHITE}${prompt}${RESET}: "
        fi
        
        if read -r input </dev/tty 2>/dev/null; then
            input=$(printf "%s" "$input" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [ -z "$input" ] && [ -n "$default" ]; then
                echo "$default"
                return 0
            elif [ -z "$input" ] && [ -z "$default" ]; then
                warn "Input cannot be empty. Please try again."
                continue
            else
                echo "$input"
                return 0
            fi
        else
            warn "Input error. Please try again."
            continue
        fi
    done
}

get_yes_no() {
    local prompt="$1"
    local default="$2"
    local input=""
    
    while true; do
        if [ -n "$default" ]; then
            printf "${CYAN}  > ${WHITE}${prompt} ${GRAY}[default: ${YELLOW}${default}${GRAY}]${RESET}: "
        else
            printf "${CYAN}  > ${WHITE}${prompt}${RESET}: "
        fi
        
        if read -r input </dev/tty 2>/dev/null; then
            input=$(printf "%s" "$input" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')
            
            if [ -z "$input" ] && [ -n "$default" ]; then
                echo "$default"
                return 0
            elif [ -z "$input" ] && [ -z "$default" ]; then
                warn "Input cannot be empty. Please enter y or n."
                continue
            elif [[ "$input" =~ ^(y|yes|n|no)$ ]]; then
                echo "$input"
                return 0
            else
                warn "Invalid input. Please enter y or n."
                continue
            fi
        else
            warn "Input error. Please try again."
            continue
        fi
    done
}

get_choice() {
    local prompt="$1"
    local valid_choices="$2"
    local default="$3"
    local input=""
    
    while true; do
        if [ -n "$default" ]; then
            printf "${CYAN}  > ${WHITE}${prompt} ${GRAY}[default: ${YELLOW}${default}${GRAY}]${RESET}: "
        else
            printf "${CYAN}  > ${WHITE}${prompt}${RESET}: "
        fi
        
        if read -r input </dev/tty 2>/dev/null; then
            input=$(printf "%s" "$input" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')
            
            if [ -z "$input" ] && [ -n "$default" ]; then
                echo "$default"
                return 0
            elif [ -z "$input" ] && [ -z "$default" ]; then
                warn "Input cannot be empty. Please try again."
                continue
            elif [[ "$valid_choices" == *"$input"* ]]; then
                echo "$input"
                return 0
            else
                warn "Invalid choice. Please enter one of: ${valid_choices//,/ }"
                continue
            fi
        else
            warn "Input error. Please try again."
            continue
        fi
    done
}

# ============================================================
#   Utility Functions
# ============================================================

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${WHITE}BackRoute - Tunnel Manager${RESET}   ${GRAY}${VERSION}${RESET}                       ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}  ${GRAY}${GITHUB}${RESET}                              ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_menu_box() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${YELLOW}  BackRoute Panel — Main Menu${RESET}                           ${CYAN}║${RESET}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${CYAN}║${RESET}                                                            ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}   ${GREEN}[1]${RESET}  Configure BackRoute  (Setup Tunnel)              ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}   ${BLUE}[2]${RESET}  Edit Tunnel Config    (View & Modify)             ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}   ${MAGENTA}[3]${RESET}  Status & Monitor      (Ping / Packet Loss)       ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}   ${RED}[4]${RESET}  Remove BackRoute      (Full Uninstall)            ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}   ${GRAY}[0]${RESET}  Exit                                             ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}                                                            ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

validate_ipv4() {
    local ip="$1"
    ip=$(printf "%s" "$ip" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -ra parts <<< "$ip"
        for part in "${parts[@]}"; do
            [ "$part" -gt 255 ] && return 1
        done
        return 0
    fi
    return 1
}

validate_cidr() {
    local cidr="$1"
    cidr=$(printf "%s" "$cidr" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}\/(3[0-2]|[1-2][0-9]|[0-9])$ ]]; then
        local ip="${cidr%/*}"
        if validate_ipv4 "$ip"; then
            return 0
        fi
    fi
    return 1
}

info()    { 
    local msg="$*"
    echo -e "${CYAN}  i  ${WHITE}$msg${RESET}"
    log_message "INFO" "$msg"
}
success() { 
    local msg="$*"
    echo -e "${GREEN}  ✓  $msg${RESET}"
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
step()    { echo -e "\n${BOLD}${BLUE}  --> $*${RESET}"; }
divider() { echo -e "${GRAY}  $(printf '─%.0s' $(seq 1 58))${RESET}"; }

press_enter() {
    echo ""
    echo -ne "${GRAY}  Press Enter to return to menu...${RESET}"
    read -r
}

is_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root."
        exit 1
    fi
}

read_netplan_values() {
    if [ -f "$NETPLAN_FILE" ]; then
        LOCAL_IP=$(grep -oP 'local:\s*\K[0-9.]+' "$NETPLAN_FILE" | head -1)
        REMOTE_IP=$(grep -oP 'remote:\s*\K[0-9.]+' "$NETPLAN_FILE" | head -1)
        TUNNEL_ADDR=$(grep -oP 'addresses:\s*-\s*\K[0-9a-f:./]+' "$NETPLAN_FILE" | head -1)
        METHOD=$(grep -oP 'mode:\s*\K[a-z]+' "$NETPLAN_FILE" | head -1)
        
        if echo "$TUNNEL_ADDR" | grep -q ":"; then
            IP_VER="ipv6"
        else
            IP_VER="ipv4"
        fi
        
        if [ -n "$METHOD" ] && [ -n "$LOCAL_IP" ] && [ -n "$REMOTE_IP" ]; then
            return 0
        fi
    fi
    return 1
}

load_info() {
    if [ -f "$INFO_FILE" ]; then
        source "$INFO_FILE"
        return 0
    fi
    return 1
}

save_info() {
    cat > "$INFO_FILE" << INFOEOF
ROLE=${ROLE}
LOCAL_IP=${LOCAL_IP}
REMOTE_IP=${REMOTE_IP}
METHOD=${METHOD}
IP_VER=${IP_VER}
TUNNEL_ADDR=${TUNNEL_ADDR}
MTU=${MTU_VAL}
INFOEOF
}

tunnel_installed() {
    [ -f "$NETPLAN_FILE" ] && return 0
    return 1
}

# ============================================================
#   Method Prerequisites - Exactly like README
# ============================================================

setup_gre_prereqs() {
    step "Setting up GRE prerequisites (like README)"
    modprobe ip_gre
    echo "ip_gre" | tee /etc/modules-load.d/backroute-gre.conf > /dev/null
    echo "net.ipv4.ip_forward=1" | tee /etc/sysctl.d/backroute-ipv4.conf > /dev/null
    sysctl --system > /dev/null 2>&1
    mkdir -p /root/backroute
    success "GRE Successfully Activated"
}

setup_ipip_prereqs() {
    step "Setting up IPIP prerequisites (like README)"
    modprobe ipip
    lsmod | grep ipip > /dev/null 2>&1
    echo "ipip" | tee /etc/modules-load.d/backroute-ipip.conf > /dev/null
    echo "net.ipv4.ip_forward=1" | tee /etc/sysctl.d/backroute-ipip.conf > /dev/null
    sysctl --system > /dev/null 2>&1
    mkdir -p /root/backroute
    success "IPIP Successfully Activated"
}

setup_sit_prereqs() {
    step "Setting up SIT prerequisites (like README)"
    modprobe sit
    echo "sit" | tee /etc/modules-load.d/backroute-sit.conf > /dev/null
    echo "net.ipv6.conf.all.forwarding=1" | tee /etc/sysctl.d/backroute-ipv6.conf > /dev/null
    
    # ─── SIT Optimization ────────────────────────
    if ! grep -q "router_solicitation_delay=0" /etc/sysctl.conf; then
        echo "net.ipv6.conf.all.router_solicitation_delay=0" >> /etc/sysctl.conf
    fi
    if ! grep -q "router_solicitation_interval=1" /etc/sysctl.conf; then
        echo "net.ipv6.conf.all.router_solicitation_interval=1" >> /etc/sysctl.conf
    fi
    
    sysctl --system > /dev/null 2>&1
    mkdir -p /root/backroute
    success "SIT Successfully Activated"
}

# ============================================================
#   Firewall Rules - Smart per method
# ============================================================

setup_firewall() {
    local method="$1"
    
    if [ "$method" = "gre" ]; then
        step "Configuring firewall rules for GRE (like README)"
        if command -v iptables > /dev/null 2>&1; then
            iptables -I INPUT -p gre -j ACCEPT 2>/dev/null
            iptables -I OUTPUT -p gre -j ACCEPT 2>/dev/null
            success "iptables rules for GRE added"
        fi
    elif [ "$method" = "ipip" ]; then
        step "Configuring firewall rules for IPIP (like README)"
        if command -v iptables > /dev/null 2>&1; then
            iptables -I INPUT -p ipip -j ACCEPT 2>/dev/null
            iptables -I OUTPUT -p ipip -j ACCEPT 2>/dev/null
            success "iptables rules for IPIP added"
        fi
    else
        info "SIT does not require firewall rules"
    fi
}

# ============================================================
#   Write Netplan Configuration - with MTU
# ============================================================

write_netplan_config() {
    local method="$1"
    local local_ip="$2"
    local remote_ip="$3"
    local tunnel_addr="$4"
    
    if [ -z "$local_ip" ] || [ -z "$remote_ip" ]; then
        error "LOCAL_IP or REMOTE_IP is empty! Cannot write Netplan."
        return 1
    fi
    
    if ! validate_ipv4 "$local_ip" || ! validate_ipv4 "$remote_ip"; then
        error "Invalid LOCAL_IP or REMOTE_IP! Cannot write Netplan."
        return 1
    fi
    
    step "Writing Netplan configuration (like README)"
    mkdir -p "$INSTALL_DIR"
    
    cat > "$NETPLAN_FILE" << NETEOF
network:
  version: 2
  tunnels:
    BackRoute:
      mtu: ${MTU_VAL:-1400}
      mode: $method
      local: $local_ip
      remote: $remote_ip
      addresses:
        - $tunnel_addr
NETEOF
    
    chmod 600 "$NETPLAN_FILE"
    success "Netplan file written: $NETPLAN_FILE"
    log_message "SUCCESS" "Netplan file written"
}

# ============================================================
#   Apply MTU on Interface - FIXED
# ============================================================

apply_mtu_to_interface() {
    local mtu="$1"
    if [ -z "$mtu" ] || [ "$mtu" = "" ]; then
        mtu="1400"
    fi
    
    step "Applying MTU ($mtu) on BackRoute interface"
    
    # Wait for interface to appear
    local max_attempts=10
    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if ip link show BackRoute 2>/dev/null > /dev/null; then
            ip link set dev BackRoute mtu "$mtu" 2>/dev/null
            if [ $? -eq 0 ]; then
                # Verify MTU was actually set
                local current_mtu=$(ip link show BackRoute 2>/dev/null | grep -oP 'mtu \K[0-9]+')
                if [ "$current_mtu" = "$mtu" ]; then
                    success "MTU $mtu applied successfully to BackRoute interface (verified)"
                    return 0
                else
                    warn "MTU applied but value mismatch (expected: $mtu, actual: $current_mtu)"
                fi
            else
                warn "Failed to apply MTU to BackRoute interface"
            fi
            break
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    if [ $attempt -eq $max_attempts ]; then
        warn "BackRoute interface not found after ${max_attempts}s — MTU will apply after reboot"
        return 1
    fi
}

# ============================================================
#   Remove Interface
# ============================================================

remove_interface() {
    step "Removing old BackRoute interface..."
    if ip link show BackRoute 2>/dev/null > /dev/null; then
        ip link delete BackRoute 2>/dev/null
        if [ $? -eq 0 ]; then
            success "Old BackRoute interface removed"
        else
            warn "Failed to remove BackRoute interface"
        fi
    else
        info "No BackRoute interface found to remove"
    fi
}

# ============================================================
#   Create systemd Service - Like README but improved
# ============================================================

create_service() {
    step "Creating systemd service"

    cat > "$SERVICE_FILE" << 'SVCEOF'
[Unit]
Description=BackRoute Tunnel Service
After=network.target

[Service]
Type=oneshot
ExecStart=/root/BackRoute/backroute-start.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SVCEOF

    cat > "$START_SCRIPT" << 'STARTEOF'
#!/bin/bash
sleep 2
sudo netplan apply 2>/dev/null
STARTEOF

    chmod +x "$START_SCRIPT"
    systemctl daemon-reload
    systemctl enable backroute.service > /dev/null 2>&1
    systemctl start backroute.service
    sleep 2

    if systemctl is-active --quiet backroute.service; then
        success "Service BackRoute Successfully Created & Running"
    else
        warn "Service created but may have a startup issue."
        warn "Status: $(systemctl is-active backroute.service)"
    fi
}

# ============================================================
#   Create Smart Watchdog Cron - every 10 seconds
# ============================================================

create_watchdog_cron() {
    local tunnel_ip="$1"
    local ping_cmd="ping"
    
    if [ "$IP_VER" = "ipv6" ]; then
        if command -v ping6 > /dev/null 2>&1; then
            ping_cmd="ping6"
        else
            ping_cmd="ping -6"
        fi
    fi

    cat > "$WATCHDOG_SCRIPT" << WDEOF
#!/bin/bash
TUNNEL_IP="${tunnel_ip}"
NETPLAN_FILE="/etc/netplan/BackRoute.yaml"
SERVICE_NAME="backroute.service"
LOG_FILE="/root/BackRoute/backroute.log"
PING_CMD="${ping_cmd}"

if [ ! -f "\$NETPLAN_FILE" ]; then
    exit 0
fi

if ! systemctl is-active --quiet "\$SERVICE_NAME"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] Service is stopped, starting..." >> "\$LOG_FILE"
    systemctl start "\$SERVICE_NAME"
    sleep 2
fi

if ! \$PING_CMD -c 2 -W 3 "\$TUNNEL_IP" > /dev/null 2>&1; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] Tunnel down, reconnecting..." >> "\$LOG_FILE"
    netplan apply > /dev/null 2>&1
    sleep 3
    systemctl restart "\$SERVICE_NAME" > /dev/null 2>&1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] Reconnect attempt done." >> "\$LOG_FILE"
fi
WDEOF

    chmod +x "$WATCHDOG_SCRIPT"

    # ─── تغییر از هر ۱ دقیقه به هر ۱۰ ثانیه ──────
    (crontab -l 2>/dev/null | grep -v "backroute-watchdog"; \
     echo "*/10 * * * * /root/BackRoute/backroute-watchdog.sh") | crontab -

    success "Smart watchdog cron registered (every 10 seconds, checks service & connection)"
}

# ============================================================
#   Auto Correct Tunnel Address based on Role
# ============================================================

auto_correct_tunnel_addr() {
    if [ "$IP_VER" = "ipv4" ]; then
        if [ "$ROLE" = "SERVER" ]; then
            DEFAULT_TUNNEL_IP="10.10.10.1/30"
        else
            DEFAULT_TUNNEL_IP="10.10.10.2/30"
        fi
    else
        if [ "$ROLE" = "SERVER" ]; then
            DEFAULT_TUNNEL_IP="23e7:dc8:9a0::1/64"
        else
            DEFAULT_TUNNEL_IP="23e7:dc8:9a0::2/64"
        fi
    fi
    
    if [ "$IP_VER" = "ipv4" ]; then
        if [[ "$TUNNEL_ADDR" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}\/ ]]; then
            local base_ip="${TUNNEL_ADDR%/*}"
            local cidr="${TUNNEL_ADDR#*/}"
            local last_octet="${base_ip##*.}"
            if [ "$last_octet" = "1" ] || [ "$last_octet" = "2" ]; then
                if [ "$ROLE" = "SERVER" ] && [ "$last_octet" = "2" ]; then
                    base_ip="${base_ip%.*}.1"
                    TUNNEL_ADDR="${base_ip}/${cidr}"
                    warn "Tunnel address auto-corrected to SERVER: $TUNNEL_ADDR"
                elif [ "$ROLE" = "CLIENT" ] && [ "$last_octet" = "1" ]; then
                    base_ip="${base_ip%.*}.2"
                    TUNNEL_ADDR="${base_ip}/${cidr}"
                    warn "Tunnel address auto-corrected to CLIENT: $TUNNEL_ADDR"
                fi
            fi
        fi
    fi
}

# ============================================================
#   Apply Netplan and Restart
# ============================================================

apply_netplan_and_restart() {
    step "Applying Netplan"
    netplan apply 2>/dev/null
    if [ $? -eq 0 ]; then
        success "Netplan applied"
        log_message "SUCCESS" "Netplan applied"
    else
        warn "Netplan apply had issues, but continuing..."
        log_message "WARNING" "Netplan apply had issues"
    fi
    
    # Apply MTU after netplan apply
    sleep 2
    apply_mtu_to_interface "$MTU_VAL"
    
    if [ "$METHOD" = "gre" ] || [ "$METHOD" = "ipip" ]; then
        setup_firewall "$METHOD"
    fi
    
    step "Restarting service..."
    systemctl restart backroute.service 2>/dev/null
    sleep 2
    if systemctl is-active --quiet backroute.service; then
        success "Service restarted successfully"
        log_message "SUCCESS" "Service restarted"
    else
        warn "Service may have startup issues"
        log_message "WARNING" "Service startup issues"
    fi
}

restart_tunnel() {
    step "Restarting BackRoute tunnel..."
    
    # First, remove interface if exists
    remove_interface
    
    # Apply netplan to recreate interface
    netplan apply 2>/dev/null
    sleep 2
    
    # Apply MTU
    apply_mtu_to_interface "$MTU_VAL"
    
    if [ "$METHOD" = "gre" ] || [ "$METHOD" = "ipip" ]; then
        setup_firewall "$METHOD"
    fi
    
    if systemctl is-active --quiet backroute.service; then
        systemctl restart backroute.service > /dev/null 2>&1
        success "Tunnel restarted successfully"
    else
        systemctl start backroute.service > /dev/null 2>&1
        success "Tunnel started successfully"
    fi
    
    sleep 2
    
    # Verify interface is up
    if ip link show BackRoute 2>/dev/null > /dev/null; then
        success "BackRoute interface is active"
    else
        warn "BackRoute interface is not active yet - waiting..."
        sleep 3
        netplan apply 2>/dev/null
    fi
}

# ============================================================
#   Option 1 — Configure BackRoute
# ============================================================

menu_config() {
    if tunnel_installed; then
        print_header
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}  ${BOLD}${YELLOW}  Configure BackRoute${RESET}                                   ${CYAN}║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        warn "A tunnel is already configured on this server."
        warn "Only one tunnel per server is allowed."
        info "To modify it, use option [2] Edit Tunnel Config."
        info "To start fresh, use option [4] Remove BackRoute first."
        echo ""
        press_enter
        return
    fi

    print_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${YELLOW}  Configure BackRoute — Setup Tunnel${RESET}                    ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""

    divider
    echo -e "${WHITE}  What is the role of this server?${RESET}"
    echo ""
    echo -e "  ${GREEN}[1]${RESET}  Iran Server   (Local)   — CLIENT"
    echo -e "  ${BLUE}[2]${RESET}  Foreign Server (Abroad) — SERVER"
    echo -e "  ${GRAY}[0]${RESET}  Back"
    echo ""
    while true; do
        printf "${CYAN}  > Your choice [1/2/0]${RESET}: "
        local role_choice
        while IFS= read -r -s -t 0.1 role_choice || IFS= read -r role_choice; do
            break
        done
        role_choice=$(printf "%s" "$role_choice" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        case "$role_choice" in
            1) ROLE="CLIENT"; REMOTE_ROLE="SERVER"; break ;;
            2) ROLE="SERVER"; REMOTE_ROLE="CLIENT"; break ;;
            0) return ;;
            *) warn "Please enter 1, 2 or 0." ;;
        esac
    done
    success "This server role: $ROLE"
    echo ""

    divider
    info "Enter the real IP address of the remote server ($REMOTE_ROLE):"
    info "  (press 0 + Enter to go back)"
    while true; do
        printf "${CYAN}  > ${WHITE}Remote $REMOTE_ROLE IP${RESET}: "
        local REMOTE_IP
        while IFS= read -r -s -t 0.1 REMOTE_IP || IFS= read -r REMOTE_IP; do
            break
        done
        REMOTE_IP=$(printf "%s" "$REMOTE_IP" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ "$REMOTE_IP" = "0" ] && return
        if validate_ipv4 "$REMOTE_IP"; then
            success "Remote server IP: $REMOTE_IP"
            break
        else
            warn "Invalid IP address. Example: 1.2.3.4"
        fi
    done
    echo ""

    divider
    info "Enter the real IP address of this server ($ROLE):"
    info "  (press 0 + Enter to go back)"
    while true; do
        printf "${CYAN}  > ${WHITE}This server ($ROLE) IP${RESET}: "
        local LOCAL_IP
        while IFS= read -r -s -t 0.1 LOCAL_IP || IFS= read -r LOCAL_IP; do
            break
        done
        LOCAL_IP=$(printf "%s" "$LOCAL_IP" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ "$LOCAL_IP" = "0" ] && return
        if validate_ipv4 "$LOCAL_IP"; then
            success "This server IP: $LOCAL_IP"
            break
        else
            warn "Invalid IP address."
        fi
    done
    echo ""

    divider
    echo -e "${WHITE}  Select tunnel method:${RESET}"
    echo ""
    echo -e "  ${GREEN}[1]${RESET}  ${BOLD}GRE${RESET}   — IPv4 — Wide compatibility"
    echo -e "  ${YELLOW}[2]${RESET}  ${BOLD}IPIP${RESET}  — IPv4 — Lighter than GRE"
    echo -e "  ${BLUE}[3]${RESET}  ${BOLD}SIT${RESET}   — IPv6 — Requires IPv6 support"
    echo -e "  ${GRAY}[0]${RESET}  Back"
    echo ""
    while true; do
        printf "${CYAN}  > Select method [1/2/3/0]${RESET}: "
        local method_choice
        while IFS= read -r -s -t 0.1 method_choice || IFS= read -r method_choice; do
            break
        done
        method_choice=$(printf "%s" "$method_choice" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        case "$method_choice" in
            1) METHOD="gre";  IP_VER="ipv4"; break ;;
            2) METHOD="ipip"; IP_VER="ipv4"; break ;;
            3) METHOD="sit";  IP_VER="ipv6"; break ;;
            0) return ;;
            *) warn "Please enter 1, 2, 3 or 0." ;;
        esac
    done
    success "Selected method: $(echo "$METHOD" | tr '[:lower:]' '[:upper:]')"
    echo ""

    divider
    if [ "$IP_VER" = "ipv4" ]; then
        [ "$ROLE" = "SERVER" ] && DEFAULT_TUNNEL_IP="10.10.10.1/30" || DEFAULT_TUNNEL_IP="10.10.10.2/30"
        info "Local tunnel IP for this side ($ROLE):"
        info "  This IP is only visible between the two servers."
        echo -e "${CYAN}  > ${WHITE}Tunnel IPv4 (CIDR) ${GRAY}[default: ${YELLOW}${DEFAULT_TUNNEL_IP}${GRAY}, press Enter for default]${RESET}: "
        while true; do
            local TUNNEL_ADDR_INPUT
            while IFS= read -r -s -t 0.1 TUNNEL_ADDR_INPUT || IFS= read -r TUNNEL_ADDR_INPUT; do
                break
            done
            TUNNEL_ADDR_INPUT=$(printf "%s" "$TUNNEL_ADDR_INPUT" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [ -z "$TUNNEL_ADDR_INPUT" ]; then
                TUNNEL_ADDR="$DEFAULT_TUNNEL_IP"
                success "Tunnel address: $TUNNEL_ADDR"
                break
            elif validate_cidr "$TUNNEL_ADDR_INPUT"; then
                TUNNEL_ADDR="$TUNNEL_ADDR_INPUT"
                success "Tunnel address: $TUNNEL_ADDR"
                break
            else
                warn "Invalid CIDR format. Example: 10.10.10.1/30"
            fi
        done
    else
        [ "$ROLE" = "SERVER" ] && DEFAULT_TUNNEL_IP="23e7:dc8:9a0::1/64" || DEFAULT_TUNNEL_IP="23e7:dc8:9a0::2/64"
        info "Local tunnel IPv6 for this side ($ROLE):"
        echo -e "${CYAN}  > ${WHITE}Tunnel IPv6 (CIDR) ${GRAY}[default: ${YELLOW}${DEFAULT_TUNNEL_IP}${GRAY}, press Enter for default]${RESET}: "
        while true; do
            local TUNNEL_ADDR_INPUT
            while IFS= read -r -s -t 0.1 TUNNEL_ADDR_INPUT || IFS= read -r TUNNEL_ADDR_INPUT; do
                break
            done
            TUNNEL_ADDR_INPUT=$(printf "%s" "$TUNNEL_ADDR_INPUT" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [ -z "$TUNNEL_ADDR_INPUT" ]; then
                TUNNEL_ADDR="$DEFAULT_TUNNEL_IP"
                success "Tunnel address: $TUNNEL_ADDR"
                break
            else
                TUNNEL_ADDR="$TUNNEL_ADDR_INPUT"
                success "Tunnel address: $TUNNEL_ADDR"
                break
            fi
        done
    fi
    echo ""

    divider
    info "MTU value for the BackRoute interface:"
    echo -e "  ${GRAY}Recommended: 1400 | Standard: 1480 | Max: 1500${RESET}"
    echo -e "${CYAN}  > ${WHITE}MTU ${GRAY}[default: ${YELLOW}1400${GRAY}, press Enter for default]${RESET}: "
    while true; do
        local MTU_INPUT
        while IFS= read -r -s -t 0.1 MTU_INPUT || IFS= read -r MTU_INPUT; do
            break
        done
        MTU_INPUT=$(printf "%s" "$MTU_INPUT" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -z "$MTU_INPUT" ]; then
            MTU_VAL="1400"
            success "MTU: $MTU_VAL"
            break
        elif [[ "$MTU_INPUT" =~ ^[0-9]+$ ]] && [ "$MTU_INPUT" -ge 1280 ] && [ "$MTU_INPUT" -le 1500 ]; then
            MTU_VAL="$MTU_INPUT"
            success "MTU: $MTU_VAL"
            break
        else
            warn "Invalid MTU. Please enter a number between 1280 and 1500."
        fi
    done
    echo ""

    divider
    echo -e "${BOLD}${YELLOW}  Configuration Summary:${RESET}"
    echo ""
    echo -e "  ${GRAY}Server Role      :${RESET}  ${WHITE}$ROLE${RESET}"
    echo -e "  ${GRAY}This Server IP   :${RESET}  ${WHITE}$LOCAL_IP${RESET}"
    echo -e "  ${GRAY}Remote Server IP :${RESET}  ${WHITE}$REMOTE_IP${RESET}"
    echo -e "  ${GRAY}Method           :${RESET}  ${WHITE}$(echo "$METHOD" | tr '[:lower:]' '[:upper:]')${RESET}"
    echo -e "  ${GRAY}Tunnel Address   :${RESET}  ${WHITE}$TUNNEL_ADDR${RESET}"
    echo -e "  ${GRAY}MTU              :${RESET}  ${WHITE}$MTU_VAL${RESET}"
    echo ""
    while true; do
        printf "${CYAN}  > Proceed? [y/N/0=back]${RESET}: "
        local confirm
        while IFS= read -r -s -t 0.1 confirm || IFS= read -r confirm; do
            break
        done
        confirm=$(printf "%s" "$confirm" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ "$confirm" =~ ^[0]$ ]] && return
        if [[ "$confirm" =~ ^[yY]$ ]]; then
            break
        else
            warn "Operation cancelled."
            press_enter
            return
        fi
    done

    echo ""
    divider
    echo -e "${BOLD}${GREEN}  Starting configuration...${RESET}"
    echo ""

    remove_interface

    case "$METHOD" in
        gre)  setup_gre_prereqs ;;
        ipip) setup_ipip_prereqs ;;
        sit)  setup_sit_prereqs ;;
    esac

    write_netplan_config "$METHOD" "$LOCAL_IP" "$REMOTE_IP" "$TUNNEL_ADDR"

    create_service

    apply_netplan_and_restart

    if [ "$IP_VER" = "ipv4" ]; then
        [ "$ROLE" = "SERVER" ] && REMOTE_TUNNEL_IP="10.10.10.2" || REMOTE_TUNNEL_IP="10.10.10.1"
    else
        [ "$ROLE" = "SERVER" ] && REMOTE_TUNNEL_IP="23e7:dc8:9a0::2" || REMOTE_TUNNEL_IP="23e7:dc8:9a0::1"
    fi

    step "Setting up smart watchdog cron"
    create_watchdog_cron "$REMOTE_TUNNEL_IP"

    save_info

    echo ""
    divider
    echo -e "${GREEN}  ╔══════════════════════════════════════════════════════╗${RESET}"
    success "  BackRoute configured and started successfully!"
    echo -e "${GREEN}  ╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    step "Auto-restarting tunnel..."
    restart_tunnel
    
    echo ""
    warn "Both servers must reboot to complete tunnel activation."
    info "After both servers reboot, the tunnel will be active."
    echo ""

    read -rp "$(echo -e "${CYAN}  > Reboot now? [y/N]${RESET}: ")" do_reboot
    if [[ "$do_reboot" =~ ^[yY]$ ]]; then
        info "Rebooting..."
        sleep 2
        reboot
    else
        info "You can reboot later by running: reboot"
        press_enter
    fi
}

# ============================================================
#   Option 2 — Edit Tunnel Config
# ============================================================

menu_edit() {
    if ! tunnel_installed; then
        print_header
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}  ${BOLD}${BLUE}  Edit Tunnel Config — View & Modify${RESET}                    ${CYAN}║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        warn "No tunnel is configured yet."
        info "Use option [1] Configure BackRoute to set up a tunnel first."
        echo ""
        press_enter
        return
    fi

    print_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${BLUE}  Edit Tunnel Config — View & Modify${RESET}                    ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""

    if ! read_netplan_values; then
        warn "Could not read values from Netplan file."
        info "The Netplan file may be corrupted or missing."
        press_enter
        return
    fi

    if ! load_info; then
        warn "Config info file not found."
        info "The Netplan file exists but config details are missing."
        press_enter
        return
    fi

    divider
    echo -e "${BOLD}${WHITE}  Current Tunnel Configuration:${RESET}"
    echo ""
    echo -e "  ${GRAY}[1]${RESET}  Server Role      :  ${WHITE}${ROLE}${RESET}"
    echo -e "  ${GRAY}[2]${RESET}  This Server IP   :  ${WHITE}${LOCAL_IP}${RESET}"
    echo -e "  ${GRAY}[3]${RESET}  Remote Server IP :  ${WHITE}${REMOTE_IP}${RESET}"
    echo -e "  ${GRAY}[4]${RESET}  Method           :  ${WHITE}$(echo "${METHOD}" | tr '[:lower:]' '[:upper:]')${RESET}"
    echo -e "  ${GRAY}[5]${RESET}  Tunnel Address   :  ${WHITE}${TUNNEL_ADDR}${RESET}"
    echo -e "  ${GRAY}[6]${RESET}  MTU              :  ${WHITE}${MTU}${RESET}"
    echo ""
    echo -e "  ${GRAY}[0]${RESET}  Back to menu"
    echo ""
    divider
    echo -e "  ${YELLOW}Select the field number to edit, or 0 to go back:${RESET}"
    echo ""

    local method_changed=0
    local role_changed=0
    local old_ip_ver="$IP_VER"

    while true; do
        read -rp "$(echo -e "${CYAN}  > Your choice${RESET}: ")" edit_choice
        case "$edit_choice" in
            0) 
                if [ $method_changed -eq 1 ] || [ $role_changed -eq 1 ]; then
                    echo ""
                    read -rp "$(echo -e "${CYAN}  > Do you want to reboot now? [y/N]${RESET}: ")" do_reboot_edit
                    if [[ "$do_reboot_edit" =~ ^[yY]$ ]]; then
                        info "Rebooting..."
                        sleep 2
                        reboot
                    fi
                fi
                return 
                ;;
            1)
                echo ""
                echo -e "  ${GREEN}[1]${RESET}  CLIENT (Iran Server)"
                echo -e "  ${BLUE}[2]${RESET}  SERVER (Foreign Server)"
                read -rp "$(echo -e "${CYAN}  > New role [1/2]${RESET}: ")" r
                case "$r" in
                    1) 
                        if [ "$ROLE" != "CLIENT" ]; then
                            role_changed=1
                        fi
                        ROLE="CLIENT"
                        REMOTE_ROLE="SERVER"
                        auto_correct_tunnel_addr
                        ;;
                    2) 
                        if [ "$ROLE" != "SERVER" ]; then
                            role_changed=1
                        fi
                        ROLE="SERVER"
                        REMOTE_ROLE="CLIENT"
                        auto_correct_tunnel_addr
                        ;;
                    *) warn "Invalid."; continue ;;
                esac
                ;;
            2)
                echo ""
                while true; do
                    printf "${CYAN}  > ${WHITE}New This Server IP${RESET}: "
                    local NEW_VAL
                    while IFS= read -r -s -t 0.1 NEW_VAL || IFS= read -r NEW_VAL; do
                        break
                    done
                    NEW_VAL=$(printf "%s" "$NEW_VAL" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if validate_ipv4 "$NEW_VAL"; then 
                        LOCAL_IP="$NEW_VAL"
                        break
                    else 
                        warn "Invalid IP."
                    fi
                done
                ;;
            3)
                echo ""
                while true; do
                    printf "${CYAN}  > ${WHITE}New Remote Server IP${RESET}: "
                    local NEW_VAL
                    while IFS= read -r -s -t 0.1 NEW_VAL || IFS= read -r NEW_VAL; do
                        break
                    done
                    NEW_VAL=$(printf "%s" "$NEW_VAL" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if validate_ipv4 "$NEW_VAL"; then 
                        REMOTE_IP="$NEW_VAL"
                        break
                    else 
                        warn "Invalid IP."
                    fi
                done
                ;;
            4)
                echo ""
                echo -e "  ${GREEN}[1]${RESET} GRE  ${YELLOW}[2]${RESET} IPIP  ${BLUE}[3]${RESET} SIT"
                read -rp "$(echo -e "${CYAN}  > Method [1/2/3]${RESET}: ")" m
                
                local new_method=""
                local new_ip_ver=""
                local new_tunnel_addr=""
                
                case "$m" in
                    1) 
                        new_method="gre"
                        new_ip_ver="ipv4"
                        if [ "$ROLE" = "SERVER" ]; then
                            new_tunnel_addr="10.10.10.1/30"
                        else
                            new_tunnel_addr="10.10.10.2/30"
                        fi
                        ;;
                    2) 
                        new_method="ipip"
                        new_ip_ver="ipv4"
                        if [ "$ROLE" = "SERVER" ]; then
                            new_tunnel_addr="10.10.10.1/30"
                        else
                            new_tunnel_addr="10.10.10.2/30"
                        fi
                        ;;
                    3) 
                        new_method="sit"
                        new_ip_ver="ipv6"
                        if [ "$ROLE" = "SERVER" ]; then
                            new_tunnel_addr="23e7:dc8:9a0::1/64"
                        else
                            new_tunnel_addr="23e7:dc8:9a0::2/64"
                        fi
                        ;;
                    *) warn "Invalid."; continue ;;
                esac
                
                if [ "$METHOD" != "$new_method" ]; then
                    method_changed=1
                    METHOD="$new_method"
                    IP_VER="$new_ip_ver"
                    
                    if [ "$old_ip_ver" != "$new_ip_ver" ]; then
                        echo ""
                        warn "Changing from IPv$([ "$old_ip_ver" = "ipv4" ] && echo "4" || echo "6") to IPv$([ "$new_ip_ver" = "ipv4" ] && echo "4" || echo "6")"
                        echo -e "${YELLOW}  !  Tunnel Address will be changed to: ${WHITE}$new_tunnel_addr${RESET}"
                        echo -e "${YELLOW}  !  This is required for the new method to work properly.${RESET}"
                    fi
                    
                    TUNNEL_ADDR="$new_tunnel_addr"
                    success "Method changed to: $(echo "$METHOD" | tr '[:lower:]' '[:upper:]')"
                    success "Tunnel Address set to: $TUNNEL_ADDR"
                    
                    echo ""
                    echo -e "${YELLOW}  !  Current MTU is: ${WHITE}${MTU:-Not Set}${RESET}"
                    echo -e "${CYAN}  > Do you want to change MTU? [y/N]${RESET}: "
                    local change_mtu
                    while IFS= read -r -s -t 0.1 change_mtu || IFS= read -r change_mtu; do
                        break
                    done
                    change_mtu=$(printf "%s" "$change_mtu" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    
                    if [[ "$change_mtu" =~ ^[yY]$ ]]; then
                        info "Enter new MTU value for the BackRoute interface:"
                        echo -e "  ${GRAY}Recommended: 1400 | Standard: 1480 | Max: 1500${RESET}"
                        echo -e "${CYAN}  > ${WHITE}MTU ${GRAY}[default: ${YELLOW}${MTU:-1400}${GRAY}, press Enter for default]${RESET}: "
                        while true; do
                            local MTU_INPUT
                            while IFS= read -r -s -t 0.1 MTU_INPUT || IFS= read -r MTU_INPUT; do
                                break
                            done
                            MTU_INPUT=$(printf "%s" "$MTU_INPUT" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                            if [ -z "$MTU_INPUT" ]; then
                                MTU="${MTU:-1400}"
                                MTU_VAL="$MTU"
                                success "MTU kept: $MTU_VAL"
                                break
                            elif [[ "$MTU_INPUT" =~ ^[0-9]+$ ]] && [ "$MTU_INPUT" -ge 1280 ] && [ "$MTU_INPUT" -le 1500 ]; then
                                MTU="$MTU_INPUT"
                                MTU_VAL="$MTU"
                                success "MTU updated to: $MTU_VAL"
                                break
                            else
                                warn "Invalid MTU. Please enter a number between 1280 and 1500."
                            fi
                        done
                    else
                        if [ -z "$MTU" ] || [ "$MTU" = "" ]; then
                            MTU="1400"
                            MTU_VAL="$MTU"
                            warn "MTU was empty, auto-set to default: 1400"
                        else
                            MTU_VAL="$MTU"
                            success "MTU kept: $MTU_VAL"
                        fi
                    fi
                    
                    remove_interface
                    
                    case "$METHOD" in
                        gre)  setup_gre_prereqs ;;
                        ipip) setup_ipip_prereqs ;;
                        sit)  setup_sit_prereqs ;;
                    esac
                    
                    if [ "$METHOD" = "gre" ] || [ "$METHOD" = "ipip" ]; then
                        setup_firewall "$METHOD"
                    fi
                fi
                ;;
            5)
                echo ""
                while true; do
                    printf "${CYAN}  > ${WHITE}New Tunnel Address (IP only, without /CIDR)${RESET}: "
                    local NEW_VAL
                    while IFS= read -r -s -t 0.1 NEW_VAL || IFS= read -r NEW_VAL; do
                        break
                    done
                    NEW_VAL=$(printf "%s" "$NEW_VAL" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if [ -z "$NEW_VAL" ]; then
                        if [ "$ROLE" = "SERVER" ]; then
                            if [ "$IP_VER" = "ipv4" ]; then
                                NEW_VAL="10.10.10.1/30"
                            else
                                NEW_VAL="23e7:dc8:9a0::1/64"
                            fi
                        else
                            if [ "$IP_VER" = "ipv4" ]; then
                                NEW_VAL="10.10.10.2/30"
                            else
                                NEW_VAL="23e7:dc8:9a0::2/64"
                            fi
                        fi
                        TUNNEL_ADDR="$NEW_VAL"
                        warn "Auto-set to default: $TUNNEL_ADDR"
                        break
                    elif [ "$IP_VER" = "ipv4" ]; then
                        if validate_ipv4 "$NEW_VAL"; then
                            local cidr="30"
                            if [ "$ROLE" = "SERVER" ]; then
                                local last_octet="${NEW_VAL##*.}"
                                if [ "$last_octet" = "2" ]; then
                                    NEW_VAL="${NEW_VAL%.*}.1"
                                fi
                            else
                                local last_octet="${NEW_VAL##*.}"
                                if [ "$last_octet" = "1" ]; then
                                    NEW_VAL="${NEW_VAL%.*}.2"
                                fi
                            fi
                            TUNNEL_ADDR="${NEW_VAL}/${cidr}"
                            success "Tunnel address: $TUNNEL_ADDR"
                            break
                        else
                            warn "Invalid IP address. Example: 10.10.10.1"
                        fi
                    else
                        TUNNEL_ADDR="$NEW_VAL"
                        break
                    fi
                done
                ;;
            6)
                echo ""
                while true; do
                    printf "${CYAN}  > ${WHITE}New MTU${RESET}: "
                    local NEW_VAL
                    while IFS= read -r -s -t 0.1 NEW_VAL || IFS= read -r NEW_VAL; do
                        break
                    done
                    NEW_VAL=$(printf "%s" "$NEW_VAL" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if [ -z "$NEW_VAL" ]; then
                        MTU="1400"
                        MTU_VAL="$MTU"
                        warn "Auto-set to default MTU: 1400"
                        break
                    elif [[ "$NEW_VAL" =~ ^[0-9]+$ ]] && [ "$NEW_VAL" -ge 1280 ] && [ "$NEW_VAL" -le 1500 ]; then
                        MTU="$NEW_VAL"
                        MTU_VAL="$MTU"
                        success "MTU: $MTU_VAL"
                        break
                    else
                        warn "Invalid MTU. Please enter a number between 1280 and 1500."
                    fi
                done
                ;;
            *) warn "Invalid option."; continue ;;
        esac

        echo ""
        echo -e "${BOLD}${YELLOW}  Updated Configuration:${RESET}"
        echo ""
        echo -e "  ${GRAY}Server Role      :${RESET}  ${WHITE}${ROLE}${RESET}"
        echo -e "  ${GRAY}This Server IP   :${RESET}  ${WHITE}${LOCAL_IP}${RESET}"
        echo -e "  ${GRAY}Remote Server IP :${RESET}  ${WHITE}${REMOTE_IP}${RESET}"
        echo -e "  ${GRAY}Method           :${RESET}  ${WHITE}$(echo "${METHOD}" | tr '[:lower:]' '[:upper:]')${RESET}"
        echo -e "  ${GRAY}Tunnel Address   :${RESET}  ${WHITE}${TUNNEL_ADDR}${RESET}"
        echo -e "  ${GRAY}MTU              :${RESET}  ${WHITE}${MTU}${RESET}"
        echo ""
        read -rp "$(echo -e "${CYAN}  > Apply changes now? [y/N]${RESET}: ")" apply_now
        if [[ "$apply_now" =~ ^[yY]$ ]]; then
            MTU_VAL="${MTU}"

            if [ -z "$LOCAL_IP" ] || [ -z "$REMOTE_IP" ]; then
                error "LOCAL_IP or REMOTE_IP is empty! Please reconfigure the tunnel from scratch."
                press_enter
                return
            fi

            if ! validate_ipv4 "$LOCAL_IP" || ! validate_ipv4 "$REMOTE_IP"; then
                error "Invalid LOCAL_IP or REMOTE_IP! Please reconfigure the tunnel from scratch."
                press_enter
                return
            fi

            write_netplan_config "$METHOD" "$LOCAL_IP" "$REMOTE_IP" "$TUNNEL_ADDR"

            save_info
            
            apply_netplan_and_restart

            success "Configuration updated and applied."
            
            step "Auto-restarting tunnel..."
            restart_tunnel
            
            warn "A reboot of both servers is recommended for full effect."
            
            if [ $method_changed -eq 1 ] || [ $role_changed -eq 1 ]; then
                echo ""
                read -rp "$(echo -e "${CYAN}  > Do you want to reboot now? [y/N]${RESET}: ")" do_reboot_edit
                if [[ "$do_reboot_edit" =~ ^[yY]$ ]]; then
                    info "Rebooting..."
                    sleep 2
                    reboot
                fi
            fi
        else
            save_info
            info "Changes saved. Apply manually by running: netplan apply"
        fi

        echo ""
        press_enter
        return
    done
}

# ============================================================
#   Option 3 — Status & Monitor - FIXED
# ============================================================

menu_status() {
    if ! tunnel_installed; then
        print_header
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${RESET}  ${BOLD}${MAGENTA}  Status & Monitor${RESET}                                      ${CYAN}║${RESET}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        warn "No tunnel is configured yet."
        info "Use option [1] Configure BackRoute to set up a tunnel first."
        echo ""
        press_enter
        return
    fi

    print_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${MAGENTA}  Status & Monitor${RESET}                                      ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""

    divider
    echo -e "  ${BOLD}${WHITE}[ Service Status ]${RESET}"
    echo ""

    if systemctl is-active --quiet backroute.service 2>/dev/null; then
        SVC_STATUS="${GREEN}Running${RESET}"
    else
        SVC_STATUS="${RED}Stopped${RESET}"
    fi

    if systemctl is-enabled --quiet backroute.service 2>/dev/null; then
        SVC_ENABLED="${GREEN}Enabled${RESET}"
    else
        SVC_ENABLED="${RED}Disabled${RESET}"
    fi

    echo -e "  Service Active  :  $(echo -e "$SVC_STATUS")"
    echo -e "  Service Boot    :  $(echo -e "$SVC_ENABLED")"
    echo ""

    divider
    echo -e "  ${BOLD}${WHITE}[ Tunnel Info ]${RESET}"
    echo ""

    if tunnel_installed && load_info; then
        echo -e "  Tunnel Installed  :  ${GREEN}Yes${RESET}"
        echo -e "  This Server IP    :  ${WHITE}${LOCAL_IP}${RESET}"
        echo -e "  Remote Server IP  :  ${WHITE}${REMOTE_IP}${RESET}"
        echo -e "  Method            :  ${WHITE}$(echo "${METHOD}" | tr '[:lower:]' '[:upper:]')${RESET}"
        echo -e "  Tunnel Address    :  ${WHITE}${TUNNEL_ADDR}${RESET}"
        echo -e "  Server Role       :  ${WHITE}${ROLE}${RESET}"
        echo -e "  MTU               :  ${WHITE}${MTU:-1400}${RESET}"
        echo ""

        if [ "$IP_VER" = "ipv4" ]; then
            [ "$ROLE" = "SERVER" ] && REMOTE_TUNNEL_IP="10.10.10.2" || REMOTE_TUNNEL_IP="10.10.10.1"
        else
            [ "$ROLE" = "SERVER" ] && REMOTE_TUNNEL_IP="23e7:dc8:9a0::2" || REMOTE_TUNNEL_IP="23e7:dc8:9a0::1"
        fi

        if ip link show BackRoute 2>/dev/null > /dev/null; then
            IFACE_STATUS="${GREEN}Interface UP${RESET}"
        else
            IFACE_STATUS="${RED}Interface DOWN${RESET}"
        fi
        echo -e "  Interface         :  $(echo -e "$IFACE_STATUS")"

        divider
        echo -e "  ${BOLD}${WHITE}[ Tunnel Connection ]${RESET}"
        echo ""
        echo -ne "  Testing connectivity to ${YELLOW}${REMOTE_TUNNEL_IP}${RESET} ..."

        # FIXED: Proper ping test with correct output parsing
        if [ "$IP_VER" = "ipv6" ]; then
            if command -v ping6 > /dev/null 2>&1; then
                PING_OUTPUT=$(ping6 -c 4 -W 2 "$REMOTE_TUNNEL_IP" 2>&1)
            else
                PING_OUTPUT=$(ping -6 -c 4 -W 2 "$REMOTE_TUNNEL_IP" 2>&1)
            fi
        else
            PING_OUTPUT=$(ping -c 4 -W 2 "$REMOTE_TUNNEL_IP" 2>&1)
        fi
        PING_EXIT=$?

        echo ""
        echo ""

        if [ $PING_EXIT -eq 0 ]; then
            TUNNEL_STATUS="${GREEN}Connected${RESET}"
            
            # FIXED: Better ping parsing
            AVG_PING="0"
            if echo "$PING_OUTPUT" | grep -q "rtt"; then
                AVG_PING=$(echo "$PING_OUTPUT" | grep -E "rtt|round-trip" | sed -E 's/.*= ([0-9.]+)\/([0-9.]+)\/([0-9.]+)\/([0-9.]+).*/\2/' | head -1)
            elif echo "$PING_OUTPUT" | grep -q "round-trip"; then
                AVG_PING=$(echo "$PING_OUTPUT" | grep "round-trip" | sed -E 's/.*= ([0-9.]+)\/([0-9.]+)\/([0-9.]+)\/([0-9.]+).*/\2/' | head -1)
            elif echo "$PING_OUTPUT" | grep -q "avg"; then
                AVG_PING=$(echo "$PING_OUTPUT" | grep -o "avg = [0-9.]*" | grep -o "[0-9.]*" | head -1)
            fi
            
            # If still empty, try alternative parsing
            if [ -z "$AVG_PING" ] || [ "$AVG_PING" = "0" ]; then
                AVG_PING=$(echo "$PING_OUTPUT" | grep -o "time=[0-9.]*" | grep -o "[0-9.]*" | awk '{sum+=$1} END {if(NR>0) print sum/NR}' | head -1)
                if [ -z "$AVG_PING" ]; then
                    AVG_PING="0"
                fi
            fi
            
            PKT_LOSS="0"
            if echo "$PING_OUTPUT" | grep -qi "packet loss"; then
                PKT_LOSS=$(echo "$PING_OUTPUT" | grep -o "[0-9]*%" | grep -o "[0-9]*" | head -1)
            elif echo "$PING_OUTPUT" | grep -qi "loss"; then
                PKT_LOSS=$(echo "$PING_OUTPUT" | grep -o "[0-9]*%" | grep -o "[0-9]*" | head -1)
            fi
            
            if [ -z "$PKT_LOSS" ] || ! [[ "$PKT_LOSS" =~ ^[0-9]+$ ]]; then
                PKT_LOSS="0"
            fi
            
            echo -e "  Tunnel Status   :  $(echo -e "$TUNNEL_STATUS")"
            
            # Format and color ping
            if [ -n "$AVG_PING" ] && [ "$AVG_PING" != "0" ] && [ "$AVG_PING" != "" ] 2>/dev/null; then
                AVG_PING_ROUNDED=$(printf "%.0f" "$AVG_PING" 2>/dev/null)
                if [ -z "$AVG_PING_ROUNDED" ] || ! [[ "$AVG_PING_ROUNDED" =~ ^[0-9]+$ ]]; then
                    AVG_PING_ROUNDED="0"
                fi
                if [ "$AVG_PING_ROUNDED" -le 50 ] 2>/dev/null; then
                    PING_COLOR="$GREEN"
                elif [ "$AVG_PING_ROUNDED" -le 150 ] 2>/dev/null; then
                    PING_COLOR="$YELLOW"
                else
                    PING_COLOR="$RED"
                fi
                echo -e "  Ping (avg)      :  ${PING_COLOR}${AVG_PING_ROUNDED} ms${RESET}"
            else
                # Try to get ping from output in a different way
                PING_RAW=$(echo "$PING_OUTPUT" | grep -o "time=[0-9.]*" | grep -o "[0-9.]*" | head -1)
                if [ -n "$PING_RAW" ] && [ "$PING_RAW" != "0" ]; then
                    AVG_PING_ROUNDED=$(printf "%.0f" "$PING_RAW" 2>/dev/null)
                    if [ -z "$AVG_PING_ROUNDED" ] || ! [[ "$AVG_PING_ROUNDED" =~ ^[0-9]+$ ]]; then
                        AVG_PING_ROUNDED="0"
                    fi
                    if [ "$AVG_PING_ROUNDED" -le 50 ] 2>/dev/null; then
                        PING_COLOR="$GREEN"
                    elif [ "$AVG_PING_ROUNDED" -le 150 ] 2>/dev/null; then
                        PING_COLOR="$YELLOW"
                    else
                        PING_COLOR="$RED"
                    fi
                    echo -e "  Ping (avg)      :  ${PING_COLOR}${AVG_PING_ROUNDED} ms${RESET}"
                else
                    echo -e "  Ping (avg)      :  ${GREEN}0 ms${RESET}"
                fi
            fi

            if [ "$PKT_LOSS" = "0" ]; then
                LOSS_COLOR="$GREEN"
            elif [ "$PKT_LOSS" -le 20 ] 2>/dev/null; then
                LOSS_COLOR="$YELLOW"
            else
                LOSS_COLOR="$RED"
            fi
            echo -e "  Packet Loss     :  ${LOSS_COLOR}${PKT_LOSS}%${RESET}"
            
        else
            TUNNEL_STATUS="${YELLOW}Waiting for connection...${RESET}"
            echo -e "  Tunnel Status   :  $(echo -e "$TUNNEL_STATUS")"
            echo -e "  Ping (avg)      :  ${YELLOW}Waiting...${RESET}"
            echo -e "  Packet Loss     :  ${YELLOW}Waiting...${RESET}"
        fi

    else
        echo -e "  Tunnel Installed  :  ${RED}No${RESET}"
        echo ""
        info "No tunnel configured. Use option [1] to set one up."
    fi

    echo ""
    divider
    echo ""
    echo -e "  ${GRAY}[0]${RESET}  Back to menu"
    echo -e "  ${GREEN}[R]${RESET}  Restart Tunnel"
    echo -e "  ${BLUE}[L]${RESET}  View Logs"
    echo ""
    
    while true; do
        read -rp "$(echo -e "${CYAN}  > ${RESET}")" status_choice
        case "$status_choice" in
            0)
                return
                ;;
            r|R)
                restart_tunnel
                echo ""
                press_enter
                return
                ;;
            l|L)
                show_logs
                echo ""
                press_enter
                return
                ;;
            *)
                warn "Invalid option. Please enter 0, R or L."
                ;;
        esac
    done
}

# ============================================================
#   Option 4 — Remove BackRoute
# ============================================================

menu_remove() {
    print_header
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${RED}  Remove BackRoute — Full Uninstall${RESET}                     ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    warn "This will permanently remove ALL BackRoute data!"
    warn "Includes: service, Netplan config, cron job, files and modules."
    echo ""
    echo -e "  ${GRAY}[y]${RESET}  Yes, remove everything"
    echo -e "  ${GRAY}[0]${RESET}  Back to menu"
    echo ""
    read -rp "$(echo -e "${RED}  > Are you sure? [y/N/0=back]${RESET}: ")" confirm_remove
    [[ "$confirm_remove" =~ ^[0]$ ]] && return
    if [[ ! "$confirm_remove" =~ ^[yY]$ ]]; then
        warn "Operation cancelled."
        press_enter
        return
    fi

    echo ""
    divider

    step "Stopping and disabling service"
    systemctl stop backroute.service 2>/dev/null    && success "Service stopped"   || true
    systemctl disable backroute.service 2>/dev/null && success "Service disabled"  || true
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload
    systemctl reset-failed 2>/dev/null || true

    step "Removing Netplan configuration"
    rm -f "$NETPLAN_FILE"
    netplan apply 2>/dev/null || true
    success "Netplan file removed"

    step "Removing Cron Job"
    crontab -l 2>/dev/null | grep -v 'backroute' | crontab - 2>/dev/null || true
    success "Cron Job removed"

    step "Removing kernel module configs"
    rmmod ip_gre 2>/dev/null || true
    rmmod ipip   2>/dev/null || true
    rm -f /etc/modules-load.d/backroute-gre.conf
    rm -f /etc/modules-load.d/backroute-ipip.conf
    rm -f /etc/modules-load.d/backroute-sit.conf
    rm -f /etc/sysctl.d/backroute-ipv4.conf
    rm -f /etc/sysctl.d/backroute-ipv6.conf
    rm -f /etc/sysctl.d/backroute-ipip.conf
    success "Module configs removed"

    step "Removing BackRoute command from system"
    rm -f /usr/local/bin/BackRoute
    rm -f /usr/local/bin/backroute
    success "Commands removed"

    step "Removing BackRoute directory"
    rm -rf "$INSTALL_DIR"
    success "Directory $INSTALL_DIR removed"

    echo ""
    divider
    echo -e "${RED}  x  BackRoute Completely Removed${RESET}"
    echo ""
    echo -ne "${GRAY}  Press Enter to exit...${RESET}"
    read -r
    exit 0
}

# ============================================================
#   Main Panel Loop
# ============================================================

main_panel() {
    while true; do
        print_header
        print_menu_box
        
        choice=""
        printf "${CYAN}  > Enter your choice: ${RESET}"
        
        if read -r -t 60 choice </dev/tty 2>/dev/null || read -r choice </dev/tty 2>/dev/null; then
            choice=$(echo "$choice" | tr -d '\r\n' | xargs)
            
            if [ -z "$choice" ]; then
                continue
            fi
            
            case "$choice" in
                1) 
                    menu_config 
                    ;;
                2) 
                    if tunnel_installed; then
                        menu_edit 
                    else
                        warn "No tunnel configured. Please use option [1] first."
                        sleep 1.5
                    fi
                    ;;
                3) 
                    if tunnel_installed; then
                        menu_status 
                    else
                        warn "No tunnel configured. Please use option [1] first."
                        sleep 1.5
                    fi
                    ;;
                4) 
                    menu_remove 
                    ;;
                0|q|Q|exit|Exit)
                    echo ""
                    info "Exiting BackRoute Panel..."
                    echo -e "${GRAY}  To reopen the panel, type: ${BOLD}BackRoute${RESET}"
                    echo ""
                    exit 0
                    ;;
                *)
                    warn "Invalid option. Please enter 0, 1, 2, 3 or 4."
                    sleep 1.5
                    ;;
            esac
        else
            warn "Input error, please try again..."
            sleep 1
            continue
        fi
    done
}

# ============================================================
#   Entry Point
# ============================================================

is_root

if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

main_panel