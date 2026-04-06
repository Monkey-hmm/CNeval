from socket import *
import threading

PORT = 9001

def handle(data):
    return data[::-1]

def client_thread(conn, addr):
    print(f"Connected: {addr}")
    try:
        while True:
            data = conn.recv(4096)
            if not data:
                break
            result = handle(data.decode())
            conn.send(result.encode())
    except ConnectionResetError:
        pass
    conn.close()
    print(f"Disconnected: {addr}")

server = socket(AF_INET, SOCK_STREAM)
server.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
server.bind(("", PORT))
server.listen(5)

print(f"TCP threaded server on port {PORT}")

while True:
    conn, addr = server.accept()
    threading.Thread(target=client_thread, args=(conn, addr), daemon=True).start()
