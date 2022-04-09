redis_version=7.0-rc2
redis_download_url=https://github.com/redis/redis/archive/$redis_version.tar.gz
redis_pkg=`echo $redis_download_url | sed 's/.*\///g'`
redis_folder=redis-$redis_version

redis_module_path=/home/modules/redis
redis_bin_path=$redis_module_path/bin
redis_scripts_path=$redis_module_path/scripts

redis_port=6379
redis_log_path=/home/modules/redis/redis_server.log