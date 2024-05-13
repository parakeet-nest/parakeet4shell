# Parakeet4Shell

🦜🪺🐚 **Parakeet4Shell** is a set of scripts, made to simplify the development of small **Bash** generative AI applications with **Ollama** 🦙.

## Requirements

- Linux (right now, it's just tested on Ubuntu but it should work on MacOS - 🚧 wip)
- jq (https://stedolan.github.io/jq/) - optional but useful
- curl (https://curl.se/)

## How to use

Add this at the beginning of your script:

```bash {"id":"01HXRFEAZ479XHVVEMNH6E5KV9"}
. "./lib/parakeet.sh"
```

> Let's have a look to the `example` folder.

### Chat completion without streaming

```bash {"id":"01HXRFEAZ479XHVVEMNMP4QXZA"}
#!/bin/bash
. "./lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="tinyllama"

read -r -d '' SYSTEM_CONTENT <<- EOM
You are an expert of the StarTrek universe. 
Your name is Seven of Nine.
Speak like a Borg.
EOM

read -r -d '' USER_CONTENT <<- EOM
Who is Jean-Luc Picard?
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
  "stream": false,
  "raw": false
}
EOM

jsonResult=$(Chat "${OLLAMA_URL}" "${DATA}")

messageContent=$(echo "${jsonResult}" | jq '.message.content')

echo "${messageContent}" 
```

### Chat completion with streaming

```bash {"id":"01HXRFEAZ479XHVVEMNNMQTRJG"}
#!/bin/bash
. "./lib/parakeet.sh"

OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434}

MODEL="tinyllama"

# System instructions
read -r -d '' SYSTEM_CONTENT <<- EOM
You are an expert of the StarTrek universe. 
Your name is Seven of Nine.
Speak like a Borg.
EOM

# User message
read -r -d '' USER_CONTENT <<- EOM
Who is Jean-Luc Picard?
EOM

SYSTEM_CONTENT=$(Sanitize "${SYSTEM_CONTENT}")
USER_CONTENT=$(Sanitize "${USER_CONTENT}")

# Payload to send to Ollama
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

# This function will be called for each chunk of the response
function onChunk() {
  chunk=$1
  data=$(echo ${chunk} | jq -r '.message.content')
  echo -n "${data}"
}

ChatStream "${OLLAMA_URL}" "${DATA}" onChunk
```

## Acknowledgments:

- Thanks to [Sylvain](https://github.com/swallez) for the discussion on curl callbacks.
- Thanks to [Gemini](https://gemini.google.com/app) for all the discussions on Bash.
