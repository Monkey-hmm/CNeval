
Here are the three files — server, single bus client, and a multi-bus launcher:Now the architecture diagram:**Run it:**
```
# terminal 1
python server.py

# terminal 2 — spawns all 3 buses
python run_fleet.py
```

---

**Packet format — `struct "!I f f H B B"` = 14 bytes**

| Field | Type | Bytes | Notes |
|---|---|---|---|
| `bus_id` | `I` (uint32) | 4 | unique bus identifier |
| `lat` | `f` (float) | 4 | GPS latitude |
| `lon` | `f` (float) | 4 | GPS longitude |
| `passengers` | `H` (uint16) | 2 | 0–65535 |
| `status` | `B` (uint8) | 1 | bit 0 = doors, bit 1 = engine |
| `route_id` | `B` (uint8) | 1 | route number |

The `status` byte packs two booleans into a single byte using bitmasking (`0b01` for doors, `0b10` for engine), keeping the payload tiny.

---


