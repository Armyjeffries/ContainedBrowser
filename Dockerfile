FROM docker.io/fedora:latest

# Install Firefox and certutil to load the mitmproxy cert
RUN dnf install -y firefox nss-tools procps-ng

# Set environment variables (optional)
#ENV MOZ_ENABLE_WAYLAND=0

# Copy the updated installation script 
COPY install-mitmproxy-cert.sh /install-mitmproxy-cert.sh
RUN chmod +x /install-mitmproxy-cert.sh

