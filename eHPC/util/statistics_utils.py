import threading
from .. import db
from eHPC.models import Statistic
from flask import current_app


def action(user_id, action_id, data, app):
    with app.app_context():
        db.session.add(Statistic(user_id, action_id, data))
        db.session.commit()


def statistic_record(user_id, action_id, data):
    t = threading.Thread(target=action, args=(user_id, action_id, data, current_app._get_current_object()))
    t.start()
