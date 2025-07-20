# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a patch script to fix the entity ID issue
RUN echo '#!/bin/sh\n\
# This script patches the entity ID handling to normalize Ethereum addresses\n\
# The issue is that some Ethereum addresses contain characters that PostgreSQL rejects\n\
\n\
echo "Applying entity ID normalization patch..."\n\
\n\
# Find the store.js file\n\
STORE_FILE="/usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js"\n\
\n\
if [ ! -f "$STORE_FILE" ]; then\n\
    echo "Error: Store file not found at $STORE_FILE"\n\
    exit 1\n\
fi\n\
\n\
# Create backup\n\
cp "$STORE_FILE" "$STORE_FILE.backup"\n\
\n\
# Apply the patch to normalize entity IDs\n\
sed -i "s/const id = entityId;/const id = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.toLowerCase() : entityId;/g" "$STORE_FILE"\n\
\n\
echo "Entity ID normalization patch applied successfully"\n\
echo "Backup created at $STORE_FILE.backup"\n\
' > /usr/local/bin/patch-entity-id.sh

# Make the patch script executable
RUN chmod +x /usr/local/bin/patch-entity-id.sh

# Apply the patch when the container starts
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/patch-entity-id.sh && exec /usr/local/bin/subql-node-ethereum \"$@\""] 