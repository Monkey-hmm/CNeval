import multiprocessing
import bus_client

buses = [
    (1, 42),
    (2, 17),
    (3, 5),
]

if __name__ == "__main__":
    procs = [multiprocessing.Process(target=bus_client.run_bus, args=(bid, rid)) for bid, rid in buses]
    for p in procs:
        p.start()
    for p in procs:
        p.join()
