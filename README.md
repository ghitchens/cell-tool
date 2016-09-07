CELL CLI
========

A CLI (Command Line Interface) to manage one or more Nerves "cells".

A **cell** is a Nerves device that supports a set of well known protocols for Discovery, updating firmware, network logging, and device management. See the [nerves_cell](http://github.com/ghitchens/nerves_cell) project for more information on cells.

## Installation

The `mix.exs` script installs the executable as as `/usr/local/bin/cell`.

If your user has write access to `/usr/local/bin`, you can simply:

```bash
$ mix escript.build
```

If this gives you permissions error, either grant yourself, group or user
write permission access to `/usr/local/bin`, or use sudo before the above command.

## Usage

```
$ cell -h
Manages one or more Nerves "cells" on a network

Commands:
  cell list [cells]         # Show cells on the local network
  cell info [cell]          # Show detailed information about a single cell
  cell push [cell]          # Push firmware to a cell (requires -f)
  cell watch [cell]         # Watch log of local cells on a network
  cell reboot [cell]        # Restart cell(s) (currently disabled)
  cell help [topic]         # Prints help information for commands

Options:
  -h, --help                # alias for `cell help`
  -v, --version             # Print version of `cell` tool
  -f, --firmware <foo.fw>   # Specify firmware file to use with "push"
  -S, --stype <type>        # limit search/ops to specific service type
```
