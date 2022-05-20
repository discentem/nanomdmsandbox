# Nanomdmsandbox

## Prereqs

1. Buy a domain. There are registars you can choose from but we are partial to namecheap.com.
1. Create an AWS account.
1. Generate IAM credentials with access to manage ECS, RDS, and the other services in this project. 

    > :warning: You can alternatively give the IAM credentials `AdministratorAccess` but this is not recommended.

1. Generate an APNS Certificate. Checkout https://github.com/micromdm/micromdm/blob/main/docs/user-guide/quickstart.md#configure-an-apns-certificate and https://micromdm.io/blog/certificates/ for info about this step.

## Getting started

1. `brew install tfenv`
1. Generate SCEP default CA files which outputs to a `depot` folder. This is required for the SCEP and NanoMDM containers
    ```bash
    https://github.com/micromdm/scep/releases/download/v2.1.0/scepserver-darwin-amd64-v2.1.0.zip`
    ./scepserver-darwin-amd64 ca -init
    ```
1. Save this `depot` folder within `app/config/certs/depot`
1. Install Terraform 1.1.9 

    `tfenv install 1.1.9`

1. Create terraform variable files
    1. cp terraform/example_tfvars/config.auto.tfvars.json terraform/config.auto.tfvars.json
    1. cp terraform/example_tfvars/example-secrets.auto.tfvar.json terraform/secrets.auto.tfvars.json
      1. Fill in secrets
      1. ipv4 CIDR BLOCKS
      1. root domain name 

1. Activate Terraform 1.1.9 within tfenv
    ```bash
    tfenv use 1.1.9
    ```
1. Configure AWS cli with the previously created IAM credentials.
1. Export all the vars!

    ```bash
    export AWS_PROFILE={INSERT AWS_PROFILE_NAME HERE}
    export AWS_ACCOUNT_ID={INSERT ACCOUNT ID HERE}
    ```

    Okay finally! Time to run Terraform...

1. Do the "first run". Among other things, this creates nameservers. 

    ```bash
    make tf-first-run AWS_ACCOUNT_ID=$ACCOUNT_ID AWS=$AWS_REGION
    ```
1. Point domain at your nameservers that were just created - this is external to AWS and will be specific to your registrar.
1. WAIT FOR DNS PROPAGATION. This will take a while... go grab yourself a nice dinner.
1. Run the plan
    ```
    make tf-plan
    ```
1. If the plan looks good... 
    
    ```
    make tf-apply
    ```

### Prepare the Mysql Database 

> :warning: This needs to be done before nanomdm will function properly.

1. Run the schema file. You can use the provided EC2 instance or any other way to upload the base SQL schema to the newly created RDS or your own RDS instance. You can grab the schema file at https://github.com/micromdm/nanomdm/blob/main/storage/mysql/schema.sql

    ```bash
    mysql -h ${RDS_HOST} -P 3306 -u ${USER_NAME} -p nanomdm < schema.sql
    ```

1. Force the ECS service to re-deploy:
      
      ```
      make ecs-update-service CLUSTER=production-nanomdm-cluster SERVICE=production
      ```
    - Adjust `CLUSTER` and `SERVICE` to match what you specified in Terraform app_variables

### Upload APNS Certificate

FILL IN DETAILS!

## Adding new containers

If you want to add additional services to the cluster, take a look at:

Example PR: https://github.com/discentem/nanomdmsandbox/pull/14

## Destroying Terraform Infra

```bash
make tf-destroy
```

> :warning: You may have to manually delete some components of an RDS after running `terraform destroy`. See this [github issue](https://github.com/hashicorp/terraform-provider-aws/issues/4597#issuecomment-912910432) for more info.

## Docker tips

### Mac m1 hardware
You must enable these experimental docker features in your docker_config if building from m1 mac.

```json
{
  "experimental": true,
  "features": {
    "buildkit": true
  }
}
```

## Salt

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
