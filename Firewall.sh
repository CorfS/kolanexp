#!/bin/bash
iptables -F
iptables -X

iptables -N DENY
iptables -A DENY -p tcp -m tcp -m limit --limit 30/sec --limit-burst 100 -m comment --comment "Anti-DoS" -j REJECT --reject-with tcp-reset
iptables -A DENY -m limit --limit 30/sec --limit-burst 100 -m comment --comment "Anti-DoS" -j REJECT --reject-with icmp-proto-unreachable
iptables -A DENY -m comment --comment "Alles andere ignorieren" -j DROP

iptables -N SERVICES
iptables -A SERVICES -p tcp -m tcp --dport 53 -m comment --comment "Erlaube: DNS" -j ACCEPT
iptables -A SERVICES -p udp -m udp --dport 53 -m comment --comment "Erlaube: DNS" -j ACCEPT
iptables -A SERVICES -p tcp -m tcp --dport 22 -m comment --comment "Erlaube: SSH-Zugriff" -j ACCEPT
iptables -A SERVICES -j RETURN

iptables -N TEAMSPEAK
iptables -A TEAMSPEAK -p tcp -m tcp --dport 2008 -m comment --comment "Erlaube: TeamSpeak Accounting" -j ACCEPT
iptables -A TEAMSPEAK -p tcp -m tcp --dport 30033 -m comment --comment "Erlaube: TeamSpeak Avatar" -j ACCEPT
iptables -A TEAMSPEAK -p tcp -m tcp --dport 41144 -m comment --comment "Erlaube: TeamSpeak TSDNS" -j ACCEPT
iptables -A TEAMSPEAK -j RETURN

iptables -A INPUT -i lo -m comment --comment "Erlaube: Loopback" -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -m comment --comment "Erlaube: Related und Established Verbindungen" -j ACCEPT
iptables -A INPUT -m comment --comment "Erlaube Standard Dienste" -j SERVICES
iptables -A INPUT -m comment --comment "Erlaube TeamSpeak Dienste" -j TEAMSPEAK
iptables -A INPUT -p icmp -m comment --comment "Erlaube: ICMP" -j ACCEPT
iptables -A INPUT -m comment --comment "Ignoriere alles andere" -j DENY
iptables -P INPUT DROP
