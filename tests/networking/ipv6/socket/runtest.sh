#!/bin/bash

# Copyright (c) 2006 Red Hat, Inc.  This copyrighted material 
# is made available to anyone wishing to use, modify, copy, or
# redistribute it subject to the terms and conditions of the GNU General
# Public License v.2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# Hangbin Liu: <haliu@redhat.com> 

. /usr/share/beakerlib-libraries/kernel/Library/networking-common/include.sh

fail=0
pass=0

myecho()
{
	echo -e "$1" | tee -a $OUTPUTFILE
}

rlJournalStart

	rlPhaseStartTest "IPv6 non local bind test"
setenforce 0
service iptables stop

myecho "=============== Basic Socket Interface for IPv6 TESTING ==============="
pushd ./func_tests
make >/dev/null 2>&1
scripts=`ls | grep -Ev "(\.c|\.h|Makefile|CVS|client|server)"`
for i in $scripts
do
	OUTPUTFILE=`mktemp /tmp/tmp.XXXXXX`
	myecho "\n++++++++++++++++++++ Begin Testing $i ++++++++++++++++++++\n"
	./$i 2>&1 | tee -a $OUTPUTFILE
	if [ "`grep BROK $OUTPUTFILE`" ] || [ -z "`grep PASS $OUTPUTFILE`" ]; then
		myecho "\n:: [	 FAIL	] :: RESULT $i\n"
		fail=$(($fail + 1))
		rlFail $TEST/$i
	else
		myecho "\n:: [	 PASS	] :: RESULT $i\n"
		pass=$(($pass + 1))
		rlPass $TEST/$i
	fi
	sleep 10
#	rhts_submit_log -l $OUTPUTFILE
done

OUTPUTFILE=`mktemp /tmp/tmp.XXXXXX`
myecho "\n++++++++++++++++++++ Begin Testing Socket Functions ++++++++++++++++++++\n"	
./socket_func_server 2>&1 | tee -a $OUTPUTFILE &
sleep 5
./socket_func_client ::1 2>&1 | tee -a $OUTPUTFILE
if [ "`grep BROK $OUTPUTFILE`" ] || [ -z "`grep PASS $OUTPUTFILE`" ]; then
	myecho "\n:: [	 FAIL	] :: RESULT $i\n"
	fail=$(($fail + 1))
	rlFail $TEST/$i
else
	myecho "\n:: [	 PASS	] :: RESULT $i\n"
	pass=$(($pass + 1))
	rlPass $TEST/Socket_Functions
fi

make clean
popd

if [ $fail -gt 0 ];then
	rlFail $TEST/all
else
	rlPass $TEST/all
fi


spoof_part=$(($RANDOM % 1000 + 2000))
port=$(($RANDOM % 1000 + 6000))

echo "sysctl -a | grep 'net.ipv6.ip_nonlocal_bind'"
sysctl -a | grep 'net.ipv6.ip_nonlocal_bind'
if [ $? -ne 0 ]; then
	echo "Not supoort net.ipv6.ip_nonlocal_bind yet!"
	exit 0
fi

ping_with_nonlocal_ip()
{
	HA="ip netns exec ha"
	HB="ip netns exec hb"

	netns_1_net.sh
	rlRun "$HA ip -6 rule add from ::/0 iif ha_veth0 lookup 200"
	rlRun "$HA ip -6 route add local 2001:0:0:1::/64 dev lo proto kernel scope host table 200"
	rlRun "$HA ip -6 route add default dev ha_veth0"
	rlRun "$HA sysctl -w net.ipv6.ip_nonlocal_bind=1"
	rlRun "$HA ip -6 rule"
	rlRun "$HA ip -6 route show table 200"
	rlRun "$HA tcpdump -ni ha_veth0 ip6 -w nonlocal.pcap &"

	sleep 5

	rlRun "$HB ip addr add 2001:0:0:1::2/64 dev hb_veth0"
	rlRun "$HB ip -6 route"

	# In this test scenario, it will sent out 'echo request' packets, 
	# but won't receive 'echo reply'. So expect ping6 return non-zero(1)
	rlRun "$HA ping6 -I 2001:0:0:1::1 2001:0:0:1::2 -c 5" 1
	rlRun "pkill tcpdump"
	sleep 5
	tcpdump -nnr nonlocal.pcap | grep "2001:0:0:1::1 > 2001:0:0:1::2: ICMP6, echo request"
	if [ $? -eq 0 ]; then
		rlPass "ping6 with non local ip"
	else
		rlFail "ping6 with non local ip"
	fi
	netns_clean.sh
	#rhts_submit_log -l nonlocal.pcap
}

ping_with_nonlocal_ip
	rlPhaseEnd

	rlPhaseStartSetup
		rlRun "gcc -o nonlocalbind nonlocal_bind/nonlocal_bind.c"
	rlPhaseEnd

	rlPhaseStartTest "IPv6 non local bind test"
		rlRun "sysctl -w net.ipv6.ip_nonlocal_bind=0"
		# expect EADDRNOTAVAIL  99
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port stream tcp" 99
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port dgram udp" 99
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw tcp" 99
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw udp" 99
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw sctp" 99
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw icmp" 99

		rlRun "sysctl -w net.ipv6.ip_nonlocal_bind=1"
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port stream tcp"
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port dgram udp"
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw tcp"
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw udp"
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw sctp"
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port raw icmp"
		# seems that not support STREAM/SEQPACKET SCTP yet
		# enable sctp nonlocal bind testing, RHEL7.3 will support it.
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port seqpacket sctp"
		rlRun "./nonlocalbind 2016:${spoof_part}::2345 $port stream sctp"

		# bind link local ipv6 to sctp socket
		rlRun "get_test_iface"
		rlRun "iface_lladdr=`ip -6 addr sh $TEST_IFACE | grep fe80 | awk '{print $2}' | cut -d'/' -f1`"
		rlRun "./nonlocalbind $iface_lladdr $port stream sctp"
		rlRun "./nonlocalbind $iface_lladdr $port stream tcp"
		rlRun "./nonlocalbind $iface_lladdr $port dgram udp"
		rlRun "./nonlocalbind $iface_lladdr $port raw sctp"
		rlRun "./nonlocalbind $iface_lladdr $port raw tcp"
		rlRun "./nonlocalbind $iface_lladdr $port raw udp"
		rlRun "./nonlocalbind $iface_lladdr $port raw icmp"
	rlPhaseEnd

	rlPhaseStartCleanup
		rlRun "sysctl -w net.ipv6.ip_nonlocal_bind=0"
		rlRun "rm -rf nonlocalbind"
	rlPhaseEnd
rlJournalEnd

exit 0
