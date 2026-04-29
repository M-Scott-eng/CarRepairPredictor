using CarPredictor.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Stripe;

namespace CarPredictor.Api.Controllers;

/// <summary>
/// Webhook endpoint for Stripe events.
/// </summary>
[ApiController]
[Route("api/v1/webhooks")]
public class WebhooksController : ControllerBase
{
    private readonly IStripeService _stripeService;
    private readonly ILogger<WebhooksController> _logger;

    public WebhooksController(IStripeService stripeService, ILogger<WebhooksController> logger)
    {
        _stripeService = stripeService;
        _logger = logger;
    }

    /// <summary>
    /// Handles Stripe webhook events.
    /// </summary>
    [HttpPost("stripe")]
    public async Task<IActionResult> HandleStripeWebhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var signature = Request.Headers["Stripe-Signature"].FirstOrDefault();

        if (string.IsNullOrEmpty(signature))
        {
            _logger.LogWarning("Stripe webhook received without signature");
            return BadRequest("Missing Stripe-Signature header");
        }

        Event stripeEvent;
        try
        {
            stripeEvent = _stripeService.ConstructWebhookEvent(json, signature);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe webhook signature verification failed");
            return BadRequest("Invalid webhook signature");
        }

        _logger.LogInformation("Processing Stripe webhook: {EventType} ({EventId})", stripeEvent.Type, stripeEvent.Id);

        try
        {
            await ProcessEventAsync(stripeEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Stripe webhook {EventType}", stripeEvent.Type);
            // Return 200 to acknowledge receipt even if processing fails
            // This prevents Stripe from retrying and allows us to investigate
        }

        return Ok();
    }

    private async Task ProcessEventAsync(Event stripeEvent)
    {
        switch (stripeEvent.Type)
        {
            case "checkout.session.completed":
                await HandleCheckoutCompletedAsync(stripeEvent);
                break;

            case "customer.subscription.created":
                await HandleSubscriptionCreatedAsync(stripeEvent);
                break;

            case "customer.subscription.updated":
                await HandleSubscriptionUpdatedAsync(stripeEvent);
                break;

            case "customer.subscription.deleted":
                await HandleSubscriptionDeletedAsync(stripeEvent);
                break;

            case "invoice.paid":
                await HandleInvoicePaidAsync(stripeEvent);
                break;

            case "invoice.payment_failed":
                await HandlePaymentFailedAsync(stripeEvent);
                break;

            default:
                _logger.LogDebug("Unhandled Stripe event type: {EventType}", stripeEvent.Type);
                break;
        }
    }

    private Task HandleCheckoutCompletedAsync(Event stripeEvent)
    {
        var session = stripeEvent.Data.Object as Stripe.Checkout.Session;
        if (session is null) return Task.CompletedTask;

        _logger.LogInformation(
            "Checkout completed for customer {CustomerId}, subscription {SubscriptionId}",
            session.CustomerId, session.SubscriptionId);

        // TODO: Create user account if needed, associate subscription
        // This would typically:
        // 1. Look up or create user by email from session.CustomerEmail
        // 2. Store the Stripe customer ID and subscription ID
        // 3. Activate their subscription features

        return Task.CompletedTask;
    }

    private Task HandleSubscriptionCreatedAsync(Event stripeEvent)
    {
        var subscription = stripeEvent.Data.Object as Subscription;
        if (subscription is null) return Task.CompletedTask;

        _logger.LogInformation(
            "Subscription created: {SubscriptionId} for customer {CustomerId}, status: {Status}",
            subscription.Id, subscription.CustomerId, subscription.Status);

        // TODO: Update user's subscription status in database

        return Task.CompletedTask;
    }

    private Task HandleSubscriptionUpdatedAsync(Event stripeEvent)
    {
        var subscription = stripeEvent.Data.Object as Subscription;
        if (subscription is null) return Task.CompletedTask;

        _logger.LogInformation(
            "Subscription updated: {SubscriptionId}, status: {Status}, cancelAtPeriodEnd: {CancelAtPeriodEnd}",
            subscription.Id, subscription.Status, subscription.CancelAtPeriodEnd);

        // TODO: Update user's subscription status in database
        // Handle plan changes, cancellation scheduling, etc.

        return Task.CompletedTask;
    }

    private Task HandleSubscriptionDeletedAsync(Event stripeEvent)
    {
        var subscription = stripeEvent.Data.Object as Subscription;
        if (subscription is null) return Task.CompletedTask;

        _logger.LogInformation(
            "Subscription deleted: {SubscriptionId} for customer {CustomerId}",
            subscription.Id, subscription.CustomerId);

        // TODO: Downgrade user to free plan in database

        return Task.CompletedTask;
    }

    private Task HandleInvoicePaidAsync(Event stripeEvent)
    {
        var invoice = stripeEvent.Data.Object as Invoice;
        if (invoice is null) return Task.CompletedTask;

        _logger.LogInformation(
            "Invoice paid: {InvoiceId}, amount: {Amount} {Currency}",
            invoice.Id, invoice.AmountPaid / 100m, invoice.Currency.ToUpper());

        // TODO: Log payment in database, send receipt email

        return Task.CompletedTask;
    }

    private Task HandlePaymentFailedAsync(Event stripeEvent)
    {
        var invoice = stripeEvent.Data.Object as Invoice;
        if (invoice is null) return Task.CompletedTask;

        _logger.LogWarning(
            "Payment failed for invoice {InvoiceId}, customer {CustomerId}",
            invoice.Id, invoice.CustomerId);

        // TODO: Send payment failure notification email
        // Stripe will retry the payment automatically based on your settings

        return Task.CompletedTask;
    }
}
