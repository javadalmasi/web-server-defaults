# Web Server Default Pages Installation Script

This repository contains a comprehensive installation script for deploying Persian web server error pages on various Linux systems and control panels.

## Features

- **Multi-platform support**: Works on cPanel, DirectAdmin, Nginx, Apache, and aaPanel
- **Automatic detection**: The script automatically detects your web server/control panel
- **Easy installation**: One command installation process
- **Complete error pages**: Includes all common HTTP error pages
- **Persian localization**: All pages are in Persian with RTL support
- **Local assets**: No external dependencies

## Supported Systems

- **cPanel**
- **DirectAdmin**
- **Nginx** (standalone)
- **Apache** (standalone)
- **aaPanel**

## Installation

### Prerequisites

- Root or sudo access to your server
- Bash shell environment
- Git (optional, for cloning the repository)

### Method 1: Direct Download

1. Download the repository to your server:
   ```bash
   wget https://github.com/javadalmasi/web-server-defaults/archive/main.zip
   unzip main.zip
   cd web-server-defaults-main
   ```

2. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installation script:
   ```bash
   sudo ./install.sh install
   ```

### Method 2: Git Clone

1. Clone the repository:
   ```bash
   git clone https://github.com/javadalmasi/web-server-defaults.git
   cd web-server-defaults
   ```

2. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the installation script:
   ```bash
   sudo ./install.sh install
   ```

## Usage

### Installation Command
```bash
sudo ./install.sh install
```

### Uninstallation Command
```bash
sudo ./install.sh uninstall
```

### Show Help
```bash
./install.sh help
```

## How It Works

### For Apache Systems

1. Creates a directory at `/var/www/error_pages`
2. Copies all the Persian error pages to the directory
3. Creates Apache configuration snippets to handle error codes:
   - 403: Forbidden
   - 404: Not Found
   - 410: Gone
   - 429: Too Many Requests
   - 500: Internal Server Error
   - 502: Bad Gateway
   - 503: Service Unavailable
4. Reloads Apache service

### For Nginx Systems

1. Creates a directory at `/usr/share/nginx/error_pages`
2. Copies all the Persian error pages to the directory
3. Creates Nginx configuration to handle error codes (same as Apache)
4. Adds location directive to serve error pages internally
5. Reloads Nginx service

### For Control Panels

The script detects and configures for:

- **cPanel**: Creates custom error pages in the appropriate cPanel location
- **DirectAdmin**: Sets up custom error page templates
- **aaPanel**: Configures Nginx with custom error pages

## Error Pages Included

The installation includes the following error pages in Persian:

- `403.html` - Forbidden Access
- `404.html` - Page Not Found  
- `500.html` - Internal Server Error
- `502.html` - Bad Gateway
- `503.html` - Service Unavailable
- `410.html` - Gone
- `429.html` - Too Many Requests
- `default.html` - Default Page
- `stop.html` - Site Stopped
- `unbound-domain.html` - Unbound Domain
- `index.html` - Index Guide Page

## Customization

After installation, you can customize the error pages by modifying the files in:

- **Apache**: `/var/www/error_pages/`
- **Nginx**: `/usr/share/nginx/error_pages/`
- **cPanel**: `/var/cpanel/custom_error_pages/`
- **DirectAdmin**: `/usr/local/directadmin/data/templates/custom_error_pages/`
- **aaPanel**: `/www/server/panel/vhost/error_pages/`

## Troubleshooting

### If Installation Fails

1. Check that you're running the script with sudo
2. Verify that your web server is running
3. Check that the necessary configuration files exist

### If Error Pages Don't Show

1. Verify that your web server configuration includes the error page directives
2. Check file permissions on the error pages directory
3. Restart your web server after installation

### For Nginx

If you're using a custom Nginx setup, you may need to manually add these lines to your server blocks:

```nginx
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
```

### For Apache

If you're using a custom Apache setup, add these directives to your virtual host configuration:

```apache
ErrorDocument 403 /error_pages/403.html
ErrorDocument 404 /error_pages/404.html
ErrorDocument 410 /error_pages/410.html
ErrorDocument 429 /error_pages/429.html
ErrorDocument 500 /error_pages/500.html
ErrorDocument 502 /error_pages/502.html
ErrorDocument 503 /error_pages/503.html
```

## Security Notes

- The script requires root privileges to modify system configuration files
- All files are copied locally with no external dependencies
- Error pages are served as static files for security
- Files are only accessible through the internal location directive in Nginx

## License

This project is licensed under the Creative Commons Attribution 4.0 International License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Verify your system is supported
3. Check logs for error messages
4. Open an issue on the GitHub repository

## Contributing

Contributions to improve the installer script or add support for additional systems are welcome. Please fork the repository and submit a pull request.