# ============================================================
# Lab Assignment 8 & 9 - Exercise 6
# Bottleneck / Congested Link Topology
#
#   n0 (TCP/FTP sender) --[2Mb, 10ms]--> n2 (router)
#   n1 (UDP/CBR sender) --[2Mb, 10ms]--> n2 (router)
#   n2 (router)         --[0.5Mb,20ms]--> n3 (receiver)  << BOTTLENECK
#
# The n2->n3 link is set to 0.5Mb — much lower than the
# incoming 2Mb links. This creates congestion at n2,
# causing packet drops and demonstrating TCP backoff vs
# UDP constant-rate behavior.
#
# AWK analysis on out6.tr:
#   - Total throughput on bottleneck link
#   - TCP-only throughput
#   - UDP-only throughput
#   - Average packet delay
# ============================================================

# Step 0: Create Simulator and trace files
set ns [new Simulator]

set f [open out6.tr w]
$ns trace-all $f

set nf [open out6.nam w]
$ns namtrace-all $nf

# Step 1: Create Nodes
set n0 [$ns node]   ;# TCP/FTP sender
set n1 [$ns node]   ;# UDP/CBR sender
set n2 [$ns node]   ;# Router (congestion point)
set n3 [$ns node]   ;# Receiver

# Step 2: Create Links
# Access links (high bandwidth)
$ns duplex-link $n0 $n2 2Mb  10ms DropTail
$ns duplex-link $n1 $n2 2Mb  10ms DropTail

# Bottleneck link — 0.5Mb forces congestion
# Combined demand (~1Mb TCP + 500k CBR) far exceeds 0.5Mb capacity
$ns duplex-link $n2 $n3 0.5Mb 20ms DropTail

# Step 3: TCP Agent (n0 -> n3)
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

$ns connect $tcp $sink

# Step 4: UDP Agent (n1 -> n3)
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp

set null [new Agent/Null]
$ns attach-agent $n3 $null

$ns connect $udp $null

# Step 5: Applications
set ftp [new Application/FTP]
$ftp attach-agent $tcp

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 500k

# Step 6: Finish Procedure
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out6.nam &
    exit 0
}

# Step 7: Schedule Events
$ns at 0.5 "$ftp start"
$ns at 1.0 "$cbr start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

# Step 8: Run Simulation
# After running, analyze out6.tr using:
#   awk -f total_throughput.awk  out6.tr
#   awk -f tcp_throughput.awk    out6.tr
#   awk -f udp_throughput.awk    out6.tr
#   awk -f delay.awk             out6.tr
$ns run
