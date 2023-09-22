# options.tcl

##
# namespace tkpOptions
#   This namespace encapsulates all variables and procedures
#   for handling the options of postsqlforms.

namespace eval tkpOptions {
    variable optionStructure [list \
        general [list browser terminal sudo] \
        geometry [list main text import] \
        fileselection [list lastdir]]
    variable optionDict
    variable optionArray
    variable window
    variable terminalList
    set optionDict {}
    dict for {type list} $tkpOptions::optionStructure {
        set subDict {}
        foreach option $list {
            dict append subDict $option {}
        }
        dict append optionDict $type $subDict
    }
    set window {}
    set terminalList [list \
        {xterm -title %t -e %c} \
        {lxterminal --title=%t --command=%c} \
        {vte --name=%t --command=%c} \
        {roxterm --title=%t --execute %c}]
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
        variable ::config::defaultBrowser

        switch -- $option {
            "browser" {
                set value {/usr/bin/xdg-open}
            }
            "terminal" {
                set value {lxterminal --title=%t --command=%c}
            }
            "sudo" {
                set value {0}
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
            if {$option eq {sudo}} then {
                set control [ttk::checkbutton ${frm}.con$idx \
                    -text {} \
                    -variable tkpOptions::optionArray($tab,$option) \
                    -onvalue 1 -offvalue 0]
            } elseif {$option eq {terminal}} then {
                set control [ttk::combobox ${frm}.con$idx \
                    -textvariable tkpOptions::optionArray($tab,$option) \
                    -values $tkpOptions::terminalList]
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
            if {$option in {browser}} then {
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
            set allFiles [list "All files" [list "*"]]
            set filetypes [list $allFiles]
            set initialdir {/usr/bin}
            set fs [FileSelection new -parent $window \
                -directory $initialdir \
                -filetypes $filetypes \
                -title [mc optSelect$option]]
            set filename [$fs wait]
            if {$filename ne {}} then {
                set optionArray($type,$option) $filename
            }
        }
        return
    }
}
