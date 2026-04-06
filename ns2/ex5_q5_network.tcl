# ============================================================
# Lab Assignment 8 & 9 - Exercise 5
# Network topology (from assignment diagram):
#   n0 (TCP/FTP sender)  --[2Mb]--> n2 (router)
#   n1 (UDP/CBR sender)  --[2Mb]--> n2 (router)
#   n2 (router)          --[2Mb]--> n3 (receiver)
#
# Trace file out5.tr is used for AWK analysis:
#   - Count received packets at node 2 and node 3
#   - Count dropped packets at node 2
#   - Calculate throughput
# ============================================================

# Step 0: Create Simulator and trace files
set ns [new Simulator]

set f [open out5.tr w]
$ns trace-all $f

set nf [open out5.nam w]
$ns namtrace-all $nf

# Step 1: Create Nodes
set n0 [$ns node]   ;# TCP/FTP sender
set n1 [$ns node]   ;# UDP/CBR sender
set n2 [$ns node]   ;# intermediate router / node 2
set n3 [$ns node]   ;# receiver / node 3

# Step 2: Create Links
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail

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
    exec nam out5.nam &
    exit 0
}

# Step 7: Schedule Events
$ns at 0.5 "$ftp start"
$ns at 1.0 "$cbr start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

# Step 8: Run Simulation
# After running, analyze out5.tr using AWK scripts:
#   awk -f count_packets.awk out5.tr
#   awk -f throughput.awk out5.tr
$ns run
