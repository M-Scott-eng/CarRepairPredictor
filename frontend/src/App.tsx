import { Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import CarSelectorPage from './pages/CarSelectorPage'
import PartsFinderPage from './pages/PartsFinderPage'
import CommonFaultsPage from './pages/CommonFaultsPage'
import BuyersGuidePage from './pages/BuyersGuidePage'
import PricingPage from './pages/PricingPage'
import LoginPage from './pages/LoginPage'
import SignupPage from './pages/SignupPage'
import SubscriptionSuccessPage from './pages/SubscriptionSuccessPage'
import CarModelLandingPage from './pages/CarModelLandingPage'
import PredictPage from './pages/PredictPage'
import ResultsPage from './pages/ResultsPage'

function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<CarSelectorPage />} />
        <Route path="predict" element={<PredictPage />} />
        <Route path="results" element={<ResultsPage />} />
        <Route path="parts" element={<PartsFinderPage />} />
        <Route path="faults" element={<CommonFaultsPage />} />
        <Route path="guide" element={<BuyersGuidePage />} />
        <Route path="pricing" element={<PricingPage />} />
        <Route path="login" element={<LoginPage />} />
        <Route path="signup" element={<SignupPage />} />
        <Route path="subscription/success" element={<SubscriptionSuccessPage />} />
        <Route path="cars/:make/:model" element={<CarModelLandingPage />} />
        <Route path="cars/:make" element={<CarModelLandingPage />} />
        <Route path="cars" element={<CarModelLandingPage />} />
      </Route>
    </Routes>
  )
}

export default App
