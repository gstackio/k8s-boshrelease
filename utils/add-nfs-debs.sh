#!/usr/bin/env bash

set -ueo pipefail

function configure() {
    :
}

function main() {
    setup
    configure

    mkdir -p "${RELEASE_DIR}/tmp/debs"
    pushd "${RELEASE_DIR}/tmp/debs" > /dev/null

        # bosh -d tinynetes ssh \
        #     --command="sudo apt-get update -qq ; sudo apt-get install -y \
        #         --verbose-versions --no-install-recommends --download-only \
        #         nfs-kernel-server"

        # bosh -d tinynetes scp k8s:/var/cache/apt/archives/*.deb .

        # for deb in *1%3a*.deb; do mv -v "${deb}" "${deb//1%3a/}"; done

        for deb in *.deb; do
            blob_path="nfs-bionic-debs/${deb}"
            bosh add-blob --dir="${RELEASE_DIR}" "${deb}" "${blob_path}"
        done

    popd > /dev/null
}

function setup() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    readonly SCRIPT_DIR
    RELEASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
    readonly RELEASE_DIR
}

main "$@"
