Development
===========

Upload stemcell, cloud config bits, and try a first simple deployment:

```shell
bosh upload-stemcell --sha1 "7724ce4272dd8f19b44584a17d31595eac7595e5" \
  "https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-xenial-go_agent?v=621.125"

bosh update-config --type "cloud" --name "k8s" \
    manifests/cloud-config/k8s.yml

bosh update-config --type "cloud" --name "vboox-networking" \
    manifests/cloud-config/vbox-network.yml

bosh deploy --non-interactive \
    --deployment="$(bosh int manifests/tinynetes.yml --path /name)" \
    manifests/tinynetes.yml \
    --vars-store="tmp/depl-creds.yml"
```

Then with more customizations:

```shell
(
    depl="manifests/tinynetes.yml"; ops="manifests/operators"; tops="${ops}/tinynetes";
    bosh deploy "${depl}" \
        --deployment="$(bosh int "${depl}" --path /name)" \
        --ops-file="${tops}/persistent-disk-type.yml" \
        --ops-file="${tops}/azs.yml" \
        --ops-file="${tops}/network-name.yml" \
        --ops-file="${tops}/k8s-networking.yml" \
        --ops-file="${tops}/cert-manager.yml" \
        --ops-file="${tops}/bootstrap.yml" \
        --ops-file="${ops}/latest-release.yml" \
        --vars-file="manifests/vars/tinynetes-vars.yml" \
        --ops-file="${ops}/shell-config.yml" \
        --var="os_conf_version=22.2.1" \
        --var="os_conf_sha1=daf34e35f1ac678ba05db3496c4226064b99b3e4" \
        --vars-store="tmp/depl-creds.yml" \
        --non-interactive
)
```

And when in need for destroying everything:

```shell
bosh delete-deployment -n -d tinynetes
```
