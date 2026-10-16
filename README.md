# AWS Oracle DBA Automation and Monitoring

## Project Overview
This project demonstrates AWS infrastructure automation and Oracle database monitoring using Terraform, Python, Ansible, and Amazon CloudWatch.

## Technology Stack
- AWS EC2 and CloudWatch
- Terraform infrastructure as code
- Oracle Database 26ai Free
- Python and Boto3
- Linux and cron
- Ansible
- Git and GitHub

## Architecture
1. Terraform manages AWS infrastructure resources.
2. Oracle Database 26ai runs in the lab environment.
3. Python scripts collect server and database health metrics.
4. Cron schedules server monitoring every five minutes.
5. Boto3 publishes custom metrics to CloudWatch.
6. CloudWatch alarms monitor CPU, memory, and disk utilization.

## Server Monitoring
Monitoring script: `/opt/oracle-dba-monitoring/server_health.py`

Log file: `/var/log/oracle-dba-monitoring.log`

Schedule: every five minutes.

CloudWatch namespace: `OracleDBA/Lab`

Metrics include:
- CPUUsage — 80% threshold
- MemoryUsage — 80% threshold
- DiskUsage — 80% threshold
- SwapUsage — 50% threshold

## Oracle Database Monitoring
Custom metrics include:
- OracleDatabaseHealthy
- OracleTablespaceUsedPercent
- OracleBlockingSessions
- OracleDatafileIssues
- OracleInvalidObjects

Tablespace monitoring includes SYSTEM, SYSAUX, TEMP, USERS, and UNDOTBS1.

## CloudWatch Alarms
Three alarms monitor CPU, memory, and disk utilization for the Oracle 26ai lab instance. The CPU alarm requires two consecutive five-minute datapoints above 80% before entering ALARM state.

A controlled end-to-end alarm-trigger test remains outstanding.

## Validation
- Confirmed server monitoring script execution.
- Confirmed cron is active and configured for five-minute execution.
- Verified custom metrics in CloudWatch.
- Confirmed CPU, memory, and disk alarms target the Oracle 26ai instance.
- Verified alarms were in OK state during checks.

## Useful Commands

List project metrics:

```bash
aws cloudwatch list-metrics --namespace OracleDBA/Lab --region ca-central-1
