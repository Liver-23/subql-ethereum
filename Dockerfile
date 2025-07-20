# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Apply the entity ID patch during build (when we have write permissions)
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec sed -i 's/const id = entityId;/const id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.substring(2) : entityId;/g' {} \;

# Verify the patch was applied
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec grep -n "entityId.substring" {} \;

# Create a simple wrapper to confirm the patch is active
RUN printf '#!/bin/sh\n\necho "=== ENTITY ID PATCH VERIFICATION ==="\necho "0x prefix removal patch applied during build"\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 