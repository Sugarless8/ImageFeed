#!/bin/bash
cd ~/Desktop/projects/ImageFeed
rm -f .git/index.lock
git add -A
git commit -m "Sprint 11: profile screen, auth, UIWindow from code, SplashVC in code"
git push ImageFeed sprint_11
echo ""
echo "=== Done! Press any key to close ==="
read -n 1
