#!/bin/bash
sed -i "s/^port .*/port $PORT/g" ${redis_module_path}/redis.conf

echo "redis-cli -h localhost -p ${PORT}" > /usr/local/bin/redisconnect
chmod +x /usr/local/bin/redisconnect