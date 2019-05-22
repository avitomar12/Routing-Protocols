set ns [new Simulator]

set nf [open output.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]


$ns duplex-link $n0 $n1 5Mb 2ms DropTail
$ns duplex-link $n0 $n2 5Mb 2ms DropTail
$ns duplex-link $n1 $n2 5Mb 2ms DropTail
$ns duplex-link $n2 $n3 5Mb 2ms DropTail
$ns duplex-link $n4 $n2 5Mb 2ms DropTail
$ns duplex-link $n5 $n2 5Mb 2ms DropTail
$ns duplex-link $n2 $n1 1.5Mb 10ms DropTail

set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0



set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set null0 [new Agent/Null]
$ns attach-agent $n5 $null0
$ns attach-agent $n3 $null0
$ns attach-agent
$ns connect $udp0 $null0

$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"


$ns at 5.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam output.nam &
	exit 0
}
$ns run