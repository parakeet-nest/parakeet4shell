#!/bin/bash

. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}
#OLLAMA_URL="http://bob.local:11434" # <--- 👋 this is my Raspberry PI

MODEL="qwen2:0.5b" 

read -r -d '' SYSTEM_CONTENT <<- EOM
You are a useful AI assistant 
EOM

read -r -d '' USER_CONTENT <<- EOM
Who are you?
EOM

SYSTEM_CONTENT=$(Sanitize "${SYSTEM_CONTENT}")
USER_CONTENT=$(Sanitize "${USER_CONTENT}")


read -r -d '' DATA <<- EOM
{
  "model":"${MODEL}",
  "options": {
    "temperature": 0.5,
    "repeat_last_n": 2
  },
  "messages": [
    {"role":"system", "content": "${SYSTEM_CONTENT}"},
    {"role":"user", "content": "${USER_CONTENT}"}
  ],
  "stream": true
}
EOM

function onChunk() {
  chunk=$1
  data=$(echo ${chunk} | jq -r '.message.content')
  echo -n "${data}"
}

ChatStream "${OLLAMA_URL}" "${DATA}" onChunk

echo ""



