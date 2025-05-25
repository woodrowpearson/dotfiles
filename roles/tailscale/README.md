# Tailscale VPN Role

Secure mesh VPN networking for remote access and service discovery.

## Features

- **Mesh VPN**: Secure peer-to-peer connections
- **Magic DNS**: Internal service discovery and routing  
- **ACL Management**: Fine-grained access control
- **Exit Nodes**: Internet routing through the server
- **Subnet Routing**: Access to local network resources
- **MagicDNS**: Automatic DNS for all devices
- **Taildrop**: Secure file sharing between devices

## Network Architecture

- **Server as Exit Node**: Route internet traffic through home server
- **Subnet Access**: Access home network (192.168.1.0/24) remotely
- **Service Discovery**: Access HomeAssistant, Frigate, etc. by name
- **Split Tunneling**: Selective routing for optimal performance

## Security

- **WireGuard Protocol**: Modern, fast, secure VPN
- **Key Rotation**: Automatic key management
- **Device Authentication**: Multi-factor authentication
- **Network Segmentation**: Isolated device access

## Integration

- **HomeAssistant**: Remote access to dashboard and controls
- **Frigate**: Secure camera access from anywhere
- **Monitoring**: Access to Grafana dashboards remotely
- **SSH Access**: Secure shell access to the server