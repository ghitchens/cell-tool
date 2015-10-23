CELL
====

A simple command line interface for managing cells built using modules from the
[Cellulose](cellulose.io) projects.

**Note:** All functions may not be usable with all cells. Since, all cells may
not implement all modules offered by the Cellulose Project.

## Installation

The `mix.exs` script installs the executable as as `/usr/local/bin/cell`.

If your user has write access to `/usr/local/bin`, you can simply:

```bash
$ mix escript.build
```

If this gives you permissions error, either grant yourself, group or user write
permission access to `/usr/local/bin`, or add `sudo` before the command like this:

```bash
$ sudo mix escript.build
```

## Usage

```
$ cell --help

cell list [<cells>]               list found cells (alias for discover for now)
cell discover [<cells>]           find cells using SSDP on the LAN
cell watch [<cells>]              watch multicast debug log of one or more cells
cell provision <cells> <app_id>   provisions a cell to the specified type
cell push <cells> <ware>          push specific firmware to one or more cells
cell inspect <cells> [<path>]    inspect a part of the Hub path
cell normal[ize] [<cells>]        make provisional firmware normal
cell denormal[ize] <cells>        make normal firmwae provisional
cell reboot <cells>               reboot a cell
cell [--help]                     shows this help message


Options:

  <cells>
        Specifies cell(s) to operate on, in one of the following formats:

        .nnn                    Last octet of the IP on the LAN in decimal

  <ware>
        Specifies the firmware (including path) to install, in one of the
        following formats:

        build/test.fw           Path to firmware in the filesystem

  <path>
        Specifies a path in the Hub tree to view, in the following formats:

        services

        services/firmware

        path/to/somewhere[/...]

  <app_id>
        Specifies the application ID to provision the cell to. Executes the
        method activate/2 found in ~/.cell/provision/<app_id>.ex, written for
        your particular needs. The return of this function is HTTP PUT to the
        device at the location returned by Finder plus /sys/firmware.

        The format of the <app_id> is to be one word or words joined by a '_'

        cr1a

        test_cell
```

## Configuration

Cell may be configured at runtime by placing a .conf file at `~/.cell/cell.conf`

Currently only the SSDP Service Type may be specified in the `~/.cell/cell.conf`
file.

    # Service Type for Cell tool to use in M-SEARCH
    cell.ssdp_st = "urn:someorg-com:service:cell:1"

By default Cell will conduct it's M-SEARCH requests with the Service Type:
`urn:cellulose-io:service:cell:1`

## Wishlist

    cell alias <cells> <alias>                Make an alias for one or more cells
    cell static <cell> <config>|clear         Set a static IP on a cell

## Contributing

We appreciate any contribution to Cellulose Projects, so check out our
[CONTRIBUTING.md](CONTRIBUTING.md) guide for more information. We usually keep
a list of features and bugs [in the issue tracker][issues]

[issues]: https://github.com/cellulose/ethernet/issues
