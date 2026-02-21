# Kermicle Media Brand Guide

## Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Deep Black | `#0d0d0d` | Page/body background |
| Dark Gray | `#1a1a1a` | Cards, panels, containers |
| Mid Gray | `#2a2a2a` | Borders, dividers, input backgrounds |
| Light Text | `#e0e0e0` | Primary text |
| Muted Text | `#999999` | Secondary/placeholder text |
| Gold | `#d4a843` | Accent — buttons, links, headings, borders |
| Gold Hover | `#e6bc5a` | Lighter gold for hover states |
| Success | `#4caf50` | Success states |
| Error | `#f44336` | Error states |

## Typography

- **Font Stack**: `'Segoe UI', system-ui, -apple-system, sans-serif`
- **Headings**: Bold, gold (#d4a843), letter-spacing: 0.5px
- **Body**: 16px base, line-height 1.6, #e0e0e0
- **Small/Labels**: 13px, #999999

## Component Styles

### Buttons
```css
.btn {
  background: #d4a843;
  color: #0d0d0d;
  border: none;
  padding: 10px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}
.btn:hover {
  background: #e6bc5a;
  box-shadow: 0 0 15px rgba(212, 168, 67, 0.3);
}
```

### Cards
```css
.card {
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 12px;
  padding: 24px;
  transition: all 0.3s ease;
}
.card:hover {
  border-color: #d4a843;
  box-shadow: 0 0 20px rgba(212, 168, 67, 0.15);
}
```

### Inputs
```css
input, textarea, select {
  background: #2a2a2a;
  border: 1px solid #333;
  color: #e0e0e0;
  padding: 10px 14px;
  border-radius: 8px;
  font-family: 'Segoe UI', system-ui, sans-serif;
}
input:focus {
  border-color: #d4a843;
  outline: none;
  box-shadow: 0 0 8px rgba(212, 168, 67, 0.2);
}
```

### Navigation
- Dark background (#0d0d0d or #111)
- Gold active/hover state
- Bottom border indicator for active tab: `border-bottom: 2px solid #d4a843`

## Responsive Breakpoints

- Mobile: < 768px (single column, stacked layout)
- Tablet: 768px–1024px (2 columns)
- Desktop: > 1024px (full layout)

## Spacing

- Section padding: 40px
- Card gap: 20px
- Inner padding: 24px
- Consistent 8px grid system

## Animations

- Transitions: `all 0.3s ease`
- Hover glow: `box-shadow: 0 0 15px rgba(212, 168, 67, 0.3)`
- Subtle fade-ins on page load (optional)
