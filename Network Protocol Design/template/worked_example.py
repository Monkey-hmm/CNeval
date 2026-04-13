# ================================================================
#  WORKED EXAMPLE — Vehicle Telemetry (fills in the template)
#  Run this to see the template in action before writing your own.
# ================================================================

# ── server_example.py ─────────────────────────────────────────

SERVER_CODE = '''
import socket, struct, time

HOST, PORT = "0.0.0.0", 9999

PACKET_FIELDS = [
    ("client_id",    "I"),
    ("seq",          "I"),
    ("latitude",     "f"),
    ("longitude",    "f"),
    ("speed",        "f"),
    ("fuel",         "f"),
    ("engine_temp",  "H"),
]

FMT  = "!" + "".join(fc for _, fc in PACKET_FIELDS)
SIZE = struct.calcsize(FMT)
KEYS = [n for n, _ in PACKET_FIELDS]
store = {}

def _decode(data):
    if len(data) < SIZE: return None
    return dict(zip(KEYS, struct.unpack(FMT, data[:SIZE])))

def _is_stale(pkt):
    prev = store.get(pkt["client_id"])
    return prev is not None and pkt["seq"] <= prev["seq"]

def _store(pkt):
    pkt["_ts"] = time.time()
    store[pkt["client_id"]] = pkt

def on_packet(pkt, addr):
    cid = pkt["client_id"]
    print(
        f"V{cid:03d} | seq={pkt[\'seq\']:05d} | "
        f"({pkt[\'latitude\']:.4f}, {pkt[\'longitude\']:.4f}) | "
        f"{pkt[\'speed\']:.1f} km/h | fuel={pkt[\'fuel\']:.1f}% | "
        f"temp={pkt[\'engine_temp\']}C"
    )
    if pkt["fuel"] < 10:
        print(f"  !! V{cid:03d} LOW FUEL alert")
    if pkt["engine_temp"] > 105:
        print(f"  !! V{cid:03d} OVERHEAT alert")

def run_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((HOST, PORT))
    print(f"Server on {PORT}  |  {SIZE} bytes/packet")
    while True:
        data, addr = sock.recvfrom(4096)
        pkt = _decode(data)
        if pkt and not _is_stale(pkt):
            _store(pkt)
            on_packet(pkt, addr)

if __name__ == "__main__":
    run_server()
'''

# ── client_example.py ─────────────────────────────────────────

CLIENT_CODE = '''
import socket, struct, time, random, sys

SERVER = ("127.0.0.1", 9999)
SEND_INTERVAL = 2.0

PACKET_FIELDS = [
    ("client_id",    "I"),
    ("seq",          "I"),
    ("latitude",     "f"),
    ("longitude",    "f"),
    ("speed",        "f"),
    ("fuel",         "f"),
    ("engine_temp",  "H"),
]

FMT  = "!" + "".join(fc for _, fc in PACKET_FIELDS)
KEYS = [n for n, _ in PACKET_FIELDS]

def _encode(values):
    return struct.pack(FMT, *(values[k] for k in KEYS))

def init_state(client_id):
    return {
        "lat":  28.6139 + random.uniform(-0.5, 0.5),
        "lon":  77.2090 + random.uniform(-0.5, 0.5),
        "fuel": 100.0,
    }

def get_readings(client_id, seq, state):
    state["lat"]  += random.uniform(-0.001, 0.001)
    state["lon"]  += random.uniform(-0.001, 0.001)
    state["fuel"]  = max(0, state["fuel"] - random.uniform(0, 0.4))
    return {
        "latitude":    state["lat"],
        "longitude":   state["lon"],
        "speed":       random.uniform(0, 120),
        "fuel":        state["fuel"],
        "engine_temp": int(random.uniform(70, 110)),
    }

def run_client(client_id):
    sock  = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    seq   = 0
    state = init_state(client_id)
    print(f"Vehicle {client_id} started")
    while True:
        seq += 1
        r = get_readings(client_id, seq, state)
        r["client_id"] = client_id
        r["seq"]       = seq
        sock.sendto(_encode(r), SERVER)
        time.sleep(SEND_INTERVAL)

if __name__ == "__main__":
    cid = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    run_client(cid)
'''

print("Worked example source printed above.")
print("Copy SERVER_CODE -> server_example.py")
print("Copy CLIENT_CODE -> client_example.py")
print("Then: python server_example.py  /  python client_example.py 1")
