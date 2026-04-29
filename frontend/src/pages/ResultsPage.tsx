import { useLocation, Link, Navigate } from 'react-router-dom'
import { 
  AlertTriangle, 
  Clock, 
  PoundSterling,
  Wrench,
  ChevronRight,
  Download,
  Share2,
  CheckCircle,
  Info,
  TrendingUp
} from 'lucide-react'
import Button from '../components/ui/Button'
import Card from '../components/ui/Card'
import Badge from '../components/ui/Badge'

interface PredictedFailure {
  componentName: string
  failureDescription: string
  probability: number
  estimatedCost: number
  urgency: 'Low' | 'Medium' | 'High' | 'Critical'
  mileageThreshold?: number
}

interface PredictionResult {
  reportId: string
  make: string
  model: string
  year: number
  mileage: number
  totalEstimatedCost: number
  predictedFailures: PredictedFailure[]
  generatedAt: string
  riskScore: number
}

const getUrgencyVariant = (urgency: string): 'success' | 'warning' | 'danger' | 'info' => {
  switch (urgency) {
    case 'Critical': return 'danger'
    case 'High': return 'danger'
    case 'Medium': return 'warning'
    case 'Low': return 'success'
    default: return 'info'
  }
}

const getRiskLevel = (score: number): { label: string; color: string; bg: string } => {
  if (score >= 80) return { label: 'High Risk', color: 'text-red-600', bg: 'bg-red-100' }
  if (score >= 50) return { label: 'Medium Risk', color: 'text-amber-600', bg: 'bg-amber-100' }
  return { label: 'Low Risk', color: 'text-green-600', bg: 'bg-green-100' }
}

export default function ResultsPage() {
  const location = useLocation()
  const prediction = location.state?.prediction as PredictionResult | undefined

  // Redirect if no prediction data
  if (!prediction) {
    return <Navigate to="/predict" replace />
  }

  const risk = getRiskLevel(prediction.riskScore)
  const highPriorityItems = prediction.predictedFailures.filter(f => f.urgency === 'High' || f.urgency === 'Critical')
  const mediumPriorityItems = prediction.predictedFailures.filter(f => f.urgency === 'Medium')
  const lowPriorityItems = prediction.predictedFailures.filter(f => f.urgency === 'Low')

  return (
    <div className="min-h-[calc(100vh-200px)] bg-gray-50 py-12 fade-in">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Repair Cost Prediction</h1>
            <p className="text-gray-600">
              {prediction.year} {prediction.make} {prediction.model} • {prediction.mileage.toLocaleString()} miles
            </p>
          </div>
          <div className="flex gap-3 mt-4 md:mt-0">
            <Button variant="secondary" size="sm" icon={<Share2 className="w-4 h-4" />}>
              Share
            </Button>
            <Button variant="secondary" size="sm" icon={<Download className="w-4 h-4" />}>
              Download PDF
            </Button>
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          {/* Total Cost */}
          <Card className="bg-gradient-to-br from-primary-50 to-white border-primary-200">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center">
                <PoundSterling className="w-7 h-7 text-primary-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Estimated Total</p>
                <p className="text-3xl font-bold text-primary-600">
                  £{prediction.totalEstimatedCost.toLocaleString()}
                </p>
              </div>
            </div>
            <p className="text-sm text-gray-500 mt-4">Over the next 12-24 months</p>
          </Card>

          {/* Risk Score */}
          <Card>
            <div className="flex items-center gap-4">
              <div className={`w-14 h-14 ${risk.bg} rounded-xl flex items-center justify-center`}>
                <TrendingUp className={`w-7 h-7 ${risk.color}`} />
              </div>
              <div>
                <p className="text-sm text-gray-600">Risk Score</p>
                <p className={`text-3xl font-bold ${risk.color}`}>{prediction.riskScore}/100</p>
              </div>
            </div>
            <div className="mt-4">
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div 
                  className={`h-2 rounded-full ${
                    prediction.riskScore >= 80 ? 'bg-red-500' : 
                    prediction.riskScore >= 50 ? 'bg-amber-500' : 'bg-green-500'
                  }`}
                  style={{ width: `${prediction.riskScore}%` }}
                />
              </div>
              <p className={`text-sm font-medium mt-2 ${risk.color}`}>{risk.label}</p>
            </div>
          </Card>

          {/* Issues Found */}
          <Card>
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-amber-100 rounded-xl flex items-center justify-center">
                <AlertTriangle className="w-7 h-7 text-amber-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">Issues Identified</p>
                <p className="text-3xl font-bold text-gray-900">{prediction.predictedFailures.length}</p>
              </div>
            </div>
            <div className="flex gap-2 mt-4 flex-wrap">
              {highPriorityItems.length > 0 && (
                <Badge variant="danger" size="sm">{highPriorityItems.length} High</Badge>
              )}
              {mediumPriorityItems.length > 0 && (
                <Badge variant="warning" size="sm">{mediumPriorityItems.length} Medium</Badge>
              )}
              {lowPriorityItems.length > 0 && (
                <Badge variant="success" size="sm">{lowPriorityItems.length} Low</Badge>
              )}
            </div>
          </Card>
        </div>

        {/* High Priority Repairs */}
        {highPriorityItems.length > 0 && (
          <div className="mb-8">
            <div className="flex items-center gap-2 mb-4">
              <AlertTriangle className="w-5 h-5 text-red-500" />
              <h2 className="text-xl font-semibold text-gray-900">High Priority Repairs</h2>
            </div>
            <div className="space-y-4">
              {highPriorityItems.map((failure, index) => (
                <Card key={index} className="border-l-4 border-l-red-500">
                  <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <Wrench className="w-5 h-5 text-gray-400" />
                        <h3 className="font-semibold text-gray-900">{failure.componentName}</h3>
                        <Badge variant={getUrgencyVariant(failure.urgency)} size="sm">
                          {failure.urgency}
                        </Badge>
                      </div>
                      <p className="text-gray-600 text-sm mb-2">{failure.failureDescription}</p>
                      <div className="flex items-center gap-4 text-sm text-gray-500">
                        <span className="flex items-center gap-1">
                          <Clock className="w-4 h-4" />
                          {failure.probability}% probability
                        </span>
                        {failure.mileageThreshold && (
                          <span>Typical at {failure.mileageThreshold.toLocaleString()} miles</span>
                        )}
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-2xl font-bold text-gray-900">£{failure.estimatedCost.toLocaleString()}</p>
                      <p className="text-sm text-gray-500">Estimated cost</p>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        )}

        {/* Medium Priority Repairs */}
        {mediumPriorityItems.length > 0 && (
          <div className="mb-8">
            <div className="flex items-center gap-2 mb-4">
              <Clock className="w-5 h-5 text-amber-500" />
              <h2 className="text-xl font-semibold text-gray-900">Medium Priority Repairs</h2>
            </div>
            <div className="space-y-4">
              {mediumPriorityItems.map((failure, index) => (
                <Card key={index} className="border-l-4 border-l-amber-500">
                  <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <Wrench className="w-5 h-5 text-gray-400" />
                        <h3 className="font-semibold text-gray-900">{failure.componentName}</h3>
                        <Badge variant={getUrgencyVariant(failure.urgency)} size="sm">
                          {failure.urgency}
                        </Badge>
                      </div>
                      <p className="text-gray-600 text-sm mb-2">{failure.failureDescription}</p>
                      <div className="flex items-center gap-4 text-sm text-gray-500">
                        <span className="flex items-center gap-1">
                          <Clock className="w-4 h-4" />
                          {failure.probability}% probability
                        </span>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-2xl font-bold text-gray-900">£{failure.estimatedCost.toLocaleString()}</p>
                      <p className="text-sm text-gray-500">Estimated cost</p>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        )}

        {/* Low Priority Repairs */}
        {lowPriorityItems.length > 0 && (
          <div className="mb-8">
            <div className="flex items-center gap-2 mb-4">
              <CheckCircle className="w-5 h-5 text-green-500" />
              <h2 className="text-xl font-semibold text-gray-900">Low Priority Items</h2>
            </div>
            <div className="grid md:grid-cols-2 gap-4">
              {lowPriorityItems.map((failure, index) => (
                <Card key={index} className="border-l-4 border-l-green-500">
                  <div className="flex items-start justify-between">
                    <div>
                      <h3 className="font-semibold text-gray-900 mb-1">{failure.componentName}</h3>
                      <p className="text-gray-600 text-sm">{failure.failureDescription}</p>
                    </div>
                    <p className="font-bold text-gray-900">£{failure.estimatedCost.toLocaleString()}</p>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        )}

        {/* Info Box */}
        <Card className="bg-blue-50 border-blue-200 mb-8">
          <div className="flex items-start gap-4">
            <Info className="w-6 h-6 text-blue-600 flex-shrink-0" />
            <div>
              <h3 className="font-semibold text-blue-900 mb-1">About This Prediction</h3>
              <p className="text-blue-700 text-sm">
                This prediction is based on MOT failure patterns, known common faults, and 
                mileage-based wear data for {prediction.make} {prediction.model} vehicles. 
                Actual repair needs may vary based on vehicle history and maintenance.
              </p>
            </div>
          </div>
        </Card>

        {/* CTA */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link to="/predict">
            <Button variant="secondary" size="lg">
              New Prediction
            </Button>
          </Link>
          <Link to="/pricing">
            <Button size="lg">
              Save Full Report
              <ChevronRight className="ml-2 w-5 h-5" />
            </Button>
          </Link>
        </div>

        {/* Report Info */}
        <p className="text-center text-sm text-gray-500 mt-6">
          Report ID: {prediction.reportId} • Generated: {new Date(prediction.generatedAt).toLocaleString('en-GB')}
        </p>
      </div>
    </div>
  )
}
