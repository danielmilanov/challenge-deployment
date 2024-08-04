## Monitoring
### Metrics
Metrics for the workload at the k8s resource / container level could be exposed by standard exporters like `kube-state-metrics`. Additionally metrics for endpoints probing may be exposed by `blackbox-exporter`.
Depending on scale, the metrics could be scraped, and stored by vanilla Prometheus installation, or VictoriaMetrics' vmagent, Prometheus installation with the Thanos sidecar (and other components), or any of the other solutions shipping metrics from Prometheus to object storage. 
In most cases, scraping may be configured declaratively with workload annotations or by using custom resources processed by an operator.
If the application is instrumented to serve metrics itself, they would be scraped too. 
Scraping workloads that request client certificates will require additional configuration with cert signed by appropriate CA.
Scraping workloads that are part of a service mesh will also most likely require additional configuration. 
Metrics storage solution would be exposed for running queries against the data, for example added as a data source in Grafana. 
### Alerts
Fundamental alerting that comes to mind includes:

 - watching for OOM events for catching memory leaks or wrong memory limits
  - watching for CPU throttling for adjusting CPU limits. Throttled workloads may be unable to even serve liveness probes by kubelet, and will get restarted. 
  - watching for workloads staying too long in Pending, which would indicate scheduling issues 
  - watching for CrashLoopBackOff 
  - watching for workload failing to start due to configuration errors, for example problematic ConfigMap or Secret references 
   - or just generic alerting for pods in NotReady, which could indicate different issues 
   - workload managed by HPA should be monitored for running at max replicas for too long

### Notifications
Standard monitoring stacks include a component responsible for evaluating alerting expressions, and forwarding firing alerts to AlertManager. 
AlertManager would include configuration for different receivers (mail, Slack, Pagerduty..)  based on priority or some other alerts labeling.  
A decent approach to prioritization is to have the phone ring for p1 alerts 24 hours, and for p2 alerts only during working hours.  Lower priority alerts may be routed to email. 
Sending notifications to IM solutions like Slack / RocketChat / Mattermost etc. is easily configured with webhooks. However the amount of noise produced should be carefully considered, otherwise alerts, and notifications will just be ignored.

### Logging
Workloads running in k8s should log stdout / stderr (as opposed to a log file), and ideally output structured logs with appropriate log level. If logs are not structured it may be required to configure log processing pipelines. Datadog for example will show everything as ERROR level if logs are not structured.
Logs for currently running containers, as well as the previously running container may be retrieved from k8s directly.  
Storing, and working with logs in the long term would require a log collection agent, usually running as a DaemonSet, which will collect, and ship logs to a storage system. Examples include datadog's datadog-agent, Grafana's promtail, filebeat for the ELK stack. 
Once persisted in a storage system (managed or self-hosted), logs may be queried, and inspected. Datadog comes with its own interface, Loki may be added as a data source in Grafana, and logs may be queried using LogQL, the ELK stack offers Kibana. 
Cloud providers may also collect logs, and expose them for inspection at a price. Bridging cloud provider logging with self-hosted solutions is also possible. For example Cloudwatch may be added as a data source in Grafana. 
