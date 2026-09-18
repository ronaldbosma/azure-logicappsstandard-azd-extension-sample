using Microsoft.Extensions.Configuration;

namespace IntegrationTests.Configuration;

/// <summary>
/// Contains configuration settings for the integration tests.
/// </summary>
internal class TestConfiguration
{
    private static readonly Lazy<TestConfiguration> _instance = new(() =>
    {
        AzdDotEnv.Load(optional: true); // Loads Azure Developer CLI environment variables; optional since .env file might be missing in CI/CD pipelines

        var configuration = new ConfigurationBuilder()
            .AddEnvironmentVariables()
            .Build();

        return new TestConfiguration
        {
            AzureTenantId = configuration.GetRequiredString("AZURE_TENANT_ID"),
            AzureSubscriptionId = configuration.GetRequiredString("AZURE_SUBSCRIPTION_ID"),
            AzureResourceGroup = configuration.GetRequiredString("AZURE_RESOURCE_GROUP"),
            AzureLogicAppWithoutCodeName = configuration.GetRequiredString("AZURE_LOGIC_APP_WITHOUT_CODE_NAME"),
            AzureLogicAppWithCodeName = configuration.GetRequiredString("AZURE_LOGIC_APP_WITH_CODE_NAME")
        };
    });

    public required string AzureTenantId { get; init; }
    public required string AzureSubscriptionId { get; init; }
    public required string AzureResourceGroup { get; init; }
    public required string AzureLogicAppWithoutCodeName { get; init; }
    public required string AzureLogicAppWithCodeName { get; init; }

    public static TestConfiguration Load() => _instance.Value;
}