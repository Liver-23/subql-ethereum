# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Find and patch the store.js file to remove 0x prefix from entity IDs
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec sed -i 's/const id = entityId;/const id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.substring(2) : entityId;/g' {} \;

# Create a simple wrapper to show the patch was applied
RUN printf '#!/bin/sh\n\necho "=== ENTITY ID PATCH APPLIED ==="\necho "0x prefix removed from entity IDs for PostgreSQL compatibility"\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 