## Quickstart

- Buy a domain
- brew install tfenv
- tfenv install 1.1.9
- <INSTRUCTIONS FOR GENERATING IAM KEYS>
- create terraform variable files
    - cp terraform/example_tfvars/config.auto.tfvars.json terraform/config.auto.tfvars.json
    - cp terraform/example_tfvars/example-secrets.auto.tfvar.json terraform/secrets.auto.tfvars.json
    - Fill in secrets
      - CIDR BLOCKS
      - root domain name 
      - 

ASSUME AWS ROLE locally

- `tfenv use 1.1.9`
- `export AWS_PROFILE={INSERT AWS_PROFILE_NAME HERE}`
- `export AWS_ACCOUNT_ID={INSERT ACCOUNT ID HERE}`
- `export AWS_PROFILE={INSERT PROFILE HERE}`
- `make tf-first-run AWS_ACCOUNT_ID=$ACCOUNT_ID AWS=$AWS_REGION`
- Point domain at your nameservers that were just created - this is external to AWS
- WAIT FOR DNS PROPAGATION
- `make tf-plan`
- `make tf-apply`

- Prep work to make RDS work with the nanomdm containers
- Within RDS --> create the initial database, we used a default database called: `nanomdm`
  - `mysql -h ${RDS_HOST} -P 3306 -u ${USER_NAME} -p`
  - `CREATE database nanomdm;`
- You can use the provided EC2 instance or some other way to upload the base SQL schema to the newly created RDS or your own RDS instance
  - https://github.com/micromdm/nanomdm/blob/main/storage/mysql/schema.sql
  - `mysql -h ${RDS_HOST} -P 3306 -u ${USER_NAME} -p nanomdm < schema.sql`

### Destroying Terraform Infra

> :warning: **You may have to manually delete some components of an RDS after running `terraform destroy`. See this [github issue](https://github.com/hashicorp/terraform-provider-aws/issues/4597#issuecomment-912910432) for more info.

## Containers

### Build from m1
You must enable these experimental docker features in your docker_config if building from m1 mac.

```json
{
"experimental": true,
  "features": {
    "buildkit": true
  }
}
```

## Run Salt

## Linux 

### Sync files

```
rsync -e "ssh -i ~/.ssh/do" -r ~/nanomdmsandbox/salt/* root@SERVER_IP:/srv
```

```shell
sudo salt-call --local state.apply
```

## macOS

From root of this project:

```shell
sudo salt-call --local state.apply --file-root salt/salt --pillar-root salt/pillar --log-level info -c ${PWD}/salt
```

# Micromdm architecture

- micromdm binary. Provides TLS + SCEP + mdm server API.
    - when devices check-in or have some other event, micromdm sends these events to it's own webhook.
    - Some other service (such as mdmdirector) can listen to the webhook and take actions based on the events.

# Nano Architecture

- nanomdm binary. Provides only an mdm server API.
    - when devices check-in or have some other event, nanomdm sends these events to its own webhook.
    - some other service can listen to the webhook and take actions based on the events.
- You need to bring your own TLS via reverse proxy/load balancer
