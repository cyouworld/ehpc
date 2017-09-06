import geoip2.database
import geoip2.errors
from flask import current_app
from flask_login import current_user
from .. import db


def save_address(ip):
    try:
        response = current_app.geoip_reader.city(ip)
    except Exception as e:
        print(e)
        return

    if 'zh-CN' in response.city.names.keys():
        current_user.last_longitude = str(response.location.longitude)
        current_user.last_latitude = str(response.location.latitude)
        current_user.city_name = response.city.names['zh-CN']
        db.session.commit()
