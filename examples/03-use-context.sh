#!/bin/bash

. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="tinyllama"

read -r -d '' USER_CONTENT <<- EOM
[Brief] Who is James T Kirk?
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
  "stream": true
}
EOM

function onChunk() {
  chunk=$1
  data=$(echo ${chunk} | jq -r '.response')
  echo -n "${data}"
  
  # Save context at the end of the stream
  if [ -z "$data" ]; then
    context=$(echo ${chunk} | jq -r '.context')
    echo "${context}" > context.save
  fi
  
}

GenerateStream "${OLLAMA_URL}" "${DATA}" onChunk

echo ""
echo ""

# New question
read -r -d '' USER_CONTENT <<- EOM
Who is his best friend?
EOM

USER_CONTENT=$(Sanitize "${USER_CONTENT}")
CONTEXT=$(cat context.save)

read -r -d '' DATA <<- EOM
{
  "model":"${MODEL}",
  "options": {
    "temperature": 0.5,
    "repeat_last_n": 2
  },
  "prompt": "${USER_CONTENT}",
  "stream": true,
  "context": ${CONTEXT}
}
EOM

GenerateStream "${OLLAMA_URL}" "${DATA}" onChunk
