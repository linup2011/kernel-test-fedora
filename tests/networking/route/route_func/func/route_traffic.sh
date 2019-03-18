#!/bin/bash

TEST_ITEMS_ALL="$TEST_ITEMS_ALL route_mtu_test route_tos_test route_addr_test route_ioctl_test option_realm_test route_part_forward_test"

route_tos_test()
{
rlPhaseStartTest "Route tos $TEST_TYPE $TEST_TOPO $ROUTE_MODE"

	local route_host
	[ x"$ROUTE_MODE" == x"local" ] && route_host=$C_HOSTNAME || route_host=$R_HOSTNAME
	local version=4
	local err=0

	# add tos route
	rlRun "vrun $route_host ip -$version route add default tos 0x10 dev $R_L_IF1 via ${R_R_IP1[$version]}"
	rlRun "vrun $route_host ip -$version route add default tos 0x10 dev $R_L_IF1 via ${R_R_IP1[$version]}" "0-255"
	rlRun "vrun $route_host ip -$version route add default tos 0x04 dev $R_L_IF2 via ${R_R_IP2[$version]}"
	rlRun "vrun $route_host ip -$version route add default tos 0x04 dev $R_L_IF2 via ${R_R_IP2[$version]}" "0-255"
	rlRun "vrun $route_host ip -$version route add default tos 0x08 dev $R_L_IF1 via ${R_R_IP1[$version]}"
	rlRun "vrun $route_host ip -$version route add default tos 0x08 dev $R_L_IF1 via ${R_R_IP1[$version]}" "0-255"

	# get route
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]} tos 0x10 | grep \"via ${R_R_IP1[$version]} dev $R_L_IF1\""
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]} tos 0x04 | grep \"via ${R_R_IP2[$version]} dev $R_L_IF2\""
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]} tos 0x08 | grep \"via ${R_R_IP1[$version]} dev $R_L_IF1\""

	# ping and check route
	vrun $route_host "nohup tcpdump -U -i $R_L_IF1 -w tos10.pcap &"
	rlRun "sleep 2"
	rlRun "vrun $route_host ping ${S_IP[$version]} -c 5 -Q 0x10"
	rlRun "sleep 2"
	rlRun "vrun $route_host pkill tcpdump" "0-255"
	rlRun "sleep 2"
	rlRun "vrun $route_host tcpdump -r tos10.pcap -nnle | grep \"> ${S_IP[$version]}\""
	[ $? -ne 0 ] && { let err++; rlRun "vrun $route_host tcpdump -r tos10.pcap -nnle"; }

	vrun $route_host "nohup tcpdump -U -i $R_L_IF2 -w tos04.pcap &"
	rlRun "sleep 2"
	rlRun "vrun $route_host ping ${S_IP[$version]} -c 5 -Q 0x04"
	rlRun "sleep 2"
	rlRun "vrun $route_host pkill tcpdump" "0-255"
	rlRun "sleep 2"
	rlRun "vrun $route_host tcpdump -r tos04.pcap -nnle | grep \"> ${S_IP[$version]}\""
	[ $? -ne 0 ] && { let err++; rlRun "vrun $route_host tcpdump -r tos04.pcap -nnle"; }

	vrun $route_host "nohup tcpdump -U -i $R_L_IF1 -w tos08.pcap &"
	rlRun "sleep 2"
	rlRun "vrun $route_host ping ${S_IP[$version]} -c 5 -Q 0x08"
	rlRun "sleep 2"
	rlRun "vrun $route_host pkill tcpdump" "0-255"
	rlRun "sleep 2"
	rlRun "vrun $route_host tcpdump -r tos08.pcap -nnle | grep \"> ${S_IP[$version]}\""
	[ $? -ne 0 ] && { let err++; rlRun "vrun $route_host tcpdump -r tos08.pcap -nnle"; }

	# del route
	rlRun "vrun $route_host ip -$version route del default tos 0x10 dev $R_L_IF1 via ${R_R_IP1[$version]}"
	rlRun "vrun $route_host ip -$version route del default tos 0x10 dev $R_L_IF1 via ${R_R_IP1[$version]}" "0-255"
	rlRun "vrun $route_host ip -$version route del default tos 0x04 dev $R_L_IF2 via ${R_R_IP2[$version]}"
	rlRun "vrun $route_host ip -$version route del default tos 0x04 dev $R_L_IF2 via ${R_R_IP2[$version]}" "0-255"
	rlRun "vrun $route_host ip -$version route del default tos 0x08 dev $R_L_IF1 via ${R_R_IP1[$version]}"
	rlRun "vrun $route_host ip -$version route del default tos 0x08 dev $R_L_IF1 via ${R_R_IP1[$version]}" "0-255"

	rlRun "vrun $C_HOSTNAME ping ${S_IP[$version]} -c 5"

rlPhaseEnd
}

route_mtu_test()
{
rlPhaseStartTest "Route Mtu $TEST_TYPE $TEST_TOPO $ROUTE_MODE"
	local route_host
	[ x"$ROUTE_MODE" == x"local" ] && route_host=$C_HOSTNAME || route_host=$R_HOSTNAME
	local test_versions="4 6"
	[ x"$ROUTE_MODE" == x"forward" ] && test_versions="4"
for version in $test_versions
do
	[ x"$version" == x"4" ] && ping=ping || ping=ping6
	rlRun "vrun $route_host ip -$version route add ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]} mtu 1400"
	rlRun "vrun $route_host ip -$version route add ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]} mtu 1400" "0-255"
	rlRun "vrun $route_host ip -$version route list | grep \"${S_IP[$version]} .* dev $R_L_IF2.*mtu 1400\""
	[ $? -ne 0 ] && rlRun -l "vrun $route_host ip -$version route list"
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]} | grep \"mtu 1400\""
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]} oif $R_L_IF2 | grep $R_L_IF2"
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]} oif $R_L_IF1 | grep $R_L_IF2" "1"

	vrun $S_HOSTNAME "nohup tcpdump -U -i any -U -w server.pcap &"
	rlRun "sleep 5"
	rlRun "vrun $C_HOSTNAME $ping ${S_IP[$version]} -c 1 -s 1500"
	rlRun "sleep 2"
	rlRun "vrun $S_HOSTNAME pkill tcpdump" "0-255"
	rlRun "sleep 5"
	if [ x"$version" == x"4" ]
	then
		rlRun "vrun $S_HOSTNAME tcpdump -r server.pcap -nnle | grep \"length 1412: .* > ${S_IP[$version]}\""
		[ $? -ne 0 ] && rlRun "vrun $S_HOSTNAME tcpdump -r server.pcap -nnle"
	else
		rlRun "vrun $S_HOSTNAME tcpdump -r server.pcap -nnle | grep \"length 1416: .* > ${S_IP[$version]}\""
		[ $? -ne 0 ] && rlRun "vrun $S_HOSTNAME tcpdump -r server.pcap -nnle"
	fi

	rlRun "vrun $route_host ip -$version route del ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]} mtu 1400"
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]} | grep \"mtu 1400\"" "1"
	rlRun "vrun $route_host ip -$version route del ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]} mtu 1400" "0-255"
	rlRun "vrun $route_host $ping ${S_IP[$version]} -c 5"
done

rlPhaseEnd
}

# add route for different type of address
# and send packet to confirm if the route
# take effect
route_addr_test()
{
rlPhaseStartTest "Route Addr $TEST_TYPE $TEST_TOPO $ROUTE_MODE"
	local route_host
	[ x"$ROUTE_MODE" == x"local" ] && route_host=$C_HOSTNAME || route_host=$R_HOSTNAME
	multi_addr[4]=237.1.1.1
	multi_addr[6]=ff0e::1

for version in 4 6
do
	[ x"$version" == x"4" ] && ping=ping || ping=ping6
	#default route
	vrun $route_host "nohup tcpdump -U -i $R_L_IF1 -p -w route_addr.pcap &"
	rlRun "sleep 2"
	rlRun "vrun $C_HOSTNAME $ping ${S_IP[$version]} -c 1"
	rlRun "sleep 1"
	rlRun "vrun $route_host pkill tcpdump" "0-255"
	rlRun "sleep 5"
	rlRun "vrun $route_host tcpdump -r route_addr.pcap -nnle | grep \"> ${S_IP[$version]}\""
	[ $? -ne 0 ] && rlRun "vrun $route_host tcpdump -r route_addr.pcap -nnle"

	#change route
	rlRun "vrun $route_host ip -$version route add ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]}"
	rlRun "vrun $route_host ip -$version route add ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]}" "0-255"
	rlRun "vrun $route_host ip -$version route list"
	rlRun "vrun $route_host ip -$version route get ${S_IP[$version]}"
	vrun $route_host "nohup tcpdump -U -i $R_L_IF2 -p -w route_addr.pcap &"
	rlRun "sleep 2"
	rlRun "vrun $C_HOSTNAME $ping ${S_IP[$version]} -c 1"
	rlRun "sleep 1"
	rlRun "vrun $route_host pkill tcpdump" "0-255"
	rlRun "sleep 5"
	rlRun "vrun $route_host tcpdump -r route_addr.pcap -nnle | grep \"> ${S_IP[$version]}\""
	[ $? -ne 0 ] && rlRun "vrun $route_host tcpdump -r route_addr.pcap -nnle"
	rlRun "vrun $route_host ip -$version route del ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]}"
	rlRun "vrun $route_host ip -$version route del ${S_IP[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]}" "0-255"

	#multicast addr
	if [ x"$ROUTE_MODE" == x"local" ]
	then
		rlRun "vrun $route_host ip -$version route get ${multi_addr[$version]}"
		if vrun $route_host ip -$version route get ${multi_addr[$version]} | grep $R_L_IF1
		then
			:
		else
			local route_change=1
			[ x"$version" == x"4" ] && \
				rlRun "vrun $route_host ip -$version route add ${multi_addr[$version]} dev $R_L_IF1 via ${R_R_IP1[$version]}" || \
				rlRun "vrun $route_host ip -$version route add ${multi_addr[$version]} dev $R_L_IF1 via ${R_R_IP1[$version]} table local"
		fi
		rlRun "vrun $route_host ip -$version route get ${multi_addr[$version]}"
		vrun $route_host "nohup tcpdump -U -i $R_L_IF1 -p -w route_multi.pcap &"
		rlRun "sleep 2"
		rlRun "vrun $route_host $ping ${multi_addr[$version]} -c 1" "0,1"
		rlRun "sleep 1"
		rlRun "vrun $route_host pkill tcpdump" "0-255"
		rlRun "sleep 5"
		rlRun "vrun $route_host tcpdump -r route_multi.pcap -nnle | grep \"> ${multi_addr[$version]}\""
		[ $? -ne 0 ] && rlRun "vrun $route_host tcpdump -r route_multi.pcap -nnle"
		if [ x"$route_change" == x"1" ]
		then
			[ x"$version" == x"4" ] && \
				rlRun "vrun $route_host ip -$version route del ${multi_addr[$version]} dev $R_L_IF1 via ${R_R_IP1[$version]}" || \
				rlRun "vrun $route_host ip -$version route del ${multi_addr[$version]} dev $R_L_IF1 via ${R_R_IP1[$version]} table local"
		fi

		[ x"$version" == x"4" ] && \
			rlRun "vrun $route_host ip -$version route add ${multi_addr[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]}" || \
			rlRun "vrun $route_host ip -$version route add ${multi_addr[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]} table local"
		rlRun "vrun $route_host ip -$version route get ${multi_addr[$version]}"
		vrun $route_host "nohup tcpdump -U -i $R_L_IF2 -p -w route_multi.pcap &"
		rlRun "sleep 2"
		rlRun "vrun $route_host $ping ${multi_addr[$version]} -c 1" "0,1"
		rlRun "sleep 1"
		rlRun "vrun $route_host pkill tcpdump" "0-255"
		rlRun "sleep 5"
		rlRun "vrun $route_host tcpdump -r route_multi.pcap -nnle | grep \"> ${multi_addr[$version]}\""
		[ $? -ne 0 ] && rlRun "vrun $route_host tcpdump -r route_multi.pcap -nnle"
		[ x"$version" == x"4" ] && \
			rlRun "vrun $route_host ip -$version route del ${multi_addr[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]}" || \
			rlRun "vrun $route_host ip -$version route del ${multi_addr[$version]} dev $R_L_IF2 via ${R_R_IP2[$version]} table local"
	fi
done

rlPhaseEnd
}


route_ioctl_test()
{
rlPhaseStartTest "Route ioctl $TEST_TYPE $TEST_TOPO $ROUTE_MODE"
	[ x"$ROUTE_MODE" != x"local" ] && { rlLog "ROUTE_MODE:$ROUTE_MODE not local, return";return; }
	rlLog "[route_ioctl_test] check default v4 with route"
	rlRun "vrun $C_HOSTNAME route -A inet -n | grep \"0.0.0.0.*${R_R_IP1[4]}.*$R_L_IF1\""
	local networkv4_if1=`ipcalc -4 -n ${R_L_IP1[4]}/24 | awk -F= '{print $2}'`
	local netmaskv4_if1=`ifcalc -4 -m ${R_L_IP1[4]}/24 | awk -F= '{print $2}'`
	rlRun "vrun $C_HOSTNAME route -A inet -n | grep \"$networkv4_if1 .*0.0.0.0$netmaskv4_if1 .*$R_L_IF1\""

	rlLog "[route_ioctl_test] check default v6 with route"
	rlRun "vrun $C_HOSTNAME route -A inet6 -n | grep \"::/0.*${R_R_IP1[6]}.*$R_L_IF1\""
	rlRun "vrun $C_HOSTNAME route -A inet6 -n | grep \"ff00::/8.*$R_L_IF1\""

	local test_dst[4]=172.111.1.1
	local test_dst[6]=5010:2222:1111::1
	local version=4

for version in 4 6
do
	local family=inet
	local ping_cmd=ping
	[ x"$version" == x"6" ] && { family=inet6;ping_cmd=ping6; }
	rlRun "vrun $C_HOSTNAME route -A $family -Fn"
	uname -r | grep 2.6.32 || rlRun "vrun $C_HOSTNAME route -A $family -Cn"
	rlRun "vrun $C_HOSTNAME route -A $family -ne"
	rlRun "vrun $C_HOSTNAME route -A $family -nee"
	rlRun "vrun $C_HOSTNAME route -A $family -vn"

	vrun $C_HOSTNAME "nohup tcpdump -U -i $R_L_IF1 -w route_ioctl.pcap &"
	sleep 2
	rlRun "vrun $C_HOSTNAME $ping_cmd ${S_IP[$version]} -c 1"
	sleep 5
	rlRun "vrun $C_HOSTNAME pkill tcpdump" "0-255"
	sleep 1
	rlRun "vrun $C_HOSTNAME tcpdump -r route_ioctl.pcap -nnle | grep \"${R_L_IP1[$version]} > ${S_IP[$version]}\""


	local metric=0
	[ x"$version" == x"6" ] && metric=1024
	rlRun "vrun $C_HOSTNAME route -A $family del default metric $metric"
	rlRun "vrun $C_HOSTNAME route -A $family del default metric $metric" "0-255"
	rlRun "vrun $C_HOSTNAME route -A $family add default gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family add default gw ${R_R_IP2[$version]} dev $R_L_IF2" "0-255"
	rlRun "vrun $C_HOSTNAME $ping_cmd ${S_IP[$version]} -c 5"
	vrun $C_HOSTNAME "nohup tcpdump -U -i $R_L_IF2 -w route_ioctl.pcap &"
	rlRun "sleep 2"
	rlRun "vrun $C_HOSTNAME $ping_cmd ${S_IP[$version]} -c 1"
	rlRun "sleep 5"
	rlRun "vrun $C_HOSTNAME pkill tcpdump" "0-255"
	rlRun "sleep 1"
	rlRun "vrun $C_HOSTNAME tcpdump -r route_ioctl.pcap -nnle | grep \"${R_L_IP2[$version]} > ${S_IP[$version]}\""
	rlRun "vrun $C_HOSTNAME route -A $family del default gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family del default gw ${R_R_IP2[$version]} dev $R_L_IF2" "0-255"
	rlRun "vrun $C_HOSTNAME route -A $family add default gw ${R_R_IP1[$version]} dev $R_L_IF1 metric $metric"
	rlRun "vrun $C_HOSTNAME route -A $family add default gw ${R_R_IP1[$version]} dev $R_L_IF1 metric $metric" "0-255"

	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family -n | grep \"${test_dst[$version]}.*${R_R_IP2[$version]} .*$R_L_IF2\""
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 metric 100"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 metric 100" "0-255"
	rlRun "vrun $C_HOSTNAME route -A $family -n | grep \"${test_dst[$version]}.*${R_R_IP2[$version]} .*100 .*$R_L_IF2\""
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 metric 100"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 metric 100" "0-255"
done

	family=inet
	version=4
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 mss 1400"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 mss 1400"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 mss 100000000" "0,3,4"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 mss 100000000" "0,3,4"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 window 1024"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 window 1024"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 window 16385"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 window 16385"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 irtt 300"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 irtt 300"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 irtt 12001"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2 irtt 12001"

	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} reject"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_dst[$version]} reject" "0-255"
	rlRun "vrun $C_HOSTNAME $ping_cmd ${test_dst[$version]} -c 1" "2"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} reject"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_dst[$version]} reject" "0-255"

	local test_net[4]=172.111.120.0/24
	local test_net[6]=2345::/64

	rlRun "vrun $C_HOSTNAME route -A $family add -net ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family add -net ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2" "0-255"
	rlRun "vrun $C_HOSTNAME route -A $family del -net ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family del -net ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2" "0-255"

	family=inet6
	version=6
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family add ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2" "0-255"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME route -A $family del ${test_net[$version]} gw ${R_R_IP2[$version]} dev $R_L_IF2" "0-255"
rlPhaseEnd
}


option_realm_test()
{
rlPhaseStartTest "option realm $TEST_TYPE $TEST_TOPO $ROUTE_MODE"
	local route_host
	[ x"$ROUTE_MODE" == x"local" ] && route_host=$C_HOSTNAME || route_host=$R_HOSTNAME

	# valid and invlid realms with ip route
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms -1" "1-255"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms 0"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 realms 0"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms 65536"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 realms 65536"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms 65535"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 realms 65535"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms 256/256" "1-255"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms 255/255"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 realms 255/255"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms 0/0"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 realms 0/0"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 realms -1/-1" "1-255"

	# valid and invalid realms with ip rule
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms -1" "1-255"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 0"
	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 0"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 65536"
	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 65536"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 65535"
	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 65535"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms -1/-1" "1-255"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 0/0"
	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 0/0"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 255/255"
	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 255/255"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 256/256" "1-255"

	# normal operation with ip rule and ip route
	# only ip rule provide realms
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 1/2 table 1234"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} table 1234"
	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1"
	# rlRun "vrun $route_host rtacct 1 | grep \"1.*84.*1.*84.*1\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct 1"
	# rlRun "vrun $route_host rtacct 2 | grep \"2.*84.*1.*84.*1\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct 2"
	rlRun "vrun $route_host cat /proc/net/rt_acct"
	rlRun "vrun $route_host rtacct -r"

	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 1/2 table 1234"
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 3 table 1234"
	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1"
	# rlRun "vrun $route_host rtacct 3 | grep \"3.*84.*1.*84.*1\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct 3"
	# rlRun "vrun $route_host rtacct | grep \"unknown.*84.*1.*84.*1\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct"
	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 3 table 1234"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} table 1234"
	rlRun "vrun $route_host cat /proc/net/rt_acct"
	rlRun "vrun $route_host rtacct -r"

	# only ip route provides realms
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 1/2"
	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1"
	# rlRun "vrun $route_host rtacct 1 | grep \"1.*84.*1\""
	# [ $? -ne 0 ] && rlRun "vrun $route_host rtacct 1"
	# rlRun "vrun $route_host rtacct 2 | grep \"2.*84.*1\""
	# [ $? -ne 0 ] && rlRun "vrun $route_host rtacct 2"
	rlRun "vrun $route_host cat /proc/net/rt_acct"
	rlRun "vrun $route_host rtacct -r"

	rlRun "vrun $route_host ip route change ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 3"
	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1"
	# rlRun "vrun $route_host rtacct 3 | grep \"3.*84.*1.*84.*1\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct 3"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 3"
	rlRun "vrun $route_host cat /proc/net/rt_acct"
	rlRun "vrun $route_host rtacct -r"

	# both ip rule and ip route provide realms
	rlRun "vrun $route_host ip rule add to ${S_IP[4]} realms 1/2 table 1234"
	rlRun "vrun $route_host ip rule list | grep \"${S_IP[4]}.*realms 1/2\""
	[ $? -ne 0 ] && rlRun -l "vrun $route_host ip rule list"
	rlRun "vrun $route_host ip route add ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 3/4 table 1234"
	rlRun "vrun $route_host ip route list table 1234 | grep \"${S_IP[4]}.*realms 3/4\""
	[ $? -ne 0 ] && rlRun "vrun $route_host ip route list table 1234"
	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1"
	# rlRun "vrun $route_host rtacct | grep \"^3\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct"
	# rlRun "vrun $route_host rtacct | grep \"^4\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct"
	rlRun "vrun $route_host cat /proc/net/rt_acct"
	rlRun "vrun $route_host rtacct -r"

	rlRun "vrun $route_host ip route replace ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 5/6 table 1234"
	rlRun "vrun $route_host ip route list table 1234 | grep \"${S_IP[4]}.*realms 5/6\""
	[ $? -ne 0 ] && rlRun "vrun $route_host ip route list table 1234"
	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1"
	# rlRun "vrun $route_host rtacct | grep \"^5\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct"
	# rlRun "vrun $route_host rtacct | grep \"^6\""
	# [ $? -ne 0 ] && rlRun -l "vrun $route_host rtacct"
	rlRun "vrun $route_host cat /proc/net/rt_acct"
	rlRun "vrun $route_host rtacct -r"

	rlRun "vrun $route_host ip route append ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 7/8 table 1234"
	rlRun "vrun $route_host ip route list table 1234 | grep \"${S_IP[4]}.*realms 7/8\""
	[ $? -ne 0 ] && rlRun "vrun $route_host ip route list table 1234"
	rlRun "vrun $route_host ip route del ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 7/8 table 1234"
	rlRun "vrun $route_host ip route list table 1234 | grep \"${S_IP[4]}.*realms 7/8\"" "1"
	[ $? -ne 1 ] && rlRun "vrun $route_host ip route list table 1234"

	rlRun "vrun $route_host ip route append ${S_IP[4]} dev $R_L_IF1 via ${R_R_IP1[4]} realms 9/10 table 1234"
	rlRun "vrun $route_host ip route flush table 1234"
	rlRun "vrun $route_host ip route list table 1234 | grep realms" "1"
	[ $? -ne 1 ] && rlRun -l "vrun $route_host ip route list table 1234"

	rlRun "vrun $route_host ip rule del to ${S_IP[4]} realms 1/2 table 1234"

rlPhaseEnd
}

route_part_forward_test()
{
rlPhaseStartTest "part forward $TEST_TYPE $TEST_TOPO $ROUTE_MODE"
	[ x"$ROUTE_MODE" != x"local" ] && { rlLog "ROUTE_MODE:$ROUTE_MODE not local, return";return; }

	rlRun "vrun $R_HOSTNAME sysctl -w net.ipv4.conf.${R_R_IF1}.forwarding=0"
	# ip route get would return 2 on 4 kernel
	if vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF1 from ${R_L_IP1[4]}
	then
		rlRun "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF1 from ${R_L_IP1[4]} | grep \"unreachable\""
		[ $? -ne 0 ] && rlRun -l "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF1 from ${R_L_IP1[4]}"
		rlRun "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF2 from ${R_L_IP2[4]} | grep \"unreachable\"" "1"
		[ $? -ne 1 ] && rlRun -l "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF2 from ${R_L_IP2[4]}"
	else
		rlRun "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF2 from ${R_L_IP2[4]}"
		[ $? -ne 0 ] && rlRun -l "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF2 from ${R_L_IP2[4]}"
		rlRun "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF2 from ${R_L_IP2[4]} | grep \"unreachable\"" "1"
		[ $? -ne 1 ] && rlRun -l "vrun $R_HOSTNAME ip route get to ${S_IP[4]} iif $R_R_IF2 from ${R_L_IP2[4]}"
	fi

	rlRun "vrun $R_HOSTNAME ip route flush cache"

	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1" "1-255"
	rlRun "vrun $C_HOSTNAME ip route change default via ${R_R_IP2[4]} dev $R_L_IF2"
	rlRun "vrun $C_HOSTNAME ping ${S_IP[4]} -c 1"
	rlRun "vrun $C_HOSTNAME ip route change default via ${R_R_IP1[4]} dev $R_L_IF1"

	rlRun "vrun $C_HOSTNAME ip route flush cache"
	rlRun "vrun $R_HOSTNAME ip route flush cache"

	rlRun "vrun $R_HOSTNAME sysctl -w net.ipv4.conf.${R_R_IF1}.forwarding=1"

rlPhaseEnd
}
