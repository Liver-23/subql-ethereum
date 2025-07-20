# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# First, let's find where the store.js file is located
RUN find /usr -name "store.js" 2>/dev/null | grep -i subql || echo "No store.js found in /usr"

# Also check in node_modules
RUN find /usr/local -name "store.js" 2>/dev/null | grep -i subql || echo "No store.js found in /usr/local"

# Check what's in the node_modules directory
RUN ls -la /usr/local/lib/node_modules/ || echo "No node_modules in /usr/local/lib"

# Create a simple wrapper for now
RUN printf '#!/bin/sh\n\necho "=== DEBUGGING STORE.JS LOCATION ==="\necho "Checking for store.js files..."\nexec /usr/local/bin/subql-node-ethereum "$@"\n' > /tmp/subql-node-ethereum-wrapper && chmod +x /tmp/subql-node-ethereum-wrapper

# Use the wrapper as the entrypoint
ENTRYPOINT ["/tmp/subql-node-ethereum-wrapper"] 