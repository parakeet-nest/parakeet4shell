#!/bin/bash

. "../lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="tinyllama"

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
  "stream": true
}
EOM

# A function that handles a chunk of data received from a stream.
#
# Parameters:
#   - $1: The chunk of data received from the stream.
#
# Returns:
#   - The extracted response from the chunk, without a newline character.
function onChunk() {
  chunk=$1
  data=$(echo ${chunk} | jq -r '.response')
  echo -n "${data}"
}

# For tests
function onJsonChunk() {
  chunk=$1
  echo ${chunk} | jq -c '{ response, context }'
}

GenerateStream "${OLLAMA_URL}" "${DATA}" onChunk




