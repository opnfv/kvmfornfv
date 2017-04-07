from __future__ import print_function
import json
import ast
import sys
from influxdb import InfluxDBClient
import getopt
import datetime

def json_create():
#Json containing measurement,fields,tags is created
    options, args = getopt.getopt(sys.argv[4:], 'r:w:m:')
    read = []
    write = []
    memory = []
    json_body=[]
    time_stamp = datetime.datetime.strptime(sys.argv[2], "%Y-%m-%d-%H-%M-%S")
    for opt, arg in options:
        if opt in ('-w'):
            write = arg.split("\n")
        elif opt in ('-r'):
            read = arg.split("\n")
        elif opt in ('-m'):
            memory = arg.split("\n")

    for read_v,memory_v,write_v in map(None,read,memory,write):
        json_body.append(
            {
                "measurement": sys.argv[1] + "_MBW",
                "tags": {
                    "id": "pcm data",
                },
                "time": time_stamp,
                "fields": {
                    "read_throughput": read_v,
                    "write_throughput": write_v,
                    "memory_throughput": memory_v,
                }
            }
        )
        time_stamp = time_stamp + datetime.timedelta(seconds=int(sys.argv[3]))
    return json_body

def influx_push(json_body):
# JSON is pushed into "memory_bandwidth" database of influxdb
    print(json_body)
    client = InfluxDBClient('10.10.100.20', 8086, 'admin', 'admin', 'PCM')
    client.switch_database('PCM')
    client.write_points(json_body)
    print(client.query('select * from memorystress_MBW'))

influx_push(json_body=json_create())
