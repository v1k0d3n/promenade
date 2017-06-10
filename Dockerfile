# Copyright 2017 The Promenade Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM python:3.6

ENV CNI_VERSION=v0.5.2 \
    HELM_VERSION=v2.4.2 \
    KUBECTL_VERSION=v1.6.2 \
    KUBELET_VERSION=v1.6.2

VOLUME /etc/promenade
VOLUME /target

RUN mkdir /promenade
WORKDIR /promenade

RUN set -ex \
    && export KUBELET_DIR=/assets/usr/local/bin \
    && mkdir -p $KUBELET_DIR \
    && curl -sL -o $KUBELET_DIR/kubelet \
        http://storage.googleapis.com/kubernetes-release/release/$KUBELET_VERSION/bin/linux/amd64/kubelet \
    && chmod 555 $KUBELET_DIR/kubelet \
    && mkdir -p /opt/cni/bin \
    && curl -sL https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-amd64-$CNI_VERSION.tgz | tar -zxv -C /opt/cni/bin/ \
    && curl -sLo /usr/local/bin/kubectl http://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubelet \
    && chmod 555 /usr/local/bin/kubectl \
    && curl -sL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv -C /tmp linux-amd64/helm \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod 555 /usr/local/bin/helm

RUN set -ex \
    && apt-get update -qq \
    && apt-get install --no-install-recommends -y \
        libyaml-dev \
        openssl \
        rsync \
    && rm -rf /var/lib/apt/lists/*

COPY requirements-frozen.txt /promenade
RUN pip install --no-cache-dir -r requirements-frozen.txt

COPY . /promenade
RUN pip install -e /promenade

COPY assets/ /assets