#!/bin/bash
# 특정 포트의 프로세스(webui.sh)가 정상적인 응답을 보내면 잠깐 대기하다가 종료시킴
# stable diffusion webui 설치과정 중 꼭 필요함

# 포트 번호
PORT=7859
MAX_RETRIES=60
RETRY_COUNT=0

# 무한 루프
while true; do
  # curl 명령어로 상태 확인
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" localhost:$PORT)

  # 정상적인 응답 코드가 200인 경우 break
  if [ "$RESPONSE" -eq 200 ]; then
    echo "Port $PORT is active. Attempting to terminate the application."
    sleep 30
    break
  fi

  # 최대 재시도 횟수에 도달한 경우 break
  if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
    echo "Maximum retry attempts reached. Attempting to terminate the application and Exiting..."
    break
  fi

  # 10초 대기 후 다음 재시도
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "Port $PORT is not active or returned a non-200 response. Retrying ($RETRY_COUNT)..."
  sleep 10
  
done

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