# ============================================================
# NS2 — Solved Example Q1
# Six-node topology: A, B, C, D, E, F
#
# TOPOLOGY:
#   A ---[3Mb,10ms,DropTail]--- B
#   A ---[2Mb,25ms,RED]-------- F
#   C ---[5Mb, 7ms,DropTail]--- D   (question says FIFO → DropTail)
#   C ---[1Mb,30ms,DropTail]--- F
#   F ---[4Mb,12ms,DropTail]--- B   (question says FIFO → DropTail)
#   F ---[1.2Mb,18ms,RED]------ D
#   B ---[6Mb, 6ms,DropTail]--- E
#
# Traffic: TCP/FTP from A to E, UDP/CBR from C to E
# ============================================================

set ns [new Simulator]

set f  [open out_q1.tr  w]
set nf [open out_q1.nam w]
$ns trace-all    $f
$ns namtrace-all $nf

# --- Nodes ---
set nA [$ns node]
set nB [$ns node]
set nC [$ns node]
set nD [$ns node]
set nE [$ns node]
set nF [$ns node]

# --- Links (exact specs from question) ---
$ns duplex-link $nA $nB 3Mb   10ms DropTail
$ns duplex-link $nA $nF 2Mb   25ms RED
$ns duplex-link $nC $nD 5Mb    7ms DropTail
$ns duplex-link $nC $nF 1Mb   30ms DropTail
$ns duplex-link $nF $nB 4Mb   12ms DropTail
$ns duplex-link $nF $nD 1.2Mb 18ms RED
$ns duplex-link $nB $nE 6Mb    6ms DropTail

# --- NAM layout (optional visual positioning) ---
$ns duplex-link-op $nA $nB orient right
$ns duplex-link-op $nA $nF orient down
$ns duplex-link-op $nC $nD orient right
$ns duplex-link-op $nC $nF orient up-right
$ns duplex-link-op $nF $nB orient up-right
$ns duplex-link-op $nF $nD orient right
$ns duplex-link-op $nB $nE orient right

# --- TCP/FTP: A → E ---
set tcp  [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $nA $tcp
$ns attach-agent $nE $sink
$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

# --- UDP/CBR: C → E ---
set udp  [new Agent/UDP]
set null [new Agent/Null]
$ns attach-agent $nC $udp
$ns attach-agent $nE $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_     500k
$cbr set packetSize_ 512

# --- Finish ---
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out_q1.nam &
    exit 0
}

# --- Events ---
$ns at 0.5 "$ftp start"
$ns at 1.0 "$cbr start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

$ns run
