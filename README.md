**LittleKt**

This is the website repository for LittleKt, including the docs.

## Run locally

`bundle exec jekyll server --livereload`

## Docs versions

Each version lives once in `_docs/<version>/`, using `/docs/<version>/` links, with its sidebar in `_data/docs/<version>.yml` (dots as underscores, e.g. `0_12_0.yml`). It's served at `/docs/<version>/`.

`_data/versions.yml` picks which versions are also served at `/docs/` & `/docs/next/`:

```yaml
latest: "0.11.0"
next: "0.12.0"
```

## Release docs

`python scripts/release-docs.py 0.12.0 --next 0.13.0`

This makes `0.12.0` the latest and starts `0.13.0` as next, copied from `0.12.0`.

## Homepage & features

The homepage (`index.html`) & features page (`_pages/features.html`) read from `_data/features.yml`. Its `docs_base` points the docs links at `/docs/next/` while those features are unreleased. Switch it to `/docs/` once they ship.

## Deploy

Pushing to `master` builds & deploys the site with the `Deploy site` GitHub Action. The repo's Pages source must be set to **GitHub Actions**.
