from __future__ import print_function
import json
import ast
import sys
import datetime
import glob, os
import csv
import subprocess
from influxdb import InfluxDBClient

def influx_push(json_body):
# JSON is pushed into "yardstick" database of influxdb
    client = InfluxDBClient('104.197.68.199', 8086, 'opnfv', '0pnfv2015', 'yardstick')
    client.write_points(json_body)

def csv_json_create():
#Converts the CSV file to JSON
    for file in glob.glob("*.csv"):
        print(file)
        f = open( file, 'r' )
        reader = csv.DictReader( f )
        result = json.dumps( [ row for row in reader ] )
        result = ast.literal_eval(result)
        print(result)
        return result

def packetforwarding_publish():
#Function to publish packetforwarding logs into influxdb
    time_stamp=sys.argv[1]
    test_type=sys.argv[2]
    results_dir=sys.argv[3]
    result=csv_json_create()
    influx_push(json_body=pf_json(result,test_type))

def mbwInfo_publish():
#Function to publish Memory Bandwidth logs into influxdb
    test_type=sys.argv[1]
    results_dir=sys.argv[2]
    result=csv_json_create()
    influx_push(json_body=mbwInfo_json(result,test_type))

def pf_json(result,test_type):
#Creates a modified JSON of packetforwarding for influxdb
    json_body=[]
    for i in result:
        test = i['id'] + '_' +test_type
        json_body.append(
            {
                "measurement": test,
                "tags": {
                "id": i['id'],
                "type": i['type'],
                   "packet_size": i['packet_size']
                   },
                "time": time_stamp,
                "fields": {
                   "min_value": i['min_latency_ns'],
                   "avg_value": i['avg_latency_ns'],
                   "max_value": i['max_latency_ns']
                }
            }
        )
    return json_body

def mbwInfo_json(result,test_type):
#Creates a modified JSON of Memory Bandwidth for influxdb
    json_body=[]
    for i in result:
        json_body.append(
            {
                "measurement": "kvmfornfv_cyclictest_" + test_type +"_MBW",
                "tags": {
                    "id": "pcm data",
                },
                "time": i['Date']+"T"+i['Time']+"Z",
                "fields": {
                    "read_throughput": i['Read'],
                    "write_throughput": i['Write'],
                }
            }
        )
    return(json_body)

if (len(sys.argv) == 4):
    packetforwarding_publish()
else if (len(sys.argv) == 3):
    mbwInfo_publish
else:
    print("Error: No suitable test case name passed")
