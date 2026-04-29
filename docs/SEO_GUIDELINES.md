# CarCheck SEO Guidelines

Best practices for creating SEO-optimised pages in the CarCheck platform.

## Overview

Our SEO strategy targets car enthusiasts, DIY mechanics, and used car buyers in the UK searching for:
- `[Make] [Model] common faults`
- `[Make] [Model] parts prices UK`
- `[Make] [Model] buyer's guide`
- `[Make] [Model] reliability`
- `[Make] [Model] MOT failures`

## Page Structure

### URL Format
- Car model pages: `/cars/{make}/{model}` (e.g., `/cars/bmw/3-series`)
- Part searches: `/parts?make={make}&model={model}&query={term}`
- Faults: `/faults?make={make}&model={model}`
- Buyer guides: `/guide?make={make}&model={model}`

Use lowercase, hyphenated slugs: `mercedes-benz`, `a-class`, `timing-chain-kit`.

### Title Tags

Format: `{Make} {Model} - {Primary Value Proposition} | CarCheck`

**Examples:**
- `BMW 3 Series - Common Faults, Parts Prices & Buyer's Guide UK | CarCheck`
- `Ford Focus Parts - Compare Prices from eBay, Amazon & Autodoc | CarCheck`
- `Audi A4 Timing Chain Problems - Cost Guide UK 2025 | CarCheck`

**Rules:**
- Keep under 60 characters
- Primary keyword near start
- Include geographic modifier (UK) where relevant
- End with brand

### Meta Descriptions

Format: 150-160 characters describing page value and CTA.

**Template:**
```
Complete {Make} {Model} buyer's guide for UK. Find common faults, compare parts prices 
across eBay, Amazon & Autodoc, check reliability scores, and read MOT failure patterns. 
Updated {Month} {Year}.
```

**Rules:**
- Include primary keyword
- Mention UK explicitly
- Add freshness signal (date)
- Include call-to-action or value proposition
- No duplicate descriptions across pages

## Structured Data (JSON-LD)

We use Schema.org structured data for rich snippets. See `/frontend/src/components/seo/carModelSchema.ts`.

### Required Schemas per Page Type

**Car Model Landing Page (`/cars/{make}/{model}`):**
- `WebPage` with breadcrumb
- `FAQPage` for FAQ section
- `Car` or `Vehicle` entity
- `Article` if editorial content present
- `Review` with aggregate rating
- `ItemList` for parts comparison

**Parts Search Page (`/parts`):**
- `Product` schema for each part
- `Offer` with price, seller, availability
- `AggregateOffer` for price comparison

**Faults Page (`/faults`):**
- `HowTo` for repair guides
- `FAQPage` for fault questions

### Implementation Example

```tsx
import { SEOHead } from '../components/seo';
import { getCarModelPageSchema } from '../components/seo/carModelSchema';

function CarPage() {
  const structuredData = getCarModelPageSchema({
    make: 'BMW',
    model: '3 Series',
    description: 'Complete BMW 3 Series buyer\'s guide...',
    reliabilityScore: 7.5,
    faqs: [
      { question: 'What are common faults?', answer: '...' },
    ],
  });

  return (
    <>
      <SEOHead
        title="BMW 3 Series - Common Faults & Parts Prices UK"
        description="..."
        canonicalUrl="/cars/bmw/3-series"
        keywords={['bmw 3 series faults', 'bmw 3 series parts']}
        structuredData={structuredData}
      />
      {/* Page content */}
    </>
  );
}
```

## Content Guidelines

### Heading Hierarchy

Every page must have exactly one `<h1>` containing the primary keyword.

```html
<h1>BMW 3 Series - Common Faults, Parts & Buyer's Guide</h1>
  <h2>Common Faults</h2>
    <h3>Timing Chain Issues</h3>
    <h3>Water Pump Failure</h3>
  <h2>Parts Prices</h2>
  <h2>Reliability Score</h2>
  <h2>Frequently Asked Questions</h2>
```

### Content Sections for Car Model Pages

1. **Hero Section** - Make, model, quick stats, primary CTAs
2. **Common Faults** - Top 5-10 faults with severity and cost
3. **Parts Categories** - Popular parts with pricing
4. **Buyer's Guide Highlights** - Pros/cons, what to look for
5. **MOT Failure Patterns** - Common failure points
6. **FAQ Section** - 5-7 FAQs in Schema.org format
7. **CTA Section** - Final conversion prompt

### Writing Style

- Use UK English (colour, metre, tyre)
- Currency in GBP (£99.99)
- Reference UK-specific terms (MOT, DVLA)
- Include local context (UK garages, UK suppliers)
- Write for humans first, search engines second

## Technical SEO

### Canonical URLs

Always set canonical URL to prevent duplicate content:

```tsx
<SEOHead canonicalUrl="/cars/bmw/3-series" />
```

### Breadcrumbs

Implement both visual breadcrumbs and Schema.org BreadcrumbList:

```
Home > Cars > BMW > 3 Series
```

### Internal Linking

- Link from car pages to parts finder
- Link from faults to buyer's guide
- Cross-link between related models (e.g., BMW 3 Series → BMW 5 Series)

### Page Speed

- Lazy load images below fold
- Use next-gen formats (WebP) where supported
- Server-side render critical content
- Target Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1

### Mobile-First

- All pages must be mobile-responsive
- Touch targets minimum 44x44px
- Text readable without zoom (16px base)

## Sitemap & Indexing

### Static Pages (submit in sitemap)
- `/` (homepage)
- `/parts`
- `/guide`
- `/pricing`

### Dynamic Pages (generate programmatically)
- `/cars/{make}` - one per make
- `/cars/{make}/{model}` - one per make/model combination

### robots.txt

```
User-agent: *
Allow: /
Sitemap: https://carcheck.uk/sitemap.xml

Disallow: /api/
Disallow: /login
Disallow: /signup
Disallow: /subscription/
```

## Performance Monitoring

Track these metrics in Google Search Console:
- Click-through rate (CTR) by page
- Average position for target keywords
- Impressions by query
- Mobile usability issues

## Keyword Research Reference

### Primary Keywords (by intent)

**Transactional (parts buying):**
- `[make] [model] parts UK`
- `buy [make] [model] [part] online`
- `cheap [make] [model] parts`

**Informational (research):**
- `[make] [model] common problems`
- `[make] [model] reliability issues`
- `are [make] [model] reliable`
- `[make] [model] things to check`

**Commercial Investigation:**
- `[make] [model] buyer's guide`
- `used [make] [model] review`
- `[make] [model] vs [competitor]`

### Long-Tail Examples

- `bmw 3 series n47 timing chain failure`
- `ford focus mk3 powershift gearbox problems`
- `audi a4 b8 oil consumption fix`
- `vw golf mk7 dsg gearbox issues`

## Schema Function Reference

| Function | Purpose | Page Types |
|----------|---------|------------|
| `getCarFAQSchema()` | FAQ rich snippets | Car model, faults |
| `getPartsProductSchema()` | Product listings | Parts search |
| `getVehicleSchema()` | Car/Vehicle entity | Car model |
| `getBuyersGuideArticleSchema()` | Article schema | Buyer's guide |
| `getBreadcrumbSchema()` | Navigation breadcrumb | All pages |
| `getReliabilityReviewSchema()` | Review/rating data | Car model |
| `getPartsComparisonListSchema()` | ItemList for parts | Parts comparison |
| `getCarModelPageSchema()` | Combined graph | Car model landing |

## Updates

- Review and update this document quarterly
- Track algorithm changes from Google Search Central
- A/B test title/description changes monthly

---

*Last updated: January 2025*
