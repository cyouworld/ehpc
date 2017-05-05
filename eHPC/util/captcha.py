#! /usr/bin/env python
# -*- coding: utf-8 -*-

import requests
from config import CAPTCHA_VERIFY_URL, CAPTCHA_API_KEY


def verify_captcha(response):
    r = requests.post(CAPTCHA_VERIFY_URL,
                      data={'api_key': CAPTCHA_API_KEY,
                            'response': response})
    if r.json()['res'] == 'success':
        return True
    else:
        return False
