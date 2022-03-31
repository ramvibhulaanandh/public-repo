FROM alpine:3

ARG HELM_VERSION=3.7.0
ARG HELM_TESTING=3.5.0
ARG KUBELINTER_VERSION=0.2.5

RUN apk add --update --no-cache \
    bash git jq redis make \
    curl ca-certificates && \
    curl -sL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64
 
COPY setup.sh /root/
RUN chmod +x /root/setup.sh  \
    && /root/setup.sh \
    && apk add --update --no-cache python3 py3-pip \
    && rm /root/setup.sh

# add helm-diff
RUN helm plugin install --version v3.1.3 https://github.com/databus23/helm-diff && rm -rf /tmp/helm-*

# add helm-unittest
RUN helm plugin install --version v0.2.8 https://github.com/quintush/helm-unittest && rm -rf /tmp/helm-*

# add helm-push
RUN helm plugin install --version v0.10.1 https://github.com/chartmuseum/helm-push && rm -rf /tmp/helm-*
 
# Kubernetes linter
RUN wget https://github.com/stackrox/kube-linter/releases/download/${KUBELINTER_VERSION}/kube-linter-linux.tar.gz -O /tmp/kube-linter.tar.gz \
    && cd /tmp/ \
    && tar xf kube-linter.tar.gz \
    && rm kube-linter.tar.gz \
    && chmod +x ./kube-linter \
    && cp kube-linter /usr/local/bin
 
ENV PYTHONUNBUFFERED=1

RUN pip3 install --no-cache --upgrade pip setuptools \
    && pip3 install yq

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]