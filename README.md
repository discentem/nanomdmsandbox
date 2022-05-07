## Quickstart

- Buy a domain
- brew install tfenv
- tfenv install 1.1.9
- <INSTRUCTIONS FOR GENERATING IAM KEYS>
- create terraform variable files
    - cp terraform/example_tfvars/config.auto.tfvars.json terraform/config.auto.tfvars.json
    - cp terraform/example_tfvars/example-secrets.auto.tfvar.json terraform/secrets.auto.tfvars.json
    - Fill in secrets

ASSUME AWS ROLE locally

- tfenv use 1.1.9
- make tf-first-run AWS_ACCOUNT_ID=$ACCOUNT_ID AWS=$AWS_REGION
- Point domain at your nameservers that were just created
- WAIT FOR DNS PROPAGATION
- make tf-plan
- make tf-apply

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
