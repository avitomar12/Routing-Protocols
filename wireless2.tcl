
#
# wireless2.tcl
# simulation of a wired-cum-wireless scenario consisting of 2 wired nodes
# connected to a wireless domain through a base-station node.
# ======================================================================
# Define options
# ======================================================================
set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy            ;# network interface type
set opt(mac)            Mac/802_11                 ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50                         ;# max packet in ifq
set opt(nn)             3                          ;# number of mobilenodes
set opt(adhocRouting)   DSDV                       ;# routing protocol

set opt(cp)             ""                         ;# connection pattern file
set opt(sc)     "/home/avi/Documents/Curaj/3rdSem/project/scen-3-test"    ;# node movement file. 

set opt(x)      670                            ;# x coordinate of topology
set opt(y)      670                            ;# y coordinate of topology
set opt(seed)   0.0                            ;# seed for random number gen.
set opt(stop)   250                            ;# time to stop simulation

set opt(ftp1-start)      160.0                 ;#start time of communication1
set opt(ftp2-start)      170.0                 ;#start time of communication1

set num_wired_nodes      10                    ;# Number of Wired node
set num_bs_nodes         1                     ; #Number of Base Station

# ============================================================================
# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical
AddrParams set domain_num_ 2           ;# number of domains
lappend cluster_num 2 1                ;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 5 5 4              ;# number of nodes in each cluster 
AddrParams set nodes_num_ $eilastlevel ;# of each domain

set tracefd  [open wireless2-out.tr w]
set namtrace [open wireless2-out.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)

# create God
create-god [expr $opt(nn) + $num_bs_nodes]

#create wired nodes
set temp {0.0.0 0.0.1 0.0.2 0.0.3 0.0.4 0.1.0 0.1.1 0.1.2 0.1.3 0.1.4}        ;# hierarchical addresses for wired domain
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns_ node [lindex $temp $i]] 
    $W($i) color green
    

}

# configure for base-station node
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF 

#create base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3}   ;# hier address to be used for wireless
                                     ;# domain
set BS(0) [$ns_ node [lindex $temp 0]]
$BS(0) random-motion 0               ;# disable random motion
$BS(0) color red
#provide some co-ord (fixed) to base station node


# create mobilenodes in the same domain as BS(0)  
# note the position and movement of mobilenodes is as defined
# in $opt(sc)

#configure for mobilenodes
$ns_ node-config -wiredRouting OFF

  for {set j 0} {$j < $opt(nn)} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp \
	    [expr $j+1]] ]

    $node_($j) base-station [AddrParams addr2id \
	    [$BS(0) node-addr]]
$node_($j) color blue
        
}
$W(0) set X_ 100
$W(0) set Y_ 100
$W(0) set Z_ 0
$W(1) set X_ 200
$W(1) set Y_ 100
$W(1) set Z_ 0
$W(2) set X_ 300
$W(2) set Y_ 100
$W(2) set Z_ 0
$W(3) set X_ 400
$W(3) set Y_ 100
$W(3) set Z_ 0
$W(4) set X_ 150
$W(4) set Y_ 150
$W(4) set Z_ 0
$W(5) set X_ 300
$W(5) set Y_ 150
$W(5) set Z_ 0
$W(6) set X_ 300
$W(6) set Y_ 200
$W(6) set Z_ 0
$W(7) set X_ 300
$W(7) set Y_ 400
$W(7) set Z_ 0
$W(8) set X_ 300
$W(8) set Y_ 600
$W(8) set Z_ 0
$W(9) set X_ 300
$W(9) set Y_ 30
$W(9) set Z_ 0

#create links between wired and BS nodes

$ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail 
$ns_ duplex-link $W(1) $BS(0) 5Mb 2ms DropTail
$ns_ duplex-link $W(5) $W(2) 2Mb 2ms DropTail
$ns_ duplex-link $W(2) $W(3) 2Mb 2ms DropTail
$ns_ duplex-link $W(2) $W(4) 2Mb 2ms DropTail
$ns_ duplex-link $W(4) $W(7) 2Mb 2ms DropTail
$ns_ duplex-link $W(4) $W(8) 2Mb 2ms DropTail
$ns_ duplex-link $W(3) $W(4) 5Mb 2ms DropTail
$ns_ duplex-link $W(6) $W(3) 1.5Mb 10ms DropTail
$ns_ duplex-link $W(1) $W(3) 5Mb 2ms DropTail


# setup TCP connections
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $W(0) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at $opt(ftp1-start) "$ftp1 start"

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $W(1) $tcp2
$ns_ attach-agent $node_(2) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at $opt(ftp2-start) "$ftp2 start"

set tcp3 [new Agent/TCP]
$tcp3 set class_ 2
set sink3 [new Agent/TCPSink]
$ns_ attach-agent $W(3) $tcp3
$ns_ attach-agent $node_(1) $sink3
$ns_ connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns_ at 45.0 "$ftp3 start"

set tcp3 [new Agent/TCP]
$tcp3 set class_ 2
set sink3 [new Agent/TCPSink]
$ns_ attach-agent $W(2) $tcp3
$ns_ attach-agent $node_(1) $sink3
$ns_ connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns_ at 2.0 "$ftp3 start"


# source connection-pattern and node-movement scripts
#if { $opt(cp) == "" } {
#	puts "*** NOTE: no connection pattern specified."
 #       set opt(cp) "none"
#} else {
#	puts "Loading connection pattern..."
#	source $opt(cp)
#}
#if { $opt(sc) == "" } {
#	puts "*** NOTE: no scenario file specified."
#        set opt(sc) "none"
#} else {
#	puts "Loading scenario file..."
#	source $opt(sc)
#	puts "Load complete..."
#}
set god_ [God instance]
$ns_ at 50.000000000000 "$node_(2) setdest 369.463244915743 170.519203111152 3.371785899154"
$ns_ at 51.000000000000 "$node_(1) setdest 221.826585497093 80.855495003839 14.909259208114"
$ns_ at 33.000000000000 "$node_(0) setdest 89.663708107313 283.494644426442 19.153832288917"


$node_(2) set Z_ 0.000000000000
$node_(2) set Y_ 199.3
$node_(2) set X_ 591.25
$node_(1) set Z_ 0.000000000000
$node_(1) set Y_ 345.35
$node_(1) set X_ 257.04
$node_(0) set Z_ 0.000000000000
$node_(0) set Y_ 239.4
$node_(0) set X_ 83.36

# Define initial node position in nam

for {set i 0} {$i < $opt(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your
    # scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 20
    $node_($i) color red

}     

# Tell all nodes when the simulation ends
for {set i } {$i < $opt(nn) } {incr i} {
   $ns_ at $opt(stop).0 "$node_($i) reset";
}

$ns_ at $opt(stop).0 "$BS(0) reset";

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd namtrace
   $ns_ flush-trace
    close $tracefd
    close $namtrace
}

# informative headers for CMUTracefile
puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp \
	$opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"


puts "Starting Simulation..."
$ns_ run

