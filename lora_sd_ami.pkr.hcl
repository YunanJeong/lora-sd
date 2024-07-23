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
variable "ubuntu_22_lts" {
  default = {
    ami  = "ami-063454de5fe8eba79"
    user = "ubuntu"
  }
}

/*
Name = "string-example-{{timestamp}}"  # 현재 타임스탬프를 포함
Name = "string-example-{{uuid}}"       # UUID를 포함
Name = "string-example-{{isotime}}"    # ISO 8601 형식의 현재 시간을 포함
Name = "{{clean_ami_name `string-example-{{isotime}}`}}"  # AMI 이름에서 AWS에서 허용하지 않는 문자를 제거
Name = "string-example-{{build_name}}" # 현재 빌드의 이름을 포함
Name = "string-example-{{build_type}}" # 현재 빌드의 타입을 포함
Name = "string-example-{{user `custom_var`}}" # 사용자 정의 변수를 포함
*/
variable "tags" {
  default = {
    Name    = "yunan-sd-webui-{{timestamp}}"
    Owner   = env("TAG_OWNER")
    Service = env("TAG_SERVICE")
    Packer  = true
  }
}

source "amazon-ebs" "example" {
  # AWS 자격증명 설정 (생략시 환경변수 또는 awscli의 default 프로필이 자동적용됨)
  // access_key = var.aws_access_key 
  // secret_key = var.aws_secret_key
  // region     = "ap-northeast-2"
  // profile    = "default" # ~/.aws/credentials에서 프로필 선택 명시

  # ami 생성을 위한 임시 인스턴스 설정
  source_ami    = var.ubuntu_22_lts.ami
  ssh_username  = var.ubuntu_22_lts.user
  instance_type = "g4dn.2xlarge" # "c5.large"
  run_tags      = var.tags

  # 결과물 ami 설정 (참고: ami_name과 ami의 tag Name은 다른 개념)
  ami_name = "ami-${var.tags.Name}"
  tags     = var.tags

  # 디스크 설정 (default 8GB라서 SD모델 포함시 크게 잡아줘야 함)
  launch_block_device_mappings { # 임시 인스턴스의 EBS
    device_name = "/dev/sda1"
    volume_size = 15 # GB 단위
  }
  ami_block_device_mappings { # 최종 결과물 ami의 EBS
    device_name = "/dev/sda1"
    volume_size = 15 # GB
  }
}

build {
  # 빌드 블록이 여러 개 있을 시 식별용 이름(이미지 이름 아님)
  name = "my-ami-builder"
  # 소스 빌더 지정
  sources = [
    # AWS AMI 생성시 일반적인 소스빌더(거의 이것만 쓴다고 생각해도 무방)  
    # EBS 볼륨기반으로 AMI를 생성 (EBS기반이 아니면 데이터 보존이 안됨)
    "source.amazon-ebs.example"
  ]

  # 이미지에 포함될 앱 설치 & 서비스 실행 등 설정
  # packer ami 빌드절차: 임시 인스턴스 실행=>프로비저닝 스크립트 실행=>임시 인스턴스 종료=>이미지 생성
  provisioner "file" {
    source      = "service"
    destination = "/tmp/service"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y git python3 python3-pip",
      "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git",
      "cd stable-diffusion-webui",
      "sudo pip3 install -r requirements.txt",
      # webui 서비스 실행
      "sudo mv /tmp/service/stable-diffusion-webui.service /etc/systemd/system/stable-diffusion-webui.service",
      "sudo systemctl enable stable-diffusion-webui.service"
    ]
  }

  provisioner "shell" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh \| bash",
      "sudo mv /tmp/service/filebrowser.service /etc/systemd/system/filebrowser.service",
      "sudo systemctl enable filebrowser.service",
      // "sudo systemctl start filebrowser.service" // ami생성시엔 start 필요없음
    ]
  }
}