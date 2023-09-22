## msgs/ROOT.msg
#
# To translate the user interface strings to another language,
# make a copy of this file and store it in the same directory. Its
# name should be something like:
#
#     en.msg    for English, or
#     en_us.msg for US English, or
#     en_gb.msg for UK English
#     nl.msg    for Dutch, or
#     de.msg    for German, or
#     de_ch.msg for Swiss German, etc.
#
# ROOT.msg is the default language file and will be used if there
# is no msg-file matching the user's locale.
#
# This file must be encoded in UTF-8. Always check that your text editor
# displays the following characters correctly:
#     &euml : ë
#     &oelig : œ
#     &ccedil: ç
#     &euro : €


## specify the locale in the next statement:
#   {} for any, en for English, en_us for US English, en_gb for UK English
#   nl for Dutch, or de_ch for Swiss German, etc.

set locale {}

##
# In defintions for menus, buttons and notebook tabs, 1 character can
# be underlined, which has a special meaning for keyboard shortcuts:
# pressing ALT-<underlined character> invokes the menu, button or notebook
# tab. In this file, underlined characters are indicated by a "&" before
# the character that has to be underlined.

# Menu definitions
::msgcat::mcmset $locale {

mnuPacman
{&Pacman}

mnuLog
{Show pacman.&log}

mnuClean
{Clean cache}

mnuImport
{Install local package}

mnuQuit
{&Quit}

mnuTools
{&Tools}

mnuOptions
{&Options}

mnuIncrFont
{&Bigger fonts}

mnuDecrFont
{&Smaller fonts}

mnuHelp
{&Help}

mnuLicense
{&License}

mnuAbout
{&About}

}

# Button defintions
::msgcat::mcmset $locale {

btnOK
{&OK}

btnCancel
{&Cancel}

btnYes
{&Yes}

btnNo
{&No}

btnHelp
{&Help}

btnWrap
{&Wrap}

btnSearch
{&Search}

lbReadOnly
{READ ONLY}

btnLegend
{&Legend}

btnWebsite
{&Website}

btnRefresh
{&Resync
Database}

btnSysUpgrade
{System
&Upgrade}

rbAvailable
{&Available packages}

rbInstalled
{&Installed packages}

btnClose
{&Close}

mnuMark
{&Mark}

mnToggle
{Mark/Unmark}

mnMarkAll
{Mark all}

mnUnMarkAll
{Unmark all}

btnApply
{Apply
&Changes}

btnInstallFile
{&Local
Package}

btnInfo
{I&nfo}

btnFiles
{&Files}

btnApplyShort
{&Apply}

btnForget
{&Forget}

}

# Main window
::msgcat::mcmset $locale {
tkPacman
{tkPacman}

hdMark
{Mark}

hdName
{Name}

hdDescription
{Description}

generalYes
{yes}

generalNo
{no}

smallInfo
{name        : %1$s
description : %2$s
version     : %3$s
installed   : %4$s
groups      : %5$s
repository  : %6$s}

spaceDouble
{space, double click}

rbGroup
{&Group}

rbRepo
{Repo}

rbSearch
{&Word}

rbOrphans
{Orphans}

rbExplicit
{Explicit}

rbFilterOff
{&Off}

rbUpgrades
{Upgrades}

rbForeign
{Foreign}

rbFileOwner
{File owner}

adviceTerm
{You may need to install a terminal emulator program such as 'xterm' or 'lxterminal'.

Or you may need to modify the option 'terminal'. See Tools -> Options -> terminal.}

nrOfPackages
{Number of packages}

packagesListed
{Listed: }

markedInstall
{Marked for installation: }

markedRemoval
{Marked for removal: }

packagesAvail
{Available: }

packagesInstalled
{Installed: }

allAvailable
{All packages available in repositories}

filterWordAvailable
{All available packages containing word '%1$s' in 'name' or 'description'}

filterGroupAvailable
{All available packages in group '%1$s'}

allInstalled
{All installed packages}

filterWordInstalled
{All installed packages containing word '%1$s' in 'name' or 'description'}

filterGroupInstalled
{All installed packages in group '%1$s'}

filterRepoAvailable
{All packages available in repo '%1$s'}

filterRepoInstalled
{All packages installed from repo '%1$s'}

filterOrphans
{All packages installed as a dependency but not required anymore}

filterExplicit
{All packages explicitly installed and not required by another package}

filters
{Filters}

filterUpgrades
{Available upgrades}

filterForeign
{Installed packages that are not in the repositories}

filterFileowner
{Installed package that owns '%1$s'}

manyItems
{You are about to mark %1$s packages for %2$s.

Do you really want to do this?}

forInstallation
{installation}

forRemoval
{removal}


browser_failed
{Command %1$s has failed:
%2$s
Check the option 'browser'.
Use Tools -> Options.}

about_tkp
{tkPacman version %1$s

Copyright © Willem Herremans 2013

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

See 'Help -> License' for details.

The tkPacman website is at %5$s. There you can report bugs, request new features and get support.

tkPacman is using %3$s as Tcl run time environment. The Tcl version is %4$s.

tkPacman is installed in %2$s}

unappliedChanges {
There are still packages marked for %2$s:

%1$s

What do you want to do with that operation?}

closeTerminal
{Press ENTER to close the terminal. }

runAsRoot
{tkPacman - Run as root}

warningUpgrade
{The recommended way to perform a system upgrade is to press the 'System Upgrade' button.

Marking all the packages listed here and then pressing the 'Apply Changes' button, is not the same as pressing the 'System Upgrade' button.}

}

# import window
::msgcat::mcmset $locale {
tkPacmanImport
{tkPacman - Install package from local file}

lbImportFile
{Package file}

btnInstall
{&Install}

btnQuit
{&Quit}

}

# options.tcl
::msgcat::mcmset $locale {
optionsTitle
{tkPacman - Options}

optHelpTitle
{tkPacman - Help for option %s}

opt_arrow_down
{Open selection dialogue (arrow down)}

opt_expand
{Show option in expanded editor window (Alt-x)}

opt_reset
{Reset options to default value (Alt-r)}

opt_help
{Display help for this option (Alt-h)}

optHelp_browser
{Location of your favorite browser.

Default: xdg-open
}

optHelp_terminal {
The command by which the terminal program will be called to execute
pacman commands.

Using the drop down box, you can choose between the following terminal
invocation commands:

    lxterminal --title=%t --command=%c
    xterm -title %t -e %c
    vte --name=%t --command=%c
    roxterminal --title=%t --execute %c

On invocation, tkPacman replaces %t with an appropriate title for the
terminal window and %c with the command to execute in the terminal.

These commands are known to work. If you would like to use another
terminal, you can type a command instead of selecting one of these.

lxterminal is the default because it is both nice and lightweight.

I have tried the more sofisticated terminals like gnome-terminal,
konsole and xfce4-terminal, but I could not get them to work properly
in the context of tkPacman.}

optHelp_sudo {
Should tkPacman use 'sudo' for executing commands as 'root'?

If not, tkPacman will use 'su' for executing commands as 'root'.

Default: No.}

optPasteFilename
{&Paste filename}

}

# generic.tcl
::msgcat::mcmset $locale {

searchEOT
{End of text reached.
Find will return to begin of file now.}

lsbSearchFound
{'%s' found}

lsbSearchNotFound
{Begin of list}

mnuText
{&Text}

mnuTxtClose
{&Close}

mnuExtra
{&Extra}

miscChoose
{tkPacman - Choose}

miscValues
{Values}

fsDirectory
{Directory}

fsFilename
{Filename}

btnUp
{&Up}

fsSubdirectories
{Subsdirectories}

fsFiles
{Files}

btnNewdir
{&New subdirectory}

fsFiletype
{File type}

btnShowHidden
{&Show hidden}

fsLbNewDir
{Newdir}

fsNewDir
{Make new directory}

fsLegend
{Legend}

fsh_arrow_up
{Go to parent directory (Alt-p)}

fsh_arrow_top
{Go to root directory (Control-Home)}

fsh_home_dir
{Go to home directory (Alt-Home)}

fsh_arrow_down
{This listbox has keyboard input focus}

fsh_arrow_right
{This entry has keyboard input focus}

fsSearch
{Search}

}

# misc.tcl
::msgcat::mcmset $locale {
tkp_message
{tkPacman - message}

}

