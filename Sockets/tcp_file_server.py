from socket import *
import os

PORT = 9002
SAVE_DIR = "uploads"

def on_receive(filename, data):
    os.makedirs(SAVE_DIR, exist_ok=True)
    path = os.path.join(SAVE_DIR, os.path.basename(filename))
    with open(path, "wb") as f:
        f.write(data)
    print(f"Saved: {path}")

server = socket(AF_INET, SOCK_STREAM)
server.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
server.bind(("", PORT))
server.listen(5)

print(f"TCP file server on port {PORT}")

while True:
    conn, addr = server.accept()
    header = b""
    while b"\n" not in header:
        header += conn.recv(1)
    filename = header.decode().strip()
    data = b""
    while True:
        chunk = conn.recv(4096)
        if not chunk:
            break
        data += chunk
    on_receive(filename, data)
    conn.close()
