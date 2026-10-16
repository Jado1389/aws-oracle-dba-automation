# AWS Oracle DBA Automation

## Overview
A hands-on database administration project demonstrating AWS infrastructure automation, Oracle database health monitoring, CloudWatch metrics and alarms, and SNS email notifications.

## Architecture
- **AWS:** Amazon EC2 lab environment in ca-central-1.
- **Database:** Oracle 26ai lab running in the `oracle-free` container.
- **Terraform:** Infrastructure-as-code for AWS networking and CloudWatch alarm configuration.
- **Python:** Server and Oracle database health-monitoring automation.
- **Amazon CloudWatch:** Centralized custom metrics and threshold-based alarms.
- **Amazon SNS:** Email notifications for monitoring alerts.

## Monitoring
The monitoring solution publishes custom metrics under the `OracleDBA/Lab` namespace.

### Server metrics
- CPU utilization
- Memory utilization
- Disk utilization
- Swap utilization

### Oracle database checks
- Database health
- Tablespace utilization
- Blocking sessions
- Datafile issues
- Invalid database objects

## CloudWatch alarms
Three alarms are configured with an 80% threshold:

| Alarm | Metric | Threshold |
|---|---|---:|
| `oracle-dba-high-cpu` | CPUUsage | 80% |
| `oracle-dba-high-memory` | MemoryUsage | 80% |
| `oracle-dba-high-disk` | DiskUsage | 80% |

Each alarm evaluates two consecutive five-minute periods and requires both datapoints to breach the threshold before entering ALARM.

## Email notifications
Amazon SNS topic: `oracle-26ai-alerts`

The email subscription was confirmed, and a test message was successfully published through SNS and received by the subscriber. All three CloudWatch alarms have the SNS topic configured as an alarm action.

## Validation
- Verified CloudWatch metrics were being published.
- Confirmed all three alarms were in the `OK` state during verification.
- Verified alarm thresholds and SNS alarm actions.
- Confirmed SNS email delivery with a test notification.

Note: The SNS test validates email delivery. It does not independently prove that a real threshold breach triggered an alarm email.

## Business value
- Improves visibility into database-server resource utilization.
- Helps DBAs identify capacity and availability concerns earlier.
- Reduces repetitive manual health-checking tasks.
- Supports repeatable infrastructure configuration through Terraform.
- Improves operational awareness through automated email alerts.

## Security
- Do not commit AWS credentials, private keys, passwords, Terraform state files, or sensitive configuration.
- Restrict network access using appropriate security groups and least-privilege IAM permissions.
- Store secrets in an appropriate secrets-management service.

## Repository contents
The repository contains Terraform configuration and database administration monitoring scripts. Review the project directories for implementation details.

## Architecture Diagram

```mermaid
flowchart TD
    A["Terraform"] --> B["AWS Infrastructure"]
    B --> C["Oracle Database 26ai"]
    C --> D["Python Monitoring"]
    D --> E["Amazon CloudWatch"]
    E --> F{"Threshold Breached?"}
    F -->|Yes| G["CloudWatch Alarm"]
    G --> H["Amazon SNS"]
    H --> I["Email Notification"]
    F -->|No| D
