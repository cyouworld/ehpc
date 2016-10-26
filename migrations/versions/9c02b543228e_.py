"""empty message

Revision ID: 9c02b543228e
Revises: 52dbc735b9b7
Create Date: 2016-10-24 07:50:48.831960

"""

# revision identifiers, used by Alembic.
revision = '9c02b543228e'
down_revision = '52dbc735b9b7'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.add_column('articles', sa.Column('updatedTime', sa.DateTime(), nullable=True))
    op.drop_column('articles', 'createdTime')
    op.alter_column('users', 'email',
               existing_type=mysql.VARCHAR(length=64),
               nullable=False)
    op.alter_column('users', 'password_hash',
               existing_type=mysql.VARCHAR(length=128),
               nullable=False)
    op.alter_column('users', 'username',
               existing_type=mysql.VARCHAR(length=64),
               nullable=False)
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.alter_column('users', 'username',
               existing_type=mysql.VARCHAR(length=64),
               nullable=True)
    op.alter_column('users', 'password_hash',
               existing_type=mysql.VARCHAR(length=128),
               nullable=True)
    op.alter_column('users', 'email',
               existing_type=mysql.VARCHAR(length=64),
               nullable=True)
    op.add_column('articles', sa.Column('createdTime', mysql.DATETIME(), nullable=True))
    op.drop_column('articles', 'updatedTime')
    ### end Alembic commands ###
