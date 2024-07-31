
# 파이썬 3.10 환경 및 필수 라이브러리
sudo apt update -y 
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.10 python3-pip python3.10-venv libgl1 libglib2.0-0

# kohya_ss에서 요구하는 추가 모듈
sudo apt install -y python3-tk python3.10-tk
