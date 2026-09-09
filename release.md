# Releasing ZapTasks

## 1. Create a pull request

Push your feature branch and open a pull request against `main`.

```bash
git push -u origin <branch-name>
gh pr create --base main --head <branch-name> --fill
```

Wait for the pull request checks to pass and review the changes.

## 2. Merge and close the pull request

Merge the pull request into `main`, then close it if GitHub does not close it automatically.

Update your local `main` branch:

```bash
git switch main
git pull --ff-only
```

## 3. Tag `main`

Create an annotated version tag. For example:

```bash
git tag -a v0.2.2 -m "ZapTasks v0.2.2"
```

## 4. Push the tag

```bash
git push origin v0.2.2
```

## 5. Automatic release steps

Pushing a `v*` tag starts the GitHub Actions release workflow automatically. It will:

1. Build ZapTasks for macOS.
2. Create a DMG and ZIP artifact.
3. Create a GitHub release with those artifacts.
4. Update the Homebrew cask with the new version, download URL, and SHA256 checksum.
