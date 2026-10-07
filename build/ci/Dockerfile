FROM python:3.12-slim-bookworm

ARG TARGETARCH
ARG TFENV_VERSION=3.2.1
ARG TERRAFORM_VERSION=1.13.0
ARG PACKER_VERSION=1.16.1
ARG TASK_VERSION=3.53.1
ARG KUBECTL_VERSION=v1.37.1
ARG HELM_VERSION=3.22.0

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

ENV TFENV_ROOT=/opt/tfenv
ENV PATH="${TFENV_ROOT}/bin:${PATH}"

RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        bash \
        ca-certificates \
        curl \
        git \
        openssh-client \
        sshpass \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/ci-requirements.txt
RUN python -m pip install --no-cache-dir --requirement /tmp/ci-requirements.txt \
    && python -m pip check \
    && rm /tmp/ci-requirements.txt

# Match the version manager used by the repository's Terraform Taskfiles.
RUN git clone --depth 1 --branch "v${TFENV_VERSION}" \
        https://github.com/tfutils/tfenv.git "${TFENV_ROOT}" \
    && tfenv install "${TERRAFORM_VERSION}" \
    && tfenv use "${TERRAFORM_VERSION}"

# Install pinned multi-architecture CLI tools and verify each downloaded archive.
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64|arm64) ;; \
        *) echo "Unsupported target architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    tools_dir="$(mktemp -d)"; \
    trap 'rm -rf "${tools_dir}"' EXIT; \
    packer_archive="packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip"; \
    curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS" \
        -o "${tools_dir}/packer_SHA256SUMS"; \
    curl -fsSL "https://releases.hashicorp.com/packer/${PACKER_VERSION}/${packer_archive}" \
        -o "${tools_dir}/${packer_archive}"; \
    awk -v archive="${packer_archive}" '$2 == archive { print }' \
        "${tools_dir}/packer_SHA256SUMS" > "${tools_dir}/packer.sha256"; \
    (cd "${tools_dir}" && sha256sum --check packer.sha256); \
    unzip -q "${tools_dir}/${packer_archive}" -d /usr/local/bin; \
    task_archive="task_linux_${TARGETARCH}.tar.gz"; \
    curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_checksums.txt" \
        -o "${tools_dir}/task_checksums.txt"; \
    curl -fsSL "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/${task_archive}" \
        -o "${tools_dir}/${task_archive}"; \
    awk -v archive="${task_archive}" '$2 == archive { print }' \
        "${tools_dir}/task_checksums.txt" > "${tools_dir}/task.sha256"; \
    (cd "${tools_dir}" && sha256sum --check task.sha256); \
    tar -xzf "${tools_dir}/${task_archive}" -C "${tools_dir}" task; \
    install -m 0755 "${tools_dir}/task" /usr/local/bin/task; \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
        -o "${tools_dir}/kubectl"; \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl.sha256" \
        -o "${tools_dir}/kubectl.sha256"; \
    (cd "${tools_dir}" && printf '%s  kubectl\n' "$(cat kubectl.sha256)" | sha256sum --check -); \
    install -m 0755 "${tools_dir}/kubectl" /usr/local/bin/kubectl; \
    helm_archive="helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz"; \
    curl -fsSL "https://get.helm.sh/${helm_archive}" -o "${tools_dir}/${helm_archive}"; \
    curl -fsSL "https://get.helm.sh/${helm_archive}.sha256sum" \
        -o "${tools_dir}/${helm_archive}.sha256sum"; \
    (cd "${tools_dir}" && sha256sum --check "${helm_archive}.sha256sum"); \
    tar -xzf "${tools_dir}/${helm_archive}" -C "${tools_dir}" "linux-${TARGETARCH}/helm"; \
    install -m 0755 "${tools_dir}/linux-${TARGETARCH}/helm" /usr/local/bin/helm

RUN ansible --version \
    && ansible-lint --version \
    && yamllint --version \
    && terraform version \
    && packer version \
    && task --version \
    && kubectl version --client \
    && helm version --short
