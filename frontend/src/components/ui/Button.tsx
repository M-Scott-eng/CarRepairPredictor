import { forwardRef } from 'react'
import clsx from 'clsx'
import Spinner from './Spinner'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  icon?: React.ReactNode
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', loading, icon, children, className, disabled, ...props }, ref) => {
    const baseClasses = 'inline-flex items-center justify-center font-medium rounded-lg transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed'
    
    const variantClasses = {
      primary: 'bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500',
      secondary: 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-primary-500',
      ghost: 'bg-transparent text-gray-600 hover:bg-gray-100 focus:ring-gray-500',
      danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500',
    }
    
    const sizeClasses = {
      sm: 'px-3 py-1.5 text-sm',
      md: 'px-5 py-2.5 text-sm',
      lg: 'px-6 py-3 text-base',
    }

    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={clsx(
          baseClasses,
          variantClasses[variant],
          sizeClasses[size],
          className
        )}
        {...props}
      >
        {loading ? (
          <>
            <Spinner size="sm" className="mr-2" />
            Loading...
          </>
        ) : (
          <>
            {icon && <span className="mr-2">{icon}</span>}
            {children}
          </>
        )}
      </button>
    )
  }
)

Button.displayName = 'Button'

export default Button
