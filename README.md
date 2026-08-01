# mcpshop.ir — Landing Page

Static, single-page site (`index.html`) for **mcpshop.ir** — a concept showcase for an MCP (Model Context Protocol)
marketplace, pointing visitors to the GitHub repo: https://github.com/mohammadkani/mcpshop.ir

No build step. No dependencies except a Google Fonts link (Vazirmatn) loaded via CDN. Pure HTML/CSS/JS —
canvas-based particle background, SVG flow diagram, scroll-reveal animations.

## Files
- `index.html` — the entire site
- `robots.txt`, `sitemap.xml` — basic SEO plumbing
- `CNAME` — for GitHub Pages custom domain (already set to `mcpshop.ir`)

## Deploy option A — GitHub Pages (simplest, free)
1. Push these files to the root of `github.com/mohammadkani/mcpshop.ir` (branch `main`).
2. Repo → Settings → Pages → Source: `main` branch, `/ (root)`.
3. Keep the `CNAME` file as-is (already contains `mcpshop.ir`) — GitHub Pages reads it automatically.
4. At your domain registrar, point DNS for `mcpshop.ir`:
   - **Apex domain (`mcpshop.ir`)**: add A records to GitHub Pages IPs:
     `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - **www subdomain** (optional): CNAME `www` → `mohammadkani.github.io`
5. Wait for DNS propagation, then in repo Settings → Pages, enable "Enforce HTTPS".

## Deploy option B — Vercel / Netlify (faster propagation, easier SSL)
1. Import the GitHub repo into Vercel or Netlify.
2. Framework preset: "Other" / static — no build command needed, output directory `/`.
3. Add `mcpshop.ir` as a custom domain in the project settings.
4. Update DNS at your registrar per the instructions the platform gives you (usually an A/ALIAS + CNAME).

## After launch
- Verify `https://mcpshop.ir/sitemap.xml` and `/robots.txt` are reachable.
- Submit the site in Google Search Console for faster indexing.
- Update `sitemap.xml`'s `<lastmod>` if content changes later (optional field, not included by default).
