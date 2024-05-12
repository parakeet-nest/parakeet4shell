#!/bin/bash
# Parakeet 🦜🪺🐚 v0.0.0 loaded!"

: <<'END_COMMENT'
Generate -Generates a response using the OLLAMA API.

 Args:
    OLLAMA_URL (str): The URL of the OLLAMA API.
    DATA (str): The JSON data to be sent to the API.

 Returns:
    str: The JSON response from the API, containing the generated response and context.
END_COMMENT
function Generate() {
    OLLAMA_URL="${1}"
    DATA="${2}"

    JSON_RESULT=$(curl --silent ${OLLAMA_URL}/api/generate \
        -H "Content-Type: application/json" \
        -d "${DATA}"
    )
    echo "${JSON_RESULT}"
}

: <<'END_COMMENT'
Sanitize - Sanitizes the given content by removing any newlines.

 Args:
    CONTENT (str): The content to be sanitized.

 Returns:
    str: The sanitized content.
END_COMMENT
function Sanitize() {
    CONTENT="${1}"
    CONTENT=$(echo ${CONTENT} | tr -d '\n')
    echo "${CONTENT}"
}

: <<'END_COMMENT'
GenerateStream - Generates a stream of data by sending a request to the specified URL with the given data.

 Args:
    OLLAMA_URL (str): The URL to send the request to.
    DATA (str): The data to send in the request body.
    CALL_BACK (function): The callback function to process each line of the response.

 Returns:
    None
END_COMMENT
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

: <<'END_COMMENT'
Chat - Generates a response using the OLLAMA API.

 Args:
    OLLAMA_URL (str): The URL of the OLLAMA API.
    DATA (str): The JSON data to be sent to the API.

 Returns:
    str: The JSON response from the API, containing the generated response and context.
END_COMMENT
function Chat() {
    OLLAMA_URL="${1}"
    DATA="${2}"

    JSON_RESULT=$(curl --silent ${OLLAMA_URL}/api/chat \
        -H "Content-Type: application/json" \
        -d "${DATA}"
    )
    echo "${JSON_RESULT}"
}

: <<'END_COMMENT'
ChatStream - Generates a response using the OLLAMA API in a streaming manner.

 Args:
   - OLLAMA_URL (str): The URL of the OLLAMA API.
   - DATA (str): The JSON data to be sent to the API.
   - CALL_BACK (function): The callback function to handle each line of the response.

 Returns:
   None
END_COMMENT
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
