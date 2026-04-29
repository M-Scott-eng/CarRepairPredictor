import { useSearchParams, Link, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  AlertTriangle,
  AlertCircle,
  CheckCircle,
  XCircle,
  ChevronRight,
  Car,
  Wrench,
  PoundSterling,
  Gauge,
  ShoppingCart,
  ArrowLeft,
  Info,
} from 'lucide-react';
import { faultsApi } from '../services/api';
import Card from '../components/ui/Card';
import Button from '../components/ui/Button';
import { SkeletonCard } from '../components/ui/Spinner';
import type { CommonFault } from '../types/parts';

const severityConfig = {
  low: {
    icon: CheckCircle,
    color: 'text-green-600',
    bgColor: 'bg-green-50',
    borderColor: 'border-green-200',
    label: 'Low',
  },
  medium: {
    icon: Info,
    color: 'text-amber-600',
    bgColor: 'bg-amber-50',
    borderColor: 'border-amber-200',
    label: 'Medium',
  },
  high: {
    icon: AlertTriangle,
    color: 'text-orange-600',
    bgColor: 'bg-orange-50',
    borderColor: 'border-orange-200',
    label: 'High',
  },
  critical: {
    icon: XCircle,
    color: 'text-red-600',
    bgColor: 'bg-red-50',
    borderColor: 'border-red-200',
    label: 'Critical',
  },
};

function FaultCard({ fault, onFindParts }: { fault: CommonFault; onFindParts: (partName: string) => void }) {
  const severity = severityConfig[fault.severity];
  const SeverityIcon = severity.icon;

  return (
    <Card className={`!border-l-4 ${severity.borderColor} hover:shadow-md transition-shadow`}>
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-start gap-3">
          <div className={`w-10 h-10 ${severity.bgColor} rounded-lg flex items-center justify-center`}>
            <SeverityIcon className={`w-5 h-5 ${severity.color}`} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-900">{fault.title}</h3>
            <span className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${severity.bgColor} ${severity.color}`}>
              {severity.label} Severity
            </span>
          </div>
        </div>
        {fault.affectedYears && (
          <span className="text-sm text-gray-500">
            {fault.affectedYears}
          </span>
        )}
      </div>

      <p className="text-gray-600 mb-4">{fault.description}</p>

      <div className="grid sm:grid-cols-2 gap-4 mb-4">
        <div>
          <h4 className="text-sm font-medium text-gray-700 mb-2 flex items-center gap-1">
            <AlertCircle className="w-4 h-4" />
            Symptoms
          </h4>
          <ul className="space-y-1">
            {fault.symptoms.map((symptom, index) => (
              <li key={index} className="text-sm text-gray-600 flex items-start gap-2">
                <span className="text-gray-400 mt-1">•</span>
                {symptom}
              </li>
            ))}
          </ul>
        </div>
        <div className="space-y-3">
          <div>
            <h4 className="text-sm font-medium text-gray-700 flex items-center gap-1">
              <Gauge className="w-4 h-4" />
              Typical Mileage
            </h4>
            <p className="text-sm text-gray-600">{fault.typicalMileage}</p>
          </div>
          <div>
            <h4 className="text-sm font-medium text-gray-700 flex items-center gap-1">
              <PoundSterling className="w-4 h-4" />
              Repair Cost
            </h4>
            <p className="text-sm font-semibold text-gray-900">{fault.repairCostRange}</p>
          </div>
        </div>
      </div>

      {fault.partsNeeded && fault.partsNeeded.length > 0 && (
        <div className="pt-4 border-t border-gray-100">
          <h4 className="text-sm font-medium text-gray-700 mb-2 flex items-center gap-1">
            <Wrench className="w-4 h-4" />
            Parts Needed
          </h4>
          <div className="flex flex-wrap gap-2">
            {fault.partsNeeded.map((part, index) => (
              <button
                key={index}
                onClick={() => onFindParts(part)}
                className="inline-flex items-center gap-1 px-3 py-1.5 bg-blue-50 text-blue-700 rounded-full text-sm hover:bg-blue-100 transition-colors"
              >
                <ShoppingCart className="w-3.5 h-3.5" />
                {part}
              </button>
            ))}
          </div>
        </div>
      )}
    </Card>
  );
}

export default function CommonFaultsPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  
  const make = searchParams.get('make') || '';
  const model = searchParams.get('model') || '';
  const year = searchParams.get('year') ? parseInt(searchParams.get('year')!) : undefined;

  const { data, isLoading, error } = useQuery({
    queryKey: ['faults', make, model, year],
    queryFn: () => faultsApi.getCommonFaults(make, model, year),
    enabled: !!make && !!model,
  });

  const handleFindParts = (partName: string) => {
    const params = new URLSearchParams({
      make,
      model,
      query: partName,
      ...(year && { year: year.toString() }),
    });
    navigate(`/parts?${params.toString()}`);
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
            Choose your car's make and model to see common faults.
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
      <section className="bg-gradient-to-r from-amber-500 to-orange-500 text-white">
        <div className="gv-container py-12">
          <Link
            to="/"
            className="inline-flex items-center text-white/80 hover:text-white mb-4 transition-colors"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            Back to search
          </Link>
          <div className="flex items-center gap-3 mb-2">
            <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center">
              <AlertTriangle className="w-6 h-6" />
            </div>
            <div>
              <h1 className="text-3xl font-bold">
                Common Faults
              </h1>
              <p className="text-white/80">
                {make} {model} {year && `(${year})`}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Content */}
      <section className="gv-container py-8">
        {isLoading ? (
          <div className="space-y-6">
            {[...Array(3)].map((_, i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        ) : error ? (
          <Card className="text-center py-12">
            <AlertCircle className="w-16 h-16 text-red-300 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              Failed to Load Faults
            </h2>
            <p className="text-gray-600 mb-6">
              We couldn't retrieve fault data. Please try again.
            </p>
            <Button onClick={() => window.location.reload()}>
              Try Again
            </Button>
          </Card>
        ) : data?.faults.length === 0 ? (
          <Card className="text-center py-12">
            <CheckCircle className="w-16 h-16 text-green-300 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              No Known Faults
            </h2>
            <p className="text-gray-600">
              We don't have any common faults on record for this vehicle yet.
            </p>
          </Card>
        ) : (
          <>
            {/* Summary */}
            <div className="mb-8">
              <div className="flex flex-wrap gap-4">
                <div className="flex items-center gap-2 text-sm">
                  <span className="font-medium text-gray-700">Found:</span>
                  <span className="text-gray-600">{data?.totalFaults} known issues</span>
                </div>
                <div className="flex items-center gap-4">
                  {['critical', 'high', 'medium', 'low'].map((sev) => {
                    const count = data?.faults.filter(f => f.severity === sev).length || 0;
                    if (count === 0) return null;
                    const config = severityConfig[sev as keyof typeof severityConfig];
                    return (
                      <div key={sev} className="flex items-center gap-1 text-sm">
                        <span className={`w-2 h-2 rounded-full ${config.bgColor}`}></span>
                        <span className={config.color}>{count} {config.label}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>

            {/* Faults List */}
            <div className="space-y-6">
              {data?.faults.map((fault) => (
                <FaultCard key={fault.id} fault={fault} onFindParts={handleFindParts} />
              ))}
            </div>

            {/* CTA */}
            <Card className="mt-8 bg-gradient-to-r from-blue-50 to-indigo-50 !border-blue-100">
              <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
                <div>
                  <h3 className="font-semibold text-gray-900">Need Parts for Repairs?</h3>
                  <p className="text-sm text-gray-600">
                    Compare prices across eBay, Amazon, Autodoc & more.
                  </p>
                </div>
                <Link to={`/parts?make=${make}&model=${model}${year ? `&year=${year}` : ''}`}>
                  <Button>
                    <ShoppingCart className="w-4 h-4 mr-2" />
                    Find Parts
                    <ChevronRight className="w-4 h-4 ml-1" />
                  </Button>
                </Link>
              </div>
            </Card>
          </>
        )}
      </section>
    </div>
  );
}
