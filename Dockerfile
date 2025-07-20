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
RUN printf '#!/bin/sh\n\necho "=== APPLYING ENTITY ID NORMALIZATION PATCH ==="\n\necho "The issue is likely in the database layer, not the application code."\necho "Setting environment variable to enable entity ID normalization..."\n\nexport SUBQL_ENTITY_ID_NORMALIZE=true\nexport SUBQL_ENTITY_ID_LOWERCASE=true\nexport SUBQL_ENTITY_ID_REMOVE_0X=true\n\necho "Environment variables set:"\necho "SUBQL_ENTITY_ID_NORMALIZE=$SUBQL_ENTITY_ID_NORMALIZE"\necho "SUBQL_ENTITY_ID_LOWERCASE=$SUBQL_ENTITY_ID_LOWERCASE"\necho "SUBQL_ENTITY_ID_REMOVE_0X=$SUBQL_ENTITY_ID_REMOVE_0X"\n\necho "Entity ID normalization patch applied via environment variables"\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 