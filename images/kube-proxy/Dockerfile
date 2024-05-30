ARG ubuntu
ARG alpine

FROM ${ubuntu} AS build
ENV VERSION=1.19.0
RUN apt-get update \
 && apt-get install -y curl
RUN echo "retrieving kube-proxy v${VERSION}..." \
 && mkdir -p /build \
 && curl -fSL --url https://dl.k8s.io/v${VERSION}/bin/linux/amd64/kube-proxy \
         -o /build/kube-proxy \
 && chmod 755 /build/*

FROM ${alpine}
MAINTAINER James Hunt <james@niftylogic.com>
RUN apk add iptables ipset ipvsadm conntrack-tools
COPY --from=build /build/ /
