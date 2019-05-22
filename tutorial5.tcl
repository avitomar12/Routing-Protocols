#topology design
set ns [new Simulator]




set tracefd  [open output.tr w]
$ns trace-all $tracefd
set nf [open output.nam w]
$ns namtrace-all $nf



#Creating wired nodes
set n0 [$ns node]
$n0 color green
set n1 [$ns node]
$n1 color green
set n2 [$ns node]
$n2 color green
set n3 [$ns node]
$n3 color green
set n4 [$ns node]
$n4 color green
set n5 [$ns node]
$n5 color green
set n6 [$ns node]
$n6 color green
set n7 [$ns node]
$n7 color green
set n8 [$ns node]
$n8 color green
#connection between wired nodes

$ns duplex-link $n5 $n2 2Mb 2ms DropTail
$ns duplex-link $n0 $n2 2Mb 2ms DropTail
$ns duplex-link $n2 $n4 2Mb 2ms DropTail
$ns duplex-link $n4 $n7 2Mb 2ms DropTail
$ns duplex-link $n4 $n8 2Mb 2ms DropTail
$ns duplex-link $n3 $n4 5Mb 2ms DropTail
$ns duplex-link $n6 $n3 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 5Mb 2ms DropTail



  
set basestation1 [$ns node]
$basestation1 color red
set basestation2 [$ns node]
$basestation2 color red



 #configure for mobilenodes
#Creating wirless nodes

for {set j 0} {$j < 4} {incr j} {
    set nodes($j) [ $ns node ]
    $nodes($j) color blue
  }


proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam output.nam &
	exit 0
}
$ns run