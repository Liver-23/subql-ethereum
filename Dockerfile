# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# First, let's inspect the store.js file to understand its structure
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec head -20 {} \;

# Also check what the set function looks like
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec grep -n "set.*entityId" {} \;

# Create a more comprehensive patch that handles multiple patterns
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec sed -i 's/entityId\.startsWith("0x")/entityId.startsWith("0x")/g' {} \;

# Create a wrapper that applies the patch at runtime
RUN printf '#!/bin/sh\n\necho "=== APPLYING RUNTIME PATCH ==="\nSTORE_FILE="/usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js"\nif [ -f "$STORE_FILE" ]; then\n  echo "Found store.js, applying patch..."\n  sed -i "s/const id = entityId;/const id = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.substring(2) : entityId;/g" "$STORE_FILE"\n  echo "Patch applied successfully"\nelse\n  echo "Store.js not found"\nfi\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 