import { loadStripe, Stripe } from '@stripe/stripe-js';

let stripePromise: Promise<Stripe | null>;

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:5000';

interface StripeConfig {
  publishableKey: string;
  prices: {
    basicMonthly: string;
    basicAnnual: string;
    premiumMonthly: string;
    premiumAnnual: string;
  };
}

interface CheckoutResponse {
  sessionId: string;
  url: string;
}

interface SubscriptionStatus {
  isActive: boolean;
  plan: string;
  status: string;
  subscriptionId?: string;
  customerId?: string;
  currentPeriodEnd?: string;
  cancelAtPeriodEnd: boolean;
}

/**
 * Fetches Stripe configuration from the API.
 */
export async function getStripeConfig(): Promise<StripeConfig> {
  const response = await fetch(`${API_BASE}/api/v1/subscription/config`);
  if (!response.ok) {
    throw new Error('Failed to fetch Stripe configuration');
  }
  return response.json();
}

/**
 * Gets or creates a Stripe instance.
 */
export async function getStripe(): Promise<Stripe | null> {
  if (!stripePromise) {
    const config = await getStripeConfig();
    stripePromise = loadStripe(config.publishableKey);
  }
  return stripePromise;
}

/**
 * Creates a Stripe Checkout session and redirects to it.
 */
export async function redirectToCheckout(
  email: string,
  plan: 'basic' | 'premium',
  annual: boolean = false
): Promise<void> {
  const response = await fetch(`${API_BASE}/api/v1/subscription/checkout`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email,
      plan,
      annual,
      successUrl: `${window.location.origin}/subscription/success?session_id={CHECKOUT_SESSION_ID}`,
      cancelUrl: `${window.location.origin}/pricing`,
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to create checkout session');
  }

  const data: CheckoutResponse = await response.json();
  
  // Redirect to Stripe Checkout
  window.location.href = data.url;
}

/**
 * Creates a customer portal session for subscription management.
 */
export async function redirectToCustomerPortal(email: string): Promise<void> {
  const response = await fetch(`${API_BASE}/api/v1/subscription/portal`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email,
      returnUrl: `${window.location.origin}/account`,
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to create portal session');
  }

  const data = await response.json();
  window.location.href = data.url;
}

/**
 * Gets the subscription status for an email address.
 */
export async function getSubscriptionStatus(email: string): Promise<SubscriptionStatus> {
  const response = await fetch(
    `${API_BASE}/api/v1/subscription/status?email=${encodeURIComponent(email)}`
  );

  if (!response.ok) {
    throw new Error('Failed to fetch subscription status');
  }

  return response.json();
}

/**
 * Cancels a subscription.
 */
export async function cancelSubscription(subscriptionId: string): Promise<void> {
  const response = await fetch(`${API_BASE}/api/v1/subscription/cancel`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ subscriptionId }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to cancel subscription');
  }
}
