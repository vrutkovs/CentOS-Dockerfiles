# -*- coding: UTF-8 -*-
from behave import when, then, given
from time import sleep
from common_steps import common_docker_steps, common_connection_steps


@when(u'mariadb container is started')
def mariadb_container_is_started(context):
    # Read mariadb params from context var
    params = ' --name=ctf --privileged=true'
    for param in context.mariadb:
        params += ' -e %s=%s' % (param, context.mariadb[param])
    context.execute_steps(u'* Docker container is started with params "%s"' % params)
    sleep(10)


@given(u'mariadb container param "{param}" is set to "{value}"')
def set_mariadb_params(context, param, value):
    if not hasattr(context, "mariadb"):
        context.mariadb = {}
    context.mariadb[param] = value


@then(u'mariadb connection can be established')
@then(u'mariadb connection can {negative:w} be established')
@then(u'mariadb connection with parameters can be established')
@then(u'mariadb connection with parameters can {negative:w} be established')
def mariadb_connect(context, negative=False):
    if context.table:
        for row in context.table:
            context.mariadb[row['param']] = row['value']

    user = context.mariadb['MYSQL_USER']
    password = context.mariadb['MYSQL_PASSWORD']
    db = context.mariadb['MYSQL_DATABASE']

    try:
        context.execute_steps(u'* port 3306 is open')
    except Exception as e:
        if negative:
            # We're expecting the port to be closed
            return
        else:
            raise e

    for attempts in xrange(0, 5):
        try:
            context.run('docker run --rm %s mysql -h %s -u"%s" -p"%s" -e "SELECT 1;" %s' % (
                context.image, context.ip, user, password, db))
            return
        except AssertionError:
            # If  negative part was set, then we expect a bad code
            # This enables steps like "can not be established"
            if negative:
                return
            sleep(5)

    raise Exception("Failed to connect to mariadb")
