# C4 System Context

This diagram shows the Privorum website as a single software system and the external actors and services around it.

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
C4Context
  title System Context Diagram for Privorum Website

  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")

  Person(marketingEditor, "Marketing Editor", "Maintains marketing copy, service pages, and site data")
  Person(siteVisitor, "Website Visitor", "Browses Privorum marketing pages and contact information")

  System(privorumSite, "Privorum Website", "Hugo-generated static marketing website for Privorum")

  System_Ext(github, "Git Hosting", "Stores the source repository and deployment branch")
  System_Ext(staticHosting, "Static Web Hosting", "Serves the generated website over HTTPS")
  System_Ext(gtm, "Google Tag Manager", "Optional tag loading in production")
  System_Ext(ga, "Google Analytics", "Optional visitor analytics in production")

  Rel(marketingEditor, github, "Commits site content and theme changes")
  Rel(github, privorumSite, "Provides source for builds")
  Rel(siteVisitor, privorumSite, "Uses", "HTTPS")
  Rel(privorumSite, staticHosting, "Is published to")
  Rel(privorumSite, gtm, "Loads tags when configured", "JavaScript")
  Rel(privorumSite, ga, "Sends analytics when configured", "JavaScript")

  UpdateElementStyle(marketingEditor, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(siteVisitor, $bgColor="#dbeafe", $fontColor="#0f172a", $borderColor="#2563eb")
  UpdateElementStyle(privorumSite, $bgColor="#bfdbfe", $fontColor="#0f172a", $borderColor="#1d4ed8")
  UpdateElementStyle(github, $bgColor="#e2e8f0", $fontColor="#0f172a", $borderColor="#64748b")
  UpdateElementStyle(staticHosting, $bgColor="#e2e8f0", $fontColor="#0f172a", $borderColor="#64748b")
  UpdateElementStyle(gtm, $bgColor="#fef3c7", $fontColor="#0f172a", $borderColor="#d97706")
  UpdateElementStyle(ga, $bgColor="#fef3c7", $fontColor="#0f172a", $borderColor="#d97706")
```

## Notes

- The system has no application backend in this repository.
- Contact information is rendered statically from repository data, not submitted to a server-side form handler.
- Google integrations are optional and controlled by Hugo params or environment variables.
