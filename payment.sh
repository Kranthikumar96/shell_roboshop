#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"      #30 = black, 34 = blue, 35 = magenta, 36 = cyan, 37 = white
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
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

VALIDATE (){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$R ERROR :: $2 is FAILED $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing Python3 packages"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop was already created ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment Application CODE"

rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping payment Application CODE"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing Python Dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copying Payment Service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon Reload"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enable payment"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting payment"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE