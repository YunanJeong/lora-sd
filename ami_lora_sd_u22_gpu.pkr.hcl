packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# variable을 별도 선언하면 inspect, 로그 등에서 확인이 용이함. 딱히 안써도됨. 
variable "aws_access_key" {
  default = env("AWS_ACCESS_KEY") # env함수로 환경변수 읽기가능
}
variable "aws_secret_key" {
  default = env("AWS_SECRET_KEY")
}
variable "ubuntu24_lts" {
  default = {
    ami  = "ami-04a81a99f5ec58529" # us-east-1
    user = "ubuntu"
    setup  = "cd /tmp/files && ./install_nvidia_cuda.sh && ./install_python.sh && ./install_apps.sh"
  }
}
variable "ubuntu22_gpu" {
  default = {
    ami  = "ami-0f7c4a792e3fb63c8" # us-east-1, Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04)
    user = "ubuntu" 
    setup = "cd /tmp/files && ./install_apps.sh"
  }
}

/*
Name = "string-example-{{timestamp}}"  # 현재 타임스탬프를 포함
Name = "string-example-{{uuid}}"       # UUID를 포함
Name = "string-example-{{isotime}}"    # ISO 8601 형식의 현재 시간을 포함
Name = "string-example-{{build_name}}" # 현재 빌드의 이름을 포함
Name = "string-example-{{build_type}}" # 현재 빌드의 타입을 포함
Name = "string-example-{{user `custom_var`}}" # 사용자 정의 변수를 포함
*/
variable "tags" {
  default = {
    Name    = "lora-sd-ubuntu22-gpu-{{ timestamp }}"
    Owner   = env("TAG_OWNER")
    Service = env("TAG_SERVICE")
    Packer  = true
  }
}

source "amazon-ebs" "example" {
  # AWS 자격증명 설정 (생략시 환경변수 또는 awscli의 default 프로필이 자동적용됨)
  // access_key = var.aws_access_key 
  // secret_key = var.aws_secret_key
  region = "us-east-1"
  // profile    = "default" # ~/.aws/credentials에서 프로필 선택 명시

  # ami 생성을 위한 임시 인스턴스 설정
  source_ami    = var.ubuntu22_gpu.ami
  ssh_username  = var.ubuntu22_gpu.user
  instance_type = "g6.xlarge" # us-east-1
  run_tags      = var.tags

  # 결과물 ami 설정 (참고: ami_name과 ami의 tag Name은 다른 개념)
  ami_name = "ami-${var.tags.Name}"
  tags     = var.tags

  # 임시 인스턴스의 EBS 설정
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 100  # GB  # ami의 기본 볼륨으로 그대로 적용됨
    delete_on_termination = true # 인스턴스 종료시 EBS 삭제. 설정안해주면 EBS 내역이 계속 쌓임 
  }
}

build {
  name = "my-ami-builder"
  sources = [
    "source.amazon-ebs.example"
  ]

  # 이미지에 포함될 앱 설치 & 서비스 실행 등 설정
  provisioner "file" {
    source      = "files"
    destination = "/tmp/files"
  }
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"] # CLI 비대화형모드 (debconf 경고방지)
    inline = [
      "cloud-init status --wait", # 인스턴스 초기화 작업 종료까지 대기 (에러방지)

      "sudo chmod +x /tmp/files/*",
      "sudo mv /tmp/files/*.service /etc/systemd/system/",
      
      var.ubuntu22_gpu.setup,
      "sudo systemctl daemon-reload",
      "sudo systemctl enable ongen-browser ongen-kohya ongen-sd-webui",

      # 디렉토리
      "cd ~/ && sudo mkdir image model upload",
      "cd ~/ && sudo rm -rf BUILD_FROM_SOURCE_PACKAGES_LICENCES LINUX_PACKAGES_LICENSES LINUX_PACKAGES_LIST OSSNvidiaDriver_v535.183.01_license.txt PYTHON_PACKAGES_LICENSES THIRD_PARTY_SOURCE_CODE_URLS nvidia-acknowledgements",

      # 불필요파일 삭제(용량 확보)
      "python3.10 -m pip cache purge", # python3.10 -m pip cache dir, pip3 cache dir, pip cache dir로 캐시 경로 확인가능
      "sudo apt clean  ;  sudo rm -rf /tmp/*",
    ]
  }
} 