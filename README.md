# Nanomdmsandbox

Nanomdmsandbox is a project that tries to make it easier (for some definition of easy) to spin up a development/testing environment for https://github.com/micromdm/nanomdm. It definitely approaches something that could be production ready, but might require tweaks for your environment. 

## Prerequisites

1. Buy a domain. There are many registrars you can choose from but we are partial to namecheap.com.
1. Create an AWS account.
1. Generate IAM credentials with access to manage ECS, RDS, and the other services in this project. 

    > :warning: You can alternatively give the IAM credentials `AdministratorAccess` but this is not recommended.

### Generate APNS Certificate

1. Generate an APNS Certificate. Checkout https://github.com/micromdm/micromdm/blob/main/docs/user-guide/quickstart.md#configure-an-apns-certificate and https://micromdm.io/blog/certificates/ for info about this step.

## Getting started

1. `brew install tfenv`
1. Generate SCEP default CA files which outputs to a `depot` folder. This is required for the SCEP and NanoMDM containers
    ```bash
    sh scripts/depot.sh
    ```
1. Install Terraform 1.1.9 

    `tfenv install 1.1.9`

1. Create terraform variable files
    ```
    cp terraform/example_tfvars/config.auto.tfvars.json terraform/config.auto.tfvars.json
    cp terraform/example_tfvars/example-secrets.auto.tfvar.json terraform/secrets.auto.tfvars.json
    cp terraform/example_tfvars/_backend.tf terraform/backend.tf
    ```
1. Fill in the secrets:
    1. `public_inbound_cidr_blocks_ipv4`
    1. `domain_name`, which should be `acme.co` (replace with your real domain name). Later, when you do `make tf-apply` a `mdm-infra` subdomain will be created: `mdm-infra.acme.co`.
    1. `public_key` <-- used for sshing to the ec2 instance which is pre-configured with access to the mysql rds instance where you need to later upload the mysql schema.
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

1. Create the TF remote state. You don't have to use S3 backend and can use whatever you want but this project recommends an S3 bucket for ease of collaboration while working on Terraform.
    ```bash
    make tf-remote-state-init
    ```
1. Copy outputted `bucket_name` to the corresponding filed in `terraform/backend.tf`.

1. Copy your `mdm_push_cert.pem` into place. See [Generate APNS Certificate](#generate-apns-certificate) for more info.

```shell
cp /path/to/mdm_push_cert.pem docker/config/certs/mdm_push_cert.pem
```

1. Now the "first run" stuff can be launched. Among other things, this creates proper Route53 NS associations that can be used to manage all sub-domain or root domain operations for any of the required Route53 records within the module. 
    ```bash
    make tf-first-run
    ```
1. Make note of the nameservers that were just created. Navigate to https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones# and then click on your domain name.
1. Point domain at these nameservers that you just noted. This process is external to AWS and will be specific to your registrar.
1. **WAIT FOR DNS PROPAGATION**. This will take a while... go grab yourself a nice dinner.
1. Confirm that the DNS has propagated by digging against various DNS providers like Google and CloudFlare. 

```shell
dig @8.8.8.8 +short NS INSERT_YOUR_DOMAIN_HERE
dig @1.1.1.1 +short NS INSERT_YOUR_DOMAIN_HERE
```

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

1. Optional: ssh to the provided ec2 box

    ```bash
    ssh -i ~/.ssh/ec2.pub ec2-user@THE.IP
    ```

1. Obtain the schema file.

    ```bash
    curl https://raw.githubusercontent.com/micromdm/nanomdm/main/storage/mysql/schema.sql -o schema.sql
    ```

1. Run the schema file.

    ```bash
    mysql -h ${RDS_HOST} -P 3306 -u ${USER_NAME} -p nanomdm < schema.sql
    ```

1. Force the ECS service to re-deploy:
      
      ```
      make ecs-update-service CLUSTER=production-nanomdm-cluster SERVICE=nanomdm
      ```
    Adjust `CLUSTER` and `SERVICE` to match what you specified in Terraform app_variables

### Upload APNS Certificate

```bash
cat /path/to/mdm_push_cert.pem /path/to/mdmcert.download.push.key | curl -T - -u nanomdm:nanomdm 'https://mdm-infra.acme.co/v1/pushcert'
```

### Send a push notification

### Set a wallpaper

```bash
python3 ~/nanomdm/tools/cmdr.py InstallProfile config_profiles/desktop-setting.mobileconfig | curl -T - -u nanomdm:nanomdm 'https://mdm-infra.acme.co/v1/enqueue/UUID_GOES_HERE'
```

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
