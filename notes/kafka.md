# Messaging: Kafka and Solace

## Kafka
- Topics, partitions, offsets; ordering is only guaranteed within a partition.
- Consumer groups and rebalancing; committing offsets.
- Replication factor, leader/follower, ISR, `min.insync.replicas`, `acks=all`.
- Delivery semantics: at-most-once, at-least-once, exactly-once (idempotent producer + transactions).
- Retention vs. compaction. Consumer lag as the key health metric.
- Running Kafka on Kubernetes (Strimzi) vs. on bare metal.

## Solace
- Hardware/software event broker common in banks; topics with wildcards, guaranteed vs. direct messaging, queues.

## In a derivatives context
- Market data and vol surface updates fanned out to pricers; risk results collected from a grid.
- What happens to pricers when the broker is slow or a partition leader moves?
