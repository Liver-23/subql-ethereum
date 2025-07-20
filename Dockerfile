# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Install additional tools if needed
RUN apk add --no-cache curl

# Create a patch script to fix the entity ID issue
RUN echo '#!/bin/sh\n\
# This script patches the entity ID handling to normalize Ethereum addresses\n\
# The issue is that some Ethereum addresses contain characters that PostgreSQL rejects\n\
\n\
# Create a backup of the original file\n\
cp /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js.backup\n\
\n\
# Apply the patch to normalize entity IDs\n\
sed -i "s/const id = entityId;/const id = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.toLowerCase() : entityId;/g" /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js\n\
\n\
echo "Entity ID normalization patch applied successfully"\n\
' > /usr/local/bin/patch-entity-id.sh

# Make the patch script executable
RUN chmod +x /usr/local/bin/patch-entity-id.sh

# Apply the patch when the container starts
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/patch-entity-id.sh && exec /usr/local/bin/subql-node-ethereum \"$@\""] 