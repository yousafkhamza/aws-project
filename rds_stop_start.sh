#!/bin/sh

service=$1
replica1=replica-view-1.cjzkplclwa1m.ap-south-1.rds.amazonaws.com
replica2=replica-view-2.cjzkplclwa1m.ap-south-1.rds.amazonaws.com
user=admin
pass=admin123

if [ -z "$service" ]
then
        echo "Please enter any values"
        exit 1
fi

case "$1" in 
start|START)

	mysql -u $user -p$pass -h $replica1 -e "CALL mysql.rds_start_replication;"
	mysql -u $user -p$pass -h $replica2 -e "CALL mysql.rds_start_replication;"

	rsync -avz --progress --exclude "wp-config.php" -e 'ssh -p22' /var/www/html/* root@rsync.db.pv:/wp/
;;
stop|STOP)

	mysql -u $user -p$pass -h $replica1 -e "CALL mysql.rds_stop_replication;"
	mysql -u $user -p$pass -h $replica2 -e "CALL mysql.rds_stop_replication;"
;;

*)
            # Invalid choice
            echo 'Unfortunatly we have only two options --start/stop--' >&2
;;
esac