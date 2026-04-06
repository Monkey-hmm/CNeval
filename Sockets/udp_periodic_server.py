from socket import *
import time

PORT = 9004
CLIENT_TIMEOUT = 10

def handle(seq, payload, delay):
    print(f"Seq: {seq}  Payload: {payload}  Delay: {round(delay, 2)}s")

server = socket(AF_INET, SOCK_DGRAM)
server.bind(("", PORT))
server.settimeout(CLIENT_TIMEOUT)

print(f"UDP periodic server on port {PORT}")

last_seq = -1

while True:
    try:
        data, addr = server.recvfrom(4096)
        parts = data.decode().split(",", 2)
        seq = int(parts[0])
        ts = float(parts[1])
        payload = parts[2] if len(parts) > 2 else ""
        delay = time.time() - ts

        if last_seq != -1 and seq != last_seq + 1:
            print(f"Lost {seq - last_seq - 1} packet(s)")

        handle(seq, payload, delay)
        last_seq = seq

    except timeout:
        print("Client timed out")
        last_seq = -1
