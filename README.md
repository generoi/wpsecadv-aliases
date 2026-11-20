# wpsecadv-aliases

A static Composer repository that re-serves [wpsecadv](https://github.com/typisttech/wpsecadv)
security advisories under package names wpsecadv can't match.

wpsecadv matches a package by its project name against Wordfence slugs.
Some premium plugins have no slug of their own in Wordfence: Polylang Pro
issues are filed under `polylang`, so `generoi/polylang-pro` gets no
advisories. This repository copies the advisories of the slug that covers
them to our package name.

Published at https://generoi.github.io/wpsecadv-aliases/, rebuilt twice a
day (after wpsecadv syncs) and on every push.

## When it applies

Check whenever a site requires a premium plugin through our own mirror
(`generoi/<plugin>-pro`, `generoi/<plugin>-premium`, a renamed plugin
directory) instead of a `wp-plugin/*` package:

1. Ask wpsecadv for it:
   `curl -s -o /dev/null -w '%{http_code}' https://repo-wpsecadv.typist.tech/p2/generoi/<package>.json`.
   A 200 means Wordfence tracks the slug itself and nothing is needed here.
2. On a 404, find the free plugin it's built on and check whether it ships
   that code at the same version numbers (see "Adding an alias"). If it does,
   alias it. If the versions differ, an alias would match the wrong ranges:
   leave it out.
3. Make sure the mirror is locked to a **tagged version**. A site that
   requires `dev-master` locks no version, and no advisory range can ever
   match it, aliased or not. Tag the mirror at its plugin version and change
   the constraint to `^<major>.<minor>`.

## Use

The shared `vulnerability-scan.yml` in `generoi/github-actions` already adds
this repository for every nightly scan. To run the same audit by hand, add it
next to wpsecadv:

```sh
composer config -g repositories.wpsecadv-aliases composer https://generoi.github.io/wpsecadv-aliases --no-interaction
```

`packages.json` lists only the aliased names in `available-packages`, so
Composer asks this repository about nothing else.

## Adding an alias

Add `"<our package>": "<wpsecadv package>"` to `aliases.json`.

Only alias when the premium plugin ships the free plugin's code at the same
version numbers, so the free plugin's affected ranges apply as is. Issues in
premium-only code are not covered by any alias.

Current aliases and why each is safe:

- `generoi/polylang-pro` → `wp-plugin/polylang`: `polylang.php` loads the
  bundled `wpsyntex/polylang`, and both report the same version.
- `generoi/wpdev-booking` → `wp-plugin/booking`: Booking Calendar Business is
  the free plugin's code; its `WP_BK_VERSION_NUM` follows the wordpress.org
  releases (10.10.2 on both).
- `generoi/enhanced-media-library-pro` → `wp-plugin/enhanced-media-library`:
  PRO is the free plugin's tree at the same `EML_VERSION` plus a `pro/`
  directory; everything outside `pro/` is byte-identical (checked at 2.8.8).
- `generoi/custom-facebook-feed-pro` → `wp-plugin/custom-facebook-feed`: the
  weakest of these. Pro has its own codebase at the free plugin's version
  numbers (`CFFVER`), with extra releases of its own. Smash Balloon ports
  security fixes to both at the same version (CVE-2026-125033: vulnerable in
  both at 4.15.1, fixed in both at 4.16.0), so free ranges have held so far,
  but a Pro release missing from wordpress.org can fall outside them.

An alias makes the nightly scan see advisories it couldn't before, so expect
the affected sites' next scan to go red.

## Build locally

```sh
./build.sh _site http://127.0.0.1:8000
```
