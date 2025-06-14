# Mongo Python Scripts

## :mag: :chart_with_upwards_trend: Fetch server metrics & push to CloudWatch namespace

This script connects to a MongoDB host using various options, and fetch server metrics essential to observe a production grade setup.

These fetched metrics are pushed to CloudWatch under `MongoDBMetrics` namespace and individual setups are identified by metric named `ApplicationId`.

*This script is also used in the terraform module to run on periodic basis and export metrics. Referenced files -*

1. `mongo-single-node/iac/terraform/aws/locals.tf:19`
2. `mongo-single-node/iac/terraform/aws/ec2.tf:15`
3. `mongo-single-node/iac/terraform/aws/files/userdata.sh.tftpl:82`
4. `mongo-single-node/iac/terraform/aws/files/userdata.sh.tftpl:91`

### Prepare a Python3 environment

```bash
conda create --name mongo-metrics python=3.11

conda activate mongo-metrics

python -m pip install -r metrics.requirements.txt
```

### Run the script

```bash
python metrics.py [Options]
```

Script Options -

1. `-r`, `--remote` - Use remote MongoDB setup
2. `-u USERNAME`, `--username USERNAME` - MongoDB username
3. `-P PASSWORD`, `--password PASSWORD` - MongoDB password
4. `--host HOST` - MongoDB host (required when remote is True, default: localhost)
5. `-p PORT`, `--port PORT` - MongoDB port (default: 27017)
6. `--use-tunnel` - Enable SSH tunnel through bastion
7. `-k KEY`, `--key KEY` - Path to SSH key for bastion access
8. `--bastion-host BASTION_HOST` - Bastion server hostname
9. `--ssh-user SSH_USER` - SSH user for bastion server host
10. `-i IDENTIFIER`, `--identifier IDENTIFIER` - Application identifier to distinguish b/w metrics from multiple MongoDB setups
11. `--dry-run` - Fetch metrics and print, skip sending to CloudWatch

> Tip: Use `-h` / `--help` to see all options in cli console

### Examples

Fetch metrics from a local MongoDB, without authentication -

```bash
python metrics.py -i <APPLICATION_NAME>
```

Fetch metrics from a local MongoDB, with authentication -

```bash
python metrics.py -u <MONGO_DB_USERNAME> -P <MONGO_DB_PASSWORD> -i <APPLICATION_NAME>
```

Fetch metrics from a remote MongoDB, hosted in a public network accessible over internet -

```bash
python metrics.py -r \
    -u <MONGO_DB_USERNAME> \
    -P <MONGO_DB_PASSWORD> \
    --host <MONGO_DB_HOST> \
    -i <APPLICATION_NAME>
```

Fetch metrics from a remote MongoDB, hosted in a private network accessible via SSH tunneling using bastion host -

```bash
python metrics.py -r --use-tunnel \
    -u <MONGO_DB_USERNAME> \
    -P <MONGO_DB_PASSWORD> \
    --host <MONGO_DB_HOST> \
    -k "$HOME/.ssh/<SSH_KEY_PAIR_NAME>" \
    --bastion-host <BASTION_HOST_ADDRESS> \
    --ssh-user <BASTION_HOST_SSH_USER> \
    -i <APPLICATION_NAME>
```

> Tip: While testing, always use `--dry-run` to ensure correct metrics are being produced before actually sending them to CloudWatch
