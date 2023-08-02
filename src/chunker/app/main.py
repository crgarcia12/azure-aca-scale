
from os import environ
import asyncio
import sys

from typing import Union
from fastapi import FastAPI
import uvicorn
from dotenv import load_dotenv

from azure.identity.aio import DefaultAzureCredential
from azure.storage.queue.aio import QueueClient
import logging

app = FastAPI()

processed_messages = 0

@app.get("/")
def read_root():
    return {f"Hello World! We already processed {processed_messages} messages."}

async def start_queue_listener():
    try:
        # Create a logger for the 'azure.storage.queue' SDK
        logger = logging.getLogger('azure.storage.queue')
        logger.setLevel(logging.DEBUG)
        # Configure a console output
        handler = logging.StreamHandler(stream=sys.stdout)
        logger.addHandler(handler)

        queue_name = "chunkerqueue"
        account_url = environ.get("QUEUE_STORAGE_ACCOUNT_URL")
        if not account_url:
            raise ValueError("Missing QUEUE_STORAGE_ACCOUNT_URL environment variable.")

        default_credential = DefaultAzureCredential(exclude_environment_credential = True)
        logging.info(f"Using account URL '{account_url}' to send messages to queue '{queue_name}' with credential '{default_credential}'")
        
        async with default_credential:
            queue_client = QueueClient(account_url, queue_name=queue_name ,credential=default_credential)

            while True:
                response = queue_client.receive_messages()
                async for message in response:
                    global processed_messages
                    processed_messages = processed_messages + 1
                    print(message.content)
                    await queue_client.delete_message(message)
                    
    except Exception as err:
        print(f"Unexpected error trying to get messages from queue: {err=}, {type(err)=}")
        logging.error(f"Unexpected error trying to get messages from queue: {err=}, {type(err)=}")
        

# Start the main method
@app.on_event("startup")
async def startup_event():
    print("Starting up...")
    logging.warn("Starting up...")
    global processed_messages
    processed_messages = 0
    asyncio.create_task(start_queue_listener())

if __name__ == "__main__":
    print("run main")
    logging.warn("run main")
    load_dotenv() 
    uvicorn.run(app, host="0.0.0.0", port=3000, log_level="info", debug=True)