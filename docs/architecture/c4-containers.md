# C4 Container Diagram

This project is not a multi-service application. The most useful container view is the separation between source inputs, Hugo generation, published static assets, and the browser runtime.

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'background': '#ffffff',
    'primaryColor': '#dbeafe',
    'primaryTextColor': '#0f172a',
    'primaryBorderColor': '#1d4ed8',
    'lineColor': '#475569',
    'secondaryColor': '#e2e8f0',
    'tertiaryColor': '#f8fafc',
    'fontFamily': 'Arial',
    'fontSize': '18px'
  }
}}%%
C4Container
  title Container Diagram for Privorum Website

  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")

  Person(marketingEditor, "Marketing Editor", "Updates pages, data, media, and configuration")
  Person(siteVisitor, "Website Visitor", "Browses the website")

  System_Boundary(privorumBoundary, "Privorum Website") {
    Container(contentRepo, "Content and Configuration", "Markdown, TOML, YAML, JSON, images", "Site source in content, data, static, and config.toml")
    Container(themeLayer, "Theme and Templates", "Hugo theme, Go templates, SCSS, JavaScript", "Presentation layer in the hugo-serif-theme theme")
    Container(generator, "Static Site Generator", "Hugo", "Builds pages and bundles assets into the public output")
    Container(staticSite, "Published Static Site", "HTML, CSS, JavaScript, images", "Generated website served to visitors")
  }

  Container_Ext(staticHosting, "Static Web Hosting", "Web server/CDN", "Hosts generated files")
  Container_Ext(gtm, "Google Tag Manager", "JavaScript", "Optional tag delivery")
  Container_Ext(ga, "Google Analytics", "JavaScript", "Optional analytics tracking")

  Rel(marketingEditor, contentRepo, "Edits")
  Rel(marketingEditor, themeLayer, "Maintains")
  Rel(contentRepo, generator, "Supplies content and configuration")
  Rel(themeLayer, generator, "Supplies layouts and assets")
  Rel(generator, staticSite, "Builds")
  Rel(staticSite, staticHosting, "Is deployed to")
  Rel(siteVisitor, staticSite, "Uses", "HTTPS")
  Rel(staticSite, gtm, "Loads when configured", "JavaScript")
  Rel(staticSite, ga, "Loads tracking when configured", "JavaScript")

  UpdateElementStyle(marketingEditor, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(siteVisitor, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(contentRepo, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(themeLayer, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(generator, $bgColor="#bfdbfe", $fontColor="#0f172a", $borderColor="#1d4ed8")
  UpdateElementStyle(staticSite, $bgColor="#bfdbfe", $fontColor="#0f172a", $borderColor="#1d4ed8")
  UpdateElementStyle(staticHosting, $bgColor="#e2e8f0", $fontColor="#0f172a", $borderColor="#64748b")
  UpdateElementStyle(gtm, $bgColor="#fef3c7", $fontColor="#0f172a", $borderColor="#d97706")
  UpdateElementStyle(ga, $bgColor="#fef3c7", $fontColor="#0f172a", $borderColor="#d97706")
```

## Container responsibilities

- `Content and Configuration` defines the site structure, page copy, metadata, menus, and reusable data sets.
- `Theme and Templates` defines shared layouts, SCSS compilation inputs, partials, and browser-side behavior like the mobile menu toggle.
- `Static Site Generator` resolves content against layouts and produces deployable files.
- `Published Static Site` is the only runtime artifact exposed to end users.
