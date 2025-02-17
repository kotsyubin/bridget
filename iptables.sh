#!/bin/bash
# https://superuser.com/questions/203272/list-only-the-device-names-of-all-available-network-interfaces
IFACES=$(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d') 
echo "Found external interfaces: $IFACES"

function find_public_iface() {
    for i in $IFACES; do
    # https://stackoverflow.com/questions/75270465/linux-terminal-ping-but-only-true-false
    if ping -c1 -I $i $1 > /dev/null 2>&1; then
        PUBLIC_IFACE=$i
        IFACES=( "${IFACES[@]/$i}")
        echo "Ping to $1 successful. Setting our public interface to $i"
    fi
done
}

function flush_iptables() {
    echo "Flushing iptables rules"
    # https://serverfault.com/questions/200635/best-way-to-clear-all-iptables-rules
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -t nat -F
    iptables -t mangle -F
    iptables -F
    iptables -X
}

function get_netaddr() {
    IFACE_IP=$(ifconfig $2 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
    IFACE_MASK=$(ifconfig "$2" | sed -rn '2s/ .*:(.*)$/\1/p')
    # https://stackoverflow.com/questions/15429420/given-the-ip-and-netmask-how-can-i-calculate-the-network-address-using-bash
    IFS=. read -r i1 i2 i3 i4 <<< $IFACE_IP
    IFS=. read -r m1 m2 m3 m4 <<< $IFACE_MASK
    # https://unix.stackexchange.com/questions/615527/how-to-return-a-string-from-a-bash-function-without-forking
    declare -n result="$1"
    result=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")
}

function create_rules() {
    flush_iptables
    # https://serverfault.com/questions/7503/how-to-determine-if-a-bash-variable-is-empty
    if [ ! -z "${PUBLIC_IFACE}" ]; then
        echo "Public interface found: creating routes to it and bridging private networks"
        for i in $IFACES; do
            get_netaddr IFACE_NETADDR $i
            echo "iptables -t nat -A POSTROUTING -o $PUBLIC_IFACE -s $IFACE_NETADDR -j MASQUERADE"
            iptables -t nat -A POSTROUTING -o $PUBLIC_IFACE -s $IFACE_NETADDR -j MASQUERADE
            for e in ${IFACES[@]/$i}; do
                get_netaddr EFACE_NETADDR $e
                echo "iptables -t nat -A POSTROUTING -o $i -s $EFACE_NETADDR -j MASQUERADE"
                iptables -t nat -A POSTROUTING -o $i -s $EFACE_NETADDR -j MASQUERADE
            done
        done
    elif [ -z "${PUBLIC_IFACE}" ]; then
        echo "No public interface found: bridging private networks only"
        for i in $IFACES; do
            get_netaddr IFACE_NETADDR $i
            for e in ${IFACES[@]/$i}; do
                get_netaddr EFACE_NETADDR $e
                echo "iptables -t nat -A POSTROUTING -o $i -s $EFACE_NETADDR -j MASQUERADE"
                iptables -t nat -A POSTROUTING -o $i -s $EFACE_NETADDR -j MASQUERADE
            done
        done
    fi
}

find_public_iface 8.8.8.8
if [ ! -z "${PUBLIC_IFACE}" ]; then
    find_public_iface dl.astralinux.ru
fi
create_rules