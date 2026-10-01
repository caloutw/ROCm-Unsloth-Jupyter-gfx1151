FROM rocm/pytorch:rocm10.0_ubuntu24.04_py3.12_pytorch_release_2.12.0

LABEL maintainer="caloutw"
LABEL org.opencontainers.image.title="ROCm-Unsloth-gfx1151"
LABEL org.opencontainers.image.version="1.2.0"
LABEL org.opencontainers.image.authors="calou code platform"
LABEL org.opencontainers.image.description="[CCP] A unsloth container for gfx1151 (ROCm 10.0)."

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

ENV HSA_OVERRIDE_GFX_VERSION=11.5.1
ENV HF_HUB_DISABLE_XET=1
ENV FLASH_ATTENTION_TRITON_AMD_ENABLE=TRUE
ENV PYTHONWARNINGS="ignore::FutureWarning:transformers.utils.import_utils"

ENV SHELL=/bin/bash

USER root
WORKDIR /spc

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl \
    sudo \
    git \
    wget \
    ca-certificates \
    gnupg \
    tmux \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip freeze | grep -Ei '^(torch|torchvision|torchaudio)==' > /tmp/rocm-torch-constraints.txt && \
    echo "== locked ROCm torch versions ==" && cat /tmp/rocm-torch-constraints.txt && \
    pip install --no-cache-dir -c /tmp/rocm-torch-constraints.txt \
        jupyter uv "unsloth[amd]" "bitsandbytes==0.50.0"

RUN set -eux; \
    ROCM_LIB="$(python -c 'import _rocm_sdk_core, os; print(os.path.join(os.path.dirname(_rocm_sdk_core.__file__), "lib"))')"; \
    for f in "${ROCM_LIB}"/*.so.*; do \
        base="$(basename "$f")"; \
        ln -sf "$f" "/opt/venv/lib/${base%%.so.*}.so"; \
    done

RUN git clone https://github.com/ROCm/flash-attention.git && \
    cd flash-attention && \
    git checkout main_perf && \
    pip install --no-cache-dir packaging ninja einops && \
    pip install --no-cache-dir --no-build-isolation . && \
    cd /spc && rm -rf /spc/flash-attention

RUN echo 'export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# "' >> /root/.bashrc

RUN mkdir /root/workspace
WORKDIR /root/workspace

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''", "--notebook-dir=/root/workspace"]
