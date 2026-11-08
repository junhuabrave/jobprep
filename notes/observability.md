# Observability

## Prometheus / Grafana
- Pull model, exporters (node_exporter, kube-state-metrics, cAdvisor), service discovery.
- Metric types: counter, gauge, histogram, summary.
- PromQL: `rate()`, `sum by ()`, `histogram_quantile(0.99, ...)`, recording rules.
- Alertmanager: routing, grouping, inhibition, silences. Avoiding alert fatigue.
- Retention and scale: Thanos / Mimir / VictoriaMetrics for long-term and multi-cluster.
- Datadog: agent-based, how it compares.

## SLOs
- SLI vs. SLO vs. SLA, error budgets, burn-rate alerts.
- What would the SLOs be for a pricing service? (Latency of a reprice, staleness of vol surfaces, job completion for overnight risk.)

## Questions
- Pricing latency jumped at 09:30. Walk me through finding out why.
- How do you monitor 2,000 bare-metal hosts today, and what would you change for Kubernetes?
