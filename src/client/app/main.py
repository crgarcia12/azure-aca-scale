from typing import Union
from fastapi import FastAPI
import uvicorn
from dotenv import load_dotenv

from os import environ
import sys
from azure.identity import DefaultAzureCredential, AzureCliCredential
from azure.storage.queue import QueueServiceClient, QueueClient, QueueMessage

import logging


app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/sendmessages/{msg_count}")
def read_item(msg_count: int, q: Union[str, None] = None):

    # Setup the logger
    logger = logging.getLogger('azure.identity')
    logger.setLevel(logging.INFO)

    handler = logging.StreamHandler(stream=sys.stdout)
    formatter = logging.Formatter('[%(levelname)s %(name)s] %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    # Start the Function
    logging.info(f"Received request to send '{msg_count}' messages.")

    queue_name = "chunkerqueue"
    default_credential = DefaultAzureCredential(exclude_environment_credential = True )
    #default_credential = AzureCliCredential()
    
    account_url = environ.get("QUEUE_STORAGE_ACCOUNT_URL")
    if not account_url:
        raise ValueError("Missing QUEUE_STORAGE_ACCOUNT_URL environment variable.")
    
    logging.info(f"Using account URL '{account_url}' to send messages to queue '{queue_name}' with credential '{default_credential}'")
    queue_client = QueueClient(account_url, queue_name=queue_name ,credential=default_credential)

    for i in range(int(msg_count)):
        print("Generating message #", i)
        queue_client.send_message(f"Hello World {i}")

    return {f"sent '{msg_count}' messages to queue '{queue_name}'"}


if __name__ == "__main__":
    load_dotenv() 
    uvicorn.run(app, host="0.0.0.0", port=3000, log_level="info", debug=True)