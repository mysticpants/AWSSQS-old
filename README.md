# AWSSQS

The helper library to implement [AWS SQS](https://aws.amazon.com/documentation/sqs/) functions from agent code.

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.2"
#require "AWSSQS.class.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to perform actions with the AWS SQS (Simple Queueing Service)

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)
AWSSQS object constructor takes the following parameters:

Parameter              | Type           | Description
---------------------- | -------------- | -----------
region                 | string         | AWS region (e.g. "us-west-2")
accessKeyId            | string         | IAM Access Key ID
secretAccessKey        | string         | IAM Secret Access Key


```squirrel
const AWS_SQS_ACCESS_KEY_ID = "YOUR_ACCESS_KEY_ID_HERE";
const AWS_SQS_SECRET_ACCESS_KEY = "YOUR_SECRET_ACCESS_KEY_ID_HERE/gFFOFxSMZHAlG2";
const AWS_SQS_URL = "YOUR_SQS_URL_HERE";
const AWS_SQS_REGION = "YOUR_REGION_HERE";

// initialise the class
sqs <- AWSSQS(AWS_SQS_REGION, AWS_SQS_ACCESS_KEY_ID, AWS_SQS_SECRET_ACCESS_KEY);
```

### DeleteMessage(params, cb)
Deletes the specified message from the specified queue. You specify the message by using the message's receipt handle and not the MessageId you receive when you send the message.
http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteMessage.html

 Parameter            |       Type     | Description
----------------------| -------------- | -----------
**params**            | table          | Table of parameters (See API Reference)
**cb**                | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter    | Type    |Required | Description             
-------------|-------- |-------- |--------------------------
QueueUrl     | String  | Yes     | The URL of the Amazon SQS queue from which messages are deleted
ReceiptHandle| String  | Yes     | The receipt handle associated with the message to delete

```squirrel
// RECEIPT_HANDLE can be found from the response.body in ReceiveMessage
deleteParams <- {
    "QueueUrl": "AWS_SQS_URL"
	"ReceiptHandle": "RECEIPT_HANDLE"
}
sqs.DeleteMessage(deleteParams, function(res) {
    server.log(res.statuscode);
});

```

### DeleteMessageBatch(params, cb)
Deletes up to ten messages from the specified queue. This is a batch version of DeleteMessage. The result of the action on each message is reported individually in the response.
http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_DeleteMessageBatch.html

 Parameter       |       Type     | Description
-----------------| -------------- | -----------
**params**       | table          | Table of parameters (See API Reference)
**cb**           | function       | Callback function that takes one parameter (a response table)


where `params` includes

Parameter                          | Type    | Required | Description|
-----------------------------------|-------- |--------  |--------------------------
QueueUrl                           | String  | Yes      | The URL of the Amazon SQS queue from which messages are deleted
DeleteMessageBatchRequestEntry.N.X | String  | Yes      | A list of DeleteMessageBatchResultEntry items. Where N is the message entry number and X is the SendMessageBatchResultEntry parameter.

#### DeleteMessageBatchRequestEntry

Parameter     | Type    | Required | Description             |
------------- |-------- |--------  | --------------------------
Id            | String  | Yes      | An identifier for this particular receipt handle.
ReceiptHandle | String  | Yes      | The receipt handle associated with the message to delete


```squirrel
// delete the message corresponding to id "m1"
// see ReceiveMessage for receipt

local deleteParams = {
    "QueueUrl": "AWS_SQS_URL",
    "DeleteMessageBatchRequestEntry.1.Id": "m1"
    "DeleteMessageBatchRequestEntry.1.ReceiptHandle": receipt,
}

_sqs.DeleteMessageBatch(deleteParams, function(res) {
    server.log(res.statuscode);
}

```

### ReceiveMessage(params, cb)
Retrieves one or more messages (up to 10), from the specified queue.
http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_ReceiveMessage.html

 Parameter |       Type     | Description
---------- | -------------- | -----------
**params** | table          | Table of parameters (See API Reference)
**cb**     | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter               | Type     | Required | Description|
----------------------  |----------|--------- |-------------
QueueUrl                | String   | Yes      | The URL of the Amazon SQS queue from which messages are deleted
AttributeName.N         | array of Strings|No | A list of attributes that need to be returned along with each message. See api document for details
MaxNumberOfMessages     | Integer  | No       | The maximum number of messages to return. Between 1 and 10 messages may be selected to be returned
MessageAttributeName.N  | array of Strings|No | The name of the message attribute, where N is the index
ReceiveRequestAttemptId | String   | No       | This parameter applies only to FIFO (first-in-first-out) queues.The token used for deduplication of ReceiveMessage calls. If a networking issue occurs after a ReceiveMessage action, and instead of a response you receive a generic error, you can retry the same action with an identical ReceiveRequestAttemptId
VisibilityTimeout       | Integer  | No       | The duration (in seconds) that the received messages are hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request
WaitTimeSeconds         | Integer  | No       | The duration (in seconds) for which the call waits for a message to arrive in the queue before returning. If a message is available, the call returns sooner than WaitTimeSeconds

```squirrel
local receiptFinder = function(messageBody) {
    local start = messageBody.find("<ReceiptHandle>");
    local finish = messageBody.find("/ReceiptHandle>");
    local receipt = messageBody.slice((start + 15), (finish - 1));
    return receipt;
}

// Receive Message
receiveParams <- {
    "QueueUrl": "AWS_SQS_URL"
}
sqs.ReceiveMessage(receiveParams, function(res) {
    server.log(res.statuscode);
    server.log(receiptFinder(res.body);
});

```

### SendMessage(params, cb)
Delivers a message to the specified queue.
http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessage.html

 Parameter          |       Type     | Description
------------------- | -------------- | -----------
**params** | table  | Table of parameters (See API Reference)
**cb**              | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter             | Type      | Required | Description|
----------------------|-----------|----------|------------
QueueUrl              | String    | Yes      | The URL of the Amazon SQS queue from which messages are deleted
DelaySeconds          | Integer   | No       | The number of seconds to delay a specific message. Valid values: 0 to 900.
MessageAttribute      | String to MessageAttributeValue object map | No | MessageAttribute.N.Name (key), MessageAttribute.N.Value (value). Each message attribute consists of a Name, Type, and Value
MessageBody           | String    | Yes      | The message to send. The maximum string size is 256 KB.
MessageDeduplicationId| String    | No       | This parameter applies only to FIFO (first-in-first-out) queues. The token used for deduplication of sent messages. If a message with a particular MessageDeduplicationId is sent successfully, any messages sent with the same MessageDeduplicationId are accepted successfully but aren't delivered during the 5-minute deduplication interval
MessageGroupId        | String    | No       | This parameter applies only to FIFO (first-in-first-out) queues.The tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are processed in a FIFO manner (however, messages in different message groups might be processed out of order)

```squirrel
// Send Message
sendParams <- {
    "QueueUrl": "AWS_SQS_URL",
    "MessageBody": "testMessage"
}

sqs.SendMessage(sendParams, function(res) {
    server.log(http.jsonencode(res));
});

```

### SendMessageBatch(params, cb)
Delivers up to ten messages to the specified queue.
http://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_SendMessageBatch.html

 Parameter             | Type           | Description
---------------------- | -------------- | -----------
**params**             | table          | Table of parameters (See API Reference)
**cb**                 | function       | Callback function that takes one parameter (a response table)

where `params` includes

Parameter                        | Type    | Required   |Description
---------------------------------|---------|------------|-----------
QueueUrl                         | String  | Yes        | The URL of the Amazon SQS queue from which messages are deleted
SendMessageBatchRequestEntry.N.X | String | Yes | A list of SendMessageBatchResultEntry items. Where N is the message entry number and X is the SendMessageBatchResultEntry parameter.

#### SendMessageBatchRequestEntry

Parameter                | Type      | Required   | Description
------------------------ |-----------|------------|---------------
DelaySeconds          	 | Integer   | No         | The number of seconds to delay a specific message. Valid values: 0 to 900.
Id                       | String    | Yes        | An identifier for the message in this batch.
MessageAttribute         | String to MessageAttributeValue object map | No | MessageAttribute.N.Name (key), MessageAttribute.N.Value (value). Each message attribute consists of a Name, Type, and Value
MessageBody              | String    | Yes        | The message to send. The maximum string size is 256 KB.
MessageDeduplicationId   | String    | No         | This parameter applies only to FIFO (first-in-first-out) queues. The token used for deduplication of sent messages. If a message with a particular MessageDeduplicationId is sent successfully, any messages sent with the same MessageDeduplicationId are accepted successfully but aren't delivered during the 5-minute deduplication interval
MessageGroupId           | String    | No         | This parameter applies only to FIFO (first-in-first-out) queues.The tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are processed in a FIFO manner (however, messages in different message groups might be processed out of order)


```squirrel
local messageBatchParams = {
    "QueueUrl": "AWS_SQS_URL",
    "SendMessageBatchRequestEntry.1.Id": "m1",
    "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
    "SendMessageBatchRequestEntry.2.Id": "m2",
    "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
}
sqs.SendMessageBatch (messageBatchParams, function(res) {
    server.log(res.statuscode);
});

```

# License

The AWSSQS library is licensed under the [MIT License](https://github.com/electricimp/thethingsapi/tree/master/LICENSE).
