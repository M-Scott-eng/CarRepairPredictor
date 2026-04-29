import { useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Menu, X, ShoppingCart, Wrench, BookOpen } from 'lucide-react'
import clsx from 'clsx'
import { Logo } from './brand'

const navigation = [
  { name: 'Home', href: '/' },
  { name: 'Find Parts', href: '/parts', icon: ShoppingCart },
  { name: 'Common Faults', href: '/faults', icon: Wrench },
  { name: "Buyer's Guide", href: '/guide', icon: BookOpen },
]

export default function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const location = useLocation()

  return (
    <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-sm border-b border-gray-100">
      <nav className="gv-container" aria-label="Global">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2">
            <Logo size="md" showText={true} />
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-6">
            {navigation.map((item) => (
              <Link
                key={item.name}
                to={item.href}
                className={clsx(
                  'font-medium transition-colors flex items-center gap-1.5',
                  location.pathname === item.href || (item.href !== '/' && location.pathname.startsWith(item.href))
                    ? 'text-primary-600'
                    : 'text-gray-600 hover:text-gray-900'
                )}
              >
                {item.icon && <item.icon className="w-4 h-4" />}
                {item.name}
              </Link>
            ))}
          </div>

          {/* Desktop Auth Buttons */}
          <div className="hidden md:flex items-center gap-4">
            <Link
              to="/login"
              className="font-medium text-gray-600 hover:text-gray-900 transition-colors"
            >
              Log in
            </Link>
            <Link to="/signup" className="gv-btn-primary">
              Get Started
            </Link>
          </div>

          {/* Mobile menu button */}
          <button
            type="button"
            className="md:hidden p-2 text-gray-600"
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          >
            {mobileMenuOpen ? (
              <X className="w-6 h-6" />
            ) : (
              <Menu className="w-6 h-6" />
            )}
          </button>
        </div>

        {/* Mobile Navigation */}
        {mobileMenuOpen && (
          <div className="md:hidden py-4 border-t border-gray-100 animate-fade-in">
            <div className="flex flex-col gap-4">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  to={item.href}
                  className={clsx(
                    'font-medium py-2 flex items-center gap-2',
                    location.pathname === item.href || (item.href !== '/' && location.pathname.startsWith(item.href))
                      ? 'text-primary-600'
                      : 'text-gray-600'
                  )}
                  onClick={() => setMobileMenuOpen(false)}
                >
                  {item.icon && <item.icon className="w-4 h-4" />}
                  {item.name}
                </Link>
              ))}
              <div className="flex flex-col gap-2 pt-4 border-t border-gray-100">
                <Link
                  to="/login"
                  className="gv-btn-secondary justify-center"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  Log in
                </Link>
                <Link
                  to="/signup"
                  className="gv-btn-primary justify-center"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  Get Started
                </Link>
              </div>
            </div>
          </div>
        )}
      </nav>
    </header>
  )
}
