# https://github.com/AUTOMATIC1111/stable-diffusion-webui

# NVIDIA Driver 및 CUDA 설치 (Ubuntu24)
# 다양한 OS에 대응하므로 공홈 참조하여 다운로드 (https://developer.nvidia.com/cuda-downloads)
# Nvidia Driver와 Cuda간 호환성이 중요하므로 설치페이지에 함께 표기된 것으로 설치(555)
# 최신버전 설치시 대부분 GPU에 호환가능
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-5 nvidia-driver-555-open cuda-drivers-555

# 파이썬 3.10 환경 및 필수 라이브러리 (240729: sd webui's official support: 3.10.6)
sudo apt update -y 
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.10 python3-pip python3.10-venv libgl1 libglib2.0-0


# sd webui 다운로드
cd $HOME
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
echo python_cmd=\"python3.10\" >> webui-user.sh
python3.10 -m venv venv/  # 파이썬 가상환경 생성 (webui.sh에 가상환경 생성 단계가 있으나 버그로 안됨. 직접 생성 필요)

# 추가 dependency 설치 (파이썬 모듈 및 sd1.5 등 기본모델)
# 세션점유를 막기 위해 백그라운드로 실행
  # webui.sh 에는 dependency 설치와 webui 실행 절차 등이 모두 포함되어 있음
   # 설치파일엔 모델 등이 포함되어있어 오래걸림
   # => 실제 사용할 인스턴스에서 초기화로 수행되면 안되고 packer ami에 반드시 포함필요
  # webui.sh를 그냥 실행하면?
    # dependency는 잘 설치되나, 재부팅 전까지 cuda 미적용상태이므로 앱 실행은 Fail
    # => Fail이 뜨고 세션 점유되어 packer 작업 무기한 중지
    # 그렇다고 reboot 후 실행하면, 모델 로딩 절차 등으로 인해 packer작업시간이 너무 길어짐
    # packer 작업 단계에서는 굳이 앱을 실행할 필요는 없음
nohup ./webui.sh --skip-torch-cuda-test --xformers > /dev/null 2>&1 &
for i in $(seq 60 -1 1); do echo "Waiting for $i seconds..."; sleep 1; done  # denpendency 설치될 때까지 대기
echo "Stable Diffusion WebUI installed !"