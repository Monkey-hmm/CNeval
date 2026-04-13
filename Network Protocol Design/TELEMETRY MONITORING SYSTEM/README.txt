================================================================
  REAL-TIME VEHICLE TELEMETRY MONITORING SYSTEM — UDP
================================================================

OVERVIEW
--------
A UDP-based fleet telemetry system where multiple vehicle clients
periodically transmit sensor data to a central management server.
The server maintains a real-time, in-memory snapshot of the latest
readings from every vehicle.

Files:
  server.py          — central fleet management server
  vehicle_client.py  — single vehicle telemetry client
  run_fleet.py       — launches all 5 vehicles simultaneously


================================================================
HOW TO RUN
================================================================

Requirements: Python 3.6+, no external libraries needed.

Step 1 — Start the server (Terminal 1):
  python server.py

Step 2 — Launch the full fleet (Terminal 2):
  python run_fleet.py

  OR launch a single vehicle manually:
  python vehicle_client.py <vehicle_id>
  e.g. python vehicle_client.py 3

The server will print a live log line for every packet received:
  V001 | seq=00042 | (28.61230, 77.20910) | 87.3 km/h | fuel=94.2% | temp=91C

To stop: Ctrl+C in each terminal.


================================================================
PACKET FORMAT
================================================================

Each packet is a fixed 22-byte binary struct, packed with Python's
struct module using format string: !I f f f f H I

  !  = big-endian (network byte order)
  I  = vehicle_id    (uint32, 4 bytes) — unique vehicle identifier
  f  = lat           (float32, 4 bytes) — GPS latitude
  f  = lon           (float32, 4 bytes) — GPS longitude
  f  = speed         (float32, 4 bytes) — speed in km/h
  f  = fuel          (float32, 4 bytes) — fuel level as percentage (0-100)
  H  = engine_temp   (uint16, 2 bytes)  — engine temperature in Celsius
  I  = seq           (uint32, 4 bytes)  — monotonic sequence number

Total: 22 bytes per packet.

Why binary struct?
  - Far smaller than JSON or CSV (a JSON equivalent would be ~120+ bytes)
  - Fixed-size makes parsing O(1) with no delimiter scanning
  - Network byte order (!) ensures consistent decoding across platforms
  - Efficient to produce and consume in both Python and C/embedded systems


================================================================
SERVER-SIDE LOGIC
================================================================

1. RECEIVE
   sock.recvfrom(1024) blocks until a UDP datagram arrives.
   The 1024-byte buffer is much larger than our 22-byte packet,
   leaving room for future field additions.

2. VALIDATE
   If len(data) < SIZE the packet is malformed and silently dropped.

3. UNPACK
   struct.unpack(FMT, data[:SIZE]) extracts all 7 fields in one call.

4. SEQUENCE GUARD (out-of-order protection)
   If the incoming seq number is not greater than the last stored seq
   for that vehicle, the packet is discarded. This prevents a delayed
   packet from overwriting fresher data already in the fleet dict.

5. UPSERT
   fleet[vid] = { lat, lon, speed, fuel, engine_temp, seq, last_seen }
   Only the latest snapshot per vehicle is kept in memory. The dict
   key is the vehicle_id, so lookups and updates are O(1).

6. LOG
   A formatted summary line is printed to stdout for every accepted
   packet, giving a live view of the fleet.


================================================================
THEORY — UDP COMMUNICATION
================================================================

WHY UDP?
  Telemetry is a continuous stream of small, time-sensitive readings.
  If a packet is lost, the next one arrives within seconds anyway —
  there is no value in retransmitting old sensor data. UDP is therefore
  a better fit than TCP for this use case because:
    - No connection setup overhead (no 3-way handshake)
    - No head-of-line blocking (a lost packet doesn't stall the stream)
    - Lower CPU and memory cost on embedded vehicle hardware
    - Naturally supports many clients sending to one server without
      managing per-client connection state

UDP TRADE-OFFS
  UDP provides no delivery guarantee, no ordering guarantee, and no
  duplicate detection. The system must handle all three explicitly.


================================================================
UDP CHALLENGES AND MITIGATION STRATEGIES
================================================================

1. PACKET LOSS
   Problem:
     UDP datagrams can be silently dropped at any network hop —
     router buffers fill, wireless links fade, switches discard
     during congestion. The sender never knows a packet was lost.

   Mitigation strategies (not implemented):
     a) Redundancy bursts — for each reading, the vehicle sends the
        same packet 2-3 times in rapid succession (~50ms apart).
        The server's sequence guard deduplicates them automatically.
        Triples bandwidth cost but drastically reduces effective loss.

     b) Critical-event retransmit — normal telemetry tolerates loss,
        but threshold alerts (fuel < 10%, temp > 105C) should be
        delivered reliably. The vehicle retries the alert packet every
        500ms on a separate thread until it receives a 1-byte ACK
        datagram back from the server.

     c) Staleness detection — server checks (now - last_seen) for
        each vehicle on a timer. If any vehicle has been silent for
        more than a configurable threshold (e.g. 10 seconds), it is
        flagged as potentially unreachable.

2. OUT-OF-ORDER DELIVERY
   Problem:
     Two packets sent 2 seconds apart may travel different network
     paths and arrive in reverse order. Without a guard, the older
     stale reading would overwrite the newer one in the fleet dict.

   Mitigation (partially implemented):
     The seq field is a monotonic counter incremented by the vehicle
     on every send. The server discards any packet whose seq is not
     strictly greater than the last accepted seq for that vehicle.
     This is a lightweight, stateless fix requiring only one integer
     comparison per packet.

   Additional strategy (not implemented):
     Include the vehicle's unix timestamp in the packet. The server
     can then log the latency (server_time - vehicle_time) and flag
     packets that are anomalously delayed, even if they pass the seq
     check (e.g. a vehicle reboots and resets its seq counter).

3. NO ACKNOWLEDGEMENT / DELIVERY CONFIRMATION
   Problem:
     Vehicles transmit blind — they have no way to know whether the
     server received a packet, whether the server is even running,
     or whether the network path is healthy.

   Mitigation strategies (not implemented):
     a) Heartbeat ACK — server sends a periodic 1-byte "alive" datagram
        back to each vehicle it has recently heard from. If a vehicle
        stops receiving heartbeats it can trigger a local alert or
        switch to a backup network interface.

     b) Sequence echo — server echoes the last accepted seq number
        back to each vehicle. The vehicle compares this to its own
        counter to estimate packet loss rate and dynamically increase
        transmission frequency when loss is high.

4. CLOCK DRIFT
   Problem:
     last_seen is stamped using the server's clock. If a vehicle's
     local RTC drifts significantly, comparing vehicle-side timestamps
     to server-side timestamps gives misleading latency figures.

   Mitigation (not implemented):
     Add a vehicle_ts (uint32 unix epoch) field to the packet. The
     server computes delta = server_time - vehicle_ts on receipt and
     flags any vehicle where abs(delta) > 5 seconds as having a
     clock sync problem. NTP on both server and vehicles is the
     simplest long-term fix.

5. BUFFER OVERFLOW / CONGESTION
   Problem:
     At high vehicle counts or short intervals, the server's UDP
     receive buffer can fill faster than the application reads it,
     causing the OS to drop datagrams before they reach recvfrom().

   Mitigation (not implemented):
     a) Increase the socket receive buffer:
          sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1<<20)
     b) Move packet processing to a worker thread so recvfrom() runs
        in a tight loop on its own thread, minimising buffer dwell time.
     c) Adaptive send rate — vehicles reduce transmission frequency
        during known congestion windows (e.g. urban peak hours).


================================================================
DATA FORMAT COMPARISON
================================================================

Format     Size (approx)   Parse cost   Human-readable
---------  --------------  -----------  ---------------
struct      22 bytes        O(1)         No
JSON       ~130 bytes       O(n)         Yes
CSV        ~80 bytes        O(n)         Yes
Protobuf   ~30 bytes        O(n)         No (with schema)

struct is chosen here for minimum bandwidth and maximum parse speed,
which matters on embedded hardware with limited CPU and cellular data.


================================================================
EXTENDING THE SYSTEM
================================================================

Add a field:
  1. Append the new type to FMT in both server.py and vehicle_client.py
  2. Update struct.unpack and struct.pack call signatures
  3. Add the field to the fleet dict upsert block

Dashboard:
  Replace the print() in server.py with a Flask/FastAPI endpoint that
  returns fleet as JSON. A simple HTML page polling /fleet every 2s
  gives a live browser dashboard with zero extra dependencies.

Persistence:
  After the fleet upsert, append the reading to a CSV or SQLite db
  for historical analysis and replay.

Alert engine:
  After upsert, check thresholds:
    if v['fuel'] < 10: send_alert(vid, 'low fuel')
    if v['engine_temp'] > 105: send_alert(vid, 'overheating')

================================================================
