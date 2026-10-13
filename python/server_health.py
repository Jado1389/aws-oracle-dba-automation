#!/usr/bin/env python3

import json
import shutil
import subprocess
import urllib.request

import boto3


CPU_THRESHOLD = 80
MEMORY_THRESHOLD = 80
DISK_THRESHOLD = 80
SWAP_THRESHOLD = 50

CLOUDWATCH_NAMESPACE = "OracleDBA/Lab"
AWS_REGION = "ca-central-1"


def get_instance_id():
    """Retrieve the EC2 instance ID using IMDSv2."""
    token_request = urllib.request.Request(
        "http://169.254.169.254/latest/api/token",
        method="PUT",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
    )

    with urllib.request.urlopen(token_request, timeout=3) as response:
        token = response.read().decode("utf-8")

    instance_request = urllib.request.Request(
        "http://169.254.169.254/latest/meta-data/instance-id",
        headers={"X-aws-ec2-metadata-token": token},
    )

    with urllib.request.urlopen(instance_request, timeout=3) as response:
        return response.read().decode("utf-8")


def get_cpu_usage():
    result = subprocess.run(
        ["top", "-bn1"],
        capture_output=True,
        text=True,
        check=True,
    )

    for line in result.stdout.splitlines():
        if "Cpu(s)" in line:
            for part in line.split(","):
                if "id" in part:
                    idle = float(part.strip().split()[0])
                    return round(100 - idle, 2)

    return None


def get_memory_usage():
    result = subprocess.run(
        ["free", "-m"],
        capture_output=True,
        text=True,
        check=True,
    )

    for line in result.stdout.splitlines():
        if line.startswith("Mem:"):
            values = line.split()
            total = int(values[1])
            used = int(values[2])
            if total == 0:
                return None
            return round((used / total) * 100, 2)

    return None


def get_disk_usage():
    total, used, free = shutil.disk_usage("/")
    if total == 0:
        return None
    return round((used / total) * 100, 2)


def get_swap_usage():
    result = subprocess.run(
        ["free", "-m"],
        capture_output=True,
        text=True,
        check=True,
    )

    for line in result.stdout.splitlines():
        if line.startswith("Swap:"):
            values = line.split()
            total = int(values[1])
            used = int(values[2])

            if total == 0:
                return 0.0

            return round((used / total) * 100, 2)

    return None


def get_status(value, threshold):
    if value is None:
        return "UNKNOWN"

    if value > threshold:
        return "WARNING"

    return "OK"


def publish_metrics(health_data, instance_id):
    """Publish available health metrics to Amazon CloudWatch."""
    cloudwatch = boto3.client("cloudwatch", region_name=AWS_REGION)

    metric_names = {
        "cpu_usage": "CPUUsage",
        "memory_usage": "MemoryUsage",
        "disk_usage": "DiskUsage",
        "swap_usage": "SwapUsage",
    }

    metric_data = []

    for key, metric_name in metric_names.items():
        value = health_data[key]

        if value is not None:
            metric_data.append(
                {
                    "MetricName": metric_name,
                    "Dimensions": [
                        {
                            "Name": "InstanceId",
                            "Value": instance_id,
                        }
                    ],
                    "Value": value,
                    "Unit": "Percent",
                }
            )

    if metric_data:
        cloudwatch.put_metric_data(
            Namespace=CLOUDWATCH_NAMESPACE,
            MetricData=metric_data,
        )


def main():
    cpu = get_cpu_usage()
    memory = get_memory_usage()
    disk = get_disk_usage()
    swap = get_swap_usage()

    cpu_status = get_status(cpu, CPU_THRESHOLD)
    memory_status = get_status(memory, MEMORY_THRESHOLD)
    disk_status = get_status(disk, DISK_THRESHOLD)
    swap_status = get_status(swap, SWAP_THRESHOLD)

    statuses = [
        cpu_status,
        memory_status,
        disk_status,
        swap_status,
    ]

    overall_status = (
        "WARNING" if "WARNING" in statuses else
        "UNKNOWN" if "UNKNOWN" in statuses else
        "HEALTHY"
    )

    health_data = {
        "cpu_usage": cpu,
        "cpu_status": cpu_status,
        "memory_usage": memory,
        "memory_status": memory_status,
        "disk_usage": disk,
        "disk_status": disk_status,
        "swap_usage": swap,
        "swap_status": swap_status,
        "overall_status": overall_status,
    }

    try:
        instance_id = get_instance_id()
        publish_metrics(health_data, instance_id)
        health_data["cloudwatch_status"] = "PUBLISHED"
    except Exception as error:
        health_data["cloudwatch_status"] = "FAILED"
        health_data["cloudwatch_error"] = str(error)

    print(json.dumps(health_data, indent=2))


if __name__ == "__main__":
    main()
