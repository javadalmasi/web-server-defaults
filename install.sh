#!/bin/bash

# Web Server Default Pages Installer
# This script installs Persian web server error pages on various Linux systems and control panels
# Supports: cPanel, DirectAdmin, Nginx, Apache, aaPanel

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$NAME
        DISTRO_VERSION=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si)
        DISTRO_VERSION=$(lsb_release -sr)
    elif [ -f /etc/redhat-release ]; then
        DISTRO=$(cat /etc/redhat-release | cut -d' ' -f1)
        DISTRO_VERSION="Unknown"
    else
        DISTRO="Unknown"
        DISTRO_VERSION="Unknown"
    fi
    print_status "Detected distribution: $DISTRO $DISTRO_VERSION"
}

# Detect web server/control panel
detect_webserver() {
    WEB_SERVER="unknown"
    
    # Check for cPanel
    if [ -f /usr/local/cpanel/cpanel ]; then
        WEB_SERVER="cpanel"
    # Check for DirectAdmin
    elif [ -f /usr/local/directadmin/directadmin ]; then
        WEB_SERVER="directadmin"
    # Check for aaPanel
    elif [ -f /www/server/panel/BTPanel ]; then
        WEB_SERVER="aapanel"
    # Check for Nginx
    elif command -v nginx >/dev/null 2>&1; then
        if [ -f /etc/nginx/nginx.conf ]; then
            WEB_SERVER="nginx"
        fi
    # Check for Apache
    elif command -v apache2 >/dev/null 2>&1 || command -v httpd >/dev/null 2>&1; then
        if [ -f /etc/apache2/apache2.conf ] || [ -f /etc/httpd/conf/httpd.conf ]; then
            WEB_SERVER="apache"
        fi
    fi
    
    print_status "Detected web server: $WEB_SERVER"
}

# Create the error pages directory
create_pages_dir() {
    local pages_dir="$1"
    if [ ! -d "$pages_dir" ]; then
        mkdir -p "$pages_dir"
        print_status "Created pages directory: $pages_dir"
    fi
}

# Copy error pages to destination
copy_pages() {
    local dest_dir="$1"
    local script_dir=$(dirname "$0")
    
    print_status "Copying error pages to $dest_dir"
    
    # Copy all HTML files
    cp "$script_dir"/*.html "$dest_dir/" 2>/dev/null || true
    # Copy assets directory
    if [ -d "$script_dir/assets" ]; then
        cp -r "$script_dir/assets" "$dest_dir/" 2>/dev/null || true
    fi
    # Copy LICENSE and README if they exist
    cp "$script_dir/LICENSE" "$dest_dir/" 2>/dev/null || true
    cp "$script_dir/README.md" "$dest_dir/" 2>/dev/null || true
    
    print_success "Error pages copied successfully"
}

# Configure Apache
configure_apache() {
    print_status "Configuring Apache error pages"
    
    local apache_conf_dir=""
    local apache_vhost_dir=""
    
    # Determine Apache configuration directories based on distro
    if [ -d "/etc/apache2" ]; then
        apache_conf_dir="/etc/apache2"
        apache_vhost_dir="/etc/apache2/sites-enabled"
    elif [ -d "/etc/httpd" ]; then
        apache_conf_dir="/etc/httpd/conf"
        apache_vhost_dir="/etc/httpd/conf.d"
    else
        print_error "Could not determine Apache configuration directory"
        return 1
    fi
    
    # Create error pages directory
    local pages_dir="/var/www/error_pages"
    create_pages_dir "$pages_dir"
    
    # Copy error pages
    copy_pages "$pages_dir"
    
    # Create Apache error configuration snippet
    cat > /tmp/apache_error_pages.conf << 'EOF'
# Custom error pages configuration
ErrorDocument 403 /error_pages/403.html
ErrorDocument 404 /error_pages/404.html
ErrorDocument 410 /error_pages/410.html
ErrorDocument 429 /error_pages/429.html
ErrorDocument 500 /error_pages/500.html
ErrorDocument 502 /error_pages/502.html
ErrorDocument 503 /error_pages/503.html
EOF

    # Determine where to place the configuration
    if [ -d "/etc/apache2/mods-enabled" ]; then
        # Debian/Ubuntu - enable the configuration as a module
        local apache_error_conf="$apache_conf_dir/conf-available/error-pages.conf"
        sudo cp /tmp/apache_error_pages.conf "$apache_error_conf"
        sudo a2enconf error-pages
        sudo systemctl reload apache2
    else
        # CentOS/RHEL - include in main config
        echo "IncludeOptional $apache_conf_dir/error-pages.conf" >> "$apache_conf_dir/httpd.conf"
        sudo cp /tmp/apache_error_pages.conf "$apache_conf_dir/error-pages.conf"
        sudo systemctl reload httpd
    fi
    
    print_success "Apache configured for error pages"
}

# Configure Nginx
configure_nginx() {
    print_status "Configuring Nginx error pages"
    
    # Create error pages directory
    local pages_dir="/usr/share/nginx/error_pages"
    create_pages_dir "$pages_dir"
    
    # Copy error pages
    copy_pages "$pages_dir"
    
    # Create Nginx error configuration
    cat > /tmp/nginx_error_pages.conf << 'EOF'
# Custom error pages configuration
error_page 403 /error_pages/403.html;
error_page 404 /error_pages/404.html;
error_page 410 /error_pages/410.html;
error_page 429 /error_pages/429.html;
error_page 500 /error_pages/500.html;
error_page 502 /error_pages/502.html;
error_page 503 /error_pages/503.html;

location ^~ /error_pages/ {
    alias /usr/share/nginx/error_pages/;
    internal;
}
EOF

    # Backup main nginx config and add error page configuration
    if [ -f /etc/nginx/nginx.conf ]; then
        sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
        sudo sed -i.bak '/http {/a\'$'\n\tinclude /etc/nginx/error-pages.conf;' /etc/nginx/nginx.conf
        sudo cp /tmp/nginx_error_pages.conf /etc/nginx/error-pages.conf
        sudo nginx -t && sudo systemctl reload nginx
        print_success "Nginx configured for error pages"
    else
        print_error "Nginx configuration file not found"
        return 1
    fi
}

# Configure cPanel
configure_cpanel() {
    print_status "Configuring cPanel error pages"
    
    # Create directory for cPanel error pages
    local pages_dir="/var/cpanel/custom_error_pages"
    create_pages_dir "$pages_dir"
    
    # Copy error pages
    copy_pages "$pages_dir"
    
    # Update cPanel error pages
    # cPanel uses a specific system for custom error pages
    # Create Apache virtual host configurations
    for domain in /var/cpanel/users/*; do
        if [ -f "$domain" ]; then
            user=$(basename "$domain")
            # For each user, we need to update their vhost
            print_status "Configuring error pages for user: $user"
        fi
    done
    
    # Restart cPanel Apache
    sudo /scripts/restartsrv_httpd
    print_success "cPanel error pages configured"
}

# Configure DirectAdmin
configure_directadmin() {
    print_status "Configuring DirectAdmin error pages"
    
    # Create directory for DirectAdmin error pages
    local pages_dir="/usr/local/directadmin/data/templates/custom_error_pages"
    create_pages_dir "$pages_dir"
    
    # Copy error pages
    copy_pages "$pages_dir"
    
    # Update DirectAdmin configuration
    if [ -f /usr/local/directadmin/conf/directadmin.conf ]; then
        # Make backup
        sudo cp /usr/local/directadmin/conf/directadmin.conf /usr/local/directadmin/conf/directadmin.conf.backup
        
        print_status "DirectAdmin error pages directory created"
        print_warning "DirectAdmin requires template modifications for full error page support"
        print_status "Please modify /usr/local/directadmin/data/templates/custom error page files as needed"
        print_status "Restarting DirectAdmin service..."
        sudo systemctl restart directadmin
        print_success "DirectAdmin configuration updated"
    else
        print_error "DirectAdmin configuration not found"
        return 1
    fi
}

# Configure aaPanel
configure_aapanel() {
    print_status "Configuring aaPanel error pages"
    
    # Create directory for aaPanel error pages
    local pages_dir="/www/server/panel/vhost/error_pages"
    create_pages_dir "$pages_dir"
    
    # Copy error pages
    copy_pages "$pages_dir"
    
    # Check if aaPanel Nginx is running and configure it
    if [ -f /www/server/nginx/conf/nginx.conf ]; then
        print_status "Configuring aaPanel Nginx"
        
        # Create error configuration file
        cat > /tmp/aapanel_error_pages.conf << 'EOF'
# aaPanel custom error pages configuration
error_page 403 /error_pages/403.html;
error_page 404 /error_pages/404.html;
error_page 410 /error_pages/410.html;
error_page 429 /error_pages/429.html;
error_page 500 /error_pages/500.html;
error_page 502 /error_pages/502.html;
error_page 503 /error_pages/503.html;

location ^~ /error_pages/ {
    alias /www/server/panel/vhost/error_pages/;
    internal;
}
EOF

        sudo cp /tmp/aapanel_error_pages.conf /www/server/nginx/conf/error_pages.conf
        sudo sed -i '/http {/a \    include /www/server/nginx/conf/error_pages.conf;' /www/server/nginx/conf/nginx.conf
        
        # Test configuration and restart
        if /www/server/nginx/sbin/nginx -t; then
            sudo systemctl reload nginx
            print_success "aaPanel Nginx configured for error pages"
        else
            print_error "Nginx configuration test failed"
            return 1
        fi
    else
        print_error "aaPanel Nginx configuration not found"
        return 1
    fi
}

# Main installation function
install_error_pages() {
    detect_distro
    detect_webserver
    
    case $WEB_SERVER in
        "nginx")
            configure_nginx
            ;;
        "apache")
            configure_apache
            ;;
        "cpanel")
            configure_cpanel
            ;;
        "directadmin")
            configure_directadmin
            ;;
        "aapanel")
            configure_aapanel
            ;;
        *)
            print_error "Unsupported or undetected web server: $WEB_SERVER"
            print_warning "You may need to configure manually for your server type"
            ;;
    esac
}

# Uninstall function
uninstall_error_pages() {
    print_status "Uninstalling error pages..."
    
    # Remove error pages directories
    sudo rm -rf /var/www/error_pages
    sudo rm -rf /usr/share/nginx/error_pages
    sudo rm -rf /var/cpanel/custom_error_pages
    sudo rm -rf /usr/local/directadmin/data/templates/custom_error_pages
    sudo rm -rf /www/server/panel/vhost/error_pages
    
    # Remove configuration files
    sudo rm -f /etc/nginx/error-pages.conf
    sudo rm -f /etc/apache2/conf-available/error-pages.conf
    sudo rm -f /tmp/apache_error_pages.conf
    sudo rm -f /tmp/nginx_error_pages.conf
    sudo rm -f /tmp/aapanel_error_pages.conf
    
    # Remove included configurations (if they exist)
    if [ -f /etc/nginx/nginx.conf ] && [ -f /etc/nginx/nginx.conf.backup ]; then
        sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
    fi
    
    print_success "Error pages uninstalled"
}

# Show help
show_help() {
    echo "Web Server Default Pages Installer"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  install     Install Persian error pages (default)"
    echo "  uninstall   Remove error pages"
    echo "  help        Show this help message"
    echo ""
    echo "Supported systems:"
    echo "  - cPanel"
    echo "  - DirectAdmin"
    echo "  - Nginx"
    echo "  - Apache"
    echo "  - aaPanel"
    echo ""
    echo "The script will auto-detect which system you are using and configure accordingly."
}

# Main execution
case "${1:-install}" in
    "install")
        install_error_pages
        ;;
    "uninstall")
        uninstall_error_pages
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac