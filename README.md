## Quickstart

- Buy a domain

### Generating an APNS Certificate
- > :Disclaimer: ** While the mdmcert.download is a great site that we have used for and highly recommended for development and testing purposes, this solution should NOT be used for production usage. You should apply directly to Apple to retrieve an APNS certificate for your corporate entity. Apple requires that you have an Enterprise Developer Account to generate this type of certificate. **
- mdmcert.download generation instructions:
  1. https://mdmcert.download/registration --> This must also be registered under a business domain account.
  2. Download and build `mdmctl` from `github.com/micromdm/micromdm`
    - You will only need to generate the `mdmctl` via `make mdmctl`
  3. Generate the vendor certificate that will be uploaded to `mdmcert.download`
    - `mdmctl mdmcert.download -new -email=cool.mdm.admin@example.org`
    - The following files should have been generated and an email with your encrypted CSR will be attached.
      - `mdmcert.download.pki.{crt|key}` --> These are generated for handling the decryption fo mdmcert.download
      - `mdmcert.download.push.{csr|key}` --> These are for the Apple Identity Portal
  4. Decrypt the downloaded CSR from the email into the `mdmcert.download.key`
    - `mdmctl mdmcert.download -decrypt=~/Downloads/mdm_signed_request.20171122_094910_220.plist.b64.p7`
  5. Upload the decrypted CSR push certificate `mdmcert.download.push.req` request to Apple
    - `https://identity.apple.com`
  6. Upload to the nanomdm instance once the infrastructure is build:
    - `cat ./push_certificate.pem ./mdmcert.download.push.key | curl -T - -u ${USERNAME}:${PASSWORD} 'https://mdm.us-east-1.example.com/v1/pushcert'`
    - The default nanomdm container username/password combination is: nanomdm:nanomdm


####


- `brew install tfenv`
- Generate SCEP default CA files which outputs to a `depot` folder. This is required for the SCEP and NanoMDM containers
  - `https://github.com/micromdm/scep/releases/download/v2.1.0/scepserver-darwin-amd64-v2.1.0.zip`
  - `./scepserver-darwin-amd64 ca -init`
  - Save this `depot` folder within `app/config/certs/depot`
- `tfenv install 1.1.9`
- <INSTRUCTIONS FOR GENERATING IAM KEYS>
- create terraform variable files
    - cp terraform/example_tfvars/config.auto.tfvars.json terraform/config.auto.tfvars.json
    - cp terraform/example_tfvars/example-secrets.auto.tfvar.json terraform/secrets.auto.tfvars.json
    - Fill in secrets
      1. ipv4 CIDR BLOCKS
      1. root domain name 

- `tfenv use 1.1.9`
- `export AWS_PROFILE={INSERT AWS_PROFILE_NAME HERE}`
- `export AWS_ACCOUNT_ID={INSERT ACCOUNT ID HERE}`
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

- Force the ECS service to re-deploy:
  - `make ecs-update-service CLUSTER=production-nanomdm-cluster SERVICE=production`
  - Adjust `CLUSTER` and `SERVICE` to match what you specified in Terraform app_variables

## Adding new containers

- ecr repo
- update `make tf-first-run` to include this new ecr repo
- ecs service definition
- target group for new service
- add load balancer to service
- update main.tf (write variables at each layer)
- listeners <---> target groups
- 


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
