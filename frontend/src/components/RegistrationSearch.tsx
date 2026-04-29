import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { Search, AlertCircle, CheckCircle, Clock, Fuel, Gauge, X } from 'lucide-react';
import { vehicleApi, VehicleLookupResponse } from '../services/api';
import Button from './ui/Button';
import Spinner from './ui/Spinner';
import Card from './ui/Card';

interface RegistrationSearchProps {
  onVehicleFound?: (vehicle: VehicleLookupResponse) => void;
  showFullResults?: boolean;
}

export default function RegistrationSearch({ 
  onVehicleFound,
  showFullResults = true 
}: RegistrationSearchProps) {
  const navigate = useNavigate();
  const [registration, setRegistration] = useState('');
  const [loading, setLoading] = useState(false);
  const [predictLoading, setPredictLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<VehicleLookupResponse | null>(null);

  const handleSearch = async () => {
    console.log('handleSearch called, registration:', registration);
    
    if (!registration.trim()) {
      setError('Please enter a registration number');
      return;
    }

    // Basic UK reg validation
    const cleanReg = registration.replace(/\s+/g, '').toUpperCase();
    if (cleanReg.length < 2 || cleanReg.length > 8) {
      setError('Invalid registration format');
      return;
    }

    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const data = await vehicleApi.lookupByRegistration(cleanReg);
      setResult(data);
      onVehicleFound?.(data);
    } catch (err: unknown) {
      console.error('Vehicle lookup error:', err);
      const axiosErr = err as { response?: { status: number; data?: { error?: string } }; message?: string };
      if (axiosErr?.response?.status === 404) {
        setError('Vehicle not found. Please check the registration number.');
      } else if (axiosErr?.response?.data?.error) {
        setError(axiosErr.response.data.error);
      } else if (axiosErr?.message) {
        setError(axiosErr.message);
      } else {
        setError('Failed to look up vehicle. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      handleSearch();
    }
  };

  const handleGetFullReport = async () => {
    if (!result) return;
    
    setPredictLoading(true);
    setError(null);
    
    try {
      // Call prediction API
      const response = await axios.post('/api/v1/prediction', {
        make: result.make,
        model: result.model,
        year: result.year,
        mileage: result.currentMileage || 60000,
        fuelType: result.fuelType || 'Petrol',
      });
      
      // Transform response to match ResultsPage expected format
      const prediction = {
        reportId: response.data.predictionId,
        make: result.make,
        model: result.model,
        year: result.year,
        mileage: result.currentMileage || 60000,
        totalEstimatedCost: response.data.estimatedTwelveMonthCost || response.data.annualRepairCost || 0,
        predictedFailures: (response.data.predictedFailures || []).map((f: { componentName: string; failureDescription: string; probability: number; estimatedCost: { min: number; max: number }; urgency: string; mileageThreshold?: number }) => ({
          componentName: f.componentName,
          failureDescription: f.failureDescription,
          probability: f.probability,
          estimatedCost: f.estimatedCost?.min || 0,
          urgency: f.urgency || 'Medium',
          mileageThreshold: f.mileageThreshold,
        })),
        generatedAt: response.data.generatedAt,
        riskScore: 100 - (response.data.reliabilityScore || 95),
        // Include MOT history data
        motHistory: result.motHistory,
        recentDefects: result.recentDefects,
        registration: result.registration,
        reliabilityGrade: response.data.reliabilityGrade,
        reliabilityScore: response.data.reliabilityScore,
      };
      
      // Navigate to results with the prediction data
      navigate('/results', { state: { prediction } });
    } catch (err) {
      console.error('Prediction error:', err);
      setError('Failed to generate repair prediction. Please try again.');
    } finally {
      setPredictLoading(false);
    }
  };

  const handleClear = () => {
    setRegistration('');
    setResult(null);
    setError(null);
  };

  const getMotStatusColor = (status?: string) => {
    if (!status) return 'text-gray-500';
    const lower = status.toLowerCase();
    if (lower.includes('valid')) return 'text-green-600';
    if (lower.includes('expired') || lower.includes('sorn')) return 'text-red-600';
    return 'text-amber-600';
  };

  const getTaxStatusColor = (status?: string) => {
    if (!status) return 'text-gray-500';
    const lower = status.toLowerCase();
    if (lower.includes('taxed')) return 'text-green-600';
    if (lower.includes('sorn') || lower.includes('untaxed')) return 'text-red-600';
    return 'text-amber-600';
  };

  return (
    <div className="space-y-4">
      {/* Search Input */}
      <form onSubmit={(e) => { e.preventDefault(); handleSearch(); }} className="flex gap-2">
        <div className="relative flex-1">
          <input
            type="text"
            value={registration}
            onChange={(e) => setRegistration(e.target.value.toUpperCase())}
            onKeyDown={handleKeyDown}
            placeholder="AB12 CDE"
            className="block w-full px-4 py-3 text-2xl font-bold tracking-[0.25em] text-center border-2 border-gray-800 rounded-md focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            style={{
              backgroundColor: '#F7D117',
              color: '#000000',
              fontFamily: 'ui-monospace, SFMono-Regular, "SF Mono", Consolas, "Liberation Mono", Menlo, monospace',
              textTransform: 'uppercase',
            }}
            maxLength={8}
          />
          {registration && (
            <button
              type="button"
              onClick={handleClear}
              className="absolute inset-y-0 right-0 pr-3 flex items-center"
            >
              <X className="h-5 w-5 text-gray-800 hover:text-gray-600" />
            </button>
          )}
        </div>
        <Button
          type="submit"
          disabled={loading || !registration.trim()}
          className="px-6"
        >
          {loading ? <Spinner size="sm" /> : <Search className="h-5 w-5" />}
        </Button>
      </form>

      {/* Error Message */}
      {error && (
        <div className="flex items-center gap-2 text-red-600 bg-red-50 p-3 rounded-lg">
          <AlertCircle className="h-5 w-5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Results */}
      {result && showFullResults && (
        <Card className="!p-0 overflow-hidden">
          {/* Demo Mode Banner */}
          {result.isDemo && (
            <div className="bg-amber-50 border-b border-amber-200 px-4 py-2 text-sm text-amber-800">
              Demo mode - showing sample data. Configure API keys for live lookups.
            </div>
          )}

          {/* Vehicle Summary */}
          <div className="bg-gradient-to-r from-primary-600 to-primary-700 text-white p-4">
            <div className="flex items-start justify-between">
              <div>
                <div className="text-sm opacity-80">{result.registration}</div>
                <h3 className="text-2xl font-bold">
                  {result.year} {result.make} {result.model}
                </h3>
                <div className="flex flex-wrap gap-3 mt-2 text-sm">
                  {result.fuelType && (
                    <span className="flex items-center gap-1">
                      <Fuel className="h-4 w-4" />
                      {result.fuelType}
                    </span>
                  )}
                  {result.engineSize && (
                    <span className="flex items-center gap-1">
                      <Gauge className="h-4 w-4" />
                      {result.engineSize}cc
                    </span>
                  )}
                  {result.colour && <span>{result.colour}</span>}
                </div>
              </div>
              {result.prediction && (
                <div className="text-right">
                  <div className="text-sm opacity-80">Reliability</div>
                  <div className={`text-3xl font-bold ${
                    result.prediction.reliabilityGrade === 'A' ? 'text-green-300' :
                    result.prediction.reliabilityGrade === 'B' ? 'text-green-200' :
                    result.prediction.reliabilityGrade === 'C' ? 'text-yellow-300' :
                    result.prediction.reliabilityGrade === 'D' ? 'text-orange-300' :
                    'text-red-300'
                  }`}>
                    {result.prediction.reliabilityGrade}
                  </div>
                  <div className="text-xs opacity-70">
                    Score: {result.prediction.reliabilityScore.toFixed(1)}%
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Status Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 p-4 bg-gray-50">
            {/* Mileage */}
            <div className="text-center">
              <div className="text-xs text-gray-500 uppercase tracking-wide">Mileage</div>
              <div className="text-xl font-bold text-gray-900">
                {result.currentMileage?.toLocaleString() || 'Unknown'}
              </div>
            </div>

            {/* MOT Status */}
            <div className="text-center">
              <div className="text-xs text-gray-500 uppercase tracking-wide">MOT</div>
              <div className={`text-xl font-bold ${getMotStatusColor(result.motStatus)}`}>
                {result.motStatus || 'Unknown'}
              </div>
              {result.motExpiryDate && (
                <div className="text-xs text-gray-500">
                  Expires: {new Date(result.motExpiryDate).toLocaleDateString('en-GB')}
                </div>
              )}
            </div>

            {/* Tax Status */}
            <div className="text-center">
              <div className="text-xs text-gray-500 uppercase tracking-wide">Tax</div>
              <div className={`text-xl font-bold ${getTaxStatusColor(result.taxStatus)}`}>
                {result.taxStatus || 'Unknown'}
              </div>
            </div>

            {/* MOT History Summary */}
            <div className="text-center">
              <div className="text-xs text-gray-500 uppercase tracking-wide">MOT Tests</div>
              <div className="text-xl font-bold text-gray-900">
                {result.motHistory.length} tests
              </div>
            </div>
          </div>

          {/* MOT History */}
          {result.motHistory.length > 0 && (
            <div className="p-4 border-t">
              <h4 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                <Clock className="h-4 w-4" />
                Recent MOT History
              </h4>
              <div className="space-y-2">
                {result.motHistory.slice(0, 3).map((test, idx) => (
                  <div
                    key={idx}
                    className={`flex items-center justify-between p-2 rounded ${
                      test.passed ? 'bg-green-50' : 'bg-red-50'
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      {test.passed ? (
                        <CheckCircle className="h-4 w-4 text-green-600" />
                      ) : (
                        <AlertCircle className="h-4 w-4 text-red-600" />
                      )}
                      <span className="font-medium">
                        {new Date(test.testDate).toLocaleDateString('en-GB')}
                      </span>
                    </div>
                    <div className="flex items-center gap-4 text-sm">
                      {test.mileage && (
                        <span className="text-gray-600">
                          {test.mileage.toLocaleString()} miles
                        </span>
                      )}
                      {test.defectCount > 0 && (
                        <span className="text-red-600">{test.defectCount} failures</span>
                      )}
                      {test.advisoryCount > 0 && (
                        <span className="text-amber-600">{test.advisoryCount} advisories</span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Recent Defects */}
          {result.recentDefects && result.recentDefects.length > 0 && (
            <div className="p-4 border-t">
              <h4 className="font-semibold text-gray-900 mb-2">Recent Issues Found</h4>
              <ul className="space-y-1">
                {result.recentDefects.slice(0, 5).map((defect, idx) => (
                  <li key={idx} className="text-sm text-gray-600 flex items-start gap-2">
                    <AlertCircle className="h-4 w-4 text-amber-500 flex-shrink-0 mt-0.5" />
                    <span className="capitalize">{defect}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Predicted Costs */}
          {result.prediction && (
            <div className="p-4 border-t bg-primary-50">
              <h4 className="font-semibold text-gray-900 mb-2">Predicted Annual Repair Cost</h4>
              <div className="text-3xl font-bold text-primary-700">
                £{result.prediction.estimatedAnnualCost.toLocaleString()}
              </div>
              {result.prediction.topIssues.length > 0 && (
                <div className="mt-3 space-y-1">
                  {result.prediction.topIssues.slice(0, 3).map((issue, idx) => (
                    <div key={idx} className="flex justify-between text-sm">
                      <span>{issue.name}</span>
                      <span className="text-gray-600">{issue.costRange}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Action Button */}
          <div className="p-4 border-t">
            <Button 
              type="button" 
              onClick={handleGetFullReport} 
              disabled={predictLoading}
              className="w-full"
            >
              {predictLoading ? (
                <>
                  <Spinner size="sm" className="mr-2" />
                  Generating Report...
                </>
              ) : (
                'Get Full Repair Prediction Report'
              )}
            </Button>
          </div>
        </Card>
      )}
    </div>
  );
}
