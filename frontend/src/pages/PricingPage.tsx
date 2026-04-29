import { useState } from 'react'
import { Link } from 'react-router-dom'
import { 
  Check, 
  X,
  Zap,
  Shield,
  Star,
  HelpCircle,
  Loader2
} from 'lucide-react'
import Button from '../components/ui/Button'
import Card from '../components/ui/Card'
import Input from '../components/ui/Input'
import { redirectToCheckout } from '../services/stripe'
import { SEOHead, getFAQSchema, getWebPageSchema } from '../components/seo'

const plans = [
  {
    id: 'free',
    name: 'Free',
    description: 'Perfect for one-off checks',
    price: 0,
    period: '',
    features: [
      { text: '3 predictions per month', included: true },
      { text: 'Basic repair cost estimates', included: true },
      { text: 'MOT failure analysis', included: true },
      { text: 'PDF report download', included: false },
      { text: 'Historical comparisons', included: false },
      { text: 'Priority support', included: false },
    ],
    cta: 'Get Started Free',
    popular: false,
  },
  {
    id: 'basic',
    name: 'Basic',
    description: 'For regular car buyers',
    price: 4.99,
    period: '/month',
    features: [
      { text: '20 predictions per month', included: true },
      { text: 'Detailed repair cost breakdown', included: true },
      { text: 'MOT failure analysis', included: true },
      { text: 'PDF report download', included: true },
      { text: 'Historical comparisons', included: false },
      { text: 'Priority support', included: false },
    ],
    cta: 'Start Basic Plan',
    popular: false,
  },
  {
    id: 'premium',
    name: 'Premium',
    description: 'For dealers & enthusiasts',
    price: 14.99,
    period: '/month',
    features: [
      { text: 'Unlimited predictions', included: true },
      { text: 'Detailed repair cost breakdown', included: true },
      { text: 'Full MOT history analysis', included: true },
      { text: 'PDF report download', included: true },
      { text: 'Historical comparisons', included: true },
      { text: 'Priority support', included: true },
    ],
    cta: 'Start Premium Plan',
    popular: true,
  },
]

const faqs = [
  {
    question: 'How accurate are the predictions?',
    answer: 'Our predictions are based on real MOT failure data and common fault databases for UK vehicles. We achieve approximately 92% accuracy for identifying potential repair needs.',
  },
  {
    question: 'Can I cancel my subscription anytime?',
    answer: 'Yes, you can cancel your subscription at any time. You will continue to have access until the end of your billing period.',
  },
  {
    question: 'Do you support all car makes and models?',
    answer: 'We currently support popular UK makes including BMW, Audi, Ford, Vauxhall, Volkswagen, and more. We are constantly adding new vehicles to our database.',
  },
  {
    question: 'How is the repair cost calculated?',
    answer: 'Repair costs are calculated using current UK labour rates and parts prices from our network of suppliers. Costs are updated monthly to reflect market changes.',
  },
]

export default function PricingPage() {
  const [billingPeriod, setBillingPeriod] = useState<'monthly' | 'annual'>('monthly')
  const [openFaq, setOpenFaq] = useState<number | null>(null)
  const [checkoutModal, setCheckoutModal] = useState<{ open: boolean; plan: string } | null>(null)
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const annualDiscount = 0.20 // 20% discount for annual

  const getPrice = (basePrice: number) => {
    if (basePrice === 0) return 0
    if (billingPeriod === 'annual') {
      return (basePrice * 12 * (1 - annualDiscount)).toFixed(2)
    }
    return basePrice.toFixed(2)
  }

  const handleCheckout = async (planId: string) => {
    if (planId === 'free') {
      window.location.href = '/signup'
      return
    }
    setCheckoutModal({ open: true, plan: planId })
  }

  const handleSubmitCheckout = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email || !checkoutModal) return

    setLoading(true)
    setError('')

    try {
      await redirectToCheckout(
        email,
        checkoutModal.plan as 'basic' | 'premium',
        billingPeriod === 'annual'
      )
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to start checkout')
      setLoading(false)
    }
  }

  return (
    <div className="min-h-[calc(100vh-200px)] bg-gray-50 py-12 fade-in">
      <SEOHead
        title="Pricing Plans"
        description="Choose a plan for car repair cost predictions. Free, Basic, and Premium options with MOT analysis and accurate UK repair estimates."
        keywords={[
          'car repair predictor pricing',
          'vehicle cost analysis subscription',
          'used car checker price',
          'MOT analysis tool cost',
        ]}
        canonicalUrl="/pricing"
        structuredData={{
          '@context': 'https://schema.org',
          '@graph': [
            getWebPageSchema({
              name: 'Pricing Plans - Car Repair Predictor',
              description: 'Choose a subscription plan for car repair cost predictions.',
              url: '/pricing',
            }),
            getFAQSchema(faqs),
          ],
        }}
      />
      
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
            Simple, Transparent Pricing
          </h1>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto mb-8">
            Choose the plan that fits your needs. All plans include our core prediction engine.
          </p>

          {/* Billing Toggle */}
          <div className="inline-flex items-center bg-white rounded-lg p-1 border border-gray-200">
            <button
              className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                billingPeriod === 'monthly' 
                  ? 'bg-primary-600 text-white' 
                  : 'text-gray-600 hover:text-gray-900'
              }`}
              onClick={() => setBillingPeriod('monthly')}
            >
              Monthly
            </button>
            <button
              className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
                billingPeriod === 'annual' 
                  ? 'bg-primary-600 text-white' 
                  : 'text-gray-600 hover:text-gray-900'
              }`}
              onClick={() => setBillingPeriod('annual')}
            >
              Annual
              <span className="ml-1 text-xs text-green-600 font-bold">Save 20%</span>
            </button>
          </div>
        </div>

        {/* Pricing Cards */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          {plans.map((plan) => (
            <Card 
              key={plan.id}
              className={`relative ${plan.popular ? 'border-primary-500 border-2' : ''}`}
            >
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                  <span className="inline-flex items-center gap-1 bg-primary-600 text-white text-sm font-medium px-3 py-1 rounded-full">
                    <Star className="w-4 h-4" />
                    Most Popular
                  </span>
                </div>
              )}

              <div className="text-center mb-6">
                <h3 className="text-xl font-semibold text-gray-900 mb-1">{plan.name}</h3>
                <p className="text-gray-500 text-sm">{plan.description}</p>
              </div>

              <div className="text-center mb-6">
                <div className="flex items-baseline justify-center">
                  <span className="text-4xl font-bold text-gray-900">
                    £{getPrice(plan.price)}
                  </span>
                  {plan.price > 0 && (
                    <span className="text-gray-500 ml-1">
                      {billingPeriod === 'annual' ? '/year' : plan.period}
                    </span>
                  )}
                </div>
                {billingPeriod === 'annual' && plan.price > 0 && (
                  <p className="text-sm text-green-600 mt-1">
                    Save £{((plan.price * 12 * annualDiscount)).toFixed(2)} per year
                  </p>
                )}
              </div>

              <ul className="space-y-3 mb-8">
                {plan.features.map((feature, index) => (
                  <li key={index} className="flex items-start gap-3">
                    {feature.included ? (
                      <Check className="w-5 h-5 text-green-500 flex-shrink-0" />
                    ) : (
                      <X className="w-5 h-5 text-gray-300 flex-shrink-0" />
                    )}
                    <span className={feature.included ? 'text-gray-700' : 'text-gray-400'}>
                      {feature.text}
                    </span>
                  </li>
                ))}
              </ul>

              <Button 
                className="w-full" 
                variant={plan.popular ? 'primary' : 'secondary'}
                onClick={() => handleCheckout(plan.id)}
              >
                {plan.cta}
              </Button>
            </Card>
          ))}
        </div>

        {/* Trust Indicators */}
        <div className="bg-white rounded-2xl p-8 mb-16">
          <div className="grid md:grid-cols-3 gap-8 text-center">
            <div className="flex flex-col items-center">
              <div className="w-14 h-14 bg-green-100 rounded-xl flex items-center justify-center mb-4">
                <Shield className="w-7 h-7 text-green-600" />
              </div>
              <h3 className="font-semibold text-gray-900 mb-1">Secure Payments</h3>
              <p className="text-sm text-gray-500">256-bit SSL encryption for all transactions</p>
            </div>
            <div className="flex flex-col items-center">
              <div className="w-14 h-14 bg-blue-100 rounded-xl flex items-center justify-center mb-4">
                <Zap className="w-7 h-7 text-blue-600" />
              </div>
              <h3 className="font-semibold text-gray-900 mb-1">Instant Access</h3>
              <p className="text-sm text-gray-500">Start using predictions immediately after signup</p>
            </div>
            <div className="flex flex-col items-center">
              <div className="w-14 h-14 bg-purple-100 rounded-xl flex items-center justify-center mb-4">
                <Star className="w-7 h-7 text-purple-600" />
              </div>
              <h3 className="font-semibold text-gray-900 mb-1">Money-Back Guarantee</h3>
              <p className="text-sm text-gray-500">30-day refund if you're not satisfied</p>
            </div>
          </div>
        </div>

        {/* FAQs */}
        <div className="max-w-3xl mx-auto">
          <h2 className="text-2xl font-bold text-gray-900 text-center mb-8">
            Frequently Asked Questions
          </h2>
          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <Card key={index} hover onClick={() => setOpenFaq(openFaq === index ? null : index)}>
                <div className="flex items-center justify-between">
                  <h3 className="font-medium text-gray-900">{faq.question}</h3>
                  <HelpCircle className={`w-5 h-5 text-gray-400 transition-transform ${
                    openFaq === index ? 'rotate-180' : ''
                  }`} />
                </div>
                {openFaq === index && (
                  <p className="text-gray-600 mt-4 pt-4 border-t border-gray-100">
                    {faq.answer}
                  </p>
                )}
              </Card>
            ))}
          </div>
        </div>

        {/* CTA */}
        <div className="text-center mt-16">
          <p className="text-gray-600 mb-4">Still have questions?</p>
          <Link to="/contact">
            <Button variant="secondary">Contact Us</Button>
          </Link>
        </div>
      </div>

      {/* Checkout Modal */}
      {checkoutModal?.open && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <Card className="w-full max-w-md">
            <div className="text-center mb-6">
              <h3 className="text-xl font-semibold text-gray-900">
                Subscribe to {checkoutModal.plan.charAt(0).toUpperCase() + checkoutModal.plan.slice(1)}
              </h3>
              <p className="text-gray-500 text-sm mt-1">
                {billingPeriod === 'annual' ? 'Annual' : 'Monthly'} billing
              </p>
            </div>

            <form onSubmit={handleSubmitCheckout}>
              <div className="mb-4">
                <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                  Email Address
                </label>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>

              {error && (
                <div className="mb-4 p-3 bg-red-50 text-red-700 rounded-lg text-sm">
                  {error}
                </div>
              )}

              <div className="flex gap-3">
                <Button
                  type="button"
                  variant="secondary"
                  className="flex-1"
                  onClick={() => {
                    setCheckoutModal(null)
                    setEmail('')
                    setError('')
                  }}
                  disabled={loading}
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  className="flex-1"
                  disabled={loading || !email}
                >
                  {loading ? (
                    <span className="flex items-center justify-center gap-2">
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Processing...
                    </span>
                  ) : (
                    'Continue to Payment'
                  )}
                </Button>
              </div>
            </form>

            <p className="text-xs text-gray-500 text-center mt-4">
              Secure payment powered by Stripe. You can cancel anytime.
            </p>
          </Card>
        </div>
      )}
    </div>
  )
}
