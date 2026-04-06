# ============================================================
# Lab Assignment 8 & 9 - Exercise 3
# TELNET over TCP — same topology as Q2, replace FTP with Telnet
# Telnet generates small interactive/bursty packets
# unlike FTP which sends large continuous bulk data
# ============================================================

# Step 0: Create Simulator and trace files
set ns [new Simulator]

set f [open out3.tr w]
$ns trace-all $f

set nf [open out3.nam w]
$ns namtrace-all $nf

# Step 1: Create Nodes
set n0 [$ns node]   ;# Telnet sender
set n1 [$ns node]   ;# intermediate router
set n2 [$ns node]   ;# Receiver

# Step 2: Create Links
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail

# Step 3: TCP Agent (n0 -> n2)
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink

$ns connect $tcp $sink

# Step 4: Telnet Application over TCP
# Telnet simulates interactive traffic (small bursty packets)
set telnet [new Application/Telnet]
$telnet attach-agent $tcp

# Step 5: Finish Procedure
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out3.nam &
    exit 0
}

# Step 6: Schedule Events
$ns at 0.5 "$telnet start"
$ns at 4.5 "$telnet stop"
$ns at 5.0 "finish"

# Step 7: Run Simulation
$ns run
