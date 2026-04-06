from socket import *

HOST = "localhost"
PORT = 9000

def prepare():
    return input("Enter data: ")

s = socket(AF_INET, SOCK_STREAM)
s.connect((HOST, PORT))

data = prepare()
s.send(data.encode())

reply = s.recv(4096).decode()
print("Reply:", reply)

s.close()
