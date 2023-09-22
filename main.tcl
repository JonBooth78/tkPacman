#!/usr/bin/tclsh

#######################################################################
# This is 'tkPacman', lightweight GUI front end for the Arch linux
# pacman utility.
#
# Copyright (C) 2013-2015 Willem Herremans
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# The home page for the tkPacman project is at
#
# http://sourceforge.net/projects/tkpacman
#
# There you can report bugs, request new features and get support.
#
# tkPacman is also published as a package in the AUR:
#
# https://aur.archlinux.org/packages/tkpacman
#
#######################################################################

package require Tk
package require msgcat
namespace import msgcat::mc
package require TclOO

## Load and init other sources

## config.tcl
source [file join [file dirname [file normalize [info script]]] config.tcl]
config::initConfig

## load string definitions from the msgs directory
msgcat::mcload $config::languageDir

## load and create images for icons
proc createBitmap {args} {
    lassign $args icon foreground background iconFile
    if {$iconFile eq {}} then {
        set iconFile "${icon}.xbm"
    }
    image create bitmap ::img::$icon \
        -file [file join $config::installDir icons $iconFile] \
        -foreground $foreground -background $background
    return
}

set grayIcons {}
lappend grayIcons arrow_down arrow_end arrow_home arrow_left arrow_right
lappend grayIcons empty_5_9 empty_9_5 expand files help reset
lappend grayIcons unmarkall unmarked
foreach icon $grayIcons {
    createBitmap $icon gray35
}
createBitmap arrow_up blue4
createBitmap arrow_top red4
createBitmap home_dir green4
createBitmap marked black green4 unmarked.xbm
createBitmap remove black red4 unmarked.xbm
createBitmap removeall red4 {} installall.xbm
createBitmap refresh blue4
createBitmap upgrade green4
createBitmap apply green4
createBitmap info white green4
createBitmap cancel red4
createBitmap installall green4
createBitmap box #C8A064
createBitmap directory #86ABD9
createBitmap errors gray35 {} error.xbm
createBitmap newerrors red {} error.xbm

image create photo ::img::tkpacman_icon \
    -file [file join $config::installDir icons "tkpacman-icon.png"]

image create photo ::img::warning \
    -file [file join $config::installDir icons "warning.png"]

global readonlyBackground
set readonlyBackground {#F3F0EB}

## misc.tcl
# miscelaneous procedures.
# namespaces geometry, TpOnlyTags
source [file join $config::installDir misc.tcl]

## generic.tcl
## general purpose classes: Class_with_getvar, GenDialog, GenForm, TextEdit, ListBox
source [file join $config::installDir generic.tcl]

## options.tcl
source [file join $config::installDir options.tcl]

proc installReturnBindings {} {
    # The default Tk binding for generating a button press event
    # is <KeyPress-space>. We extend that behaviour to <KeyPress-Return>
    bind TButton <KeyPress-Return> {event generate %W <KeyPress-space>}
    bind TCheckbutton <KeyPress-Return> {event generate %W <KeyPress-space>}
    bind TRadiobutton <KeyPress-Return> {event generate %W <KeyPress-space>}
    bind Button <KeyPress-Return> {event generate %W <KeyPress-space>}
    bind Checkbutton <KeyPress-Return> {event generate %W <KeyPress-space>}
    bind Radiobutton <KeyPress-Return> {event generate %W <KeyPress-space>}
    return
}

# Set all backgrounds equal.
# Without these adjustments, there are some ugly background colour
# differences in the KDE desktop. The toplevel windows take their
# background colour from KDE and the other widgets take it from
# the Tk theme.
set themeBackground [ttk::style lookup TFrame -background]
option clear
option add *Toplevel.background $themeBackground
option add *Message.background $themeBackground
{.} configure -background $themeBackground

# Common procedures

namespace eval comproc {
    namespace ensemble create -subcommands \
        [list runCmd runAsRoot runAsUser browse updateTxtWidget markURL]
}

namespace eval comproc {
    # For runCmd, $cmd is used in the Tcl 'exec' command.
    # That means that arguments containing spaces must be contained
    # in { and }. In other words, $cmd must be constructed using the
    # Tcl 'list' command as in the following example:
    # set cmd [list pacman --query --quiet --owns $filename]
    # Then, if $filename contains spaces, it will be included in { and }.
    proc runCmd {cmd errChan} {
        set allerrors [tkpOptions getOption general allerrors]
        set exec exec
        foreach arg $cmd {
            lappend exec $arg
        }
        # The errors produced by this procedure are usually not
        # relevant for the user. They are only interesting for
        # debugging. Additionally, pacman often returns with non-zero
        # exit code when no packages are returned, e.g.
        # pacman --query --upgrades when there are no upgrades.
        if {$allerrors} then {
            # We redirect the command's stderr to $errChan
            lappend exec 2>@ $errChan
        } else {
            # We redirect the command's stderr to tkPacman's stderr,
            # i.e. it is printed on the terminal from which tkPacman
            # was started. This prevents the generation of an error
            # just because the command has written something to stderr
            # e.g. a warning message.
            lappend exec 2>@ stderr
        }
        if {[catch $exec result]} then {
            if {$allerrors} then {
                set msg "Error executing '${cmd}'.\n${result}"
                chan puts $errChan $msg
            }
            set result {}
        }
        return $result
    }
}

namespace eval comproc {
    # For runAsRoot, $cmd is not used in the Tcl 'exec' command, but in
    # a shell command. Hence $cmd must follow the shell syntax here.
    # So, if a command argument may contain spaces, the argument must
    # be quoted as in the following example (use single quotes):
    # set cmd "pacman --upgrade '${filename}'"
    proc runAsRoot {cmd errChan} {
        set invokeTerm [tkpOptions getOption general terminal]
        set runasroot [tkpOptions getOption general runasroot]
        set tmpdir [tkpOptions getOption general tmpdir]
        set close [mc closeTerminal]
        set title [mc runAsRoot]
        # extract termcmd, the command that will be executed within the virtual terminal
        # It is also the argument of %terminal( ... ) in runasroot
        set first [string first {%terminal(} $runasroot]
        set last [string first {)} $runasroot $first]
        set termcmd [string range $runasroot "${first}+10" "${last}-1"]
        set termcmd [string map [list %p $cmd %close $close] $termcmd]
        # set filenames of scripts
        namespace import ::tcl::mathfunc::rand ::tcl::mathfunc::round
        set num [round [expr {[rand] * 10000}]]
        set xtermscript [file join $tmpdir tkpacman-${num}-xterm.sh]
        set cmdscript [file join $tmpdir tkpacman-${num}-cmd.sh]
        # replace %terminal(...) with $xtermscript in runasroot.
        # runasroot will be used in Tcl exec. So, use { and } to enclose
        # arguments that may contain spaces. Therefore we use [list $xtermscript]
        # instead of just $xtermscript in the following line.
        set runasroot [string replace $runasroot $first $last [list $xtermscript]]
        set invokeTerm [string map [list %t "'${title}'" %c "'${cmdscript}'"] $invokeTerm]
        # write tkpacman-xterm.sh in /tmp
        set xtermchan [open $xtermscript w]
        chan puts $xtermchan "#!/bin/sh"
        chan puts $xtermchan $invokeTerm
        chan close $xtermchan
        file attributes $xtermscript -permissions 0700
        # write tkpacman-cmd.sh in /tmp
        set cmdchan [open $cmdscript w]
        chan puts $cmdchan "#!/bin/sh"
        chan puts $cmdchan $termcmd
        chan close $cmdchan
        file attributes $cmdscript -permissions 0700
        set exec "exec $runasroot"
        # Errors generated by this procedure are usually important
        # for the user to help setting 'terminal' and 'runasroot'
        # options.
        if {[tkpOptions getOption general allerrors]} then {
            lappend exec 2>@ $errChan
        } else {
            # If !$allerrors, we don't redirect the command's stderr to
            # $errChan, but to the command's stdout. This means that
            # what the command writes to stderr is appended to the
            # exec's return value (variable 'error').
            # By doing so, we prevent simple warning messages from
            # external programs to generate an error (catch returns 0),
            # but if a serious error occurs (catch returns 1),
            # the information sent to stderr by one of the external
            # programs is present in 'error' and thus also in the error
            # message sent to the user.
            lappend exec 2>@1
        }
        # puts $exec
        if {[catch $exec error]} then {
            set msg "Error executing '${runasroot}'.\n"
            append msg "${error}\n"
            append msg "${xtermscript}:\n"
            append msg " 1    #!/bin/sh\n"
            append msg " 2    ${invokeTerm}\n"
            append msg "${cmdscript}:\n"
            append msg " 1    #!/bin/sh\n"
            append msg " 2    ${termcmd}\n\n"
            append msg [mc adviceTerm]
            chan puts $errChan $msg
        }
        file delete $xtermscript
        file delete $cmdscript
        return
    }
}

namespace eval comproc {
    proc browse {url parent} {
        global tcl_platform
        set user $tcl_platform(user)
        if {$user eq {root}} then {
            tkp_message [mc browserAsRoot] $parent
            return
        }
        set browser [tkpOptions getOption general browser]
        set exec [list exec $browser $url &]
        if {[catch $exec error]} then {
            tkp_message $error $parent
        }
        return
    }
}

namespace eval comproc {
    proc updateTxtWidget {txtWidget txt image} {
        $txtWidget configure -state normal
        foreach tag [$txtWidget tag names] {
            $txtWidget tag delete $tag
        }
        $txtWidget delete 1.0 end
        if {$image ne {}} then {
            $txtWidget image create end -image $image -pady 5 -padx 5
            $txtWidget insert end "\n"
        }
        $txtWidget insert end $txt
        $txtWidget configure -state disabled
        return
    }
}

namespace eval comproc {
    proc markURL {txtWidget parent} {
        set urlnr 0
        set defaultCursor [$txtWidget cget -cursor]
        foreach http {{http://} {https://}} {
            foreach startURL [$txtWidget search -nocase -all $http 1.0] {
                incr urlnr
                set afterURL [$txtWidget index "$startURL lineend"]
                set url [$txtWidget get -- $startURL $afterURL]
                set tag "url$urlnr"
                $txtWidget tag add $tag $startURL $afterURL
                $txtWidget tag configure $tag -foreground blue -underline 1
                $txtWidget tag bind $tag <1> \
                    [list comproc browse $url $parent]
                $txtWidget tag bind $tag <Enter> \
                    [list $txtWidget configure -cursor hand2]
                $txtWidget tag bind $tag <Leave> \
                    [list $txtWidget configure -cursor $defaultCursor]
            }
        }
        return
    }
}

##
# class MainWin
#   This is the class for the object associated with the main window.
#   There is only 1 object of this class. It is created when the
#   application starts.
# Instance variables:
#   - window: Tk pathname of main window
#   - packlist: is an array with the following elements
#       - packlist(list): the list of packages where each item is a list of:
#           $installed $name $description $version $groups $repo
#         Depending on $packlist(mode) it is the list of available or installed packages.
#       - packlist(mode): sync or query
#       - packlist(length): length of packlist(list)
#   - filter: an array with the following elements:
#       - filter(mode): one of off, search, group, repo, upgrades, orphans,
#           explicit, foreign, fileowner
#       - filter(pattern): word for filtering in mode search
#       - filter(currgroup): group for filtering in mode group
#       - filter(currepo): repo for filtering in mode repo
#       - filter(ownedfile): filename for filtering in mode fileowner
#   - nrOfMarked(total): total number of marked packages
#   - nrOfMarked(install): number of packages marked for installation
#   - nrOfMarked(remove): number of packages marked for removal
#   - marklist: list of the names of marked packages
#   - nrOfItems: number of items in packageBox
#   - errorlog: contains everything that is written to $writeErr channel
#   - writeErr: channel opened for writing. All error messages are
#       written to channel $writeErr.
#   - readErr: channel opened for reading and linked to channel $writeErr
#       in a 'chan pipe'. Everything written to channel $writeErr becomes
#       readable in channel $readErr.
#   - all the others are Tk pathnames of widgets
# Constructor arguments: none
##


oo::class create MainWin {

    variable window filter packlist marklist errorlog readErr writeErr \
        nrOfMarked nrOfItems \
        packageBox fBox btnApply btnError txtInfo \
        lbAvail mnMark btnFiles btnInfo \
        rbOrphans rbExplicit rbUpgrades rbForeign entSearch cmbGroup \
        menubar rbFileOwner cmbRepo txtError

    constructor {} {
        tkpOptions initOptions
        pacmanOptions initOptions
        installReturnBindings
        geometry::initGeometry
        my initFontSize
        set window {.}
        set packlist(mode) sync
        set packlist(list) {}
        set packlist(length) 0
        set filter(mode) off
        set filter(pattern) {}
        set filter(currgroup) {}
        set filter(currepo) {}
        set filter(ownedfile) {}
        set marklist(install) {}
        set marklist(remove) {}
        set errorlog {}
        set nrOfMarked(total) 0
        set nrOfMarked(install) 0
        set nrOfMarked(remove) 0
        set nrOfItems 0
        set txtError {}
        set writeErr stderr
        # register sudo askpass helper
        global env
        set env(SUDO_ASKPASS) [file join $config::installDir askpass askpass.tcl]
        wm title $window [mc tkPacman]
        wm iconphoto $window -default ::img::tkpacman_icon
        wm geometry $window [join [geometry::getSize main] {x}]
        my initWindow
        my setupErrChan
        my refreshPackagelist
        my refreshPackageBox
        set tpOnly [bindToplevelOnly $window <Destroy> [list [self object] destroy]]
        bind $tpOnly <Configure> {geometry::setSize main {%w %h}}
        return
    }

    destructor {
        chan event $readErr readable {}
        chan close $writeErr
        chan close $readErr
        geometry::saveGeometry
        return
    }
}

oo::define MainWin {
    method fillGroupCombo {combo} {
        if {$packlist(mode) eq {sync}} then {
            set cmd [list pacman --sync --groups]
            set grouplist [split [comproc runCmd $cmd $writeErr] "\n"]
        } else {
            set cmd [list pacman --query --groups]
            set fullist [split [comproc runCmd $cmd $writeErr] "\n"]
            set grouplist {}
            set prev {}
            foreach item $fullist {
                set group [lindex $item 0]
                if {$group ne $prev} then {
                    lappend grouplist $group
                    set prev $group
                }
            }
        }
        $combo configure -values [lsort $grouplist]
        return
    }
}

oo::define MainWin {
    method fillRepoCombo {} {
        $cmbRepo configure -values [pacmanOptions getRepolist]
        return
    }
}

oo::define MainWin {
    method refreshPackagelist {} {

        proc parseFirst {first} {
            set cursor 0
            set separator [string first "/" $first $cursor]
            set repo [string range $first $cursor $separator-1]
            set cursor [expr {$separator + 1}]
            set separator [string first " " $first $cursor]
            set name [string range $first $cursor $separator-1]
            set cursor [expr {$separator + 1}]
            set separator [string first " " $first $cursor]
            if {$separator >= 0} then {
                set version [string range $first $cursor $separator-1]
                set cursor [expr {$separator + 1}]
                if {[string index $first $cursor] eq "("} then {
                    incr cursor
                    set separator [string first ")" $first $cursor]
                    set groups [string range $first $cursor $separator-1]
                    set cursor [expr {$separator + 2}]
                } else {
                    set groups {}
                }
            } else {
                set version [string range $first $cursor end]
                set groups {}
            }
            return [list $repo $name $version $groups]
        }

        # Show "loading package list" before really loading it
        # Thus the tkPacman window appears faster on the screen and
        # the user is informed about what is happening.
        comproc updateTxtWidget $txtInfo [mc initPackList] {}
        update
        if {$packlist(mode) eq {sync}} then {
            # get installed list
            set cmd [list pacman --query --quiet]
            set packlist(installed) [lsort [split [comproc runCmd $cmd $writeErr] "\n"]]
        }
        set cmd [list pacman --$packlist(mode) --search {}]
        set pacout [split [comproc runCmd $cmd $writeErr] "\n"]
        set last [expr {[llength $pacout] - 1}]
        set packlist(list) {}
        for {set i 0} {$i < $last} {incr i 2} {
            set first [lindex $pacout $i]
            lassign [parseFirst $first] repo name version groups
            set description [string trim [lindex $pacout $i+1]]
            if {$packlist(mode) eq {sync}} then {
                set installed [expr {[lsearch -sorted $packlist(installed) $name] >= 0}]
            } else {
                set installed 1
            }
            lappend packlist(list) [list $installed $name $description $version $groups $repo]
        }
        unset pacout
        set packlist(list) [lsort -index 1 $packlist(list)]
        set packlist(length) [llength $packlist(list)]
    }
}

oo::define MainWin {
    method getOwnedFile {} {
        set fs [FileSelection new -parent $window]
        set filename [$fs wait]
        return $filename
    }
}

oo::define MainWin {
    method refreshPackageBox {} {
        foreach tag {installed marked} {
            $packageBox tag remove $tag
        }
        set nrOfItems 0
        $packageBox delete [$packageBox children {}]
        if {$nrOfMarked(total) > 0} then {
            $btnApply state !disabled
            set marklist(install) [lsort $marklist(install)]
            set marklist(remove) [lsort $marklist(remove)]
        } else {
            $btnApply state disabled
        }
        if {$packlist(mode) eq {sync}} then {
            set operation install
        } else {
            set operation remove
        }
        # Determine pacman command to get a list of filtered packages.
        # The list should only contain the package names. This usually
        # means that the "--quiet" option must be used.
        set cmd {}
        if {$filter(mode) eq {group}} then {
            set cmd [list pacman --$packlist(mode) --quiet --groups $filter(currgroup)]
        } elseif {$filter(mode) eq {repo}} then {
            set cmd [list pacman --sync --quiet --list $filter(currepo)]
        } elseif {$filter(mode) eq {orphans}} then {
            set cmd [list pacman --query --quiet --deps --unrequired]
        } elseif {$filter(mode) eq {explicit}} then {
            set cmd [list pacman --query --quiet --explicit --unrequired]
        } elseif {$filter(mode) eq {upgrades}} then {
            set cmd [list pacman --query --quiet --upgrades]
        } elseif {$filter(mode) eq {foreign}} then {
            set cmd [list pacman --query --quiet --foreign]
        } elseif {$filter(mode) eq {fileowner}} then {
            set cmd [list pacman --query --quiet --owns $filter(ownedfile)]
        }
        if {$cmd ne {}} then {
            set filterList [lsort [split [comproc runCmd $cmd $writeErr] "\n"]]
        } elseif {$filter(mode) eq {pending}} then {
            set filterList $marklist($operation)
        } else {
            set filterList {}
        }
        foreach package $packlist(list) {
            set addPackage 0
            set installed [lindex $package 0]
            set name [lindex $package 1]
            set description [lindex $package 2]
            if {$filter(mode) eq {off}} then {
                set addPackage 1
            } elseif {$filter(mode) eq {search}} then {
                if {([string length $filter(pattern)] == 0) || \
                    [string match -nocase "*${filter(pattern)}*" $name] || \
                    [string match -nocase "*${filter(pattern)}*" $description]} then {
                    set addPackage 1
                }
            } else {
                if {[lsearch -sorted $filterList $name] >= 0} then {
                    set addPackage 1
                }
            }
            if {$addPackage} then {
                incr nrOfItems
                set item [$packageBox insert {} end -values [list $name $description]]
                if {$installed} then {
                    $packageBox tag add installed $item
                }
                if {[lsearch -sorted $marklist($operation) $name] >= 0} then {
                    $packageBox tag add marked $item
                    if {$packlist(mode) eq {sync}} then {
                        $packageBox item $item -image ::img::marked
                    } else {
                        $packageBox item $item -image ::img::remove
                    }
                } else {
                    $packageBox item $item -image ::img::unmarked
                }
            }
        }
        set first [lindex [$packageBox children {}] 0]
        $packageBox selection set $first
        $packageBox focus $first
        $packageBox see $first
        focus $packageBox
        if {$nrOfItems > 0} then {
            $menubar entryconfigure 1 -state normal
            $btnInfo state {!disabled}
            if {$packlist(mode) eq {query}} then {
                $btnFiles state {!disabled}
            } else {
                $btnFiles state disabled
            }
        } else {
            $menubar entryconfigure 1 -state disabled
            $btnInfo state disabled
            $btnFiles state disabled
        }
        if {$packlist(mode) eq {sync}} then {
            if {$filter(mode) eq {off}} then {
                set label [mc allAvailable]
            } elseif {$filter(mode) eq {search}} then {
                if {$filter(pattern) eq {}} then {
                    set label [mc allAvailable]
                } else {
                    set label [mc filterWordAvailable $filter(pattern)]
                }
            } elseif {$filter(mode) eq {group}} then {
                set label [mc filterGroupAvailable $filter(currgroup)]
            } elseif {$filter(mode) eq {repo}} then {
                set label [mc filterRepoAvailable $filter(currepo)]
            } elseif {$filter(mode) eq {upgrades}} then {
                set label [mc filterUpgrades]
            } elseif {$filter(mode) eq {pending}} then {
                set label [mc filterPendingInstallation]
            } else {
                set label {}
            }
        } elseif {$packlist(mode) eq {query}} then {
            if {$filter(mode) eq {off}} then {
                set label [mc allInstalled]
            } elseif {$filter(mode) eq {search}} then {
                if {$filter(pattern) eq {}} then {
                    set label [mc allInstalled]
                } else {
                    set label [mc filterWordInstalled $filter(pattern)]
                }
            } elseif {$filter(mode) eq {group}} then {
                set label [mc filterGroupInstalled $filter(currgroup)]
            } elseif {$filter(mode) eq {repo}} then {
                set label [mc filterRepoInstalled $filter(currepo)]
            } elseif {$filter(mode) eq {orphans}} then {
                set label [mc filterOrphans]
            } elseif {$filter(mode) eq {explicit}} then {
                set label [mc filterExplicit]
            } elseif {$filter(mode) eq {foreign}} then {
                set label [mc filterForeign]
            } elseif {$filter(mode) eq {fileowner}} then {
                set label [mc filterFileowner $filter(ownedfile)]
            } elseif {$filter(mode) eq {pending}} then {
                set label [mc filterPendingRemoval]
            } else {
                set label {}
            }
        } else {
            chan puts $writeErr "refreshPackageBox: wrong packlist(mode) '$packlist(mode)'"
            set label {}
        }
        $fBox configure -text $label
        if {$packlist(mode) eq {sync}} then {
            $rbOrphans state disabled
            $rbExplicit state disabled
            $rbUpgrades state {!disabled}
            $rbForeign state disabled
            $rbFileOwner state disabled
        } else {
            $rbOrphans state {!disabled}
            $rbExplicit state {!disabled}
            $rbUpgrades state disabled
            $rbForeign state {!disabled}
            $rbFileOwner state {!disabled}
        }
        if {$filter(mode) eq {upgrades}} then {
            update
            comproc updateTxtWidget $txtInfo [mc warningUpgrade] \
                ::img::warning
        }
        return
    }
}

oo::define MainWin {
    method onImport {} {
        set importObj [ImportWin new -parent $window -errorchan $writeErr]
        return
    }
}

oo::define MainWin {
    method onApply {refreshBox} {
        if {$nrOfMarked(total) > 0} then {
            if {$nrOfMarked(remove) > 0} then {
                set cmd "pacman --remove $marklist(remove)"
                comproc runAsRoot $cmd $writeErr
            }
            if {$nrOfMarked(install) > 0} then {
                set cmd "pacman --sync $marklist(install)"
                comproc runAsRoot $cmd $writeErr
            }
            set marklist(install) {}
            set marklist(remove) {}
            set nrOfMarked(total) 0
            set nrOfMarked(install) 0
            set nrOfMarked(remove) 0
            $btnApply state disabled
            my refreshPackagelist
            if {$refreshBox} then {
                my refreshPackageBox
            }
        } else {
            chan puts $writeErr "onApply: btnApply active but nrOfMarked(total) = 0"
        }
        return
    }
}

oo::define MainWin {
    method onInfo {} {
        set item [$packageBox selection]
        set packname [lindex [$packageBox item $item -values] 0]
        set cmd [list pacman --$packlist(mode) --info $packname]
        comproc updateTxtWidget $txtInfo [comproc runCmd $cmd $writeErr] {}
        comproc markURL $txtInfo $window
        return
    }
}

oo::define MainWin {
    method onFiles {} {
        set item [$packageBox selection]
        set packname [lindex [$packageBox item $item -values] 0]
        set cmd [list pacman --query --quiet --list $packname]
        comproc updateTxtWidget $txtInfo [comproc runCmd $cmd $writeErr] {}
        return
    }
}

oo::define MainWin {
    method unappliedChanges {} {
        if {$nrOfMarked(total) > 0} then {
            set dlg [GenDialog new \
                -parent $window \
                -title [mc tkPacman] \
                -message [mc unappliedChanges $marklist(install) $marklist(remove)] \
                -msgWidth 500 \
                -buttonList {btnApplyShort btnForget} \
                -defaultButton btnApply]
            if {[$dlg wait] eq {btnApplyShort}} then {
                update
                my onApply 0
            } else {
                set nrOfMarked(total) 0
                set nrOfMarked(install) 0
                set nrOfMarked(remove) 0
                set marklist(install) {}
                set marklist(remove) {}
                $btnApply state disabled
                update
            }
        }
        return
    }
}

oo::define MainWin {
    method onToggleMark {} {
        if {$packlist(mode) eq {sync}} then {
            set operation install
        } else {
            set operation remove
        }
        set item [$packageBox selection]
        set package [lindex [$packageBox item $item -values] 0]
        if {[$packageBox tag has marked $item]} then {
            $packageBox tag remove marked $item
            $packageBox item $item -image ::img::unmarked
            set pkgIndex [lsearch -exact $marklist($operation) $package]
            if {$pkgIndex >= 0} then {
                set marklist($operation) [lreplace $marklist($operation) $pkgIndex $pkgIndex]
                incr nrOfMarked(total) -1
                incr nrOfMarked($operation) -1
            } else {
                chan puts $writeErr "onToggleMark: unmarking package that is not in 'marklist'"
            }
        } else {
            $packageBox tag add marked $item
            if {$packlist(mode) eq {sync}} then {
                $packageBox item $item -image ::img::marked
            } else {
                $packageBox item $item -image ::img::remove
            }
            lappend marklist($operation) $package
            incr nrOfMarked(total) 1
            incr nrOfMarked($operation) 1
        }
        if {$nrOfMarked(total) > 0} then {
            $btnApply state {!disabled}

        } else {
            $btnApply state disabled
        }
        return
    }
}

oo::define MainWin {
    method onMarkAll {} {
        if {$packlist(mode) eq {sync}} then {
            set operation install
        } else {
            set operation remove
        }
        set apply 0
        if {$nrOfItems > 50} then {
            if {$packlist(mode) eq {sync}} then {
                set forOp [mc forInstallation]
            } else {
                set forOp [mc forRemoval]
            }
            set dlg [GenDialog new \
                -parent $window \
                -title [mc tkPacman] \
                -message [mc manyItems $nrOfItems $forOp] \
                -msgWidth 500 \
                -buttonList {btnYes btnNo} \
                -defaultButton btnNo]
            set apply [expr {[$dlg wait] eq {btnYes}}]
        } else {
            set apply 1
        }
        if {$apply} then {
            foreach item [$packageBox children {}] {
                if {![$packageBox tag has marked $item]} then {
                    $packageBox tag add marked $item
                    if {$packlist(mode) eq {sync}} then {
                        $packageBox item $item -image ::img::marked
                    } else {
                        $packageBox item $item -image ::img::remove
                    }
                    set package [lindex [$packageBox item $item -values] 0]
                    lappend marklist($operation) $package
                    incr nrOfMarked(total) 1
                    incr nrOfMarked($operation) 1
                }
            }
            $btnApply state {!disabled}
        }
        return
    }
}

oo::define MainWin {
    method onUnMarkAll {} {
        if {$packlist(mode) eq {sync}} then {
            set operation install
        } else {
            set operation remove
        }
        foreach item [$packageBox tag has marked] {
            $packageBox item $item -image ::img::unmarked
            set package [lindex [$packageBox item $item -values] 0]
            set pkgIndex [lsearch -exact $marklist($operation) $package]
            if {$pkgIndex >= 0} then {
                set marklist($operation) [lreplace $marklist($operation) $pkgIndex $pkgIndex]
                incr nrOfMarked(total) -1
                incr nrOfMarked($operation) -1
            } else {
                chan puts $writeErr "onUnMarkAll: removing package not in marklist"
            }
        }
        $packageBox tag remove marked
        if {$nrOfMarked(total) == 0} then {
            $btnApply state disabled
        }
        return
    }
}

oo::define MainWin {
    method onRightClick {x y X Y} {
        set item [$packageBox identify item $x $y]
        $packageBox selection set $item
        $packageBox focus $item
        tk_popup $mnMark $X $Y
        return
    }
}

oo::define MainWin {
    method onSearch {} {
        set filter(mode) search
        set filter(currgroup) {}
        set filter(currepo) {}
        my refreshPackageBox
        return
    }
}

oo::define MainWin {
    method onFilterSwitch {} {
        set filter(pattern) {}
        set filter(currgroup) {}
        set filter(currepo) {}
        set filter(ownedfile) {}
        if {$filter(mode) eq {search}} then {
            focus $entSearch
        } elseif {$filter(mode) eq {group}} then {
            focus $cmbGroup
        } elseif {$filter(mode) eq {repo}} then {
            focus $cmbRepo
        } elseif {$filter(mode) eq {fileowner}} then {
            set filter(ownedfile) [my getOwnedFile]
            my refreshPackageBox
        } elseif {$filter(mode) in {off pending upgrades orphans explicit foreign}} then {
            my refreshPackageBox
        }
        return
    }
}

oo::define MainWin {
    method onModeSwitch {} {
        # This method is called when the user presses one of the radiobuttons
        # for Available or Installed packages
        if {(($packlist(mode) eq {sync}) && ($filter(mode) in {orphans explicit foreign fileowner})) || \
            (($packlist(mode) eq {query}) && ($filter(mode) in {upgrades}))} then {
            set filter(mode) off
            set filter(pattern) {}
            set filter(currgroup) {}
            set filter(currepo) {}
            set filter(ownedfile) {}
        }
        if {$packlist(mode) eq {sync}} then {
            $lbAvail configure -text [mc packagesAvail]
            $mnMark entryconfigure 0 -image ::img::marked
            $mnMark entryconfigure 1 -image ::img::installall
        } else {
            $lbAvail configure -text [mc packagesInstalled]
            $mnMark entryconfigure 0 -image ::img::remove
            $mnMark entryconfigure 1 -image ::img::removeall
        }
        my refreshPackagelist
        my refreshPackageBox
        return
    }
}

oo::define MainWin {
    method onSelectGroup {} {
        # my unappliedChanges
        set filter(mode) group
        set filter(pattern) {}
        set filter(currepo) {}
        set filter(ownedfile) {}
        my refreshPackageBox
        return
    }
}

oo::define MainWin {
    method onSelectRepo {} {
        # my unappliedChanges
        set filter(mode) repo
        set filter(pattern) {}
        set filter(currgroup) {}
        set filter(ownedfile) {}
        my refreshPackageBox
        return
    }
}

oo::define MainWin {
    method onCheckUpgrades {} {
        set DBPath [pacmanOptions getOption options DBPath]
        if {$DBPath eq {}} then {
            set DBPath {/var/lib/pacman}
        }
        set DBPath [file normalize $DBPath]
        set DBLocal [file join $DBPath local]
        if {![file exists $DBPath]} then {
            tkp_message [mc DBPathWrong $DBPath] $window
        } elseif {![file exists $DBLocal]} then {
            tkp_message [mc DBPathWrong $DBLocal] $window
        } else {
            set tmpdir [tkpOptions getOption general tmpdir]
            set tmpDB [file join $tmpdir tkpacman]
            set tmpLocal [file join $tmpDB local]
            if {![file exists $tmpDB]} then {
                file mkdir $tmpDB
            }
            if {![file exists $tmpLocal]} then {
                file link -symbolic $tmpLocal $DBLocal
            } elseif {[file link $tmpLocal] ne $DBLocal} then {
                file delete $tmpLocal
                file link -symbolic $tmpLocal $DBLocal
            }
            namespace import ::tcl::mathfunc::rand ::tcl::mathfunc::round
            set num [round [expr {[rand] * 10000}]]
            set script [file join $tmpdir checkupgrades-${num}.sh]
            set chan [open $script w]
            chan puts $chan "#!/bin/sh"
            chan puts $chan "echo \"fakeroot -- pacman --sync --refresh --dbpath '${tmpDB}'\""
            chan puts $chan "fakeroot -- pacman --sync --refresh --dbpath '${tmpDB}'"
            chan puts $chan "echo \"\""
            chan puts $chan "echo \"pacman --query --upgrades --dbpath '${tmpDB}'\""
            chan puts $chan "pacman --query --upgrades --dbpath '${tmpDB}'"
            chan puts $chan "echo \"\""
            chan puts $chan "read -p \"[mc closeTerminal]\""
            chan close $chan
            file attributes $script -permissions 0700
            set terminal [tkpOptions getOption general terminal]
            # set cmd "'${script}'"
            # Some terminal emulators (e.g. qterminal don't like that %c
            # is enclosed in single quotes. Removing the single quotes
            # could be a problem if ${cmd} contains spaces. Normally,
            # it is something like /tmp/checkupgrades-xxx.sh. So it would
            # only contain spaces if $tmpdir does. Therefore I have decided
            # to leave out the single quotes.
            set cmd ${script}
            set exec exec
            foreach par $terminal {
                set par [string map [list %t "tkPacman" %c ${cmd}] $par]
                lappend exec $par
            }
            # puts $exec
            if {[catch $exec error]} then {
                chan puts $writeErr $error
            }
            file delete $script
        }
        return
    }
}

oo::define MainWin {
    method onSysUpgrade {} {
        # my unappliedChanges
        comproc runAsRoot "pacman --sync --refresh --sysupgrade" $writeErr
        my refreshPackagelist
        my refreshPackageBox
        return
    }
}

oo::define MainWin {
    method onQuit {} {
        my unappliedChanges
        destroy $window
        return
    }
}

oo::define MainWin {
    method onErrorLog {} {
        set txtError [TextEdit new $window [mc errorLog] $errorlog 1]
        $txtError defineCallBack [list [self object] destroyErrWindow]
        $btnError state disabled
        return
    }
}

oo::define MainWin {
    method destroyErrWindow {} {
        $txtError destroy
        set txtError {}
        set errorlog {}
        $btnError state !disabled
        $btnError configure -image ::img::errors
        return
    }
}

##
# MainWin displayHelp
##

oo::define MainWin {
    method displayHelp {} {
        set helpFolder [file join $::config::docDir en]
        foreach locale [lrange [::msgcat::mcpreferences] 0 end-1] {
            set translatedFolder [file join $::config::docDir $locale]
            if {[file exists $translatedFolder] && \
                [file isdirectory $translatedFolder]} then {
                set helpFolder $translatedFolder
                break
            }
        }
        set helpfile [file join $helpFolder help.txt]
        if {[catch {open $helpfile r} helpchan]} then {
            chan puts $writeErr $helpchan
        } else {
            set helptext [chan read $helpchan]
            chan close $helpchan
            set txtEdit [TextEdit new $window "tkPacman - Help" $helptext 1]
            $txtEdit setWrap "word"
            $txtEdit renderBold
            set txtWidget [$txtEdit getvar txtWidget]
            comproc markURL $txtWidget $window
        }
        return
    }
}

##
# MainWin displayAbout
#   This method displays the about information by creating a GenDialog
#   object.
##

oo::define MainWin {
    method displayAbout {} {
        variable ::config::version
        variable ::config::installDir
        variable ::config::website
        set dlg [GenDialog new -parent $window -title tkPacman \
            -message [mc about_tkp $version $installDir \
                [info nameofexecutable] [info patchlevel] $website] \
            -msgWidth 500 -defaultButton btnOK -buttonList [list btnOK btnWebsite]]
        if {[$dlg wait] eq {btnWebsite}} then {
            comproc browse $website $window
        }
        return
    }
}

##
# MainWin displayLicense
#   This method displays the GNU license in a text window.
##

oo::define MainWin {
    method displayLicense {} {
        set filename [file join $::config::licenseDir license.txt]
        if {[catch {open $filename r} chan]} then {
            set textEdit [TextEdit new $window License $chan 1]
        } else {
            set textEdit [TextEdit new $window License [chan read $chan] 1]
            chan close $chan
        }
        return
    }
}


oo::define MainWin {
    method showLog {} {
        set filename [file join / var log pacman.log]
        if {[catch {open $filename r} chan]} then {
            set textEdit [TextEdit new $window "pacman.log" $chan 1]
        } else {
            set textEdit [TextEdit new $window "pacman.log" [chan read $chan] 0]
            chan close $chan
            set txtWidget [$textEdit getvar txtWidget]
            $txtWidget see end
            $txtWidget mark set insert end
        }
        focus $txtWidget
        return
    }
}

oo::define MainWin {
    method cleanCache {} {
        set dlg [GenDialog new -title [mc whichClean] \
            -message [mc helpClean] \
            -msgWidth 400 \
            -buttonList [list btnCancel btnAll btnNoLongerInstalled] \
            -defaultButton btnNoLongerInstalled]
        set result [$dlg wait]
        update
        if {$result eq "btnAll"} then {
            set cmd "pacman --sync --clean --clean"
            comproc runAsRoot $cmd $writeErr
        } elseif {$result eq "btnNoLongerInstalled"} then {
            set cmd "pacman --sync --clean"
            comproc runAsRoot $cmd $writeErr
        }
        return
    }
}

oo::define MainWin {
    method optimizeDB {} {
        comproc runAsRoot pacman-optimize $writeErr
        return
    }
}


##
# MainWin changeFontSize $increment
#   This method increases or decreases the font size by 'increment'
#
# arguments:
#   increment: +1 or -1
##

oo::define MainWin {
    method changeFontSize {increment} {
        foreach font {TkDefaultFont TkTextFont TkFixedFont TkMenuFont TkHeadingFont} {
            set size [font configure $font -size]
            if {$size > 0} then {
                font configure $font -size [expr $size + $increment]
            } else {
                font configure $font -size [expr $size - $increment]
            }
        }
        set fontincrement [tkpOptions getOption general fontincrement]
        incr fontincrement $increment
        tkpOptions setOption general fontincrement $fontincrement
        tkpOptions saveOptions
        return
    }
}

##
# MainWin initFontSize
#   This method sets the fontsize as stored in tkpOption general fontincrement
#
# arguments:
#   none
#

oo::define MainWin {
    method initFontSize {} {
        set fontincrement [tkpOptions getOption general fontincrement]
        foreach font {TkDefaultFont TkTextFont TkFixedFont TkMenuFont TkHeadingFont} {
            set size [font configure $font -size]
            if {$size > 0} then {
                font configure $font -size [expr $size + $fontincrement]
            } else {
                font configure $font -size [expr $size - $fontincrement]
            }
        }
        return
    }
}


oo::define MainWin {
    method setupErrChan {} {
        lassign [chan pipe] readErr writeErr
        chan configure $readErr -encoding utf-8 -buffering line
        chan configure $writeErr -encoding utf-8 -buffering line
        chan event $readErr readable [list [self object] processErrChan]
        return
    }
}

oo::define MainWin {
    method processErrChan {} {
        if {![chan eof $readErr]} then {
            set error "[chan gets $readErr]\n"
            append errorlog $error
            $btnError configure -image ::img::newerrors
            if {$txtError ne {}} then {
                $txtError appendText $error black
            }
        } else {
            chan event $readErr readable {}
        }
        return
    }
}


oo::define MainWin {
    method setupTop {parent} {
        set pnTop [ttk::frame [appendToPath $parent pnTop] -relief flat]
        set fBox [ttk::labelframe [appendToPath $pnTop fBox] \
            -text [mc allAvailable] -labelanchor n]
        set packageBox [ttk::treeview [appendToPath $fBox pBox] \
            -columns {name description} \
            -selectmode browse \
            -show {tree headings} \
            -height 1]
        $packageBox column #0 -width 45 -stretch 0
        $packageBox column name -width 150 -stretch 0
        $packageBox column description -width 150 -stretch 1
        $packageBox heading #0 -text [mc hdMark]
        $packageBox heading name -text [mc hdName]
        $packageBox heading description -text [mc hdDescription]
        $packageBox tag configure installed -foreground green4
        set vsb [ttk::scrollbar [appendToPath $fBox vsb] \
            -orient vertical \
            -command [list $packageBox yview]]
        $packageBox configure -yscrollcommand [list $vsb set]
        pack $packageBox -side left -expand 1 -fill both
        pack $vsb -side left -fill y
        pack $fBox -side top -expand 1 -fill both -pady {5 0}
        bind $packageBox <<TreeviewSelect>> [list [self object] displaySmallInfo]
        bind $packageBox <3> [list [self object] onRightClick %x %y %X %Y]
        bind $packageBox <KeyPress-space> [list [self object] onToggleMark]
        bind $packageBox <Double-Button-1> [list [self object] onToggleMark]

        return $pnTop
    }
}

oo::define MainWin {
    method displaySmallInfo {} {
        if {$nrOfItems > 0} then {
            set item [$packageBox selection]
            set packname [lindex [$packageBox item $item -values] 0]
            set package [lsearch -exact -index 1 -inline $packlist(list) $packname]
            lassign $package installed name description version groups repo
            if {$packlist(mode) eq {query}} then {
                set installed [mc generalYes]
            } else {
                if {$installed eq "1"} then {
                    set installed [mc generalYes]
                } else {
                    set installed [mc generalNo]
                }
            }
            comproc updateTxtWidget $txtInfo [mc smallInfo \
                $name $description $version $installed $groups $repo] {}
        } else {
            comproc updateTxtWidget $txtInfo {} {}
        }
        return
    }
}

oo::define MainWin {
    method setupBot {parent} {
        set pnBot [ttk::frame [appendToPath $parent pnBot] -relief flat]
        set fButtons [ttk::frame [appendToPath $pnBot fButtons]]
        set btnInfo [defineButton [appendToPath $fButtons btnInfo] \
            $window btnInfo [list [self object] onInfo]]
        $btnInfo configure -image ::img::info -compound left
        set btnFiles [defineButton [appendToPath $fButtons btnFiles] \
            $window btnFiles [list [self object] onFiles]]
        $btnFiles configure -image ::img::files -compound left
        $btnFiles state disabled
        pack $btnInfo -side left -expand 1 -fill both
        pack $btnFiles -side left -expand 1 -fill both
        pack $fButtons -side top -fill x
        set fmText [ttk::frame [appendToPath $pnBot fmText]]
        set txtInfo [text [appendToPath $fmText txtInfor] \
            -background white \
            -height 1 \
            -width 1 \
            -wrap word]
        set vsb [ttk::scrollbar [appendToPath $fmText vsb] \
            -command [list $txtInfo yview]]
        $txtInfo configure -yscrollcommand [list $vsb set]
        pack $txtInfo -side left -expand 1 -fill both
        pack $vsb -side left -fill y
        pack $fmText -side top -expand 1 -fill both
        return $pnBot
    }
}


oo::define MainWin {
    method setupLeft {parent} {
        # Filters
        set fLeft [ttk::frame [appendToPath $parent fLeft] -relief flat]
        set fFilter [ttk::labelframe [appendToPath $fLeft fFilter] \
            -text [mc filters] -labelanchor n]
        # no filter
        set rbFilterOff [defineRadiobutton [appendToPath $fFilter rbFilterOff] \
            $window rbFilterOff [list [self object] onFilterSwitch] \
            [my varname filter(mode)] off]
        # Search
        set entSearch [ttk::entry [appendToPath $fFilter entSearch] \
            -textvariable [my varname filter(pattern)] -width 10]
        bind $entSearch <KeyPress-Return> [list [self object] onSearch]
        set rbSearch [defineRadiobutton [appendToPath $fFilter rbSearch] \
            $window rbSearch [list [self object] onFilterSwitch] \
            [my varname filter(mode)] search]
        # Group
        set cmbGroup [ttk::combobox [appendToPath $fFilter cmbGroup] \
            -textvariable [my varname filter(currgroup)] -width 10]
        $cmbGroup configure -postcommand [list [self object] fillGroupCombo $cmbGroup]
        bind $cmbGroup <<ComboboxSelected>> [list [self object] onSelectGroup]
        set rbGroup [defineRadiobutton [appendToPath $fFilter rbGroup] \
            $window rbGroup [list [self object] onFilterSwitch] \
            [my varname filter(mode)] group]
        # repo
        set rbRepo [defineRadiobutton [appendToPath $fFilter rbRepo] \
            $window rbRepo [list [self object] onFilterSwitch] \
            [my varname filter(mode)] repo]
        set cmbRepo [ttk::combobox [appendToPath $fFilter cmbRepo] \
            -textvariable [my varname filter(currepo)] -width 10]
        $cmbRepo configure -postcommand [list [self object] fillRepoCombo]
        bind $cmbRepo <<ComboboxSelected>> [list [self object] onSelectRepo]
        # pending
        set rbPending [defineRadiobutton [appendToPath $fFilter rbPending] \
            $window rbPending [list [self object] onFilterSwitch] \
            [my varname filter(mode)] pending]
        # upgrades
        set rbUpgrades [defineRadiobutton [appendToPath $fFilter rbUpgrades] \
            $window rbUpgrades [list [self object] onFilterSwitch] \
            [my varname filter(mode)] upgrades]
        # orphans
        set rbOrphans [defineRadiobutton [appendToPath $fFilter rbOrphans] \
            $window rbOrphans [list [self object] onFilterSwitch] \
            [my varname filter(mode)] orphans]
        set rbExplicit [defineRadiobutton [appendToPath $fFilter rbExplicit] \
            $window rbExplicit [list [self object] onFilterSwitch] \
            [my varname filter(mode)] explicit]
        set rbForeign [defineRadiobutton [appendToPath $fFilter rbForeign] \
            $window rbForeign [list [self object] onFilterSwitch] \
            [my varname filter(mode)] foreign]
        set rbFileOwner [defineRadiobutton [appendToPath $fFilter rbFileOwner] \
            $window rbFileOwner [list [self object] onFilterSwitch] \
            [my varname filter(mode)] fileowner]

        pack $rbFilterOff -side top -fill x
        pack $rbSearch -side top -fill x
        pack $entSearch -side top -fill x -padx {15 5}
        pack $rbGroup -side top -fill x
        pack $cmbGroup -side top -fill x -padx {15 5}
        pack $rbRepo -side top -fill x
        pack $cmbRepo -side top -fill x -padx {15 5}
        pack $rbPending -side top -fill x
        pack $rbUpgrades -side top -fill x
        pack $rbOrphans -side top -fill x
        pack $rbExplicit -side top -fill x
        pack $rbForeign -side top -fill x
        pack $rbFileOwner -side top -fill x
        pack $fFilter -side top -expand 1 -fill both -pady {5 0}
        return $fLeft
    }
}

##
# MainWin initWindow
#   This method issues the Tk commands to setup the main window.
##

oo::define MainWin {
    method initWindow {} {
        # Define menus
        set menubar [menu [appendToPath $window mb] -tearoff 0]
        # tkPacman menu
        set mnPacman [menu $menubar.db -tearoff 0]
        addMenuItem $mnPacman mnuImport command [list [self object] onImport]
        addMenuItem $mnPacman mnuLog command [list [self object] showLog]
        addMenuItem $mnPacman mnuClean command [list [self object] cleanCache]
        # addMenuItem $mnPacman mnuOptimize command [list [self object] optimizeDB]
        # item had to be removed, because pacman no longer supports pacman-optimize
        addMenuItem $mnPacman mnuQuit command [list [self object] onQuit]
        # accelerators for Database menu
        $mnPacman entryconfigure 4 -accelerator {Cntrl-q}
        bind $window <Control-KeyPress-q> [list [self object] onQuit]

        # Mark menu
        set mnMark [menu $menubar.mark -tearoff 0]
        $mnMark add command \
            -label [mc mnToggle] \
            -command [list [self object] onToggleMark] \
            -accelerator "([mc spaceDouble])" \
            -image ::img::marked -compound left
        $mnMark add command \
            -label [mc mnMarkAll] \
            -command [list [self object] onMarkAll] \
            -image ::img::installall -compound left
        $mnMark add command \
            -label [mc mnUnMarkAll] \
            -command [list [self object] onUnMarkAll] \
            -image ::img::unmarkall -compound left
        # Tools menu
        set mnTools [menu $menubar.tools -tearoff 0]
        addMenuItem $mnTools mnuOptions command [list tkpOptions showWindow $window]
        $mnTools add separator
        addMenuItem $mnTools mnuIncrFont command [list [self object] changeFontSize 1]
        addMenuItem $mnTools mnuDecrFont command [list [self object] changeFontSize -1]
        $mnTools entryconfigure 2 -accelerator {Cntrl +}
        $mnTools entryconfigure 3 -accelerator {Cntrl -}
        bind all <Control-KeyPress-plus> [list [self object] changeFontSize 1]
        bind all <Control-KeyPress-minus> [list [self object] changeFontSize -1]

        # Help menu
        set mnHelp [menu $menubar.help -tearoff 0]
        addMenuItem $mnHelp mnuHelpFile command [list [self object] displayHelp]
        addMenuItem $mnHelp mnuLicense command [list [self object] displayLicense]
        addMenuItem $mnHelp mnuAbout command [list [self object] displayAbout]

        # connect submenus to menubar
        addMenuItem $menubar mnuPacman cascade $mnPacman
        addMenuItem $menubar mnuMark cascade $mnMark
        addMenuItem $menubar mnuTools cascade $mnTools
        addMenuItem $menubar mnuHelp cascade $mnHelp
        $window configure -menu $menubar

        # toolbar
        set fButtons [ttk::frame [appendToPath $window fButtons] -relief groove]
        set btnCheckUp [defineButton [appendToPath $fButtons btnCheckUp] $window \
            btnCheckUp [list [self object] onCheckUpgrades]]
        $btnCheckUp configure -image ::img::refresh -compound left
        set btnSysUpgrade [defineButton [appendToPath $fButtons btnSysUpgrade] $window \
            btnSysUpgrade [list [self object] onSysUpgrade]]
        $btnSysUpgrade configure -image ::img::upgrade -compound left
        set btnApply [defineButton [appendToPath $fButtons btnApply] \
            $window btnApply [list [self object] onApply 1]]
        $btnApply configure -image ::img::apply -compound left
        # btnApply must be disabled initially.
        $btnApply state disabled
        set btnInstallFile [defineButton [appendToPath $fButtons btnInstallFile] \
            $window btnInstallFile [list [self object] onImport]]
        $btnInstallFile configure -image ::img::box -compound left
        set btnError [defineButton [appendToPath $fButtons btnError] \
            $window btnError [list [self object] onErrorLog]]
        $btnError configure -image ::img::errors -compound left
        set fSpace [ttk::frame [appendToPath $fButtons fSpace]]
        set btnQuit [defineButton [appendToPath $fButtons btnQuit] \
            $window btnQuit [list [self object] onQuit]]
        $btnQuit configure -image ::img::cancel -compound left
        pack $btnCheckUp -side left -fill y
        pack $btnSysUpgrade -side left -fill y
        pack $btnApply -side left -fill y
        pack $btnInstallFile -side left -fill y
        pack $btnError -side left -fill y
        pack $fSpace -side left -expand 1
        pack $btnQuit -side left -fill y

        # packlist(mode) bar
        set fMode [ttk::frame [appendToPath $window fMode] -relief groove]
        set rbAvailable [defineRadiobutton [appendToPath $fMode rbAvailable] \
            $window rbAvailable [list [self object] onModeSwitch] \
            [my varname packlist(mode)] sync]
        set rbInstalled [defineRadiobutton [appendToPath $fMode rbInstalled] \
            $window rbInstalled [list [self object] onModeSwitch] \
            [my varname packlist(mode)] query]
        grid $rbAvailable -column 0 -row 0 -pady 3 -padx 5
        grid $rbInstalled -column 1 -row 0 -pady 3 -padx 5
        grid anchor $fMode n

        # panedwindow
        set pwh [ttk::panedwindow [appendToPath $window pwh] -orient horizontal]
        set pnLeft [my setupLeft $pwh]
        set pwv [ttk::panedwindow [appendToPath $pwh pwv] -orient vertical]
        set pnTop [my setupTop $pwv]
        set pnBot [my setupBot $pwv]
        $pwv add $pnTop -weight 1
        $pwv add $pnBot -weight 1
        $pwh add $pnLeft -weight 1
        $pwh add $pwv -weight 3
        pack $fButtons -side top -fill x
        pack $fMode -side top -fill x
        pack $pwh -side top -expand 1 -fill both

        # status bar
        set fStatus [ttk::frame [appendToPath $window fStatus]]
        # nr of packages
        set lbNrOfPackages [ttk::label [appendToPath $fStatus lbNrOfPackages] \
            -text [mc nrOfPackages] -foreground blue4]
        # listed packages
        set fListed [ttk::frame [appendToPath $fStatus fListed]]
        set lbListed [ttk::label [appendToPath $fListed lbListed] \
            -text [mc packagesListed] -foreground blue4]
        set lbNrListed [ttk::label [appendToPath $fListed lbNrListed] \
            -textvariable [my varname nrOfItems] -foreground blue4]
        pack $lbListed -side left
        pack $lbNrListed -side left
        # available packages
        set fAvail [ttk::frame [appendToPath $fStatus fAvail]]
        set lbAvail [ttk::label [appendToPath $fAvail lbAvail] \
            -text [mc packagesAvail] -foreground blue4]
        set lbNrAvail [ttk::label [appendToPath $fAvail lbNrAvail] \
            -textvariable [my varname packlist(length)] -foreground blue4]
        pack $lbAvail -side left
        pack $lbNrAvail -side left
        # marked for install
        set fMarkedInstall [ttk::frame [appendToPath $fStatus fMarkedInstall]]
        set lbMarkedInstall [ttk::label [appendToPath $fMarkedInstall lbMarkedInstall] \
            -text [mc markedInstall] -foreground blue4 -image ::img::marked -compound left]
        set lbNrMarkedInstall [ttk::label [appendToPath $fMarkedInstall lbNrMarkedInstall] \
            -textvariable [my varname nrOfMarked(install)] -foreground blue4]
        pack $lbMarkedInstall -side left
        pack $lbNrMarkedInstall -side left
        # marked for remove
        set fMarkedRemove [ttk::frame [appendToPath $fStatus fMarkedRemove]]
        set lbMarkedRemove [ttk::label [appendToPath $fMarkedRemove lbMarkedRemove] \
            -text [mc markedRemove] -foreground blue4 -image ::img::remove -compound left]
        set lbNrMarkedRemove [ttk::label [appendToPath $fMarkedRemove lbNrMarkedRemove] \
            -textvariable [my varname nrOfMarked(remove)] -foreground blue4]
        pack $lbMarkedRemove -side left
        pack $lbNrMarkedRemove -side left
        # sizegrip
        set sg [ttk::sizegrip [appendToPath $fStatus sg]]
        # pack status bar
        pack $lbNrOfPackages -side left -expand 1
        pack $fAvail -side left -expand 1
        pack $fListed -side left -expand 1
        pack $fMarkedInstall -side left -expand 1
        pack $fMarkedRemove -side left -expand 1
        pack $sg -side left
        pack $fStatus -side top -fill x
        return
    }
}

oo::class create ImportWin {

    variable window filename txtInfo btnInfo btnFiles btnInstall writeErr

    constructor {args} {
        set parent {}
        set writeErr stderr
        dict for {option value} $args {
            if {$option eq {-parent}} then {
                set parent $value
            } elseif {$option eq {-errorchan}} then {
                set writeErr $value
            } else {
                chan puts $writeErr "ImportWim '$option': unknown option"
            }
        }
        set window [toplevel [appendToPath $parent \
            [namespace tail [string tolower [self namespace]]]]]
        wm title $window [mc tkPacmanImport]
        wm iconphoto $window -default ::img::tkpacman_icon
        wm geometry $window [join [geometry::getSize import] {x}]
        my initWindow
        set tpOnly [bindToplevelOnly $window <Destroy> [list [self object] destroy]]
        bind $tpOnly <Configure> {geometry::setSize import {%w %h}}
        bind $window <KeyPress-Escape> [list destroy $window]
        return
    }

    destructor {
        return
    }
}

oo::define ImportWin {
    method initWindow {} {
        # package file
        set fFile [ttk::frame ${window}.fFile]
        set lbFile [ttk::label ${fFile}.lbFile -text [mc lbImportFile]]
        set entFile [ttk::entry ${fFile}.entFile \
            -textvariable [my varname filename]]
        set btnfs [ttk::button ${fFile}.btnfs \
            -image ::img::arrow_down \
            -command [list [self object] onSelectFile] \
            -takefocus 0]
        focus $entFile
        bind $entFile <KeyPress-Down> [list $btnfs invoke]
        pack $lbFile -side left
        pack $entFile -side left -expand 1 -fill x
        pack $btnfs -side left
        # buttons
        set fButtons [ttk::frame ${window}.fButtons]
        set btnInfo [defineButton ${fButtons}.btnInfo \
            $window btnInfo [list [self object] onInfo]]
        $btnInfo configure -image ::img::info -compound left
        $btnInfo state disabled
        set btnFiles [defineButton ${fButtons}.btnFiles \
            $window btnFiles [list [self object] onFiles]]
        $btnFiles state disabled
        $btnFiles configure -image ::img::files -compound left
        set btnInstall [defineButton ${fButtons}.btnInstall \
            $window btnInstall [list [self object] onInstall]]
        $btnInstall configure -image ::img::apply -compound left
        $btnInstall state disabled
        set btnClose [defineButton ${fButtons}.btnClose \
            $window btnClose [list destroy $window]]
        $btnClose configure -image ::img::cancel -compound left
        pack $btnInfo -side left -expand 1 -fill x
        pack $btnFiles -side left -expand 1 -fill x
        pack $btnInstall -side left -expand 1 -fill x
        pack $btnClose -side left -expand 1 -fill x
        # text widget
        set fInfo [ttk::frame ${window}.fInfo]
        set txtInfo [text ${fInfo}.txtInfo \
            -background white -width 1 -height 1 -wrap word]
        set vsbInfo [ttk::scrollbar ${fInfo}.vsb -orient vertical \
            -command [list $txtInfo yview]]
        $txtInfo configure -yscrollcommand [list $vsbInfo set]
        # status bar
        set fStat [ttk::frame ${window}.fStat]
        set sg [ttk::sizegrip ${fStat}.sg]
        pack $sg -side right
        pack $txtInfo -side left -expand 1 -fill both
        pack $vsbInfo -side left -fill y
        pack $fFile -side top -fill x -pady {10 5} -padx 5
        pack $fButtons -side top -fill x -pady 5 -padx 5
        pack $fInfo -side top -expand 1 -fill both
        pack $fStat -side top -fill x
        return
    }
}

oo::define ImportWin {
    method onSelectFile {} {
        set fs [FileSelection new \
            -parent $window \
            -filetypes {{{Package} {*.pkg.tar.xz}} {{All files} {*}}}]
        set filename [$fs wait]
        if {[string length $filename] > 0} then {
            $btnInfo state {!disabled}
            $btnFiles state {!disabled}
            $btnInstall state {!disabled}
            my onInfo
        }
        return
    }
}

oo::define ImportWin {
    method onFiles {} {
        set cmd [list pacman --query --quiet --list --file $filename]
        comproc updateTxtWidget $txtInfo [comproc runCmd $cmd $writeErr] {}
        return
    }
}

oo::define ImportWin {
    method onInfo {} {
        set cmd [list pacman --query --info --file $filename]
        comproc updateTxtWidget $txtInfo [comproc runCmd $cmd $writeErr] {}
        comproc markURL $txtInfo $window
        return
    }
}

oo::define ImportWin {
    method onInstall {} {
        set cmd "pacman --upgrade '${filename}'"
        comproc runAsRoot $cmd $writeErr
        return
    }
}

## Create the one and only MainWin object
set tkpObject [MainWin new]

