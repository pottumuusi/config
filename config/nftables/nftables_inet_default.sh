#!/bin/bash

set -e

# readonly transfer_port=$(keepassxc-cli \
#         show --show-protected \
#         ${HOME}/my/data/for_programs/keepass/Database.kdbx \
#         "for_automation/backups/transfer_port" \
#         | grep "Password:" \
#         | tr -d ' ' \
#         | cut -d ':' -f 2)

readonly nftables_configuration=$(cat <<HEREDOC
#!/usr/sbin/nft -f

flush ruleset

# https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_workstation
# https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_server
# https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes

table inet filter {
	chain input {
		# Discard all packets not accepted by the ruleset
		type filter hook input priority 0; policy drop;

		# Accept traffic originated from us
		ct state established,related accept

		# Accept any localhost traffic
		iif lo accept

		# Allow traffic to port used for serving backups
		# tcp dport { ${transfer_port}, } accept
		tcp dport { 8000, } accept

		# Accept neighbour discovery otherwise IPv6 connectivity breaks
		icmpv6 type { nd-neighbor-solicit, nd-router-advert, nd-neighbor-advert } accept
	}

	chain forward {
		type filter hook forward priority 0; policy accept;
	}

	chain output {
		type filter hook output priority 0; policy accept;
	}
}
HEREDOC
)

main() {
	echo "${nftables_configuration}"
}

main "${@}"
