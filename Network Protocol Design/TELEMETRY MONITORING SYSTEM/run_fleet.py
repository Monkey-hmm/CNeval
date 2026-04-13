import multiprocessing
import vehicle_client

VEHICLE_IDS = [1, 2, 3, 4, 5]

if __name__ == "__main__":
    procs = [multiprocessing.Process(target=vehicle_client.run_vehicle, args=(vid,)) for vid in VEHICLE_IDS]
    for p in procs:
        p.start()
    for p in procs:
        p.join()
