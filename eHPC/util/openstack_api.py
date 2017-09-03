# -*- coding: utf-8 -*-
import requests

# openstack API 文档： https://developer.openstack.org/api-ref

# base_url: http://hostname:port/v3/


# /identity/v3/#authentication-and-token-management
def get_token(url, domainName, userName, passWord):
    """
    获取token凭证，返回token
    :param url: base_url + auth/tokens
    :param domainName:
    :param userName:
    :param passWord:
    :return:
    """

    payload = {
        "auth": {
            "identity": {
                # 这里的method指的是获取token的方式，对于这个函数固定为"password"
                "method": {
                    "password"
                },
                "password": {
                    "user": {
                        "name": userName,
                        "domain": {
                            "name" : domainName
                        },
                        "password": passWord
                    }
                }
            }
        }
    }

    r = requests.post(url, params=payload)

    try:
        token = r.headers["X-Subject-Token"]
    except Exception as ex:
        print("Error: %s" % ex)
        token = None

    return token

# /identity/v3/#users
def create_user(url, projectID, domainID, enabled, name, password):
    """
    创建用户,返回密码过期的时间
    :param url: base_url + v3/users
    :param projectID:
    :param domainID:
    :param enabled: 用户是否激活。boolean
    :param name:
    :param password:
    :return:
    """
    payload = {
        "user": {
            "default_project_id": projectID,
            "domain_id": domainID,
            "enabled": enabled,
            "name": name,
            "password": password
        }
    }

    r = requests.post(url, params=payload)

    responsedata = r.json()

    return responsedata["password_expires_at"]