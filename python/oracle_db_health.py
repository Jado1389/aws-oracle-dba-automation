#!/usr/bin/env python3
"""Read-only Oracle health checks and CloudWatch metric publishing."""

import json
import os
import subprocess
import urllib.request

REGION = "ca-central-1"
NAMESPACE = "OracleDBA/Lab"

SQL = r"""
SET HEADING OFF FEEDBACK OFF PAGESIZE 0 VERIFY OFF ECHO OFF
SET TRIMSPOOL ON LINESIZE 200
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';

SELECT 'DB|' || open_mode || '|' || database_role FROM v$database;
SELECT 'DATAFILE_ISSUES|' || COUNT(*) FROM dba_data_files
 WHERE status <> 'AVAILABLE';
SELECT 'INVALID_OBJECTS|' || COUNT(*) FROM dba_objects
 WHERE status = 'INVALID';
SELECT 'BLOCKING_SESSIONS|' || COUNT(*) FROM v$session
 WHERE blocking_session IS NOT NULL;
SELECT 'TABLESPACE|' || tablespace_name || '|' ||
       TO_CHAR(used_percent, 'FM999990D00')
FROM dba_tablespace_usage_metrics;
EXIT
"""


def get_instance_id():
    request = urllib.request.Request(
        "http://169.254.169.254/latest/api/token",
        method="PUT",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
    )
    with urllib.request.urlopen(request, timeout=3) as response:
        token = response.read().decode()

    request = urllib.request.Request(
        "http://169.254.169.254/latest/meta-data/instance-id",
        headers={"X-aws-ec2-metadata-token": token},
    )
    with urllib.request.urlopen(request, timeout=3) as response:
        return response.read().decode()


def main():
    result = subprocess.run(
        ["docker", "exec", "-i", "oracle-free",
         "bash", "-lc", "sqlplus -s / as sysdba"],
        input=SQL,
        capture_output=True,
        text=True,
        timeout=60,
    )
    if result.returncode != 0 or "ORA-" in result.stdout or "SP2-" in result.stdout:
        raise RuntimeError(f"Oracle SQL check failed: {result.stderr}\n{result.stdout}")

    metrics = []
    database_ok = False
    tablespaces = []

    for line in result.stdout.splitlines():
        fields = [field.strip() for field in line.strip().split("|")]
        if fields[0] == "DB" and len(fields) == 3:
            database_ok = fields[1] == "READ WRITE" and fields[2] == "PRIMARY"
        elif fields[0] in {
            "DATAFILE_ISSUES", "INVALID_OBJECTS", "BLOCKING_SESSIONS"
        } and len(fields) == 2:
            metrics.append({
                "MetricName": {
                    "DATAFILE_ISSUES": "OracleDatafileIssues",
                    "INVALID_OBJECTS": "OracleInvalidObjects",
                    "BLOCKING_SESSIONS": "OracleBlockingSessions",
                }[fields[0]],
                "Value": float(fields[1]),
                "Unit": "Count",
            })
        elif fields[0] == "TABLESPACE" and len(fields) == 3:
            value = float(fields[2])
            tablespaces.append((fields[1], value))

    if not any(metric["MetricName"] == "OracleDatafileIssues" for metric in metrics):
        raise RuntimeError(f"Expected Oracle metrics missing from SQL output:\n{result.stdout}")

    metrics.append({
        "MetricName": "OracleDatabaseHealthy",
        "Value": 1.0 if database_ok else 0.0,
        "Unit": "Count",
    })

    for name, value in tablespaces:
        metrics.append({
            "MetricName": "OracleTablespaceUsedPercent",
            "Dimensions": [{"Name": "Tablespace", "Value": name}],
            "Value": value,
            "Unit": "Percent",
        })

    instance_id = get_instance_id()
    for metric in metrics:
        metric["Dimensions"] = metric.get("Dimensions", []) + [
            {"Name": "InstanceId", "Value": instance_id}
        ]

    payload = json.dumps(metrics)
    subprocess.run(
        ["aws", "cloudwatch", "put-metric-data",
         "--region", REGION, "--namespace", NAMESPACE,
         "--metric-data", payload],
        check=True,
        capture_output=True,
        text=True,
        timeout=30,
    )

    print(json.dumps({
        "instance_id": instance_id,
        "database_healthy": database_ok,
        "metrics_published": len(metrics),
        "tablespaces_checked": len(tablespaces),
        "oracle_check": "SUCCESS",
        "cloudwatch_publish": "SUCCESS",
    }, indent=2))


if __name__ == "__main__":
    main()
