# 环境变量
- CINDER_DB: designate数据库ip
- CINDER_DBPASS: designate数据库密码
- RABBIT_HOST: rabbitmq IP
- RABBIT_USERID: rabbitmq user
- RABBIT_PASSWORD: rabbitmq user 的 password
- KEYSTONE_ENDPOINT: keystone endpoint
- CINDER_PASS: openstack cinder用户密码
- MY_IP: my_ip
# volumes:
- /opt/openstack/designate-api/: /etc/designate
- /opt/openstack/log/designate-api/: /var/log/designate/

# 启动cinder-api
```bash
docker run -d --name cinder-api \
    -p 8776:8776 \
    -v /opt/openstack/cinder-api/:/etc/cinder \
    -v /opt/openstack/log/cinder-api/:/var/log/cinder/ \
    -e CINDER_DB=10.64.0.52 \
    -e CINDER_DBPASS=cinder_dbpass \
    -e RABBIT_HOST=10.64.0.52 \
    -e RABBIT_USERID=openstack \
    -e RABBIT_PASSWORD=openstack \
    -e KEYSTONE_ENDPOINT=10.64.0.52 \
    -e CINDER_PASS=cinder \
    -e MY_IP=10.64.0.52 \
    10.64.0.50:5000/lzh/cinder-api:kilo
```