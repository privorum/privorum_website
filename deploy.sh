#!/bin/sh
set -e

# Deploy the Hugo site to the gh-pages branch.
# `public/` is a git worktree tracking origin/gh-pages. If it's missing or
# broken, this script repairs it automatically before building.
#
# Usage:
#   ./deploy.sh           build + publish (repairs the worktree if needed)
#   ./deploy.sh setup     just repair / create the worktree, do not publish

setup_worktree() {
    echo "Setting up public/ as a gh-pages worktree"
    rm -rf public
    git worktree prune
    git fetch origin gh-pages
    git worktree add -B gh-pages public origin/gh-pages
}

is_worktree() {
    [ -d public/.git ] || [ -f public/.git ]
}

case "${1:-}" in
    setup)
        setup_worktree
        echo "Done. Run ./deploy.sh to publish."
        exit 0
        ;;
    ""|deploy)
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo "Usage: $0 [setup|deploy]" >&2
        exit 2
        ;;
esac

if ! is_worktree; then
    setup_worktree
fi

echo "Cleaning previous build"
find public -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

echo "Building site"
hugo --minify

echo "Publishing to gh-pages"
cd public
git add -A
if git diff --cached --quiet; then
    echo "No changes to publish."
    exit 0
fi
git commit -m "Publish site to gh-pages"
git push origin gh-pages
