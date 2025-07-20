# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Apply the entity ID patch during build (when we have write permissions)
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec sed -i 's/const id = entityId;/const id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.substring(2) : entityId;/g' {} \;

# Also try alternative patterns in case the first one doesn't match
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec sed -i 's/entityId\.startsWith("0x")/entityId.startsWith("0x")/g' {} \;

# Create a pre-startup wrapper that applies patch before SubQuery starts
RUN printf '#!/bin/sh\n\necho "=== APPLYING PRE-STARTUP PATCH ==="\nSTORE_FILE="/usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js"\nif [ -f "$STORE_FILE" ]; then\n  echo "Applying entity ID patch before SubQuery starts..."\n  sed -i "s/const id = entityId;/const id = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.substring(2) : entityId;/g" "$STORE_FILE"\n  echo "Pre-startup patch applied successfully"\nelse\n  echo "Store.js not found for pre-startup patch"\nfi\necho "Starting SubQuery with entity ID patch active..."\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 