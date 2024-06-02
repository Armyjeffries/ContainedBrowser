# ContainedBrowser
ContainedBrowser - disposable, containerized, intercept-ready-proxied, firefox browser to assist with suspicious web links.
Designed to operate on "rootless" podman install - using mitmproxy. Mostly isolated. with least privilege (hence rootless podman), and only X11 socket volume mapping for the DISPLAY and bridges port mapping to :8081 for mitmweb interface on host (@ localhost:8081) 

# Prerequisites
### Podman: You'll need Podman installed on your system. Refer to the Podman Installation Guide for instructions.
podman-compose: Install podman-compose. You can get it using pipx install podman-compose.
X11 Server (if applicable): If you want to display the Firefox GUI on your host machine, ensure you have an X11 server running.
Steps:

## Linux Install
Clone the Repository & change directory into it
```Bash
git clone https://github.com/armyjeffries/containedbrowser.git
cd containedbrowser
```

Build the image(s)
```
podman-compose build
```

Run the project
```
podman-compose up
```

~Create~ docker-compose.yaml File:
```
version: '3'
services:
  mitmweb:
    image: docker.io/mitmproxy/mitmproxy
    command: mitmweb --web-port 8081 --web-host 0.0.0.0 --ssl-insecure
    ports:
      - target: 8080
        published: 8080
        protocol: tcp
      - target: 8081
        published: 8081
        protocol: tcp
    networks:
      - containedbrowser_my-network

  contained-browser:
    image: docker.io/fedora:latest
    build: .
    environment:
      DISPLAY: $DISPLAY
      http_proxy: http://mitmweb:8080
      https_proxy: http://mitmweb:8080
      no_proxy: localhost,127.0.0.1
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix
    networks:
      - containedbrowser_my-network
    depends_on:
      - mitmweb
    entrypoint: ["/install-mitmproxy-cert.sh"]

networks:
  containedbrowser_my-network:
    driver: bridge
```

Dockerfile
```
FROM docker.io/fedora:latest

# Install Firefox and certutil to load the mitmproxy cert
RUN dnf install -y firefox nss-tools procps-ng

# Set environment variables (optional)
#ENV MOZ_ENABLE_WAYLAND=0

# Copy the updated installation script
COPY install-mitmproxy-cert.sh /install-mitmproxy-cert.sh
RUN chmod +x /install-mitmproxy-cert.sh
```
install-mitmproxy-cert.sh
```
#!/bin/bash
# Install needed dependencies
dnf install nss-tools -y

# Start Firefox
firefox &

# Wait for Firefox to start
until pgrep -f firefox; do
    echo "Waiting for Firefox to start..."
    sleep 1
done

# Fetch the certificate using curl and store it in a temporary file
curl -sSf "http://mitm.it/cert/pem" -o /tmp/mitmproxy-ca-cert.pem

# Find the Firefox profile directory, which is typically in $HOME/.mozilla/firefox/<profile_name>
sleep 10
firefox_profile_dir=$(find "$HOME/.mozilla/firefox/" -type d -name "*.default-release" | head -n 1)  # Get the first match

# Make sure the profile directory exists
if [ ! -d "$firefox_profile_dir" ]; then
  echo "Firefox profile directory not found."
  exit 1
fi
echo "Profile Directory: $firefox_profile_dir"

# Download and install the certificate
echo "Installing mitmproxy certificate..."

# Use the downloaded file as input for certutil
certutil -d sql:$firefox_profile_dir -A -t "C,," -n mitmproxy -i /tmp/mitmproxy-ca-cert.pem

# Prevent the container from exiting after the script finishes
while true; do sleep 1; done
```
Build and Run the Containers:

Bash
podman-compose up --build

This will build the mitmweb image, start both containers, and the install-mitmproxy-cert.sh script will execute to prepare Firefox.

# Notes
Use the mitmweb interface to inspect, modify, or replay HTTP/HTTPS traffic.

**Remember to stop the containers when you're finished using podman-compose down.**

Rootless Podman: This setup is designed to work with rootless Podman.
Certificate Persistence: The installed certificate will be stored in the Firefox profile within the container. If you delete the container, you'll need to reinstall the certificate.
Troubleshooting: Refer to the mitmproxy documentation for more advanced configuration and troubleshooting tips.
