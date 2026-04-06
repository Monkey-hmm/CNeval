# ============================================================
# Lab Assignment 8 & 9 - Exercise 1
# TCP (FTP) from n0 to n2, CBR (UDP) from n1 to n2
# Node 0 = TCP sender (node 1 in question)
# Node 1 = UDP/CBR sender (node 3 in question)
# Node 2 = Receiver (node 5 in question)
# ============================================================

# Step 0: Create Simulator and trace files
set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f

set nf [open out.nam w]
$ns namtrace-all $nf

# Step 1: Create Nodes
set n0 [$ns node]   ;# TCP sender
set n1 [$ns node]   ;# UDP/CBR sender
set n2 [$ns node]   ;# Receiver

# Step 2: Create Links
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail

# Step 3: TCP Agent (n0 -> n2)
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink

$ns connect $tcp $sink

# Step 4: UDP Agent (n1 -> n2)
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp

set null [new Agent/Null]
$ns attach-agent $n2 $null

$ns connect $udp $null

# Step 5: Applications

# FTP over TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# CBR over UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 500k

# Step 6: Finish Procedure
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out.nam &
    exit 0
}

# Step 7: Schedule Events
# FTP and CBR start at different times as required
$ns at 0.5 "$ftp start"
$ns at 1.0 "$cbr start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

# Step 8: Run Simulation
$ns run
