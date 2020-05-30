# Terraform
Configurations for AWS and OCI Clouds with Docker.

## Setup
Choose which Cloud and Operating System you would like to create a VM: `aws-ubuntu`, `aws-amazonlinux2`, `oci-centos`.

e.g.
```console
foo@bar# cd aws-ubuntu
```

For AWS, create the file `vars.env` with the following:
```
## fill with aws profile
PROFILE=
##
export TF_VAR_credentials_file=$HOME/.aws/credentials
export TF_VAR_credentials_profile=$PROFILE
export TF_VAR_key_name=
export TF_VAR_region=us-east-2

export TF_VAR_security_groups=`aws ec2 describe-security-groups --filter Name=ip-permission.to-port,Values=22 Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].{Name:GroupId}" --output text --profile $PROFILE`
```

For OCI, create the file `vars.env` with the following:
```
export TF_VAR_tenancy_ocid=<tenancy_ocid>
export TF_VAR_user_ocid=<user_ocid>
export TF_VAR_compartment_ocid=<compartment_ocid>
export TF_VAR_fingerprint=<key_fingerprint>
export TF_VAR_private_key_path=<oci_api_key>
export TF_VAR_region=<region_id>
```

## Init
```console
foo@bar# terraform init
```

## Plan
```console
foo@bar# terraform plan -out my.tfplan
```

## Apply
```console
foo@bar# terraform apply my.tfplan
```

## Destroy
```console
foo@bar# terraform destroy
```
