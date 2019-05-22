# ======================================================================
# Define options
# ======================================================================
set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           DSR                     ;# ad-hoc routing protocol 
set val(nn)           5                        ;# number of mobilenodes
set val(cp)             "../mobility/scene/cbr-3-test" 
set val(sc)             "../mobility/scene/scen-3-test" 
set ns [new Simulator]

set tracefd [open simple.tr w]
$ns trace-all $tracefd
set nf [open output.nam w]
$ns namtrace-all-wireless $nf 500 500

set topo [new Topography]

$topo load_flatgrid 500 500

create-god $val(nn)

# Configure nodes
        $ns node-config -adhocRouting $val(rp) \
                         -llType $val(ll) \
                         -macType $val(mac) \
                         -ifqType $val(ifq) \
                         -ifqLen $val(ifqlen) \
                         -antType $val(ant) \
                         -propType $val(prop) \
                         -phyType $val(netif) \
                         -topoInstance $topo \
                         -channelType $val(chan) \
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace OFF \
                         -movementTrace OFF

for { set i 0} {$i < $val(nn)} { incr i } {
	set node($i) [$ns node]
	$node($i) random-motion 0
}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for node_(0) and node_(1)
#
$node(0) set X_ 15.0
$node(0) set Y_ 12.0

$node(1) set X_ 39.0
$node(1) set Y_ 3.0


$node(2) set X_ 39.0
$node(2) set Y_ 38.0

$node(3) set X_ 90.0
$node(3) set Y_ 85.0

$node(4) set X_ 90.0
$node(4) set Y_ 35.0


#
# Node_(1) starts to move towards node_(0)
$ns at 0.0 "$node(4) setdest 25.0 20.0 20.0"
$ns at 0.0 "$node(1) setdest 1.0 20.0 20.0"
$ns at 0.0 "$node(0) setdest 20.0 1.0 10.0"
$ns at 0.0 "$node(2) setdest 1.1 10.0 10"
$ns at 0.0 "$node(3) setdest 99.0 99.0 30.0"

# 



set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node(0) $tcp
$ns attach-agent $node(2) $tcp
$ns attach-agent $node(3) $tcp
$ns attach-agent $node(4) $tcp
$ns attach-agent $node(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.1 "$ftp start"

#
# Tell nodes when the simulation ends
#
$ns at 5.0 "stop"
$ns at 5.1 "puts \"NS EXITING...\" ; $ns halt"
proc stop {} {
    global ns tracefd nf
    close $tracefd
	close $nf
	exec nam output.nam &
	exit 0
    
}
puts "Starting Simulation..."
$ns run


