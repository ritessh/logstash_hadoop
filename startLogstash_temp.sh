#!/usr/bin/bash -i
LOGSTASH_HOME=/opt/logstash
cd $LOGSTASH_HOME
USE_JRUBY=1 bin/logstash agent -p . -f LOGSTASH_CONFIG_TEMPLATE.conf > $LOGSTASH_HOME/logstash.log &
#USE_JRUBY=1 $LOGSTASH_HOME/bin/logstash agent -p $LOGSTASH_HOME -f $LOGSTASH_HOME/LOGSTASH_CONFIG_TEMPLATE.conf >> logstash.log 2>&1  &
