# NVIDIA Driver 및 CUDA 설치 (Ubuntu24)
# 다양한 OS에 대응하므로 공홈 참조하여 다운로드 (https://developer.nvidia.com/cuda-downloads)
# Nvidia Driver와 Cuda간 호환성이 중요하므로 설치페이지에 함께 표기된 것으로 설치(555)
# 최신버전 설치시 대부분 GPU에 호환가능
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-5 nvidia-driver-555-open cuda-drivers-555

# 파이썬 3.10 환경 및 필수 라이브러리
sudo apt update -y 
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.10 python3-pip python3.10-venv libgl1 libglib2.0-0

# 파이썬 로컬경로 등록 (launch.py로 실행시 시스템환경 사용함)
echo 'export PATH=$PATH:/home/ubuntu/.local/bin' >> ~/.bashrc
source ~/.bashrc
# 파이썬 가상환경 생성 (webui.sh로 실행시 자동으로 가상환경 선택함. 생성은 직접 필요)
python3.10 -m venv venv/  

# sd webui 다운로드
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
echo python_cmd=\"python3.10\" >> webui-user.sh
# cat requirements.txt > temp  &&  cat temp > requirements.txt  && rm -rf temp  # CRLF -> LF
echo >> requirements.txt && echo xformers >> requirements.txt

# 파이썬 모듈 및 sd1.5 등 기본모델 다운로드  # 재부팅 전까지 cuda 미적용상태이므로 실행은 안됨
./webui.sh --skip-torch-cuda-test
