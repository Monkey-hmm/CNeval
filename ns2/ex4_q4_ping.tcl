# ============================================================
# Lab Assignment 8 & 9 - Exercise 4
# 6 nodes in a linear chain: n0--n1--n2--n3--n4--n5
# node(i) connected to node(i+1) with a duplex link
# Ping agent on n0, Ping responder on n5
#
# NOTE: Ping Agent concept —
#   Agent/Ping sends ICMP-like ping packets
#   The receiving node's Agent/Ping automatically replies
#   RTT is printed to console via the recv callback
# ============================================================

# Step 0: Create Simulator and trace files
set ns [new Simulator]

set f [open out4.tr w]
$ns trace-all $f

set nf [open out4.nam w]
$ns namtrace-all $nf

# Step 1: Create 6 Nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

# Step 2: Create Duplex Links — node(i) to node(i+1)
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n3 $n4 1Mb 10ms DropTail
$ns duplex-link $n4 $n5 1Mb 10ms DropTail

# Step 3: Ping Agent on n0 (sender)
set ping0 [new Agent/Ping]
$ns attach-agent $n0 $ping0

# Step 4: Ping Agent on n5 (responder)
set ping5 [new Agent/Ping]
$ns attach-agent $n5 $ping5

# Connect the two ping agents
$ns connect $ping0 $ping5

# When a reply arrives at n0, print RTT
$ping0 proc recv {from rtt} {
    puts "Ping reply from node $from: RTT = $rtt ms"
}

# Step 5: Finish Procedure
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out4.nam &
    exit 0
}

# Step 6: Schedule Ping sends at different times
$ns at 0.5 "$ping0 send"
$ns at 1.0 "$ping0 send"
$ns at 1.5 "$ping0 send"
$ns at 2.0 "$ping0 send"
$ns at 2.5 "$ping0 send"
$ns at 5.0 "finish"

# Step 7: Run Simulation
$ns run
