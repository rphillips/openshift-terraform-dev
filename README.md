Fetch the cloud image:

``` sh
wget https://download.fedoraproject.org/pub/fedora/linux/releases/27/CloudImages/x86_64/images/Fedora-Cloud-Base-27-1.6.x86_64.qcow2
```

Resize the image so there is enough drive space:
```sh
qemu-img resize Fedora-Cloud-Base-27-1.6.x86_64.qcow2 +8G
```

