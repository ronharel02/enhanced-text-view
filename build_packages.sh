#!/bin/bash

# This script builds the extension for distribution.
# It creates a CRX package for local installation on Chrome-based browsers and an XPI package for local installation on Firefox-based browsers.
# The /secrets directory is expected to contain a few files:
# - `amo.env` which should contain `AMO_JWT_ISSUER` and `AMO_JWT_SECRET`.
# - `extension.pem` a private key to be used when building for chrome.
# Usage:
# --publish, Builds both packages and publishes the Firefox extension to AMO.
# --name <name>, Sets the extension name (defaults to the name in the manifest).

EXTENSION_DIR="/extension-pack"
SECRETS_DIR="/secrets"
OUTPUT_DIR="/dist"
EXTENSION_NAME=$(jq --raw-output ".name" $EXTENSION_DIR/manifest.json | sed -e 's/\(.*\)/\L\1/' -e 's/ /-/g')

PUBLISH=false

# Parse arguments.
while [[ $# -gt 0 ]]; do
    case "$1" in
        --publish)
            PUBLISH=true
            shift
            ;;
        --name)
            if [[ "$2" =~ ^[^-][A-Za-z0-9_-]+$ ]]; then
                EXTENSION_NAME="$2"
                shift 2
            else
                echo "Error: --name requires a valid argument."
                exit 1
            fi
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

echo "Bundling extension..."
NODE_PATH=node_modules/ esbuild "$EXTENSION_DIR/content.js" --bundle --outfile="$EXTENSION_DIR/bundle.js"

if [ ! -f "$SECRETS_DIR/extension.pem" ]; then
    echo "No RSA key provided, generating one in $SECRETS_DIR/extension.pem..."
    openssl genrsa -out "$SECRETS_DIR/extension.pem" 2048
fi

echo "Building CRX package for chromium-based browsers."
chromium --no-sandbox --pack-extension=$EXTENSION_DIR --pack-extension-key="$SECRETS_DIR/extension.pem"
mv "$EXTENSION_DIR.crx" "$OUTPUT_DIR/$EXTENSION_NAME.crx"

if ! $PUBLISH; then
    echo "Building XPI package for firefox-based browsers."
    web-ext build --source-dir=$EXTENSION_DIR --artifacts-dir=$OUTPUT_DIR --filename="$EXTENSION_NAME.xpi" --overwrite-dest
else
    echo "Signing and publishing firefox extension to AMO."
    source "$SECRETS_DIR/amo.env"
    web-ext sign                                          \
        --no-input                                        \
        --amo-metadata "$EXTENSION_DIR/amo-metadata.json" \
        --upload-source-code                              \
        --source-dir=$EXTENSION_DIR                       \
        --artifacts-dir=$OUTPUT_DIR                       \
        --api-key=$AMO_JWT_ISSUER                         \
        --api-secret=$AMO_JWT_SECRET                      \
        --channel listed
    mv "$OUTPUT_DIR/*.xpi" "$OUTPUT_DIR/$EXTENSION_NAME.xpi"
fi

echo "Operation complete!"
