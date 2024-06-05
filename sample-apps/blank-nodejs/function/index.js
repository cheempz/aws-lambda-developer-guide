const AWSXRay = require('aws-xray-sdk-core')
const AWS = AWSXRay.captureAWS(require('aws-sdk'))
const axios = require("axios")
const URL = require('node:url').URL

// Create client outside of handler to reuse
const lambda = new AWS.Lambda()
// unexpected usage, this creates an extra trace during cold start
lambda.getAccountSettings().promise()

// Handler
exports.handler = async function(event, context) {
  const response = {}

  if (event.hasOwnProperty('Records')) {
    event.Records.forEach(record => {
      console.log(record.body)
    })
  }
  console.log('## ENVIRONMENT VARIABLES: ' + serialize(process.env))
  console.log('## CONTEXT: ' + serialize(context))
  console.log('## EVENT: ' + serialize(event))

  if (event.hasOwnProperty('rpc')) {
    let url
    try {
        url = new URL(event.rpc)
    } catch (err) {
        url = 'https://postman-echo.com/headers'
    }
    try {
      response.rpc = (await axios.get(url)).data
    } catch (error) {
      console.log(error)
    }
  }

  if (event.hasOwnProperty('sleepMs')) {
    let sleepMs = Number(event.sleepMs) || Math.floor(Math.random() * 3000);
    console.log('sleeping ' + sleepMs + ' milliseconds')
    await new Promise(resolve => setTimeout(resolve, sleepMs))
  }

  if (event.hasOwnProperty("exception")) {
    throw new Error("Booooom!")
  }

  response.awsclient = await getAccountSettings()
  return {"statusCode": 200, "body": JSON.stringify(response)}
}

// Use SDK client
const getAccountSettings = async function(){
  return (await lambda.getAccountSettings().promise()).AccountUsage
}

const serialize = function(object) {
  return JSON.stringify(object, null, 2)
}