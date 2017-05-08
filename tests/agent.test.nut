// Please Enter your AWS keys, region and SQS URL
const AWS_TEST_ACCESS_KEY_ID = "YOUR_ACCESS_KEY_ID_HERE";
const AWS_TEST_SECRET_ACCESS_KEY = "YOUR_SECRET_ACCESS_KEY_ID_HERE";
const AWS_TEST_REGION = "YOUR_REGION_HERE";
const AWS_TEST_SQS_URL = "YOUR_SQS_URL_HERE";

const AWS_TEST_MESSAGE = "testMessage";

// invalid information used to check tests
const AWS_TEST_INVALID_ACCESS_KEY_ID = "AAAAAAAAAAAAAAAAAAAAA";
const AWS_TEST_INVALID_RECEIPT_HANDLE = "ASFAEDFAWEFQAWEQWFDAF";

// http response codes
const AWS_TEST_HTTP_RESPONSE_SUCCESS = 200;
const AWS_TEST_HTTP_RESPONSE_FORBIDDEN = 403;
const AWS_TEST_HTTP_RESPONSE_NOT_FOUND = 404;
const AWS_TEST_HTTP_RESPONSE_BAD_REQUEST = 400;



class AgentTestCase extends ImpTestCase {

    _sqs = null;


    // setUP initialises the class
    function setUp() {

        _sqs = AWSSQS(AWS_TEST_REGION, AWS_TEST_ACCESS_KEY_ID, AWS_TEST_SECRET_ACCESS_KEY);
    }


    // testing successfully sending a message. Checks against http ok response
    function testSendMessage() {

        // message params
        local sendParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "MessageBody": AWS_TEST_MESSAGE
        }
        return Promise(function(resolve, reject) {

            _sqs.SendMessage(sendParams, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));

    }



    // testing failing to send a message due to an invalid aws access key. Check against a http forbidden response
    function testInvalidKey() {

        local sqs = AWSSQS(AWS_TEST_REGION, AWS_TEST_INVALID_ACCESS_KEY_ID, AWS_TEST_SECRET_ACCESS_KEY);
        // message params
        local sendParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "MessageBody": AWS_TEST_MESSAGE
        }

        return Promise(function(resolve, reject) {

            sqs.SendMessage(sendParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_FORBIDDEN, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));

    }



    // test successfully receiving a message. Checking against a successful http response.
    function testReceiveMessage() {

        local receiveParams = {
            "QueueUrl": AWS_TEST_SQS_URL
        }
        return Promise(function(resolve, reject) {

            _sqs.ReceiveMessage(receiveParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }



    // test successfully deleting a message
    // first need to receive a message to get ReceiptHandle then you can delete it
    function testDeleteMessage() {

        // finds the receipt handle string in the body string.
        local receiptFinder = function(messageBody) {
            local start = messageBody.find("<ReceiptHandle>");
            local finish = messageBody.find("/ReceiptHandle>");
            local receipt = messageBody.slice((start + 15), (finish - 1));
            return receipt;
        }

        local receiveParams = {
            "QueueUrl": AWS_TEST_SQS_URL
        }
        return Promise(function(resolve, reject) {

            _sqs.ReceiveMessage(receiveParams, function(res) {

                local receipt = receiptFinder(res.body);
                local deleteParams = {
                    "QueueUrl": AWS_TEST_SQS_URL,
                    "ReceiptHandle": receipt
                }
                _sqs.DeleteMessage(deleteParams, function(res) {

                    try {
                        this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                        resolve();
                    } catch (e) {
                        reject(e);
                    }

                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));

    }



    // using an invalid ReceiptHandle to fail to delete a message. Check against http response code
    function testFailDeleteMessage() {

        local deleteParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "ReceiptHandle": AWS_TEST_INVALID_RECEIPT_HANDLE
        }

        return Promise(function(resolve, reject) {

            _sqs.DeleteMessage(deleteParams, function(res) {
                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_NOT_FOUND, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }



    // test a successful batch transmission. Validate against the http response
    function testSendBatchMessages() {

        // parameters for sending multiple messages
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m2",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        }
        return Promise(function(resolve, reject) {

            _sqs.SendMessageBatch(messageBatchParams, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }

            }.bindenv(this));
        }.bindenv(this));
    }



    // test a failure batch transmission. When id's are not unique should receive a 400 response
    function testFailSendBatchMessages() {

        // note duplicate id's in parameters
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m1",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        }
        return Promise(function(resolve, reject) {

            _sqs.SendMessageBatch(messageBatchParams, function(res) {

                try {
                    this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status code " + res.statuscode);
                    resolve();
                } catch (e) {
                    reject(e);
                }
            }.bindenv(this));
        }.bindenv(this));
    }




    // test successfully deleting a batch of messages. Validate against the http response
    function testDeleteMessageBatch() {

        // parameters for multiple messages to be sent
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m2",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        }

        // finds the receipt handle string in the body string.
        local receiptFinder = function(messageBody) {
			
            local start = messageBody.find("<ReceiptHandle>");
            local finish = messageBody.find("/ReceiptHandle>");
            local receipt = messageBody.slice((start + 15), (finish - 1));
            return receipt;
        }

        // reception parameters to recieve messages
        local receiveParams = {
            "QueueUrl": AWS_TEST_SQS_URL
        }

        return Promise(function(resolve, reject) {

            // send multiple messages
            _sqs.SendMessageBatch(messageBatchParams, function(res) {

                // receive multiple messages
                _sqs.ReceiveMessage(receiveParams, function(res) {

                    // get the receipt handle and set up the deletion parameters
                    local receipt = receiptFinder(res.body);
                    local deleteParams = {
                        "QueueUrl": AWS_TEST_SQS_URL,
                        "DeleteMessageBatchRequestEntry.1.Id": "m1"
                        "DeleteMessageBatchRequestEntry.1.ReceiptHandle": receipt,
                    }
                    _sqs.DeleteMessageBatch(deleteParams, function(res) {

                        try {
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_SUCCESS, "Actual status code " + res.statuscode);
                            resolve();
                        } catch (e) {
                            reject(e);
                        }

                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));
    }



    // test for an unsuccessful deletion of a batch. When deletion params has no details the
    // http should respond with a bad request
    function testFailDeleteMessageBatch() {

        // parameters for multiple messages to be sent
        local messageBatchParams = {
            "QueueUrl": AWS_TEST_SQS_URL,
            "SendMessageBatchRequestEntry.1.Id": "m1",
            "SendMessageBatchRequestEntry.1.MessageBody": "testMessage1",
            "SendMessageBatchRequestEntry.2.Id": "m2",
            "SendMessageBatchRequestEntry.2.MessageBody": "testMessage2",
        }

        // finds the receipt handle string in the body string.
        local receiptFinder = function(messageBody) {
            local start = messageBody.find("<ReceiptHandle>");
            local finish = messageBody.find("/ReceiptHandle>");
            local receipt = messageBody.slice((start + 15), (finish - 1));
            return receipt;
        }

        // reception parameters to receive messages
        local receiveParams = {
            "QueueUrl": AWS_TEST_SQS_URL
        }

        return Promise(function(resolve, reject) {

            // send multiple messages
            _sqs.SendMessageBatch(messageBatchParams, function(res) {

                // receive multiple messages
                _sqs.ReceiveMessage(receiveParams, function(res) {

                    // get the receipt handle and set up the deletion parameters
                    local receipt = receiptFinder(res.body);
                    local deleteParams = {
                        "QueueUrl": AWS_TEST_SQS_URL,
                    }
                    _sqs.DeleteMessageBatch(deleteParams, function(res) {

                        try {
                            this.assertTrue(res.statuscode == AWS_TEST_HTTP_RESPONSE_BAD_REQUEST, "Actual status code " + res.statuscode);
                            resolve();
                        } catch (e) {
                            reject(e);
                        }

                    }.bindenv(this));
                }.bindenv(this));
            }.bindenv(this));
        }.bindenv(this));


    }

}