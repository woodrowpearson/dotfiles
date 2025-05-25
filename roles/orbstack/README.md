# OrbStack Role

Optimized container runtime configuration for Intel Mac Mini with thermal management and resource allocation.

## Features

- **Intel Mac Mini Optimization**: Tailored for Intel i7 processors with thermal management
- **Resource Efficiency**: 75% RAM reduction compared to Docker Desktop
- **Thermal Integration**: Automatic throttling based on CPU temperature
- **Container Profiles**: Pre-configured resource limits for home server services
- **Native macOS Integration**: Seamless file system access and networking
- **Performance Monitoring**: Built-in resource usage tracking

## Why OrbStack over Docker Desktop

### Performance Benefits
- **Memory Usage**: 300MB vs 1.2GB (Docker Desktop)
- **CPU Overhead**: 2-5% vs 10-15% (Docker Desktop)
- **Startup Time**: 3 seconds vs 30+ seconds (Docker Desktop)
- **File System**: Native performance vs virtualized file system

### Intel Mac Mini Advantages
- **Thermal Efficiency**: Lower background CPU usage = less heat generation
- **Resource Availability**: More memory for containers and system operations
- **Battery Life**: Minimal impact on power consumption (for portable deployments)

## Configuration

### OrbStack Settings

```yaml
orbstack_settings:
  enabled: true
  cpu_limit: 4        # Cores (out of 6 total)
  memory_limit: "6GB" # RAM (out of 16GB total)
  disk_limit: "100GB"
  swap_limit: "2GB"
  
  # Intel-specific optimizations
  thermal_management: true
  performance_mode: "balanced"
  io_optimization: true
```

### Container Resource Profiles

```yaml
container_profiles:
  lightweight:
    cpu_limit: "0.5"
    memory_limit: "256MB"
    restart_policy: "unless-stopped"
    
  standard:
    cpu_limit: "1.0"
    memory_limit: "512MB"
    restart_policy: "unless-stopped"
    
  heavy:
    cpu_limit: "2.0"
    memory_limit: "2GB"
    restart_policy: "unless-stopped"
```

### Thermal Management

```yaml
thermal_integration:
  temp_monitoring: true
  throttle_threshold: 80  # °C
  auto_scaling: true
  
  throttle_actions:
    80: "reduce_cpu_25"
    85: "reduce_cpu_50"
    90: "stop_non_essential"
```

## Usage

### Deploy OrbStack

```bash
ansible-playbook -i hosts remote_env.yml --tags orbstack
```

### Container Management

```bash
# List running containers with resource usage
docker stats

# Deploy with resource limits
docker run -d \
  --name homeassistant \
  --cpus="1.0" \
  --memory="1g" \
  --restart=unless-stopped \
  homeassistant/home-assistant

# Check OrbStack status
orb status
```

### Resource Monitoring

```bash
# OrbStack resource usage
orb info

# Container resource limits
docker inspect container_name | grep -A 10 "Resources"

# System thermal state
pmset -g thermlog
```

## Container Deployment Profiles

### Home Server Services

| Service | Profile | CPU | Memory | Purpose |
|---------|---------|-----|--------|---------|
| HomeAssistant | Standard | 1.0 | 1GB | Smart home hub |
| Frigate | Heavy | 2.0 | 2GB | Video processing |
| AdGuard | Lightweight | 0.5 | 256MB | DNS filtering |
| Uptime Kuma | Lightweight | 0.5 | 256MB | Monitoring |
| Vaultwarden | Standard | 1.0 | 512MB | Password manager |

### Resource Allocation Strategy

```yaml
# Total Intel Mac Mini Resources: 6 cores, 16GB RAM
# Reserved for macOS: 2 cores, 10GB RAM
# Available for containers: 4 cores, 6GB RAM

allocation:
  system_reserve:
    cpu_cores: 2
    memory_gb: 10
    purpose: "macOS, Finder, system services"
    
  container_pool:
    cpu_cores: 4
    memory_gb: 6
    max_containers: 8
    
  overhead_buffer:
    cpu_percent: 10
    memory_mb: 500
    purpose: "OrbStack runtime, caching"
```

## Performance Optimization

### Intel-Specific Tuning

```yaml
intel_optimizations:
  # CPU scheduling
  cpu_scheduler: "performance"
  turbo_boost: true
  hyper_threading: true
  
  # Memory management
  memory_balloon: false
  memory_swap: "conserve"
  memory_compression: true
  
  # I/O optimization
  io_scheduler: "deadline"
  disk_cache: "writethrough"
  network_acceleration: true
```

### Container Optimization

```bash
# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1

# Use multi-stage builds
FROM node:alpine AS builder
# ... build steps
FROM node:alpine AS runtime
COPY --from=builder /app/dist ./dist

# Optimize image size
RUN apt-get update && apt-get install -y package \
    && rm -rf /var/lib/apt/lists/*
```

## Thermal Management Integration

### Temperature-Based Scaling

The role implements automatic resource scaling based on CPU temperature:

```bash
# Monitor thermal state
while true; do
  temp=$(powermetrics --samplers smc -n 1 | grep "CPU die" | awk '{print $3}')
  if (( $(echo "$temp > 80" | bc -l) )); then
    # Reduce container CPU limits
    docker update --cpus="0.5" $(docker ps -q)
  fi
  sleep 60
done
```

### Thermal Profiles

```yaml
thermal_profiles:
  cool: # < 70°C
    cpu_multiplier: 1.0
    memory_multiplier: 1.0
    container_limit: 8
    
  warm: # 70-80°C
    cpu_multiplier: 0.8
    memory_multiplier: 1.0
    container_limit: 6
    
  hot: # > 80°C
    cpu_multiplier: 0.5
    memory_multiplier: 0.8
    container_limit: 4
```

## Networking

### OrbStack Network Configuration

```yaml
networking:
  bridge_name: "orbstack"
  ip_range: "192.168.64.0/24"
  dns_server: "192.168.64.1"
  
  port_forwarding:
    homeassistant: "8123:8123"
    frigate: "5000:5000"
    adguard: "3001:3000"
```

### Service Discovery

```bash
# Access containers by name
curl http://homeassistant.orb.local:8123
curl http://frigate.orb.local:5000

# Direct container networking
docker exec -it homeassistant ping frigate
```

## Storage Integration

### Volume Management

```yaml
volumes:
  external_storage:
    source: "/Volumes/HomeServerStorage"
    containers:
      - homeassistant:/config
      - frigate:/media
      - vaultwarden:/data
      
  system_storage:
    source: "/opt/homeserver"
    containers:
      - adguard:/opt/adguardhome/conf
      - uptime-kuma:/app/data
```

### Backup Integration

```bash
# Container volume backup
docker run --rm \
  -v homeassistant_config:/source:ro \
  -v /Volumes/HomeServerStorage/Backups:/backup \
  alpine tar czf /backup/homeassistant-$(date +%Y%m%d).tar.gz -C /source .
```

## Troubleshooting

### Performance Issues

**High CPU Usage**:
```bash
# Check container resource usage
docker stats --no-stream

# Identify resource-heavy containers
docker ps --format "table {{.Names}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Check thermal throttling
pmset -g thermlog | tail -20
```

**Memory Pressure**:
```bash
# Check OrbStack memory usage
orb info | grep Memory

# Check system memory pressure
memory_pressure

# Restart memory-heavy containers
docker restart container_name
```

### Thermal Issues

**Overheating Protection**:
```bash
# Check current temperature
powermetrics --samplers smc -n 1 | grep "CPU die"

# Force container resource reduction
docker update --cpus="0.5" --memory="512m" $(docker ps -q)

# Check fan speed
powermetrics --samplers smc -n 1 | grep -i fan
```

### Container Startup Issues

**Resource Constraints**:
```bash
# Check available resources
orb info

# Inspect container resource limits
docker inspect container_name | jq '.HostConfig.Resources'

# View container logs
docker logs container_name --tail 50
```

## Dependencies

- macOS 11.0+ (Big Sur or later)
- Intel Mac Mini (2018+ recommended)
- OrbStack application installed
- At least 8GB RAM (16GB recommended)
- 50GB+ free disk space

## Migration from Docker Desktop

### Pre-Migration Checklist

1. **Export container configurations**:
```bash
docker inspect container_name > container_name.json
```

2. **Backup volumes**:
```bash
docker run --rm -v volume_name:/data -v $(pwd):/backup alpine tar czf /backup/volume_name.tar.gz -C /data .
```

3. **Document port mappings and networks**

### Migration Steps

1. **Stop Docker Desktop**
2. **Install OrbStack**
3. **Import containers and volumes**
4. **Update resource limits using this role**
5. **Verify thermal management is working**

## Best Practices

1. **Resource Planning**: Don't exceed 75% of allocated resources continuously
2. **Thermal Monitoring**: Set up automated alerts for temperature thresholds
3. **Container Optimization**: Use Alpine-based images when possible
4. **Regular Maintenance**: Restart containers weekly to clear memory leaks
5. **Backup Strategy**: Automate volume backups to external storage