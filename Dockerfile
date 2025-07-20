# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a Node.js script that will intercept and normalize entity IDs
RUN echo 'const fs = require("fs"); const path = require("path"); const storePath = "/usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js"; const originalContent = fs.readFileSync(storePath, "utf8"); const patchedContent = originalContent.replace(/async set\(entity, entityId, fields\) {/g, "async set(entity, entityId, fields) { const normalizedEntityId = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.toLowerCase() : entityId;"); const setMethodRegex = /async set\(entity, entityId, fields\) \{[\s\S]*?\}/g; const patchedSetMethod = originalContent.replace(setMethodRegex, (match) => { return match.replace(/entityId/g, "normalizedEntityId"); }); fs.writeFileSync(storePath, patchedSetMethod); console.log("Entity ID normalization patch applied successfully");' > /tmp/patch-entity-id.js

# Create a wrapper script using printf for better reliability
RUN printf '#!/bin/sh\n\necho "=== APPLYING ENTITY ID NORMALIZATION PATCH ==="\n\necho "Running Node.js patch script..."\nnode /tmp/patch-entity-id.js\n\necho "Entity ID normalization patch applied successfully"\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 