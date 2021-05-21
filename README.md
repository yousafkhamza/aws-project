# Highly available fault-tolerant PHP application (Deployed on AWS Cloud)
[![Builds](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)


## Description:
It is an application with PHP with a database. I just tell you the project baseline. There was a website like (blog.com) that website is used for upload blogs/images and there have millions of clients and heavy traffic from viewers. But it's another portion like (blog.com/admin) this section is only used, admins/creators. So, there has no heavy traffic with this URL. So, I have designed to structure to separate servers for viewers and creators through application load balancers (Target group). I know all you have doubts about how to manage the creator's database sync with the viewer's database. I overcome with used an RDS-Master server for admin/creators and I have built RDS-Replica servers to connect with viewers servers. Once, if you have any updates on creators/admin servers you saved a replica stop script on your master server and first stop the replica script then update your kinds of stuff on the master server, and then you can start the server through the same script as the scripts run time new data sync to the viewer's server and new database changes applied to the replica servers.

## Used Resources/ Dependencies: 
-ALB
-Target Group
-Target Tracking (For Creating instances based on CPU utilization)
-Launch Templates 
-AMI
-IAM Role (For accessing S3)
-Autoscaling Group
-VPC (Internet Gateway, Security Groups,.... etc)
-Route53 (Private/Public Hosted zones)
-EC2
-EFS (Creator/Viewer data stored)
-Bastion Instance (Using the same instance like act with a sync server)
-RDS
-CloudFront (It's optional and it makes load the same with edge locations)
-S3 (Stored images through offloading)
-Bash Script (Stop and Start with Sync script for RDS/Syncing)

# Architecture Image: 
- _Architecture Image_

![alt text](https://i.ibb.co/WDQKSfz/Project-Architecture.jpg)

# Script Explanation: 
_The script is using for rds master to replica connection stop/start and also starting along with sync the master server to sync server that means the viewer EFS is already connected to the sync server so that datas and database is succesfully replcated through one script_
```sh
#!/bin/sh

service=$1
replica1=replica-view-1.cjzkplclwa1m.ap-south-1.rds.amazonaws.com <==== replica one server endpoint
replica2=replica-view-2.cjzkplclwa1m.ap-south-1.rds.amazonaws.com <==== replica two server endpoint
user=admin <==== username of rds
pass=admin123 <==== password of rds 

if [ -z "$service" ]
then
        echo "Please enter any values"
        exit 1
fi

case "$1" in 
start|START)

	mysql -u $user -p$pass -h $replica1 -e "CALL mysql.rds_start_replication;"
	mysql -u $user -p$pass -h $replica2 -e "CALL mysql.rds_start_replication;"

	rsync -avz --progress --exclude "wp-config.php" -e 'ssh -p22' /var/www/html/* root@rsync.db.pv:/wp/   <==== use your rds hostname/private ip
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
```
## Script sample screenshot
- _Sample Screenshot_

![alt text](https://i.ibb.co/PQj1cCB/sample.jpg)

