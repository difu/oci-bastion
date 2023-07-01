# OCI Bastion

Silly little testbed to play with OCI Bastion Service
It uses code
from [https://github.com/jake-oci/oci-cli_bastion_session_automator](https://github.com/jake-oci/oci-cli_bastion_session_automator).

## Install requirements

```shell
pip install -r requirements.txt
```

## Create your virtual machine in a private subnet without internet access environment

You will need to specify

- your compartment OCID in which the created private VM will be deployed.
- the image OCID of the OS image the VM is provisioned with
- your public key

Example:

```shell
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..aaaaaaaaXXX"
export TF_VAR_image_ocid="ocid1.image.oc1.XXX"
export TF_VAR_ssh_public_keys="/path/to/your/public_key/id_rsa_oci.pub"
```

Run terraform

```shell
terraform apply
```

A simple setup with VCN, private subnet and a little VM will be created.

## Login via bastion service

Terraform will return the OCID of the bation service and the private IP adress of the VM:

```
...

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bastion_ocid = "ocid1.bastion.oc1.eu-frankfurt-1.amaaaaaaxxx"
instance_private_ip = [
  "10.0.0.126",
]

```

```
python bastion_session_automator.py -b ocid1.bastion.oc1.eu-frankfurt-1.amaaaaaaxxx" -l 10.0.0.126 22 -r

SSH KEY -- Generating an ephemeral SSH keypair for this Bastion Session.
OCI -- Authenticating OCI User...
OCI -- Connected to the EU-FRANKFURT-1 OCI Region
Bastion Host -- CIDR ALLOW Rule '0.0.0.0/0' will allow connectivity from PUB IP 93.202.241.92
Bastion Host -- OCI_BASTION_DEMO Total Active Sessions = 0
Bastion Session -- OCI Is Creating A Bastion Session.
Bastion Session -- Bastion is in a CREATING status, waiting for ACTIVE.
Bastion Session -- Bastion Session is in an ACTIVE status.

[Attention!]
Sessions will indefinitely be created for you in the background.
You might see a temporary disconnect while a new session is created.

!!!KEEP THIS TERMINAL OPEN!!!
SOCKS5 PROXY <--MAPPED TO--> localhost:46208
10.0.0.126:22 <--MAPPED TO--> localhost:45454
```

In another shell you are now able to login:

```shell
ssh opc@localhost -p 45454 -i ~/path/to/private_key/id_rsa_oci
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Sat Jul  1 11:25:42 2023 from 10.0.0.111
```