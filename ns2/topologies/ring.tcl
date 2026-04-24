# Ring Topology
set ns [new Simulator]

set f [open ring.tr w]
$ns trace-all $f
set nf [open ring.nam w]
$ns namtrace-all $nf

# Create 5 nodes
for {set i 0} {$i < 5} {incr i} {
    set n($i) [$ns node]
}

# Create links in a ring
$ns duplex-link $n(0) $n(1) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 2Mb 10ms DropTail
$ns duplex-link $n(3) $n(4) 2Mb 10ms DropTail
$ns duplex-link $n(4) $n(0) 2Mb 10ms DropTail

# Orient links for nam (roughly a circle)
$ns duplex-link-op $n(0) $n(1) orient right
$ns duplex-link-op $n(1) $n(2) orient down
$ns duplex-link-op $n(2) $n(3) orient left
$ns duplex-link-op $n(3) $n(4) orient up-left
$ns duplex-link-op $n(4) $n(0) orient up-right

# UDP Traffic from n(0) to n(2)
set udp [new Agent/UDP]
$ns attach-agent $n(0) $udp
set null [new Agent/Null]
$ns attach-agent $n(2) $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 1Mb

proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam ring.nam &
    exit 0
}

$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

$ns run
