# ============================================================
# NS2 — Solved Example Q2
# Six-node topology: A, B, C, D, E, F
#
# TOPOLOGY:
#   A ---[5Mb,100ms,RED]--- C
#   C ---[4Mb, 50ms,FIFO/DropTail]--- D
#   D ---[1Mb, 80ms,DropTail]--- E
#   E ---[10Mb,15ms,FIFO/DropTail]--- F  (F-E reversed = same duplex)
#   B ---[6Mb,120ms,RED]--- C
#
# NOTES:
#   "FIFO" in a question = DropTail in NS2 syntax
#   Nodes D and E are connected in a chain → natural bottleneck at D-E (1Mb)
#   RED on A-C and B-C provides early congestion signalling
#
# Traffic: TCP/FTP from A to E, TCP/Telnet from B to F
# ============================================================

set ns [new Simulator]

set f  [open out_q2.tr  w]
set nf [open out_q2.nam w]
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
# FIFO in question = DropTail in NS2
$ns duplex-link $nA $nC 5Mb  100ms RED
$ns duplex-link $nC $nD 4Mb   50ms DropTail
$ns duplex-link $nD $nE 1Mb   80ms DropTail
$ns duplex-link $nF $nE 10Mb  15ms DropTail
$ns duplex-link $nB $nC 6Mb  120ms RED

# --- NAM layout ---
$ns duplex-link-op $nA $nC orient right
$ns duplex-link-op $nB $nC orient down-right
$ns duplex-link-op $nC $nD orient right
$ns duplex-link-op $nD $nE orient right
$ns duplex-link-op $nF $nE orient left

# --- Traffic Pair 1: TCP/FTP  A → E ---
set tcp0  [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns attach-agent $nA $tcp0
$ns attach-agent $nE $sink0
$ns connect $tcp0 $sink0

set ftp [new Application/FTP]
$ftp attach-agent $tcp0

# --- Traffic Pair 2: TCP/Telnet  B → F ---
set tcp1  [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns attach-agent $nB $tcp1
$ns attach-agent $nF $sink1
$ns connect $tcp1 $sink1

set telnet [new Application/Telnet]
$telnet attach-agent $tcp1

# --- Finish ---
proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam out_q2.nam &
    exit 0
}

# --- Events ---
$ns at 0.5 "$ftp    start"
$ns at 1.0 "$telnet start"
$ns at 4.0 "$ftp    stop"
$ns at 4.5 "$telnet stop"
$ns at 5.0 "finish"

$ns run
