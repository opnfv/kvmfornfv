from __future__ import print_function
import glob, os
import csv
import json
import sys
import ast
import subprocess
from influxdb import InfluxDBClient

test_type=sys.argv[1]
results_dir=sys.argv[2]
time_stamp=sys.argv[3]

def publish_results(testtype):
    for file in glob.glob("*.csv"):
        print(file)
        f = open( file, 'r' )
        reader = csv.DictReader( f )
        result = json.dumps( [ row for row in reader ] )
        result = ast.literal_eval(result)
        print(result)

        for i in result:
            test = i['id'] + '_' +testtype
            json_body = [
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
            ]
            print(time_stamp)
            client = InfluxDBClient('10.10.100.20', 8086, 'admin', 'admin', 'packet_forwarding')
            client.switch_database('packet_forwarding')
            client.write_points(json_body)

os.chdir(results_dir)
publish_results(test_type)
