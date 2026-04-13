import multiprocessing
import udp_client_template as client

# ── CONFIGURE ──────────────────────────────────────────────────────────────────

CLIENT_IDS = [1, 2, 3]   # one process per ID

# ── LAUNCHER (do not edit) ─────────────────────────────────────────────────────

if __name__ == "__main__":
    procs = [
        multiprocessing.Process(target=client.run_client, args=(cid,))
        for cid in CLIENT_IDS
    ]
    for p in procs:
        p.start()
    for p in procs:
        p.join()
