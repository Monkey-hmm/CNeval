# ============================================================
# NS2 TEMPLATE — Custom Multi-Node Topology
# ============================================================
# USE THIS TEMPLATE FOR QUESTIONS THAT:
#   - Give you N nodes (A, B, C, ...)
#   - Give you a list of links with bandwidth, delay, queue type
#   - Ask you to "design", "illustrate", or "simulate" the topology
#   - May ask about packet counts, throughput, or delay (use AWK)
#
# HOW TO ADAPT:
#   STEP 1 — Change SIM_NAME to match your question number
#   STEP 2 — Change NUM_NODES to however many nodes the question gives
#   STEP 3 — Replace the node variable names (nA, nB, ...) to match the question
#   STEP 4 — Replace the links section with the exact specs from the question
#   STEP 5 — Add/remove traffic agents to match what is being tested
#   STEP 6 — Adjust simulation start/stop times if needed
#
# QUEUE TYPE REFERENCE (copy-paste the exact NS2 spelling):
#   DropTail   — standard FIFO with tail drop (most common)
#   RED        — Random Early Detection (congestion avoidance)
#   FQ         — Fair Queuing
#   CBQ        — Class-Based Queuing
#   Note: "FIFO" in a question means DropTail in NS2 syntax
#         Questions that say FIFO → use DropTail
# ============================================================

# ============================================================
# SECTION 0 — Simulation name (change for each question)
# ============================================================
# EDIT: Change "topology" to your question label, e.g. "q1", "q7" etc.
set SIM_NAME "topology"

set ns [new Simulator]

# --- Trace files (named after SIM_NAME automatically) ---
set TRACE_FILE "out_${SIM_NAME}.tr"
set NAM_FILE   "out_${SIM_NAME}.nam"

set f  [open $TRACE_FILE w]
set nf [open $NAM_FILE   w]
$ns trace-all    $f
$ns namtrace-all $nf

# ============================================================
# SECTION 1 — Node Creation
# EDIT: Add or remove nodes to match the question.
#       Rename variables to reflect node labels (nA, nB, nC …)
# ============================================================
# Example: question gives nodes A, B, C, D, E, F  →  6 nodes
set nA [$ns node]   ;# Node A
set nB [$ns node]   ;# Node B
set nC [$ns node]   ;# Node C
set nD [$ns node]   ;# Node D
set nE [$ns node]   ;# Node E
set nF [$ns node]   ;# Node F

# ============================================================
# SECTION 2 — Link Creation
# Syntax: $ns duplex-link <node1> <node2> <BW> <delay> <queue>
# EDIT: Replace each line with the exact link specs from the question.
#       If the question gives a one-way (simplex) link use:
#         $ns simplex-link <node1> <node2> <BW> <delay> <queue>
#       If question says FIFO → use DropTail
# ============================================================
# --- EXAMPLE: from the first sample question ---
# Link A-B: 3 Mb, 10 ms, DropTail
$ns duplex-link $nA $nB 3Mb  10ms DropTail

# Link A-F: 2 Mb, 25 ms, RED
$ns duplex-link $nA $nF 2Mb  25ms RED

# Link C-D: 5 Mb,  7 ms, FIFO (DropTail in NS2)
$ns duplex-link $nC $nD 5Mb   7ms DropTail

# Link C-F: 1 Mb, 30 ms, DropTail
$ns duplex-link $nC $nF 1Mb  30ms DropTail

# Link F-B: 4 Mb, 12 ms, FIFO (DropTail in NS2)
$ns duplex-link $nF $nB 4Mb  12ms DropTail

# Link F-D: 1.2 Mb, 18 ms, RED
$ns duplex-link $nF $nD 1.2Mb 18ms RED

# Link B-E: 6 Mb,  6 ms, DropTail
$ns duplex-link $nB $nE 6Mb   6ms DropTail

# ============================================================
# SECTION 3 — Optional: NAM Layout Hints
# These position nodes nicely in the NAM visualiser window.
# EDIT: Adjust x/y coordinates to match your drawn topology.
#       You can skip this section entirely — it only affects visuals.
# ============================================================
$ns duplex-link-op $nA $nB orient right
$ns duplex-link-op $nA $nF orient down
$ns duplex-link-op $nC $nD orient right
$ns duplex-link-op $nC $nF orient up-right
$ns duplex-link-op $nF $nB orient up-right
$ns duplex-link-op $nF $nD orient right
$ns duplex-link-op $nB $nE orient right

# ============================================================
# SECTION 4 — Traffic Agents
# EDIT: Choose the traffic pattern that the question asks about.
#       Common patterns shown below — comment out the ones you don't need.
#
# SENDER TYPES:
#   TCP  + FTP  → bulk data transfer (large file)
#   TCP  + Telnet → bursty interactive traffic
#   UDP  + CBR  → constant bitrate stream
#   PING (ICMPAgent) → round-trip time measurement
#
# PICK source and destination nodes from Section 1.
# ============================================================

# --- Traffic Pair 1: TCP/FTP  (nA → nE, as an example) ---
set tcp0  [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $nA $tcp0
$ns attach-agent $nE $sink0
$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# --- Traffic Pair 2: UDP/CBR  (nC → nE, as an example) ---
set udp0  [new Agent/UDP]
set null0 [new Agent/Null]
$ns attach-agent $nC $udp0
$ns attach-agent $nE $null0
$ns connect $udp0 $null0

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set rate_     500k   ;# EDIT: change CBR rate to suit question
$cbr0 set packetSize_ 512  ;# EDIT: optional — set packet size in bytes

# ============================================================
# SECTION 5 — Finish Procedure (do not change)
# ============================================================
proc finish {} {
    global ns f nf NAM_FILE
    $ns flush-trace
    close $f
    close $nf
    exec nam $NAM_FILE &
    exit 0
}

# ============================================================
# SECTION 6 — Event Schedule
# EDIT: Adjust start/stop times and add more events as needed.
#       General rule — stop traffic before the finish time.
# ============================================================
$ns at 0.5  "$ftp0 start"
$ns at 1.0  "$cbr0 start"
$ns at 4.0  "$ftp0 stop"
$ns at 4.5  "$cbr0 stop"
$ns at 5.0  "finish"        ;# EDIT: increase for longer simulations

# ============================================================
# SECTION 7 — Run
# ============================================================
$ns run

# ============================================================
# AFTER RUNNING — AWK Analysis commands
# (un-comment the ones you need)
# ============================================================
# awk -f count_packets.awk   out_topology.tr
# awk -f throughput.awk      out_topology.tr
# awk -f total_throughput.awk out_topology.tr
# awk -f tcp_throughput.awk  out_topology.tr
# awk -f udp_throughput.awk  out_topology.tr
# awk -f delay.awk           out_topology.tr
