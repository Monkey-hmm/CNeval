# AWK Script: Count received packets at node 2 and node 3,
#             and dropped packets at node 2
# Usage: awk -f count_packets.awk out5.tr

BEGIN {
    recv_n2 = 0
    recv_n3 = 0
    drop_n2 = 0
}
{
    event = $1
    from  = $3
    to    = $4

    if (event == "r" && to == 2) recv_n2++
    if (event == "r" && to == 3) recv_n3++
    if (event == "d" && from == 2) drop_n2++
}
END {
    print "Total packets received at node 2 : " recv_n2
    print "Total packets received at node 3 : " recv_n3
    print "Total packets dropped  at node 2 : " drop_n2
}
