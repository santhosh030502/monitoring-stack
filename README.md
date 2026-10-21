# monitoring-stack

A ready-to-run monitoring setup with Prometheus, Grafana and Alertmanager,
started with one `docker compose up`. I built it to learn how these tools
connect, and I keep it as a base I can reuse when I need monitoring for a
new project.

## What's included

| Service           | What it does                                  | Port  |
|-------------------|-----------------------------------------------|-------|
| Prometheus        | collects and stores metrics, evaluates alerts | 9090  |
| Grafana           | dashboards                                    | 3001  |
| Alertmanager      | groups alerts and sends them to Slack         | 9093  |
| Node Exporter     | host metrics (CPU, memory, disk, network)     | -     |
| cAdvisor          | per-container metrics                         | -     |
| Blackbox Exporter | HTTP uptime checks, response time, SSL expiry | -     |

Only Prometheus, Grafana and Alertmanager are exposed on the host. Everything
else is reachable only inside the docker network.

```
 node-exporter ─┐
 cadvisor ──────┼──> Prometheus ──> Alertmanager ──> Slack
 blackbox ──────┘        │
                         └──> Grafana (dashboards)
```

## Quick start

```bash
git clone https://github.com/santhosh030502/monitoring-stack.git
cd monitoring-stack
make up
```

Then open:

- Grafana: http://localhost:3001 (login comes from `.env`, default `admin` / `changeme`)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093

The Prometheus datasource and the dashboards are provisioned automatically, so
there is nothing to click through in Grafana.

## Dashboards

**Node Overview**: uptime, CPU, memory, disk usage gauges, network traffic and disk I/O.

**Service Health**: targets up or down, firing alerts, endpoint status and
response time, SSL certificate days left, and per-container CPU and memory.

## Alerts

All rules are in `prometheus/rules/alerts.yml`:

| Alert                | When it fires                              | Severity |
|----------------------|--------------------------------------------|----------|
| InstanceDown         | a scrape target is down for 1m             | critical |
| HighCpuUsage         | CPU > 85% for 5m                           | warning  |
| HighMemoryUsage      | memory > 90% for 5m                        | warning  |
| DiskSpaceLow         | less than 15% disk free                    | warning  |
| DiskWillFillIn24h    | disk will fill up within 24h at the current rate | warning  |
| ContainerHighMemory  | container uses > 90% of its memory limit   | warning  |
| EndpointDown         | HTTP probe failing for 2m                  | critical |
| SlowEndpoint         | response time > 2s                         | warning  |
| SslCertExpiringSoon  | cert expires in less than 14 days          | warning  |

Alertmanager has an inhibit rule: when a critical alert fires for an instance,
its warning alerts are muted. One broken server sends one message, not five.

### Slack setup

```bash
echo "https://hooks.slack.com/services/your/real/url" > alertmanager/secrets/slack_webhook
make reload
```

This file is in `.gitignore`, so the webhook URL never ends up in the repo.

## Adding your own targets

**Monitor a website**: add the URL under `blackbox-http` in `prometheus/prometheus.yml`.

**Scrape an app running on your machine**: there is a commented `task-api` job
in `prometheus.yml`. It works with the app from my
[k8s-cicd-pipeline](https://github.com/santhosh030502/k8s-cicd-pipeline) repo,
which exposes `/metrics`. Uncomment it and run `make reload`.

## CI

`.github/workflows/validate.yml` runs on every push and PR:

1. checks the compose file, Prometheus config, alert rules, Alertmanager and Blackbox configs with the official tools (`promtool`, `amtool`)
2. checks the dashboard JSON files are valid
3. starts the whole stack in the runner and checks that every service responds

A broken alert rule fails CI before it gets merged.

## Useful commands

```bash
make ps       # status
make logs     # follow logs
make reload   # reload prometheus + alertmanager config, no restart
make down     # stop
make clean    # stop and delete all stored data
```

## Notes

- On macOS, node-exporter shows metrics for the Docker Desktop VM, not the Mac itself.
  It shows real host metrics on a Linux server.
- Prometheus keeps 15 days of data. To change it, edit `--storage.tsdb.retention.time` in `docker-compose.yml`.

## Next steps

- Loki + Promtail for logs
- Deploy the same stack to Kubernetes with kube-prometheus-stack
- Terraform to provision an EC2 instance and run this stack on it
