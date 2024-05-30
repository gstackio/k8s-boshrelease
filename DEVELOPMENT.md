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
    depl="manifests/tinynetes.yml"; ops="manifests/operators/tinynetes";
    bosh deploy "${depl}" \
        --deployment="$(bosh int "${depl}" --path /name)" \
        --ops-file="${ops}/persistent-disk-type.yml" \
        --ops-file="${ops}/azs.yml" \
        --ops-file="${ops}/network-name.yml" \
        --ops-file="${ops}/k8s-networking.yml" \
        --ops-file="${ops}/bootstrap.yml" \
        --ops-file="manifests/operators/latest-release.yml" \
        --vars-file="manifests/vars/tinynetes-vars.yml" \
        --vars-store="tmp/depl-creds.yml" \
        --non-interactive
)
```

And when in need for destroying everything:

```shell
bosh delete-deployment -n -d tinynetes
```
