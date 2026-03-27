// ============================================================
// Monash University Presentation Theme for Quarto / Typst
// Mirrors beamerthemeMonash.sty
// ============================================================

// --- Colour palette ---
#let monash-blue   = rgb("#1969AA")
#let monash-orange = rgb("#C14b14")
#let dark-grey     = rgb("#646464")
#let dark-yellow   = rgb("#E6AC00")
#let light-grey    = rgb("#e7e7e7")

// --- Slide geometry (16:9) ---
#let slide-width   = 25.4cm
#let slide-height  = 14.29cm
#let margin-x      = 0.8cm
#let margin-top    = 1.0cm
#let margin-bottom = 0.2cm
#let title-bar-h   = 1.7cm   // height of the blue frame-title bar

// --- Helpers ---
#let _parse-color(c) = {
  if c == "white" { white }
  else if c == "black" { black }
  else { rgb(c) }
}

// Draw the Monash title bar (blue bar with white text).
// dx / dy shift account for the page margins so the bar
// spans the full page width.
#let _title-bar(body) = {
  place(
    top + left,
    dx: -margin-x,
    dy: -margin-top,
    rect(
      width:  slide-width,
      height: title-bar-h,
      fill:   monash-blue,
      inset:  (x: margin-x - 0.2cm, y: 0.45cm),
    )[
      #set text(fill: white, size: 1.3em, weight: "bold")
      #body
    ]
  )
  // Push subsequent content below the bar
  v(title-bar-h - margin-top + 0.75cm)
}

// ============================================================
// Main template function
// ============================================================
#let presentation(
  title:         none,
  subtitle:      none,
  authors:       none,   // rendered content (string or block)
  date:          none,
  titlegraphic:  "bg-02.png",
  titlecolor:    "black",
  titlefontsize: 36pt,
  toc:           false,
  toc-title:     "Outline",
  fontsize:      22pt,
  bg-path:       "_extensions/presentation/_images/background/",
  doc,
) = {

  // ---- Page layout ------------------------------------------------
  set page(
    width:  slide-width,
    height: slide-height,
    margin: (x: margin-x, top: margin-top, bottom: margin-bottom),
    footer: context {
      let n     = counter(page).at(here()).at(0)
      let total = counter(page).final().at(0)
      // Progress bar (orange fill proportional to progress)
      place(bottom + left,
        dx: -margin-x,
        dy: margin-bottom - 2pt,
        rect(width: slide-width, height: 2pt, fill: light-grey)
      )
      place(bottom + left,
        dx: -margin-x,
        dy: margin-bottom - 2pt,
        rect(
          width:  slide-width * n / total,
          height: 2pt,
          fill:   monash-orange,
        )
      )
      // Frame number box — flush bottom-right corner of slide
      place(bottom + right,
        dx: margin-x,
        dy: margin-bottom,
        box(
          stroke: 0.5pt + dark-grey,
          inset: (x: 5pt, y: 11pt),
          text(fill: rgb("#c7c7c7"), size: 0.7em)[#n]
        )
      )
    },
  )

  // ---- Figures ----------------------------------------------------
  // Disable floating so figures stay on the slide they belong to
  set figure(placement: none)

  // ---- Typography -------------------------------------------------
  set text(font: ("Fira Sans", "Liberation Sans"), size: fontsize)
  set par(justify: false, leading: 0.65em)

  // Mono font for all raw/code elements
  show raw: it => {
    set text(font: ("DejaVu Sans Mono", "Noto Sans Mono", "Liberation Mono"))
    it
  }
  // Skylighting (chunk output/source) uses block(fill: rgb("#f1f3f5"), ...)
  // Target that fill colour to apply 85% font size to all code blocks
  show block.where(fill: rgb("#f1f3f5")): it => {
    set text(size: fontsize * 0.85)
    it
  }

  // ---- Bullet lists -----------------------------------------------
  set list(
    marker: (
      // Level 1: filled orange square (matches \setbeamertemplate{itemize item}[square])
      box(width: 0.55em, height: 0.55em, baseline: -0.05em, fill: monash-orange),
      // Level 2: small filled right-triangle (matches beamer blacktriangleright)
      text(fill: monash-orange.lighten(20%), size: 0.75em)[#sym.triangle.filled.r],
      // Level 3: star (matches beamer bigstar)
      text(fill: monash-orange.lighten(20%), size: 0.75em)[#sym.star.filled],
    ),
    indent:      1.2em,
    body-indent: 0.6em,
  )

  // ---- Numbered lists ---------------------------------------------
  // Orange filled square box with white number, matching the custom
  // beamer [mysquare] enumerate template.
  set enum(
    full: true,
    numbering: (..nums) => {
      let n = nums.pos().last()
      box(
        fill:   monash-orange,
        inset:  (x: 4pt, y: 2pt),
        text(fill: white, size: 0.72em, weight: "bold")[#n]
      )
    },
    indent:      1.2em,
    body-indent: 0.8em,
  )

  // ---- Alert / strong text ----------------------------------------
  // Beamer: \setbeamercolor{alerted text}{fg=Orange}
  show strong: it => text(fill: monash-orange, weight: "bold", it.body)

  // ---- Tables (booktabs style) ------------------------------------
  // Mimics the booktabs style as used in beamer slides.
  set table(inset: (x: 6pt, y: 8pt), stroke: none)
  set table.hline(stroke: 1pt + dark-grey)  // midrule
  show table: it => context {
    let w = measure(it).width
    set align(center)
    line(length: w, stroke: 2pt + dark-grey)  // toprule
    v(-1em)
    it
    v(-1em)
    line(length: w, stroke: 2pt + dark-grey)  // bottomrule
  }

  // ---- Shared TOC entry renderer ----------------------------------
  // cur = 0 → all entries full colour (main TOC)
  // cur = n → entry n full colour, others faded (section divider)
  let _slide-n   = counter("_pres-slide")
  let _section-n = counter("_pres-section")
  let _after-sec = state("_after-sec", false)

  let _toc-entries(sections, cur) = {
    for (i, sec) in sections.enumerate() {
      let n   = i + 1
      let col = if cur == 0 or n == cur { monash-orange } else { monash-orange.lighten(60%) }
      block(
        above: fontsize, below: fontsize,
        inset: (left: 1cm),
        link(sec.location(),
          text(size: fontsize * 1.1)[
            #box(fill: col, inset: (x: 8pt, y: 5pt), baseline: 20%,
              text(fill: white, weight: "bold")[#n])
            #h(0.4em)
            #text(fill: col, weight: "regular")[#sec.body]
          ]
        )
      )
    }
  }

  // ---- Section headings (H1 = \section) ---------------------------
  show heading.where(level: 1): it => {
    v(0pt, weak: true)
    place(dx: -9999cm, it)   // off-screen but kept for outline / query tracking
    if toc {
      context if _slide-n.at(here()).at(0) > 0 { pagebreak() }
      _after-sec.update(true)
      _section-n.step()
      { set text(size: fontsize); _title-bar[#toc-title] }
      v(0.5cm)
      context {
        let cur = _section-n.at(here()).at(0)
        _toc-entries(query(heading.where(level: 1)), cur)
      }
    }
  }

  // ---- Slide headings (H2 = frame title) --------------------------
  // Insert pagebreak before every slide except the very first one,
  // OR when coming directly after a section-divider slide.
  show heading.where(level: 2): h => {
    context if _slide-n.at(here()).at(0) > 0 or _after-sec.at(here()) {
      pagebreak()
    }
    _after-sec.update(false)
    _slide-n.step()
    { set text(size: fontsize); _title-bar(h.body) }
  }

  // ---- Sub-slide headings (H3, used as \block-style headings) ------
  show heading.where(level: 3): h => {
    v(1em, weak: true)
    text(weight: "bold", fill: monash-blue)[#h.body]
    v(0.7em, weak: true)
  }

  // ================================================================
  // Title slide
  // ================================================================
  let title-color-val = _parse-color(titlecolor)
  let img-path = if titlegraphic.contains("/") {
    titlegraphic
  } else {
    bg-path + titlegraphic
  }

  // Full-page background image (extends over the page margins)
  place(
    top + left,
    dx: -margin-x,
    dy: -margin-top,
    image(img-path, width: slide-width, height: slide-height, fit: "cover"),
  )

  // Title text (mirrors textblock at x=1cm, y=2.8cm in before-title.tex)
  place(
    top + left,
    dx: 0.5cm,
    dy: 3.4cm,
    block(width: slide-width * 0.65)[
      #set text(fill: title-color-val, size: titlefontsize, weight: "bold")
      #set par(leading: 0.8em)
      #title
      #if subtitle != none {
        linebreak()
        text(size: titlefontsize * 0.65, weight: "regular")[#subtitle]
      }
    ]
  )

  // Author and date (mirrors textblock at x=1cm, y=6.8cm in before-title.tex)
  place(
    top + left,
    dx: 0.5cm,
    dy: slide-height - margin-top - margin-bottom - 3cm,
    block(width: slide-width * 0.6)[
      #set text(fill: title-color-val, size: fontsize * 1.1)
      #if authors != none { authors }
      #if date != none { v(0.0em); date }
    ]
  )

  pagebreak()

  // ================================================================
  // Table of contents slide (if toc: true)
  // ================================================================
  if toc {
    _title-bar[#toc-title]
    v(0.5cm)
    context _toc-entries(query(heading.where(level: 1)), 0)
    pagebreak()
  }

  // ================================================================
  // Document body
  // ================================================================
  doc
}
