# ============================================================
# Lab Assignment 8 & 9 - Exercise 2
# FTP over TCP only — no UDP/CBR
# Node 0 = TCP/FTP sender (node 1 in question)
# Node 2 = Receiver       (node 6 in question)
# Only TCP + FTP traffic required
# ============================================================

# Step 0: Create Simulator and trace files
set ns [new Simulator]

set f [open out2.tr w]
$ns trace-all $f

set nf [open out2.nam w]
$ns namtrace-all $nf

# Step 1: Create Nodes
set n0 [$ns node]   ;# TCP/FTP sender
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

# Step 4: FTP Application over TCP
# FTP simulates bulk data transfer
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Step 5: Finish Procedure
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out2.nam &
    exit 0
}

# Step 6: Schedule Events
$ns at 0.5 "$ftp start"
$ns at 4.5 "$ftp stop"
$ns at 5.0 "finish"

# Step 7: Run Simulation
$ns run
