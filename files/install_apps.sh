TMP_DIR=/tmp/files

#############################################################################
# filebrowser
#############################################################################
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

#############################################################################
# Stable Diffusion WebUI  # https://github.com/AUTOMATIC1111/stable-diffusion-webui # official python support: 3.10.6
#############################################################################
sudo apt update -y && sudo apt install -y python3.10-venv
cd $HOME
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
echo python_cmd=\"python3.10\" >> webui-user.sh
python3.10 -m venv venv/  # 파이썬 가상환경 생성 (webui.sh에 가상환경 생성 단계가 있으나 버그로 안됨. 직접 생성 필요)

# sd-webui 설치 (파이썬 모듈 및 sd1.5 등 기본모델 포함)
# webui.sh는 설치와 실행을 모두 포함하며, 항상 세션을 점유한다.
# webui.sh의 모든 사전설치과정을 ami에 담기 위해 정상실행 단계까지 완료해준다.
# 정상실행완료 후 점유된 세션으로 인해 packer작업이 진행되지 않으므로 별도의 백그라운드 스크립트를 통해 강제로 종료시킨다.
  # webui.sh를 백그라운드 실행하지 않는다. 세션점유는 피할 수 있으나, 설치완료 전에 packer가 종료 될 수 있음
  # 설치 중 소요시간이 천차만별이라서 단순 sleep으로 대응하기 힘듦
nohup "$TMP_DIR/wait_webui_install.sh" &
./webui.sh --skip-torch-cuda-test --xformers --port 7859  # > /dev/null 2>&1

#############################################################################
# kohya_ss  # https://github.com/bmaltais/kohya_ss  # official python support: 3.10.11
#############################################################################
sudo apt update -y && sudo apt install -y python3.10-venv python3-tk python3.10-tk
cd $HOME
git clone --recursive https://github.com/bmaltais/kohya_ss.git
cd kohya_ss
sudo chmod +x ./setup.sh
./setup.sh
