#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /kernel/networking/
#   Description: /home/weichen/workingfolder/inet6_ioctl
#   Author: Wei Chen <weichen@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2014 Red Hat, Inc. 
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Global parameters
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/share/beakerlib-libraries/kernel/Library/networking-common/include.sh


###reset_if()
###{

###        iface=$1

###        ip link set dev $iface down
###        ip addr flush dev $iface
###        ip link set dev $iface up
###        sleep 1
###}


###Cur_nic_iface=$(get_required_iface | awk '{ print $1 }')
###Sec_nic_iface=$(get_sec_iface)
###$(get_required_iface | awk '{ print $2 }')
###CLI_ADDR6_1="2012::11"

rlJournalStart

        rlPhaseStartSetup
###            rlRun "yum -y install lksctp-tools*"
            rlRun "gcc -o ipv6_icmpfilter ipv6_icmpfilter.c -lpthread -lc"
            rlRun "yum -y install libgcc.i686"
            rlRun "yum -y install glibc-static.i686"
            rlRun "yum -y install glibc-devel.i686"
            if [ `uname -p` == "x86_64" ];then
	    	rlRun "gcc -o ipv6_icmpfilter_32 ipv6_icmpfilter.c -m32"
            fi
###            Sec_nic_iface=$(get_sec_iface)
###            $(get_required_iface | awk '{ print $2 }')
###            rlRun "ip -6 addr flush dev $Sec_nic_iface"
###            reset_if $Sec_nic_iface
###            rlRun "ip addr add ${CLI_ADDR6_1}/64 dev $Sec_nic_iface"
        rlPhaseEnd

        rlPhaseStartTest
            rlRun "./ipv6_icmpfilter"
            if [ `uname -p` == "x86_64" ];then
	    	rlRun "./ipv6_icmpfilter_32"
	    fi
        rlPhaseEnd

        rlPhaseStartCleanup
            pkill "./ipv6_icmpfilter";
	    if [ `uname -p` == "x86_64" ];then
            	pkill "./ipv6_icmpfilter_32";
	    fi
        rlPhaseEnd

        rlJournalPrintText

rlJournalEnd
