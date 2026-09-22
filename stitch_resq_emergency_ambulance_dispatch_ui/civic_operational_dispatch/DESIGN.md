---
name: Civic Operational Dispatch
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#5b403d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#8f6f6c'
  outline-variant: '#e4beb9'
  surface-tint: '#b91c1c'
  primary: '#93000b'
  on-primary: '#ffffff'
  primary-container: '#b91c1c'
  on-primary-container: '#ffcdc7'
  inverse-primary: '#ffb4ab'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#dae2fd'
  on-secondary-container: '#5c647a'
  tertiary: '#00513a'
  on-tertiary: '#ffffff'
  tertiary-container: '#006c4e'
  on-tertiary-container: '#8debc2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad6'
  primary-fixed-dim: '#ffb4ab'
  on-primary-fixed: '#410002'
  on-primary-fixed-variant: '#93000b'
  secondary-fixed: '#dae2fd'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3f465c'
  tertiary-fixed: '#97f5cc'
  tertiary-fixed-dim: '#7bd8b1'
  on-tertiary-fixed: '#002115'
  on-tertiary-fixed-variant: '#00513a'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Public Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Public Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Public Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Public Sans
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Public Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Public Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.06em
  telemetry-numeral:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 36px
    letterSpacing: -0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.25rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.875rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style

The visual identity embodies civic-grade operational precision and immediate cognitive legibility under extreme stress. It marries the real-time telemetry and fluid reassurance of modern on-demand consumer apps with the uncompromised reliability, high contrast, and authority of institutional emergency dispatch consoles. 

The aesthetic is clean, tactical, and distraction-free: crisp, luminous neutral-50 backdrops paired with deep slate-900 typography to guarantee visibility under glare and direct sunlight. Critical actions and active states employ a deliberate deep crimson accent (`#B91C1C`), used with strict rationing so urgent signals are never diluted. The interface avoids frivolous ornamentation, leaning on structural hierarchy, confident typography, and ergonomic one-handed interaction targets (minimum 56px) designed for trembling hands, ambient glare, and time-critical decision making.

## Colors

Color is treated as an operational signal rather than pure decoration. The palette is strictly partitioned into canvas, content, telemetry, and critical dispatch alerts:

- **Primary (`#B91C1C`):** Emergency Red. Reserved strictly for primary dispatch triggers, cancellation prompts, critical medical warnings, and live ETA alert highlights. Never used for non-urgent structural accents.
- **Secondary (`#0F172A`):** Deep Slate. Powers foundational typography, high-priority operational buttons (e.g., "Confirm Address"), map overlays, and dark telemetry banners. Delivers maximum contrast against light surfaces.
- **Tertiary (`#047857`):** Unit Emerald. Represents active unit assignment, positive telemetry, secure en-route status, and validated responder connections.
- **Telemetry Amber (`#D97706`):** Dedicated state color for queue buffering, dynamic search, and pending dispatch confirmation.
- **Neutral Canvas (`#F8FAFC`):** Pure civic background base, paired with `#FFFFFF` for elevated modular cards and `#E2E8F0` for precision 1px structural dividing lines.

## Typography

Typography pairs the structural geometric precision of **Manrope** for numbers, vehicle calls, and high-impact headlines with the institutional legibility of **Public Sans** for transactional prose, instructions, and dispatch status chips.

Key guidelines:
- **Telemetry Numerals:** ETA countdowns and distance metrics use bold tabular digits in `Manrope` to eliminate jitter during real-time updates.
- **Labels & Micro-copy:** Sub-headers, operational status pills, and vital triage tags use uppercase `Public Sans` with expanded letter spacing (+0.04em to +0.06em) to preserve readability at rapid glance.
- **Body Hierarchy:** Keep body descriptions to a minimum during active dispatch states; emphasize bold data points (unit identifier, responder credentials, blood type tags) over long-form prose.

## Layout & Spacing

The layout system is optimized for thumb-driven, bottom-sheet ergonomics on mobile devices. Key operational components are concentrated in the lower 60% of the display viewport to guarantee swift single-handed triggering.

- **Base Rhythm:** Built on an 8px grid with a 4px sub-grid for fine alignment of telemetry icons and status pill internals.
- **Touch Targets:** All interactive triggers maintain an unconditional minimum bounding box of 56px in height and width. Critical buttons (e.g., "Request Advanced Life Support") stretch 100% width across the safe layout margin.
- **Margins & Safe Zones:** Canvas margins default to 16px (`1rem`) on standard mobile viewports, providing maximal map and tracking real estate, scaling to 20px (`1.25rem`) on larger devices.

## Elevation & Depth

Visual depth is produced through high-contrast layering and subtle, crisp edge definitions rather than heavy atmospheric shadows. This ensures components render with stark distinction across varying phone brightness settings and direct sunlight.

- **Level 0 (Map & Canvas):** Flat `#F8FAFC` base surface or full-bleed interactive map canvas.
- **Level 1 (Structural Sheet / Standard Card):** Surface `#FFFFFF` enclosed with a 1px solid border (`#E2E8F0`) and an ambient shadow: `0px 1px 3px rgba(15, 23, 42, 0.08)`.
- **Level 2 (Floating Action Panels & Bottom Drawers):** High-priority tracking bottom sheets float with `0px 8px 24px -4px rgba(15, 23, 42, 0.12)`, edged with a subtle `#E2E8F0` top border.
- **Level 3 (Emergency Overlays & Triage Modals):** Backdrop scrim tinted to `rgba(15, 23, 42, 0.6)` with elevated cards employing `0px 16px 36px -6px rgba(15, 23, 42, 0.22)`.

## Shapes

The shape system leverages Level 2 roundedness across interactive elements, balancing modern tactile friendliness with structured civic discipline:

- **Buttons & Core Inputs:** Standard border radius of `0.5rem` (8px) for inputs and tertiary triggers, scaling to `0.75rem` (12px) for full-width primary response buttons.
- **Operational Cards & Panels:** Enclosing dispatch cards, paramedic vehicle profiles, and bottom drawer interfaces utilize `rounded-2xl` (`1rem` / 16px to 24px on top corners) to visually cradle actionable content.
- **Pills & Status Badges:** Fully circular pill shapes (`9999px`) to immediately communicate self-contained status indicators (e.g., "En Route", "Paramedic On Board").

## Components

### Buttons
- **Primary Dispatch Button:** 56px to 64px height. Solid `#B91C1C` fill with `#FFFFFF` `headline-sm` text. Full-width thumb target with active state haptic snap and feedback depression.
- **Secondary Operational Button:** 56px height. Solid `#0F172A` with `#FFFFFF` text. Used for secondary critical decisions like "Call Paramedic" or "Share Live Medical ID".
- **Ghost Action / Bordered:** 56px height. Crisp 1.5px border in `#CBD5E1` on `#FFFFFF` background, `#0F172A` text. Used for non-urgent updates (e.g., "Edit Landmark Notes").

### Status Badges & Pills
- **Searching Badge:** Amber background (`#FEF3C7`), text and dot indicator in `#D97706`. Pulse animation applied to the leading 8px indicator circle.
- **Assigned / En Route Badge:** Emerald background (`#D1FAE5`), text and leading indicator in `#047857`.
- **Urgent / Diverted Badge:** Crimson background (`#FEE2E2`), text and icon in `#B91C1C`.
- Geometry: Minimum 32px height, 12px horizontal padding, full pill radius (`rounded-full`).

### Dispatch Cards
- Constructed on pure `#FFFFFF` with a 1px `#E2E8F0` border and `1rem` corner rounding.
- Structured with internal 16px padding, separating unit details, responder photo/license ID, live telemetry ETA clock, and direct one-tap telephone links via crisp 1px hairpins.

### Input Fields & Location Pickers
- Height of 56px. Background `#F8FAFC`, transitioning to `#FFFFFF` with a 2px `#0F172A` outline on focus.
- Leading icons for pickup pinpoint (pulsing `#B91C1C`) and trailing clear or voice-input triggers sized at 24px within a 48px hit box.

### Telemetry Counter
- Large numerical display using `telemetry-numeral` (`Manrope`, 32px, bold) for arriving minutes, paired directly with an uppercase `label-sm` unit label ("MIN AWAY") in `#64748B`.