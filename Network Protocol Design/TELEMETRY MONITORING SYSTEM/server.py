import socket
import struct
import time

HOST = "0.0.0.0"
PORT = 9999

# !I f f f f H I  →  vehicle_id, lat, lon, speed, fuel, engine_temp, seq
FMT = "!I f f f f H I"
SIZE = struct.calcsize(FMT)

fleet = {}

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((HOST, PORT))
print(f"Server listening on port {PORT}...")

while True:
    data, _ = sock.recvfrom(1024)
    if len(data) < SIZE:
        continue

    vid, lat, lon, speed, fuel, engine_temp, seq = struct.unpack(FMT, data[:SIZE])
    now = time.time()

    prev = fleet.get(vid)
    if prev and seq <= prev["seq"]:
        continue

    fleet[vid] = {
        "lat": round(lat, 5),
        "lon": round(lon, 5),
        "speed": round(speed, 1),
        "fuel": round(fuel, 1),
        "engine_temp": engine_temp,
        "seq": seq,
        "last_seen": now,
    }

    v = fleet[vid]
    print(
        f"V{vid:03d} | seq={seq:05d} | ({v['lat']}, {v['lon']}) | "
        f"{v['speed']} km/h | fuel={v['fuel']}% | temp={v['engine_temp']}C"
    )
