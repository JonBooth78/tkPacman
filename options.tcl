# options.tcl

namespace eval pacmanOptions {
    # This namespace encapsulates all variable and procedures related to
    # the pacman options as stored in /etc/pacman.conf. pacmanDict is a
    # dictionary of dictionaries. The outer dictionary uses the section
    # names (options, core, extra, community ...) as keys and the section
    # bodies as values. Each section body is itself a dictionary with
    # what comes before the '=' as key, and the rest of the line as
    # value. If there is no '=' in the line, the empty string {} is used
    # as value.
    variable pacmanDict {}
    namespace ensemble create -subcommands {initOptions getOption getRepolist}
}

namespace eval pacmanOptions {
    # This procedure reads /etc/pacman.conf and populates pacmanDict.
    proc initOptions {} {
        variable pacmanDict
        if {![catch {open "/etc/pacman.conf" r} confchan]} then {
            set pacmanConf [split [chan read $confchan] "\n"]
            chan close $confchan
            # remove all comments and empty lines
            set index 0
            foreach line $pacmanConf {
                # remove all empty space before and after line
                set line [string trim $line]
                if {[string length $line] == 0} then {
                    # empty line, remove it
                    set pacmanConf [lreplace $pacmanConf $index $index]
                    incr index -1
                } else {
                    set hash [string first "#" $line 0]
                    if {$hash == 0} then {
                        # first char of line is "#" --> whole line is comment,
                        # remove it
                        set pacmanConf [lreplace $pacmanConf $index $index]
                        incr index -1
                    } elseif {$hash > 0} then {
                        # line contains comment, remove comment
                        set line [string replace $line $hash end ""]
                        set pacmanConf [lreplace $pacmanConf $index $index $line]
                    } else {
                        # no comments and not empty, but line may be trimmed -->
                        # it must be replaced nevertheless.
                        set pacmanConf [lreplace $pacmanConf $index $index $line]
                    }
                }
                incr index
            }
        } else {
            set pacmanConf {}
        }
        set pacmanDict {}
        set section {}
        set body {}
        foreach line $pacmanConf {
            if {[string index $line 0] eq {[}} then {
                # new section --> append accumulated lines
                # to previous section
                if {$section ne {}} then {
                    # There is a previous section
                    dict append pacmanDict $section $body
                    set body {}
                }
                set end [string first {]} $line]
                set section [string range $line 1 ${end}-1]
            } else {
                # section continues. Append line to body
                set line [split $line {=}]
                set key [string trim [lindex $line 0]]
                if {[llength $line] == 1} then {
                    set value {}
                } else {
                    set value [string trim [lindex $line 1]]
                }
                dict append body $key $value
            }
        }
        if {$section ne {}} then {
            dict append pacmanDict $section $body
        }
        # puts $pacmanDict
        return
    }
}

namespace eval pacmanOptions {
    proc getOption {section option} {
        variable pacmanDict
        if {[dict exists $pacmanDict $section $option]} then {
            set value [dict get $pacmanDict $section $option]
        } else {
            set value {}
        }
        return $value
    }
}

namespace eval pacmanOptions {
    proc getRepolist {} {
        variable pacmanDict
        set repolist {}
        foreach key [dict keys $pacmanDict] {
            if {$key ne {options}} then {
                lappend repolist $key
            }
        }
        return $repolist
    }
}


##
# namespace tkpOptions
#   This namespace encapsulates all variables and procedures
#   for handling the options of tkPacman.

namespace eval tkpOptions {
    variable optionStructure [list \
        general [list browser terminal runasroot tmpdir allerrors fontincrement] \
        geometry [list main text import] \
        fileselection [list lastdir]]
    variable optionDict
    variable optionArray
    variable window
    variable terminalList
    variable runasrootList
    set optionDict {}
    dict for {type list} $tkpOptions::optionStructure {
        set subDict {}
        foreach option $list {
            dict append subDict $option {}
        }
        dict append optionDict $type $subDict
    }
    set window {}
    # WHE : terminalList updated 22-10-2017
    # roxterm does not work very well anymore --> removed
    # konsole template corrected
    # qterminal added
    set terminalList [list \
        {xfce4-terminal --disable-server --title=%t --command=%c} \
        {konsole --nofork -p tabtitle=%t -e %c} \
        {mate-terminal --disable-factory --title=%t --command=%c} \
        {vte --name=%t --command=%c} \
        {qterminal --execute %c} \
        {xterm -title %t -e %c}]
    set runasrootList [list \
        {%terminal(echo "%p" ; su --command="%p" ; read -p "%close")} \
        {sudo --askpass %terminal(echo "%p" ; %p ; read -p "%close")} \
        {gksu --description pacman %terminal(echo "%p" ; %p ; read -p "%close")} \
        {kdesu %terminal(echo "%p" ; %p ; read -p "%close")}]
    namespace ensemble create -subcommands [list getDefault \
        getOption initOptions saveOptions setOption showWindow]
}

namespace eval tkpOptions {
    proc initOptions {} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window

        set filename [file normalize "~/.tkpacman"]
        if {[file exists $filename]} then {
            set chan [open $filename r]
            set fileDict [chan read -nonewline $chan]
            chan close $chan
        } else {
            set fileDict {}
        }
        dict for {type list} $tkpOptions::optionStructure {
            foreach option $list {
                if {[dict exists $fileDict $type $option]} then {
                    dict set optionDict $type $option \
                        [dict get $fileDict $type $option]
                } else {
                    dict set optionDict $type $option \
                        [getDefault $type $option]
                }
            }
        }
        saveOptions
        return
    }
}


namespace eval tkpOptions {
    proc saveOptions {} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window

        set filename [file normalize "~/.tkpacman"]
        set chan [open $filename w]
        chan puts $chan $optionDict
        chan close $chan
        return
    }
}

namespace eval tkpOptions {
    proc getDefault {type option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        switch $type {
            general {
                set value [getGeneralDefault $option]
            }
            geometry {
                set value [getGeometryDefault $option]
            }
            fileselection {
                set value [getFileselectDefault $option]
            }
            default {
                set value {}
            }
        }
        return $value
    }
}

namespace eval tkpOptions {
    proc getGeneralDefault {option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        variable terminalList
        variable runasrootList
        variable ::config::defaultBrowser

        switch -- $option {
            "browser" {
                set value {/usr/bin/xdg-open}
            }
            "terminal" {
                set value [lindex $terminalList 0]
                foreach terminal $terminalList {
                    set termexec [lindex $terminal 0]
                    if {![catch {exec which $termexec} msg]} then {
                        set value $terminal
                        break
                    }
                }
            }
            "runasroot" {
                set value [lindex $runasrootList 0]
            }
            "tmpdir" {
                set value {/tmp}
            }
            "allerrors" {
                set value 0
            }
            "fontincrement" {
                set value 0
            }
            default {
                set value {}
            }
        }
        return $value
    }
}

namespace eval tkpOptions {
    proc getGeometryDefault {option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        switch $option {
            main {
                set value {750 450}
            }
            text {
                set value {600 400}
            }
            import {
                set value {600 400}
            }
            default {
                set value {600 400}
            }
        }
        return $value
    }
}

namespace eval tkpOptions {
    proc getFileselectDefault {option} {
        if {$option eq "lastdir"} then {
            set value [file normalize ~]
        } else {
            set value {}
        }
        return $value
    }
}

namespace eval tkpOptions {
    proc getOption {type option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        return [dict get $optionDict $type $option]
    }
}

namespace eval tkpOptions {
    proc setOption {type option newValue} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        dict set optionDict $type $option $newValue
        return
    }
}

namespace eval tkpOptions {
    proc showWindow {parent} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        if {$window eq {}} then {
            foreach type {general} {
                foreach option [dict get $optionStructure $type] {
                    set optionArray($type,$option) [dict get $optionDict $type $option]
                }
            }
            set window [toplevel [appendToPath $parent options]]
            wm transient $window $parent
            wm title $window [mc optionsTitle]
            # set noteBook [ttk::notebook ${window}.nb -takefocus 0]
            set fGeneral [setupTab general ${window}.general]
            #addNotebookTab $noteBook $fGeneral optTabGeneral
            #ttk::notebook::enableTraversal $noteBook
            #pack $noteBook -side top -expand 1 -fill both
            pack $fGeneral -side top -expand 1 -fill both -padx 5 -pady 5
            set frmButtons [ttk::frame ${window}.frmbtns]
            set btnLegend [defineButton ${frmButtons}.btnlegend $window \
                btnLegend tkpOptions::onLegend]
            set btnOK [defineButton ${frmButtons}.btnok $window btnOK \
                tkpOptions::onOK]
            set btnCancel [defineButton ${frmButtons}.btncancel $window \
                btnCancel [list destroy $window]]
            pack $btnLegend -side right
            pack $btnCancel -side right
            pack $btnOK -side right
            pack $frmButtons -side top -fill x -pady 5 -padx 5
            bindToplevelOnly $window <Destroy> tkpOptions::onDestroyWindow
            #bind $window <KeyPress-Down> {focus [tk_focusNext [focus]]}
            #bind $window <KeyPress-Up> {focus [tk_focusPrev [focus]]}
            bind $window <KeyPress-Return> [list tkpOptions::onOK]
            bind $window <KeyPress-Escape> [list destroy $window]
        } else {
            wm deiconify $window
            raise $window
            focus $window
        }
        return
    }
}

namespace eval tkpOptions {
    proc setupTab {tab pathname} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        set entrywidth 40
        set frm [ttk::frame $pathname]
        set idx 0
        foreach option [dict get $tkpOptions::optionStructure $tab] {
            set lbl [ttk::label ${frm}.lb$idx -text $option \
                -compound right -image ::img::empty_5_9]
            grid $lbl -column 0 -row $idx -sticky w
            if {$option eq {runasroot}} then {
                set control [ttk::combobox ${frm}.con$idx \
                    -textvariable tkpOptions::optionArray($tab,$option) \
                    -values $tkpOptions::runasrootList]
            } elseif {$option eq {terminal}} then {
                set control [ttk::combobox ${frm}.con$idx \
                    -textvariable tkpOptions::optionArray($tab,$option) \
                    -values $tkpOptions::terminalList]
            } elseif {$option eq {allerrors}} then {
                set control [ttk::checkbutton ${frm}.con$idx \
                    -variable tkpOptions::optionArray($tab,$option) \
                    -onvalue 1 -offvalue 0]
            } elseif {$option eq {fontincrement}} then {
                set control [entry ${frm}.con$idx \
                    -textvariable tkpOptions::optionArray($tab,$option)]
                $control configure -state readonly
            } else {
                set control [entry ${frm}.con$idx \
                    -textvariable tkpOptions::optionArray($tab,$option)]
                $control configure -width $entrywidth
            }
            bind $control <FocusIn> \
                [list $lbl configure -compound right -image ::img::arrow_right]
            bind $control <FocusOut> \
                [list $lbl configure -compound right -image ::img::empty_5_9]
            if {$idx == 0} then {
                focus $control
            }
            if {$option in {browser tmpdir}} then {
                set btnSelect [ttk::button ${frm}.sel$idx \
                    -image ::img::arrow_down \
                    -takefocus 0 \
                    -command [list tkpOptions::onSelect $tab $option]]
                bind $control <KeyPress-Down> [list $btnSelect invoke]
                bind $control <Alt-KeyPress-s> [list $btnSelect invoke]
                grid $control -column 1 -row $idx -sticky wens
                grid $btnSelect -column 2 -row $idx -sticky wens
                # $control configure -state {readonly}
            } else {
                grid $control -column 1 -columnspan 2 -row $idx \
                    -sticky wens
            }
            set btnExpand [ttk::button ${frm}.exp$idx \
                -image ::img::expand \
                -takefocus 0 \
                -command [list tkpOptions::onExpand $tab $option]]
            bind $control <Alt-KeyPress-x> [list $btnExpand invoke]
            grid $btnExpand -column 3 -row $idx -sticky wens
            set btnDefault [ttk::button ${frm}.def$idx \
                -image ::img::reset \
                -takefocus 0 \
                -command [list tkpOptions::onDefault $tab $option]]
            bind $control <Alt-KeyPress-r> \
                [list tkpOptions::onDefault $tab $option]
            grid $btnDefault -column 4 -row $idx -sticky wens
            set btnHelp [ttk::button ${frm}.help$idx \
                -image ::img::help \
                -takefocus 0 \
                -command [list tkpOptions::onHelp $tab $option]]
            bind $control <Alt-KeyPress-h> [list $btnHelp invoke]
            grid $btnHelp -column 5 -row $idx -sticky wens
            incr idx
        }
        grid columnconfigure $frm 1 -weight 1
        grid anchor $frm center
        return $frm
    }
}

namespace eval tkpOptions {
    proc onOK {} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        foreach type {general} {
            foreach option [dict get $tkpOptions::optionStructure $type] {
                dict set optionDict $type $option $optionArray($type,$option)
            }
        }
        saveOptions
        destroy $window
        return
    }
}

namespace eval tkpOptions {
    proc onDestroyWindow {} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        array unset optionArray
        set window {}
        return
    }
}

namespace eval tkpOptions {
    proc onExpand {type option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        set textEdit [TextEdit new $window $option \
            $optionArray($type,$option) 0]
        if {$option in {browser terminal}} then {
            $textEdit addMenuItem [mc optPasteFilename] command {
                %T insert insert [fileSelectionFunction \
                    -parent [winfo toplevel %T]]
            }
        }
        if {[$textEdit wait result]} then {
            set optionArray($type,$option) $result
        }
        return
    }
}

namespace eval tkpOptions {
    proc onDefault {type option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        set optionArray($type,$option) [getDefault $type $option]
        return
    }
}

namespace eval tkpOptions {
    proc onHelp {type option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        set textEdit [TextEdit new $window [mc optHelpTitle $option] \
                [mc optHelp_${option}] 1]
        return
    }
}

namespace eval tkpOptions {
    proc onLegend {} {
        variable window
        set llist {}
        foreach icon {arrow_down expand reset help} {
            lappend llist [list ::img::$icon [mc opt_$icon]]
        }
        set legend [Legend new $window [mc fsLegend] $llist]
        return
    }
}

namespace eval tkpOptions {
    proc onSelect {type option} {
        variable optionStructure
        variable optionDict
        variable optionArray
        variable window
        variable terminalList
        global env
        global tcl_platform
        if {$option in {browser}} then {
            set initialdir {/usr/bin}
            set fs [FileSelection new -parent $window \
                -directory $initialdir \
                -title [mc optSelect$option]]
            set filename [$fs wait]
            if {$filename ne {}} then {
                set optionArray($type,$option) $filename
            }
        } elseif {$option in {tmpdir}} then {
            set initialdir {/tmp}
            set fs [FileSelection new -parent $window \
                -directory $initialdir \
                -title [mc optSelect$option] \
                -dironly 1]
            set dirname [$fs wait]
            if {$dirname ne {}} then {
                set optionArray($type,$option) $dirname
            }
        }
        return
    }
}
