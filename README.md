`BOX`
===

A simple command line interface for managing boxes based on the echo
framework.

For now, just handles discovery of nodes on the LAN and viewing the
debug logs of nodes that implement `logger_multicast_backend`.  Still,
that's pretty useful, if you ask me.

# Installation

	mix escript.build

# Usage

	box help		shows this help message
	box discover	find boxes on the network
	box watch		watch multicast debug log

