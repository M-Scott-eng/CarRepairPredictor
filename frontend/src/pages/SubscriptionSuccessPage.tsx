import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { CheckCircle, ArrowRight, Loader2 } from 'lucide-react'
import Button from '../components/ui/Button'
import Card from '../components/ui/Card'

export default function SubscriptionSuccessPage() {
  const [searchParams] = useSearchParams()
  const sessionId = searchParams.get('session_id')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // In a real app, you would verify the session with your backend
    const timer = setTimeout(() => {
      setLoading(false)
    }, 1500)
    return () => clearTimeout(timer)
  }, [sessionId])

  if (loading) {
    return (
      <div className="min-h-[calc(100vh-200px)] flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="w-12 h-12 text-primary-600 animate-spin mx-auto mb-4" />
          <p className="text-gray-600">Confirming your subscription...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-[calc(100vh-200px)] bg-gray-50 py-12 fade-in">
      <div className="max-w-lg mx-auto px-4">
        <Card className="text-center">
          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle className="w-10 h-10 text-green-600" />
          </div>

          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            Subscription Activated!
          </h1>
          <p className="text-gray-600 mb-8">
            Thank you for subscribing. Your account has been upgraded and you now have access to all premium features.
          </p>

          <div className="bg-gray-50 rounded-lg p-4 mb-6">
            <h3 className="font-medium text-gray-900 mb-2">What's Next?</h3>
            <ul className="text-sm text-gray-600 space-y-2 text-left">
              <li className="flex items-start gap-2">
                <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                <span>Check your email for a confirmation receipt</span>
              </li>
              <li className="flex items-start gap-2">
                <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                <span>Start running unlimited predictions immediately</span>
              </li>
              <li className="flex items-start gap-2">
                <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                <span>Manage your subscription from your account page</span>
              </li>
            </ul>
          </div>

          <div className="flex flex-col sm:flex-row gap-3">
            <Link to="/predict" className="flex-1">
              <Button className="w-full" variant="primary">
                Start Predicting
                <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
            </Link>
            <Link to="/" className="flex-1">
              <Button className="w-full" variant="secondary">
                Go to Dashboard
              </Button>
            </Link>
          </div>
        </Card>

        <p className="text-center text-sm text-gray-500 mt-6">
          Need help? <a href="mailto:support@carrepairpredictor.co.uk" className="text-primary-600 hover:underline">Contact Support</a>
        </p>
      </div>
    </div>
  )
}
