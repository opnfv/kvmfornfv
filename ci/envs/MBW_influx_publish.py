from __future__ import print_function
import json
import ast
import sys
from influxdb import InfluxDBClient
import getopt
import datetime

def json_create():
#Json file containing measurement,fields,tags is created
    options, args = getopt.getopt(sys.argv[4:], 'r:w')
    read = []
    write = []
    json_body=[]
    time_stamp = datetime.datetime.strptime(sys.argv[2], "%Y-%m-%d-%H-%M-%S")
    for opt, arg in options:
        if opt in ('-w'):
            write = arg.split("\n")
        elif opt in ('-r'):
            read = arg.split("\n")

    for read_v,write_v in map(None,read,write):
        json_body.append(
            {
                "measurement": "kvmfornfv_cyclictest_" + sys.argv[1] + "_MBW",
                "tags": {
                    "id": "pcm data",
                },
                "time": time_stamp,
                "fields": {
                    "read_throughput": read_v,
                    "write_throughput": write_v,
                }
            }
        )
        time_stamp = time_stamp + datetime.timedelta(seconds=int(sys.argv[3]))
    return json_body

def influx_push(json_body):
# JSON is pushed into "yardstick" database of influxdb
    client = InfluxDBClient('104.197.68.199', 8086, 'opnfv', '0pnfv2015', 'yardstick')
    client.write_points(json_body)

influx_push(json_body=json_create())
