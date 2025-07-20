# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a monkey patch that converts Ethereum addresses to hash-based IDs
RUN echo 'const Module = require("module"); const crypto = require("crypto"); const originalRequire = Module.prototype.require; Module.prototype.require = function(id) { const result = originalRequire.apply(this, arguments); if (id.includes("@subql/node-core") && id.includes("store")) { const originalSet = result.Store.prototype.set; result.Store.prototype.set = function(entity, entityId, fields) { let normalizedEntityId = entityId; if (typeof entityId === "string" && entityId.startsWith("0x")) { normalizedEntityId = "addr_" + crypto.createHash("sha256").update(entityId).digest("hex").substring(0, 16); } return originalSet.call(this, entity, normalizedEntityId, fields); }; } return result; }; console.log("Hash-based entity ID conversion patch applied successfully");' > /tmp/monkey-patch.js

# Create a wrapper that applies the hash-based patch
RUN printf '#!/bin/sh\n\necho "=== APPLYING HASH-BASED PATCH ==="\necho "Converting Ethereum addresses to hash-based IDs..."\nexec node --require /tmp/monkey-patch.js /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 