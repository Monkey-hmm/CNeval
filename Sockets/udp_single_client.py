from socket import *

HOST = "localhost"
PORT = 9003
TIMEOUT = 2

def prepare():
    return input("Enter data: ")

s = socket(AF_INET, SOCK_DGRAM)
s.settimeout(TIMEOUT)

data = prepare()
s.sendto(data.encode(), (HOST, PORT))

try:
    reply, _ = s.recvfrom(4096)
    print("Reply:", reply.decode())
except timeout:
    print("No reply (timed out)")

s.close()
