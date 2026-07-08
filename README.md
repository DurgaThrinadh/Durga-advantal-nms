# Advantal NMS

![Advantal logo](ui/logo.png)

An enterprise-class, open-source distributed network monitoring solution by **Advantal Technologies Pvt Ltd**, designed to monitor the performance and availability of network devices, servers, services, and other IT resources.

Advantal NMS is a flexible solution that can monitor anything from a simple, standalone application to a large-scale environment, with features including:

- **Resource discovery:** Discover network entities, server resources, and onboard/offboard devices. Use out-of-the-box integrations (templates) to monitor anything from a low-level device to a SAAS service.
- **Metric acquisition:** Use an agent or agent-less approach for metric acquisition from any source – devices, sensors, operating systems, virtualization platforms, container platforms like Docker, Kubernetes, cloud infrastructures, databases, webpages, Java ecosystems, application servers, API endpoints, business applications, and many more.
- **Root cause analysis and problem detection:** Count on high-performance, real-time problem detection that correlates both existing and incoming problems and performs root cause analyses.
- **Incidents, alerts, and notifications:** Receive an alert when an issue is triggered (proactively or post-mortem) in the ecosystem. Use multiple messaging channels (including Slack, JIRA, Microsoft Teams, email or text messages) to get notified about the different types of events occurring in your environment.
- **"Single pane of glass" overview:** Visualize collected data and monitoring events in graphs, lists, geomaps, and network topology maps.
- **Multitenancy and distributed monitoring:** Enjoy the convenience of one monitoring solution for multiple data centers, departments, and organizations, and monitor remote locations behind firewalls with remote command execution capability.
- **Unparalleled flexibility:** Adapt Advantal NMS to your needs and utilize built-in functionalities, including the ability to stream metrics and events over HTTP, reporting, auditing, security, service SLA calculations, and many more.

## Deployment

```bash
git clone https://github.com/DurgaThrinadh/Durga-advantal-nms
cd Durga-advantal-nms
git checkout feature/durga-advantal-nms-setup
docker compose up -d --build
```

Access: `http://<server-ip>:9090` (Login: Admin / zabbix)

## Architecture

| Container | Role | Port |
|-----------|------|------|
| advantal-db | PostgreSQL database | Internal |
| advantal-server | NMS backend (compiled from source) | 10051 |
| advantal-web | Web frontend (PHP/Nginx) | 9090 |
| advantal-agent | Monitoring agent | Internal |
| advantal-snmptraps | SNMP trap receiver | 162/UDP |

## License

Based on Zabbix, distributed under [AGPL-3.0-only](COPYING)
