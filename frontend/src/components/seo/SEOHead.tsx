import { Helmet } from 'react-helmet-async';

interface SEOHeadProps {
  title?: string;
  description?: string;
  keywords?: string[];
  canonicalUrl?: string;
  ogType?: 'website' | 'article' | 'product';
  ogImage?: string;
  noIndex?: boolean;
  structuredData?: object;
}

const SITE_NAME = 'Car Repair Predictor';
const DEFAULT_DESCRIPTION = 'Predict repair costs for used cars in the UK. Get accurate estimates for potential failures, MOT issues, and maintenance costs before you buy.';
const DEFAULT_KEYWORDS = [
  'used car repair costs',
  'car reliability check',
  'MOT failure prediction',
  'car maintenance costs UK',
  'used car buying guide',
  'vehicle repair estimate',
  'car fault predictor',
  'UK car costs'
];
const BASE_URL = 'https://carrepairpredictor.co.uk';
const DEFAULT_IMAGE = `${BASE_URL}/og-image.jpg`;

/**
 * SEO Head component for managing meta tags across pages.
 */
export default function SEOHead({
  title,
  description = DEFAULT_DESCRIPTION,
  keywords = DEFAULT_KEYWORDS,
  canonicalUrl,
  ogType = 'website',
  ogImage = DEFAULT_IMAGE,
  noIndex = false,
  structuredData,
}: SEOHeadProps) {
  const fullTitle = title ? `${title} | ${SITE_NAME}` : SITE_NAME;
  const fullCanonicalUrl = canonicalUrl ? `${BASE_URL}${canonicalUrl}` : undefined;

  return (
    <Helmet>
      {/* Primary Meta Tags */}
      <title>{fullTitle}</title>
      <meta name="title" content={fullTitle} />
      <meta name="description" content={description} />
      <meta name="keywords" content={keywords.join(', ')} />
      
      {/* Robots */}
      {noIndex ? (
        <meta name="robots" content="noindex, nofollow" />
      ) : (
        <meta name="robots" content="index, follow" />
      )}
      
      {/* Canonical URL */}
      {fullCanonicalUrl && <link rel="canonical" href={fullCanonicalUrl} />}
      
      {/* Open Graph / Facebook */}
      <meta property="og:type" content={ogType} />
      <meta property="og:site_name" content={SITE_NAME} />
      <meta property="og:title" content={fullTitle} />
      <meta property="og:description" content={description} />
      <meta property="og:image" content={ogImage} />
      {fullCanonicalUrl && <meta property="og:url" content={fullCanonicalUrl} />}
      <meta property="og:locale" content="en_GB" />
      
      {/* Twitter */}
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={fullTitle} />
      <meta name="twitter:description" content={description} />
      <meta name="twitter:image" content={ogImage} />
      
      {/* Additional Meta */}
      <meta name="author" content="Car Repair Predictor" />
      <meta name="geo.region" content="GB" />
      <meta name="geo.placename" content="United Kingdom" />
      <meta name="language" content="English" />
      
      {/* Structured Data */}
      {structuredData && (
        <script type="application/ld+json">
          {JSON.stringify(structuredData)}
        </script>
      )}
    </Helmet>
  );
}

export { SITE_NAME, DEFAULT_DESCRIPTION, DEFAULT_KEYWORDS, BASE_URL };
