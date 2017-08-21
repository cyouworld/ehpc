import geoip2.database
import geoip2.errors
from flask_login import current_user
from .. import db


def save_address(ip):
    reader = geoip2.database.Reader('GeoLite2-City.mmdb')

    try:
        response = reader.city(ip)
    except geoip2.errors.AddressNotFoundError:
        return

    current_user.last_longitude = str(response.location.longitude)
    current_user.last_latitude = str(response.location.latitude)
    current_user.city_name = response.city.names['zh-CN']
    db.session.commit()