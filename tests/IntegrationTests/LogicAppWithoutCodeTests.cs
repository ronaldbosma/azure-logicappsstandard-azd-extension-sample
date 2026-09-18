using System.Net;

using IntegrationTests.Clients;
using IntegrationTests.Configuration;

namespace IntegrationTests;

[TestClass]
public sealed class LogicAppWithoutCodeTests
{
    [TestMethod]
    public async Task EchoWorkflow_ValidText_200OkReturnedWithText()
    {
        // Arrange
        var config = TestConfiguration.Load();

        using var sut = new LogicAppWorkflowClient(
            config.AzureTenantId,
            config.AzureSubscriptionId,
            config.AzureResourceGroup,
            config.AzureLogicAppWithoutCodeName,
            "echo-workflow"
        );

        var expectedText = "Hello there!";

        // Act
        var response = await sut.PostAsync(expectedText);

        // Assert
        Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "Unexpected status code returned");

        var actualText = await response.Content.ReadAsStringAsync();
        Assert.AreEqual(expectedText, actualText, "Unexpected response content returned");
    }

}