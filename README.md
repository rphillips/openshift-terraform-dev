# Create a KVM Libvirt OpenShift cluster using Terraform

By changing constants located in constants.tfvar a local libvirt cluster will be
created. Openshift Ansible can then be run against the cluster to provision a
local development environment for OpenShift.

## Cloud Image

Fetch the cloud image:

``` sh
wget https://download.fedoraproject.org/pub/fedora/linux/releases/27/CloudImages/x86_64/images/Fedora-Cloud-Base-27-1.6.x86_64.qcow2
```

Resize the image so there is enough drive space:

```sh
qemu-img resize Fedora-Cloud-Base-27-1.6.x86_64.qcow2 +8G
```

## Install Dependencies

* mkisofs
* make
* terraform
* libvirtd
* virsh
* [terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt#building-from-source)
  * mkdir -p ~/.terraform.d/plugins
  * cp $GOPATH/bin/terraform-provider-libvirt ~/.terraform.d/plugins

## Running

Copy the constants.tfvar.example to constants.tfvar

``` sh
cp constants.tfvar.example constants.tfvar
```

Edit `constants.tfvar`:

* `cloud_image` needs to be the full path to the image
* `ssh_pub_key` needs to be the public component of your ssh key starting with `ssh-ed25519` or `ssh-rsa`

Start the cluster:

``` sh
make install
```

Destroy the cluster:

``` sh
make clean
```

Finding the IP of nodes:

``` sh
make output
```

or

``` sh
sudo virsh domifaddr cluster1-compute-0
sudo virsh domifaddr cluster1-infra-0
sudo virsh domifaddr cluster1-master-0
```
