from socket import *
import time

HOST = "localhost"
PORT = 9004
COUNT = 10
INTERVAL = 1.0

def prepare(seq):
    return f"heartbeat-{seq}"

s = socket(AF_INET, SOCK_DGRAM)

for seq in range(COUNT):
    payload = prepare(seq)
    msg = f"{seq},{time.time()},{payload}"
    s.sendto(msg.encode(), (HOST, PORT))
    print(f"Sent seq={seq}")
    time.sleep(INTERVAL)

s.close()
print("Done")
