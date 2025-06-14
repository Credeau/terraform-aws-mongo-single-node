#!/usr/bin/env python3
"""
MongoDB Metrics Collection Script

This script fetches performance and operational metrics from a MongoDB instance and
pushes them to AWS CloudWatch for observability.

Why this shebang?
Using `#!/usr/bin/env python3` allows the system to resolve Python from the current PATH,
making it more portable across systems and virtual environments.

Maintainer:
    harshit.sharma@credeau.com

Tested on:
    Python 3.11
"""

import json
import logging
import argparse

import boto3

from pymongo import MongoClient
from sshtunnel import SSHTunnelForwarder


def parse_args():
    '''
    Parse required arguments from cli
    '''
    parser = argparse.ArgumentParser(description='MongoDB Metrics Collection Script')
    parser.add_argument('-r', '--remote', action='store_true',
                      help='Use remote MongoDB setup')
    parser.add_argument('-u', '--username',
                      help='MongoDB username')
    parser.add_argument('-P', '--password',
                      help='MongoDB password')
    parser.add_argument('--host', default='localhost',
                      help='MongoDB host (required when remote is True, default: localhost)')
    parser.add_argument('-p', '--port', type=int, default=27017,
                      help='MongoDB port (default: 27017)')
    parser.add_argument('--use-tunnel', action='store_true',
                      help='Enable SSH tunnel through bastion')
    parser.add_argument('-k', '--key',
                      help='Path to SSH key for bastion access')
    parser.add_argument('--bastion-host',
                      help='Bastion server hostname')
    parser.add_argument('--ssh-user',
                      help='SSH user for bastion server host')
    parser.add_argument('-i', '--identifier', default='localhost',
                      help='Application identifier to distinguish b/w metrics from multiple MongoDB setups')
    parser.add_argument('--dry-run', action='store_true',
                      help='Fetch metrics and print, skip sending to CloudWatch')

    args = parser.parse_args()

    # Validation
    if args.remote and not args.host:
        parser.error("--host is required when using --remote")
    if args.use_tunnel and (not args.key or not args.bastion_host):
        parser.error("--key and --bastion-host are required when using --use-tunnel")

    return args

def get_mongo_stats(args):
    '''
    Connect to MongoDB using provided config in args and fetch performance stats
    '''
    tunnel = None
    client = None

    try:
        if args.use_tunnel:
            # Create SSH tunnel
            tunnel = SSHTunnelForwarder(
                (args.bastion_host, 22),  # Bastion host and port
                ssh_username=args.ssh_user,
                ssh_pkey=args.key,
                remote_bind_address=(args.host, args.port),
                local_bind_address=('localhost', 27017)  # Local port forwarding
            )

            tunnel.start()

            connect_host = 'localhost'
            connect_port = tunnel.local_bind_port
        else:
            connect_host = args.host
            connect_port = args.port

        if args.username and args.password:
            _auth_prefix = f'{args.username}:{args.password}'
            uri = f"mongodb://{_auth_prefix}@{connect_host}:{connect_port}/?authSource=admin"
        else:
            uri = f"mongodb://{connect_host}:{connect_port}/"

        # Connect to MongoDB through the tunnel
        client = MongoClient(uri)
        db = client.admin
        server_status = db.command('serverStatus')

        return server_status

    except Exception:
        logging.error('unable to get mongo stats', exc_info=True)

    finally:
        if client:
            client.close()
        if tunnel:
            tunnel.stop()

def send_to_cloudwatch(namespace, metric_data):
    '''
    Send metrics data to a namespace in cloudwatch
    '''
    cloudwatch = boto3.client('cloudwatch', region_name='ap-south-1')
    cloudwatch.put_metric_data(Namespace=namespace, MetricData=metric_data)


if __name__ == '__main__':
    cli_args = parse_args()

    stats = get_mongo_stats(cli_args)

    # Customize your metrics here
    metrics = [
        # Application identifier
        # Why: To associate an unique application specific identifier with metrics,
        # so that they do not collide with similar metrics from other MongoDB hosts
        {
            'MetricName': 'ApplicationId',
            'Value': cli_args.identifier
        },

        # Current number of active client connections to MongoDB
        # Why: Spikes or plateaus in connections can indicate application pressure or leaks in connection handling.
        {
            'MetricName': 'Connections',
            'Value': stats['connections']['current'],
            'Unit': 'Count'
        },

        # Resident memory (RAM) being used by MongoDB, in MB
        # Why: Indicates memory pressure and helps detect memory leaks or insufficient RAM provisioning.
        {
            'MetricName': 'MemoryUsage',
            'Value': stats['mem']['resident'],
            'Unit': 'Megabytes'
        },

        # Number of insert operations since startup
        # Why: Shows write traffic patterns and helps track workload changes or ingestion spikes.
        {
            'MetricName': 'OpCounters_Insert',
            'Value': stats['opcounters']['insert'],
            'Unit': 'Count'
        },

        # Number of query (read) operations since startup
        # Why: Helps track read load; a key indicator of application usage and potential read bottlenecks.
        {
            'MetricName': 'OpCounters_Query',
            'Value': stats['opcounters']['query'],
            'Unit': 'Count'
        },

        # Number of update operations since startup
        # Why: Tracks mutation activity; useful for understanding how often records are changing.
        {
            'MetricName': 'OpCounters_Update',
            'Value': stats['opcounters']['update'],
            'Unit': 'Count'
        },

        # Number of delete operations since startup
        # Why: Helps catch unexpected deletions or heavy churn in your data model.
        {
            'MetricName': 'OpCounters_Delete',
            'Value': stats['opcounters']['delete'],
            'Unit': 'Count'
        },

        # Total number of operations queued for lock acquisition
        # Why: Indicates contention and lock saturation, a potential source of latency or bottlenecks.
        {
            'MetricName': 'CurrentQueuedOperations',
            'Value': stats['globalLock']['currentQueue']['total'],
            'Unit': 'Count'
        },

        # Number of currently active clients (any operations, not just queries)
        # Why: Tracks concurrent usage and can reflect scaling demands from the app side.
        {
            'MetricName': 'ActiveClients',
            'Value': stats['globalLock']['activeClients']['total'],
            'Unit': 'Count'
        },

        # Number of unused connections still available
        # Why: If this drops to 0, it may signal connection saturation and blocked requests.
        {
            'MetricName': 'ConnectionsAvailable',
            'Value': stats['connections']['available'],
            'Unit': 'Count'
        },

        # Total page faults since startup
        # Why: Frequent page faults indicate MongoDB is reading from disk instead of memory, suggesting insufficient RAM or poor cache usage.
        {
            'MetricName': 'PageFaults',
            'Value': stats['extra_info']['page_faults'],
            'Unit': 'Count/Second'
        },

        # Percent of WiredTiger cache in use
        # Why: High cache usage (>90%) can cause evictions and performance degradation. Critical for capacity planning.
        {
            'MetricName': 'CacheUsagePercent',
            'Value': stats['wiredTiger']['cache']['maximum bytes configured'] > 0 
                    and (stats['wiredTiger']['cache']['bytes currently in the cache'] * 100 / 
                         stats['wiredTiger']['cache']['maximum bytes configured']) or 0,
            'Unit': 'Percent'
        },

        # Server uptime in seconds
        # Why: Useful to detect restarts, crashes, or maintenance downtime.
        {
            'MetricName': 'Uptime',
            'Value': stats['uptime'],
            'Unit': 'Seconds'
        },

        # Number of warnings issued by MongoDB
        # Why: Can point to unexpected conditions or deprecated behaviors needing attention.
        {
            'MetricName': 'Assertions_Warning',
            'Value': stats['asserts']['warning'],
            'Unit': 'Count'
        },

        # Number of errors asserted by the MongoDB server
        # Why: High error counts indicate internal issues and are crucial for debugging problems.
        {
            'MetricName': 'Assertions_Errors',
            'Value': stats['asserts']['msg'],
            'Unit': 'Count'
        },

        # Total number of bytes sent by the server
        # Why: Helps monitor outgoing network traffic; can indicate large result sets or bulk responses.
        {
            'MetricName': 'NetworkBytesOut',
            'Value': stats['network']['bytesOut'],
            'Unit': 'Bytes'
        },

        # Total number of bytes received by the server
        # Why: Helps monitor incoming network traffic; useful for detecting large writes or sync operations.
        {
            'MetricName': 'NetworkBytesIn',
            'Value': stats['network']['bytesIn'],
            'Unit': 'Bytes'
        }
    ]

    if cli_args.dry_run:
        print(json.dumps(metrics, indent=4))
    else:
        send_to_cloudwatch('MongoDBMetrics', metrics)
