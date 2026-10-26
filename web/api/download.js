// Redirects to the newest GitHub release's .img.xz asset, so the site's
// Download button never needs updating when a new release ships.
// Edge-cached for 10 min to stay well under GitHub's unauthenticated API limit.
const REPO = "evanchoudhury/aether-os";
const RELEASES = `https://github.com/${REPO}/releases/latest`;

export default async function handler(req, res) {
  let target = RELEASES;
  try {
    const r = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, {
      headers: { "User-Agent": "aether-os-site", Accept: "application/vnd.github+json" },
    });
    if (r.ok) {
      const data = await r.json();
      const asset = (data.assets || []).find((a) => a.name.endsWith(".img.xz"));
      if (asset) target = asset.browser_download_url;
    }
  } catch {
    // fall back to the releases page
  }
  res.setHeader("Cache-Control", "s-maxage=600, stale-while-revalidate=86400");
  res.statusCode = 302;
  res.setHeader("Location", target);
  res.end();
}
