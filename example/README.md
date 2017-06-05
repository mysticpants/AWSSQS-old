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


## Setting up AIM Policy

1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select `IAM Manage User Access and Encryption Keys` item
1. Select `Policies` item from the menu on the left
1. Press `Create Policy` button
1. Press `Select` for `Policy Generator`
1. On the `Edit Permissions` page do the following
    1. Set `Effect` to `Allow`
    1. Set `AWS Service` to `Amazon SQS`
    1. Set `Actions` to `All Actions`
    1. Leave `Amazon Resource Name (ARN)` blank
    1. Press `Add Statement`
    1. Press `Next Step`
1. Give your policy a name, for example, `allow-sqs` and type in into the `Policy Name` field
1. Press `Create Policy`

## Setting up the AIM User

1. Select `Services` link (on the top left of the page) and them type `IAM` in the search line
1. Select the `IAM Manage User Access and Encryption Keys` item
1. Select `Users` item from the menu on the left
1. Press `Add user`
1. Choose a user name, for example `user-calling-sqs`
1. Check `Programmatic access` but not anything else
1. Press `Next: Permissions` button
1. Press `Attach existing policies directly` icon
1. Check `allow-sqs` from the list of policies
1. Press `Next: Review`
1. Press `Create user`
1. Copy down your `Access key ID` and `Secret access key`

API keys for SQS

At the top of the sample.agent.nut there are three constants that need to be configured.

Parameter                   | Description
--------------------------- | -----------
AWS_TEST_REGION     		| AWS region (e.g. "us-west-2")
AWS_SQS_ACCESS_KEY_ID       | IAM Access Key ID
AWS_SQS_SECRET_ACCESS_KEY   | IAM Secret Access Key
AWS_SQS_URL					| Your SQS queue URL


The AWSSQS library is licensed under the [MIT License](../LICENSE).
