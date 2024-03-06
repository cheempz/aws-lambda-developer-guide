import os
import logging
import jsonpickle
import boto3
import random
import time
#from aws_xray_sdk.core import xray_recorder
#from aws_xray_sdk.core import patch_all

logger = logging.getLogger()
logger.setLevel(logging.INFO)
#patch_all()

client = boto3.client('lambda')
client.get_account_settings()

def lambda_handler(event, context):
    logger.info('## ENVIRONMENT VARIABLES\r' + jsonpickle.encode(dict(**os.environ)))
    logger.info('## EVENT\r' + jsonpickle.encode(event))
    logger.info('## CONTEXT\r' + jsonpickle.encode(context))

    if 'sleepMs' in event.keys():
        try:
            sleep_s = int(event.get("sleepMs")) / 1000
        except ValueError:
            sleep_s = random.uniform(0, 3.0)
        logger.info("sleeping %f seconds", sleep_s)
        time.sleep(sleep_s)

    if 'exception' in event.keys():
        # throw a division by zero
        notused = 1/0

    response = client.get_account_settings()
    return {"statusCode": 200, "body": jsonpickle.encode(response['AccountUsage'])}
