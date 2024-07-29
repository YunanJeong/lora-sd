# https://github.com/bmaltais/kohya_ss

# install_sd_webui.sh에서 이미 설치됨
  # install nvidia driver/cuda
  # install python, python-venv, ... (240729: kohya_ss's official support: 3.10.11)

# python을 3.10으로 설치했기 때문에 python3.10-tk 필요
# 단, python3-tk가 없을시 setup.sh 스크립트 진행이 안되도록 막혀있기 때문에 python3-tk도 설치
# 앱 실제 동작에는 python3.10-tk가 사용된다.
sudo apt update -y
sudo apt install -y python3.10-tk python3-tk

# install kohya_ss
git clone --recursive https://github.com/bmaltais/kohya_ss.git
cd kohya_ss
sudo chmod +x ./setup.sh
./setup.sh

# Run
# cd kohya_ss
# ./setup-runpod.sh # ./gui.sh --listen=0.0.0.0 --headless