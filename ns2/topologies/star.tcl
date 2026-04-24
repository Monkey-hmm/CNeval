# Star Topology
set ns [new Simulator]

set f [open star.tr w]
$ns trace-all $f
set nf [open star.nam w]
$ns namtrace-all $nf

# Create 5 nodes
for {set i 0} {$i < 5} {incr i} {
    set n($i) [$ns node]
}

# n(0) is the central node
for {set i 1} {$i < 5} {incr i} {
    $ns duplex-link $n(0) $n($i) 2Mb 10ms DropTail
}

# Orient links for nam
$ns duplex-link-op $n(0) $n(1) orient left-up
$ns duplex-link-op $n(0) $n(2) orient right-up
$ns duplex-link-op $n(0) $n(3) orient left-down
$ns duplex-link-op $n(0) $n(4) orient right-down

# UDP Traffic from n(1) to n(4)
set udp [new Agent/UDP]
$ns attach-agent $n(1) $udp
set null [new Agent/Null]
$ns attach-agent $n(4) $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 1Mb

proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam star.nam &
    exit 0
}

$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

$ns run
