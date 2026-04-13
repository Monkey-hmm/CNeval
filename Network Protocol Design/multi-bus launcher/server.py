import socket
import struct
import time

HOST = "0.0.0.0"
PORT = 9999
fleet = {}

FMT = "!I f f H B B"
SIZE = struct.calcsize(FMT)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((HOST, PORT))
print(f"Server listening on {PORT}...")

while True:
    data, addr = sock.recvfrom(1024)
    if len(data) < SIZE:
        continue

    bus_id, lat, lon, passengers, status, route_id = struct.unpack(FMT, data[:SIZE])
    received_at = time.time()

    fleet[bus_id] = {
        "route_id": route_id,
        "lat": round(lat, 5),
        "lon": round(lon, 5),
        "passengers": passengers,
        "doors_open": bool(status & 0b01),
        "engine_on": bool(status & 0b10),
        "last_seen": received_at,
    }

    print(
        f"Bus {bus_id:03d} | route={route_id} | "
        f"({fleet[bus_id]['lat']}, {fleet[bus_id]['lon']}) | "
        f"pax={passengers} | doors={'open' if fleet[bus_id]['doors_open'] else 'closed'} | "
        f"engine={'on' if fleet[bus_id]['engine_on'] else 'off'}"
    )
