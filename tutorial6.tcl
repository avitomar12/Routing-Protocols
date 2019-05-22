#topology design
set ns [new Simulator]

global opt
set opt(chan)       Channel/WirelessChannel
set opt(prop)       Propagation/TwoRayGround
set opt(netif)      Phy/WirelessPhy
set opt(mac)        Mac/802_11
set opt(ifq)        Queue/DropTail/PriQueue
set opt(ll)         LL
set opt(ant)        Antenna/OmniAntenna
set opt(x)             670   
set opt(y)              670   
set opt(ifqlen)         50   
set opt(tr)          wired-and-wireless.tr
set opt(namtr)       wired-and-wireless.nam
set opt(nn)             3                       
set opt(adhocRouting)   DSDV                      
set val(cp)             "/home/avi/Documents/Curaj/3rdSem/project/cbr-10-test"
set opt(stop)           250                           
set num_wired_nodes      9
set num_bs_nodes         1

$ns node-config -addressType hierarchical
AddrParams set domain_num_ 2          
lappend cluster_num 2 1              
AddrParams set cluster_num_ $cluster_num
append eilastlevel 5 4 4               
AddrParams set nodes_num_ $eilastlevel 

set tracefd  [open output.tr w]
$ns trace-all $tracefd
set nf [open output.nam w]
$ns namtrace-all-wireless $nf $opt(x) $opt(y)


  set topo   [new Topography]
 $topo load_flatgrid $opt(x) $opt(y)
 # god needs to know the number of all wireless interfaces
  create-god [ expr $opt(nn) + $num_bs_nodes ]

#Creating wired nodes
# create wired nodes
set temp {0.0.0 0.0.1 0.0.2 0.0.3 0.0.4 0.1.0 0.1.1 0.1.2 0.1.3 0.1.4};# hierarchical addresses to be used
for {set i 0} {$i < $num_wired_nodes} {incr i} {
    set W($i) [$ns node [lindex $temp $i]]
    $W($i) color green
}



#connection between wired nodes
$ns duplex-link $W(0) $W(1) 2Mb 2ms DropTail
$ns duplex-link $W(5) $W(2) 2Mb 2ms DropTail orient
$ns duplex-link $W(0) $W(2) 2Mb 2ms DropTail
$ns duplex-link $W(2) $W(4) 2Mb 2ms DropTail
$ns duplex-link $W(4) $W(7) 2Mb 2ms DropTail
$ns duplex-link $W(4) $W(8) 2Mb 2ms DropTail
$ns duplex-link $W(3) $W(4) 5Mb 2ms DropTail
$ns duplex-link $W(6) $W(3) 1.5Mb 10ms DropTail
$ns duplex-link $W(1) $W(3) 5Mb 2ms DropTail



  $ns node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propInstance [new $opt(prop)] \
                 -phyType $opt(netif) \
                 -channel [new $opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF

#create base-station node
set temp {1.0.0 1.0.1 1.0.2 1.0.3}   ;# hier address to be used for
                                     ;# wireless domain
set BS(0) [ $ns node [lindex $temp 0]]
$BS(0) random-motion 0               ;# disable random motion
$BS(0) color red
#provide some co-ordinates (fixed) to base station node
$BS(0) set X_ 1.0
$BS(0) set Y_ 2.0
$BS(0) set Z_ 0.0




 #configure for mobilenodes
$ns node-config -wiredRouting OFF
#Creating wirless nodes
# now create mobilenodes
for {set j 0} {$j < $opt(nn)} {incr j} {
    set node($j) [ $ns node [lindex $temp [expr $j+1]] ]
    $node($j) base-station [AddrParams addr2id [$BS(0) node-addr]] 
    $node($j) color blue
}
#$ns duplex-link-op $W(0) $W(1) orient down
#$ns duplex-link-op $W(1) $BS(0) orient left-down



proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam output.nam &
	exit 0
}
$ns run