make # Privorum Website

Static Hugo website for Privorum, a blockchain and software consultancy.

The site is content-driven and theme-based:

- page copy lives in `content/`
- site settings and navigation live in `config.toml`
- layouts, partials, styles, and small JavaScript behaviors live in `themes/hugo-serif-theme/`
- architecture documentation lives in `docs/architecture/`

## Stack

- Hugo
- `hugo-serif-theme`
- Markdown content
- SCSS and small JavaScript assets managed through the theme

## Project Structure

- `content/` page content and front matter
- `content/services/` service landing pages
- `content/team/` team pages
- `content/clients/` client section content
- `content/protocols/` protocol section content
- `themes/hugo-serif-theme/` Hugo theme files
- `static/` copied static assets
- `docs/architecture/` C4 architecture documentation
- `config.toml` site metadata, menus, logo, and analytics settings
- `Makefile` local development helpers
- `deploy.sh` publish script (builds into `public/`, a `gh-pages` worktree, and pushes it)

## Local Development

Prerequisite: install Hugo and make sure the `hugo` command is available on your `PATH`.

Start the local server:

```bash
make start
```

Alternative target:

```bash
make start-watch
```

The current development command in `Makefile` is:

```bash
hugo server --watch=true
```

## Build

Generate the static site:

```bash
make build
```

That command removes `public/` and rebuilds the site with Hugo. `public/` is also the `gh-pages` worktree used by `./deploy.sh`, which recreates it on the next run.

## Configuration Notes

- Base URL is configured in `config.toml`.
- Main and footer navigation are configured in `config.toml`.
- Optional Google Analytics and Google Tag Manager IDs are also configured in `config.toml`.
- Branding assets such as the site logo are referenced from `config.toml`.

## Content Editing

Most day-to-day updates should happen in `content/`.

Use content edits for:

- service descriptions
- homepage and about-page copy
- team bios
- client and protocol section updates
- contact page content

Use theme edits for:

- shared page layouts
- partials and navigation markup
- global styling
- browser-side interactions

## Architecture Docs

Architecture documentation is in [docs/architecture](./docs/architecture/README.md).

It includes:

- system context
- container view
- component view for site generation
- deployment view

## Deployment

The site is published manually; there is no CI, so pushing to `master` does not publish.

```bash
make deploy    # same as ./deploy.sh
```

The script makes sure `public/` is a worktree of the `gh-pages` branch, clears it, runs `hugo --minify`, commits "Publish site to gh-pages" and pushes `gh-pages`. The site is served at `https://privorum.com` (`baseURL` in `config.toml`, `CNAME` in `static/`), most likely by GitHub Pages. Commit and push `master` before publishing so the source matches what goes live. `./deploy.sh setup` only repairs the worktree.
