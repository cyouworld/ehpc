"""empty message

Revision ID: 7817e631ed63
Revises: 854d37b1e676
Create Date: 2017-05-15 16:47:36.941000

"""

# revision identifiers, used by Alembic.
revision = '7817e631ed63'
down_revision = '854d37b1e676'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('lab_programs')
    op.alter_column('apply', 'course_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True,
               existing_server_default=sa.text(u"'0'"))
    op.alter_column('apply', 'user_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True,
               existing_server_default=sa.text(u"'0'"))
    op.alter_column('challenges', 'content',
               existing_type=mysql.TEXT(),
               nullable=False)
    op.alter_column('challenges', 'title',
               existing_type=mysql.VARCHAR(length=1024),
               nullable=False)
    op.alter_column('courses', 'group_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True)
    op.alter_column('courses', 'title',
               existing_type=mysql.VARCHAR(length=128),
               nullable=False,
               existing_server_default=sa.text(u"''"))
    op.drop_constraint(u'homework_ibfk_1', 'homework', type_='foreignkey')
    op.create_foreign_key(None, 'homework', 'courses', ['course_id'], ['id'])
    op.drop_constraint(u'homework_appendix_ibfk_1', 'homework_appendix', type_='foreignkey')
    op.drop_constraint(u'homework_appendix_ibfk_2', 'homework_appendix', type_='foreignkey')
    op.create_foreign_key(None, 'homework_appendix', 'homework', ['homework_id'], ['id'])
    op.create_foreign_key(None, 'homework_appendix', 'users', ['user_id'], ['id'])
    op.drop_constraint(u'homework_upload_ibfk_2', 'homework_upload', type_='foreignkey')
    op.drop_constraint(u'homework_upload_ibfk_1', 'homework_upload', type_='foreignkey')
    op.create_foreign_key(None, 'homework_upload', 'users', ['user_id'], ['id'])
    op.create_foreign_key(None, 'homework_upload', 'homework', ['homework_id'], ['id'])
    op.alter_column('lessons', 'number',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False)
    op.alter_column('lessons', 'title',
               existing_type=mysql.VARCHAR(length=128),
               nullable=False)
    op.add_column('machine_apply', sa.Column('submit_status', sa.Integer(), nullable=True))
    op.alter_column('programs', 'user_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True)
    op.alter_column('qrcode', 'course_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True)
    op.alter_column('questions', 'user_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True)
    op.drop_index('course_id', table_name='questions')
    op.alter_column('submit_problem', 'pid',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True)
    op.drop_constraint(u'user_questions_ibfk_1', 'user_questions', type_='foreignkey')
    op.alter_column('users', 'gender',
               existing_type=mysql.TINYINT(display_width=1),
               nullable=True)
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.alter_column('users', 'gender',
               existing_type=mysql.TINYINT(display_width=1),
               nullable=False)
    op.create_foreign_key(u'user_questions_ibfk_1', 'user_questions', 'users', ['user_id'], ['id'])
    op.alter_column('submit_problem', 'pid',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False)
    op.create_index('course_id', 'questions', ['user_id'], unique=False)
    op.alter_column('questions', 'user_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False)
    op.alter_column('qrcode', 'course_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False)
    op.alter_column('programs', 'user_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False)
    op.drop_column('machine_apply', 'submit_status')
    op.alter_column('lessons', 'title',
               existing_type=mysql.VARCHAR(length=128),
               nullable=True)
    op.alter_column('lessons', 'number',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=True)
    op.drop_constraint(None, 'homework_upload', type_='foreignkey')
    op.drop_constraint(None, 'homework_upload', type_='foreignkey')
    op.create_foreign_key(u'homework_upload_ibfk_1', 'homework_upload', 'homework', ['homework_id'], ['id'], onupdate=u'CASCADE', ondelete=u'CASCADE')
    op.create_foreign_key(u'homework_upload_ibfk_2', 'homework_upload', 'users', ['user_id'], ['id'], onupdate=u'CASCADE', ondelete=u'CASCADE')
    op.drop_constraint(None, 'homework_appendix', type_='foreignkey')
    op.drop_constraint(None, 'homework_appendix', type_='foreignkey')
    op.create_foreign_key(u'homework_appendix_ibfk_2', 'homework_appendix', 'users', ['user_id'], ['id'], onupdate=u'CASCADE', ondelete=u'CASCADE')
    op.create_foreign_key(u'homework_appendix_ibfk_1', 'homework_appendix', 'homework', ['homework_id'], ['id'], onupdate=u'CASCADE', ondelete=u'CASCADE')
    op.drop_constraint(None, 'homework', type_='foreignkey')
    op.create_foreign_key(u'homework_ibfk_1', 'homework', 'courses', ['course_id'], ['id'], onupdate=u'CASCADE', ondelete=u'CASCADE')
    op.alter_column('courses', 'title',
               existing_type=mysql.VARCHAR(length=128),
               nullable=True,
               existing_server_default=sa.text(u"''"))
    op.alter_column('courses', 'group_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False)
    op.alter_column('challenges', 'title',
               existing_type=mysql.VARCHAR(length=1024),
               nullable=True)
    op.alter_column('challenges', 'content',
               existing_type=mysql.TEXT(),
               nullable=True)
    op.alter_column('apply', 'user_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False,
               existing_server_default=sa.text(u"'0'"))
    op.alter_column('apply', 'course_id',
               existing_type=mysql.INTEGER(display_width=11),
               nullable=False,
               existing_server_default=sa.text(u"'0'"))
    op.create_table('lab_programs',
    sa.Column('id', mysql.INTEGER(display_width=11), nullable=False),
    sa.Column('source_code', mysql.TEXT(), nullable=False),
    sa.Column('default_code', mysql.TEXT(), nullable=True),
    sa.PrimaryKeyConstraint('id'),
    mysql_default_charset=u'utf8',
    mysql_engine=u'InnoDB'
    )
    ### end Alembic commands ###
