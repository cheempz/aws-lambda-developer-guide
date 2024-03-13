const AWSXRay = require('aws-xray-sdk-core')
const AWS = AWSXRay.captureAWS(require('aws-sdk'))

// Create client outside of handler to reuse
const lambda = new AWS.Lambda()
// unexpected usage, this creates an extra trace during cold start
lambda.getAccountSettings().promise()

// Handler
exports.handler = async function(event, context) {
  if (event.hasOwnProperty('Records')) {
    event.Records.forEach(record => {
      console.log(record.body)
    })
  }
  console.log('## ENVIRONMENT VARIABLES: ' + serialize(process.env))
  console.log('## CONTEXT: ' + serialize(context))
  console.log('## EVENT: ' + serialize(event))

  if (event.hasOwnProperty('sleepMs')) {
    let sleepMs = Number(event.sleepMs) || Math.floor(Math.random() * 3000);
    console.log('sleeping ' + sleepMs + ' milliseconds')
    await new Promise(resolve => setTimeout(resolve, sleepMs));
  }

  if (event.hasOwnProperty("exception")) {
    throw new Error("Booooom!")
  }

  return getAccountSettings()
}

// Use SDK client
var getAccountSettings = function(){
  return lambda.getAccountSettings().promise()
}

var serialize = function(object) {
  return JSON.stringify(object, null, 2)
}
