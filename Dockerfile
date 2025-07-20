# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Find and patch the store.js file to normalize entity IDs
RUN find /usr/local/lib/node_modules/@subql/node-core -name "store.js" -exec sed -i 's/this\.set = function (entity, entityId, fields) {/this.set = function (entity, entityId, fields) { const normalizedEntityId = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.toLowerCase() : entityId; entityId = normalizedEntityId;/g' {} \;

# Create a simple wrapper to show the patch was applied
RUN printf '#!/bin/sh\n\necho "=== ENTITY ID NORMALIZATION PATCH APPLIED ==="\necho "Store.js has been patched to normalize Ethereum addresses"\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 