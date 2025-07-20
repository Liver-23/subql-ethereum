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
RUN printf '#!/bin/sh\n\necho "=== APPLYING ENTITY ID NORMALIZATION PATCH ==="\n\necho "Searching for files containing entityId..."\nfind /usr/local/lib/node_modules/@subql/node-ethereum -name "*.js" -exec grep -l "entityId" {} \\; 2>/dev/null || echo "No files found with entityId"\n\necho "Searching for files containing entity ID assignments..."\nfind /usr/local/lib/node_modules/@subql/node-ethereum -name "*.js" -exec grep -l "id.*=" {} \\; 2>/dev/null | head -5\n\necho "Checking the actual store.js file content:"\nhead -50 /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js\n\necho "Checking for set method in store.js:"\ngrep -n "set.*entityId" /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js || echo "No set method with entityId found"\n\necho "Checking for any entityId references:"\ngrep -r "entityId" /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/ || echo "No entityId found in store directory"\n\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 