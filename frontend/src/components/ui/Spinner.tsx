import clsx from 'clsx'

interface SpinnerProps {
  size?: 'sm' | 'md' | 'lg'
  className?: string
}

export default function Spinner({ size = 'md', className }: SpinnerProps) {
  const sizeClasses = {
    sm: 'w-4 h-4 border-2',
    md: 'w-8 h-8 border-4',
    lg: 'w-12 h-12 border-4',
  }

  return (
    <div
      className={clsx(
        'border-primary-200 border-t-primary-600 rounded-full animate-spin',
        sizeClasses[size],
        className
      )}
    />
  )
}

export function LoadingOverlay({ message = 'Loading...' }: { message?: string }) {
  return (
    <div className="fixed inset-0 bg-white/80 backdrop-blur-sm z-50 flex items-center justify-center">
      <div className="text-center">
        <Spinner size="lg" />
        <p className="mt-4 text-gray-600 font-medium">{message}</p>
      </div>
    </div>
  )
}

export function PageLoader() {
  return (
    <div className="min-h-[400px] flex items-center justify-center">
      <Spinner size="lg" />
    </div>
  )
}

export function SkeletonCard() {
  return (
    <div className="gv-card animate-pulse">
      <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
      <div className="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
      <div className="h-4 bg-gray-200 rounded w-2/3"></div>
    </div>
  )
}
