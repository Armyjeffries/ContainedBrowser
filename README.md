# ContainedBrowser
Browser in the middle - disposable, containerized, intercept-ready-proxied, firefox browser to assist with suspicious web links.
Designed to operate on "rootless" podman install - using mitmproxy. Mostly isolated. with least privilege (hence rootless podman), and only X11 socket volume mapping for the DISPLAY and bridges port mapping to :8081 for mitmweb interface on host (@ localhost:8081) 

## Linux Install
**WIP**
git "xxxxxx"
podman-compose build
podman-compose up 
