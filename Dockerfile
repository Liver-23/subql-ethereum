# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a wrapper script in a writable location
RUN echo '#!/bin/sh\n\
# Wrapper script that applies entity ID patch and then runs the original command\n\
\n\
echo "Applying entity ID normalization patch..."\n\
\n\
# Find the store.js file\n\
STORE_FILE="/usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js"\n\
\n\
if [ -f "$STORE_FILE" ]; then\n\
    # Create backup in a writable location\n\
    cp "$STORE_FILE" "/tmp/store.js.backup"\n\
    \n\
    # Apply the patch to normalize entity IDs\n\
    sed -i "s/const id = entityId;/const id = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.toLowerCase() : entityId;/g" "$STORE_FILE"\n\
    \n\
    echo "Entity ID normalization patch applied successfully"\n\
    echo "Backup created at /tmp/store.js.backup"\n\
else\n\
    echo "Warning: Store file not found, patch not applied"\n\
fi\n\
\n\
# Execute the original command with all arguments\n\
exec /usr/local/bin/subql-node-ethereum "$@"\n\
' > /tmp/subql-node-ethereum-wrapper

# Make the wrapper script executable
RUN chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 