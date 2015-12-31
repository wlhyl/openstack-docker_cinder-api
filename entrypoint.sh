#!/bin/bash

if [ -z "$CINDER_DBPASS" ];then
  echo "error: CINDER_DBPASS not set"
  exit 1
fi

if [ -z "$CINDER_DB" ];then
  echo "error: CINDER_DB not set"
  exit 1
fi

if [ -z "$RABBIT_HOST" ];then
  echo "error: RABBIT_HOST not set"
  exit 1
fi

if [ -z "$RABBIT_USERID" ];then
  echo "error: RABBIT_USERID not set"
  exit 1
fi

if [ -z "$RABBIT_PASSWORD" ];then
  echo "error: RABBIT_PASSWORD not set"
  exit 1
fi

if [ -z "$CINDER_PASS" ];then
  echo "error: CINDER_PASS not set"
  exit 1
fi

if [ -z "$KEYSTONE_INTERNAL_ENDPOINT" ];then
  echo "error: KEYSTONE_INTERNAL_ENDPOINT not set"
  exit 1
fi

if [ -z "$KEYSTONE_ADMIN_ENDPOINT" ];then
  echo "error: KEYSTONE_ADMIN_ENDPOINT not set"
  exit 1
fi

if [ -z "$MY_IP" ];then
  echo "error: MY_IP not set. my_ip use management interface IP address of cinder-api."
  exit 1
fi

CRUDINI='/usr/bin/crudini'

CONNECTION=mysql://cinder:$CINDER_DBPASS@$CINDER_DB/cinder

if [ ! -f /etc/cinder/.complete ];then
    cp -rp /cinder/* /etc/cinder

    $CRUDINI --set /etc/cinder/cinder.conf database connection $CONNECTION

    $CRUDINI --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit

    $CRUDINI --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host $RABBIT_HOST
    $CRUDINI --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid $RABBIT_USERID
    $CRUDINI --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $RABBIT_PASSWORD    

    $CRUDINI --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone

    $CRUDINI --del /etc/cinder/cinder.conf keystone_authtoken

    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://$KEYSTONE_INTERNAL_ENDPOINT:5000
    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://$KEYSTONE_ADMIN_ENDPOINT:35357
    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin password
    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id default
    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id default
    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken project_name service
    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken username cinder
    $CRUDINI --set /etc/cinder/cinder.conf keystone_authtoken password $CINDER_PASS

    $CRUDINI --set /etc/cinder/cinder.conf DEFAULT my_ip $MY_IP
    # 使用 glance api v2
    $CRUDINI --set /etc/cinder/cinderconf DEFAULT glance_api_version 2

    $CRUDINI --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
    $CRUDINI --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder

    touch /etc/cinder/.complete
fi

chown -R cinder:cinder /var/log/cinder/

# 同步数据库
echo 'select * from volumes limit 1;' | mysql -h$CINDER_DB  -ucinder -p$CINDER_DBPASS cinder
if [ $? != 0 ];then
    su -s /bin/sh -c "cinder-manage db sync" cinder
fi

/usr/bin/supervisord -n