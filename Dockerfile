FROM rocm/pytorch:rocm7.2.4_ubuntu24.04_py3.12_pytorch_2.10.0_ORT_1.23.2

LABEL maintainer="caloutw"
LABEL org.opencontainers.image.title="ROCm-Unsloth-gfx1151"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="calou code platform"
LABEL org.opencontainers.image.description="[CCP] A unsloth container for gfx1151."

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

ENV HSA_OVERRIDE_GFX_VERSION=11.5.1
ENV HF_HUB_DISABLE_XET=1
ENV FLASH_ATTENTION_TRITON_AMD_ENABLE=TRUE
ENV PYTHONWARNINGS="ignore::FutureWarning:transformers.utils.import_utils"

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

RUN pip install jupyter uv "unsloth[amd]" "bitsandbytes==0.50.0" --no-cache-dir

RUN git clone https://github.com/ROCm/flash-attention.git && \
    cd flash-attention && \
    python -m pip install --no-cache-dir packaging && \
    git checkout main_perf && \
    python setup.py install && \
    cd /spc && rm -rf /spc/flash-attention

RUN mkdir /root/workspace
WORKDIR /root/workspace

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''", "--notebook-dir=/root/workspace"]
