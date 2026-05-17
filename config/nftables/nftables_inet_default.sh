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

table inet filter {
	chain input {
		type filter hook input priority 0

		# Discard all packets not accepted by the ruleset
		policy drop

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
		type filter hook forward priority filter;
	}

	chain output {
		type filter hook output priority filter;
	}
}
HEREDOC
)

main() {
	echo "${nftables_configuration}"
}

main "${@}"
