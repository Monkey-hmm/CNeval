import socket
import struct
import time
import random
import sys

SERVER = ("127.0.0.1", 9999)
FMT = "!I f f f f H I"

def run_vehicle(vehicle_id):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    lat = 28.6139 + random.uniform(-0.5, 0.5)
    lon = 77.2090 + random.uniform(-0.5, 0.5)
    fuel = 100.0
    seq = 0

    print(f"Vehicle {vehicle_id} started")
    while True:
        lat += random.uniform(-0.001, 0.001)
        lon += random.uniform(-0.001, 0.001)
        speed = random.uniform(0, 120)
        fuel = max(0, fuel - random.uniform(0, 0.5))
        engine_temp = int(random.uniform(70, 110))
        seq += 1

        pkt = struct.pack(FMT, vehicle_id, lat, lon, speed, fuel, engine_temp, seq)
        sock.sendto(pkt, SERVER)
        time.sleep(2)

if __name__ == "__main__":
    vid = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    run_vehicle(vid)
