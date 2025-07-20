# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a patched version of the store.js file
RUN cp /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js /tmp/store.js.original && \
    sed 's/const id = entityId;/const id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.toLowerCase() : entityId;/g' /tmp/store.js.original > /tmp/store.js.patched

# Create a wrapper script that replaces the original file with our patched version
RUN echo '#!/bin/sh\n\n# Wrapper script that applies entity ID patch and then runs the original command\n\necho "Applying entity ID normalization patch..."\n\n# Replace the original store.js with our patched version\ncp /tmp/store.js.patched /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js\n\necho "Entity ID normalization patch applied successfully"\necho "Original file backed up at /tmp/store.js.original"\n\n# Execute the original command with all arguments\nexec "$@"' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 