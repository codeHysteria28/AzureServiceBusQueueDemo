const express = require('express');
const app = express();
const str = require("@supercharge/strings");
const { ServiceBusClient } = require('@azure/service-bus');
const moment = require('moment');
const appInsights = require('applicationinsights');
require('dotenv').config();

// connection to Azure Service Bus and app insights
// !!! - needs to be specified in Azure Portal in App Service Configuration Settings -!!!
const conn_string = process.env.service_bus_conn_string;
const queue_name = process.env.service_bus_queue_name;
const app_insights_conn = process.env.instrument_app_insights;

appInsights.setup(app_insights_conn).start();

// send messages to the service bus queue
const sendMessage = async msg => {
    // create a Service Bus client using the connection string to the Service Bus namespace
	const sbClient = new ServiceBusClient(conn_string);

	// createSender() can also be used to create a sender for a topic.
	const sender = sbClient.createSender(queue_name);

    try {
		// Send the last created batch of messages to the queue
		await sender.sendMessages(msg);

		console.log(`Sent a message with ID: ${msg.body.id} to the queue: ${queue_name}`);

		// Close the sender
		await sender.close();
	} finally {
		await sbClient.close();
	}
}

// generate random messages function
const generateMessage = () => {
    // generate random message every 2 seconds
    setInterval(() => {
        // generate random number
        let randomNum = Math.floor(Math.random() * 1000);

        // generate random string
        let randomStr = str.random();

        // create new object which will contain string, number and timestamp
        let messageObj = {
            body: {
                id: randomNum.toString(),
                order: randomStr,
                timestamp: moment().format('MMMM Do YYYY, h:mm:ss a'),
            }
        }

        // call sendMessage function
        sendMessage(messageObj).catch((err) => {
            console.log("Error occurred: ", err);
            process.exit(1);
        });
    }, 2000);
}

// call generate messages function
generateMessage();

// app listening on given port
app.listen(process.env.PORT || 5000, () => console.log("Running on port " + process.env.PORT || 5000));