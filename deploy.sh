#!/bin/sh
set -e

# Deploy the Hugo site to the gh-pages branch.
# Assumes `public/` is a git worktree tracking origin/gh-pages.
# First-time setup (run once):
#   rm -rf public
#   git worktree add -B gh-pages public origin/gh-pages

if [ ! -d public/.git ] && [ ! -f public/.git ]; then
    echo "public/ is not a gh-pages worktree. Run:"
    echo "  rm -rf public && git worktree add -B gh-pages public origin/gh-pages"
    exit 1
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
