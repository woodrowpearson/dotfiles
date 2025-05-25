# 🏠 Ultimate Mac Mini Home Server

Transform your Mac Mini into a comprehensive smart home automation hub with monitoring, security, and remote access capabilities.

## 🌟 Overview

This setup creates a **server-first Mac Mini** optimized for 24/7 operation with:
- **Complete HomeAssistant ecosystem** with Zigbee, Matter, and WiFi support
- **AI-powered CCTV monitoring** with Frigate NVR and object detection
- **Comprehensive monitoring stack** with Grafana, Prometheus, and AlertManager
- **Network-wide ad blocking** with AdGuard Home
- **Secure remote access** via Tailscale mesh VPN
- **Professional monitoring** with real-time dashboards and alerts

## 🚀 Quick Start

### One-Command Deployment
```bash
# Complete home server stack
ansible-playbook -i hosts remote_env.yml
```

### Layer-by-Layer Deployment
```bash
# Bootstrap core system
ansible-playbook -i hosts remote_env.yml --tags bootstrap

# Setup networking (VPN + DNS)
ansible-playbook -i hosts remote_env.yml --tags networking

# Deploy home automation
ansible-playbook -i hosts remote_env.yml --tags homeautomation

# Add monitoring stack
ansible-playbook -i hosts remote_env.yml --tags monitoring
```

## 🏗️ Architecture Overview

### 🏠 Bootstrap Layer
- **Core System**: macOS optimization for server operation
- **Docker Foundation**: Container runtime for all services
- **Network Configuration**: Firewall and port management
- **System Hardening**: Security settings and performance tuning

### 🌐 Networking Layer
- **Tailscale VPN**: Secure mesh networking with exit node capabilities
- **AdGuard Home**: DNS-based ad blocking for entire network
- **Port Management**: Proper firewall configuration
- **Service Discovery**: Magic DNS for easy service access

### 🏡 Home Automation Layer
- **HomeAssistant Core**: Complete smart home platform
- **PostgreSQL Database**: Reliable data storage
- **MQTT Broker**: Device communication backbone
- **Zigbee2MQTT**: Zigbee device integration
- **Frigate NVR**: AI-powered camera monitoring

### 📊 Monitoring Layer
- **Grafana**: Beautiful dashboards and visualization
- **Prometheus**: Time-series metrics collection
- **AlertManager**: Intelligent alert routing
- **Node Exporter**: System metrics
- **Container Monitoring**: Docker health and resources

## 🎛️ Service Access

After deployment, access your services:

| Service | Local Access | Remote Access (Tailscale) |
|---------|-------------|---------------------------|
| **HomeAssistant** | `http://mac-mini.local:8123` | `http://mac-mini-server:8123` |
| **Frigate NVR** | `http://mac-mini.local:5000` | `http://mac-mini-server:5000` |
| **Grafana** | `http://mac-mini.local:3000` | `http://mac-mini-server:3000` |
| **AdGuard Home** | `http://mac-mini.local:3001` | `http://mac-mini-server:3001` |
| **SSH Access** | `ssh woodrow@mac-mini.local` | `ssh mac-mini-server` |

## 🔧 Initial Configuration

### 1. First Boot Setup

#### System Settings
- **Energy**: Prevent automatic sleeping, wake for network access
- **Sharing**: Enable Screen Sharing and Remote Login
- **Firewall**: Enable with proper exceptions
- **FileVault**: Enable disk encryption (save recovery key!)
- **Software Update**: Enable automatic security updates

#### Network Configuration
- Connect via Ethernet for best performance
- Disable Wi-Fi after Ethernet connection
- Set static IP (optional but recommended)

### 2. Pre-Deployment Checklist

```bash
# Ensure SSH key access
ssh-copy-id woodrow@mac-mini.local

# Verify Ansible connectivity
ansible -i hosts remote -m ping

# Run dry-run to check configuration
ansible-playbook -i hosts remote_env.yml --check
```

### 3. Post-Deployment Configuration

#### HomeAssistant Setup
1. Navigate to `http://mac-mini.local:8123`
2. Complete onboarding wizard
3. Add integrations for your devices:
   - **Hue Bridge**: Discover and add Philips Hue lights
   - **Google Home**: Configure Google Assistant integration
   - **Apple HomeKit**: Enable HomeKit bridge
   - **Zigbee2MQTT**: Add Zigbee devices via MQTT

#### Frigate Camera Setup
1. Edit `/opt/frigate/config/config.yml`
2. Add your camera streams:
```yaml
cameras:
  front_door:
    ffmpeg:
      inputs:
        - path: rtsp://admin:password@192.168.1.100:554/stream1
          roles: [detect, record]
    detect:
      width: 1280
      height: 720
      fps: 5
```

#### AdGuard Network Setup
1. Access `http://mac-mini.local:3001`
2. Complete initial setup wizard
3. Configure router DNS to point to Mac Mini IP
4. Test ad blocking functionality

#### Tailscale Configuration
1. Install Tailscale on your devices
2. Access services remotely via `mac-mini-server` hostname
3. Configure exit node for secure browsing

## 🔍 Monitoring & Maintenance

### Grafana Dashboards
Import pre-configured dashboards:
- **Node Exporter Full**: System metrics and performance
- **Docker and System Monitoring**: Container health
- **HomeAssistant Dashboard**: Smart home metrics
- **AdGuard Home**: DNS and blocking statistics

### Health Checks
```bash
# SSH into the server
ssh mac-mini-server

# Check service status
docker ps
systemctl status tailscaled

# View logs
docker logs homeassistant
docker logs frigate
docker logs adguard
```

### Updates and Maintenance
```bash
# Update the entire stack
cd ~/.dotfiles
git pull origin main
ansible-playbook -i hosts remote_env.yml

# Update specific services
ansible-playbook -i hosts remote_env.yml --tags homeassistant
ansible-playbook -i hosts remote_env.yml --tags monitoring
```

## 🌐 Smart Home Integration

### Supported Devices
- **Zigbee**: Philips Hue, IKEA TRÅDFRI, Aqara sensors
- **Matter**: Thread-enabled devices
- **WiFi**: TP-Link Kasa, Shelly switches
- **LoRaWAN**: Long-range IoT sensors
- **Cameras**: ONVIF/RTSP IP cameras
- **Audio**: AirPlay speakers, Chromecast Audio
- **Voice**: Google Home, Apple HomePod

### Popular Integrations
- **Google Assistant**: Voice control
- **Apple HomeKit**: Siri integration
- **HACS**: Community store for custom components
- **Node-RED**: Visual automation flows
- **ESPHome**: Custom ESP32/ESP8266 devices

## 🔐 Security Considerations

### Network Security
- **Firewall**: Only necessary ports exposed
- **VPN Access**: All remote access via Tailscale
- **DNS Filtering**: AdGuard blocks malicious domains
- **SSL/TLS**: HTTPS for all web interfaces

### Data Protection
- **Local Processing**: No cloud dependencies for core functions
- **Encrypted Storage**: FileVault disk encryption
- **Backup Strategy**: Regular configuration backups
- **Access Control**: Role-based permissions

## 🚨 Troubleshooting

### Common Issues

**Service won't start**:
```bash
docker logs <service-name>
sudo systemctl restart docker
```

**Tailscale connection issues**:
```bash
tailscale status
tailscale up --reset
```

**HomeAssistant database corruption**:
```bash
# Restore from backup
docker exec homeassistant cp /backup/latest.db /config/home-assistant_v2.db
```

### Performance Optimization
- **SSD Storage**: Use fast storage for database operations
- **Memory**: 16GB+ recommended for full stack
- **Network**: Gigabit Ethernet for camera streams
- **Heat Management**: Ensure proper ventilation

## 📚 Additional Resources

- [HomeAssistant Documentation](https://home-assistant.io/docs/)
- [Frigate Configuration](https://docs.frigate.video/)
- [Tailscale Setup Guide](https://tailscale.com/kb/)
- [AdGuard Home Wiki](https://github.com/AdguardTeam/AdGuardHome/wiki)
- [Grafana Dashboard Gallery](https://grafana.com/grafana/dashboards/)

---

*Transform your Mac Mini into the ultimate smart home command center! 🏠✨*