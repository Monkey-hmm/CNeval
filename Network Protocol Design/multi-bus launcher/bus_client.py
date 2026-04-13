import socket
import struct
import time
import random
import sys

SERVER = ("127.0.0.1", 9999)
FMT = "!I f f H B B"

def run_bus(bus_id, route_id):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    lat, lon = 28.6139 + random.uniform(-0.1, 0.1), 77.2090 + random.uniform(-0.1, 0.1)

    print(f"Bus {bus_id} starting on route {route_id}")
    while True:
        lat += random.uniform(-0.001, 0.001)
        lon += random.uniform(-0.001, 0.001)
        passengers = random.randint(0, 60)
        doors_open = random.random() < 0.2
        engine_on = True
        status = (int(doors_open) & 0b01) | ((int(engine_on) << 1) & 0b10)

        pkt = struct.pack(FMT, bus_id, lat, lon, passengers, status, route_id)
        sock.sendto(pkt, SERVER)
        time.sleep(2)

if __name__ == "__main__":
    bus_id = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    route_id = int(sys.argv[2]) if len(sys.argv) > 2 else 42
    run_bus(bus_id, route_id)
