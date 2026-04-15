# C4 Component Diagram

This component view focuses on the internal structure that matters most in this repository: how Hugo assembles the website from content, data, templates, and assets.

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
C4Component
  title Component Diagram for Privorum Website Site Generation

  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")

  Container(generator, "Hugo Generator", "Hugo", "Builds the site")

  Container_Boundary(siteSource, "Site Source") {
    Component(config, "Site Configuration", "TOML", "Global settings, menus, metadata, and theme selection in config.toml")
    Component(content, "Content Pages", "Markdown", "Page bodies and front matter under content")
    Component(dataFiles, "Structured Data", "YAML and JSON", "Reusable content such as features, clients, protocols, and contact data")
    Component(layouts, "Theme Layouts and Partials", "Hugo templates", "Page composition in layouts partials and templates")
    Component(assetPipeline, "Theme Asset Pipeline", "SCSS and JavaScript", "Compiles styles and bundles browser assets from assets")
    Component(staticAssets, "Static Assets", "Images and favicon files", "Files copied directly from static")
  }

  Component(browserRuntime, "Browser Runtime", "HTML, CSS, JavaScript", "Rendered pages plus small interactive behaviors")
  Component(analyticsScripts, "Analytics Integrations", "Google scripts", "Optional GTM and GA snippets included in production")

  Rel(config, generator, "Configures site generation")
  Rel(content, generator, "Provides page source")
  Rel(dataFiles, generator, "Provides reusable data")
  Rel(layouts, generator, "Defines page structure")
  Rel(assetPipeline, generator, "Compiles and fingerprints assets")
  Rel(staticAssets, generator, "Supplies copied files")
  Rel(generator, browserRuntime, "Produces")
  Rel(browserRuntime, analyticsScripts, "Loads when configured", "JavaScript")

  UpdateElementStyle(generator, $bgColor="#bfdbfe", $fontColor="#0f172a", $borderColor="#1d4ed8")
  UpdateElementStyle(config, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(content, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(dataFiles, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(layouts, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(assetPipeline, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(staticAssets, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(browserRuntime, $bgColor="#e2e8f0", $fontColor="#0f172a", $borderColor="#64748b")
  UpdateElementStyle(analyticsScripts, $bgColor="#fef3c7", $fontColor="#0f172a", $borderColor="#d97706")

  UpdateRelStyle(generator, browserRuntime, $textColor="#0f172a", $lineColor="#334155")
  UpdateRelStyle(browserRuntime, analyticsScripts, $textColor="#0f172a", $lineColor="#334155", $offsetY="-10")
```

## Component notes

- `layouts/_default/baseof.html` is the main composition root for shared page structure.
- `layouts/index.html`, `layouts/services/*`, `layouts/team/*`, and similar templates provide page-type-specific rendering.
- `assets/js/scripts.js` provides the primary interactive behavior in this repository: toggling the mobile menu state.
- `assets/js/pages/services.js` and `assets/js/libs/library.js` are currently placeholders with console logging rather than substantial application logic.
