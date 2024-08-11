#!/bin/bash

. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="tinyllama:latest"

read -r -d '' USER_CONTENT <<- EOM
Who is James T Kirk?
EOM

USER_CONTENT=$(Sanitize "${USER_CONTENT}")

read -r -d '' DATA <<- EOM
{
  "model":"${MODEL}",
  "options": {
    "temperature": 0.5,
    "repeat_last_n": 2
  },
  "prompt": "${USER_CONTENT}",
  "stream": false
}
EOM

jsonResult=$(Generate "${OLLAMA_URL}" "${DATA}")

context=$(echo ${jsonResult} | jq -r '.context')
echo "${context}"

response=$(echo ${jsonResult} | jq -r '.response')
echo "${response}"
