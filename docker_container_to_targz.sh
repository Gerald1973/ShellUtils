#!/bin/bash

# Script to create a Docker image from a running container and export it to tar.gz.
# Usage: ./script.sh <container_name_or_id>
# Parameters:
#   $1: Container name or ID (required)

# Check if container name/ID is provided
if [ -z "$1" ]; then
    echo "Error: Container name or ID is required."
    echo "Usage: $0 <container_name_or_id>"
    exit 1
fi

CONTAINER="$1"
IMAGE_NAME="image_from_$CONTAINER"
TAG="FROM$(date +%Y%m%d)"
TAR_FILE="${IMAGE_NAME}_${TAG}.tar"
GZ_FILE="${IMAGE_NAME}_${TAG}.tar.gz"

# Step 1: Verify if the container exists and is running
if ! docker ps -q -f name="$CONTAINER" | grep -q .; then
    echo "Error: Container '$CONTAINER' is not running or does not exist."
    exit 1
fi

# Step 2: Commit the container to a new image
echo "Committing container '$CONTAINER' to image '$IMAGE_NAME:$TAG'..."
docker commit "$CONTAINER" "$IMAGE_NAME:$TAG"

if [ $? -ne 0 ]; then
    echo "Error: Failed to commit the image."
    exit 1
fi

# Step 3: Export the image to TAR
echo "Exporting image to '$TAR_FILE'..."
docker save -o "$TAR_FILE" "$IMAGE_NAME:$TAG"

if [ $? -ne 0 ]; then
    echo "Error: Failed to save the image to TAR."
    exit 1
fi

# Step 4: Compress the TAR to GZ
echo "Compressing '$TAR_FILE' to '$GZ_FILE'..."
gzip "$TAR_FILE"

if [ $? -ne 0 ]; then
    echo "Error: Failed to compress the TAR file."
    exit 1
fi

# Cleanup (optional: remove the temporary image if not needed)
docker rmi "$IMAGE_NAME:$TAG"

echo "Process completed successfully. Compressed image: $GZ_FILE"