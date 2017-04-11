# Demo Instructions

This demo will show you how to send, receive and delete a message in a SQS queue

As the sample code includes the private key verbatim in the source, it should be treated carefully, and not checked into version control!

## Setting up a Queue in AWS SQS

1. Go to the sqs console  
1. Click "Create New Queue"
1. Enter in testQueue in the "Queue Name" section
1. Note your AWS region
1. Select "Standard Queue"
1. Click "Quick-Create Queue"
1. Note the URL of the SQS queue you are using.

## Configure the API keys for SQS

At the top of the sample.agent.nut there are three constants that need to be configured.

Parameter                   | Description
--------------------------- | -----------
AWS_TEST_REGION     		| AWS region (e.g. "us-west-2")
AWS_SQS_ACCESS_KEY_ID       | IAM Access Key ID
AWS_SQS_SECRET_ACCESS_KEY   | IAM Secret Access Key
AWS_SQS_URL					| Your SQS queue URL


The AWSSQS library is licensed under the [MIT License](../LICENSE).
