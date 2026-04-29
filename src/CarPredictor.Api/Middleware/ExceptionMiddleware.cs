using System.Net;
using System.Text.Json;
using CarPredictor.Api.DTOs.Responses;

namespace CarPredictor.Api.Middleware;

/// <summary>
/// Global exception handling middleware.
/// </summary>
public sealed class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;
    private readonly IHostEnvironment _environment;

    public ExceptionMiddleware(
        RequestDelegate next,
        ILogger<ExceptionMiddleware> logger,
        IHostEnvironment environment)
    {
        _next = next;
        _logger = logger;
        _environment = environment;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var traceId = context.TraceIdentifier;
        
        _logger.LogError(exception, "Unhandled exception. TraceId: {TraceId}", traceId);

        var (statusCode, errorCode, message) = exception switch
        {
            ArgumentNullException argNull => (HttpStatusCode.BadRequest, "ArgumentNull", $"Required parameter '{argNull.ParamName}' was not provided"),
            ArgumentException arg => (HttpStatusCode.BadRequest, "InvalidArgument", arg.Message),
            InvalidOperationException inv => (HttpStatusCode.BadRequest, "InvalidOperation", inv.Message),
            KeyNotFoundException => (HttpStatusCode.NotFound, "NotFound", "The requested resource was not found"),
            UnauthorizedAccessException => (HttpStatusCode.Unauthorized, "Unauthorized", "You are not authorized to perform this action"),
            _ => (HttpStatusCode.InternalServerError, "InternalError", "An unexpected error occurred")
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        var response = new ErrorResponseDto
        {
            Error = errorCode,
            Message = message,
            Detail = _environment.IsDevelopment() ? exception.ToString() : null,
            TraceId = traceId
        };

        var jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };

        await context.Response.WriteAsync(JsonSerializer.Serialize(response, jsonOptions));
    }
}

/// <summary>
/// Extension method to register exception middleware.
/// </summary>
public static class ExceptionMiddlewareExtensions
{
    public static IApplicationBuilder UseExceptionMiddleware(this IApplicationBuilder app)
    {
        return app.UseMiddleware<ExceptionMiddleware>();
    }
}