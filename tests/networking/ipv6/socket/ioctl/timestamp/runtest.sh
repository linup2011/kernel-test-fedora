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

rlJournalStart

        rlPhaseStartSetup

            rlRun "yum install -y lksctp-tools-devel"
            rlRun "modprobe sctp"
            rlRun "gcc -o ipv6_ioctl_timestamp ipv6_ioctl_timestamp.c -lpthread -lsctp -lc"

        rlPhaseEnd

        rlPhaseStartTest

            rlRun "tcpdump -i any -vvv -n -nn -l -w /root/tcpdumplog.pcap &"
              
            rlRun "./ipv6_ioctl_timestamp" 0

        rlPhaseEnd

        rlPhaseStartCleanup
                
            pkill "./ipv6_ioctl_timestamp";
            pkill "tcpdump";
    
        rlPhaseEnd

        rlJournalPrintText

rlJournalEnd
