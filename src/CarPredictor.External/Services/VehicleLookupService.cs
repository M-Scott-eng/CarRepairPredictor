using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.RegularExpressions;
using CarPredictor.External.Configuration;
using CarPredictor.External.Models;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace CarPredictor.External.Services;

/// <summary>
/// Implementation of vehicle lookup using UK Government MOT and DVLA APIs.
/// </summary>
public sealed partial class VehicleLookupService : IVehicleLookupService
{
    private readonly HttpClient _motClient;
    private readonly HttpClient _dvlaClient;
    private readonly HttpClient _tokenClient;
    private readonly MotApiSettings _settings;
    private readonly ILogger<VehicleLookupService> _logger;
    
    // OAuth2 token cache
    private string? _cachedAccessToken;
    private DateTime _tokenExpiry = DateTime.MinValue;
    private readonly SemaphoreSlim _tokenLock = new(1, 1);

    public VehicleLookupService(
        IHttpClientFactory httpClientFactory,
        IOptions<MotApiSettings> settings,
        ILogger<VehicleLookupService> logger)
    {
        _motClient = httpClientFactory.CreateClient("MotHistory");
        _dvlaClient = httpClientFactory.CreateClient("DvlaVes");
        _tokenClient = httpClientFactory.CreateClient("OAuth2Token");
        _settings = settings.Value;
        _logger = logger;
    }

    public bool IsConfigured => 
        _settings.HasMotOAuth2Credentials || 
        !string.IsNullOrWhiteSpace(_settings.DvlaApiKey);

    public async Task<VehicleLookupResult> LookupByRegistrationAsync(
        string registration,
        CancellationToken cancellationToken = default)
    {
        var cleanReg = CleanRegistration(registration);
        
        if (string.IsNullOrWhiteSpace(cleanReg))
        {
            return new VehicleLookupResult
            {
                Registration = registration,
                IsValid = false,
                ErrorMessage = "Invalid registration number format"
            };
        }

        _logger.LogInformation("Looking up vehicle: {Registration}", cleanReg);

        // Return demo data if API keys not configured
        if (!IsConfigured)
        {
            _logger.LogInformation("API keys not configured, returning demo data for {Registration}", cleanReg);
            return GenerateDemoData(cleanReg);
        }

        try
        {
            // Fetch MOT history and DVLA data in parallel
            var motTask = GetMotHistoryAsync(cleanReg, cancellationToken);
            var dvlaTask = GetDvlaVehicleAsync(cleanReg, cancellationToken);
            
            await Task.WhenAll(motTask, dvlaTask);
            
            var motHistory = await motTask;
            var dvlaData = await dvlaTask;

            if (motHistory == null && dvlaData == null)
            {
                return new VehicleLookupResult
                {
                    Registration = cleanReg,
                    IsValid = false,
                    ErrorMessage = "Vehicle not found"
                };
            }

            return BuildCombinedResult(cleanReg, motHistory, dvlaData);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error looking up vehicle {Registration}", cleanReg);
            return new VehicleLookupResult
            {
                Registration = cleanReg,
                IsValid = false,
                ErrorMessage = "An error occurred while looking up the vehicle"
            };
        }
    }

    public async Task<MotHistoryResponse?> GetMotHistoryAsync(
        string registration,
        CancellationToken cancellationToken = default)
    {
        // Check if we have any credentials configured
        var hasOAuth2 = _settings.HasMotOAuth2Credentials;
        var hasApiKeyOnly = !string.IsNullOrWhiteSpace(_settings.MotHistoryApiKey);
        
        if (!hasOAuth2 && !hasApiKeyOnly)
        {
            _logger.LogDebug("MOT History API credentials not configured");
            return null;
        }

        var cleanReg = CleanRegistration(registration);
        
        try
        {
            var request = new HttpRequestMessage(
                HttpMethod.Get, 
                $"/trade/vehicles/mot-tests?registration={cleanReg}");
            
            // Use OAuth2 if configured, otherwise fall back to API key only (v6 style)
            if (hasOAuth2)
            {
                var accessToken = await GetAccessTokenAsync(cancellationToken);
                if (string.IsNullOrEmpty(accessToken))
                {
                    _logger.LogWarning("Failed to obtain OAuth2 access token for MOT History API");
                    return null;
                }
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            }
            
            // Always add API key header if available
            if (hasApiKeyOnly)
            {
                request.Headers.Add("x-api-key", _settings.MotHistoryApiKey);
            }
            
            var response = await _motClient.SendAsync(request, cancellationToken);
            
            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogWarning(
                    "MOT History API returned {StatusCode} for {Registration}: {Error}", 
                    response.StatusCode, 
                    cleanReg,
                    errorContent);
                return null;
            }

            var results = await response.Content.ReadFromJsonAsync<List<MotHistoryResponse>>(
                cancellationToken: cancellationToken);
            
            return results?.FirstOrDefault();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching MOT history for {Registration}", cleanReg);
            return null;
        }
    }
    
    /// <summary>
    /// Gets an OAuth2 access token using client credentials flow.
    /// Caches the token until near expiry.
    /// </summary>
    private async Task<string?> GetAccessTokenAsync(CancellationToken cancellationToken)
    {
        // Return cached token if still valid (with 60 second buffer)
        if (_cachedAccessToken != null && DateTime.UtcNow < _tokenExpiry.AddSeconds(-60))
        {
            return _cachedAccessToken;
        }
        
        await _tokenLock.WaitAsync(cancellationToken);
        try
        {
            // Double-check after acquiring lock
            if (_cachedAccessToken != null && DateTime.UtcNow < _tokenExpiry.AddSeconds(-60))
            {
                return _cachedAccessToken;
            }
            
            _logger.LogDebug("Requesting new OAuth2 access token for MOT History API");
            
            var tokenRequest = new HttpRequestMessage(HttpMethod.Post, _settings.TokenUrl);
            tokenRequest.Content = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["grant_type"] = "client_credentials",
                ["client_id"] = _settings.ClientId,
                ["client_secret"] = _settings.ClientSecret,
                ["scope"] = _settings.Scope
            });
            
            var response = await _tokenClient.SendAsync(tokenRequest, cancellationToken);
            
            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogError("Failed to obtain OAuth2 token: {StatusCode} - {Error}", 
                    response.StatusCode, errorContent);
                return null;
            }
            
            var tokenResponse = await response.Content.ReadFromJsonAsync<OAuth2TokenResponse>(
                cancellationToken: cancellationToken);
            
            if (tokenResponse == null || string.IsNullOrEmpty(tokenResponse.AccessToken))
            {
                _logger.LogError("OAuth2 token response was empty or invalid");
                return null;
            }
            
            _cachedAccessToken = tokenResponse.AccessToken;
            _tokenExpiry = DateTime.UtcNow.AddSeconds(tokenResponse.ExpiresIn);
            
            _logger.LogDebug("Successfully obtained OAuth2 access token, expires in {ExpiresIn} seconds", 
                tokenResponse.ExpiresIn);
            
            return _cachedAccessToken;
        }
        finally
        {
            _tokenLock.Release();
        }
    }

    public async Task<DvlaVehicleResponse?> GetDvlaVehicleAsync(
        string registration,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_settings.DvlaApiKey))
        {
            _logger.LogDebug("DVLA API key not configured");
            return null;
        }

        var cleanReg = CleanRegistration(registration);
        
        try
        {
            var request = new HttpRequestMessage(HttpMethod.Post, "/vehicle-enquiry/v1/vehicles");
            request.Headers.Add("x-api-key", _settings.DvlaApiKey);
            request.Content = JsonContent.Create(new { registrationNumber = cleanReg });
            
            var response = await _dvlaClient.SendAsync(request, cancellationToken);
            
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning(
                    "DVLA API returned {StatusCode} for {Registration}", 
                    response.StatusCode, 
                    cleanReg);
                return null;
            }

            return await response.Content.ReadFromJsonAsync<DvlaVehicleResponse>(
                cancellationToken: cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching DVLA data for {Registration}", cleanReg);
            return null;
        }
    }

    private VehicleLookupResult BuildCombinedResult(
        string registration,
        MotHistoryResponse? motHistory,
        DvlaVehicleResponse? dvlaData)
    {
        var motTestSummaries = motHistory?.MotTests
            .Select(t => new MotTestSummary
            {
                TestDate = DateTime.TryParse(t.CompletedDate, out var date) ? date : DateTime.MinValue,
                Passed = t.TestResult?.Equals("PASSED", StringComparison.OrdinalIgnoreCase) == true,
                Mileage = int.TryParse(t.OdometerValue, out var m) ? m : null,
                DefectCount = t.Defects?.Count(d => d.Type != "ADVISORY") ?? 0,
                AdvisoryCount = t.Defects?.Count(d => d.Type == "ADVISORY") ?? 0,
                Defects = t.Defects?.Where(d => d.Type != "ADVISORY").Select(d => d.Text).ToList() ?? [],
                Advisories = t.Defects?.Where(d => d.Type == "ADVISORY").Select(d => d.Text).ToList() ?? []
            })
            .OrderByDescending(t => t.TestDate)
            .ToList() ?? [];

        var latestTest = motTestSummaries.FirstOrDefault();
        
        var recentDefects = motTestSummaries
            .Take(3)
            .SelectMany(t => t.Defects.Concat(t.Advisories))
            .Distinct()
            .Take(10)
            .ToList();

        return new VehicleLookupResult
        {
            Registration = registration,
            Make = dvlaData?.Make ?? motHistory?.Make ?? "Unknown",
            Model = motHistory?.Model ?? "Unknown",
            Year = dvlaData?.YearOfManufacture ?? ParseYear(motHistory?.ManufactureDate),
            FuelType = dvlaData?.FuelType ?? motHistory?.FuelType,
            Colour = dvlaData?.Colour ?? motHistory?.PrimaryColour,
            EngineSize = dvlaData?.EngineCapacity ?? ParseEngineSize(motHistory?.EngineSize),
            TaxStatus = dvlaData?.TaxStatus,
            MotStatus = dvlaData?.MotStatus,
            MotExpiryDate = dvlaData?.MotExpiryDate,
            CurrentMileage = latestTest?.Mileage,
            MotHistory = motTestSummaries,
            RecentDefects = recentDefects,
            IsValid = true
        };
    }

    private static string CleanRegistration(string registration)
    {
        if (string.IsNullOrWhiteSpace(registration))
            return string.Empty;
            
        // Remove spaces and convert to uppercase
        return RegistrationCleanupRegex().Replace(registration.ToUpperInvariant(), "");
    }

    private static int? ParseYear(string? dateString)
    {
        if (string.IsNullOrWhiteSpace(dateString))
            return null;
            
        if (DateTime.TryParse(dateString, out var date))
            return date.Year;
            
        return null;
    }

    private static int? ParseEngineSize(string? engineSize)
    {
        if (string.IsNullOrWhiteSpace(engineSize))
            return null;
            
        if (int.TryParse(engineSize, out var size))
            return size;
            
        return null;
    }

    /// <summary>
    /// Generates realistic demo data based on the registration format.
    /// Uses a hash of the registration to produce consistent results for the same plate.
    /// </summary>
    private static VehicleLookupResult GenerateDemoData(string registration)
    {
        // Use registration hash for consistent demo data
        var hash = registration.GetHashCode();
        var random = new Random(hash);

        // Demo vehicle pool - popular UK cars that match our database
        var demoVehicles = new[]
        {
            ("BMW", "3 Series", 2019, 1998, "Diesel"),
            ("BMW", "3 Series", 2017, 1998, "Petrol"),
            ("BMW", "5 Series", 2020, 2993, "Diesel"),
            ("Volkswagen", "Golf", 2018, 1968, "Diesel"),
            ("Volkswagen", "Golf", 2021, 1498, "Petrol"),
            ("Volkswagen", "Polo", 2019, 999, "Petrol"),
            ("Ford", "Focus", 2018, 1499, "Petrol"),
            ("Ford", "Fiesta", 2020, 999, "Petrol"),
            ("Ford", "Kuga", 2019, 1999, "Diesel"),
            ("Audi", "A3", 2019, 1498, "Petrol"),
            ("Audi", "A4", 2018, 1968, "Diesel"),
            ("Mercedes-Benz", "C-Class", 2020, 1991, "Petrol"),
            ("Toyota", "Yaris", 2021, 1490, "Hybrid"),
            ("Honda", "Civic", 2019, 1498, "Petrol"),
            ("Vauxhall", "Corsa", 2020, 1199, "Petrol"),
            ("Vauxhall", "Astra", 2018, 1598, "Diesel"),
            ("Nissan", "Qashqai", 2019, 1598, "Diesel"),
            ("Hyundai", "i30", 2020, 1353, "Petrol"),
            ("Kia", "Sportage", 2019, 1685, "Diesel"),
            ("Peugeot", "208", 2021, 1199, "Petrol"),
        };

        var vehicle = demoVehicles[Math.Abs(hash) % demoVehicles.Length];
        var colours = new[] { "Black", "White", "Silver", "Blue", "Red", "Grey" };
        var colour = colours[Math.Abs(hash / 10) % colours.Length];

        // Generate realistic mileage based on age
        var currentYear = DateTime.Now.Year;
        var age = currentYear - vehicle.Item3;
        var baseMileage = age * 10000 + random.Next(-2000, 5000);
        var currentMileage = Math.Max(5000, baseMileage);

        // Generate MOT history
        var motHistory = GenerateDemoMotHistory(vehicle.Item3, currentMileage, random);
        
        // Common advisories from MOT tests
        var recentDefects = new List<string>();
        if (motHistory.Count > 0 && motHistory[0].Advisories.Count > 0)
        {
            recentDefects.AddRange(motHistory[0].Advisories.Take(3));
        }

        // MOT expiry - either valid or about to expire
        var motExpiryDate = DateTime.Now.AddMonths(random.Next(1, 11)).ToString("yyyy-MM-dd");
        var taxStatus = random.Next(10) > 1 ? "Taxed" : "SORN";

        return new VehicleLookupResult
        {
            Registration = registration,
            Make = vehicle.Item1,
            Model = vehicle.Item2,
            Year = vehicle.Item3,
            FuelType = vehicle.Item5,
            Colour = colour,
            EngineSize = vehicle.Item4,
            TaxStatus = taxStatus,
            MotStatus = "Valid",
            MotExpiryDate = motExpiryDate,
            CurrentMileage = currentMileage,
            MotHistory = motHistory,
            RecentDefects = recentDefects,
            IsValid = true,
            IsDemo = true
        };
    }

    private static List<MotTestSummary> GenerateDemoMotHistory(int vehicleYear, int currentMileage, Random random)
    {
        var history = new List<MotTestSummary>();
        var currentYear = DateTime.Now.Year;
        
        // First MOT at 3 years old
        var firstMotYear = vehicleYear + 3;
        if (firstMotYear > currentYear) return history;

        var mileage = currentMileage;
        var yearlyMileage = currentMileage / Math.Max(1, currentYear - vehicleYear);

        for (var year = currentYear; year >= firstMotYear; year--)
        {
            var passed = random.Next(10) > 1; // 90% pass rate
            var advisoryCount = random.Next(0, 4);
            var defectCount = passed ? 0 : random.Next(1, 3);

            var advisories = GenerateRandomAdvisories(advisoryCount, random);
            var defects = passed ? new List<string>() : GenerateRandomDefects(defectCount, random);

            history.Add(new MotTestSummary
            {
                TestDate = new DateTime(year, random.Next(1, 13), random.Next(1, 28)),
                Passed = passed,
                Mileage = mileage,
                AdvisoryCount = advisoryCount,
                DefectCount = defectCount,
                Advisories = advisories,
                Defects = defects
            });

            mileage = Math.Max(1000, mileage - yearlyMileage + random.Next(-1000, 1000));
        }

        return history.OrderByDescending(m => m.TestDate).ToList();
    }

    private static List<string> GenerateRandomAdvisories(int count, Random random)
    {
        var allAdvisories = new[]
        {
            "Front brake disc worn close to legal limit",
            "Rear brake disc worn close to legal limit",
            "Tyre worn close to legal limit (front nearside)",
            "Tyre worn close to legal limit (front offside)",
            "Oil leak, not excessive",
            "Front suspension arm ball joint dust cover deteriorated",
            "Windscreen washer provides insufficient water",
            "Registration plate lamp slightly obscured",
            "Headlamp lens slightly deteriorated",
            "Exhaust has minor leak of exhaust gases",
            "Parking brake efficiency below requirements",
            "Front anti-roll bar linkage has slight play",
            "Rear shock absorber has light misting of oil",
            "Front coil spring corroded",
            "Boot lid catch worn but secure"
        };

        return allAdvisories.OrderBy(_ => random.Next()).Take(count).ToList();
    }

    private static List<string> GenerateRandomDefects(int count, Random random)
    {
        var allDefects = new[]
        {
            "Headlamp aim too high (offside)",
            "Stop lamp not working (nearside rear)",
            "Front position lamp not working",
            "Horn not working",
            "Tyre tread depth below requirements",
            "Windscreen wiper does not clear windscreen effectively",
            "Exhaust emissions exceed requirements"
        };

        return allDefects.OrderBy(_ => random.Next()).Take(count).ToList();
    }

    [GeneratedRegex("[^A-Z0-9]")]
    private static partial Regex RegistrationCleanupRegex();
}