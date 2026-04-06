# AWK Script: TCP-only throughput on bottleneck link (n2 -> n3)
# Filters by packet type "tcp"
# Usage: awk -f tcp_throughput.awk out6.tr

BEGIN {
    bytes  = 0
    t_prev = 0
    window = 0.5
    print "Time(s)\t\tTCP Throughput(Mbps)"
}
{
    event   = $1
    time    = $2
    from    = $3
    to      = $4
    pkttype = $5
    pktsize = $6

    if (event == "r" && from == 2 && to == 3 && pkttype == "tcp") {
        bytes += pktsize
    }

    if (time - t_prev >= window) {
        throughput = (bytes * 8) / (window * 1000000)
        printf "%f\t%f\n", time, throughput
        bytes  = 0
        t_prev = time
    }
}
END {
    print "---"
    print "TCP-only throughput on bottleneck n2->n3"
}
