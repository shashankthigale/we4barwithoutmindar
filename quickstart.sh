#!/bin/bash

# WebAR Image Tracking - Quick Start Script
# This script helps set up and run the WebAR application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║   WebAR Image Tracking - Quick Start   ║"
echo "╔════════════════════════════════════════╗"
echo -e "${NC}"

# Check if required files exist
check_files() {
    echo -e "${YELLOW}Checking required files...${NC}"
    
    if [ ! -f "index.html" ]; then
        echo -e "${RED}✗ index.html not found!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ index.html found${NC}"
    
    if [ ! -f "poster.png" ]; then
        echo -e "${YELLOW}⚠ poster.png not found${NC}"
        echo -e "${BLUE}  You need to provide a target image as 'poster.png'${NC}"
        MISSING_ASSETS=true
    else
        echo -e "${GREEN}✓ poster.png found${NC}"
    fi
    
    if [ ! -f "overlay.mp4" ]; then
        echo -e "${YELLOW}⚠ overlay.mp4 not found${NC}"
        echo -e "${BLUE}  You need to provide an overlay video as 'overlay.mp4'${NC}"
        MISSING_ASSETS=true
    else
        echo -e "${GREEN}✓ overlay.mp4 found${NC}"
    fi
    
    echo ""
}

# Check assets and exit if missing
check_missing_assets() {
    if [ "$MISSING_ASSETS" = true ]; then
        echo -e "${RED}Required assets are missing!${NC}"
        echo -e "${YELLOW}Please provide:${NC}"
        echo -e "${BLUE}  - poster.png (target image for tracking)${NC}"
        echo -e "${BLUE}  - overlay.mp4 (video to display on target)${NC}"
        echo -e ""
        echo -e "${YELLOW}Place both files in the project root directory${NC}"
        exit 1
    fi
}

# Detect and start web server
start_server() {
    echo -e "${YELLOW}Starting web server...${NC}"
    
    PORT=8000
    
    # Check if port is in use
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}Port $PORT is already in use${NC}"
        read -p "Use port 8001 instead? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            PORT=8001
        else
            exit 1
        fi
    fi
    
    # Detect available web server
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}Using Python 3 HTTP server${NC}"
        echo -e "${BLUE}Server running at: http://localhost:$PORT${NC}"
        echo -e "${BLUE}Press Ctrl+C to stop${NC}"
        echo ""
        python3 -m http.server $PORT
    elif command -v python &> /dev/null; then
        echo -e "${GREEN}Using Python 2 HTTP server${NC}"
        echo -e "${BLUE}Server running at: http://localhost:$PORT${NC}"
        echo -e "${BLUE}Press Ctrl+C to stop${NC}"
        echo ""
        python -m SimpleHTTPServer $PORT
    elif command -v php &> /dev/null; then
        echo -e "${GREEN}Using PHP built-in server${NC}"
        echo -e "${BLUE}Server running at: http://localhost:$PORT${NC}"
        echo -e "${BLUE}Press Ctrl+C to stop${NC}"
        echo ""
        php -S localhost:$PORT
    elif command -v npx &> /dev/null; then
        echo -e "${GREEN}Using Node.js http-server${NC}"
        echo -e "${BLUE}Server running at: http://localhost:$PORT${NC}"
        echo -e "${BLUE}Press Ctrl+C to stop${NC}"
        echo ""
        npx -y http-server -p $PORT
    else
        echo -e "${RED}No web server found!${NC}"
        echo -e "${YELLOW}Please install one of: Python 3, PHP, or Node.js${NC}"
        exit 1
    fi
}

# Show mobile access instructions
show_mobile_instructions() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}  Server Started Successfully!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Desktop Access:${NC}"
    echo -e "  http://localhost:$PORT"
    echo ""
    echo -e "${BLUE}Mobile Access:${NC}"
    echo -e "${YELLOW}  1. Ensure your mobile device is on the same WiFi network${NC}"
    echo -e "${YELLOW}  2. Find your local IP address:${NC}"
    
    # Try to get local IP
    if command -v ipconfig &> /dev/null; then
        # Windows
        IP=$(ipconfig | grep -i "IPv4" | head -n 1 | awk '{print $NF}')
    elif command -v ifconfig &> /dev/null; then
        # macOS/Linux
        IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}')
    elif command -v ip &> /dev/null; then
        # Linux (newer)
        IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}' | cut -d/ -f1)
    fi
    
    if [ ! -z "$IP" ]; then
        echo -e "${GREEN}     Your IP: $IP${NC}"
        echo -e "${GREEN}     Mobile URL: http://$IP:$PORT${NC}"
    else
        echo -e "${YELLOW}     Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux) to find your IP${NC}"
        echo -e "${YELLOW}     Then visit: http://YOUR_IP:$PORT on your mobile device${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "${YELLOW}  1. Open the URL in Chrome (Android) or Safari (iOS)${NC}"
    echo -e "${YELLOW}  2. Grant camera permissions${NC}"
    echo -e "${YELLOW}  3. Print poster.png or display on another screen${NC}"
    echo -e "${YELLOW}  4. Point camera at the image${NC}"
    echo -e "${YELLOW}  5. Watch the AR overlay appear!${NC}"
    echo ""
}

# Main execution
main() {
    check_files
    check_missing_assets
    
    show_mobile_instructions
    start_server
}

# Run main function
main

