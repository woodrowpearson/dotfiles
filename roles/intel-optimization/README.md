# Intel Optimization Role

Hardware-specific optimizations and thermal management for Intel Mac Mini home server deployment.

## Features

- **Thermal Management**: Active temperature monitoring and throttling protection
- **Performance Tuning**: Intel-specific system optimizations for always-on operation
- **Resource Allocation**: Optimized memory and CPU scheduling for server workloads
- **Power Management**: Energy-efficient settings for 24/7 operation
- **Hardware Monitoring**: Continuous health checks for Intel i7 processors
- **Container Optimization**: Resource limits optimized for Intel Mac Mini hardware

## Intel Mac Mini Specifications

### Supported Models
- **Mac Mini (2018)**: Intel Core i7-8700B 6-core @ 3.2GHz, up to 64GB RAM
- **Mac Mini (2020)**: Intel Core i7-8700B 6-core @ 3.2GHz, up to 64GB RAM

### Thermal Characteristics
- **Operating Temperature**: 10°C to 35°C ambient
- **Max CPU Temperature**: 100°C (thermal throttling at 85°C)
- **Cooling**: Single axial fan with thermal sensors

## Configuration

### Hardware Detection

```yaml
intel_hardware:
  cpu_model: "Intel i7"
  memory_gb: 16
  max_operating_temp: 85
  thermal_design_power: 65  # Watts
  cores: 6
  threads: 12
```

### Thermal Management

```yaml
thermal_management:
  enabled: true
  cpu_temp_threshold_warning: 75
  cpu_temp_threshold_critical: 85
  thermal_throttling_enabled: true
  fan_curve_optimization: true
  ambient_temp_monitoring: true
```

### System Optimization

```yaml
system_optimization:
  memory_management:
    swap_usage: "conservative"
    memory_pressure_handling: true
    buffer_cache_tuning: true
    
  cpu_scheduling:
    scheduler: "performance"
    governor: "ondemand"
    boost_enabled: true
    
  io_optimization:
    disk_scheduler: "deadline"
    read_ahead_kb: 4096
    dirty_ratio: 15
```

### Container Resource Limits

```yaml
container_limits:
  cpu_cores: 4  # Leave 2 cores for system
  memory_gb: 6  # Leave 10GB for system + cache
  swap_gb: 2
  max_containers: 8
```

## Usage

### Deploy Intel Optimizations

```bash
ansible-playbook -i hosts remote_env.yml --tags intel-optimization
```

### Monitor System Performance

```bash
# CPU temperature monitoring
sudo powermetrics --samplers smc -n 1 | grep -i temp

# Memory pressure monitoring
memory_pressure

# Thermal state monitoring
pmset -g thermlog
```

### Thermal Management Scripts

The role installs monitoring scripts that:
- Check CPU temperature every 5 minutes
- Throttle container resources if temperature > 80°C
- Send alerts for thermal issues
- Automatically adjust fan curves

## Performance Tuning

### Intel-Specific Optimizations

1. **CPU Performance**
   - Turbo Boost enabled for burst workloads
   - Hyper-Threading optimization for container workloads
   - CPU frequency scaling for power efficiency

2. **Memory Management**
   - Optimized virtual memory settings for server workloads
   - Buffer cache tuning for storage-heavy operations
   - Swap configuration for container memory overflow

3. **I/O Performance**
   - Deadline scheduler for consistent latency
   - Read-ahead optimization for sequential access
   - Dirty page writeback tuning

### Container Resource Allocation

```yaml
# Recommended container limits for 16GB Intel Mac Mini
services:
  homeassistant:
    cpu_limit: "1.0"
    memory_limit: "1GB"
    
  frigate:
    cpu_limit: "2.0"
    memory_limit: "2GB"
    
  monitoring:
    cpu_limit: "0.5"
    memory_limit: "512MB"
    
  adguard:
    cpu_limit: "0.5"
    memory_limit: "256MB"
```

## Monitoring and Alerting

### Temperature Monitoring

```bash
# Real-time temperature monitoring
sudo powermetrics --samplers smc -n 0 | grep -E "CPU die|GPU die"

# Historical thermal data
sudo log show --predicate 'subsystem == "com.apple.thermalmonitor"' --last 1h
```

### Performance Metrics

```bash
# CPU utilization per core
top -l 1 | grep "CPU usage"

# Memory pressure and paging
vm_stat

# Disk I/O statistics
iostat -w 5
```

### Alert Thresholds

- **CPU Temperature > 75°C**: Warning alert
- **CPU Temperature > 85°C**: Critical alert + throttling
- **Memory Pressure > 80%**: Warning alert
- **Disk I/O Wait > 20%**: Performance alert

## Thermal Safety Features

### Automatic Throttling

1. **75°C Warning**: Log temperature spike, check system load
2. **80°C Caution**: Reduce container CPU limits by 25%
3. **85°C Critical**: Reduce container CPU limits by 50%
4. **90°C Emergency**: Stop non-essential containers

### Recovery Procedures

```bash
# Force thermal reset
sudo pmset -a force 1

# Container resource reduction
docker update --cpus="0.5" container_name

# System thermal monitoring
sudo powermetrics --samplers smc,cpu_power -n 10
```

## Troubleshooting

### High Temperature Issues

**Symptoms**: Frequent thermal throttling, fan noise
**Solutions**:
- Check ambient room temperature (should be < 25°C)
- Clean Mac Mini vents and fans
- Reduce container resource limits
- Enable aggressive power management

### Performance Degradation

**Symptoms**: Slow response times, high CPU wait
**Solutions**:
- Check for thermal throttling with `pmset -g thermlog`
- Monitor container resource usage
- Verify disk I/O isn't saturated
- Review memory pressure with `memory_pressure`

### Memory Pressure

**Symptoms**: High swap usage, container OOM kills
**Solutions**:
- Reduce container memory limits
- Enable swap compression
- Add swap file if needed
- Monitor with `vm_stat` and `top`

## Dependencies

- macOS 10.15+ (for thermal management APIs)
- Intel Mac Mini hardware
- Administrator privileges for system tuning
- Homebrew (for monitoring tools)

## Best Practices

1. **Monitor continuously**: Set up automated temperature monitoring
2. **Plan for thermal limits**: Don't exceed 70% CPU utilization continuously
3. **Stagger workloads**: Avoid running all intensive tasks simultaneously
4. **Regular maintenance**: Clean hardware every 6 months
5. **Room cooling**: Maintain ambient temperature below 25°C