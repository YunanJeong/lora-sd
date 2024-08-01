#!/bin/bash
# 특정 포트의 프로세스가 정상적인 응답을 보내면 잠깐 대기하다가 종료시킴
# stable diffusion webui 설치과정 중 꼭 필요함

# 포트 번호
PORT=7859

# 정상 응답이 올 때까지 무한 루프
while true; do
  # curl 명령어로 상태 확인
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" localhost:$PORT)

  # 정상적인 응답 코드가 200인 경우
  if [ "$RESPONSE" -eq 200 ]; then
    echo "Port $PORT is active. Attempting to terminate the application."

    # 약간의 대기
    sleep 30

    # 포트에서 실행 중인 프로세스 ID 찾기
    PID=$(sudo lsof -t -i:$PORT)
    echo "targetPID: $PID"

    # 프로세스 종료
    if [ -n "$PID" ]; then
      kill -9 $PID
      echo "Application on port $PORT has been terminated."
    else
      echo "No process found on port $PORT."
    fi

    # 루프 종료
    break
  else
    echo "Port $PORT is not active or returned a non-200 response. Retrying..."
    # 10초 대기 후 다시 시도
    sleep 10
  fi
done