CELL
====

A simple command line interface for discovering and managing nerves devices that support the common discovery, firmware, and logging conventions (cells).

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

  ## Configuration Example

  Runtime configuration is possible by placing a file at `~/.cell/cell.conf`
  with the following format:

  ```bash
  # Service Type for Cell tool to use in M-SEARCH
  # Default: "urn:cellulose-io:serivce:cell:1"
  cell.ssdp_st = "urn:mydomain-com:service:audio:1"

  # Services Doc location relative to base path
  # Default: "jrtp"
  cell.services_path = "cell"
  ```

  ## Examples

      $ cell list
      1 cells found
      NAME	SERIAL#		TYPE	VERSION - 1 cell(s)
      .172	CP1-xxxxx	CP1	  1.1.1

      $ cell list -c .168
      0 cells found matching ".168"

      $ cell push -c .168 -f _images/firmware.fw
      Pushing '_images/firmwmare.fw' to ".168"
      cell: /jrtp/sys/firmware/current -> ok


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

