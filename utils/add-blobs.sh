#!/usr/bin/env bash

set -ueo pipefail

function configure() {
    IPVSADM_VERSION=1.30
    IPVSADM_SHA256=888a281cb468118fefb939ab764b85aad504dc4a5ccb6b81d8d91c3214a53d5c

    LIBNL_VERSION=3.2.25
    LIBNL_SHA256=8beb7590674957b931de6b7f81c530b85dc7c1ad8fbda015398bc1e8d1ce8ec5

    POPT_VERSION=1.16
    POPT_MD5=3743beefa3dd6247a73f8f7a32c14c33
    POPT_SHA256=e728ed296fe9f069a0e005003c3d6b2dde3d9cad453422a10d6558616d304cc8

    JQ_VERSION=1.6
    JQ_SHA256=af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44

    HAPROXY_VERSION=1.8.22
    HAPROXY_SHA256=7be245cdbc3fff9365af1df1c13fdff768fb7f9c4363e7daa52c315ec20dc1f8

    KEEPALIVED_VERSION=2.0.16
    KEEPALIVED_SHA256=f0c7dc86147a286913c1c2c918f557735016285d25779d4d2fce5732fcb888df

    SOCAT_VERSION=1.7.3.3
    SOCAT_SHA256=0dd63ffe498168a4aac41d307594c5076ff307aa0ac04b141f8f1cec6594d04a
}

function main() {
    setup
    configure

    mkdir -p "${RELEASE_DIR}/tmp/blobs"
    pushd "${RELEASE_DIR}/tmp/blobs" > /dev/null

        local blob_file

        # http://www.linuxvirtualserver.org/software/ipvs.html
        # https://cdn.kernel.org/pub/linux/utils/kernel/ipvsadm/
        # https://mirrors.edge.kernel.org/pub/linux/utils/kernel/ipvsadm/
        blob_file="ipvsadm-${IPVSADM_VERSION}.tar.gz"
        add_blob "ipvsadm" "${blob_file}" "ipvsadm/${blob_file}"

        # Netlink Library homepage: https://www.infradead.org/~tgr/libnl/
        blob_file="libnl-${LIBNL_VERSION}.tar.gz"
        add_blob "libnl" "${blob_file}" "ipvsadm/${blob_file}"

        # https://www.linuxfromscratch.org/blfs/view/basic/popt.html
        # https://rpm5.org/files/popt/popt-1.16.tar.gz
        blob_file="popt-${POPT_VERSION}.tar.gz"
        add_blob "popt" "${blob_file}" "ipvsadm/${blob_file}"

        # https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux64
        blob_file="jq-${JQ_VERSION}.tar.gz"
        add_blob "jq" "${blob_file}" "jq/jq"

        # https://www.haproxy.org/download/1.8/src/haproxy-1.8.22.tar.gz
        blob_file="haproxy-${HAPROXY_VERSION}.tar.gz"
        add_blob "haproxy" "${blob_file}" "lb/${blob_file}"

        # https://www.keepalived.org/download.html
        # https://www.keepalived.org/software/keepalived-2.0.16.tar.gz
        blob_file="keepalived-${KEEPALIVED_VERSION}.tar.gz"
        add_blob "keepalived" "${blob_file}" "lb/${blob_file}"

        # http://www.dest-unreach.org/socat/
        # http://www.dest-unreach.org/socat/download/Archive/socat-1.7.3.3.tar.bz2
        blob_file="socat-${SOCAT_VERSION}.tar.bz2"
        add_blob "socat" "${blob_file}" "socat/${blob_file}"

    popd > /dev/null
}

function setup() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    readonly SCRIPT_DIR
    RELEASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
    readonly RELEASE_DIR
}

function add_blob() {
    local blob_name="$1"
    local blob_file="$2"
    local blob_path="$3"

    if [[ ! -f "${blob_file}" ]]; then
        "download_${blob_name}" "${blob_file}"
    fi
    (
        set -x
        bosh add-blob --dir="${RELEASE_DIR}" "${blob_file}" "${blob_path}"
    )
}

function download_ipvsadm() {
    local blob_file="$1"
    download_blob_and_checksum \
        "https://mirrors.edge.kernel.org/pub/linux/utils/kernel/ipvsadm/ipvsadm-${IPVSADM_VERSION}.tar.gz" \
        "${blob_file}" "${IPVSADM_SHA256}"
}

function download_libnl() {
    local blob_file="$1"
    download_blob_and_checksum \
        "https://www.infradead.org/~tgr/libnl/files/libnl-${LIBNL_VERSION}.tar.gz" \
        "${blob_file}" "${LIBNL_SHA256}"
}

function download_popt() {
    local blob_file="$1"
    download_blob_and_checksum \
        "https://src.fedoraproject.org/repo/pkgs/popt/popt-${POPT_VERSION}.tar.gz/md5/${POPT_MD5}/popt-${POPT_VERSION}.tar.gz" \
        "${blob_file}" "${POPT_SHA256}"
}

function download_jq() {
    local blob_file="$1"
    download_blob_and_checksum \
        "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux64" \
        "${blob_file}" "${JQ_SHA256}"
}

function download_haproxy() {
    local blob_file="$1"
    local branch_ver=${HAPROXY_VERSION%.*}
    download_blob_and_checksum \
        "https://www.haproxy.org/download/${branch_ver}/src/haproxy-${HAPROXY_VERSION}.tar.gz" \
        "${blob_file}" "${HAPROXY_SHA256}"
}

function download_keepalived() {
    local blob_file="$1"
    download_blob_and_checksum \
        "https://www.keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz" \
        "${blob_file}" "${KEEPALIVED_SHA256}"
}

function download_socat() {
    local blob_file="$1"
    download_blob_and_checksum \
        "http://www.dest-unreach.org/socat/download/Archive/socat-${SOCAT_VERSION}.tar.bz2" \
        "${blob_file}" "${SOCAT_SHA256}"
}

function download_blob_and_checksum() {
    local url="$1"
    local blob_file="$2"
    local sha256="$3"

    (
        set -x
        curl --silent --fail --show-error --location \
            --url "${url}" --output "${blob_file}"
        shasum -a 256 --check <<< "${sha256}  ${blob_file}"
    )
}

main "$@"
