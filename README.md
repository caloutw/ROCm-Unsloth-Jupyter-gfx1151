# ROCm-Unsloth-Jupyter-gfx1151

Unsloth and Jupyter for AMD Strix Halo (`gfx1151`), built on the official ROCm 7.2 PyTorch image.

## Prerequisites

* **GPU:** AMD Strix Halo (`gfx1151`)
* **Kernel:** Tested on `6.18.38-061838-generic`
* **Docker:** Docker Engine (`docker-ce`) is required

Docker Desktop runs containers inside a virtual machine and cannot directly access the host's `/dev/kfd` and `/dev/dri` GPU devices. As a result, ROCm GPU passthrough will not work correctly with Docker Desktop.

## Build

Create a directory in your home folder for persistent storage:

```bash
mkdir -p ~/finetune
```

## Run

```bash
docker run -d \
    --name rocm-unsloth-jupyter-gfx1151 \
    --device=/dev/kfd \
    --device=/dev/dri \
    --security-opt seccomp=unconfined \
    -p 8888:8888 \
    -v ~/finetune:/root/workspace \
    ghcr.io/caloutw/rocm-unsloth-jupyter-gfx1151:latest
```

## Use

Open the following URL in your browser:

```text
http://localhost:8888
```

## Result

Test configuration:

* **Model:** Ministral 3 3B
* **Method:** 4-bit QLoRA
* **Dataset size:** 500 samples
* **Training time:** Approximately 30 minutes

Actual training time may vary depending on the training parameters and system configuration.

## Thanks

Special thanks to the following project for its AMD Strix Halo LLM fine-tuning research and implementation:

* [amd-strix-halo-llm-finetuning](https://github.com/kyuz0/amd-strix-halo-llm-finetuning)

