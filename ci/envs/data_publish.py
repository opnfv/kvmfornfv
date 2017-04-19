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

def csv_json_create(results_dir):
#Converts the CSV file to JSON
    os.chdir(results_dir)
    for file in glob.glob("*.csv"):
        print(file)
        f = open( file, 'r' )
        reader = csv.DictReader( f )
        result = json.dumps( [ row for row in reader ] )
        result = ast.literal_eval(result)
        return result

def packetforwarding_publish():
#Function to publish packetforwarding logs into influxdb
    results_dir=sys.argv[3]
    influx_push(json_body=pf_json(result=csv_json_create(results_dir)))

def mbwInfo_publish():
#Function to publish Memory Bandwidth logs into influxdb
    results_dir=sys.argv[2]
    influx_push(json_body=mbwInfo_json(result=csv_json_create(results_dir)))

def pf_json(result):
#Creates a modified JSON of packetforwarding for influxdb
    json_body=[]
    for i in result:
        test = i['id'] + '_' + sys.argv[2]
        json_body.append(
            {
                "measurement": test,
                "tags": {
                "id": i['id'],
                "type": i['type'],
                   "packet_size": i['packet_size']
                   },
                "time": sys.argv[1],
                "fields": {
                   "min_value": i['min_latency_ns'],
                   "avg_value": i['avg_latency_ns'],
                   "max_value": i['max_latency_ns']
                }
            }
        )
    print(json_body)
    return json_body

def mbwInfo_json(result):
#Creates a modified JSON of Memory Bandwidth for influxdb
    json_body=[]
    for i in result:
        json_body.append(
            {
                "measurement": "kvmfornfv_cyclictest_" + sys.argv[1] +"_MBW",
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
    print(json_body)
    return(json_body)

if (len(sys.argv) == 4):
    packetforwarding_publish()
else if (len(sys.argv) == 3):
    mbwInfo_publish()
else:
    print("Error: No suitable test case name passed")
