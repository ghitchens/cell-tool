BOX
===

A simple command line interface for managing echo boxs (node hardware).  For now, handles discovery of nodes on the LAN and installing firmware.

# Installation

mix escript.build

# Usage

## `box list`

Lists all discoverable boxs in a simple text tabular format.

## `box show <box-id>`

Shows details about the box.

## `box push <firmware> box-id`
    
Pushes firmware to the associated box.



