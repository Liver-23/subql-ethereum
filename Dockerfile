# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Create a Node.js script that uses monkey patching to override the store module
RUN echo 'const fs = require("fs"); const path = require("path"); const Module = require("module"); const originalRequire = Module.prototype.require; Module.prototype.require = function(id) { const result = originalRequire.apply(this, arguments); if (id.includes("@subql/node-core") && id.includes("store")) { const originalSet = result.Store.prototype.set; result.Store.prototype.set = function(entity, entityId, fields) { const normalizedEntityId = typeof entityId === "string" && entityId.startsWith("0x") ? entityId.toLowerCase() : entityId; return originalSet.call(this, entity, normalizedEntityId, fields); }; } return result; }; console.log("Entity ID normalization monkey patch applied successfully");' > /tmp/monkey-patch.js

# Create a wrapper script using printf for better reliability
RUN printf '#!/bin/sh\n\necho "=== APPLYING ENTITY ID NORMALIZATION PATCH ==="\n\necho "Running Node.js monkey patch script..."\nnode -e "require(\"/tmp/monkey-patch.js\")"\necho "Entity ID normalization patch applied successfully"\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 