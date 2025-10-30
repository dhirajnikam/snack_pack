# Publishing to pub.dev

This document explains how the automatic publishing workflow works and how to set it up.

## Automatic Publishing

This repository uses GitHub Actions to automatically publish to pub.dev when changes are pushed to the `main` branch.

### Workflow Trigger

The publish workflow runs when:
1. A commit is pushed to `main` branch with "release" in the commit message, OR
2. A version tag (e.g., `v1.0.1`) is pushed

### Setting Up Credentials

To enable automatic publishing, you need to set up pub.dev credentials as a GitHub secret:

#### Step 1: Generate pub.dev Credentials

1. Run the following command locally to generate credentials:
   ```bash
   flutter pub publish --dry-run
   ```

2. This will create a credentials file at:
   - **macOS/Linux**: `~/.pub-cache/credentials.json`
   - **Windows**: `%APPDATA%\Pub\Cache\credentials.json`

#### Step 2: Add Credentials to GitHub Secrets

1. Copy the contents of `credentials.json`
2. Go to your GitHub repository settings
3. Navigate to **Settings** → **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Name: `PUB_DEV_CREDENTIALS`
6. Value: Paste the entire contents of `credentials.json`
7. Click **Add secret**

### Publishing a New Version

#### Method 1: Using Commit Messages (Recommended)

1. Update the version in `pubspec.yaml`
2. Update `CHANGELOG.md` with the new changes
3. Commit with "release" in the message:
   ```bash
   git add .
   git commit -m "release: version 1.0.1"
   git push origin main
   ```

#### Method 2: Using Git Tags

1. Update the version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Commit and push your changes
4. Create and push a version tag:
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

### Pre-Publish Checks

The workflow automatically runs these checks before publishing:
- ✓ Formatting verification
- ✓ Static analysis
- ✓ All tests must pass
- ✓ Dry-run publish check

If any check fails, the publish will be aborted.

### Manual Publishing

If you prefer to publish manually:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Run tests: `flutter test`
4. Dry run: `dart pub publish --dry-run`
5. Publish: `dart pub publish`

## CI/CD Workflows

This repository has two workflows:

### 1. Test Workflow (`test.yml`)
- Runs on every push and pull request to `main` or `develop`
- Verifies formatting, runs analysis, and executes tests
- Checks pub score using `pana`

### 2. Publish Workflow (`publish.yml`)
- Runs on push to `main` (with "release" in commit) or version tags
- Runs all tests and checks
- Automatically publishes to pub.dev if all checks pass

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):
- **Major** (1.0.0): Breaking changes
- **Minor** (1.1.0): New features, backward compatible
- **Patch** (1.0.1): Bug fixes, backward compatible

## Troubleshooting

### Publish fails with authentication error
- Verify `PUB_DEV_CREDENTIALS` secret is correctly set
- Regenerate credentials if they've expired

### Workflow doesn't trigger
- Ensure commit message contains "release" OR you're pushing a version tag
- Check that the workflow file is on the `main` branch

### Tests fail in CI but pass locally
- Ensure all dependencies are in `pubspec.yaml`
- Check Flutter version matches (see workflow file)
- Verify formatting: `dart format .`

## Security Notes

- Never commit `credentials.json` to the repository
- Credentials are stored securely in GitHub Secrets
- Only repository administrators can view/edit secrets
- Rotate credentials if compromised
