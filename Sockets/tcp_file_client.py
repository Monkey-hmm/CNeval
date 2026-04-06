from socket import *
import sys
import os

HOST = "localhost"
PORT = 9002

def get_file():
    path = sys.argv[1] if len(sys.argv) > 1 else input("Enter file path: ")
    name = os.path.basename(path)
    with open(path, "rb") as f:
        data = f.read()
    return name, data

s = socket(AF_INET, SOCK_STREAM)
s.connect((HOST, PORT))

name, data = get_file()
s.send((name + "\n").encode())
s.send(data)

s.close()
print(f"Uploaded: {name}")
