# Create a KVM Libvirt OpenShift cluster using Terraform

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

`cloud_image` needs to be the full path to the image.
`ssh_pub_key` needs to be the public component of your ssh key starting with
`ssh-ed25519` or `ssh-rsa`.

Start the cluster:

``` sh
make install
```

Destroy the cluster:

``` sh
make destroy clean
```

Finding the IP of nodes:

``` sh
sudo virsh domifaddr compute-0
sudo virsh domifaddr infra-0
sudo virsh domifaddr master-0
```
