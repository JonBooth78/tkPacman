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

mnuOptimize
{Optimize pacman database}

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

mnuHelpFile
{&Display help}

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

btnCheckUp
{List
Upgrades}

btnSysUpgrade
{System
&Upgrade}

btnError
{Errors}

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

btnAll
{All}

btnNoLongerInstalled
{No longer installed}

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

initPackList
{

    Loading the package list}

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

rbPending
{Marked}

rbUpgrades
{Upgrades}

rbForeign
{Foreign}

rbFileOwner
{File owner}

adviceTerm
{There was a problem with running a pacman command as root.

This could mean that you have to modify the 'terminal' or 'runasroot'
options (see menu Tools -> Options), or that you have to install a
package required by the commands called in the 'terminal' or 'runasroot'
options.

The information above may help you to solve this problem.
}

nrOfPackages
{Number of packages}

packagesListed
{Listed: }

markedInstall
{Install: }

markedRemove
{Remove: }

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

filterPendingInstallation
{All packages marked for installation}

filterPendingRemoval
{All packages marked for removal}

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

Copyright © Willem Herremans 2013-2015

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See 'Help -> License' for details.

The tkPacman website is at %5$s. There you can report bugs, request new features and get support.

tkPacman is using %3$s as Tcl run time environment. The Tcl version is %4$s.

tkPacman is installed in %2$s}

unappliedChanges {
There are still packages marked for installation or removal:

installation: %1$s

removal: %2$s

What do you want to do with these operations?}

closeTerminal
{Press ENTER to close the terminal. }

runAsRoot
{tkPacman - Run as root}

warningUpgrade
{The recommended way to perform a system upgrade is to press the 'System Upgrade' button.

If there are any packages here, your systeem may have had a "partial upgrade".

It is highly recommended to install all the upgrades shown here.}

browserAsRoot
{tkPacman refuses to start browser as 'root'}

errorLog
{tkPacman - Error messages}

whichClean
{Clean cache}

helpClean
{Do you want to remove all packages from the cache, or only the pacakges that are no longer installed?}

DBPathWrong
{%1$s does not exist. Check /etc/pacman.conf}

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

    xfce4-terminal --disable-server --title=%t --command=%c
    konsole --nofork --caption %t -e %c
    mate-terminal --disable-factory --title=%t --command=%c
    roxterm --separate --title=%t --execute %c
    vte --name=%t --command=%c
    xterm -title %t -e %c

On invocation, tkPacman replaces %t with an appropriate title for the
terminal window and %c with the command to execute in the terminal.

These commands are known to work. If you would like to use another
terminal, you can type a command instead of selecting one of these.

The default is the first one of the list above that is actually
installed.

For use in the context of tkPacman, it is important that the terminal
program does not return control to tkPacman until the command '%c' has
been completed. Some terminal programs behave well in that respect:
xterm and vte. Others need to be called with a special option:
xfce4-terminal --disable-server, mate-terminal --disable-factory,
roxterm --separate, konsole --nofork. Still others I could not prevent
from returning control to tkPacman immediately: gnome-terminal,
lxterminal.}

optHelp_runasroot {
The command that tkPacman should use to execute pacman commands as root.

This string may contain some special symbols that will be interpreted
by tkPacman.

%p will be replaced with the pacman command to execute.

%close will be replaced with a message inviting the user to press
ENTER to close the terminal when the command has finished.

%terminal(cmdlist) will execute the commands from the argument 'cmdlist'
in the terminal emulation program defined by the option 'terminal'.
The commands in 'cmdlist' must be separated by ';'.

Using the drop down box, you can choose between the following runasroot
commands:

 1. %terminal(echo "%p" ; su --command="%p" ; read -p "%close")
 2. sudo --askpass %terminal(echo "%p" ; %p ; read -p "%close")
 3. gksu --description pacman %terminal(echo "%p" ; %p ; read -p "%close")
 4. kdesu %terminal(echo "%p" ; %p ; read -p "%close")

Choice 1 is the default. It requires you to type the root's password
on every invocation of a pacman command.

Choice 2 requires the package 'sudo' and a properly configured
'/etc/sudoers' file. It has the advantage that it caches your
password during a certain time (5 minutes by default). During that
time you can run another pacman command without having to type your
password again. sudo normally requires you to type your own password
instead of the 'root' password. If you are using KDE, it is probably
better to use 'kdesu'.

Choice 3 requires the package 'gksu'. gksu can keep the 'root' password
during the session or even store it in the gnome keyring. This minimizes
the number of times you have to type the 'root' password, but it is
less secure, because all commands can be run as root for as long as you
are logged in with your normal account.

Choice 4 requires the package 'kdebase-runtime'. kdesu is similar to
gksu, but belongs to the KDE desktop.

These commands are known to work. If you would like to use another
runasroot, you can type a command instead of selecting one of these.

Default: the first one from the above list.}

optHelp_allerrors
{This option determines whether tkPacman shows all errors or only
the most relevant ones.

Default: Not allerrors}

optPasteFilename
{&Paste filename}

optSelectbrowser
{Select browser}

optSelecttmpdir
{Select temporary directory.}

optHelp_tmpdir
{tkPacman occasionally makes temporary scripts in the directory defined
by 'tmpdir'.

tkPacman also uses this directory to make a copy of the package database
for the "List Upgrades" feature.

Some features of tkPacman may not work if the 'tmpdir' pathname contains
spaces.

Default: /tmp}

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
{New dir}

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

