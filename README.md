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

## Use

Add it next to wpsecadv:

```sh
composer config -g repositories.wpsecadv-aliases composer https://generoi.github.io/wpsecadv-aliases --no-interaction
```

`packages.json` lists only the aliased names in `available-packages`, so
Composer asks this repository about nothing else.

## Adding an alias

Add `"<our package>": "<wpsecadv package>"` to `aliases.json`.

Only alias when the premium plugin ships the free plugin's code at the same
version numbers, so the free plugin's affected ranges apply as is. For
Polylang Pro, `polylang.php` loads the bundled `wpsyntex/polylang` and both
report the same version. Issues in premium-only code are not covered by any
alias.

## Build locally

```sh
./build.sh _site http://127.0.0.1:8000
```
