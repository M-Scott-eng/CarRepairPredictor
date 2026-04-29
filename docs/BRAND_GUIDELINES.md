# CarCheck Brand Guidelines

## Brand Overview

**CarCheck** (formerly "Car Repair Predictor") is a UK-focused service that helps used car buyers predict repair costs before purchasing a vehicle.

### Brand Positioning
- **Trustworthy**: Data-driven predictions you can rely on
- **Accessible**: Simple to use, no automotive expertise required
- **UK-Focused**: Built specifically for the British market

---

## Brand Names

### Primary Name
**CarCheck** - Clean, memorable, and directly communicates the service's purpose.

### Alternative Options Considered
1. **PredictMyRepairs** - Descriptive but longer
2. **CarCostCheck** - Alliterative but complex
3. **MotorGuard** - Premium feel, less descriptive
4. **CheckMyCar UK** - UK-focused but generic
5. **RepairRadar** - Catchy but less clear

### Domain
- Primary: `carcheck.co.uk`
- Current: `carrepairpredictor.co.uk`

---

## Logo System

### Primary Logo
The CarCheck logo combines a stylised car silhouette with a verification checkmark badge. This represents:
- **Car**: The automotive focus of our service
- **Checkmark**: Trust, verification, and peace of mind
- **Green badge**: Positive outcomes and approval

### Logo Variants
| Variant | Use Case |
|---------|----------|
| `logo.svg` | Primary logo with car + checkmark |
| `car-icon.svg` | Favicon and small contexts |
| `apple-touch-icon.svg` | iOS home screen icon |
| `og-image.svg` | Social media sharing |

### Clear Space
Maintain minimum clear space equal to the height of the checkmark badge around all sides of the logo.

### Minimum Size
- Digital: 32px height minimum
- Print: 15mm height minimum

---

## Color Palette

### Primary Colors
| Name | Hex | Tailwind | Usage |
|------|-----|----------|-------|
| Primary Blue | `#2563eb` | `blue-600` | Primary brand color, CTAs |
| Primary Dark | `#1e40af` | `blue-800` | Headers, emphasis |
| Primary Light | `#3b82f6` | `blue-500` | Hover states, accents |

### Secondary Colors
| Name | Hex | Tailwind | Usage |
|------|-----|----------|-------|
| Success Green | `#10b981` | `emerald-500` | Checkmark, positive indicators |
| Warning Amber | `#f59e0b` | `amber-500` | Warnings, attention |
| Error Red | `#ef4444` | `red-500` | Errors, critical alerts |

### Neutral Colors
| Name | Hex | Tailwind | Usage |
|------|-----|----------|-------|
| Dark Navy | `#1e3a5f` | Custom | Wheels, dark accents |
| Slate | `#64748b` | `slate-500` | Secondary text |
| Light Blue | `#bfdbfe` | `blue-200` | Backgrounds, windows |

---

## Typography

### Primary Font
**Inter** - A modern, highly legible sans-serif optimised for screens.

```css
font-family: 'Inter', system-ui, -apple-system, sans-serif;
```

### Type Scale
| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| H1 | 48px / 3rem | Bold (700) | Page titles |
| H2 | 36px / 2.25rem | Semibold (600) | Section headers |
| H3 | 24px / 1.5rem | Semibold (600) | Card titles |
| Body | 16px / 1rem | Regular (400) | Body text |
| Small | 14px / 0.875rem | Regular (400) | Captions, labels |

---

## Voice & Tone

### Brand Voice
- **Clear**: No jargon, plain English
- **Helpful**: Focused on user benefit
- **Confident**: Data-backed statements
- **Friendly**: Approachable, not corporate

### Writing Examples

✅ **Do say:**
- "Get peace of mind before you buy"
- "Know what repairs to expect"
- "Based on real UK MOT data"

❌ **Don't say:**
- "Revolutionary AI-powered solution"
- "Guaranteed accurate predictions"
- "The best car checker in the world"

---

## Iconography

Use **Lucide React** icons throughout the application for consistency.

### Key Icons
| Icon | Usage |
|------|-------|
| `Car` | Vehicle references |
| `Shield` | Trust, security |
| `Search` | Analysis, checking |
| `PoundSterling` | Costs, pricing |
| `CheckCircle` | Success, verified |
| `AlertTriangle` | Warnings |

---

## Photography & Imagery

### Style Guidelines
- Real UK cars (not stock American vehicles)
- Clean, well-lit images
- Focus on common makes: Ford, Vauxhall, BMW, Audi, VW
- Avoid perfect showroom shots; show realistic used cars

### Image Treatment
- Slight blue tint overlay for brand consistency
- Rounded corners (8px-16px)
- Subtle shadows for depth

---

## Application Examples

### Website Header
```
[Logo] CarCheck | Predict | Pricing | Login
```

### Social Media Bio
```
🚗 Know what repairs to expect before you buy
📊 Data-driven predictions for UK used cars
🇬🇧 Built for British drivers
```

### Email Signature
```
CarCheck - Predict Repair Costs
carrepairpredictor.co.uk
```

---

## File Locations

```
frontend/public/
├── logo.svg              # Primary logo
├── car-icon.svg          # Favicon
├── apple-touch-icon.svg  # iOS icon
├── og-image.svg          # Social sharing
├── robots.txt            # SEO
└── sitemap.xml           # SEO
```

---

## Contact

For brand asset requests or guidelines questions:
- Email: brand@carrepairpredictor.co.uk

---

*Last updated: April 2026*
