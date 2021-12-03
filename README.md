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

# Monitoring

For both Azure Function and App Service there's decicated Application Insights service to further monitor the usage of the services. Additional logs agents were installed into App Service environment.






# How to run this demo ?

First of all you need to clone this repo into your local machine. The you can procceed with ARM template and create the resources in your Azure Subscription. The deployment of the actual app can be done via the Visual Studio Code Azure extension or by Deployment center in App service (you need to fork this repo and setup connection with App Service).

Configure CosmoDB: 
1. Account Name: messagestorage
2. Database Name: messages
3. Container Name: messages1
4. Partion key: /id

Configure Azure Function:
1. Input binding: Service Bus queue
2. Output binging: CosmosDB

Configure KeyVault:
1. Create the service with Vault Access Policy setting
2. Then create app service and create identity and comeback here
3. Once indetity was created you can add new Access Policy directly only for this app with "GET | LIST" permissions
4. Create two secrets for Service Bus Queue Connection String and Queue Name

Configure App Service: 
1. Deploy code into environment either from Github or by VS code extension
2. Create system assigned identity (STATUS -> ON)
3. Once KeyVault is ready create reference for the SB queue connection string and Queue name in app configuration pane

# Example of Resource Group
![example](https://user-images.githubusercontent.com/46035047/144589324-002b9f6f-ec81-42a3-84c0-5061d85ef94f.png)

# Example of Azure Function
![fn](https://user-images.githubusercontent.com/46035047/144589965-9c952378-4e32-4b9f-82bf-cda9fa5c004b.png)

# Example of Scaling Rules
![scalling](https://user-images.githubusercontent.com/46035047/144590038-15007131-7c0c-40e7-91d6-787359728eb3.png)

# Example of CosmosDB stored documents
![db](https://user-images.githubusercontent.com/46035047/144590077-a7359ba3-95f4-48a4-a85c-533d22df0c40.png)
