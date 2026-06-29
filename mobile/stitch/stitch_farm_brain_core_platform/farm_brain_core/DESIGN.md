---
name: Farm Brain Core
colors:
  surface: '#f7fbf1'
  surface-dim: '#d8dbd2'
  surface-bright: '#f7fbf1'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f5ec'
  surface-container: '#ecefe6'
  surface-container-high: '#e6e9e0'
  surface-container-highest: '#e0e4db'
  on-surface: '#191d17'
  on-surface-variant: '#41493e'
  inverse-surface: '#2d322c'
  inverse-on-surface: '#eff2e9'
  outline: '#717a6d'
  outline-variant: '#c0c9bb'
  surface-tint: '#2a6b2c'
  primary: '#00450d'
  on-primary: '#ffffff'
  primary-container: '#1b5e20'
  on-primary-container: '#90d689'
  inverse-primary: '#91d78a'
  secondary: '#1b6d24'
  on-secondary: '#ffffff'
  secondary-container: '#a0f399'
  on-secondary-container: '#217128'
  tertiary: '#6b1d3d'
  on-tertiary: '#ffffff'
  tertiary-container: '#883454'
  on-tertiary-container: '#ffaec6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#acf4a4'
  primary-fixed-dim: '#91d78a'
  on-primary-fixed: '#002203'
  on-primary-fixed-variant: '#0c5216'
  secondary-fixed: '#a3f69c'
  secondary-fixed-dim: '#88d982'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005312'
  tertiary-fixed: '#ffd9e2'
  tertiary-fixed-dim: '#ffb1c8'
  on-tertiary-fixed: '#3e001d'
  on-tertiary-fixed-variant: '#7a2949'
  background: '#f7fbf1'
  on-background: '#191d17'
  surface-variant: '#e0e4db'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
  data-mono:
    fontFamily: monospace
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base_unit: 8px
  margin_mobile: 16px
  margin_desktop: 24px
  gutter: 16px
  stack_sm: 4px
  stack_md: 8px
  stack_lg: 16px
---

## Brand & Style
The design system for this platform is engineered for high-utility, field-operable agricultural management. It balances professional-grade reliability with a modern, data-dense aesthetic. The brand personality is authoritative yet approachable, reflecting the precision of modern ag-tech. 

The visual style follows a **Modern Corporate** approach, heavily influenced by Material Design 3 (MD3) principles but optimized for high-density information display. It prioritizes clarity, systematic hierarchy, and rapid scanning of complex datasets. The interface uses a clean, structured layout with subtle depth to guide the user's eye toward critical operational metrics and status indicators.

## Colors
This design system utilizes an "Agri-Tech Premium" palette designed for readability in varying light conditions, including high-glare outdoor environments.

- **Primary & Secondary:** Deep Forest and Organic Leaf greens anchor the system in its agricultural roots, used for primary actions and brand presence.
- **Accent:** Intellectual Blue is reserved for technical data points, sync states, and interactive links to differentiate "system" information from "biological/crop" information.
- **Background & Surface:** A soft Eco-Gray background reduces eye strain compared to pure white, while Pure White surfaces are used for cards and containers to create a clear "layering" effect.
- **Semantic:** Standardized colors for critical alerts, warnings, and normal operation states, ensuring immediate recognition of farm health issues.

## Typography
Inter is used across all levels to ensure maximum legibility and a contemporary, technical feel. For high-density data lists, a monospace fallback or specialized mono-variant of Inter should be used for numerical values to ensure column alignment in tables.

Typography is structured to handle deeply nested hierarchies. Labels use a higher font weight (500-600) to remain visible at small sizes (12px) for technical metadata.

## Layout & Spacing
This design system employs an **8dp grid system** to ensure mathematical consistency across all components.

- **Mobile First:** The layout uses a fluid column system with 16dp side margins.
- **Data Density:** Vertical spacing is tightened in list views (8px between items) to maximize the information visible on a single screen without scrolling.
- **Grid:** A 4-column grid is used for mobile, expanding to 12-columns for tablet and desktop views. Component widths should always snap to the 8dp grid.

## Elevation & Depth
Consistent with MD3, depth is conveyed through **Tonal Layers** and subtle **Ambient Shadows**.

1.  **Level 0 (Background):** Soft Eco-Gray (#F5F7F5).
2.  **Level 1 (Cards/Surface):** Pure White with a 1px stroke (#E0E0E0) or a very soft shadow (Blur 4px, Y: 2px, 5% opacity).
3.  **Level 2 (Active/Hover):** Increased shadow depth to indicate interactivity.
4.  **Tonal Overlays:** Primary-colored surfaces with low opacity (e.g., 8% Forest Green) are used for selected states in lists or navigation items.

## Shapes
The design system uses a **Rounded** shape language (8px default) to soften the technical nature of the data and align with MD3 standards. 

- **Containers/Cards:** 8px (0.5rem) corner radius.
- **Pills/Chips:** Fully rounded (pill-shaped) to distinguish them from actionable buttons or data cards.
- **Input Fields:** 4px radius on the top corners when using underlined styles, or 8px when using outlined styles.

## Components

- **MD3 Cards:** Use "Elevated" style for primary dashboard metrics and "Outlined" style for secondary data sections to manage visual noise.
- **Top App Bar:** Contains a persistent "Sync Status" indicator. 
    - *Online:* Accent Blue icon.
    - *Offline:* Warning Orange icon with "Cached" label.
- **Bottom Navigation:** Fixed 4-5 item bar for mobile, providing instant access to Dashboard, Fields, Tasks, and Alerts.
- **Pill Filters:** Used at the top of data lists for rapid "Crop Type" or "Status" filtering. Use secondary green for active states.
- **Data Lists:** High-density rows (48px height) with leading icons for category and trailing text for timestamps or values.
- **Step Indicators:** Vertical indicators for multi-stage processes like "Chemical Application" or "Harvest Logistics," using semantic colors to show completion vs. pending status.
- **Buttons:**
    - *Primary:* Filled Forest Green with white text.
    - *Secondary:* Outlined Forest Green.
    - *Critical:* Filled Critical Red for destructive actions like "Cancel Batch."