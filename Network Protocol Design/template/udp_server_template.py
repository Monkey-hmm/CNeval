import socket
import struct
import time

# ── CONFIGURE ──────────────────────────────────────────────────────────────────

HOST = "0.0.0.0"
PORT = 9999

# Define your packet layout here.
# Format chars: I=uint32 H=uint16 B=uint8 f=float32 i=int32
# Prefix with ! for network (big-endian) byte order.
# Each entry: (field_name, format_char)
PACKET_FIELDS = [
    ("client_id",  "I"),
    ("seq",        "I"),
    # ── ADD YOUR FIELDS BELOW ──
    # ("latitude",   "f"),
    # ("longitude",  "f"),
    # ("speed",      "f"),
    # ("fuel",       "f"),
    # ("temperature","H"),
]

# ── NETWORKING CORE (do not edit) ──────────────────────────────────────────────

FMT  = "!" + "".join(fc for _, fc in PACKET_FIELDS)
SIZE = struct.calcsize(FMT)
KEYS = [name for name, _ in PACKET_FIELDS]

store = {}   # client_id -> latest decoded packet dict


def _decode(data: bytes) -> dict | None:
    if len(data) < SIZE:
        return None
    values = struct.unpack(FMT, data[:SIZE])
    return dict(zip(KEYS, values))


def _is_stale(pkt: dict) -> bool:
    prev = store.get(pkt["client_id"])
    return prev is not None and pkt["seq"] <= prev["seq"]


def _store(pkt: dict):
    pkt["_ts"] = time.time()
    store[pkt["client_id"]] = pkt


def run_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((HOST, PORT))
    print(f"Server listening on {HOST}:{PORT}  |  packet size = {SIZE} bytes")

    while True:
        data, addr = sock.recvfrom(4096)
        pkt = _decode(data)
        if pkt is None:
            continue
        if _is_stale(pkt):
            continue
        _store(pkt)
        on_packet(pkt, addr)   # ← your logic runs here


# ── YOUR LOGIC (edit this) ─────────────────────────────────────────────────────

def on_packet(pkt: dict, addr: tuple):
    """
    Called once per accepted, decoded, in-order packet.

    pkt  — dict of all PACKET_FIELDS values plus '_ts' (server receive time)
    addr — (ip, port) of the sender

    Print, alert, aggregate, write to DB — anything you need.
    """
    cid = pkt["client_id"]
    seq = pkt["seq"]
    # ── REPLACE THE LINE BELOW WITH YOUR DISPLAY / ALERT LOGIC ──
    print(f"[{cid:03d}] seq={seq:05d} | {pkt}")


# ── ENTRY POINT ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    run_server()
