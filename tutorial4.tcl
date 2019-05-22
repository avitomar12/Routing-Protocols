### This simulation is an example of combination of wired and wireless 
### topologies.


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
set opt(nn)             10                       
set opt(adhocRouting)   DSDV                      
set val(cp)             "/home/avi/Documents/Curaj/3rdSem/project/cbr-10-test"
set opt(stop)           250                           
set num_wired_nodes      2
set num_bs_nodes         2

set ns_   [new Simulator]
# set up for hierarchical routing
  $ns_ node-config -addressType hierarchical
  AddrParams set domain_num_ 2          
  lappend cluster_num 2 1                 
  AddrParams set cluster_num_ $cluster_num
  lappend eilastlevel 1 1 12               
  AddrParams set nodes_num_ $eilastlevel 

  set tracefd  [open $opt(tr) w]
  $ns_ trace-all $tracefd
  set namtracefd [open $opt(namtr) w]
  $ns_ namtrace-all $namtracefd


  set topo   [new Topography]
  $topo load_flatgrid $opt(x) $opt(y)
  # god needs to know the number of all wireless interfaces
  create-god [expr $opt(nn) + $num_bs_nodes]

  #create wired nodes
  set temp {0.0.0 0.1.0}        
  for {set i 0} {$i < $num_wired_nodes} {incr i} {
      set W($i) [$ns_ node [lindex $temp $i]]
  } 
  $ns_ node-config -adhocRouting $opt(adhocRouting) \
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

  set temp {1.0.1 1.0.2 1.0.3 1.0.4 1.0.5 1.0.6 1.0.7 1.0.8 1.0.9 1.0.10 1.0.11}   
  set BS(0) [$ns_ node 1.0.0]
  set BS(1) [$ns_ node 2.0.0]
  $BS(0) random-motion 0 
  $BS(1) random-motion 0

  $BS(0) set X_ 1.0
  $BS(0) set Y_ 2.0
  $BS(0) set Z_ 0.0
  
  $BS(1) set X_ 650.0
  $BS(1) set Y_ 600.0
  $BS(1) set Z_ 0.0
  
  #configure for mobilenodes
  $ns_ node-config -wiredRouting OFF

  for {set j 0} {$j < $opt(nn)} {incr j} {
    set node_($j) [ $ns_ node [lindex $temp $j] ]
    $node_($j) base-station [AddrParams addr2id [$BS(0) node-addr]]
  }

  #create links between wired and BS nodes
  $ns_ duplex-link $W(0) $W(1) 5Mb 2ms DropTail
  $ns_ duplex-link $W(1) $BS(0) 5Mb 2ms DropTail
  $ns_ duplex-link $W(1) $BS(1) 5Mb 2ms DropTail
  $ns_ duplex-link-op $W(0) $W(1) orient down
  $ns_ duplex-link-op $W(1) $BS(0) orient left-down
  $ns_ duplex-link-op $W(1) $BS(1) orient right-down

  # setup TCP connections
# nodes: 10, max conn: 8, send rate: 0.25, seed: 1.0
#
#
# 1 connecting to 2 at time 2.5568388786897245
#
#set udp_(0) [new Agent/UDP]
#$ns_ attach-agent $node_(1) $udp_(0)
#set null_(0) [new Agent/Null]
#$ns_ attach-agent $node_(2) $null_(0)
#set cbr_(0) [new Application/Traffic/CBR]
#$cbr_(0) set packetSize_ 512
#$cbr_(0) set interval_ 0.25
#$cbr_(0) set random_ 1
#$cbr_(0) set maxpkts_ 10000
#$cbr_(0) attach-agent $udp_(0)
#$ns_ connect $udp_(0) $null_(0)
#$ns_ at 2.5568388786897245 "$cbr_(0) start"
#
# 4 connecting to 5 at time 56.333118917575632
#

# 7 connecting to 8 at time 29.546173154165118

  
  for {set i 0} {$i < $opt(nn)} {incr i} {
      $ns_ initial_node_pos $node_($i) 20
   }

  for {set i 0} {$i < $opt(nn) } {incr i} {
      $ns_ at $opt(stop).0000010 "$node_($i) reset";
  }
  $ns_ at $opt(stop).0000010 "$BS(0) reset";

  $ns_ at $opt(stop).1 "puts \"NS EXITING...\" ; $ns_ halt"

  puts "Starting Simulation..."
  $ns_ run
