#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER
echo "The Script was executing at $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ] #checking the file scritp having the root access or not
then 
    echo -e "$R ERROR :: PLEASE RUN THE SCRIPT WITH ROOT ACCESS $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G YOU ARE RUNNIBG WITH ROOT ACCESS $N" | tee -a $LOG_FILE
fi

echo "Please enter rabbitmq password to setup RoboShop@1"
read -s RABBITMQ_PASSWD

VALIDATE (){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$R ERROR :: $2 is FAILED $N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq server"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE