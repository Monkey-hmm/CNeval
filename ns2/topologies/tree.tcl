# Tree Topology
set ns [new Simulator]

set f [open tree.tr w]
$ns trace-all $f
set nf [open tree.nam w]
$ns namtrace-all $nf

# Create 7 nodes for a binary tree (depth 2)
for {set i 0} {$i < 7} {incr i} {
    set n($i) [$ns node]
}

# Create links for tree topology
# Level 0 to Level 1
$ns duplex-link $n(0) $n(1) 2Mb 10ms DropTail
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail

# Level 1 to Level 2
$ns duplex-link $n(1) $n(3) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(4) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(5) 2Mb 10ms DropTail
$ns duplex-link $n(2) $n(6) 2Mb 10ms DropTail

# Orient links for nam to show a tree structure
$ns duplex-link-op $n(0) $n(1) orient left-down
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(3) orient left-down
$ns duplex-link-op $n(1) $n(4) orient right-down
$ns duplex-link-op $n(2) $n(5) orient left-down
$ns duplex-link-op $n(2) $n(6) orient right-down

# UDP Traffic from n(3) (leaf) to n(6) (leaf)
set udp [new Agent/UDP]
$ns attach-agent $n(3) $udp
set null [new Agent/Null]
$ns attach-agent $n(6) $null
$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set rate_ 1Mb

proc finish {} {
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    exec nam tree.nam &
    exit 0
}

$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

$ns run
