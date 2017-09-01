from __future__ import print_function

import os
from datetime import datetime
from urllib2 import urlopen

URL = os.environ['URL']
TEXT = os.environ['TEXT']


def validate(res):
    '''Return False to trigger the canary

    Currently this simply checks whether the TEXT string is present.
    However, you could modify this to perform any number of arbitrary
    checks on the contents of URL.
    '''
    return TEXT in res


def lambda_handler(event, context):
    print('Checking {} at {}...'.format(URL, event['time']))
    try:
        if not validate(urlopen(URL).read()):
            raise Exception('Validation failed')
    except Exception:
        print('Check failed!')
        raise
    else:
        print('Check passed!')
        return event['time']
    finally:
        print('Check complete at {}'.format(str(datetime.now())))
