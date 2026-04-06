================================================================
  NS2 Lab Assignment 8 & 9  —  Scripts & Run Instructions
================================================================

ALL FILES
---------
ex1_q1_tcp_cbr.tcl      Q1 : TCP/FTP (n0) + CBR/UDP (n1) -> receiver (n2)
ex2_q2_ftp.tcl          Q2 : FTP over TCP only
ex3_q3_telnet.tcl       Q3 : Telnet over TCP (replace FTP with Telnet)
ex4_q4_ping.tcl         Q4 : Ping over 6-node linear chain
ex5_q5_network.tcl      Q5 : 4-node network, trace file analysis with AWK
ex6_q6_bottleneck.tcl   Q6 : Bottleneck link (0.5Mb) causing congestion

count_packets.awk       Q5 : Count recv/drop at node 2 and node 3
throughput.awk          Q5 : Throughput on each link (prints to terminal)
total_throughput.awk    Q6 : Total throughput on bottleneck link
tcp_throughput.awk      Q6 : TCP-only throughput on bottleneck
udp_throughput.awk      Q6 : UDP-only throughput on bottleneck
delay.awk               Q6 : Per-packet delay + average delay

================================================================
HOW TO RUN
================================================================

--- Run simulations ---
ns ex1_q1_tcp_cbr.tcl
ns ex2_q2_ftp.tcl
ns ex3_q3_telnet.tcl
ns ex4_q4_ping.tcl
ns ex5_q5_network.tcl
ns ex6_q6_bottleneck.tcl

--- Q5 AWK Analysis (uses out5.tr) ---
awk -f count_packets.awk out5.tr
awk -f throughput.awk    out5.tr

--- Q6 AWK Analysis (uses out6.tr) ---
awk -f total_throughput.awk out6.tr
awk -f tcp_throughput.awk   out6.tr
awk -f udp_throughput.awk   out6.tr
awk -f delay.awk            out6.tr

--- Save AWK output to a text file ---
awk -f delay.awk out6.tr > delay_result.txt

================================================================
TOPOLOGY SUMMARY
================================================================

Q1  n0(TCP/FTP) ---[2Mb]---> n2(receiver)
    n1(UDP/CBR) ---[2Mb]---> n2(receiver)
    Both senders share the receiver. FTP starts at 0.5s,
    CBR starts at 1.0s — different time events as required.

Q2  n0(TCP/FTP) --[2Mb]--> n1(router) --[2Mb]--> n2(receiver)
    Only FTP/TCP. No UDP. Observe bulk data transfer.

Q3  Same as Q2 but Telnet replaces FTP.
    Telnet = small bursty interactive packets vs FTP bulk.

Q4  n0--n1--n2--n3--n4--n5  (1Mb links, 10ms delay each)
    Ping sent from n0, echo reply from n5.
    RTT printed to console for each ping.

Q5  n0(TCP) ---[2Mb]--> n2(router) ---[2Mb]--> n3(receiver)
    n1(UDP) ---[2Mb]--> n2(router)
    AWK scripts analyze out5.tr for counts and throughput.

Q6  n0(TCP) ---[2Mb]--> n2(router) ---[0.5Mb BOTTLENECK]--> n3(receiver)
    n1(UDP) ---[2Mb]--> n2(router)
    0.5Mb bottleneck vs ~1.5Mb combined demand = congestion.
    TCP detects drops and reduces rate (congestion control).
    UDP ignores drops and keeps sending at 500k (unfair).

================================================================
TRACE FILE COLUMN REFERENCE
================================================================
$1  Event:  + enqueue | - dequeue | r receive | d drop
$2  Time (seconds)
$3  From node
$4  To node
$5  Packet type: tcp / cbr / ack
$6  Packet size (bytes)
$7  Flags
$8  Flow ID
$9  Source address (node.port)
$10 Destination address (node.port)
$11 Sequence number
$12 Packet unique ID
================================================================
