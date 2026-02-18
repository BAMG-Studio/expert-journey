# Git Commands Reference

## SIEM Pipeline Version Control

### Branch Strategy
```bash
# Main branches
main       # Production-ready code
develop    # Integration branch

# Feature branches
git checkout -b feature/add-waf-normalizer develop
git checkout -b fix/firehose-buffer-issue develop
```

### Daily Workflow
```bash
# Pull latest changes
git pull origin develop

# Create feature branch
git checkout -b feature/my-feature develop

# Stage and commit
git add .
git commit -m "feat(siem): add WAF log normalizer"

# Push to remote
git push -u origin feature/my-feature

# Create PR (via GitHub)
gh pr create --title "Add WAF normalizer" --base develop
```

### Commit Convention
```
feat(scope): add new feature
fix(scope): fix a bug
docs(scope): update documentation
refactor(scope): code refactoring
test(scope): add/update tests
chore(scope): maintenance tasks
```

### Useful Commands
```bash
# View commit history
git log --oneline --graph -20

# Show changes in staging
git diff --staged

# Stash work in progress
git stash
git stash pop

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Cherry-pick a specific commit
git cherry-pick abc123
```
