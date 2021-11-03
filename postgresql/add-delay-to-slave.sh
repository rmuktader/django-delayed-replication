

#!/bin/sh

# SLAVE_IP=172.20.0.3/32

# waits until postgresql-slave hostname becames resolvable
while ! getent hosts postgresql-slave ; do
  sleep 0.1
done
echo "Executing script to add delay to slave..."
# get IP of the PostgreSQL slave container
SLAVE_IP=$(getent hosts postgresql-slave | cut -f 1 -d ' ')

DELAY_MS=1000
INTERFACE_NAME=eth0

# tc - show / manipulate traffic control settings
# define the root queue and set priority to be the same for all traffic
tc qdisc add dev ${INTERFACE_NAME} root handle 1: prio priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
# qdisc add dev {INTERFACE_NAME} - adds a root queueing discipline on a network device $INTERFACE_NAME
# root handle 1: - it is a root discipline on the device with handle 1:
# See https://lartc.org/howto/lartc.qdisc.classful.html#AEN882 for details
# prio priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 - creates priority map with all priorities set to band/class 0
# See https://lartc.org/howto/lartc.qdisc.classful.html#AEN902 for details
# By default it creates classes 1:1, 1:2, 1:3

# any traffic that makes it into this queue will get delayed
tc qdisc add dev ${INTERFACE_NAME} parent 1:2 handle 20: netem delay ${DELAY_MS}ms
# qdisc add dev ${INTERFACE_NAME} - adds another queueing discipline on the network device $INTERFACE_NAME
# parent 1:2 handle 20: - it is a child discipline with handle 20: under the class 1:2
# See https://lartc.org/howto/lartc.qdisc.classful.html#AEN882
# netem delay ${DELAY_MS}ms - adds delay of ${DELAY_MS} ms
# See https://wiki.linuxfoundation.org/networking/netem#emulating_wide_area_network_delays

# filter direct traffic going into the slave DB into the queue defined above
tc filter add dev ${INTERFACE_NAME} parent 1:0 protocol ip u32 match ip dst "${SLAVE_IP}" flowid 1:2
# filter add dev ${INTERFACE_NAME} - adds a filter on the network device ${INTERFACE_NAME}
# parent 1:0 - the filter is added on class 1:0 which is a root discipline
# protocol ip - only filter IP protocol
# u32 match ip dst "${SLAVE_IP}" - matches destination IP with PostgreSQL slave container IP
# # See https://man7.org/linux/man-pages/man8/tc-u32.8.html for documentation on u32 matcher
# flowid 1:2 - assigns class 1:2 to the matched traffic (class 1:2 is a qdisc with a delay set by the previous command)