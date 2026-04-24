# Bus Topology
set ns [new Simulator]

set f [open bus.tr w]
$ns trace-all $f
set nf [open bus.nam w]
$ns namtrace-all $nf

# Create 5 nodes
for {set i 0} {$i < 5} {incr i} {
    set n($i) [$ns node]
}

# Create a LAN to simulate Bus Topology
# Syntax: $ns make-lan <node_list> <bandwidth> <delay> <queue_type> <mac_type> <channel_type>
set lan [$ns make-lan "$n(0) $n(1) $n(2) $n(3) $n(4)" 10Mb 10ms LL Queue/DropTail Mac/802_3 Channel]

# UDP Traffic from n(0) to n(4)
set udp [new Agent/UDP]
$ns attach-agent $n(0) $udp
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
    exec nam bus.nam &
    exit 0
}

$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

$ns run
