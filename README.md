# Azure ServiceBus Queue Demo





# GUIDE

The actual demo is related to Azure Service Bus Queue:

What I've used ? 

1. Azure App Service -> NodeJS; Express based backend which will generate random messages and send them to Service Bus Queue
2. Azure Service Bus Queue to store and distribute the messages
3. (optional) Azure Function with Service Bus trigger binding to demonstrate 1:1 relationship as sender -> receiver, can be turned by defining parameter when deploying the bicep file eg. `az deployment group create --parameters deployFnSubStorAcc=true --template-file main.bicep`



# Details regarding the architecture

The app itself is generating random messages every two seconds in following format:

`const exampleMessage = { body: { id: randomNumber, order: randomString, timestamp: current date and time }}`

Then we will pass this created message object to the function that is sending the messages as parameter for later use. After the message is sent it initiate connection with service bus and try to send the message. Once message is received it is stored in Azure Service Bus Queue. 
