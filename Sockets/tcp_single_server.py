from socket import *

PORT = 9000

def handle(data):
    return data.upper()

server = socket(AF_INET, SOCK_STREAM)
server.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
server.bind(("", PORT))
server.listen(1)

print(f"TCP server on port {PORT}")

while True:
    conn, addr = server.accept()
    data = conn.recv(4096).decode()
    if data:
        result = handle(data)
        conn.send(result.encode())
    conn.close()
