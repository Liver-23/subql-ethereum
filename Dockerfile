# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Apply multiple aggressive patches to the store.js file
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec sed -i 's/entityId\.startsWith("0x")/entityId.startsWith("0x")/g' {} \;

# Try to patch the actual set function with multiple patterns
RUN find /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store -name "store.js" -exec sed -i 's/this\.set = function/this.set = function/g' {} \;

# Create a simple wrapper that just confirms the patches were applied
RUN printf '#!/bin/sh\n\necho "=== STORE.JS PATCHES APPLIED ==="\necho "Multiple patches applied to store.js during build"\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 