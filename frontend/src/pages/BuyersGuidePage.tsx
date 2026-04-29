import { useSearchParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  BookOpen,
  Car,
  ArrowLeft,
  CheckCircle,
  XCircle,
  AlertTriangle,
  Info,
  Star,
  Shield,
  PoundSterling,
  TrendingUp,
  ChevronRight,
  Wrench,
  ShoppingCart,
  Lightbulb,
} from 'lucide-react';
import { guidesApi } from '../services/api';
import Card from '../components/ui/Card';
import Button from '../components/ui/Button';
import { PageLoader } from '../components/ui/Spinner';

function ScoreCard({ label, score, icon: Icon }: { label: string; score: number; icon: React.ElementType }) {
  const getScoreColor = (s: number) => {
    if (s >= 8) return 'text-green-600 bg-green-50';
    if (s >= 6) return 'text-amber-600 bg-amber-50';
    return 'text-red-600 bg-red-50';
  };

  return (
    <div className="text-center">
      <div className={`w-16 h-16 rounded-full ${getScoreColor(score)} flex items-center justify-center mx-auto mb-2`}>
        <span className="text-2xl font-bold">{score.toFixed(1)}</span>
      </div>
      <div className="flex items-center justify-center gap-1 text-gray-600">
        <Icon className="w-4 h-4" />
        <span className="text-sm">{label}</span>
      </div>
    </div>
  );
}

function GuideSection({ section }: { section: { id: string; title: string; content: string; tips?: string[]; warnings?: string[] } }) {
  return (
    <Card className="mb-6">
      <h3 className="text-xl font-semibold text-gray-900 mb-4">{section.title}</h3>
      <p className="text-gray-600 mb-4">{section.content}</p>
      
      {section.tips && section.tips.length > 0 && (
        <div className="mb-4">
          <h4 className="text-sm font-medium text-green-700 mb-2 flex items-center gap-1">
            <Lightbulb className="w-4 h-4" />
            Tips
          </h4>
          <ul className="space-y-2">
            {section.tips.map((tip, index) => (
              <li key={index} className="flex items-start gap-2 text-sm text-gray-600">
                <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 shrink-0" />
                {tip}
              </li>
            ))}
          </ul>
        </div>
      )}

      {section.warnings && section.warnings.length > 0 && (
        <div className="bg-red-50 border border-red-100 rounded-lg p-4">
          <h4 className="text-sm font-medium text-red-700 mb-2 flex items-center gap-1">
            <AlertTriangle className="w-4 h-4" />
            Watch Out For
          </h4>
          <ul className="space-y-2">
            {section.warnings.map((warning, index) => (
              <li key={index} className="flex items-start gap-2 text-sm text-red-700">
                <XCircle className="w-4 h-4 mt-0.5 shrink-0" />
                {warning}
              </li>
            ))}
          </ul>
        </div>
      )}
    </Card>
  );
}

function ProsCons({ pros, cons }: { pros: string[]; cons: string[] }) {
  return (
    <div className="grid md:grid-cols-2 gap-6 mb-6">
      <Card className="!bg-green-50 !border-green-100">
        <h3 className="text-lg font-semibold text-green-800 mb-4 flex items-center gap-2">
          <CheckCircle className="w-5 h-5" />
          Pros
        </h3>
        <ul className="space-y-2">
          {pros.map((pro, index) => (
            <li key={index} className="flex items-start gap-2 text-green-700">
              <CheckCircle className="w-4 h-4 mt-0.5 shrink-0" />
              <span>{pro}</span>
            </li>
          ))}
        </ul>
      </Card>
      
      <Card className="!bg-red-50 !border-red-100">
        <h3 className="text-lg font-semibold text-red-800 mb-4 flex items-center gap-2">
          <XCircle className="w-5 h-5" />
          Cons
        </h3>
        <ul className="space-y-2">
          {cons.map((con, index) => (
            <li key={index} className="flex items-start gap-2 text-red-700">
              <XCircle className="w-4 h-4 mt-0.5 shrink-0" />
              <span>{con}</span>
            </li>
          ))}
        </ul>
      </Card>
    </div>
  );
}

export default function BuyersGuidePage() {
  const [searchParams] = useSearchParams();
  
  const make = searchParams.get('make') || '';
  const model = searchParams.get('model') || '';
  const year = searchParams.get('year') ? parseInt(searchParams.get('year')!) : undefined;

  const { data, isLoading, error } = useQuery({
    queryKey: ['guide', make, model, year],
    queryFn: () => guidesApi.getBuyersGuide(make, model, year),
    enabled: !!make && !!model,
  });

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
            Choose your car's make and model to view the buyer's guide.
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

  if (isLoading) {
    return <PageLoader />;
  }

  if (error || !data) {
    return (
      <div className="gv-container py-16">
        <Card className="max-w-lg mx-auto text-center">
          <AlertTriangle className="w-16 h-16 text-red-300 mx-auto mb-4" />
          <h2 className="text-xl font-semibold text-gray-900 mb-2">
            Failed to Load Guide
          </h2>
          <p className="text-gray-600 mb-6">
            We couldn't retrieve the buyer's guide. Please try again.
          </p>
          <Button onClick={() => window.location.reload()}>
            Try Again
          </Button>
        </Card>
      </div>
    );
  }

  return (
    <div className="fade-in">
      {/* Header */}
      <section className="bg-gradient-to-r from-green-600 to-emerald-600 text-white">
        <div className="gv-container py-12">
          <Link
            to="/"
            className="inline-flex items-center text-white/80 hover:text-white mb-4 transition-colors"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            Back to search
          </Link>
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center">
              <BookOpen className="w-6 h-6" />
            </div>
            <div>
              <h1 className="text-3xl font-bold">Buyer's Guide</h1>
              <p className="text-white/80">
                {make} {model} {year && `(${year})`}
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Scores */}
      <section className="bg-white border-b border-gray-200">
        <div className="gv-container py-8">
          <div className="grid grid-cols-3 gap-8 max-w-lg mx-auto">
            <ScoreCard label="Overall" score={data.overallRating} icon={Star} />
            <ScoreCard label="Reliability" score={data.reliabilityScore} icon={Shield} />
            <ScoreCard label="Running Costs" score={data.runningCostScore} icon={PoundSterling} />
          </div>
        </div>
      </section>

      {/* Content */}
      <section className="gv-container py-8">
        <div className="max-w-3xl mx-auto">
          {/* Guide Sections */}
          {data.sections.map((section) => (
            <GuideSection key={section.id} section={section} />
          ))}

          {/* Pros & Cons */}
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Pros & Cons</h2>
          <ProsCons pros={data.prosAndCons.pros} cons={data.prosAndCons.cons} />

          {/* Verdict */}
          <Card className="!bg-gradient-to-r !from-primary-50 !to-blue-50 !border-primary-100 mb-8">
            <h3 className="text-xl font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-primary-600" />
              Our Verdict
            </h3>
            <p className="text-gray-700 leading-relaxed">{data.verdictSummary}</p>
          </Card>

          {/* Navigation CTAs */}
          <div className="grid sm:grid-cols-2 gap-4">
            <Link to={`/faults?make=${make}&model=${model}${year ? `&year=${year}` : ''}`}>
              <Card hover className="h-full">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-amber-100 rounded-lg flex items-center justify-center">
                    <Wrench className="w-5 h-5 text-amber-600" />
                  </div>
                  <div className="flex-1">
                    <h4 className="font-semibold text-gray-900">View Common Faults</h4>
                    <p className="text-sm text-gray-500">See known issues for this model</p>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </Card>
            </Link>
            <Link to={`/parts?make=${make}&model=${model}${year ? `&year=${year}` : ''}`}>
              <Card hover className="h-full">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                    <ShoppingCart className="w-5 h-5 text-blue-600" />
                  </div>
                  <div className="flex-1">
                    <h4 className="font-semibold text-gray-900">Find Parts</h4>
                    <p className="text-sm text-gray-500">Compare prices across suppliers</p>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" />
                </div>
              </Card>
            </Link>
          </div>

          {/* Affiliate Disclaimer */}
          <div className="mt-8 p-4 bg-gray-50 rounded-lg border border-gray-200">
            <p className="text-xs text-gray-500 text-center">
              <Info className="w-3 h-3 inline mr-1" />
              Some links on this page are affiliate links. We may earn a small commission if you make a purchase through these links, at no extra cost to you. This helps support our free buyer's guides.
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
