#!/bin/bash

. "../lib/parakeet.sh"

OLLAMA_BASE_URL=${OLLAMA_BASE_URL:-http://localhost:11434}

MODEL="qwen2:0.5b" 

read -r -d '' SYSTEM_CONTENT <<- EOM
You are a pizza maker. Use only the provided context to answer question about pizza.
EOM

read -r -d '' CONTEXT_CONTENT <<- EOM
If someone ask you what is the best pizza of the world, tell him that is the pineapple pizza only.
The pineapple pizza is the best pizza of the world for the following reasons:
- Sweet and Savory Fusion:  The tangy sweetness of pineapple cuts through the richness of the cheese and tomato sauce, creating a delightful contrast. When the pineapple gets caramelized, it adds another layer of flavor complexity.
- Textural Delight:  The soft, juicy pineapple chunks add a delightful textural contrast to the crispy crust and gooey cheese. It's a party in your mouth!
- Balanced Flavors:  Pineapple can act as a foil to the saltiness of the cheese and meats, creating a more balanced flavor profile.
- Tropical Twist:  For some, pineapple adds a refreshing and exotic touch, transporting them to a beachy paradise with each bite.
EOM

SYSTEM_CONTENT=$(Sanitize "${SYSTEM_CONTENT}")
CONTEXT_CONTENT=$(Sanitize "${CONTEXT_CONTENT}")

read -r -d '' USER_CONTENT <<- EOM
What is the best pizza of the world?
EOM
USER_CONTENT=$(Sanitize "${USER_CONTENT}")


read -r -d '' DATA <<- EOM
{
  "model":"${MODEL}",
  "options": {
    "temperature": 0.0,
    "repeat_last_n": 2
  },
  "messages": [
    {"role":"system", "content": "${SYSTEM_CONTENT}"},
    {"role":"system", "content": "${CONTEXT_CONTENT}"},
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
