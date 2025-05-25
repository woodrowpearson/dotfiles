# User Choice Framework

The Mac Mini Home Server deployment includes a comprehensive user choice framework that allows for flexible service selection and deployment profiles tailored to different use cases and resource requirements.

## Overview

The framework is implemented in `group_vars/remote` and provides three pre-configured deployment profiles with the ability to customize individual service selections and resource allocations.

## Deployment Profiles

### Enhanced Profile
**Target**: Power users with maximum features and comprehensive monitoring
- **CPU Usage**: 70-80% of available resources
- **Memory Usage**: 4-5GB container allocation
- **Services**: All available services enabled
- **Use Case**: Complete home automation, advanced monitoring, development environment

```yaml
deployment_profile: "enhanced"
```

**Included Services:**
- HomeAssistant (Smart home hub)
- Scrypted (Advanced camera management)
- Uptime Kuma (Comprehensive monitoring)
- AdGuard Home (Network-wide ad blocking)
- Vaultwarden (Password management)
- Frigate (AI-powered video surveillance)
- Grafana + Prometheus (Advanced analytics)

### Balanced Profile ⭐ **Recommended**
**Target**: Most users seeking core functionality with good performance
- **CPU Usage**: 50-60% of available resources  
- **Memory Usage**: 3-4GB container allocation
- **Services**: Essential services with smart defaults
- **Use Case**: Home automation, basic monitoring, network services

```yaml
deployment_profile: "balanced"
```

**Included Services:**
- HomeAssistant (Smart home hub)
- Scrypted (Camera management) 
- Uptime Kuma (Basic monitoring)
- AdGuard Home (DNS filtering)
- Vaultwarden (Password management)

### Lightweight Profile
**Target**: Minimal resource usage or testing environments
- **CPU Usage**: 30-40% of available resources
- **Memory Usage**: 2-3GB container allocation  
- **Services**: Core services only
- **Use Case**: Basic home automation, development testing, resource-constrained setups

```yaml
deployment_profile: "lightweight"
```

**Included Services:**
- HomeAssistant (Smart home hub)
- Frigate (Basic camera system)
- Uptime Kuma (Simple monitoring)
- AdGuard Home (DNS filtering)

## Service Selection Matrix

The framework automatically enables services based on the selected profile:

| Service | Enhanced | Balanced | Lightweight | Resource Impact |
|---------|----------|----------|-------------|-----------------|
| HomeAssistant | ✅ | ✅ | ✅ | Medium |
| Camera Service* | Scrypted | Scrypted | Frigate | High |
| Monitoring** | Grafana | Uptime Kuma | Uptime Kuma | Low-High |
| DNS Filtering | AdGuard | AdGuard | AdGuard | Low |
| Password Mgmt | Vaultwarden | Vaultwarden | - | Low |
| AI Video | Frigate | - | Frigate | High |
| Analytics | Grafana | - | - | Medium |

*Camera Service Choice: Scrypted (advanced) vs Frigate (basic)
**Monitoring Choice: Grafana (advanced) vs Uptime Kuma (simple)

## Configuration Structure

### Main Configuration
Located in `group_vars/remote`:

```yaml
# Deployment Profile Selection
deployment_profile: "balanced"  # enhanced | balanced | lightweight

# Service Profiles (auto-configured based on deployment_profile)
service_profiles:
  enhanced:
    camera_service: "scrypted"
    monitoring_service: "grafana"
    containers: ["homeassistant", "scrypted", "grafana", "prometheus", "adguard", "vaultwarden", "frigate"]
    
  balanced:
    camera_service: "scrypted"
    monitoring_service: "uptime_kuma"
    containers: ["homeassistant", "scrypted", "uptime-kuma", "adguard", "vaultwarden"]
    
  lightweight:
    camera_service: "frigate"
    monitoring_service: "uptime_kuma"
    containers: ["homeassistant", "frigate", "uptime-kuma", "adguard"]
```

### Service Enablement Logic

```yaml
# Automatic service enablement based on profile
homeassistant_enabled: true  # Always enabled
scrypted_enabled: "{{ service_profiles[deployment_profile].camera_service == 'scrypted' }}"
frigate_enabled: "{{ service_profiles[deployment_profile].camera_service == 'frigate' }}"
grafana_enabled: "{{ service_profiles[deployment_profile].monitoring_service == 'grafana' }}"
uptime_kuma_enabled: "{{ service_profiles[deployment_profile].monitoring_service == 'uptime_kuma' }}"
adguard_enabled: true  # Always enabled
vaultwarden_enabled: "{{ 'vaultwarden' in service_profiles[deployment_profile].containers }}"
```

## Resource Allocation

### Intel Mac Mini Resource Planning (16GB RAM, 6-core i7)

```yaml
# System Resource Allocation
mac_mini_resources:
  total_cores: 6
  total_memory_gb: 16
  
  # System reservation
  system_cores: 2
  system_memory_gb: 10
  
  # Container allocation by profile
  enhanced_allocation:
    cores: 4
    memory_gb: 6
    max_containers: 8
    
  balanced_allocation:
    cores: 3
    memory_gb: 4
    max_containers: 5
    
  lightweight_allocation:
    cores: 2
    memory_gb: 3
    max_containers: 4
```

### Container Resource Limits by Profile

```yaml
# Enhanced Profile Resource Limits
enhanced_limits:
  homeassistant:
    cpu_limit: "1.5"
    memory_limit: "1GB"
  scrypted:
    cpu_limit: "2.0"
    memory_limit: "2GB"
  grafana:
    cpu_limit: "1.0"
    memory_limit: "1GB"
  prometheus:
    cpu_limit: "1.0"
    memory_limit: "1GB"

# Balanced Profile Resource Limits  
balanced_limits:
  homeassistant:
    cpu_limit: "1.0"
    memory_limit: "768MB"
  scrypted:
    cpu_limit: "1.5"
    memory_limit: "1.5GB"
  uptime_kuma:
    cpu_limit: "0.5"
    memory_limit: "256MB"

# Lightweight Profile Resource Limits
lightweight_limits:
  homeassistant:
    cpu_limit: "0.8"
    memory_limit: "512MB"
  frigate:
    cpu_limit: "1.0"
    memory_limit: "1GB"
  uptime_kuma:
    cpu_limit: "0.3"
    memory_limit: "128MB"
```

## Customization Options

### Override Individual Services

```yaml
# Custom service selection (overrides profile defaults)
custom_service_selection:
  homeassistant_enabled: true
  scrypted_enabled: false      # Disable even if profile includes it
  frigate_enabled: true        # Enable even if profile doesn't include it
  grafana_enabled: false       # Use lightweight monitoring instead
  uptime_kuma_enabled: true
  adguard_enabled: true
  vaultwarden_enabled: false   # Disable password manager
```

### Custom Resource Limits

```yaml
# Override default resource limits
custom_resource_limits:
  homeassistant:
    cpu_limit: "2.0"           # Increase from profile default
    memory_limit: "2GB"        # Increase from profile default
  frigate:
    cpu_limit: "1.5"           # Reduce for thermal management
    memory_limit: "1.5GB"
```

### Storage Path Customization

```yaml
# Custom storage paths (defaults to external storage)
custom_storage_paths:
  camera_footage: "/Volumes/CameraStorage"      # Separate drive for cameras
  container_data: "/opt/homeserver/containers"  # Local SSD for performance
  backups: "/Volumes/BackupDrive"               # Dedicated backup drive
```

## Usage Examples

### Switching Deployment Profiles

```bash
# Edit group_vars/remote
vim group_vars/remote

# Change deployment_profile to desired setting
deployment_profile: "enhanced"

# Re-run deployment
ansible-playbook -i hosts remote_env.yml
```

### Profile Comparison Deployment

```bash
# Deploy specific profile sections for testing
ansible-playbook -i hosts remote_env.yml --tags foundation,storage,optimization
ansible-playbook -i hosts remote_env.yml --tags monitoring --extra-vars "deployment_profile=lightweight"
```

### Custom Service Selection

```bash
# Deploy with custom overrides
ansible-playbook -i hosts remote_env.yml --extra-vars '{
  "deployment_profile": "balanced",
  "scrypted_enabled": false,
  "frigate_enabled": true,
  "grafana_enabled": true
}'
```

## Profile Migration

### Upgrading from Lightweight to Balanced

1. **Check Resources**: Ensure sufficient CPU/memory available
2. **Update Configuration**: Change `deployment_profile` to `"balanced"`
3. **Deploy**: Run full playbook to install additional services
4. **Verify**: Check container resource usage and thermal status

### Downgrading from Enhanced to Balanced

1. **Backup Data**: Export configurations from services being removed
2. **Update Configuration**: Change `deployment_profile` to `"balanced"`
3. **Deploy**: Run playbook (will automatically stop excluded services)
4. **Cleanup**: Remove unused container volumes if needed

## Monitoring and Validation

### Resource Usage Validation

```bash
# Check container resource consumption
docker stats --no-stream

# Verify profile allocation matches actual usage
docker system df

# Monitor thermal status during operation
pmset -g thermlog
```

### Service Health Checks

```bash
# Verify all profile services are running
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check service-specific health endpoints
curl -f http://localhost:8123/api/ # HomeAssistant
curl -f http://localhost:3001/     # AdGuard
curl -f http://localhost:3001/     # Uptime Kuma
```

## Best Practices

1. **Start with Balanced**: Most users should begin with the balanced profile
2. **Monitor Resources**: Watch CPU temperature and memory usage for first 24 hours
3. **Gradual Scaling**: Move from lightweight → balanced → enhanced over time
4. **Thermal Awareness**: Enhanced profile may require better cooling/ventilation
5. **Backup Before Changes**: Always backup container volumes before profile changes
6. **Test Deployments**: Use `--check` flag to preview changes before applying

## Troubleshooting

### Profile Deployment Issues

**Symptom**: Services not starting after profile change
**Solution**: Check resource limits and container logs
```bash
docker logs container_name
docker inspect container_name | jq '.HostConfig.Resources'
```

**Symptom**: High CPU temperature with enhanced profile
**Solution**: Reduce to balanced profile or improve cooling
```bash
powermetrics --samplers smc -n 1 | grep "CPU die"
```

**Symptom**: Memory pressure warnings
**Solution**: Reduce profile or increase system memory
```bash
memory_pressure
vm_stat | grep "Pages free"
```