# Branch-based Semantic Versioning

This project uses **branch names** to automatically determine semantic version bumps, making the workflow simpler and more intuitive.

## Branch Naming Convention

| Branch Prefix | Description | Version Bump | Example |
|---------------|-------------|--------------|---------|
| `feat/` | New features | **MINOR** (0.1.0 → 0.2.0) | `feat/clickhouse-integration` |
| `fix/` | Bug fixes | **PATCH** (0.1.0 → 0.1.1) | `fix/postgres-connection-timeout` |
| `hotfix/` | Critical bug fixes | **PATCH** (0.1.0 → 0.1.1) | `hotfix/security-vulnerability` |
| `breaking/` | Breaking changes | **MAJOR** (0.1.0 → 1.0.0) | `breaking/api-v2-migration` |
| `major/` | Major changes | **MAJOR** (0.1.0 → 1.0.0) | `major/architecture-refactor` |
| `docs/` | Documentation updates | **PATCH** (0.1.0 → 0.1.1) | `docs/update-readme` |
| `*` | Other changes | **PATCH** (0.1.0 → 0.1.1) | `refactor/cleanup-spark-job` |

## Workflow Examples

### 1. Adding a New Feature
```bash
# Create feature branch
git checkout -b feat/metabase-dashboard-integration

# Make your changes
# ... code changes ...

# Commit your work (any commit message format)
git add .
git commit -m "Add Metabase integration with PostgreSQL and ClickHouse"

# Push and create PR
git push origin feat/metabase-dashboard-integration
# Create PR to main branch
# When merged → MINOR version bump (e.g., v0.1.0 → v0.2.0)
```

### 2. Fixing a Bug
```bash
# Create fix branch
git checkout -b fix/postgres-connection-pool-leak

# Fix the issue
# ... bug fixes ...

# Commit and push
git commit -m "Fix connection pool leak in PostgreSQL writer"
git push origin fix/postgres-connection-pool-leak
# When merged → PATCH version bump (e.g., v0.2.0 → v0.2.1)
```

### 3. Breaking Change
```bash
# Create breaking change branch
git checkout -b breaking/migrate-to-spark-4

# Make breaking changes
# ... major changes ...

# Commit and push
git commit -m "Migrate to Spark 4.0 with new API"
git push origin breaking/migrate-to-spark-4
# When merged → MAJOR version bump (e.g., v0.2.1 → v1.0.0)
```

### 4. Documentation Update
```bash
# Create docs branch
git checkout -b docs/add-deployment-guide

# Update documentation
# ... docs changes ...

# Commit and push
git commit -m "Add comprehensive deployment guide"
git push origin docs/add-deployment-guide
# When merged → PATCH version bump (e.g., v1.0.0 → v1.0.1)
```

## Branch Naming Best Practices

### ✅ Good Examples
- `feat/clickhouse-analytics-warehouse`
- `fix/spark-memory-optimization`
- `breaking/remove-deprecated-api`
- `docs/update-installation-guide`
- `hotfix/critical-security-patch`

### ❌ Avoid These
- `feature-branch` (no prefix)
- `fix_bug` (underscore instead of slash)
- `feat-new-stuff` (dash instead of slash)
- `FEAT/UPPERCASE` (use lowercase)

## Commit Message Freedom

Since versioning is based on branch names, you can use **any commit message format**:

```bash
# All of these work fine:
git commit -m "Add new feature"
git commit -m "WIP: working on database integration"
git commit -m "🚀 Amazing new dashboard functionality!"
git commit -m "Quick fix for the thing"
```

## Benefits of Branch-based Versioning

✅ **Simpler workflow**: No need to remember commit message formats  
✅ **Clear intent**: Branch name shows exactly what type of change it is  
✅ **Automatic versioning**: Version determined from branch prefix  
✅ **Flexible commits**: Use any commit message format you want  
✅ **Pull request workflow**: Encourages code review before release  
✅ **Docker tagging**: Images automatically tagged with semantic versions  

## How It Works

1. **Create feature branch** with appropriate prefix:
   ```bash
   git checkout -b feat/new-dashboard-widget
   ```

2. **Make changes and commit** (any message format):
   ```bash
   git commit -m "Add awesome new widget"
   ```

3. **Push and create Pull Request**:
   ```bash
   git push origin feat/new-dashboard-widget
   # Create PR on GitHub
   ```

4. **Merge PR** → **Automatic release**:
   - Version calculated from branch name (`feat/` → MINOR bump)
   - Git tag created (e.g., `v0.1.0` → `v0.2.0`)
   - GitHub release created with automatic notes
   - Docker image built and tagged

## Release Trigger

- **Trigger**: Pull Request merged to `main` branch
- **Condition**: Branch name determines version bump
- **Output**: Git tag, GitHub release, Docker image

## Migration from Conventional Commits

If you were using conventional commits before, this approach is:

| Old Way | New Way | Result |
|---------|---------|--------|
| `git commit -m "feat: new feature"` | `git checkout -b feat/new-feature` | Same MINOR bump |
| `git commit -m "fix: bug fix"` | `git checkout -b fix/bug-name` | Same PATCH bump |
| `git commit -m "feat!: breaking"` | `git checkout -b breaking/change-name` | Same MAJOR bump |

**Advantages**: 
- ✅ Easier to remember
- ✅ Works with any commit style
- ✅ Encourages better branch organization
- ✅ Natural fit with PR-based workflows