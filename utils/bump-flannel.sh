#!/usr/bin/env bash

set -ueo pipefail

function configure() {
    FLANNEL_VERSION="0.15.0"
}

function main() {
    setup
    configure

    curl -fSL --url https://github.com/flannel-io/flannel/raw/v${FLANNEL_VERSION}/Documentation/kube-flannel.yml \
        -o "${RELEASE_DIR}/jobs/net-flannel/templates/k8s-init/flannel.yml"
}

function setup() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    readonly SCRIPT_DIR
    RELEASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
    readonly RELEASE_DIR
}

main "$@"
