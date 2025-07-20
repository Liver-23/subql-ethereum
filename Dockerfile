# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a Node.js monkey patch script that overrides the Store.set method
RUN echo 'const Module = require("module"); const originalRequire = Module.prototype.require; Module.prototype.require = function(id) { const result = originalRequire.apply(this, arguments); if (id.includes("@subql/node-core") && id.includes("store")) { const originalSet = result.Store.prototype.set; result.Store.prototype.set = function(entity, entityId, fields) { const normalizedEntityId = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.substring(2) : entityId; return originalSet.call(this, entity, normalizedEntityId, fields); }; } return result; }; console.log("Entity ID normalization monkey patch applied successfully");' > /tmp/monkey-patch.js

# Create a wrapper that preloads the monkey patch
RUN printf '#!/bin/sh\n\necho "=== APPLYING MONKEY PATCH ==="\necho "Preloading entity ID normalization patch..."\nexec node --require /tmp/monkey-patch.js /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 