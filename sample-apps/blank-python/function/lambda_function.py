import os
import logging
import jsonpickle
import boto3
import random
import requests
import time
from opentelemetry import trace
from urllib import parse
#from aws_xray_sdk.core import xray_recorder
#from aws_xray_sdk.core import patch_all

# for manual tracing
tracer = trace.get_tracer(__name__)

logger = logging.getLogger()
logger.setLevel(logging.INFO)
#patch_all()

client = boto3.client('lambda')
# unexpected usage, this creates an extra trace during cold start
client.get_account_settings()

def lambda_handler(event, context):
    logger.info('## ENVIRONMENT VARIABLES\r' + jsonpickle.encode(dict(**os.environ)))
    logger.info('## EVENT\r' + jsonpickle.encode(event))
    logger.info('## CONTEXT\r' + jsonpickle.encode(context))

    body = {}

    current_span = trace.get_current_span()
    current_span.set_attribute("test.attribute", 1)

    if 'rpc' in event.keys():
        split = parse.urlsplit(str(event.get("rpc")))
        if split.scheme == '' or split.netloc == '':
            url = 'https://postman-echo.com/headers'
        else:
            url = '%s://%s%s' % (split.scheme, split.netloc, split.path)
        try:
            resp = requests.get(url)
            body['rpc'] = resp.text
        except Exception as e:
            logger.info("error in rpc %s", e)

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
    body['awsclient'] = response['AccountUsage']

    return {"statusCode": 200, "body": jsonpickle.encode(body)}