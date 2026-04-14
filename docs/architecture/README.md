# Privorum Website Architecture

This folder documents the architecture of the `privorum_website` project using C4-style Mermaid diagrams.

The project is a Hugo-based static marketing website. Its architecture is intentionally simple:

- Content authors update Markdown, data files, images, and site configuration in this repository.
- Hugo combines that source content with the `hugo-serif-theme` theme to generate static HTML, CSS, and JavaScript.
- The generated site is served to website visitors as static assets.
- Optional Google Tag Manager and Google Analytics scripts can be injected in production builds.

Documents in this folder:

- [c4-context.md](./c4-context.md)
- [c4-containers.md](./c4-containers.md)
- [c4-components-site-generation.md](./c4-components-site-generation.md)
- [c4-deployment.md](./c4-deployment.md)
