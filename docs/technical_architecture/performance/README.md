# Performance and Scalability Architecture

> **Status:** Active — TA-14 Architecture Complete  
> **Authority:** Numeric runtime budgets, platform headroom, load-shedding and scalability constraints

This directory owns the cross-cutting performance and scalability contracts introduced by TA-14.

Primary contract:

- [14_performance_network_memory_persistence_and_scalability_budgets.md](14_performance_network_memory_persistence_and_scalability_budgets.md)

TA-14 does not authorize gameplay implementation. Numeric implementation constants, instrumentation modules and executable regression harnesses remain downstream to TA-15/TA-17, but they must preserve the budgets and guardrails locked here.
