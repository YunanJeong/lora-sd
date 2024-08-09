# lora-sd

LoRA(Low Rank Adaptation), Stable-Diffusion(Model), Packer
주문형 생성 AI(On-demand Generative AI)를 위한 이미지

## 소스 이미지

- ubuntu24_lts: 용량 점유 적음
- ubuntu22_gpu: nvidia driver, cuda, python, docker 등 사전설치된 것들이 많아 세팅이 쉬움. 버전이 좀 오래됨

```hcl
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
```


## 참고 사이트

https://civitai.com/

