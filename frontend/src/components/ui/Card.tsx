import clsx from 'clsx'

interface CardProps {
  children: React.ReactNode
  className?: string
  hover?: boolean
  onClick?: () => void
}

export default function Card({ children, className, hover, onClick }: CardProps) {
  return (
    <div
      className={clsx(
        'gv-card',
        hover && 'hover:shadow-md hover:border-gray-200 transition-all cursor-pointer',
        className
      )}
      onClick={onClick}
    >
      {children}
    </div>
  )
}

interface CardHeaderProps {
  title: string
  subtitle?: string
  icon?: React.ReactNode
  action?: React.ReactNode
}

export function CardHeader({ title, subtitle, icon, action }: CardHeaderProps) {
  return (
    <div className="flex items-start justify-between mb-4">
      <div className="flex items-start gap-3">
        {icon && (
          <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center text-primary-600">
            {icon}
          </div>
        )}
        <div>
          <h3 className="font-semibold text-gray-900">{title}</h3>
          {subtitle && <p className="text-sm text-gray-500">{subtitle}</p>}
        </div>
      </div>
      {action}
    </div>
  )
}
