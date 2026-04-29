import { useState } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Search,
  SortAsc,
  ExternalLink,
  Star,
  Truck,
  Tag,
  ShoppingCart,
  Car,
  ArrowLeft,
  CheckCircle,
  AlertCircle,
  RefreshCw,
  Grid,
  List,
  Zap,
} from 'lucide-react';
import { partsApi } from '../services/api';
import Card from '../components/ui/Card';
import Button from '../components/ui/Button';
import Input from '../components/ui/Input';
import Select from '../components/ui/Select';
import { SkeletonCard } from '../components/ui/Spinner';
import type { NormalisedPartResult, PartsSearchResponse } from '../types/parts';

type SortOption = 'price' | 'rating' | 'delivery' | 'relevance';
type ViewMode = 'grid' | 'list';

const supplierLogos: Record<string, string> = {
  ebay: '🛒',
  amazon: '📦',
  autodoc: '🔧',
  rockauto: '🚗',
};

function PartCard({ part, viewMode }: { part: NormalisedPartResult; viewMode: ViewMode }) {
  const logo = supplierLogos[part.supplierId] || '🔧';

  if (viewMode === 'list') {
    return (
      <Card hover className="!p-4">
        <div className="flex items-center gap-4">
          <div className="w-20 h-20 bg-gray-100 rounded-lg flex items-center justify-center shrink-0">
            {part.imageUrl ? (
              <img src={part.imageUrl} alt={part.title} className="w-full h-full object-cover rounded-lg" />
            ) : (
              <span className="text-3xl">{logo}</span>
            )}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-4">
              <div className="min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-medium text-gray-500 uppercase">{part.supplierName}</span>
                  {part.isPrime && (
                    <span className="inline-flex items-center px-1.5 py-0.5 bg-blue-100 text-blue-700 rounded text-xs font-medium">
                      <Zap className="w-3 h-3 mr-0.5" /> Prime
                    </span>
                  )}
                </div>
                <h3 className="font-medium text-gray-900 truncate">{part.title}</h3>
                {part.brand && (
                  <p className="text-sm text-gray-500">
                    {part.brand} {part.oemPartNumber && `• ${part.oemPartNumber}`}
                  </p>
                )}
              </div>
              <div className="text-right shrink-0">
                <p className="text-xl font-bold text-gray-900">£{part.priceGbp.toFixed(2)}</p>
                {part.shippingGbp !== undefined && part.shippingGbp > 0 && (
                  <p className="text-sm text-gray-500">+ £{part.shippingGbp.toFixed(2)} delivery</p>
                )}
              </div>
            </div>
            <div className="flex items-center justify-between mt-2">
              <div className="flex items-center gap-4 text-sm text-gray-500">
                {part.sellerRating && (
                  <span className="flex items-center gap-1">
                    <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                    {part.sellerRating.toFixed(1)}
                  </span>
                )}
                {part.estimatedDeliveryDays && (
                  <span className="flex items-center gap-1">
                    <Truck className="w-4 h-4" />
                    {part.estimatedDeliveryDays} days
                  </span>
                )}
                {part.availability && (
                  <span className={`flex items-center gap-1 ${part.availability === 'InStock' ? 'text-green-600' : 'text-amber-600'}`}>
                    <CheckCircle className="w-4 h-4" />
                    {part.availability === 'InStock' ? 'In Stock' : 'Limited'}
                  </span>
                )}
              </div>
              <a
                href={part.affiliateUrl || part.productUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="gv-btn-primary !py-2 !px-4 text-sm"
              >
                View Deal
                <ExternalLink className="w-4 h-4 ml-1" />
              </a>
            </div>
          </div>
        </div>
      </Card>
    );
  }

  return (
    <Card hover className="flex flex-col h-full">
      <div className="relative">
        <div className="w-full h-40 bg-gray-100 rounded-lg flex items-center justify-center mb-4">
          {part.imageUrl ? (
            <img src={part.imageUrl} alt={part.title} className="w-full h-full object-cover rounded-lg" />
          ) : (
            <span className="text-5xl">{logo}</span>
          )}
        </div>
        {part.isPrime && (
          <span className="absolute top-2 right-2 inline-flex items-center px-2 py-1 bg-blue-500 text-white rounded text-xs font-medium">
            <Zap className="w-3 h-3 mr-0.5" /> Prime
          </span>
        )}
      </div>
      
      <div className="flex-1">
        <div className="flex items-center gap-2 mb-2">
          <span className="text-xs font-medium text-gray-500 uppercase">{part.supplierName}</span>
          {part.sellerRating && (
            <span className="flex items-center gap-0.5 text-xs text-gray-500">
              <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
              {part.sellerRating.toFixed(1)}
            </span>
          )}
        </div>
        <h3 className="font-medium text-gray-900 mb-1 line-clamp-2">{part.title}</h3>
        {part.brand && (
          <p className="text-sm text-gray-500 mb-2">
            {part.brand} {part.oemPartNumber && `• ${part.oemPartNumber}`}
          </p>
        )}
        <div className="flex items-center gap-2 text-sm text-gray-500 mb-3">
          {part.estimatedDeliveryDays && (
            <span className="flex items-center gap-1">
              <Truck className="w-4 h-4" />
              {part.estimatedDeliveryDays}d
            </span>
          )}
          {part.availability === 'InStock' && (
            <span className="flex items-center gap-1 text-green-600">
              <CheckCircle className="w-4 h-4" />
              In Stock
            </span>
          )}
        </div>
      </div>

      <div className="pt-3 border-t border-gray-100 mt-auto">
        <div className="flex items-center justify-between mb-3">
          <div>
            <p className="text-2xl font-bold text-gray-900">£{part.priceGbp.toFixed(2)}</p>
            {part.shippingGbp !== undefined && part.shippingGbp > 0 && (
              <p className="text-xs text-gray-500">+ £{part.shippingGbp.toFixed(2)} delivery</p>
            )}
          </div>
          <p className="text-sm font-medium text-primary-600">
            Total: £{part.totalPriceGbp.toFixed(2)}
          </p>
        </div>
        <a
          href={part.affiliateUrl || part.productUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="gv-btn-primary w-full text-center"
        >
          View Deal
          <ExternalLink className="w-4 h-4 ml-2" />
        </a>
      </div>
    </Card>
  );
}

function PriceComparisonTable({ results, sortBy, onSort }: { 
  results: NormalisedPartResult[]; 
  sortBy: SortOption;
  onSort: (sort: SortOption) => void;
}) {
  const columns = [
    { key: 'supplier', label: 'Supplier' },
    { key: 'part', label: 'Part' },
    { key: 'price', label: 'Price', sortable: true },
    { key: 'delivery', label: 'Delivery', sortable: true },
    { key: 'rating', label: 'Rating', sortable: true },
    { key: 'action', label: '' },
  ];

  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              {columns.map((col) => (
                <th
                  key={col.key}
                  className={`px-4 py-3 text-left text-sm font-medium text-gray-700 ${col.sortable ? 'cursor-pointer hover:bg-gray-100' : ''}`}
                  onClick={() => col.sortable && onSort(col.key as SortOption)}
                >
                  <div className="flex items-center gap-1">
                    {col.label}
                    {col.sortable && sortBy === col.key && (
                      <SortAsc className="w-4 h-4 text-primary-600" />
                    )}
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {results.slice(0, 10).map((part) => (
              <tr key={part.resultId} className="hover:bg-gray-50">
                <td className="px-4 py-3">
                  <div className="flex items-center gap-2">
                    <span className="text-xl">{supplierLogos[part.supplierId] || '🔧'}</span>
                    <span className="font-medium text-gray-900">{part.supplierName}</span>
                  </div>
                </td>
                <td className="px-4 py-3">
                  <div className="max-w-xs">
                    <p className="font-medium text-gray-900 truncate">{part.title}</p>
                    <p className="text-sm text-gray-500">{part.brand}</p>
                  </div>
                </td>
                <td className="px-4 py-3">
                  <p className="font-bold text-gray-900">£{part.priceGbp.toFixed(2)}</p>
                  {part.shippingGbp !== undefined && part.shippingGbp > 0 && (
                    <p className="text-xs text-gray-500">+ £{part.shippingGbp.toFixed(2)}</p>
                  )}
                </td>
                <td className="px-4 py-3">
                  <span className="flex items-center gap-1 text-sm">
                    <Truck className="w-4 h-4 text-gray-400" />
                    {part.estimatedDeliveryDays ? `${part.estimatedDeliveryDays} days` : 'N/A'}
                  </span>
                </td>
                <td className="px-4 py-3">
                  {part.sellerRating ? (
                    <span className="flex items-center gap-1">
                      <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                      {part.sellerRating.toFixed(1)}
                    </span>
                  ) : (
                    <span className="text-gray-400">—</span>
                  )}
                </td>
                <td className="px-4 py-3">
                  <a
                    href={part.affiliateUrl || part.productUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1 text-primary-600 hover:text-primary-700 font-medium text-sm"
                  >
                    View <ExternalLink className="w-4 h-4" />
                  </a>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function SupplierStatusBar({ statuses }: { statuses: PartsSearchResponse['supplierStatuses'] }) {
  return (
    <div className="flex flex-wrap gap-2">
      {statuses.map((status) => (
        <div
          key={status.supplierId}
          className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-sm ${
            status.success ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'
          }`}
        >
          <span className="text-lg">{supplierLogos[status.supplierId] || '🔧'}</span>
          <span className="font-medium">{status.supplierName}</span>
          {status.success ? (
            <span className="text-green-600">{status.resultCount} results</span>
          ) : (
            <span className="text-red-600">Failed</span>
          )}
        </div>
      ))}
    </div>
  );
}

export default function PartsFinderPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [viewMode, setViewMode] = useState<ViewMode>('grid');
  const [sortBy, setSortBy] = useState<SortOption>('relevance');
  const [searchQuery, setSearchQuery] = useState(searchParams.get('query') || '');

  const make = searchParams.get('make') || '';
  const model = searchParams.get('model') || '';
  const year = searchParams.get('year') ? parseInt(searchParams.get('year')!) : undefined;
  const query = searchParams.get('query') || '';

  const { data, isLoading, error, refetch, isFetching } = useQuery({
    queryKey: ['parts', make, model, year, query, sortBy],
    queryFn: () => partsApi.searchParts({
      make,
      model,
      year,
      searchQuery: query,
      sortBy,
      ascending: true,
      maxResults: 30,
    }),
    enabled: !!make && !!model,
  });

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    const newParams = new URLSearchParams(searchParams);
    if (searchQuery) {
      newParams.set('query', searchQuery);
    } else {
      newParams.delete('query');
    }
    setSearchParams(newParams);
  };

  // No vehicle selected
  if (!make || !model) {
    return (
      <div className="gv-container py-16">
        <Card className="max-w-lg mx-auto text-center">
          <Car className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">
            Select a Vehicle First
          </h2>
          <p className="text-gray-600 mb-6">
            Choose your car's make and model to search for parts.
          </p>
          <Link to="/">
            <Button>
              <Car className="w-4 h-4 mr-2" />
              Select Vehicle
            </Button>
          </Link>
        </Card>
      </div>
    );
  }

  return (
    <div className="fade-in">
      {/* Header */}
      <section className="bg-gradient-to-r from-blue-600 to-indigo-600 text-white">
        <div className="gv-container py-8">
          <Link
            to="/"
            className="inline-flex items-center text-white/80 hover:text-white mb-4 transition-colors"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            Back to search
          </Link>
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center">
              <ShoppingCart className="w-6 h-6" />
            </div>
            <div>
              <h1 className="text-2xl font-bold">Parts Finder</h1>
              <p className="text-white/80">
                {make} {model} {year && `(${year})`}
              </p>
            </div>
          </div>

          {/* Search Form */}
          <form onSubmit={handleSearch} className="flex gap-3 max-w-2xl">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <Input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search for parts... (e.g., timing chain, brake pads)"
                className="!pl-10 !bg-white/10 !border-white/30 !text-white !placeholder-white/50"
              />
            </div>
            <Button type="submit" className="!bg-white !text-blue-600 hover:!bg-gray-100">
              <Search className="w-4 h-4 mr-2" />
              Search
            </Button>
          </form>
        </div>
      </section>

      {/* Controls */}
      <section className="bg-white border-b border-gray-200 sticky top-16 z-40">
        <div className="gv-container py-4">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="flex items-center gap-4">
              {/* Sort */}
              <div className="flex items-center gap-2">
                <span className="text-sm text-gray-600">Sort by:</span>
                <Select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value as SortOption)}
                  className="!w-auto !py-2"
                >
                  <option value="relevance">Relevance</option>
                  <option value="price">Price (Low to High)</option>
                  <option value="rating">Rating</option>
                  <option value="delivery">Delivery Time</option>
                </Select>
              </div>

              {/* View Toggle */}
              <div className="flex items-center border border-gray-200 rounded-lg overflow-hidden">
                <button
                  onClick={() => setViewMode('grid')}
                  className={`p-2 ${viewMode === 'grid' ? 'bg-primary-50 text-primary-600' : 'text-gray-500 hover:bg-gray-50'}`}
                >
                  <Grid className="w-5 h-5" />
                </button>
                <button
                  onClick={() => setViewMode('list')}
                  className={`p-2 ${viewMode === 'list' ? 'bg-primary-50 text-primary-600' : 'text-gray-500 hover:bg-gray-50'}`}
                >
                  <List className="w-5 h-5" />
                </button>
              </div>
            </div>

            <div className="flex items-center gap-4">
              {data && (
                <span className="text-sm text-gray-600">
                  {data.metadata.totalResults} results found
                </span>
              )}
              <Button
                variant="secondary"
                onClick={() => refetch()}
                disabled={isFetching}
                className="!py-2"
              >
                <RefreshCw className={`w-4 h-4 mr-1 ${isFetching ? 'animate-spin' : ''}`} />
                Refresh
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Content */}
      <section className="gv-container py-8">
        {isLoading ? (
          <div className="space-y-4">
            <div className="flex gap-2">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="h-8 w-32 bg-gray-200 rounded-full animate-pulse" />
              ))}
            </div>
            <div className={viewMode === 'grid' ? 'grid sm:grid-cols-2 lg:grid-cols-3 gap-6' : 'space-y-4'}>
              {[...Array(6)].map((_, i) => (
                <SkeletonCard key={i} />
              ))}
            </div>
          </div>
        ) : error ? (
          <Card className="text-center py-12">
            <AlertCircle className="w-16 h-16 text-red-300 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              Search Failed
            </h2>
            <p className="text-gray-600 mb-6">
              We couldn't retrieve parts data. Please try again.
            </p>
            <Button onClick={() => refetch()}>
              <RefreshCw className="w-4 h-4 mr-2" />
              Try Again
            </Button>
          </Card>
        ) : data?.results.length === 0 ? (
          <Card className="text-center py-12">
            <ShoppingCart className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              No Parts Found
            </h2>
            <p className="text-gray-600 mb-6">
              Try a different search term or check back later.
            </p>
          </Card>
        ) : (
          <>
            {/* Supplier Status */}
            {data && (
              <div className="mb-6">
                <SupplierStatusBar statuses={data.supplierStatuses} />
              </div>
            )}

            {/* Price Summary */}
            {data && data.metadata.lowestPrice && (
              <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl">
                <div className="flex items-center justify-between flex-wrap gap-4">
                  <div className="flex items-center gap-3">
                    <Tag className="w-6 h-6 text-green-600" />
                    <div>
                      <p className="text-sm text-green-700">Best Price Found</p>
                      <p className="text-2xl font-bold text-green-800">
                        £{data.metadata.lowestPrice.toFixed(2)}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-600">
                      Price Range: £{data.metadata.lowestPrice.toFixed(2)} - £{data.metadata.highestPrice?.toFixed(2)}
                    </p>
                    <p className="text-sm text-gray-600">
                      Average: £{data.metadata.averagePrice?.toFixed(2)}
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Price Comparison Table (for list view) */}
            {viewMode === 'list' && data && (
              <div className="mb-8">
                <h2 className="text-lg font-semibold text-gray-900 mb-4">Price Comparison</h2>
                <PriceComparisonTable 
                  results={data.results} 
                  sortBy={sortBy}
                  onSort={setSortBy}
                />
              </div>
            )}

            {/* Results Grid/List */}
            {viewMode === 'grid' ? (
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {data?.results.map((part) => (
                  <PartCard key={part.resultId} part={part} viewMode={viewMode} />
                ))}
              </div>
            ) : (
              <div className="space-y-4">
                {data?.results.map((part) => (
                  <PartCard key={part.resultId} part={part} viewMode={viewMode} />
                ))}
              </div>
            )}
          </>
        )}
      </section>
    </div>
  );
}
