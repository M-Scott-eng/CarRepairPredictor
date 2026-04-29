import { BASE_URL } from './SEOHead';

/**
 * Generate FAQ structured data for a car model page.
 */
export function getCarFAQSchema(make: string, model: string, faqs: { question: string; answer: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map(faq => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  };
}

/**
 * Generate Product structured data for parts comparison.
 */
export function getPartsProductSchema(part: {
  name: string;
  brand: string;
  price: number;
  currency?: string;
  availability?: string;
  url: string;
  image?: string;
  rating?: number;
  reviewCount?: number;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: part.name,
    brand: {
      '@type': 'Brand',
      name: part.brand,
    },
    offers: {
      '@type': 'Offer',
      price: part.price,
      priceCurrency: part.currency || 'GBP',
      availability: part.availability === 'InStock' 
        ? 'https://schema.org/InStock' 
        : 'https://schema.org/LimitedAvailability',
      url: part.url,
    },
    ...(part.image && { image: part.image }),
    ...(part.rating && {
      aggregateRating: {
        '@type': 'AggregateRating',
        ratingValue: part.rating,
        reviewCount: part.reviewCount || 0,
      },
    }),
  };
}

/**
 * Generate Vehicle structured data for a car model.
 */
export function getVehicleSchema(options: {
  make: string;
  model: string;
  year?: number;
  bodyType?: string;
  fuelType?: string;
  description: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Car',
    name: `${options.make} ${options.model}${options.year ? ` ${options.year}` : ''}`,
    brand: {
      '@type': 'Brand',
      name: options.make,
    },
    model: options.model,
    ...(options.year && { modelDate: options.year.toString() }),
    ...(options.bodyType && { bodyType: options.bodyType }),
    ...(options.fuelType && { fuelType: options.fuelType }),
    description: options.description,
  };
}

/**
 * Generate Article structured data for buyer's guide content.
 */
export function getBuyersGuideArticleSchema(options: {
  make: string;
  model: string;
  year?: number;
  headline: string;
  description: string;
  datePublished: string;
  dateModified?: string;
  imageUrl?: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: options.headline,
    description: options.description,
    author: {
      '@type': 'Organization',
      name: 'CarCheck',
      url: BASE_URL,
    },
    publisher: {
      '@type': 'Organization',
      name: 'CarCheck',
      url: BASE_URL,
      logo: {
        '@type': 'ImageObject',
        url: `${BASE_URL}/logo.png`,
      },
    },
    datePublished: options.datePublished,
    dateModified: options.dateModified || options.datePublished,
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `${BASE_URL}/cars/${options.make.toLowerCase()}/${options.model.toLowerCase().replace(/\s+/g, '-')}`,
    },
    about: {
      '@type': 'Car',
      name: `${options.make} ${options.model}`,
      brand: { '@type': 'Brand', name: options.make },
    },
    ...(options.imageUrl && { image: options.imageUrl }),
  };
}

/**
 * Generate BreadcrumbList structured data for navigation.
 */
export function getBreadcrumbSchema(items: { name: string; url: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: `${BASE_URL}${item.url}`,
    })),
  };
}

/**
 * Generate Review structured data for reliability ratings.
 */
export function getReliabilityReviewSchema(options: {
  make: string;
  model: string;
  overallRating: number;
  reliabilityScore: number;
  runningCostScore: number;
  reviewBody: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Review',
    itemReviewed: {
      '@type': 'Car',
      name: `${options.make} ${options.model}`,
      brand: { '@type': 'Brand', name: options.make },
    },
    reviewRating: {
      '@type': 'Rating',
      ratingValue: options.overallRating,
      bestRating: 10,
      worstRating: 1,
    },
    author: {
      '@type': 'Organization',
      name: 'CarCheck',
    },
    reviewBody: options.reviewBody,
  };
}

/**
 * Generate ItemList structured data for parts comparison tables.
 */
export function getPartsComparisonListSchema(parts: {
  name: string;
  brand: string;
  price: number;
  supplier: string;
  url: string;
}[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'ItemList',
    name: 'Parts Price Comparison',
    numberOfItems: parts.length,
    itemListElement: parts.map((part, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      item: {
        '@type': 'Product',
        name: part.name,
        brand: { '@type': 'Brand', name: part.brand },
        offers: {
          '@type': 'Offer',
          price: part.price,
          priceCurrency: 'GBP',
          seller: { '@type': 'Organization', name: part.supplier },
          url: part.url,
        },
      },
    })),
  };
}

/**
 * Generate combined schema graph for a car model landing page.
 */
export function getCarModelPageSchema(options: {
  make: string;
  model: string;
  year?: number;
  description: string;
  bodyType?: string;
  reliabilityScore: number;
  faqs: { question: string; answer: string }[];
}) {
  const vehicleSlug = `${options.make.toLowerCase()}/${options.model.toLowerCase().replace(/\s+/g, '-')}`;
  
  return {
    '@context': 'https://schema.org',
    '@graph': [
      // WebPage
      {
        '@type': 'WebPage',
        '@id': `${BASE_URL}/cars/${vehicleSlug}#webpage`,
        url: `${BASE_URL}/cars/${vehicleSlug}`,
        name: `${options.make} ${options.model} - Common Faults, Parts & Buyer's Guide`,
        description: options.description,
        isPartOf: { '@id': `${BASE_URL}#website` },
        breadcrumb: { '@id': `${BASE_URL}/cars/${vehicleSlug}#breadcrumb` },
        inLanguage: 'en-GB',
      },
      // BreadcrumbList
      {
        '@type': 'BreadcrumbList',
        '@id': `${BASE_URL}/cars/${vehicleSlug}#breadcrumb`,
        itemListElement: [
          { '@type': 'ListItem', position: 1, name: 'Home', item: BASE_URL },
          { '@type': 'ListItem', position: 2, name: 'Cars', item: `${BASE_URL}/cars` },
          { '@type': 'ListItem', position: 3, name: options.make, item: `${BASE_URL}/cars/${options.make.toLowerCase()}` },
          { '@type': 'ListItem', position: 4, name: options.model },
        ],
      },
      // Vehicle
      {
        '@type': 'Car',
        '@id': `${BASE_URL}/cars/${vehicleSlug}#vehicle`,
        name: `${options.make} ${options.model}`,
        brand: { '@type': 'Brand', name: options.make },
        model: options.model,
        ...(options.year && { modelDate: options.year.toString() }),
        ...(options.bodyType && { bodyType: options.bodyType }),
        aggregateRating: {
          '@type': 'AggregateRating',
          ratingValue: options.reliabilityScore,
          bestRating: 10,
          ratingCount: 1,
        },
      },
      // FAQPage
      {
        '@type': 'FAQPage',
        '@id': `${BASE_URL}/cars/${vehicleSlug}#faq`,
        mainEntity: options.faqs.map(faq => ({
          '@type': 'Question',
          name: faq.question,
          acceptedAnswer: { '@type': 'Answer', text: faq.answer },
        })),
      },
    ],
  };
}
