# Use the official SubQuery Ethereum node as base
FROM subquerynetwork/subql-node-ethereum:v6.1.1

# Install additional tools
RUN apk add --no-cache curl

# Create a more robust patch script
RUN echo '#!/bin/sh\n\
# Enhanced entity ID normalization script\n\
\n\
echo "Applying entity ID normalization patch..."\n\
\n\
# Find the store.js file\n\
STORE_FILE="/usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js"\n\
\n\
if [ ! -f "$STORE_FILE" ]; then\n\
    echo "Error: Store file not found at $STORE_FILE"\n\
    exit 1\n\
fi\n\
\n\
# Create backup\n\
cp "$STORE_FILE" "$STORE_FILE.backup"\n\
\n\
# Apply multiple patches for different scenarios\n\
\n\
# Patch 1: Normalize hex strings starting with 0x\n\
sed -i "s/const id = entityId;/const id = typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.toLowerCase() : entityId;/g" "$STORE_FILE"\n\
\n\
# Patch 2: Handle potential null/undefined entityId\n\
sed -i "s/const id = entityId;/const id = entityId && typeof entityId === \"string\" && entityId.startsWith(\"0x\") ? entityId.toLowerCase() : entityId;/g" "$STORE_FILE"\n\
\n\
# Patch 3: Additional safety check\n\
sed -i "s/if (!id) throw new Error(/if (!id || (typeof id === \"string\" && !/^[a-zA-Z0-9_-]+$/.test(id))) throw new Error(/g" "$STORE_FILE"\n\
\n\
echo "Entity ID normalization patches applied successfully"\n\
echo "Backup created at $STORE_FILE.backup"\n\
' > /usr/local/bin/patch-entity-id.sh

# Make the patch script executable
RUN chmod +x /usr/local/bin/patch-entity-id.sh

# Apply the patch when the container starts
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/patch-entity-id.sh && exec /usr/local/bin/subql-node-ethereum \"$@\""] 