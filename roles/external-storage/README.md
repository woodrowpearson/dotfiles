# External Storage Role

Comprehensive external storage management for Mac Mini home server with auto-detection, mounting, health monitoring, and cleanup automation.

## Features

- **Auto-Detection**: Automatically detects and mounts external drives
- **Health Monitoring**: Continuous disk health checks using S.M.A.R.T. data
- **Directory Structure**: Creates organized storage hierarchy for all services
- **Intel Optimization**: Thermal-aware operations for Intel Mac Mini
- **Cleanup Automation**: Automated maintenance and space management
- **macOS Integration**: Native diskutil and launchd integration

## Directory Structure

```
/Volumes/HomeServerStorage/
├── CameraFootage/          # Camera recordings and snapshots
├── Backups/                # Time Machine and system backups
├── ContainerData/          # Docker/OrbStack persistent data
├── Logs/                   # Application and system logs
└── Temp/                   # Temporary processing files
```

## Configuration

### Storage Settings

```yaml
external_storage:
  enabled: true
  auto_detect: true
  mount_point: "/Volumes/HomeServerStorage"
  filesystem_type: "auto"
  health_monitoring: true
  cleanup_enabled: true
```

### Health Monitoring

```yaml
health_monitoring:
  check_interval: 3600
  smart_tests: true
  temperature_monitoring: true
  space_alerts: true
  min_free_space_gb: 50
```

### Intel Optimization

```yaml
intel_optimizations:
  thermal_throttling: true
  power_management: true
  io_scheduling: "deadline"
  cache_optimization: true
```

## Usage

### Deploy External Storage

```bash
ansible-playbook -i hosts remote_env.yml --tags external-storage
```

### Manual Mount Operations

```bash
# Check storage status
sudo /opt/homebrew/bin/storage-health.sh

# Force remount
sudo diskutil unmount /Volumes/HomeServerStorage
sudo diskutil mount /dev/disk2s1
```

### Health Monitoring

The role installs automated health monitoring that:
- Checks S.M.A.R.T. status every hour
- Monitors disk temperature and I/O
- Sends alerts for space/health issues
- Performs automatic cleanup when needed

## Templates

- `auto-mount.plist.j2`: LaunchDaemon for automatic mounting
- `storage-health.sh.j2`: Health monitoring script
- `storage-cleanup.sh.j2`: Automated cleanup script

## Dependencies

- macOS 10.15+ (Catalina or later)
- External drive with 100GB+ free space
- Homebrew (for smartmontools)

## Compatibility

- **Optimized for**: Intel Mac Mini with external USB 3.0+ drives
- **Supports**: APFS, HFS+, exFAT, NTFS (read-only)
- **Tested with**: Samsung T7, SanDisk Extreme Pro, WD My Passport