# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Quarto extension** providing Monash University-branded presentation themes for PDF (Beamer/LaTeX and Typst) and HTML (RevealJS) output. It is not a traditional software project — there are no build scripts, package managers, or automated tests.

## Common Commands

```bash
# Render the example presentation (generates both PDF and HTML)
quarto render template.qmd

# Render the README (uses R to generate screenshots; requires magick, quarto R packages)
quarto render README.qmd

# Install this extension into another project
quarto install extension quarto-monash/presentation

# Create a new project from this template
quarto use template quarto-monash/presentation
```

Rendering `template.qmd` is the primary way to test changes. It produces `template.pdf` (Beamer), `template.pdf` (Typst), and `template.html` (RevealJS).

## Architecture

The extension lives entirely in `_extensions/presentation/`. The entry point is `_extension.yml`, which defines four output formats:

- **`presentation-beamer`**: PDF via pdflatex, uses `beamer/beamerthemeMonash.sty` plus two LaTeX partials (`before-title.tex`, `toc.tex`)
- **`presentation-typst`**: PDF via Typst, uses `typst/typst-template.typ` (defines the `presentation()` function) and `typst/typst-show.typ` (Pandoc template that wires YAML metadata to the function)
- **`presentation-revealjs`**: HTML via RevealJS, styled by `revealjs/monash.scss`
- **`presentation-revealjs+letterbox`**: RevealJS variant with decorative letterbox borders for video recording, uses additional `letterbox/` files

### Key files

| File | Purpose |
|------|---------|
| `_extensions/presentation/_extension.yml` | Format definitions, default YAML options for each format |
| `_extensions/presentation/beamer/beamerthemeMonash.sty` | Main Beamer theme (colours, fonts, frame layout, footer, bullets) |
| `_extensions/presentation/beamer/before-title.tex` | Title page layout |
| `_extensions/presentation/typst/typst-template.typ` | Typst theme: `presentation()` function, colours, slide layout, show rules |
| `_extensions/presentation/typst/typst-show.typ` | Pandoc template mapping YAML vars to `presentation()` arguments |
| `_extensions/presentation/revealjs/monash.scss` | Full RevealJS colour scheme, typography, utility classes |
| `_extensions/presentation/letterbox/` | Letterbox border styling, custom title slide, background JS |
| `template.qmd` | Example/test presentation — also the file distributed to users |
| `README.qmd` | Source for README.md; contains R code to render and screenshot the template |

### How Quarto assembles the Typst output

Quarto inlines all `template-partials` in order into a single `.typ` file:
1. Quarto's built-in numbering/definitions partials
2. `typst-template.typ` — defines `presentation()`
3. `page.typ` (Quarto default) — sets a page size (overridden by `presentation()` internally)
4. `typst-show.typ` — `#show: doc => presentation(...)` with Pandoc-substituted vars
5. Document body content

Because `typst-template.typ` is a Pandoc template partial, any `$...$` sequences in it are interpreted as Pandoc template variables. Use `$$` to escape a literal `$`.

### Beamer theme details

- PDF engine: pdflatex (not xelatex)
- Colours: Monash Blue `#1969AA`, Orange `#CC5900`, Dark Grey, Yellow
- Fonts: Fira Sans (body), Source Code Pro (code), Bera Mono
- Custom YAML options: `titlegraphic`, `titlecolor`, `titlefontsize`, `toc` (boolean)
- Requires the `mathrsfs` LaTeX package (already declared in extension)

### Typst theme details

- Slide size: 25.4 cm × 14.29 cm (16:9)
- Colours: Monash Blue `#1969AA`, Orange `#CC5900`
- Fonts: Fira Sans (body, falls back to Liberation Sans), DejaVu Sans Mono (code)
- H1 headings (`#`) → section markers (invisible, appear in outline)
- H2 headings (`##`) → slide title bar (blue bar, pagebreak before)
- H3 headings (`###`) → bold blue subheading within a slide
- Custom YAML options: `titlegraphic`, `titlecolor`, `titlefontsize`, `toc`, `bg-path`
- `bg-path` defaults to `_extensions/presentation/_images/background/`; change it to `_extensions/quarto-monash/presentation/_images/background/` when using the installed extension (not the template)
- Content that overflows a slide wraps to the next page (unlike Beamer which clips)

### RevealJS theme details

- Primary colour: `#006DAE` (Monash Blue)
- Utility CSS classes follow the pattern `.monash-blue`, `.monash-bg-blue`, `.monash-border-blue` — extended across the full Monash colour palette
- KaTeX used for math rendering (not MathJax)
- Code blocks use dark theme (`#181818` background)

### Images

`_extensions/presentation/_images/` contains:
- `background/`: `bg-01.png` through `bg-13.png` — slide background images
- `logo/`: Monash logo variants in different colors/formats for use in slides
