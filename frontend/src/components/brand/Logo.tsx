import { Car, CheckCircle } from 'lucide-react';

interface LogoProps {
  size?: 'sm' | 'md' | 'lg';
  showText?: boolean;
  variant?: 'full' | 'icon';
  className?: string;
}

const sizes = {
  sm: { icon: 20, text: 'text-lg' },
  md: { icon: 28, text: 'text-xl' },
  lg: { icon: 36, text: 'text-2xl' },
};

/**
 * CarCheck brand logo component.
 */
export default function Logo({ 
  size = 'md', 
  showText = true, 
  variant = 'full',
  className = '' 
}: LogoProps) {
  const { icon, text } = sizes[size];

  if (variant === 'icon') {
    return (
      <div className={`relative inline-flex ${className}`}>
        <Car className="text-primary-600" size={icon} />
        <CheckCircle 
          className="absolute -top-1 -right-1 text-emerald-500 bg-white rounded-full" 
          size={icon * 0.5} 
        />
      </div>
    );
  }

  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <div className="relative">
        <Car className="text-primary-600" size={icon} />
        <CheckCircle 
          className="absolute -top-1 -right-2 text-emerald-500 bg-white rounded-full" 
          size={icon * 0.5} 
        />
      </div>
      {showText && (
        <span className={`font-bold text-gray-900 ${text}`}>
          Car<span className="text-primary-600">Check</span>
        </span>
      )}
    </div>
  );
}

/**
 * Inline text logo for headers and footers.
 */
export function LogoText({ className = '' }: { className?: string }) {
  return (
    <span className={`font-bold ${className}`}>
      Car<span className="text-primary-600">Check</span>
    </span>
  );
}

/**
 * Full brand lockup with tagline.
 */
export function LogoLockup({ className = '' }: { className?: string }) {
  return (
    <div className={`flex flex-col items-center ${className}`}>
      <Logo size="lg" />
      <p className="text-sm text-gray-500 mt-1">
        Predict Repair Costs Before You Buy
      </p>
    </div>
  );
}
