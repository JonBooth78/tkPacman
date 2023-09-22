#!/usr/bin/tclsh
# This script is meant to be called by 'sudo --askpass'
# sudo calls it with 1 argument containing text as:
#   [sudo] password for wim:
# This helper must be "registered" by tkPacman as sudo helper
# by setting the environment variable SUDO_ASKPASS to this script file.

package require Tk
package require msgcat
namespace import msgcat::mc

set installDir [file dirname [file normalize [info script]]]
set languageDir [file join $installDir msgs]
msgcat::mcload $languageDir

proc appendBindTag {widget newTag} {
    set tags [bindtags $widget]
    lappend tags $newTag
    bindtags $widget $tags
    return
}

proc onDestroy {} {
    bind topAskpass <Destroy> {}
    exit 2
}

proc onOK {} {
    global password
    chan puts stdout $password
    bind topAskpass <Destroy> {}
    exit 0
}

wm title {.} [mc askPassword]

set password {}
set lblHelp [ttk::label .lblHelp -text [mc sudoHelp [lindex $argv 0]]]
set fPassword [ttk::frame .fPassword]
set lblPassword [ttk::label ${fPassword}.lblPassword -text [mc password]]
set entPassword [ttk::entry ${fPassword}.entPassword -show {*} \
    -textvariable password]
set fButtons [ttk::frame .fButtons]
set btnCancel [ttk::button ${fButtons}.btnCancel -text [mc btnCancel] \
    -command [list destroy .] -takefocus 0]
set btnOK [ttk::button ${fButtons}.btnOK -text [mc btnOK] \
    -command onOK -takefocus 0]
bind . <KeyPress-Return> onOK
bind . <KeyPress-Escape> [list destroy .]
# bind <Destroy> for toplevel only
appendBindTag . topAskpass
bind topAskpass <Destroy> [list onDestroy]
focus $entPassword
pack $lblPassword -side left
pack $entPassword -side left -expand 1 -fill x
pack $btnOK -side right
pack $btnCancel -side right
pack $lblHelp -side top -pady 10 -padx 10
pack $fPassword -side top -pady 10 -padx 10 -fill x
pack $fButtons -side top -pady 10 -padx 10 -fill x
