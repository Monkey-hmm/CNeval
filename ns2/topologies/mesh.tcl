# Mesh Topology
set ns [new Simulator]

set f [open mesh.tr w]
$ns trace-all $f
set nf [open mesh.nam w]
$ns namtrace-all $nf

# Create 4 nodes
for {set i 0} {$i < 4} {incr i} {
    set n($i) [$ns node]
}

# Fully connected mesh (4 nodes)
$ns duplex-link $n(0) $n(1) 2Mb 10ms DropTail
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(0) $n(3) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(3) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 2Mb 10ms DropTail

# Orient links for nam
$ns duplex-link-op $n(0) $n(1) orient right
$ns duplex-link-op $n(0) $n(2) orient down
$ns duplex-link-op $n(0) $n(3) orient right-down
$ns duplex-link-op $n(1) $n(2) orient left-down
$ns duplex-link-op $n(1) $n(3) orient down
$ns duplex-link-op $n(2) $n(3) orient right

# UDP Traffic from n(0) to n(3)
set udp [new Agent/UDP]
$ns attach-agent $n(0) $udp
set null [new Agent/Null]
$ns attach-agent $n(3) $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 1Mb

proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam mesh.nam &
    exit 0
}

$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

$ns run
