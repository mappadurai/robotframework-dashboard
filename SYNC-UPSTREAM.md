# Manual Sync Commands for Robot Framework Dashboard Fork

## Check for upstream updates
```bash
git fetch upstream
git log --oneline main..upstream/main
```

## Simple merge (when no conflicts)
```bash
git checkout main
git merge upstream/main
git push origin main
```

## Rebase your changes on top of upstream (alternative)
```bash
git checkout main
git rebase upstream/main
git push origin main --force-with-lease
```

## Handle conflicts manually
```bash
# If conflicts occur during merge:
git merge upstream/main
# Edit conflicted files manually
git add .
git commit -m "Resolve merge conflicts with upstream"
git push origin main
```

## Create a new branch for testing upstream changes
```bash
git fetch upstream
git checkout -b test-upstream-sync upstream/main
# Test the changes
# If good, merge back to main:
git checkout main
git merge test-upstream-sync
git push origin main
```

## Reset your fork to match upstream exactly (DESTRUCTIVE)
```bash
git fetch upstream
git checkout main
git reset --hard upstream/main
git push origin main --force
```

## Check what files changed between your fork and upstream
```bash
git fetch upstream
git diff main upstream/main --name-only
```
