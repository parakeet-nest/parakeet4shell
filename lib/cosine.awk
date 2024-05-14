function dot_product(v1, v2) {
    sum = 0.0

    for (key in v1) { 
        sum = sum + v1[key] * v2[key]
    }
    return sum
}

function cosine_distance(json_v1, json_v2) {
    gsub(/^\[|\]$/, "", json_v1)    # Remove brackets from the beginning and end
    split(json_v1, v1, ",")         # Split the string on commas

    gsub(/^\[|\]$/, "", json_v2)    # Remove brackets from the beginning and end
    split(json_v2, v2, ",")         # Split the string on commas

    # Calculate the cosine distance between two vectors
    product = dot_product(v1, v2)

	norm1 = sqrt(dot_product(v1, v1))
	norm2 = sqrt(dot_product(v2, v2))

    result = 0.0
    if (norm1 <= 0.0 || norm2 <= 0.0) {
        # Handle potential division by zero
        result = 0.0
    } else {
        result = product / (norm1 * norm2)
    }
    return result
}

BEGIN {
    distance = cosine_distance(vector_1, vector_2)
    #print "cosine_distance:", distance
    print distance

}

