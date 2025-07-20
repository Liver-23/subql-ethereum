#!/bin/sh

# Wrapper script that applies entity ID patch and then runs the original command

echo "Applying entity ID normalization patch..."

# Find the store.js file
STORE_FILE="/usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js"

if [ -f "$STORE_FILE" ]; then
    # Create backup in a writable location
    cp "$STORE_FILE" "/tmp/store.js.backup"
    
    # Apply the patch to normalize entity IDs
    sed -i "s/const id = entityId;/const id = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.toLowerCase() : entityId;/g" "$STORE_FILE"
    
    echo "Entity ID normalization patch applied successfully"
    echo "Backup created at /tmp/store.js.backup"
else
    echo "Warning: Store file not found, patch not applied"
fi

# Execute the original command with all arguments
exec /usr/local/bin/subql-node-ethereum "$@" 