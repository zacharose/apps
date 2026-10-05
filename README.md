# Apps

Two installable web apps. No build step, no dependencies, nothing to compile —
plain HTML that runs offline once added to a phone's home screen.

- **forge/** — training, hydration, electrolytes, intake
- **oratory/** — Catholic prayer and the liturgical day

---

## The quick way

If you have the GitHub CLI (`brew install gh`, then `gh auth login`):

```bash
cd path/to/this/folder
bash deploy.sh
```

That creates the repo, pushes everything, switches Pages on, waits for the
first build, and prints your three links. Run it again any time to push
changes.

Everything below is the same thing done by hand.

---

## Putting it online with GitHub Pages

### 1. Make the repo

On github.com, click **+** (top right) → **New repository**.

- Name it whatever you like — `apps` is fine. The name becomes part of the URL.
- **Public.** GitHub Pages is only free on public repos.
- Don't add a README; this folder already has one.
- **Create repository.**

### 2. Upload

On the empty repo page, click **uploading an existing file**.

Drag in the **contents** of this folder — the `forge` folder, the `oratory`
folder, `index.html`, `README.md`, and `.nojekyll`. Drag the folders
themselves; GitHub keeps the structure.

Scroll down, click **Commit changes**.

> `.nojekyll` is a dot-file and some systems hide it. If it doesn't come
> through, it isn't fatal here — it just tells GitHub to skip Jekyll
> processing, which is faster and avoids surprises with underscores.

### 3. Turn Pages on

**Settings** (top of the repo) → **Pages** (left sidebar).

Under *Build and deployment*:
- Source: **Deploy from a branch**
- Branch: **main**, folder: **/ (root)**
- **Save**

Give it a minute or two. The page will show your URL when it's live.

### 4. Your links

```
https://USERNAME.github.io/REPO/              ← both apps
https://USERNAME.github.io/REPO/forge/
https://USERNAME.github.io/REPO/oratory/
```

Keep the trailing slash. Without it some relative paths resolve one level
too high.

### 5. Install on the iPhone

Open a link **in Safari** — it has to be Safari, Chrome on iOS can't install
web apps. Share button → **Add to Home Screen** → **Add**.

Then open it from the home screen icon, not from Safari. iOS keeps the two in
separate storage containers, so anything logged in Safari won't appear in the
installed app. Pick one and stay there.

---

## Changing something later

Edit the file on github.com (pencil icon) or push a commit, then **bump the
cache version** in that app's `sw.js`:

```js
const CACHE = 'forge-v1';   // → 'forge-v2'
```

That line matters more than the edit. The service worker caches hard, and
without the bump your phone will keep serving the old copy no matter how many
times you redeploy.

Then force it through: open the app, pull down to refresh, close it fully from
the app switcher, reopen.

---

## Notes

**Forge** keeps your log in the browser on the phone. Nothing is sent anywhere
and there is no account. Use **Export** on the Log tab now and then — clearing
Safari's website data would wipe it.

**Oratory** stores one thing: your chosen prayer word. It keeps no record of
practice, deliberately.

A public repo means the code is visible, but neither app has a server, a
database, or any of your data in it. Anything you log stays on your phone.
