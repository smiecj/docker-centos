hue_http_port=8281
hue_install_prefix=/usr/local
hue_install_path=$hue_install_prefix/hue
mysql_jdbc_url=https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.26/mysql-connector-java-8.0.26.jar
mysql_jdbc_file_name=`echo $mysql_jdbc_url | sed 's/.*\///g'`
mysql_jdbc_class=com.mysql.cj.jdbc.Driver