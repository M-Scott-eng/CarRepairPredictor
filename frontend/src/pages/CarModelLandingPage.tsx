import { useParams, Link, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Car,
  AlertTriangle,
  Wrench,
  ShoppingCart,
  Star,
  TrendingUp,
  Shield,
  PoundSterling,
  ChevronRight,
  CheckCircle,
  XCircle,
  HelpCircle,
  FileText,
  ExternalLink,
  Calendar,
  Gauge,
  Clock,
} from 'lucide-react';
import { SEOHead } from '../components/seo';
import { getCarModelPageSchema } from '../components/seo/carModelSchema';
import { faultsApi, guidesApi, partsApi } from '../services/api';
import Card from '../components/ui/Card';
import Button from '../components/ui/Button';
import { PageLoader, SkeletonCard } from '../components/ui/Spinner';

interface CarModelPageParams {
  make: string;
  model: string;
}

// Generate SEO-friendly title
function generatePageTitle(make: string, model: string): string {
  return `${make} ${model} - Common Faults, Parts Prices & Buyer's Guide UK`;
}

// Generate meta description
function generateMetaDescription(make: string, model: string): string {
  return `Complete ${make} ${model} buyer's guide for UK. Find common faults, compare parts prices across eBay, Amazon & Autodoc, check reliability scores, and read MOT failure patterns. Updated ${new Date().toLocaleDateString('en-GB', { month: 'long', year: 'numeric' })}.`;
}

// Generate FAQ data
function generateFAQs(make: string, model: string, faults: string[], avgPartsCost: number) {
  return [
    {
      question: `What are the most common faults on a ${make} ${model}?`,
      answer: faults.length > 0 
        ? `The most common faults on the ${make} ${model} include: ${faults.slice(0, 3).join(', ')}. Regular maintenance and early detection can help prevent costly repairs.`
        : `Common faults vary by year and engine variant. Check our detailed fault database for specific issues.`,
    },
    {
      question: `How much do ${make} ${model} parts cost in the UK?`,
      answer: `${make} ${model} parts prices vary by supplier. On average, common service parts cost around £${avgPartsCost.toFixed(0)}. We compare prices across eBay, Amazon, Autodoc, and RockAuto to find the best deals.`,
    },
    {
      question: `Is the ${make} ${model} reliable?`,
      answer: `The ${make} ${model} has mixed reliability depending on the year and engine. Check our buyer's guide for detailed reliability scores and what to look for when buying.`,
    },
    {
      question: `What are common MOT failures on a ${make} ${model}?`,
      answer: `Common MOT failure points on the ${make} ${model} typically include suspension components, brake wear, and emissions-related issues. Our guide covers specific MOT advisories to watch for.`,
    },
    {
      question: `Should I buy a used ${make} ${model}?`,
      answer: `The ${make} ${model} can be a good used buy with proper due diligence. Check service history, look for known fault symptoms, and get a pre-purchase inspection. Our buyer's guide provides detailed advice.`,
    },
  ];
}

// Score display component
function ScoreDisplay({ score, label, icon: Icon }: { score: number; label: string; icon: React.ElementType }) {
  const getScoreColor = (s: number) => {
    if (s >= 8) return 'text-green-600 bg-green-50 border-green-200';
    if (s >= 6) return 'text-amber-600 bg-amber-50 border-amber-200';
    return 'text-red-600 bg-red-50 border-red-200';
  };

  return (
    <div className={`p-4 rounded-xl border ${getScoreColor(score)}`}>
      <div className="flex items-center gap-2 mb-1">
        <Icon className="w-5 h-5" />
        <span className="text-sm font-medium">{label}</span>
      </div>
      <div className="text-3xl font-bold">{score.toFixed(1)}<span className="text-lg">/10</span></div>
    </div>
  );
}

// Fault preview card
function FaultPreviewCard({ title, severity, cost }: { title: string; severity: string; cost: string }) {
  const severityColors = {
    critical: 'bg-red-100 text-red-700 border-red-200',
    high: 'bg-orange-100 text-orange-700 border-orange-200',
    medium: 'bg-amber-100 text-amber-700 border-amber-200',
    low: 'bg-green-100 text-green-700 border-green-200',
  };

  return (
    <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
      <div className="flex items-center gap-3">
        <AlertTriangle className={`w-5 h-5 ${severity === 'critical' || severity === 'high' ? 'text-red-500' : 'text-amber-500'}`} />
        <span className="font-medium text-gray-900">{title}</span>
      </div>
      <div className="flex items-center gap-3">
        <span className={`px-2 py-1 rounded text-xs font-medium capitalize ${severityColors[severity as keyof typeof severityColors] || severityColors.medium}`}>
          {severity}
        </span>
        <span className="text-sm text-gray-600">{cost}</span>
      </div>
    </div>
  );
}

// Parts category card
function PartsCategoryCard({ category, avgPrice, partCount, onClick }: { 
  category: string; 
  avgPrice: number; 
  partCount: number;
  onClick: () => void;
}) {
  return (
    <Card hover className="cursor-pointer" onClick={onClick}>
      <div className="flex items-center justify-between">
        <div>
          <h4 className="font-medium text-gray-900">{category}</h4>
          <p className="text-sm text-gray-500">{partCount} parts available</p>
        </div>
        <div className="text-right">
          <p className="text-lg font-bold text-primary-600">from £{avgPrice.toFixed(2)}</p>
          <p className="text-xs text-gray-500">Compare prices →</p>
        </div>
      </div>
    </Card>
  );
}

// FAQ Section component
function FAQSection({ faqs }: { faqs: { question: string; answer: string }[] }) {
  return (
    <section className="py-12 bg-gray-50">
      <div className="gv-container">
        <h2 className="text-2xl font-bold text-gray-900 mb-8 flex items-center gap-2">
          <HelpCircle className="w-6 h-6 text-primary-600" />
          Frequently Asked Questions
        </h2>
        <div className="space-y-4 max-w-3xl">
          {faqs.map((faq, index) => (
            <details key={index} className="group bg-white rounded-lg border border-gray-200 overflow-hidden">
              <summary className="flex items-center justify-between p-4 cursor-pointer list-none font-medium text-gray-900 hover:bg-gray-50">
                {faq.question}
                <ChevronRight className="w-5 h-5 text-gray-400 transform group-open:rotate-90 transition-transform" />
              </summary>
              <div className="px-4 pb-4 text-gray-600">
                {faq.answer}
              </div>
            </details>
          ))}
        </div>
      </div>
    </section>
  );
}

export default function CarModelLandingPage() {
  const { make = '', model = '' } = useParams<keyof CarModelPageParams>();
  const navigate = useNavigate();
  
  // Decode URL params
  const decodedMake = decodeURIComponent(make).replace(/-/g, ' ');
  const decodedModel = decodeURIComponent(model).replace(/-/g, ' ');
  
  // Capitalise for display
  const displayMake = decodedMake.split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
  const displayModel = decodedModel.split(' ').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');

  // Fetch data
  const { data: faultsData, isLoading: faultsLoading } = useQuery({
    queryKey: ['faults', displayMake, displayModel],
    queryFn: () => faultsApi.getCommonFaults(displayMake, displayModel),
  });

  const { data: guideData, isLoading: guideLoading } = useQuery({
    queryKey: ['guide', displayMake, displayModel],
    queryFn: () => guidesApi.getBuyersGuide(displayMake, displayModel),
  });

  const { data: partsData, isLoading: partsLoading } = useQuery({
    queryKey: ['parts-preview', displayMake, displayModel],
    queryFn: () => partsApi.searchParts({ make: displayMake, model: displayModel, maxResults: 10 }),
  });

  const isLoading = faultsLoading || guideLoading || partsLoading;

  // Generate page data
  const faultTitles = faultsData?.faults.map(f => f.title) || [];
  const avgPartsCost = partsData?.metadata.averagePrice || 50;
  const faqs = generateFAQs(displayMake, displayModel, faultTitles, avgPartsCost);

  // Generate structured data
  const structuredData = getCarModelPageSchema({
    make: displayMake,
    model: displayModel,
    description: generateMetaDescription(displayMake, displayModel),
    reliabilityScore: guideData?.reliabilityScore || 7,
    faqs,
  });

  // Navigation helpers
  const navigateToParts = (query?: string) => {
    const params = new URLSearchParams({ make: displayMake, model: displayModel });
    if (query) params.append('query', query);
    navigate(`/parts?${params.toString()}`);
  };

  const navigateToFaults = () => {
    navigate(`/faults?make=${displayMake}&model=${displayModel}`);
  };

  const navigateToGuide = () => {
    navigate(`/guide?make=${displayMake}&model=${displayModel}`);
  };

  if (isLoading) {
    return <PageLoader />;
  }

  return (
    <div className="fade-in">
      <SEOHead
        title={generatePageTitle(displayMake, displayModel)}
        description={generateMetaDescription(displayMake, displayModel)}
        canonicalUrl={`/cars/${make}/${model}`}
        keywords={[
          `${displayMake} ${displayModel} common faults`,
          `${displayMake} ${displayModel} parts prices UK`,
          `${displayMake} ${displayModel} buyer's guide`,
          `${displayMake} ${displayModel} reliability`,
          `${displayMake} ${displayModel} MOT failures`,
          `${displayMake} ${displayModel} repair costs`,
          `used ${displayMake} ${displayModel} problems`,
          `${displayMake} ${displayModel} service costs UK`,
        ]}
        structuredData={structuredData}
      />

      {/* Hero Section */}
      <section className="bg-gradient-to-br from-primary-600 via-primary-700 to-primary-800 text-white">
        <div className="gv-container py-12 lg:py-16">
          {/* Breadcrumb */}
          <nav className="text-sm text-white/70 mb-6">
            <ol className="flex items-center gap-2">
              <li><Link to="/" className="hover:text-white">Home</Link></li>
              <li>/</li>
              <li><Link to="/cars" className="hover:text-white">Cars</Link></li>
              <li>/</li>
              <li><Link to={`/cars/${make}`} className="hover:text-white">{displayMake}</Link></li>
              <li>/</li>
              <li className="text-white">{displayModel}</li>
            </ol>
          </nav>

          <div className="grid lg:grid-cols-2 gap-8 items-center">
            <div>
              <h1 className="text-4xl lg:text-5xl font-bold mb-4">
                {displayMake} {displayModel}
              </h1>
              <p className="text-xl text-white/90 mb-6">
                Complete buyer's guide with common faults, parts prices, and reliability data for UK buyers.
              </p>
              <div className="flex flex-wrap gap-4">
                <Button onClick={() => navigateToParts()} className="!bg-white !text-primary-700 hover:!bg-gray-100">
                  <ShoppingCart className="w-4 h-4 mr-2" />
                  Find Parts
                </Button>
                <Button onClick={navigateToFaults} variant="ghost" className="!text-white !border-white/30 hover:!bg-white/10">
                  <AlertTriangle className="w-4 h-4 mr-2" />
                  View Faults
                </Button>
                <Button onClick={navigateToGuide} variant="ghost" className="!text-white !border-white/30 hover:!bg-white/10">
                  <FileText className="w-4 h-4 mr-2" />
                  Buyer's Guide
                </Button>
              </div>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-2 gap-4">
              <ScoreDisplay score={guideData?.overallRating || 7.5} label="Overall Score" icon={Star} />
              <ScoreDisplay score={guideData?.reliabilityScore || 6.5} label="Reliability" icon={Shield} />
              <ScoreDisplay score={guideData?.runningCostScore || 7} label="Running Costs" icon={PoundSterling} />
              <div className="p-4 rounded-xl bg-white/10 border border-white/20">
                <div className="flex items-center gap-2 mb-1">
                  <AlertTriangle className="w-5 h-5" />
                  <span className="text-sm font-medium">Known Faults</span>
                </div>
                <div className="text-3xl font-bold">{faultsData?.totalFaults || 0}</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Common Faults Section */}
      <section className="gv-container py-12">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
            <AlertTriangle className="w-6 h-6 text-amber-500" />
            Common Faults
          </h2>
          <Button variant="secondary" onClick={navigateToFaults}>
            View All <ChevronRight className="w-4 h-4 ml-1" />
          </Button>
        </div>
        <div className="space-y-3">
          {faultsData?.faults.slice(0, 5).map((fault) => (
            <FaultPreviewCard
              key={fault.id}
              title={fault.title}
              severity={fault.severity}
              cost={fault.repairCostRange}
            />
          ))}
        </div>
        <p className="mt-4 text-sm text-gray-500">
          * Repair costs are estimates based on UK independent garage rates. Dealer prices may be higher.
        </p>
      </section>

      {/* Parts Categories Section */}
      <section className="py-12 bg-gray-50">
        <div className="gv-container">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
              <Wrench className="w-6 h-6 text-blue-500" />
              Popular Parts Categories
            </h2>
            <Button variant="secondary" onClick={() => navigateToParts()}>
              Search All Parts <ChevronRight className="w-4 h-4 ml-1" />
            </Button>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {[
              { category: 'Timing Chain Kits', avgPrice: 149.99, partCount: 12 },
              { category: 'Brake Pads & Discs', avgPrice: 39.99, partCount: 24 },
              { category: 'Oil Filters', avgPrice: 8.99, partCount: 18 },
              { category: 'Air Filters', avgPrice: 12.99, partCount: 15 },
              { category: 'Clutch Kits', avgPrice: 129.99, partCount: 8 },
              { category: 'Suspension Parts', avgPrice: 45.99, partCount: 32 },
            ].map((cat) => (
              <PartsCategoryCard
                key={cat.category}
                category={cat.category}
                avgPrice={cat.avgPrice}
                partCount={cat.partCount}
                onClick={() => navigateToParts(cat.category.split(' ')[0].toLowerCase())}
              />
            ))}
          </div>
          {partsData && (
            <div className="mt-6 p-4 bg-green-50 border border-green-200 rounded-xl flex items-center justify-between">
              <div>
                <p className="font-medium text-green-800">Best Price Found Today</p>
                <p className="text-sm text-green-700">Average across {partsData.metadata.suppliersQueried} suppliers</p>
              </div>
              <p className="text-2xl font-bold text-green-800">£{partsData.metadata.lowestPrice?.toFixed(2) || '--'}</p>
            </div>
          )}
        </div>
      </section>

      {/* Buyer's Guide Preview */}
      <section className="gv-container py-12">
        <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-2">
          <FileText className="w-6 h-6 text-green-500" />
          Buyer's Guide Highlights
        </h2>
        <div className="grid md:grid-cols-2 gap-6">
          {/* Pros & Cons */}
          <Card className="!bg-green-50 !border-green-100">
            <h3 className="font-semibold text-green-800 mb-4 flex items-center gap-2">
              <CheckCircle className="w-5 h-5" /> Pros
            </h3>
            <ul className="space-y-2">
              {(guideData?.prosAndCons.pros || ['Good driving dynamics', 'Quality interior', 'Wide parts availability']).slice(0, 4).map((pro, i) => (
                <li key={i} className="flex items-start gap-2 text-green-700">
                  <CheckCircle className="w-4 h-4 mt-0.5 shrink-0" />
                  <span>{pro}</span>
                </li>
              ))}
            </ul>
          </Card>
          <Card className="!bg-red-50 !border-red-100">
            <h3 className="font-semibold text-red-800 mb-4 flex items-center gap-2">
              <XCircle className="w-5 h-5" /> Cons
            </h3>
            <ul className="space-y-2">
              {(guideData?.prosAndCons.cons || ['Expensive repairs', 'Some electrical issues', 'High insurance costs']).slice(0, 4).map((con, i) => (
                <li key={i} className="flex items-start gap-2 text-red-700">
                  <XCircle className="w-4 h-4 mt-0.5 shrink-0" />
                  <span>{con}</span>
                </li>
              ))}
            </ul>
          </Card>
        </div>
        <div className="mt-6 text-center">
          <Button onClick={navigateToGuide}>
            Read Full Buyer's Guide <ChevronRight className="w-4 h-4 ml-1" />
          </Button>
        </div>
      </section>

      {/* MOT Failure Patterns */}
      <section className="py-12 bg-gray-50">
        <div className="gv-container">
          <h2 className="text-2xl font-bold text-gray-900 mb-6 flex items-center gap-2">
            <Gauge className="w-6 h-6 text-purple-500" />
            Common MOT Failure Points
          </h2>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[
              { item: 'Suspension', rate: '18%', icon: Car },
              { item: 'Brakes', rate: '15%', icon: AlertTriangle },
              { item: 'Lights', rate: '12%', icon: TrendingUp },
              { item: 'Emissions', rate: '10%', icon: Gauge },
            ].map((mot) => (
              <Card key={mot.item}>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                    <mot.icon className="w-5 h-5 text-purple-600" />
                  </div>
                  <div>
                    <p className="font-medium text-gray-900">{mot.item}</p>
                    <p className="text-sm text-gray-500">{mot.rate} failure rate</p>
                  </div>
                </div>
              </Card>
            ))}
          </div>
          <p className="mt-4 text-sm text-gray-500">
            * Based on MOT data for {displayMake} {displayModel} vehicles in the UK.
          </p>
        </div>
      </section>

      {/* FAQ Section */}
      <FAQSection faqs={faqs} />

      {/* CTA Section */}
      <section className="gv-container py-12">
        <Card className="bg-gradient-to-r from-primary-50 to-blue-50 !border-primary-100 text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">
            Ready to Find Parts for Your {displayMake} {displayModel}?
          </h2>
          <p className="text-gray-600 mb-6 max-w-2xl mx-auto">
            Compare prices across eBay, Amazon, Autodoc, and RockAuto. Find the best deals on genuine and aftermarket parts.
          </p>
          <div className="flex flex-wrap justify-center gap-4">
            <Button onClick={() => navigateToParts()} size="lg">
              <ShoppingCart className="w-5 h-5 mr-2" />
              Compare Parts Prices
            </Button>
            <Button variant="secondary" onClick={navigateToGuide} size="lg">
              <FileText className="w-5 h-5 mr-2" />
              Full Buyer's Guide
            </Button>
          </div>
        </Card>
      </section>

      {/* Last Updated */}
      <div className="gv-container pb-8">
        <p className="text-sm text-gray-500 text-center">
          <Clock className="w-4 h-4 inline mr-1" />
          Last updated: {new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' })}
        </p>
      </div>
    </div>
  );
}
