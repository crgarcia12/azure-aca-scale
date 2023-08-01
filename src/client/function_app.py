from os import environ
import sys
from azure.functions import QueueMessage
import azure.functions as func
from azure.identity import DefaultAzureCredential, AzureCliCredential
from azure.storage.queue import QueueServiceClient, QueueClient, QueueMessage

import logging

app = func.FunctionApp()


@app.route(route="simulateClient", auth_level=func.AuthLevel.ANONYMOUS)
def simulateClient(req: func.HttpRequest) -> func.HttpResponse:

    # Setup the logger
    logger = logging.getLogger('azure.identity')
    logger.setLevel(logging.INFO)

    handler = logging.StreamHandler(stream=sys.stdout)
    formatter = logging.Formatter('[%(levelname)s %(name)s] %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    # Start the Function
    logging.info('Python HTTP trigger function processed a request.')

    queue_name = "blobchangequeue"
    #default_credential = DefaultAzureCredential(exclude_environment_credential = True )
    default_credential = AzureCliCredential()
    
    account_url = environ.get("QUEUESTORAGEACCOUNTURL")
    if not account_url:
        raise ValueError("Missing QUEUESTORAGEACCOUNTURL environment variable.")
    
    queue_client = QueueClient(account_url, queue_name=queue_name ,credential=default_credential)

    count = req.params.get('count')
    if not count:
        count = 10

    for i in range(int(count)):
        print("Generating message #", i)
        queue_client.send_message(f"Hello World {i}")

    return func.HttpResponse(f"Done! {count} messages sent.")