##!/usr/bin/bash     # For AIX
##!/bin/bash         # For Linux
##!/usr/bin/env bash
##!/bin/sh

. ./LOGSTASH_ENV.lib

CUR_DIR=`pwd`
HOSTNAME=`/bin/hostname -s`
DOCKER=/usr/bin/docker
LOGSTASH_CONFIG_FILE="logstash_${OUTPUT_APPNAME}_${HOSTNAME}"
if [[ -e  "$CUR_DIR/LOGSTASH_CONFIG_TEMPLATE.conf" && -s "$CUR_DIR/LOGSTASH_CONFIG_TEMPLATE.conf" ]] ; then
   cp "$CUR_DIR/LOGSTASH_CONFIG_TEMPLATE.conf" "$CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf"
else
   echo "ERROR : Logstash configuration file template doesn't exist."
   exit 
fi

perl -pi -e "s|"INPUT_FILE_PATH"|"${INPUT_FILE_PATH}"|" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf
perl -pi -e "s|"INPUT_LOG_TYPE"|"${INPUT_LOG_TYPE}"|g" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf
perl -pi -e "s|"OUTPUT_HDFS_SERVER"|"${OUTPUT_HDFS_SERVER}"|" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf
perl -pi -e "s|"OUTPUT_HDFS_PORT"|"${OUTPUT_HDFS_PORT}"|" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf
perl -pi -e "s|"OUTPUT_HDFS_USER"|"${OUTPUT_HDFS_USER}"|" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf
perl -pi -e "s|"OUTPUT_ENV"|"${OUTPUT_ENV}"|" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf
perl -pi -e "s|"OUTPUT_APPNAME"|"${OUTPUT_APPNAME}"|g" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf
perl -pi -e "s|"HOSTNAME"|"${HOSTNAME}"|" $CUR_DIR/logstash_${OUTPUT_APPNAME}_${HOSTNAME}.conf

if [[ -e "$DOCKER" && -s "$DOCKER" ]] ; then
   if [[ -e "$CUR_DIR/Dockerfile_Template" && -s "$CUR_DIR/Dockerfile_Template" ]] ; then
      cp $CUR_DIR/Dockerfile_Template $CUR_DIR/Dockerfile
      perl -pi -e "s|"LOGSTASH_CONFIG_TEMPLATE"|"${LOGSTASH_CONFIG_FILE}"|g" $CUR_DIR/Dockerfile
      cp $CUR_DIR/startLogstash_temp.sh  $CUR_DIR/startLogstash.sh
      perl -pi -e "s|"LOGSTASH_CONFIG_TEMPLATE"|"${LOGSTASH_CONFIG_FILE}"|g" $CUR_DIR/startLogstash.sh
      $DOCKER  build -t="logstash:v1" $CUR_DIR
      $DOCKER  create -i -t --name "$LOGSTASH_CONFIG_FILE" logstash:v1 /bin/bash 
      $DOCKER start $LOGSTASH_CONFIG_FILE
      $DOCKER exec -d $LOGSTASH_CONFIG_FILE  /opt/logstash/startLogstash.sh  
      #$DOCKER exec -itd $LOGSTASH_CONFIG_FILE  /opt/logstash/startLogstash.sh  
      #$DOCKER  run -i -t logstash:v1 /bin/bash 
      exit
   else
      echo "Dockerfile doesn't exist."
      exit
   fi
else
  echo "$DOCKER doesn't exist. Please make sure Docker is installed."
  exit
fi
