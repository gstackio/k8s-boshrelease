ARG ubuntu
ARG alpine
ARG kube_proxy_version

FROM ${ubuntu} AS build
RUN apt-get update \
 && apt-get install -y curl
RUN echo "retrieving kube-proxy v${kube_proxy_version}..." \
 && mkdir -p /build \
 && curl -fSL --url https://dl.k8s.io/v${kube_proxy_version}/bin/linux/amd64/kube-proxy \
         -o /build/kube-proxy \
 && chmod 755 /build/*

FROM ${alpine}
MAINTAINER James Hunt <james@niftylogic.com>
RUN apk add iptables ipset ipvsadm conntrack-tools
COPY --from=build /build/ /
