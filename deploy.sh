#!/bin/bash
# Publish Forge and Oratory to GitHub Pages.
#
#   cd into this folder, then:   bash deploy.sh
#
# Re-run it any time to push changes. It is safe to run twice.

set -e
REPO="${1:-apps}"          # bash deploy.sh myname  → uses that repo name instead

cd "$(dirname "$0")"
say(){ printf '\n\033[1m%s\033[0m\n' "$*"; }
die(){ printf '\n\033[31m%s\033[0m\n' "$*"; exit 1; }

[ -d forge ] && [ -d oratory ] || die "Run this from the folder that has forge/ and oratory/ in it."

# ---------- prerequisites ----------
command -v git >/dev/null || die "git isn't installed. On a Mac, run:  xcode-select --install"

if ! command -v gh >/dev/null; then
  say "The GitHub CLI isn't installed."
  echo "It's the thing that creates the repo and switches Pages on for you."
  echo
  echo "  Install it:   brew install gh"
  echo "  Then:         gh auth login     (pick GitHub.com → HTTPS → browser)"
  echo
  echo "If you'd rather not, follow README.md and do it by hand instead."
  exit 1
fi

gh auth status >/dev/null 2>&1 || { say "Not signed in to GitHub."; echo "Run:  gh auth login"; exit 1; }

USER=$(gh api user --jq .login)
say "Signed in as $USER. Publishing to $USER/$REPO"

# ---------- commit ----------
if [ ! -d .git ]; then
  git init -q
  git branch -M main
fi
git add -A
git diff --cached --quiet 2>/dev/null || git commit -q -m "Forge and Oratory"
echo "  committed"

# ---------- repo ----------
if gh repo view "$USER/$REPO" >/dev/null 2>&1; then
  echo "  repo already exists — pushing to it"
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$USER/$REPO.git"
  # The repo may have been started on github.com with a placeholder commit this
  # local history doesn't share, which a normal push would reject. This folder is
  # the source of truth, so overwrite it.
  if ! git push -q -u origin main 2>/dev/null; then
    echo "  histories differ — overwriting the remote with this folder"
    git push -q -u origin main --force
  fi
else
  echo "  creating the repo (public — Pages is only free on public repos)"
  gh repo create "$REPO" --public --source=. --remote=origin --push
fi

# ---------- pages ----------
say "Switching on GitHub Pages"
if gh api "repos/$USER/$REPO/pages" >/dev/null 2>&1; then
  echo "  already on"
else
  gh api -X POST "repos/$USER/$REPO/pages" \
    -f "source[branch]=main" -f "source[path]=/" >/dev/null \
    && echo "  enabled" \
    || echo "  couldn't switch it on automatically — Settings → Pages → main → / (root)"
fi

# ---------- wait for the first build ----------
say "Waiting for the first build (usually under a minute)"
BASE="https://$USER.github.io/$REPO"
for i in $(seq 1 40); do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/" || true)
  [ "$CODE" = "200" ] && break
  printf '.'
  sleep 6
done
echo

if [ "$CODE" = "200" ]; then say "Live."; else say "Pushed. The build may still be running — give it a few minutes."; fi

cat <<EOF

  Both apps     $BASE/
  Forge         $BASE/forge/
  Oratory       $BASE/oratory/

Open a link in SAFARI on the iPhone, then Share → Add to Home Screen.
Keep the trailing slash. Chrome on iOS can't install web apps.

Changing something later: edit the file, bump the cache version in that
app's sw.js (forge-v1 → forge-v2), then run this script again.

EOF
