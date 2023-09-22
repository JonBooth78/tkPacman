##

Note: This is a copy of the [original distribution](http://sourceforge.net/projects/tkpacman/)

All that has changed here is I hacked around with it to make it run on my windows MSY2 environment and added reconciliation after applying changes so that any changes that failed to be applied are still selected.

To run on MSYS2 I made sure I had tcl and tk installed and then changed in to the directory with this in and ran `tclsh main.tcl` and set the options appropriately.  I also had to decrease the font size a bit to make the rows readable.

If you find this, feel free to do with it what you will, I needed something and this was my way of getting there.  I doubt I'll come back to it :-)

# Original Readme

tkPacman is a graphical user interface for pacman, the package
manager for Arch Linux.

Copyright © 2013-2020 Willem Herremans

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

A copy of the  GNU General Public License is included in the 'license'
subdirectory of this software package.

The home page of tkPacman can be found at:

http://sourceforge.net/projects/tkpacman/

There you can report bugs, request new features and get support.

tkPacman is completely written in Tcl/Tk. There is no need to compile
or build anything. The best way to install it is to use the AUR package
at:

https://aur.archlinux.org/packages/tkpacman/
