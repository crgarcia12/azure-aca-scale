import azure.functions as func
import os
import sys
import logging

app = func.FunctionApp()

# Setup the logger
logger = logging.getLogger('azure.identity')
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(stream=sys.stdout)
formatter = logging.Formatter('[%(levelname)s %(name)s] %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

@app.blob_trigger(arg_name="myblob", 
    path="raw",
    connection="StorageAccountConnectionString") 
def Chunk(myblob: func.InputStream):
    logging.info(f"Python blob trigger function processed blob"
                f"Name: {myblob.name}"
                f"Blob Size: {myblob.length} bytes")



@app.queue_trigger(arg_name="msg", queue_name="blobchangequeue",
                               connection="StorageAccountConnectionString") 
def blobchange(msg: func.QueueMessage):
    logging.info('Python Queue trigger processed a message: %s',
                msg.get_body().decode('utf-8'))
