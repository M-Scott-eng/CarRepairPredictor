import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import {
  Car,
  Search,
  Wrench,
  BookOpen,
  ShoppingCart,
  ChevronRight,
  Clock,
  Star,
  Shield,
  AlertTriangle,
  FileText,
} from 'lucide-react';
import { useVehicleSelection, useRecentSearches } from '../hooks/useVehicleSelection';
import Button from '../components/ui/Button';
import Select from '../components/ui/Select';
import Card from '../components/ui/Card';
import Spinner from '../components/ui/Spinner';
import RegistrationSearch from '../components/RegistrationSearch';

type SearchTab = 'reg' | 'manual';

const features = [
  {
    icon: Search,
    title: 'Find Parts',
    description: 'Search across eBay, Amazon, Autodoc & RockAuto for the best prices.',
    href: '/parts',
    color: 'bg-blue-500',
  },
  {
    icon: AlertTriangle,
    title: 'Common Faults',
    description: 'Know what issues to expect before you buy.',
    href: '/faults',
    color: 'bg-amber-500',
  },
  {
    icon: BookOpen,
    title: "Buyer's Guide",
    description: 'Expert advice on what to look for when buying.',
    href: '/guide',
    color: 'bg-green-500',
  },
];

export default function CarSelectorPage() {
  const navigate = useNavigate();
  const [searchTab, setSearchTab] = useState<SearchTab>('reg');
  const {
    makes,
    models,
    years,
    selectedMakeId,
    selectedModelId,
    selectedYear,
    makesLoading,
    modelsLoading,
    yearsLoading,
    makesError,
    handleMakeChange,
    handleModelChange,
    handleYearChange,
    getSelectedVehicle,
  } = useVehicleSelection();

  const { searches, addSearch, clearSearches } = useRecentSearches();

  const handleSearch = (destination: string) => {
    const vehicle = getSelectedVehicle();
    if (vehicle) {
      addSearch(vehicle);
      const params = new URLSearchParams({
        make: vehicle.makeName,
        model: vehicle.modelName,
        ...(vehicle.year && { year: vehicle.year.toString() }),
      });
      navigate(`${destination}?${params.toString()}`);
    }
  };

  const handleRecentSearch = (vehicle: typeof searches[0], destination: string) => {
    const params = new URLSearchParams({
      make: vehicle.makeName,
      model: vehicle.modelName,
      ...(vehicle.year && { year: vehicle.year.toString() }),
    });
    navigate(`${destination}?${params.toString()}`);
  };

  const canSearch = selectedMakeId && selectedModelId;

  return (
    <div className="fade-in">
      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-primary-600 via-primary-700 to-primary-800 text-white overflow-hidden">
        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-10"></div>
        <div className="gv-container py-16 lg:py-24 relative">
          <div className="text-center max-w-3xl mx-auto">
            <span className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-full text-sm mb-6">
              <Shield className="w-4 h-4" />
              UK's #1 Car Parts & Buyer's Guide
            </span>
            <h1 className="text-4xl lg:text-5xl font-bold mb-6">
              Find Parts, Check Faults & Buy Smart
            </h1>
            <p className="text-xl text-primary-100 mb-8">
              Select your vehicle to compare parts prices, discover common faults,
              and get expert buying advice.
            </p>
          </div>

          {/* Car Selector Card */}
          <div className="max-w-2xl mx-auto">
            <Card className="!bg-white/10 !backdrop-blur-md !border-white/20">
              {/* Tab Buttons */}
              <div className="flex mb-6 bg-white/10 rounded-lg p-1">
                <button
                  type="button"
                  onClick={() => setSearchTab('reg')}
                  className={`flex-1 flex items-center justify-center gap-2 py-2 px-4 rounded-md text-sm font-medium transition-all ${
                    searchTab === 'reg'
                      ? 'bg-white text-primary-700 shadow-sm'
                      : 'text-white/80 hover:text-white'
                  }`}
                >
                  <FileText className="w-4 h-4" />
                  Enter Reg
                </button>
                <button
                  type="button"
                  onClick={() => setSearchTab('manual')}
                  className={`flex-1 flex items-center justify-center gap-2 py-2 px-4 rounded-md text-sm font-medium transition-all ${
                    searchTab === 'manual'
                      ? 'bg-white text-primary-700 shadow-sm'
                      : 'text-white/80 hover:text-white'
                  }`}
                >
                  <Car className="w-4 h-4" />
                  Select Vehicle
                </button>
              </div>

              {/* Registration Search Tab */}
              {searchTab === 'reg' && (
                <div>
                  <p className="text-white/80 text-sm mb-4">
                    Enter your registration number to instantly see vehicle details, MOT history, and predicted repair costs.
                  </p>
                  <RegistrationSearch showFullResults={true} />
                </div>
              )}

              {/* Manual Selection Tab */}
              {searchTab === 'manual' && (
              <div className="grid gap-4">
                <div className="grid sm:grid-cols-3 gap-4">
                  {/* Make Select */}
                  <div>
                    <label className="block text-sm font-medium text-white/80 mb-2">
                      Make
                    </label>
                    {makesLoading ? (
                      <div className="h-12 flex items-center justify-center">
                        <Spinner size="sm" className="!border-white/30 !border-t-white" />
                      </div>
                    ) : makesError ? (
                      <div className="text-red-300 text-sm">Failed to load makes</div>
                    ) : (
                      <Select
                        value={selectedMakeId?.toString() || ''}
                        onChange={(e) => handleMakeChange(e.target.value ? parseInt(e.target.value) : null)}
                        className="!bg-white/20 !border-white/30 !text-white placeholder:text-white/50"
                      >
                        <option value="">Select make...</option>
                        {makes?.map((make) => (
                          <option key={make.id} value={make.id} className="text-gray-900">
                            {make.name}
                          </option>
                        ))}
                      </Select>
                    )}
                  </div>

                  {/* Model Select */}
                  <div>
                    <label className="block text-sm font-medium text-white/80 mb-2">
                      Model
                    </label>
                    {modelsLoading ? (
                      <div className="h-12 flex items-center justify-center">
                        <Spinner size="sm" className="!border-white/30 !border-t-white" />
                      </div>
                    ) : (
                      <Select
                        value={selectedModelId?.toString() || ''}
                        onChange={(e) => handleModelChange(e.target.value ? parseInt(e.target.value) : null)}
                        disabled={!selectedMakeId}
                        className="!bg-white/20 !border-white/30 !text-white placeholder:text-white/50 disabled:opacity-50"
                      >
                        <option value="">Select model...</option>
                        {models?.map((model) => (
                          <option key={model.id} value={model.id} className="text-gray-900">
                            {model.name}
                          </option>
                        ))}
                      </Select>
                    )}
                  </div>

                  {/* Year Select */}
                  <div>
                    <label className="block text-sm font-medium text-white/80 mb-2">
                      Year <span className="text-white/50">(optional)</span>
                    </label>
                    {yearsLoading ? (
                      <div className="h-12 flex items-center justify-center">
                        <Spinner size="sm" className="!border-white/30 !border-t-white" />
                      </div>
                    ) : (
                      <Select
                        value={selectedYear?.toString() || ''}
                        onChange={(e) => handleYearChange(e.target.value ? parseInt(e.target.value) : null)}
                        disabled={!selectedModelId}
                        className="!bg-white/20 !border-white/30 !text-white placeholder:text-white/50 disabled:opacity-50"
                      >
                        <option value="">Any year</option>
                        {years?.map((year) => (
                          <option key={year} value={year} className="text-gray-900">
                            {year}
                          </option>
                        ))}
                      </Select>
                    )}
                  </div>
                </div>

                {/* Action Buttons */}
                <div className="grid sm:grid-cols-3 gap-3 pt-2">
                  <Button
                    onClick={() => handleSearch('/parts')}
                    disabled={!canSearch}
                    className="!bg-blue-500 hover:!bg-blue-600 disabled:!bg-white/20 disabled:!text-white/50"
                  >
                    <ShoppingCart className="w-4 h-4 mr-2" />
                    Find Parts
                  </Button>
                  <Button
                    onClick={() => handleSearch('/faults')}
                    disabled={!canSearch}
                    className="!bg-amber-500 hover:!bg-amber-600 disabled:!bg-white/20 disabled:!text-white/50"
                  >
                    <Wrench className="w-4 h-4 mr-2" />
                    View Faults
                  </Button>
                  <Button
                    onClick={() => handleSearch('/guide')}
                    disabled={!canSearch}
                    className="!bg-green-500 hover:!bg-green-600 disabled:!bg-white/20 disabled:!text-white/50"
                  >
                    <BookOpen className="w-4 h-4 mr-2" />
                    Buyer's Guide
                  </Button>
                </div>
              </div>
              )}
            </Card>
          </div>
        </div>
      </section>

      {/* Recent Searches */}
      {searches.length > 0 && (
        <section className="gv-container py-8">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 flex items-center gap-2">
              <Clock className="w-5 h-5 text-gray-400" />
              Recent Searches
            </h2>
            <button
              onClick={clearSearches}
              className="text-sm text-gray-500 hover:text-gray-700"
            >
              Clear all
            </button>
          </div>
          <div className="flex flex-wrap gap-3">
            {searches.map((vehicle, index) => (
              <div
                key={index}
                className="flex items-center gap-2 bg-white border border-gray-200 rounded-lg px-4 py-2 shadow-sm"
              >
                <Car className="w-4 h-4 text-gray-400" />
                <span className="font-medium">
                  {vehicle.makeName} {vehicle.modelName}
                  {vehicle.year && ` (${vehicle.year})`}
                </span>
                <div className="flex gap-1 ml-2">
                  <button
                    onClick={() => handleRecentSearch(vehicle, '/parts')}
                    className="p-1 hover:bg-blue-50 rounded text-blue-600"
                    title="Find Parts"
                  >
                    <ShoppingCart className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleRecentSearch(vehicle, '/faults')}
                    className="p-1 hover:bg-amber-50 rounded text-amber-600"
                    title="View Faults"
                  >
                    <Wrench className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Features Section */}
      <section className="gv-section bg-white">
        <div className="gv-container">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Everything You Need to Buy Smart
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              From finding the cheapest parts to understanding common faults,
              we've got you covered.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {features.map((feature) => (
              <Link
                key={feature.href}
                to={feature.href}
                className="group"
              >
                <Card hover className="h-full">
                  <div className={`w-12 h-12 ${feature.color} rounded-xl flex items-center justify-center mb-4`}>
                    <feature.icon className="w-6 h-6 text-white" />
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2 group-hover:text-primary-600 transition-colors">
                    {feature.title}
                  </h3>
                  <p className="text-gray-600 mb-4">{feature.description}</p>
                  <span className="inline-flex items-center text-primary-600 font-medium">
                    Learn more
                    <ChevronRight className="w-4 h-4 ml-1 group-hover:translate-x-1 transition-transform" />
                  </span>
                </Card>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="gv-section bg-gray-50">
        <div className="gv-container">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="text-4xl font-bold text-primary-600 mb-2">4+</div>
              <div className="text-gray-600">Parts Suppliers</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-primary-600 mb-2">500K+</div>
              <div className="text-gray-600">Parts Listed</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-primary-600 mb-2">1000+</div>
              <div className="text-gray-600">Fault Reports</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-primary-600 mb-2">15K+</div>
              <div className="text-gray-600">Happy Users</div>
            </div>
          </div>
        </div>
      </section>

      {/* Trust Indicators */}
      <section className="gv-section bg-white">
        <div className="gv-container">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Trusted by UK Car Enthusiasts
            </h2>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            <Card>
              <div className="flex items-center gap-1 mb-3">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                ))}
              </div>
              <p className="text-gray-600 mb-4">
                "Saved me £400 on brake parts for my Golf. The price comparison is brilliant!"
              </p>
              <div className="text-sm font-medium text-gray-900">James T.</div>
              <div className="text-sm text-gray-500">Manchester</div>
            </Card>
            <Card>
              <div className="flex items-center gap-1 mb-3">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                ))}
              </div>
              <p className="text-gray-600 mb-4">
                "The common faults section helped me negotiate £1,500 off a BMW. Essential tool!"
              </p>
              <div className="text-sm font-medium text-gray-900">Sarah M.</div>
              <div className="text-sm text-gray-500">Bristol</div>
            </Card>
            <Card>
              <div className="flex items-center gap-1 mb-3">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                ))}
              </div>
              <p className="text-gray-600 mb-4">
                "Finally, accurate UK pricing for parts. No more guessing import costs!"
              </p>
              <div className="text-sm font-medium text-gray-900">David K.</div>
              <div className="text-sm text-gray-500">Edinburgh</div>
            </Card>
          </div>
        </div>
      </section>
    </div>
  );
}
