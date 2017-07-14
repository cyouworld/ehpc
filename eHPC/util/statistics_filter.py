from . import filter_blueprint
from ..models import Statistic
import json


@filter_blueprint.app_template_filter('statistic_action_count')
def statistic_action_count(statistics, action):
    return len(statistics.filter_by(action=action).all())


@filter_blueprint.app_template_filter('statistic_get_data')
def statistic_get_data(statistics):
    actions = [Statistic.ACTION_USER_VISIT_PERSONAL_HOME_PAGE, Statistic.ACTION_COURSE_VISIT_DOCUMENT_OR_VIDEO,
               Statistic.ACTION_COURSE_ATTEND_QUIZ, Statistic.ACTION_COURSE_SUBMIT_QUIZ_ANSWER,
               Statistic.ACTION_COURSE_COMMENT, Statistic.ACTION_QUESTION_VISIT_QUESTION_PAGE,
               Statistic.ACTION_QUESTION_SUBMIT_ANSWER, Statistic.ACTION_PROGRAM_VISIT_PROGRAM_PAGE,
               Statistic.ACTION_PROGRAM_SUBMIT_CODE, Statistic.ACTION_TOPIC_CREATE_TOPIC,
               Statistic.ACTION_LAB_VISIT_PROGRAMING_LAB, Statistic.ACTION_LAB_PASS_A_PROGRAMING_TASK,
               Statistic.ACTION_LAB_VISIT_CONFIGURATION_LAB, Statistic.ACTION_LAB_PASS_A_CONFIGURATION_TASK]

    data = {}

    for action in actions:
        s = statistics.filter_by(action=action).all()
        temp = []
        for statistic in s:
            temp.append(dict(data=json.loads(statistic.data), time=str(statistic.timestamp)))
        data[action] = temp
    return json.dumps(data)
