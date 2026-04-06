# AWK Script: Calculate throughput on each link
# Throughput = (total bytes received on link * 8) / simulation time  [Mbps]
# Usage: awk -f throughput.awk out5.tr

BEGIN {
    bytes_02 = 0
    bytes_12 = 0
    bytes_23 = 0
    sim_time = 5.0
}
{
    event   = $1
    from    = $3
    to      = $4
    pktsize = $6

    if (event == "r") {
        if (from == 0 && to == 2) bytes_02 += pktsize
        if (from == 1 && to == 2) bytes_12 += pktsize
        if (from == 2 && to == 3) bytes_23 += pktsize
    }
}
END {
    tp_02 = (bytes_02 * 8) / (sim_time * 1000000)
    tp_12 = (bytes_12 * 8) / (sim_time * 1000000)
    tp_23 = (bytes_23 * 8) / (sim_time * 1000000)

    print "Throughput on link n0->n2 : " tp_02 " Mbps"
    print "Throughput on link n1->n2 : " tp_12 " Mbps"
    print "Throughput on link n2->n3 : " tp_23 " Mbps"
}
