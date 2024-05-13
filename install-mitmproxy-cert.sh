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
