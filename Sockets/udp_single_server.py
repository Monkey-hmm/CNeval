from socket import *

PORT = 9003

def handle(data):
    return data.upper()

server = socket(AF_INET, SOCK_DGRAM)
server.bind(("", PORT))

print(f"UDP server on port {PORT}")

while True:
    data, addr = server.recvfrom(4096)
    result = handle(data.decode())
    server.sendto(result.encode(), addr)
