# C4 Deployment Diagram

This deployment view reflects the deployment approach visible in the repository: Hugo generates static files locally or in CI, and those files are published to static hosting.

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'background': '#00ffff',
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
C4Deployment
  title Deployment Diagram for Privorum Website

  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")

  Deployment_Node(editorMachine, "Developer or CI Environment", "Workstation / CI runner", "Builds the website from the repository") {
    Container(buildRepo, "Source Repository", "Git working tree", "Content, templates, assets, and config")
    Container(hugoBuild, "Hugo Build Process", "Hugo CLI", "Runs the Hugo build or development server")
    Container(buildOutput, "Generated Site Output", "Static files in public", "HTML, CSS, JS, and images ready to publish")
  }

  Deployment_Node(hosting, "Static Hosting Platform", "Web server / CDN", "Publishes the generated site") {
    Container(runtimeSite, "Privorum Static Website", "Static website", "Serves generated assets to visitors")
  }

  Deployment_Node(visitorDevice, "Visitor Device", "Browser", "Renders the published website") {
    Container(visitorBrowser, "Web Browser", "Chrome, Safari, Firefox, Edge", "Loads and displays pages")
  }

  Deployment_Node(googleCloud, "Google Services", "External SaaS", "Optional third-party scripts") {
    Container(gtm, "Google Tag Manager", "JavaScript service", "Loads configured marketing tags")
    Container(ga, "Google Analytics", "Analytics service", "Collects page usage events")
  }

  Rel(buildRepo, hugoBuild, "Supplies site source")
  Rel(hugoBuild, buildOutput, "Generates")
  Rel(buildOutput, runtimeSite, "Publishes to")
  Rel(visitorBrowser, runtimeSite, "Requests pages and assets", "HTTPS")
  Rel(runtimeSite, gtm, "Loads tag manager when configured", "JavaScript")
  Rel(runtimeSite, ga, "Loads analytics when configured", "JavaScript")

  UpdateElementStyle(buildRepo, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(hugoBuild, $bgColor="#bfdbfe", $fontColor="#0f172a", $borderColor="#1d4ed8")
  UpdateElementStyle(buildOutput, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(runtimeSite, $bgColor="#bfdbfe", $fontColor="#0f172a", $borderColor="#1d4ed8")
  UpdateElementStyle(visitorBrowser, $bgColor="#e2e8f0", $fontColor="#0f172a", $borderColor="#64748b")
  UpdateElementStyle(gtm, $bgColor="#fef3c7", $fontColor="#0f172a", $borderColor="#d97706")
  UpdateElementStyle(ga, $bgColor="#fef3c7", $fontColor="#0f172a", $borderColor="#d97706")
```

## Deployment notes

- The `Makefile` supports local development with `./hugo server --watch=true`.
- The `build` target removes `public/` and regenerates the site with `./hugo`.
- `deploy.sh` indicates a Git-based publication flow using the generated `public/` directory and pushing to a publish branch.
- No server-side compute, database, or queue is defined in this repository.
