// Parts Finder API Types

export interface PartsSearchRequest {
  make: string;
  model: string;
  year?: number;
  engineCode?: string;
  partCategory?: string;
  searchQuery?: string;
  oemPartNumber?: string;
  maxResults?: number;
  maxPrice?: number;
  newOnly?: boolean;
  sortBy?: 'price' | 'rating' | 'delivery' | 'relevance';
  ascending?: boolean;
}

export interface NormalisedPartResult {
  resultId: string;
  supplierId: string;
  supplierName: string;
  externalId: string;
  title: string;
  brand?: string;
  oemPartNumber?: string;
  supplierPartNumber?: string;
  priceGbp: number;
  shippingGbp?: number;
  totalPriceGbp: number;
  condition?: string;
  availability?: string;
  stockQuantity?: number;
  sellerName?: string;
  sellerRating?: number;
  sellerReviewCount?: number;
  estimatedDeliveryDays?: number;
  deliveryInfo?: string;
  productUrl: string;
  affiliateUrl?: string;
  imageUrl?: string;
  description?: string;
  isPrime?: boolean;
  isFeatured?: boolean;
  relevanceScore: number;
  fetchedAt: string;
}

export interface PartsSearchMetadata {
  searchId: string;
  totalResults: number;
  lowestPrice?: number;
  highestPrice?: number;
  averagePrice?: number;
  suppliersQueried: number;
  suppliersSucceeded: number;
  searchDuration: string;
  searchedAt: string;
  fromCache: boolean;
}

export interface SupplierStatus {
  supplierId: string;
  supplierName: string;
  success: boolean;
  resultCount: number;
  responseTime: string;
  errorMessage?: string;
  rateLimited: boolean;
  fromCache: boolean;
}

export interface PartsSearchResponse {
  results: NormalisedPartResult[];
  metadata: PartsSearchMetadata;
  supplierStatuses: SupplierStatus[];
}

export interface SupplierHealthStatus {
  supplierId: string;
  supplierName: string;
  isHealthy: boolean;
  successRate: number;
  averageResponseTime: string;
  requestsLastHour: number;
  errorsLastHour: number;
}

export interface SupplierHealthResponse {
  totalSuppliers: number;
  healthySuppliers: number;
  suppliers: SupplierHealthStatus[];
}

// Common Faults Types
export interface CommonFault {
  id: number;
  title: string;
  description: string;
  symptoms: string[];
  typicalMileage: string;
  repairCostRange: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  affectedYears?: string;
  partsNeeded?: string[];
}

export interface CommonFaultsResponse {
  faults: CommonFault[];
  make: string;
  model: string;
  totalFaults: number;
}

// Car Selection Types
export interface CarMake {
  id: number;
  name: string;
  logoUrl?: string;
  popularModels?: string[];
}

export interface CarModel {
  id: number;
  name: string;
  makeId: number;
  yearRange?: string;
  popularEngines?: string[];
}

export interface CarYear {
  year: number;
  modelId: number;
}

export interface CarEngine {
  id: number;
  code: string;
  name: string;
  displacement: string;
  fuelType: string;
}

// Buyer's Guide Types
export interface BuyersGuideSection {
  id: string;
  title: string;
  content: string;
  tips?: string[];
  warnings?: string[];
}

export interface BuyersGuideResponse {
  make: string;
  model: string;
  year?: number;
  overallRating: number;
  reliabilityScore: number;
  runningCostScore: number;
  sections: BuyersGuideSection[];
  prosAndCons: {
    pros: string[];
    cons: string[];
  };
  verdictSummary: string;
}
