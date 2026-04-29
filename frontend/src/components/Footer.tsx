import { Link } from 'react-router-dom'
import { Mail, Phone, MapPin, Shield, Award, Clock } from 'lucide-react'
import { Logo } from './brand'

const footerLinks = {
  product: [
    { name: 'Find Parts', href: '/parts' },
    { name: 'Common Faults', href: '/faults' },
    { name: "Buyer's Guide", href: '/guide' },
    { name: 'Pricing', href: '/pricing' },
  ],
  company: [
    { name: 'About Us', href: '/about' },
    { name: 'Contact', href: '/contact' },
    { name: 'Careers', href: '/careers' },
    { name: 'Blog', href: '/blog' },
  ],
  legal: [
    { name: 'Privacy Policy', href: '/privacy' },
    { name: 'Terms of Service', href: '/terms' },
    { name: 'Cookie Policy', href: '/cookies' },
  ],
}

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-300">
      {/* Trust Indicators */}
      <div className="border-b border-gray-800">
        <div className="gv-container py-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="flex items-center gap-3">
              <Shield className="w-8 h-8 text-trust-green" />
              <div>
                <p className="font-semibold text-white">Data Protected</p>
                <p className="text-sm">SSL encrypted & GDPR compliant</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Award className="w-8 h-8 text-trust-green" />
              <div>
                <p className="font-semibold text-white">500K+ Predictions</p>
                <p className="text-sm">Trusted by UK car buyers</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Clock className="w-8 h-8 text-trust-green" />
              <div>
                <p className="font-semibold text-white">Real MOT Data</p>
                <p className="text-sm">Powered by official DVLA records</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Footer */}
      <div className="gv-container py-12">
        <div className="grid grid-cols-2 md:grid-cols-5 gap-8">
          {/* Brand */}
          <div className="col-span-2">
            <Link to="/" className="flex items-center gap-2 mb-4">
              <Logo size="md" className="[&_span]:text-white" />
            </Link>
            <p className="text-sm mb-6 max-w-xs">
              Helping UK car buyers make informed decisions with accurate repair cost predictions
              based on real MOT data and workshop analytics.
            </p>
            <div className="flex flex-col gap-2 text-sm">
              <a href="mailto:hello@carcheck.co.uk" className="flex items-center gap-2 hover:text-white">
                <Mail className="w-4 h-4" />
                hello@carcheck.co.uk
              </a>
              <a href="tel:+442079460958" className="flex items-center gap-2 hover:text-white">
                <Phone className="w-4 h-4" />
                020 7946 0958
              </a>
              <span className="flex items-center gap-2">
                <MapPin className="w-4 h-4" />
                London, United Kingdom
              </span>
            </div>
          </div>

          {/* Product Links */}
          <div>
            <h3 className="font-semibold text-white mb-4">Product</h3>
            <ul className="space-y-2">
              {footerLinks.product.map((link) => (
                <li key={link.name}>
                  <Link to={link.href} className="text-sm hover:text-white transition-colors">
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company Links */}
          <div>
            <h3 className="font-semibold text-white mb-4">Company</h3>
            <ul className="space-y-2">
              {footerLinks.company.map((link) => (
                <li key={link.name}>
                  <Link to={link.href} className="text-sm hover:text-white transition-colors">
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal Links */}
          <div>
            <h3 className="font-semibold text-white mb-4">Legal</h3>
            <ul className="space-y-2">
              {footerLinks.legal.map((link) => (
                <li key={link.name}>
                  <Link to={link.href} className="text-sm hover:text-white transition-colors">
                    {link.name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom */}
        <div className="mt-12 pt-8 border-t border-gray-800 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-sm">
            © {new Date().getFullYear()} CarCheck Ltd. All rights reserved.
          </p>
          <p className="text-sm text-gray-500">
            Made with ❤️ in the UK
          </p>
        </div>
      </div>
    </footer>
  )
}
