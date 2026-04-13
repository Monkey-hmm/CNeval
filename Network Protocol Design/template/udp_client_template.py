import socket
import struct
import time
import sys

# ── CONFIGURE ──────────────────────────────────────────────────────────────────

SERVER = ("127.0.0.1", 9999)
SEND_INTERVAL = 2.0   # seconds between transmissions

# Must match server PACKET_FIELDS exactly — same order, same types.
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
KEYS = [name for name, _ in PACKET_FIELDS]


def _encode(values: dict) -> bytes:
    return struct.pack(FMT, *(values[k] for k in KEYS))


def run_client(client_id: int):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    seq  = 0
    state = init_state(client_id)   # ← your initialisation runs here

    print(f"Client {client_id} started  →  {SERVER}")
    while True:
        seq += 1
        readings = get_readings(client_id, seq, state)  # ← your readings here
        readings["client_id"] = client_id
        readings["seq"]       = seq
        sock.sendto(_encode(readings), SERVER)
        time.sleep(SEND_INTERVAL)


# ── YOUR LOGIC (edit these two functions) ──────────────────────────────────────

def init_state(client_id: int) -> dict:
    """
    Return any mutable state your client needs across loop iterations.
    Examples: starting GPS position, initial fuel level, RNG seed, etc.
    Runs once before the send loop.
    """
    return {}   # replace with your initial state dict


def get_readings(client_id: int, seq: int, state: dict) -> dict:
    """
    Return a dict with a value for every field in PACKET_FIELDS
    (except client_id and seq — those are filled automatically).

    Update state in-place for values that evolve over time
    (e.g. drifting GPS, draining fuel).

    Example:
        state["lat"] += random.uniform(-0.001, 0.001)
        return {"latitude": state["lat"], ...}
    """
    # ── REPLACE WITH YOUR FIELD VALUES ──
    return {}


# ── ENTRY POINT ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    cid = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    run_client(cid)
