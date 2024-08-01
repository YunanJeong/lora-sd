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
    Name    = "lora-sd-ubuntu24-{{ timestamp }}"
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
  source_ami    = var.ubuntu24_lts.ami
  ssh_username  = var.ubuntu24_lts.user
  instance_type = "g6.xlarge" # us-east-1
  run_tags      = var.tags

  # 결과물 ami 설정 (참고: ami_name과 ami의 tag Name은 다른 개념)
  ami_name = "ami-${var.tags.Name}"
  tags     = var.tags

  # 임시 인스턴스의 EBS 설정
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 50  # GB  # ami의 기본 볼륨으로 그대로 적용됨
    delete_on_termination = true # 인스턴스 종료시 EBS 삭제. 설정안해주면 EBS 내역이 계속 쌓임 
  }
}

build {
  name = "my-ami-builder"
  sources = [
    "source.amazon-ebs.example"
  ]

  provisioner "file" {
    source      = "files"
    destination = "/tmp/files"
  }
  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"] # CLI 비대화형모드 (debconf 경고방지)
    expect_disconnect = true  # disconnect되어도 에러취급 X. reboot 대응.
    inline = [
      "cloud-init status --wait", # 인스턴스 초기화 작업 종료까지 대기 (에러방지)
      "sudo chmod +x /tmp/files/*",
      "sudo mv /tmp/files/*.service /etc/systemd/system/",
      
      "cd /tmp/files && ./install_nvidia_cuda.sh && ./install_python.sh",
      "sudo reboot",
    ]
    pause_after="15s"  # 안정적인 재부팅처리를 위해 작업 후 대기
  }

  provisioner "file" {
    source      = "files"
    destination = "/tmp/files"
  }
  provisioner "shell" {
    pause_before="15s"  # 안정적인 재부팅처리를 위해 작업 전 대기
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"] # CLI 비대화형모드 (debconf 경고방지)
    inline = [
      "sudo chmod +x /tmp/files/*",
      "cd /tmp/files && ./install_apps.sh",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable stable-diffusion-webui.service filebrowser.service lora-kohya.service",

      # 불필요파일 삭제(용량 확보)
      "python3.10 -m pip cache purge", # python3.10 -m pip cache dir, pip3 cache dir, pip cache dir로 캐시 경로 확인가능
      "sudo apt clean  ;  sudo rm -rf /tmp/*",
    ]
  }
}