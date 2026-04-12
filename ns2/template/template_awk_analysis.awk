# ============================================================
# AWK TEMPLATE — Custom Topology Analysis
# ============================================================
# Covers the four most commonly asked AWK tasks in NS2 labs:
#   1. Count received / dropped packets at a specific node
#   2. Per-link throughput
#   3. Total throughput on any link
#   4. Average end-to-end delay
#
# HOW TO USE:
#   Save this as my_analysis.awk (or split into separate files)
#   Run: awk -f my_analysis.awk out_topology.tr
#
# EDIT THE FILTER VALUES BELOW to match your trace file nodes.
# ============================================================

# ============================================================
# TASK 1 — Count received & dropped packets at specific nodes
# EDIT: Change the node numbers in the conditions below.
#       NS2 numbers nodes 0,1,2,3... in the order you created them.
#       If nA was first → node 0, nB → node 1, nC → node 2, etc.
# ============================================================
# Usage: awk -f count_packets.awk out_topology.tr

BEGIN {
    recv_n2  = 0
    recv_n3  = 0
    drop_n2  = 0
}

{
    event = $1   # r=receive, d=drop, +=enqueue, -=dequeue
    to    = $4   # destination node number

    # EDIT node numbers to match your topology
    if (event == "r" && to == 2) recv_n2++
    if (event == "r" && to == 3) recv_n3++
    if (event == "d" && to == 2) drop_n2++
}

END {
    print "Packets received at node 2 : " recv_n2
    print "Packets received at node 3 : " recv_n3
    print "Packets dropped  at node 2 : " drop_n2
}


# ============================================================
# TASK 2 — Per-link throughput
# Measures bytes received on each link and converts to Kbps.
# EDIT: Add or remove link pairs to match your topology.
# ============================================================
# Usage: awk -f throughput.awk out_topology.tr

BEGIN {
    bytes_01 = 0   # link node0 → node1
    bytes_12 = 0   # link node1 → node2
    bytes_23 = 0   # link node2 → node3
    sim_end  = 5.0  # EDIT: match your simulation end time
}

{
    if ($1 == "r") {
        from  = $3
        to    = $4
        bytes = $6

        # EDIT these pairs to match your links
        if (from == 0 && to == 1) bytes_01 += bytes
        if (from == 1 && to == 2) bytes_12 += bytes
        if (from == 2 && to == 3) bytes_23 += bytes
    }
}

END {
    print "Throughput link 0-1 : " (bytes_01 * 8) / (sim_end * 1000) " Kbps"
    print "Throughput link 1-2 : " (bytes_12 * 8) / (sim_end * 1000) " Kbps"
    print "Throughput link 2-3 : " (bytes_23 * 8) / (sim_end * 1000) " Kbps"
}


# ============================================================
# TASK 3 — Total throughput on a single (bottleneck) link
# EDIT: Change the from/to node numbers for your bottleneck link.
# ============================================================
# Usage: awk -f total_throughput.awk out_topology.tr

BEGIN {
    total_bytes = 0
    sim_end     = 5.0   # EDIT: match simulation end time
    link_from   = 2     # EDIT: source node of link to measure
    link_to     = 3     # EDIT: dest   node of link to measure
}

{
    if ($1 == "r" && $3 == link_from && $4 == link_to) {
        total_bytes += $6
    }
}

END {
    throughput_kbps = (total_bytes * 8) / (sim_end * 1000)
    print "Total throughput on link " link_from "-" link_to " : " throughput_kbps " Kbps"
}


# ============================================================
# TASK 4 — Average end-to-end delay
# Tracks enqueue time of each packet by unique ID,
# then calculates delay when the packet is received at dest.
# EDIT: Change dest_node to your receiver node number.
# ============================================================
# Usage: awk -f delay.awk out_topology.tr

BEGIN {
    total_delay  = 0
    packet_count = 0
    dest_node    = 3    # EDIT: receiver node number
}

{
    event     = $1
    time      = $2
    from      = $3
    to        = $4
    pkt_id    = $12   # unique packet ID (column 12)

    if (event == "+" && from == 0) {
        # Record send time when packet is enqueued at source
        # EDIT from == 0 to match your source node
        send_time[pkt_id] = time
    }

    if (event == "r" && to == dest_node) {
        if (pkt_id in send_time) {
            delay = time - send_time[pkt_id]
            total_delay  += delay
            packet_count++
            printf "Packet %d  delay = %.6f s\n", pkt_id, delay
        }
    }
}

END {
    if (packet_count > 0)
        printf "\nAverage delay : %.6f s  (%d packets)\n",
               total_delay / packet_count, packet_count
    else
        print "No packets received at destination node " dest_node
}
