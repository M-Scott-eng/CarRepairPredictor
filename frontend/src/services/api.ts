import axios from 'axios';
import type {
  PartsSearchRequest,
  PartsSearchResponse,
  SupplierHealthResponse,
  CommonFaultsResponse,
  BuyersGuideResponse,
} from '../types/parts';

const API_BASE = '/api/v1';

export const partsApi = {
  /**
   * Search for parts across all suppliers
   */
  searchParts: async (request: PartsSearchRequest): Promise<PartsSearchResponse> => {
    const params = new URLSearchParams();
    params.append('make', request.make);
    params.append('model', request.model);
    if (request.year) params.append('year', request.year.toString());
    if (request.engineCode) params.append('engineCode', request.engineCode);
    if (request.partCategory) params.append('category', request.partCategory);
    if (request.searchQuery) params.append('query', request.searchQuery);
    if (request.oemPartNumber) params.append('oemPartNumber', request.oemPartNumber);
    if (request.maxResults) params.append('maxResults', request.maxResults.toString());
    if (request.maxPrice) params.append('maxPrice', request.maxPrice.toString());
    if (request.newOnly) params.append('newOnly', 'true');
    if (request.sortBy) params.append('sortBy', request.sortBy);
    if (request.ascending !== undefined) params.append('ascending', request.ascending.toString());

    const response = await axios.get<PartsSearchResponse>(`${API_BASE}/parts/search?${params.toString()}`);
    return response.data;
  },

  /**
   * Get supplier health status
   */
  getSupplierHealth: async (): Promise<SupplierHealthResponse> => {
    const response = await axios.get<SupplierHealthResponse>(`${API_BASE}/parts/health`);
    return response.data;
  },

  /**
   * Get part details by supplier and external ID
   */
  getPartDetail: async (supplierId: string, externalPartId: string) => {
    const response = await axios.get(`${API_BASE}/parts/${supplierId}/${externalPartId}`);
    return response.data;
  },
};

export const carsApi = {
  /**
   * Get all makes
   */
  getMakes: async () => {
    const response = await axios.get<{ makes: { id: number; name: string }[] }>(`${API_BASE}/cars/makes`);
    return response.data.makes;
  },

  /**
   * Get models for a make
   */
  getModels: async (makeId: number) => {
    const response = await axios.get<{ models: { id: number; name: string; makeId: number }[] }>(
      `${API_BASE}/cars/models?makeId=${makeId}`
    );
    return response.data.models;
  },

  /**
   * Get years for a model
   */
  getYears: async (modelId: number) => {
    const response = await axios.get<{ years: number[] }>(`${API_BASE}/cars/years?modelId=${modelId}`);
    return response.data.years;
  },
};

export const faultsApi = {
  /**
   * Get common faults for a vehicle
   */
  getCommonFaults: async (make: string, model: string, _year?: number): Promise<CommonFaultsResponse> => {
    // Demo data - in production this would call the API
    const demoFaults: CommonFaultsResponse = {
      make,
      model,
      totalFaults: 6,
      faults: [
        {
          id: 1,
          title: 'Timing Chain Failure',
          description: 'The N47 diesel engine is prone to premature timing chain wear, which can lead to catastrophic engine failure if not addressed.',
          symptoms: ['Rattling noise on cold start', 'Check engine light', 'Rough idle', 'Loss of power'],
          typicalMileage: '60,000 - 100,000 miles',
          repairCostRange: '£1,500 - £3,000',
          severity: 'critical',
          affectedYears: '2007-2014',
          partsNeeded: ['Timing chain kit', 'Chain tensioner', 'Guide rails'],
        },
        {
          id: 2,
          title: 'EGR Valve Issues',
          description: 'Carbon buildup in the EGR valve causes poor running and reduced fuel economy.',
          symptoms: ['Poor acceleration', 'Increased emissions', 'EML warning', 'Rough running'],
          typicalMileage: '40,000 - 80,000 miles',
          repairCostRange: '£300 - £600',
          severity: 'medium',
          partsNeeded: ['EGR valve', 'Gaskets'],
        },
        {
          id: 3,
          title: 'Injector Seal Leaks',
          description: 'Fuel injector seals degrade over time causing fuel leaks and poor combustion.',
          symptoms: ['Diesel smell', 'Hard starting', 'Smoke from engine bay', 'Poor fuel economy'],
          typicalMileage: '50,000 - 90,000 miles',
          repairCostRange: '£200 - £500',
          severity: 'high',
          partsNeeded: ['Injector seals', 'Copper washers'],
        },
        {
          id: 4,
          title: 'Swirl Flap Failure',
          description: 'Intake manifold swirl flaps can break and get ingested into the engine.',
          symptoms: ['Rattling from intake', 'Loss of power', 'Check engine light'],
          typicalMileage: '80,000 - 150,000 miles',
          repairCostRange: '£400 - £1,200',
          severity: 'high',
          partsNeeded: ['Swirl flap delete kit', 'Intake manifold gaskets'],
        },
        {
          id: 5,
          title: 'Turbo Actuator Failure',
          description: 'Electronic turbo actuator fails causing limp mode and reduced power.',
          symptoms: ['Limp mode', 'Reduced boost', 'Check engine light', 'Poor acceleration'],
          typicalMileage: '60,000 - 120,000 miles',
          repairCostRange: '£400 - £900',
          severity: 'medium',
          partsNeeded: ['Turbo actuator', 'Actuator seal kit'],
        },
        {
          id: 6,
          title: 'DPF Clogging',
          description: 'Diesel particulate filter becomes blocked with short journey use.',
          symptoms: ['DPF warning light', 'Reduced power', 'Poor fuel economy', 'Regeneration failures'],
          typicalMileage: '40,000 - 100,000 miles',
          repairCostRange: '£300 - £2,500',
          severity: 'medium',
          partsNeeded: ['DPF cleaning service', 'DPF replacement (if damaged)'],
        },
      ],
    };
    return demoFaults;
  },
};

export const guidesApi = {
  /**
   * Get buyer's guide for a vehicle
   */
  getBuyersGuide: async (make: string, model: string, year?: number): Promise<BuyersGuideResponse> => {
    // Demo data - in production this would call the API
    return {
      make,
      model,
      year,
      overallRating: 7.5,
      reliabilityScore: 6.5,
      runningCostScore: 7.0,
      sections: [
        {
          id: 'overview',
          title: 'Overview',
          content: `The ${make} ${model} is a popular choice in the UK used car market. It offers a good balance of performance, comfort, and running costs, though there are some known issues to be aware of.`,
        },
        {
          id: 'what-to-look-for',
          title: 'What to Look For',
          content: 'When inspecting a used model, pay close attention to the service history and check for timing chain noise on diesel variants.',
          tips: [
            'Always get a full service history',
            'Listen for rattling on cold start (timing chain)',
            'Check for oil leaks around the engine',
            'Test all electrical systems thoroughly',
            'Inspect the condition of the alloy wheels',
          ],
          warnings: [
            'Avoid cars with incomplete service history',
            'Be wary of high-mileage diesels without timing chain replacement',
            'Check for DPF warning lights during test drive',
          ],
        },
        {
          id: 'running-costs',
          title: 'Running Costs',
          content: 'Running costs are reasonable for the class. Insurance groups range from 15-30 depending on the variant. Fuel economy is generally good, especially with diesel engines.',
        },
        {
          id: 'common-problems',
          title: 'Common Problems',
          content: 'The most serious issue is timing chain wear on N47 diesel engines. Other common problems include EGR valve issues and turbo actuator failures.',
        },
      ],
      prosAndCons: {
        pros: [
          'Strong residual values',
          'Good driving dynamics',
          'Quality interior',
          'Wide dealer network',
          'Good parts availability',
        ],
        cons: [
          'Timing chain issues on diesel',
          'Expensive to repair',
          'Some electrical gremlins',
          'Higher insurance costs',
        ],
      },
      verdictSummary: `The ${make} ${model} is a solid choice if you do your homework. Prioritise finding a car with full service history and consider having a pre-purchase inspection done by a specialist.`,
    };
  },
};

// Vehicle Lookup Types
export interface VehicleLookupResponse {
  registration: string;
  make: string;
  model: string;
  year: number;
  fuelType?: string;
  colour?: string;
  engineSize?: number;
  currentMileage?: number;
  motStatus?: string;
  motExpiryDate?: string;
  taxStatus?: string;
  motHistory: MotHistoryItem[];
  recentDefects: string[];
  isValid: boolean;
  isDemo?: boolean;
  errorMessage?: string;
  prediction?: PredictionSummary;
}

export interface MotHistoryItem {
  testDate: string;
  passed: boolean;
  mileage?: number;
  defectCount: number;
  advisoryCount: number;
  defects: string[];
  advisories: string[];
}

export interface PredictionSummary {
  reliabilityScore: number;
  reliabilityGrade: string;
  estimatedAnnualCost: number;
  topIssues: TopIssue[];
}

export interface TopIssue {
  name: string;
  probability: number;
  costRange: string;
}

export interface VehicleLookupStatus {
  isConfigured: boolean;
  message: string;
}

export const vehicleApi = {
  /**
   * Look up a vehicle by registration number
   */
  lookupByRegistration: async (registration: string): Promise<VehicleLookupResponse> => {
    const cleanReg = registration.replace(/\s+/g, '').toUpperCase();
    const response = await axios.get<VehicleLookupResponse>(
      `${API_BASE}/vehicle/lookup/${cleanReg}`
    );
    return response.data;
  },

  /**
   * Check if vehicle lookup API is configured
   */
  getLookupStatus: async (): Promise<VehicleLookupStatus> => {
    const response = await axios.get<VehicleLookupStatus>(
      `${API_BASE}/vehicle/lookup/status`
    );
    return response.data;
  },
};
