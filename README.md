`CELL TOOL`
========

A simple command line interface for managing cells (see ghitchens/cell).

For now, just handles discovery of cells on the LAN and viewing the
debug logs of cells that implement `logger_multicast_backend`.  Still,
that's pretty useful, if you ask me.

# Installation

	mix deps.get
	mix escript.build    

# Usage
    
	cell help		            shows this help message
	cell discover [<cells>]	    find cells using SSDP on the LAN
	cell watch [<cells>]        watch multicast debug log of one or more cells
    cell push <ware> <cells>    push specific 'ware to one or more cells    
    cell update <cells>         update firmware from repository
    cell norm[alize] <cells>    make provisional 'ware normal
                    
    <ware>      Specifies firmware to be installed, as follows:

    build/test.fw           Path to firmware in the filesystem
    @production             Branch of firmware in a repository
    @2.1.5-pre              Specific version# of firmware from repo

    <cells>     Specifies cell(s) to operate on, as follows:

    .nnn                    Last octet of the IP on the LAN in decimal
    @xxxxxx                 Last 3 octets of the MAC address or serial
    %cr1a                   All cells with that device id
