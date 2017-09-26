from __future__ import print_function
import glob, os
import csv
import json
import sys
import ast
import subprocess
from influxdb import InfluxDBClient

time_stamp=sys.argv[1]
test_type=sys.argv[2]
results_dir=sys.argv[3]

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
                     "max_value": i['max_latency_ns'],
                     "throughput": i['throughput_rx_mbps']
                     }
                 }
            ]
            print(time_stamp)
            client = InfluxDBClient('104.197.68.199', 8086, 'opnfv', '0pnfv2015', 'yardstick')
            client.switch_database('yardstick')
            client.write_points(json_body)

os.chdir(results_dir)
publish_results(test_type)
