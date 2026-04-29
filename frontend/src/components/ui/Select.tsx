import { forwardRef } from 'react'
import { ChevronDown } from 'lucide-react'
import clsx from 'clsx'

interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string
  error?: string
  options?: { value: string | number; label: string }[]
  placeholder?: string
  children?: React.ReactNode
}

const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ label, error, options, placeholder, className, id, children, ...props }, ref) => {
    const selectId = id || props.name

    return (
      <div className="w-full">
        {label && (
          <label htmlFor={selectId} className="block text-sm font-medium text-gray-700 mb-1">
            {label}
          </label>
        )}
        <div className="relative">
          <select
            ref={ref}
            id={selectId}
            className={clsx(
              'gv-select pr-10',
              error && 'border-red-500 focus:ring-red-500 focus:border-red-500',
              className
            )}
            {...props}
          >
            {placeholder && (
              <option value="">{placeholder}</option>
            )}
            {options ? options.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            )) : children}
          </select>
          <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400 pointer-events-none" />
        </div>
        {error && (
          <p className="mt-1 text-sm text-red-600">{error}</p>
        )}
      </div>
    )
  }
)

Select.displayName = 'Select'

export default Select
