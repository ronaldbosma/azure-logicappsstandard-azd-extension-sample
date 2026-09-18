# Demo

In this demo scenario, we will demonstrate the use of the azure.logicappsstandard azd extension.
This template deploys two Logic Apps: one is a basic Logic App; the other has a custom code project using .NET 8.

## 1. What resources will be deployed

The following resources will be deployed:

![Deployed Resources](/images/deployed-resources.png)

The deployed resources follow the naming convention: `<resource-type>-<environment-name>-<region>-<instance>`.

## 2. What can I demonstrate after deployment

### Install and use the extension

Follow the steps in the [Getting Started](/README.md#getting-started) section of the README to install the azure.logicappsstandard extension.

Then review the [azure.yaml](/azure.yaml) to show how the extension can be used:

1. The `logicAppWithoutCode` service shows the configuration for a basic Logic App with only workflows, no custom code or other artifacts.
1. The `logicAppWithCode` service shows the configuration for a Logic App with a custom code project (.NET 8).

Run `azd package <service>` to package the services and review the contents of the generated `.zip` file.

### Test the workflows

Each Logic App includes a test workflow with an HTTP request trigger that can be used to verify whether the deployment was successful.
The following sections describe how to test the workflows manually or by using the automated integration tests.

#### Manual test

Follow these steps to manually test a workflow:

1. Navigate to the **Workflows** tab of the Logic App you want to test.
1. Open the workflow.
1. Review the implementation of the workflow.
1. Select **Run with payload** in the designer view.
1. Specify `text/plain` as the value for the `Content-Type` header.
1. Enter text in the **Body** input field.
1. Select **Run**.
1. The workflow should return a `200 OK` response with a response body.

#### Automated testing with .NET integration tests

The repository includes a set of .NET [integration tests](/tests/IntegrationTests) that can be used to automatically validate the workflows in the different Logic Apps.

**Prerequisites:** The tests use your local azd environment variables from `.azure/<environment-name>/.env` to connect to the deployed resources. Ensure that your azd environment is set to the correct deployment before running the tests.

To run the integration tests from the command line, follow these steps:

1. Open a terminal and navigate to the `tests/IntegrationTests` folder in the repository.
1. Run the following command to execute the tests:

   ```
   dotnet run
   ```

When executing the tests from an IDE such as Visual Studio, you can view the request and response details in the test output window.
