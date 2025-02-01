#!/bin/bash

# This script builds the extension for distribution.
# It creates a ZIP package for publishing, a CRX package for local installation on Chrome-based browsers and an XPI package for local installation on Firefox-based browsers.
# Do note that the private key to be used should be provided in `dist/extension.pem`.
# Arguments:
# $1: The name of the extension to be built. Defaults to "enhanced-text-view".

EXTENSION_NAME=${1:-"enhanced-text-view"}
EXTENSION_DIR="/extension-pack"
SECRETS_DIR="/secrets"
OUTPUT_DIR="/dist"

NODE_PATH=node_modules/ esbuild $EXTENSION_DIR/content.js --bundle --outfile=$EXTENSION_DIR/bundle.js

if [ ! -f "$SECRETS_DIR/extension.pem" ]; then
    echo "No RSA key provided, generating in $SECRETS_DIR/extension.pem..."
    openssl genrsa -out $SECRETS_DIR/extension.pem 2048
fi

echo "Building CRX package for chromium-based browsers."
chromium --no-sandbox --pack-extension=$EXTENSION_DIR --pack-extension-key=$SECRETS_DIR/extension.pem
mv $EXTENSION_DIR.crx $OUTPUT_DIR/chrome-$EXTENSION_NAME.crx

echo "Building XPI package for firefox-based browsers."
web-ext build --source-dir=$EXTENSION_DIR --artifacts-dir=$OUTPUT_DIR --filename='firefox-{name}.zip' --overwrite-dest

echo "Build complete!"
