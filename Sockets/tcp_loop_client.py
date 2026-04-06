from socket import *

HOST = "localhost"
PORT = 9001

def prepare():
    return input("Enter data: ")

s = socket(AF_INET, SOCK_STREAM)
s.connect((HOST, PORT))

while True:
    data = prepare()
    if data.lower() == "exit":
        break
    s.send(data.encode())
    reply = s.recv(4096).decode()
    print("Reply:", reply)

s.close()
