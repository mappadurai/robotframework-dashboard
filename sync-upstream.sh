#!/bin/bash

# Sync script to update your fork with the original repository
# Usage: ./sync-upstream.sh

set -e

echo "🔄 Syncing fork with upstream repository..."

# Fetch the latest changes from upstream
echo "📥 Fetching latest changes from upstream..."
git fetch upstream

# Checkout your main branch
echo "🔀 Switching to main branch..."
git checkout main

# Show what changes will be merged
echo "📋 Changes to be merged:"
git log --oneline main..upstream/main

# Ask for confirmation
read -p "Do you want to merge these changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Merge upstream changes
    echo "🔗 Merging upstream changes..."
    git merge upstream/main
    
    # Push to your fork
    echo "📤 Pushing updates to your fork..."
    git push origin main
    
    echo "✅ Successfully synced with upstream!"
else
    echo "❌ Sync cancelled"
fi
