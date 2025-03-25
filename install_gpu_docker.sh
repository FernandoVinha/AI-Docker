#!/bin/bash

# Verifica se está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g., sudo ./install_gpu_docker.sh)"
  exit 1
fi

# Atualiza pacotes
apt update && apt upgrade -y

# Instala dependências
apt install -y curl ca-certificates gnupg lsb-release docker.io

# Inicia e habilita Docker
systemctl enable docker
systemctl start docker

# Adiciona repositório do NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Atualiza pacotes e instala toolkit
apt update
apt install -y nvidia-container-toolkit nvidia-container-runtime

# Configura Docker para usar runtime NVIDIA
nvidia-ctk runtime configure --runtime=docker

# Reinicia Docker
systemctl restart docker

# Teste da GPU dentro do container (usando imagem suportada)
docker run --rm --gpus all nvidia/cuda:12.3.0-runtime-ubuntu22.04 nvidia-smi
