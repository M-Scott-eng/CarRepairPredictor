import { Link } from 'react-router-dom'
import { 
  Car, 
  Shield, 
  Clock, 
  PoundSterling, 
  ChevronRight,
  Search,
  FileText,
  TrendingUp,
  CheckCircle,
  Star
} from 'lucide-react'
import Button from '../components/ui/Button'
import Card from '../components/ui/Card'
import { SEOHead, getOrganizationSchema, getWebsiteSchema, getServiceSchema } from '../components/seo'

const features = [
  {
    icon: Search,
    title: 'Instant Analysis',
    description: 'Get repair cost predictions in seconds using our comprehensive UK vehicle database.',
  },
  {
    icon: FileText,
    title: 'MOT History Integration',
    description: 'We analyse MOT failure patterns specific to your make, model, and year.',
  },
  {
    icon: TrendingUp,
    title: 'Part Wear Predictions',
    description: 'Understand which components are most likely to need replacement based on mileage.',
  },
  {
    icon: PoundSterling,
    title: 'Accurate UK Pricing',
    description: 'Labour and parts costs calibrated to current UK market rates.',
  },
]

const steps = [
  {
    number: '1',
    title: 'Enter Vehicle Details',
    description: 'Select make, model, year, and enter the mileage.',
  },
  {
    number: '2',
    title: 'Run Prediction',
    description: 'Our rule-based engine analyses common faults and MOT failure patterns.',
  },
  {
    number: '3',
    title: 'View Results',
    description: 'Get a detailed breakdown of predicted repair costs over 12-24 months.',
  },
]

const testimonials = [
  {
    quote: "Saved me from buying a BMW with potentially £2,000 in upcoming repairs. The timing chain warning was spot on!",
    author: "James T.",
    location: "Manchester",
    rating: 5,
  },
  {
    quote: "Used this before buying a second-hand Fiesta. The prediction helped me negotiate £400 off the asking price.",
    author: "Sarah M.",
    location: "Bristol",
    rating: 5,
  },
  {
    quote: "Finally, a tool that gives realistic UK repair costs. The MOT integration is brilliant.",
    author: "David K.",
    location: "Edinburgh",
    rating: 5,
  },
]

const stats = [
  { value: '500K+', label: 'Predictions Made' },
  { value: '92%', label: 'Accuracy Rate' },
  { value: '15K+', label: 'Happy Users' },
  { value: '£2.1M', label: 'Savings Identified' },
]

export default function HomePage() {
  const homeStructuredData = {
    '@context': 'https://schema.org',
    '@graph': [
      getOrganizationSchema(),
      getWebsiteSchema(),
      getServiceSchema(),
    ],
  };

  return (
    <div className="fade-in">
      <SEOHead
        title="Used Car Repair Cost Predictor UK"
        description="Predict repair costs for used cars before you buy. Get accurate estimates for MOT failures, common faults, and maintenance costs for UK vehicles."
        keywords={[
          'used car repair costs UK',
          'car reliability check',
          'MOT failure prediction',
          'BMW timing chain cost',
          'Audi repair costs',
          'Ford Fiesta reliability',
          'used car buying guide UK',
          'vehicle repair estimate',
        ]}
        canonicalUrl="/"
        structuredData={homeStructuredData}
      />
      
      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-primary-600 via-primary-700 to-primary-800 text-white overflow-hidden">
        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-10"></div>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28 relative">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div>
              <span className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-full text-sm mb-6">
                <Shield className="w-4 h-4" />
                Trusted by 15,000+ UK car buyers
              </span>
              <h1 className="text-4xl lg:text-5xl xl:text-6xl font-bold leading-tight mb-6">
                Know the True Cost of Your Used Car
              </h1>
              <p className="text-xl text-primary-100 mb-8 max-w-lg">
                Get accurate repair cost predictions based on MOT failure patterns, 
                mileage data, and UK market rates before you buy.
              </p>
              <div className="flex flex-col sm:flex-row gap-4">
                <Link to="/predict">
                  <Button size="lg" className="w-full sm:w-auto bg-white text-primary-700 hover:bg-gray-100">
                    Get Free Prediction
                    <ChevronRight className="ml-2 w-5 h-5" />
                  </Button>
                </Link>
                <Link to="/pricing">
                  <Button size="lg" variant="ghost" className="w-full sm:w-auto text-white border-white/30 hover:bg-white/10">
                    View Pricing
                  </Button>
                </Link>
              </div>
            </div>
            <div className="hidden lg:block relative">
              <div className="relative w-full aspect-square max-w-md mx-auto">
                <div className="absolute inset-0 bg-gradient-to-br from-white/10 to-transparent rounded-3xl transform rotate-6"></div>
                <div className="absolute inset-0 bg-white/5 backdrop-blur-sm rounded-3xl flex items-center justify-center">
                  <Car className="w-40 h-40 text-white/60" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Bar */}
      <section className="bg-white border-b border-gray-100">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {stats.map((stat) => (
              <div key={stat.label} className="text-center">
                <div className="text-3xl font-bold text-primary-600">{stat.value}</div>
                <div className="text-sm text-gray-500">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              Why Choose Our Predictor?
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Built specifically for the UK market with real MOT data and accurate labour rates.
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature) => (
              <Card key={feature.title} className="text-center" hover>
                <div className="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center mx-auto mb-4">
                  <feature.icon className="w-7 h-7 text-primary-600" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-2">{feature.title}</h3>
                <p className="text-gray-600 text-sm">{feature.description}</p>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              How It Works
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Get your repair cost prediction in three simple steps.
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            {steps.map((step, index) => (
              <div key={step.number} className="relative">
                {index < steps.length - 1 && (
                  <div className="hidden md:block absolute top-10 left-[60%] w-[80%] h-0.5 bg-primary-200"></div>
                )}
                <div className="flex flex-col items-center text-center">
                  <div className="w-20 h-20 bg-primary-600 rounded-full flex items-center justify-center text-white text-2xl font-bold mb-6 relative z-10">
                    {step.number}
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2">{step.title}</h3>
                  <p className="text-gray-600">{step.description}</p>
                </div>
              </div>
            ))}
          </div>
          <div className="text-center mt-12">
            <Link to="/predict">
              <Button size="lg">
                Start Your Prediction
                <ChevronRight className="ml-2 w-5 h-5" />
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              What Our Users Say
            </h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Join thousands of UK car buyers who made smarter decisions.
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <Card key={index}>
                <div className="flex gap-1 mb-4">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                  ))}
                </div>
                <p className="text-gray-700 mb-4 italic">"{testimonial.quote}"</p>
                <div className="flex items-center gap-2">
                  <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center text-primary-600 font-semibold">
                    {testimonial.author[0]}
                  </div>
                  <div>
                    <div className="font-medium text-gray-900">{testimonial.author}</div>
                    <div className="text-sm text-gray-500">{testimonial.location}</div>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-primary-600">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl lg:text-4xl font-bold text-white mb-4">
            Ready to Make a Smarter Purchase?
          </h2>
          <p className="text-xl text-primary-100 mb-8">
            Get your free repair cost prediction today and avoid expensive surprises.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to="/predict">
              <Button size="lg" className="w-full sm:w-auto bg-white text-primary-700 hover:bg-gray-100">
                Get Free Prediction
              </Button>
            </Link>
            <Link to="/signup">
              <Button size="lg" variant="ghost" className="w-full sm:w-auto text-white border-white/30 hover:bg-white/10">
                Create Account
              </Button>
            </Link>
          </div>
          <div className="mt-8 flex flex-wrap justify-center gap-6 text-primary-100 text-sm">
            <span className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4" />
              No credit card required
            </span>
            <span className="flex items-center gap-2">
              <Clock className="w-4 h-4" />
              Results in seconds
            </span>
            <span className="flex items-center gap-2">
              <Shield className="w-4 h-4" />
              100% secure
            </span>
          </div>
        </div>
      </section>
    </div>
  )
}
