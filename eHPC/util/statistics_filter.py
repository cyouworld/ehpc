from . import filter_blueprint
from ..models import Statistic
import json
from datetime import datetime, timedelta
from sqlalchemy import and_


@filter_blueprint.app_template_filter('statistic_get_data')
def statistic_get_data(statistics, time_str='month'):
    actions = [Statistic.ACTION_COURSE_VISIT_DOCUMENT_OR_VIDEO, Statistic.ACTION_COURSE_ATTEND_QUIZ,
               Statistic.ACTION_COURSE_SUBMIT_QUIZ_ANSWER, Statistic.ACTION_QUESTION_SUBMIT_ANSWER,
               Statistic.ACTION_LAB_PASS_A_PROGRAMING_TASK, Statistic.ACTION_LAB_PASS_A_CONFIGURATION_TASK,
               Statistic.ACTION_USER_VISIT_MAIN_PAGE]
    data = {}
    today_start = datetime.today().replace(hour=0, minute=0, second=0, microsecond=0)

    for action in actions:
        s = None
        if time_str == 'month':
            m_start = today_start - timedelta(days=today_start.day) + timedelta(days=1)
            s = statistics.filter_by(action=action).filter(Statistic.timestamp >= m_start).all()
        elif time_str == 'this-week':
            this_w_start = today_start - timedelta(days=today_start.weekday())
            s = statistics.filter_by(action=action).filter(Statistic.timestamp >= this_w_start).all()
        elif time_str == 'last-week':
            this_w_start = today_start - timedelta(days=today_start.weekday())
            last_w_start = this_w_start - timedelta(days=7)
            s = statistics.filter_by(action=action).filter(and_(Statistic.timestamp >= last_w_start,
                                                                Statistic.timestamp < this_w_start)).all()
        elif time_str == 'today':
            s = statistics.filter_by(action=action).filter(Statistic.timestamp >= today_start).all()

        elif time_str == 'all':
            s = statistics.filter_by(action=action).all()
        temp = []
        for statistic in s:
            if statistic.data is None:
                temp.append(dict(time=str(statistic.timestamp)))
            else:
                temp.append(dict(data=json.loads(statistic.data), time=str(statistic.timestamp)))
        data[action] = temp
    return json.dumps(data)

