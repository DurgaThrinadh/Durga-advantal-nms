# Advantal NMS

![Advantal logo](ui/logo.png)

An enterprise-class, open-source distributed network monitoring solution by **Advantal Technologies Pvt Ltd**, designed to monitor the performance and availability of network devices, servers, services, and other IT resources.

## Architecture

| Container | Role | Port |
|-----------|------|------|
| advantal-db | PostgreSQL database | Internal |
| advantal-server | NMS backend (compiled from source) | 10051 |
| advantal-web | Web frontend (PHP/Nginx) | 9090 |
| advantal-agent | Monitoring agent | Internal |
| advantal-snmptraps | SNMP trap receiver | 162/UDP |

---

## Server Deployment Guide

### Files Required
- `advantal-server.tar`
- `advantal-web.tar`
- `docker-compose.yml`

### Step 1: Load Docker Images
```bash
docker load -i advantal-server.tar
docker load -i advantal-web.tar
```

### Step 2: Start All Services
```bash
docker compose up -d
```

### Step 3: Verify All Containers Running
```bash
docker ps
```

### Access
- Web UI: `http://<server-ip>:9090`
- Login: `Admin` / `Test@nms`

---

## Useful Commands

```bash
# Check container status
docker compose ps

# Check logs
docker compose logs advantal-server
docker compose logs advantal-web
docker compose logs advantal-db

# Access database (psql)
docker exec -it advantal-db psql -U zabbix -d zabbix

# Restart all services
docker compose restart

# Stop all services (data preserved)
docker compose down

# Stop and DELETE all data
docker compose down -v

# Check agent status
docker compose logs advantal-agent
```

---

## Post-Deploy Setup (one-time, via Web UI)

1. Data collection → Hosts → rename "Zabbix server" → "Advantal server"
2. Data collection → Host groups → rename "Zabbix servers" → "Advantal servers"
3. Users → Admin → Name: "Advantal", Surname: "Administrator"
4. User settings → Change password to `Test@nms`

---

## Build from Source (for developers)

```bash
git clone https://github.com/DurgaThrinadh/Durga-advantal-nms
cd Durga-advantal-nms
git checkout feature/durga-advantal-nms-setup
docker compose up -d --build
```

---

## License

Based on Zabbix, distributed under [AGPL-3.0-only](COPYING)
