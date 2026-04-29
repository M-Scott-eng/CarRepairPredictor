import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { useQuery, useMutation } from '@tanstack/react-query'
import axios from 'axios'
import { 
  Car, 
  Gauge, 
  Calendar,
  ChevronRight,
  ChevronLeft,
  AlertCircle,
  Info
} from 'lucide-react'
import Button from '../components/ui/Button'
import Select from '../components/ui/Select'
import Input from '../components/ui/Input'
import Card from '../components/ui/Card'
import { SEOHead, getWebPageSchema } from '../components/seo'

interface PredictFormData {
  make: string
  model: string
  year: number
  mileage: number
}

interface Make {
  id: number
  name: string
}

interface Model {
  id: number
  name: string
  makeId: number
}

const steps = [
  { id: 1, title: 'Make & Model', icon: Car },
  { id: 2, title: 'Year & Mileage', icon: Calendar },
  { id: 3, title: 'Review', icon: Info },
]

export default function PredictPage() {
  const navigate = useNavigate()
  const [currentStep, setCurrentStep] = useState(1)
  
  const { register, handleSubmit, watch, formState: { errors } } = useForm<PredictFormData>({
    defaultValues: {
      make: '',
      model: '',
      year: 0,
      mileage: 0,
    }
  })

  const selectedMake = watch('make')
  const selectedModel = watch('model')
  const selectedYear = watch('year')
  const selectedMileage = watch('mileage')

  // Fetch makes
  const { data: makes, isLoading: makesLoading, error: makesError } = useQuery({
    queryKey: ['makes'],
    queryFn: async () => {
      const response = await axios.get<{ makes: Make[] }>('/api/v1/cars/makes')
      return response.data.makes
    }
  })

  // Fetch models based on selected make
  const { data: models, isLoading: modelsLoading } = useQuery({
    queryKey: ['models', selectedMake],
    queryFn: async () => {
      const response = await axios.get<{ models: Model[] }>(`/api/v1/cars/models?makeId=${selectedMake}`)
      return response.data.models
    },
    enabled: !!selectedMake,
  })

  // Fetch years based on selected model
  const { data: years, isLoading: yearsLoading } = useQuery({
    queryKey: ['years', selectedModel],
    queryFn: async () => {
      const response = await axios.get<{ years: number[] }>(`/api/v1/cars/years?modelId=${selectedModel}`)
      return response.data.years.map(y => ({ year: y }))
    },
    enabled: !!selectedModel,
  })

  // Prediction mutation
  const predictMutation = useMutation({
    mutationFn: async (data: PredictFormData) => {
      const makeName = makes?.find(m => m.id.toString() === data.make)?.name || ''
      const modelName = models?.find(m => m.id.toString() === data.model)?.name || ''
      
      const response = await axios.post('/api/v1/prediction', {
        make: makeName,
        model: modelName,
        year: parseInt(data.year.toString()),
        mileage: parseInt(data.mileage.toString()),
        regionCode: 'UK',
      })
      return response.data
    },
    onSuccess: (data) => {
      // Navigate to results page with prediction data
      navigate('/results', { state: { prediction: data } })
    },
  })

  const onSubmit = (data: PredictFormData) => {
    predictMutation.mutate(data)
  }

  const nextStep = () => {
    if (currentStep < 3) setCurrentStep(currentStep + 1)
  }

  const prevStep = () => {
    if (currentStep > 1) setCurrentStep(currentStep - 1)
  }

  const canProceedStep1 = selectedMake && selectedModel
  const canProceedStep2 = selectedYear && selectedMileage && selectedMileage > 0

  const getSelectedMakeName = () => makes?.find(m => m.id.toString() === selectedMake)?.name || ''
  const getSelectedModelName = () => models?.find(m => m.id.toString() === selectedModel)?.name || ''

  return (
    <div className="min-h-[calc(100vh-200px)] bg-gray-50 py-12 fade-in">
      <SEOHead
        title="Predict Car Repair Costs"
        description="Enter your vehicle details to get accurate repair cost predictions. Our tool analyses MOT data and common faults for UK cars."
        keywords={[
          'car repair cost calculator',
          'predict car repairs UK',
          'vehicle maintenance costs',
          'used car reliability check',
          'MOT failure predictor',
        ]}
        canonicalUrl="/predict"
        structuredData={getWebPageSchema({
          name: 'Car Repair Cost Prediction Tool',
          description: 'Enter your vehicle details to get accurate repair cost predictions for UK cars.',
          url: '/predict',
        })}
      />
      
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-10">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Get Your Repair Cost Prediction</h1>
          <p className="text-gray-600">Enter your vehicle details to receive an accurate cost estimate.</p>
        </div>

        {/* Progress Steps */}
        <div className="mb-10">
          <div className="flex items-center justify-between">
            {steps.map((step, index) => (
              <div key={step.id} className="flex-1 relative">
                <div className="flex items-center">
                  <div 
                    className={`w-10 h-10 rounded-full flex items-center justify-center ${
                      currentStep >= step.id 
                        ? 'bg-primary-600 text-white' 
                        : 'bg-gray-200 text-gray-500'
                    }`}
                  >
                    <step.icon className="w-5 h-5" />
                  </div>
                  {index < steps.length - 1 && (
                    <div 
                      className={`flex-1 h-1 mx-2 ${
                        currentStep > step.id ? 'bg-primary-600' : 'bg-gray-200'
                      }`}
                    />
                  )}
                </div>
                <div className="mt-2">
                  <span className={`text-sm font-medium ${
                    currentStep >= step.id ? 'text-primary-600' : 'text-gray-500'
                  }`}>
                    {step.title}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Form Card */}
        <Card className="p-8">
          <form onSubmit={handleSubmit(onSubmit)}>
            {/* Step 1: Make & Model */}
            {currentStep === 1 && (
              <div className="space-y-6 slide-up">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center">
                    <Car className="w-6 h-6 text-primary-600" />
                  </div>
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900">Select Your Vehicle</h2>
                    <p className="text-gray-500 text-sm">Choose the make and model</p>
                  </div>
                </div>

                {makesError && (
                  <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                    Unable to load vehicle makes. Please try again.
                  </div>
                )}

                <Select
                  label="Make"
                  placeholder={makesLoading ? "Loading..." : "Select a make..."}
                  options={makes?.map(m => ({ value: String(m.id), label: m.name })) || []}
                  disabled={makesLoading}
                  error={errors.make?.message}
                  {...register('make', { required: 'Please select a make' })}
                />

                <Select
                  label="Model"
                  placeholder={selectedMake ? "Select a model..." : "Select a make first"}
                  options={models?.map(m => ({ value: String(m.id), label: m.name })) || []}
                  disabled={!selectedMake || modelsLoading}
                  error={errors.model?.message}
                  {...register('model', { required: 'Please select a model' })}
                />

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 flex items-start gap-3">
                  <Info className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                  <div className="text-sm text-blue-700">
                    <p className="font-medium">Popular UK Cars Supported</p>
                    <p className="mt-1">BMW 3 Series, Audi A4, Ford Fiesta, Vauxhall Corsa, and more.</p>
                  </div>
                </div>
              </div>
            )}

            {/* Step 2: Year & Mileage */}
            {currentStep === 2 && (
              <div className="space-y-6 slide-up">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center">
                    <Gauge className="w-6 h-6 text-primary-600" />
                  </div>
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900">Vehicle Details</h2>
                    <p className="text-gray-500 text-sm">Enter the year and current mileage</p>
                  </div>
                </div>

                <Select
                  label="Year"
                  placeholder={selectedModel ? "Select year..." : "Select model first"}
                  options={years?.map(y => ({ value: String(y.year), label: y.year.toString() })) || []}
                  disabled={!selectedModel || yearsLoading}
                  error={errors.year?.message}
                  {...register('year', { 
                    required: 'Please select a year',
                    valueAsNumber: true,
                  })}
                />

                <Input
                  label="Current Mileage"
                  type="number"
                  placeholder="e.g. 85000"
                  helperText="Enter the current odometer reading in miles"
                  error={errors.mileage?.message}
                  {...register('mileage', { 
                    required: 'Please enter the mileage',
                    min: { value: 1, message: 'Mileage must be greater than 0' },
                    max: { value: 500000, message: 'Please enter a valid mileage' },
                    valueAsNumber: true,
                  })}
                />

                <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 flex items-start gap-3">
                  <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                  <div className="text-sm text-amber-700">
                    <p className="font-medium">Why Mileage Matters</p>
                    <p className="mt-1">Higher mileage vehicles typically have more wear on key components like timing chains, suspension, and clutches.</p>
                  </div>
                </div>
              </div>
            )}

            {/* Step 3: Review */}
            {currentStep === 3 && (
              <div className="space-y-6 slide-up">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center">
                    <Info className="w-6 h-6 text-primary-600" />
                  </div>
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900">Review Your Details</h2>
                    <p className="text-gray-500 text-sm">Confirm the information before generating your prediction</p>
                  </div>
                </div>

                <div className="bg-gray-50 rounded-xl p-6 space-y-4">
                  <div className="flex justify-between items-center py-3 border-b border-gray-200">
                    <span className="text-gray-600">Make</span>
                    <span className="font-semibold text-gray-900">{getSelectedMakeName()}</span>
                  </div>
                  <div className="flex justify-between items-center py-3 border-b border-gray-200">
                    <span className="text-gray-600">Model</span>
                    <span className="font-semibold text-gray-900">{getSelectedModelName()}</span>
                  </div>
                  <div className="flex justify-between items-center py-3 border-b border-gray-200">
                    <span className="text-gray-600">Year</span>
                    <span className="font-semibold text-gray-900">{selectedYear}</span>
                  </div>
                  <div className="flex justify-between items-center py-3">
                    <span className="text-gray-600">Mileage</span>
                    <span className="font-semibold text-gray-900">{selectedMileage?.toLocaleString()} miles</span>
                  </div>
                </div>

                {predictMutation.isError && (
                  <div className="bg-red-50 border border-red-200 rounded-lg p-4 flex items-start gap-3">
                    <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
                    <div className="text-sm text-red-700">
                      <p className="font-medium">Prediction Failed</p>
                      <p className="mt-1">Unable to generate prediction. Please try again.</p>
                    </div>
                  </div>
                )}
              </div>
            )}

            {/* Navigation Buttons */}
            <div className="flex justify-between mt-8 pt-6 border-t border-gray-200">
              <Button
                type="button"
                variant="secondary"
                onClick={prevStep}
                disabled={currentStep === 1}
                icon={<ChevronLeft className="w-4 h-4" />}
              >
                Back
              </Button>

              {currentStep < 3 ? (
                <Button
                  type="button"
                  onClick={nextStep}
                  disabled={
                    (currentStep === 1 && !canProceedStep1) ||
                    (currentStep === 2 && !canProceedStep2)
                  }
                >
                  Continue
                  <ChevronRight className="ml-2 w-4 h-4" />
                </Button>
              ) : (
                <Button
                  type="submit"
                  loading={predictMutation.isPending}
                  disabled={!canProceedStep1 || !canProceedStep2}
                >
                  Get Prediction
                  <ChevronRight className="ml-2 w-4 h-4" />
                </Button>
              )}
            </div>
          </form>
        </Card>
      </div>
    </div>
  )
}
