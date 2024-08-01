# NVIDIA Driver 및 CUDA 설치 (Ubuntu24)
# 다양한 OS에 대응하므로 공홈 참조하여 다운로드 (https://developer.nvidia.com/cuda-downloads)
# Nvidia Driver와 Cuda간 호환성이 중요하므로 설치페이지에 함께 표기된 것으로 설치(555)
# 최신버전 설치시 대부분 GPU에 호환가능

# 딥러닝용 이미지 사용시 사용X
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-5 nvidia-driver-555-open cuda-drivers-555

# sudo reboot