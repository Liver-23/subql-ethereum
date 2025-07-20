# SubQuery Ethereum Node Entity ID Fix

This repository contains a fix for the "Invalid character" error that occurs when using Ethereum addresses as entity IDs in SubQuery projects.

## Problem
The error occurs because PostgreSQL rejects certain characters in entity IDs when they contain hex strings with `0x` prefix, such as Ethereum addresses like `0x88d0b1b3ad75fe4f03fa30f8647653bb89c086d3`.

## Solution
We create a custom Docker image that patches the SubQuery node-core store.js file to normalize entity IDs before storing them in the database.

## Steps to Implement

### 1. Choose Your Registry
Decide where you'll host your custom image:
- **Docker Hub**: `yourusername/subql-node-ethereum-fixed`
- **AWS ECR**: `your-account.dkr.ecr.region.amazonaws.com/subql-node-ethereum-fixed`
- **Google Container Registry**: `gcr.io/your-project/subql-node-ethereum-fixed`
- **Azure Container Registry**: `yourregistry.azurecr.io/subql-node-ethereum-fixed`

### 2. Update Configuration
Edit `build-and-push.sh` and replace:
- `your-registry.com` with your actual registry
- `your-registry` with your registry path

### 3. Build and Push
```bash
# Make the script executable
chmod +x build-and-push.sh

# Run the build and push script
./build-and-push.sh
```

### 4. Update Docker Compose
Edit `docker-compose-fixed.yml` and replace:
- `your-registry.com/your-registry/subql-node-ethereum-fixed:v6.1.1-fixed` with your actual image path

### 5. Deploy
```bash
# Stop the current containers
docker-compose down

# Start with the fixed image
docker-compose -f docker-compose-fixed.yml up -d
```

## How the Fix Works

The fix applies a patch to the `store.js` file that:

1. **Normalizes Ethereum addresses**: Converts addresses starting with `0x` to lowercase
2. **Handles edge cases**: Checks for null/undefined entityId values
3. **Adds safety checks**: Validates entity ID format before database operations

## Alternative Approaches

### Option 1: Use Dockerfile.env (More Robust)
The `Dockerfile.env` provides a more comprehensive fix with multiple patches for different scenarios.

### Option 2: Environment Variable Control
You can add environment variables to control the fix behavior:
```yaml
environment:
  SUBQL_ENTITY_ID_FIX: "true"
  SUBQL_ENTITY_ID_NORMALIZE: "lowercase"  # or "remove_prefix"
```

## Testing the Fix

1. **Monitor logs**: Check if the patch is applied successfully
2. **Verify indexing**: Ensure blocks that previously failed now index correctly
3. **Check database**: Verify that entity IDs are stored in the expected format

## Rollback Plan

If issues occur, you can:
1. Revert to the original image: `subquerynetwork/subql-node-ethereum:v6.1.1`
2. Restore from backup: The patch creates a backup of the original file
3. Use the backup file: `store.js.backup`

## Troubleshooting

### Common Issues:
1. **Registry authentication**: Ensure you're logged in to your registry
2. **Image not found**: Verify the image path in docker-compose
3. **Patch not applied**: Check container logs for patch application messages

### Debug Commands:
```bash
# Check if patch was applied
docker exec node_qmnihsztax8nb1l grep -n "entityId.toLowerCase" /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/store.js

# View container logs
docker logs node_qmnihsztax8nb1l

# Check backup file
docker exec node_qmnihsztax8nb1l ls -la /usr/local/lib/node_modules/@subql/node-ethereum/node_modules/@subql/node-core/dist/indexer/store/
```

## Support

If you encounter issues:
1. Check the container logs for error messages
2. Verify the patch was applied correctly
3. Consider using the more robust `Dockerfile.env` approach
4. Ensure your registry credentials are correct 