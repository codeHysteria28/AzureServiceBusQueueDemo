# Azure ServiceBus Queue Demo





# GUIDE

The actual demo is related to Azure Service Bus Queue:

What I've used ? 

1. Azure App Service -> NodeJS; Express based backend which will generate random messages and send them to Service Bus Queue
2. Azure Service Bus Queue to store and distribute the messages
3. Azure Function to unload the Service Bus queue and store them in the Azure CosmosDB
4. Azure Keyvault to store app secrets 



# Details regarding the architecture

The app itself is generating random messages every two seconds in following format:

`const exampleMessage = { body: { id: randomNumber, order: randomString, timestamp: current date and time }}`

Then we will pass this created message object to the function that is sending the messages as parameter for later use. After the message is sent it initiate connection with service bus and try to send the message. Once message is received it is stored in Azure Service Bus Queue. There is also a consumption tier Azure Function which is unloading the Service Bus queue and saving/storing this messages in CosmosDB (serverless tier) for eg. later use.

# Security

I'm using Azure KeyVault to store app secrets. In terms of Access Policies I'm using "Vault Access policy" in terms of permission model. The App service is using managed system generated identity to be able to retrieve secrets/keys from KeyVault -> Permissions only apply to "GET | LIST" for both keys and secrets as we're following the least privilege principle. Then we're linking the secrets from KeyVault to the App Service Configuration Settings. Only this app is able to access those secrets!

# Autoscaling of App Service

In the traffic spikes I've set up the Autoscaling condition directly in App Service Plan (S1 plan).
1. If the average cpu % is higher then 70% for 5 mins it will scale out another instance (default: 1, min: 1, max: 2, 7days/week)
2. If the average cpu % is lower then 70% for 5 mins it will scale back to only one instance
