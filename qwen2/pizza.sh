#!/bin/bash

. "../lib/parakeet.sh"

OLLAMA_BASE_URL=${OLLAMA_BASE_URL:-http://localhost:11434}

MODEL="qwen2:0.5b" 

read -r -d '' SYSTEM_CONTENT <<- EOM
You are a pizza maker.
EOM

SYSTEM_CONTENT=$(Sanitize "${SYSTEM_CONTENT}")

read -r -d '' USER_CONTENT <<- EOM
What is the best pizza of the world?
EOM
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

ChatStream "${OLLAMA_BASE_URL}" "${DATA}" onChunk

echo ""
