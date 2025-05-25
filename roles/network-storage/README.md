# Network Storage Role

Network file sharing configuration for Mac Mini home server supporting SMB, AFP, and NFS protocols with Time Machine integration.

## Features

- **Multi-Protocol Support**: SMB, AFP, and NFS sharing
- **Time Machine Integration**: Dedicated backup share with proper AFP configuration
- **Security**: User-based access control and encrypted connections
- **Performance**: Optimized for Intel Mac Mini networking
- **Auto-Discovery**: Bonjour/mDNS service advertisement
- **Cross-Platform**: Compatible with macOS, Windows, and Linux clients

## Shares Configuration

### Default Shares

| Share Name | Path | Protocol | Purpose | Access |
|------------|------|----------|---------|---------|
| `HomeServer` | `/Volumes/HomeServerStorage` | SMB/AFP | General file storage | Read/Write |
| `TimeMachine` | `/Volumes/HomeServerStorage/Backups/TimeMachine` | AFP | Time Machine backups | Mac only |
| `CameraFootage` | `/Volumes/HomeServerStorage/CameraFootage` | SMB/NFS | Camera recordings | Read-only |
| `ContainerData` | `/Volumes/HomeServerStorage/ContainerData` | NFS | Container volumes | Service access |

## Configuration

### Network Sharing Settings

```yaml
network_storage:
  enabled: true
  protocols:
    smb: true
    afp: true
    nfs: true
  
  smb_settings:
    workgroup: "HOMESERVER"
    netbios_name: "{{ ansible_hostname }}"
    security: "user"
    
  afp_settings:
    server_name: "{{ ansible_hostname }} Home Server"
    time_machine: true
    
  nfs_settings:
    version: 4
    security: "sys"
```

### Time Machine Configuration

```yaml
time_machine:
  enabled: true
  max_size_gb: 500
  quota_enabled: true
  sparsebundle_bands: true
```

### Security Settings

```yaml
security:
  guest_access: false
  encrypted_connections: true
  access_control: true
  allowed_users:
    - "{{ ansible_user }}"
    - "homeserver"
```

## Usage

### Deploy Network Storage

```bash
ansible-playbook -i hosts remote_env.yml --tags network-storage
```

### Client Connection

#### macOS Clients
```bash
# Connect via Finder
# Go > Connect to Server > afp://your-mac-mini.local
# Or: smb://your-mac-mini.local

# Mount Time Machine share
sudo tmutil setdestination -a afp://username@your-mac-mini.local/TimeMachine
```

#### Windows Clients
```cmd
# Map network drive
net use Z: \\your-mac-mini.local\HomeServer /persistent:yes
```

#### Linux Clients
```bash
# Mount SMB share
sudo mount -t cifs //your-mac-mini.local/HomeServer /mnt/homeserver -o username=your-user

# Mount NFS share  
sudo mount -t nfs your-mac-mini.local:/Volumes/HomeServerStorage/CameraFootage /mnt/camera
```

## Service Management

### SMB (Samba)
```bash
# Start/stop SMB sharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.smbd.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist

# Check SMB status
smbutil statshares -a
```

### AFP (Apple Filing Protocol)
```bash
# Enable/disable AFP
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
```

### NFS (Network File System)
```bash
# Check NFS exports
sudo showmount -e localhost

# Restart NFS
sudo nfsd restart
```

## Performance Tuning

### Intel Mac Mini Optimizations
- SMB multi-channel support for USB 3.0+ drives
- AFP packet size optimization for Time Machine
- NFS async mode for camera footage streaming
- Jumbo frame support for gigabit networks

### Network Configuration
```yaml
performance:
  smb_max_protocol: "SMB3"
  smb_min_protocol: "SMB2"
  smb_signing: false  # Disable for performance
  tcp_window_scaling: true
  jumbo_frames: true  # If network supports 9000 MTU
```

## Troubleshooting

### Common Issues

**Time Machine "disk not available"**:
```bash
# Reset Time Machine destinations
sudo tmutil removedestination -i
sudo tmutil setdestination afp://server/TimeMachine
```

**SMB connection refused**:
```bash
# Check firewall settings
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/sbin/smbd
```

**NFS permission denied**:
```bash
# Check export permissions
sudo cat /etc/exports
sudo exportfs -rv
```

## Dependencies

- macOS Server features (SMB/AFP built-in)
- External storage role (provides mount points)
- Network connectivity with mDNS/Bonjour

## Security Considerations

- Use encrypted connections (SMB3, AFP with SSL)
- Restrict access to known users only
- Regular backup of share configurations
- Monitor access logs for suspicious activity