using System.Net;

using IntegrationTests.Clients;
using IntegrationTests.Configuration;

namespace IntegrationTests;

[TestClass]
public sealed class LogicAppWithCodeTests
{
    [TestMethod]
    public async Task ReverseEchoWorkflow_ValidText_200OkReturnedWithReversedText()
    {
        // Arrange
        var config = TestConfiguration.Load();

        using var sut = new LogicAppWorkflowClient(
            config.AzureTenantId,
            config.AzureSubscriptionId,
            config.AzureResourceGroup,
            config.AzureLogicAppWithCodeName,
            "reverse-echo-workflow"
        );

        var input = "Hello there!";

        // Act
        var response = await sut.PostAsync(input);

        // Assert
        Assert.AreEqual(HttpStatusCode.OK, response.StatusCode, "Unexpected status code returned");

        var expectedText = "!ereht olleH";
        var actualText = await response.Content.ReadAsStringAsync();
        Assert.AreEqual(expectedText, actualText, "Unexpected response content returned");
    }

}