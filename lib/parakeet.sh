#!/bin/bash
# Parakeet 🦜🪺🐚 v0.0.0 loaded!"

: <<'COMMENT'
Generate -Generates a response using the OLLAMA API.

 Args:
    OLLAMA_URL (str): The URL of the OLLAMA API.
    DATA (str): The JSON data to be sent to the API.

 Returns:
    str: The JSON response from the API, containing the generated response and context.
COMMENT
function Generate() {
    OLLAMA_URL="${1}"
    DATA="${2}"

    JSON_RESULT=$(curl --silent ${OLLAMA_URL}/api/generate \
        -H "Content-Type: application/json" \
        -d "${DATA}"
    )
    echo "${JSON_RESULT}"
}

: <<'COMMENT'
Sanitize - Sanitizes the given content by removing any newlines.

 Args:
    CONTENT (str): The content to be sanitized.

 Returns:
    str: The sanitized content.
COMMENT
function Sanitize() {
    CONTENT="${1}"
    CONTENT=$(echo ${CONTENT} | tr -d '\n')
    echo "${CONTENT}"
}

: <<'COMMENT'
GenerateStream - Generates a stream of data by sending a request to the specified URL with the given data.

 Args:
    OLLAMA_URL (str): The URL to send the request to.
    DATA (str): The data to send in the request body.
    CALL_BACK (function): The callback function to process each line of the response.

 Returns:
    None
COMMENT
function GenerateStream() {
    OLLAMA_URL="${1}"
    DATA="${2}"
    CALL_BACK=${3}

    curl --no-buffer --silent ${OLLAMA_URL}/api/generate \
        -H "Content-Type: application/json" \
        -d "${DATA}" | while read linestream
        do
            ${CALL_BACK} "${linestream}"
        done 

}

: <<'COMMENT'
Chat - Generates a response using the OLLAMA API.

 Args:
    OLLAMA_URL (str): The URL of the OLLAMA API.
    DATA (str): The JSON data to be sent to the API.

 Returns:
    str: The JSON response from the API, containing the generated response and context.
COMMENT
function Chat() {
    OLLAMA_URL="${1}"
    DATA="${2}"

    JSON_RESULT=$(curl --silent ${OLLAMA_URL}/api/chat \
        -H "Content-Type: application/json" \
        -d "${DATA}"
    )
    echo "${JSON_RESULT}"
}

: <<'COMMENT'
ChatStream - Generates a response using the OLLAMA API in a streaming manner.

 Args:
   - OLLAMA_URL (str): The URL of the OLLAMA API.
   - DATA (str): The JSON data to be sent to the API.
   - CALL_BACK (function): The callback function to handle each line of the response.

 Returns:
   None
COMMENT
function ChatStream() {
    OLLAMA_URL="${1}"
    DATA="${2}"
    CALL_BACK=${3}

    curl --no-buffer --silent ${OLLAMA_URL}/api/chat \
        -H "Content-Type: application/json" \
        -d "${DATA}" | while read linestream
        do
            ${CALL_BACK} "${linestream}"
        done 
}

: <<'COMMENT'
--------------
  Embeddings
--------------
🚧 work in progress
- use the Ollama API to generate embeddings
- function for the cosine distance with awk
- first iteration with in memory vectore store
- add helpers to simplify the code
COMMENT
function CreateEmbedding() {
    OLLAMA_URL="${1}"
    DATA="${2}"
    ID="${3}"
    # --silent
    JSON_RESULT=$(curl --silent ${OLLAMA_URL}/api/embeddings \
        -H "Content-Type: application/json" \
        -d "${DATA}"
    )
    echo "${JSON_RESULT}"    
}

function TrimDoubleQuotes() {
    messageContent="${1}"
    # remove double quotes at the start and the end of the string
    content="${messageContent%\"}"
    content="${content#\"}"

    echo "$content"

} 

function PrettyPrint() {
    content="${1}"
    # The -e option in the echo command enables the interpretation of escape sequences in the string to be displayed.
    # sed 's/\\"/"/g' removes all the \ from the \"
    echo -e "${content}" | sed 's/\\"/"/g'
}