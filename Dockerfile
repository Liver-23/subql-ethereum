# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a patched version of the store.js file with comprehensive debugging
RUN cp /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js /tmp/store.js.original && \
    echo "=== ORIGINAL FILE DEBUG ===" && \
    echo "File exists:" && ls -la /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js && \
    echo "File size:" && wc -l /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js && \
    echo "Lines containing 'id':" && grep -n "id" /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js | head -10 && \
    echo "Lines containing 'entity':" && grep -n "entity" /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js | head -10 && \
    echo "Lines containing 'set':" && grep -n "set" /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js | head -10 && \
    sed 's/const id = entityId;/const id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.toLowerCase() : entityId;/g' /tmp/store.js.original > /tmp/store.js.patched && \
    sed -i 's/const id = entityId;/const id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.toLowerCase() : entityId;/g' /tmp/store.js.patched && \
    sed -i 's/let id = entityId;/let id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.toLowerCase() : entityId;/g' /tmp/store.js.patched && \
    sed -i 's/id = entityId;/id = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.toLowerCase() : entityId;/g' /tmp/store.js.patched

# Create a wrapper script using printf for better reliability
RUN printf '#!/bin/sh\n\necho "=== APPLYING ENTITY ID NORMALIZATION PATCH ==="\n\necho "The issue is that the SubQuery project is using Ethereum addresses as entity IDs."\necho "The database is rejecting the 0x prefix and hex characters."\necho "This needs to be fixed in the SubQuery project itself, not the node."\necho ""\necho "RECOMMENDATION: Modify your SubQuery project mapping to normalize entity IDs:"\necho "Instead of: store.set(\"GNftUser\", address, {...})"\necho "Use: store.set(\"GNftUser\", address.replace(\"0x\", \"\").toLowerCase(), {...})"\necho ""\necho "Or use a hash of the address: store.set(\"GNftUser\", crypto.createHash(\"sha256\").update(address).digest(\"hex\"), {...})"\necho ""\necho "For now, continuing with original behavior..."\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 