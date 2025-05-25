# Week 2: Service Implementation Tasks

## Overview

Week 2 focuses on implementing core home automation and monitoring services using the Week 1 foundation architecture.

### Week 2 Scope (Days 6-10)
- **Day 6-7**: Home Automation Core (HomeAssistant + Zigbee2MQTT)
- **Day 8**: Camera Systems (Frigate/Scrypted deployment based on user profile)
- **Day 9**: Monitoring Stack (Uptime Kuma/Grafana based on user profile)
- **Day 10**: Integration Testing & Profile Validation

---

## Epic: Week 2 Service Implementation

**Priority**: High
**Estimated Effort**: 30-40 hours
**Dependencies**: Week 1 foundation complete

### Success Criteria
- [ ] All services deploy via Ansible playbook
- [ ] Services respect user choice framework (enhanced/balanced/lightweight)
- [ ] Resource limits enforced per Intel Mac Mini optimization
- [ ] Thermal management integration working
- [ ] External storage integration for persistent data
- [ ] Network storage integration for backups
- [ ] Basic home automation workflows functional

---

## Task 1: HomeAssistant Core Implementation

**Priority**: High
**Estimated Effort**: 8-10 hours
**Dependencies**: External storage, OrbStack

### Description
Complete the HomeAssistant role implementation for core smart home functionality.

### Acceptance Criteria
- [ ] Complete `roles/homeassistant/tasks/main.yml` implementation
- [ ] Container deployment with proper resource limits per profile
- [ ] Configuration volume mounted to external storage
- [ ] Integration with network storage for backups
- [ ] Basic configuration templates created
- [ ] Health checks and restart policies configured
- [ ] Web interface accessible on port 8123

### Technical Requirements
```yaml
# Resource limits by profile
lightweight: cpu: 0.8, memory: 512MB
balanced: cpu: 1.0, memory: 768MB  
enhanced: cpu: 1.5, memory: 1GB
```

### Implementation Files
- `roles/homeassistant/tasks/main.yml` - Complete container deployment
- `roles/homeassistant/templates/configuration.yaml.j2` - Update base config
- `roles/homeassistant/templates/docker-compose.yml.j2` - Container definition
- `roles/homeassistant/handlers/main.yml` - Service management

---

## Task 2: Zigbee2MQTT Integration

**Priority**: High  
**Estimated Effort**: 4-6 hours
**Dependencies**: HomeAssistant core

### Description
Implement Zigbee2MQTT for smart device connectivity with HomeAssistant.

### Acceptance Criteria
- [ ] Zigbee2MQTT container deployment
- [ ] Integration with HomeAssistant via MQTT
- [ ] Configuration persistence to external storage
- [ ] USB Zigbee coordinator device mapping
- [ ] Web interface accessible for device management
- [ ] Automatic device discovery in HomeAssistant

### Technical Requirements
- USB device passthrough to container
- MQTT broker (Mosquitto) deployment
- Network communication between containers
- Device permission handling

### Implementation Files
- `roles/homeassistant/tasks/zigbee2mqtt.yml` - Zigbee2MQTT setup
- `roles/homeassistant/templates/zigbee2mqtt-config.yaml.j2` - Z2M configuration
- `roles/homeassistant/templates/mosquitto.conf.j2` - MQTT broker config

---

## Task 3: Camera System Implementation (Profile-Dependent)

**Priority**: High
**Estimated Effort**: 10-12 hours  
**Dependencies**: External storage, user choice framework

### Description
Implement camera systems based on user deployment profile.

### Acceptance Criteria

#### Frigate (Lightweight Profile)
- [ ] Complete `roles/frigate/tasks/main.yml` implementation
- [ ] Basic camera detection and recording
- [ ] Storage integration for camera footage
- [ ] CPU-based object detection (no GPU acceleration)
- [ ] Web interface on port 5000
- [ ] Integration with HomeAssistant

#### Scrypted (Balanced/Enhanced Profiles)  
- [ ] Complete `roles/scrypted/tasks/main.yml` implementation
- [ ] Advanced camera management features
- [ ] HomeKit integration capabilities
- [ ] Plugin ecosystem support
- [ ] Web interface for camera management
- [ ] Integration with HomeAssistant

### Technical Requirements
```yaml
# Frigate resource limits
lightweight: cpu: 1.0, memory: 1GB

# Scrypted resource limits  
balanced: cpu: 1.5, memory: 1.5GB
enhanced: cpu: 2.0, memory: 2GB
```

### Implementation Files
- `roles/frigate/tasks/main.yml` - Frigate deployment
- `roles/frigate/templates/config.yml.j2` - Frigate configuration
- `roles/scrypted/tasks/main.yml` - Scrypted deployment  
- `roles/scrypted/templates/docker-compose.yml.j2` - Scrypted container

---

## Task 4: Monitoring Stack Implementation (Profile-Dependent)

**Priority**: Medium
**Estimated Effort**: 6-8 hours
**Dependencies**: User choice framework

### Description
Implement monitoring solutions based on user deployment profile.

### Acceptance Criteria

#### Uptime Kuma (Lightweight/Balanced Profiles)
- [ ] Complete `roles/uptime-kuma/tasks/main.yml` implementation
- [ ] Simple uptime monitoring for all services
- [ ] Web interface on port 3001
- [ ] Notification integrations (email, Discord, etc.)
- [ ] Basic dashboards for service health

#### Grafana/Prometheus (Enhanced Profile)
- [ ] Complete `roles/monitoring/tasks/main.yml` implementation
- [ ] Prometheus metrics collection from all services
- [ ] Grafana dashboards for system and service metrics
- [ ] Intel Mac Mini specific dashboards (temperature, CPU, memory)
- [ ] Container resource monitoring
- [ ] Storage health monitoring integration

### Technical Requirements
```yaml
# Uptime Kuma resource limits
lightweight/balanced: cpu: 0.3-0.5, memory: 128-256MB

# Grafana/Prometheus resource limits
enhanced: 
  grafana: cpu: 1.0, memory: 1GB
  prometheus: cpu: 1.0, memory: 1GB
```

### Implementation Files
- `roles/uptime-kuma/tasks/main.yml` - Uptime Kuma deployment
- `roles/monitoring/tasks/main.yml` - Grafana/Prometheus stack
- `roles/monitoring/templates/prometheus.yml.j2` - Prometheus config
- `roles/monitoring/templates/grafana-dashboards/` - Dashboard definitions

---

## Task 5: Vaultwarden Password Manager (Balanced/Enhanced)

**Priority**: Medium
**Estimated Effort**: 3-4 hours  
**Dependencies**: Network storage for backups

### Description
Implement Vaultwarden for password management in balanced and enhanced profiles.

### Acceptance Criteria
- [ ] Complete `roles/vaultwarden/tasks/main.yml` implementation
- [ ] Secure container deployment with HTTPS
- [ ] Data persistence to external storage
- [ ] Automated backups to network storage
- [ ] Web vault interface accessible
- [ ] Admin panel configuration

### Technical Requirements
```yaml
# Vaultwarden resource limits
balanced/enhanced: cpu: 1.0, memory: 512MB
```

### Implementation Files
- `roles/vaultwarden/tasks/main.yml` - Vaultwarden deployment
- `roles/vaultwarden/templates/vaultwarden.env.j2` - Environment config
- `roles/vaultwarden/handlers/main.yml` - Service management

---

## Task 6: Service Integration Testing

**Priority**: High
**Estimated Effort**: 6-8 hours
**Dependencies**: All service implementations

### Description
Comprehensive testing of service integrations and user choice framework.

### Acceptance Criteria
- [ ] Profile switching validation (lightweight ↔ balanced ↔ enhanced)
- [ ] Service communication testing (HomeAssistant ↔ cameras ↔ monitoring)
- [ ] Resource limit enforcement validation
- [ ] Thermal management integration testing
- [ ] Storage integration validation (external + network)
- [ ] Backup and restore procedures testing
- [ ] Performance benchmarking by profile

### Test Scenarios
1. **Profile Deployment**: Deploy each profile from scratch
2. **Profile Migration**: Switch between profiles with data preservation  
3. **Service Communication**: Verify all integrations work
4. **Resource Constraints**: Test behavior under resource pressure
5. **Thermal Throttling**: Test automatic scaling under heat
6. **Storage Failover**: Test behavior with storage issues
7. **Network Connectivity**: Test behavior with network issues

### Implementation Files
- `tests/week2_integration_tests.yml` - Ansible test playbook
- `scripts/profile_migration_test.sh` - Profile switching validation
- `scripts/performance_benchmark.sh` - Resource usage validation

---

## Task 7: Documentation and User Guides

**Priority**: Medium
**Estimated Effort**: 4-6 hours
**Dependencies**: All implementations complete

### Description
Create comprehensive documentation for Week 2 services.

### Acceptance Criteria
- [ ] Service-specific README files for each role
- [ ] User guide for profile selection and migration
- [ ] Troubleshooting guide for common issues
- [ ] Performance tuning recommendations
- [ ] Integration examples and workflows
- [ ] Backup and recovery procedures

### Implementation Files
- `roles/homeassistant/README.md` - HomeAssistant deployment guide
- `roles/frigate/README.md` - Frigate camera system guide  
- `roles/scrypted/README.md` - Scrypted advanced camera guide
- `roles/uptime-kuma/README.md` - Simple monitoring guide
- `roles/monitoring/README.md` - Advanced monitoring guide
- `roles/vaultwarden/README.md` - Password manager guide
- `docs/WEEK_2_DEPLOYMENT_GUIDE.md` - Complete deployment guide
- `docs/WEEK_2_TROUBLESHOOTING.md` - Issue resolution guide

---

## Week 2 Milestones

### Day 6-7 Milestone: Home Automation Core
- [ ] HomeAssistant role complete and tested
- [ ] Zigbee2MQTT integration working
- [ ] Basic smart home functionality operational

### Day 8 Milestone: Camera Systems  
- [ ] Camera system roles complete (Frigate + Scrypted)
- [ ] Profile-dependent deployment working
- [ ] Camera footage storage integrated

### Day 9 Milestone: Monitoring Stack
- [ ] Monitoring roles complete (Uptime Kuma + Grafana/Prometheus)
- [ ] Service health monitoring operational
- [ ] Performance dashboards functional

### Day 10 Milestone: Integration & Validation
- [ ] All services integrated and tested
- [ ] Profile switching validated
- [ ] Documentation complete
- [ ] Week 2 implementation ready for production

---

## Getting Started with Week 2

### Prerequisites Checklist
- [ ] Week 1 foundation deployed and validated
- [ ] External storage mounted and healthy
- [ ] Network storage configured and accessible  
- [ ] OrbStack container runtime optimized
- [ ] Intel optimizations and thermal management active
- [ ] User choice framework configured

### Deployment Commands
```bash
# Deploy specific Week 2 services
ansible-playbook -i hosts remote_env.yml --tags homeassistant
ansible-playbook -i hosts remote_env.yml --tags camera-system
ansible-playbook -i hosts remote_env.yml --tags monitoring

# Deploy complete Week 2 stack
ansible-playbook -i hosts remote_env.yml --tags week2

# Deploy specific profile
ansible-playbook -i hosts remote_env.yml --extra-vars "deployment_profile=balanced"
```

### Progress Tracking
Use this document as a checklist for Week 2 implementation progress. Each task should be completed in order, with testing after each major milestone.

---

*This task list provides the roadmap for Week 2 implementation. Each task can be converted to GitHub Issues when ready to begin work.*