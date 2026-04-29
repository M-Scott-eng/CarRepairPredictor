import { BASE_URL } from './SEOHead';

/**
 * Organization schema for the website.
 */
export function getOrganizationSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'Car Repair Predictor',
    url: BASE_URL,
    logo: `${BASE_URL}/logo.png`,
    description: 'UK-based service for predicting used car repair costs and reliability.',
    address: {
      '@type': 'PostalAddress',
      addressCountry: 'GB',
    },
    sameAs: [
      'https://twitter.com/carrepairpredict',
      'https://facebook.com/carrepairpredictor',
    ],
    contactPoint: {
      '@type': 'ContactPoint',
      contactType: 'customer service',
      email: 'support@carrepairpredictor.co.uk',
      availableLanguage: 'English',
    },
  };
}

/**
 * WebSite schema for search box support.
 */
export function getWebsiteSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'Car Repair Predictor',
    url: BASE_URL,
    potentialAction: {
      '@type': 'SearchAction',
      target: {
        '@type': 'EntryPoint',
        urlTemplate: `${BASE_URL}/predict?make={search_term_string}`,
      },
      'query-input': 'required name=search_term_string',
    },
  };
}

/**
 * WebPage schema for individual pages.
 */
export function getWebPageSchema(options: {
  name: string;
  description: string;
  url: string;
  dateModified?: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebPage',
    name: options.name,
    description: options.description,
    url: `${BASE_URL}${options.url}`,
    isPartOf: {
      '@type': 'WebSite',
      name: 'Car Repair Predictor',
      url: BASE_URL,
    },
    ...(options.dateModified && { dateModified: options.dateModified }),
  };
}

/**
 * Service schema for the prediction service.
 */
export function getServiceSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Service',
    name: 'Used Car Repair Cost Prediction',
    description: 'Predict potential repair costs and reliability issues for used vehicles based on make, model, age, and mileage.',
    provider: {
      '@type': 'Organization',
      name: 'Car Repair Predictor',
      url: BASE_URL,
    },
    serviceType: 'Automotive Reliability Analysis',
    areaServed: {
      '@type': 'Country',
      name: 'United Kingdom',
    },
    hasOfferCatalog: {
      '@type': 'OfferCatalog',
      name: 'Prediction Plans',
      itemListElement: [
        {
          '@type': 'Offer',
          itemOffered: {
            '@type': 'Service',
            name: 'Free Plan',
          },
          price: '0',
          priceCurrency: 'GBP',
        },
        {
          '@type': 'Offer',
          itemOffered: {
            '@type': 'Service',
            name: 'Basic Plan',
          },
          price: '4.99',
          priceCurrency: 'GBP',
        },
        {
          '@type': 'Offer',
          itemOffered: {
            '@type': 'Service',
            name: 'Premium Plan',
          },
          price: '14.99',
          priceCurrency: 'GBP',
        },
      ],
    },
  };
}

/**
 * FAQ schema for frequently asked questions.
 */
export function getFAQSchema(faqs: Array<{ question: string; answer: string }>) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((faq) => ({
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
 * BreadcrumbList schema for navigation.
 */
export function getBreadcrumbSchema(
  items: Array<{ name: string; url: string }>
) {
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
 * SoftwareApplication schema for the app.
 */
export function getSoftwareApplicationSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'Car Repair Predictor',
    applicationCategory: 'UtilitiesApplication',
    operatingSystem: 'Web',
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'GBP',
    },
    aggregateRating: {
      '@type': 'AggregateRating',
      ratingValue: '4.7',
      ratingCount: '1250',
      bestRating: '5',
      worstRating: '1',
    },
  };
}

/**
 * Vehicle schema for car-specific pages.
 */
export function getVehicleSchema(vehicle: {
  make: string;
  model: string;
  year: number;
  mileage?: number;
  fuelType?: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Car',
    name: `${vehicle.year} ${vehicle.make} ${vehicle.model}`,
    manufacturer: {
      '@type': 'Organization',
      name: vehicle.make,
    },
    model: vehicle.model,
    vehicleModelDate: vehicle.year.toString(),
    ...(vehicle.mileage && { mileageFromOdometer: {
      '@type': 'QuantitativeValue',
      value: vehicle.mileage,
      unitCode: 'SMI',
    }}),
    ...(vehicle.fuelType && { fuelType: vehicle.fuelType }),
  };
}

/**
 * Article schema for blog posts or guides.
 */
export function getArticleSchema(article: {
  headline: string;
  description: string;
  url: string;
  datePublished: string;
  dateModified?: string;
  author?: string;
  image?: string;
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: article.headline,
    description: article.description,
    url: `${BASE_URL}${article.url}`,
    datePublished: article.datePublished,
    dateModified: article.dateModified || article.datePublished,
    author: {
      '@type': 'Organization',
      name: article.author || 'Car Repair Predictor',
    },
    publisher: {
      '@type': 'Organization',
      name: 'Car Repair Predictor',
      logo: {
        '@type': 'ImageObject',
        url: `${BASE_URL}/logo.png`,
      },
    },
    ...(article.image && { image: article.image }),
  };
}

/**
 * LocalBusiness schema (optional, for local presence).
 */
export function getLocalBusinessSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'ProfessionalService',
    name: 'Car Repair Predictor',
    url: BASE_URL,
    description: 'Online service for predicting used car repair costs in the UK.',
    priceRange: '£0 - £15/month',
    address: {
      '@type': 'PostalAddress',
      addressCountry: 'GB',
    },
    geo: {
      '@type': 'GeoCoordinates',
      latitude: 51.5074,
      longitude: -0.1278,
    },
    openingHoursSpecification: {
      '@type': 'OpeningHoursSpecification',
      dayOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      opens: '00:00',
      closes: '23:59',
    },
  };
}
