# misc.tcl

##
# namespace geometry
#   This namespace keeps track of the window sizes
##

namespace eval geometry {
    variable windowList {main text import}
    foreach window $windowList {
        variable $window
    }
}

##
# geometry::initGeometry
#   This procedure reads the window sizes from the options.
##

namespace eval geometry {
    proc initGeometry {} {
        variable windowList

        foreach window $windowList {
            variable $window
            set $window [tkpOptions getOption geometry $window]
        }
        return
    }
}

##
# geometry::saveGeometry
#   This procedure saves the window sizes in the options file.
##

namespace eval geometry {
    proc saveGeometry {} {
        variable windowList

        foreach window $windowList {
            variable $window
            set size [subst $[subst $window]]
            # puts "$window: [lindex $size 0] x [lindex $size 1]"
            tkpOptions setOption geometry $window $size
            tkpOptions saveOptions
        }
        return
    }
}

namespace eval geometry {
    proc getSize {window} {
        variable $window
        set size [subst $[subst $window]]
        return $size
    }
}

namespace eval geometry {
    proc setSize {window size} {
        variable $window
        set $window $size
        return
    }
}

##
# proc appendToPath
# This procedure joins 2 widget paths taking into account
# the exception that {.} joined with "xxx" yields .xxx and not ..xxx
##

proc appendToPath {path tail} {

    if {$path eq {.}} then {
        set result "${path}${tail}"
    } else {
        set result "${path}.${tail}"
    }
    return $result
}

##
# proc addMenuItem {menuName itemLabel itemType argument}
#
#   - menuName: the pathname of the menu to which the item is to be added
#
#   - itemLabel: the untranslated label see files in subdir 'msgs' for
#                translated labels
#   - itemType: one of 'command', 'cascade'
#
#   - argument: if command, it is the command to bind to the menuitem
#               if cascade, it is the pathname of the menu to open
#
# This procedure adds a menu item to menu $menuName. It translates the
# $itemLabel using the files in subdir 'msgs' and looks for "&" in the
# translated label. If "&" is found, it is removed and a "-underline"
# clause is added to underline the character following the "&".
#
# This procedure returns an empty string
##

proc addMenuItem {menuName itemLabel itemType argument} {
    if {$itemType eq {cascade}} then {
        set thirdClause {-menu}
    } else {
        set thirdClause {-command}
    }
    set translated [mcunderline $itemLabel]
    if {[llength $translated] > 1} then {
        $menuName add $itemType \
            -label [lindex $translated 0] -underline [lindex $translated 1] \
            $thirdClause $argument
    } else {
        $menuName add $itemType \
            -label [lindex $translated 0] $thirdClause $argument
    }
    return
}

##
# proc defineButton {btnName bindTag btnLabel btnCommand}
#
#  - btnName: the pathname of the button to define
#
#  - bindTag: the tag to use in the bind command for the shortcut
#
#  - btnLabel: the untranslated string to display on the button
#
#  - btnCommand: the command to bind to the button.
#
# This procedure defines a button with pathname $btnName and returns
# $btnName. It translates the $btnLabel using the files in subdir 'msgs'
# and looks for "&" in the translated label. If "&" is found, it is
# removed, a "-underline" clause is added to underline the character
# following the "&" and $btnCommand is also bound to <Alt-KeyPress-x>
# where 'x' is the underlined character.
#
# Nasty problem: The binding for the keyboard shortcut with AltUnderlined
# is difficult to get right:
#
#   - without 'after 200' it works on Windows, but on Linux when
#     the button command destroys the 'text' widget that received the
#     KeyPress event, Tk raises on error because it tries to do something
#     with the text widget that has already been destroyed.
#
#   - with 'after idle' it works well on Linux but on Windows,
#     Tk derails completely when the command creates a new toplevel.
#     It goes into an endless loop with high CPU load.
#
#   - with 'after 200' it seems to work well on both Windows and Linux,
#     but I can only hope that 200 ms will always be sufficient to
#     avoid the problem.
#
#   - I have also tried to generate a virtual event <<ALtUnderlined>>,
#     but that path leads to the same troubles.
##

proc defineButton {btnName bindTag btnLabel btnCommand} {
    set translation [mcunderline $btnLabel]
    if {[llength $translation] > 1} then {
        set widget [ttk::button $btnName -takefocus 0 -command $btnCommand \
            -text [lindex $translation 0] -underline [lindex $translation 1]]
        bind $bindTag <Alt-KeyPress-[lindex $translation 2]> \
            [list after 200 [list $btnName instate {!disabled} [list $btnName invoke]]]
    } else {
        set widget [ttk::button $btnName -takefocus 0 -command $btnCommand \
            -text [lindex $translation 0]]
    }
    return $widget
}

##
# Same as define button, but for a checkbutton
##

proc defineCheckbutton {btnName bindTag btnLabel btnCommand btnVariable OnValue OffValue} {
    set translation [mcunderline $btnLabel]
    if {[llength $translation] > 1} then {
        set widget [ttk::checkbutton $btnName -takefocus 0 -command $btnCommand \
            -text [lindex $translation 0] -underline [lindex $translation 1] \
            -variable $btnVariable -onvalue $OnValue -offvalue $OffValue]
        bind $bindTag <Alt-KeyPress-[lindex $translation 2]> \
            [list after 200 [list $btnName instate {!disabled} [list $btnName invoke]]]
    } else {
        set widget [ttk::checkbutton $btnName -command $btnCommand \
            -text [lindex $translation 0] \
            -variable $btnVariable -onvalue $OnValue -offvalue $OffValue]
    }
    return $widget
}

##
# Same as define button, but for a radiobutton
##

proc defineRadiobutton {btnName bindTag btnLabel btnCommand btnVariable value} {
    set translation [mcunderline $btnLabel]
    if {[llength $translation] > 1} then {
        set widget [ttk::radiobutton $btnName -takefocus 0 -command $btnCommand \
            -text [lindex $translation 0] -underline [lindex $translation 1] \
            -variable $btnVariable -value $value]
        bind $bindTag <Alt-KeyPress-[lindex $translation 2]> \
            [list after 200 [list $btnName instate {!disabled} [list $btnName invoke]]]
    } else {
        set widget [ttk::radiobutton $btnName -command $btnCommand \
            -text [lindex $translation 0] \
            -variable $btnVariable -value $value]
    }
    return $widget
}

##
# Append newTag to a widget's bindtags
##

proc appendBindTag {widget newTag} {
    set tags [bindtags $widget]
    lappend tags $newTag
    bindtags $widget $tags
    return
}

##
# bindToplevelOnly $topPath $event $script
#
# This procedure generates a new unique bindtag of the form
# "tpOnly$counter" where counter is incremented at every invocation
# of the procedure. Then it appends this bindtag to the toplevel
# identified by $topPath and binds $event and $script to this new bindtag.
#
# Normally a toplevel receives the events from all its children.
# Sometimes that is not what you want. E.g. to catch the <Destroy> event
# from a toplevel, it is not a good idea to bind a script to the toplevel
# because it will be called for every child of the toplevel that is
# destroyed.
##

namespace eval TpOnlyTags {variable counter 0}

proc bindToplevelOnly {topPath event script} {
    variable TpOnlyTags::counter
    set newTag "tpOnly$counter"
    incr counter
    appendBindTag $topPath $newTag
    bind $newTag $event $script
    return $newTag
}

##
# Append a bindtag $tag to all descendants of $widget
##

proc recursiveAppendTag {widget tag} {
    foreach child [winfo children $widget] {
        appendBindTag $child $tag
        recursiveAppendTag $child $tag
    }
    return
}

##
# proc mcunderline {untranslated}
#
#    - untranslated: is the untranslated string
#
# This procedure translates the untranslated string using the files
# in subdir msgs. It also looks for "&" in the translated string.
#
# If "&" is found:
#    the procedure returns a list in which:
#        - the 1st item is the translated string without "&"
#        - the index where the "&" was located
#        - the lower case character that was following the "&" (i.e.
#          the character that will be displayed underlined)
# else:
#     the procedure returns a list in which the translated string
#     is the only element.
##

proc mcunderline {untranslated} {
    set translated [mc $untranslated]
    set underline [string first {&} $translated]
    if {$underline >= 0} then {
        set translated [string replace $translated $underline $underline]
        set shortcut [string tolower [string index $translated $underline]]
        set result [list $translated $underline $shortcut]
    } else {
        set result [list $translated]
    }
    return $result
}

##
# proc tkp_message {msg parent}
# This procedure reports an error message 'msg'. 'msg' must be a
# translated string.
##

proc tkp_message {msg parent} {
    if {[info command winfo] eq {winfo}} then {
        dict append arg parent $parent
        dict append arg title [mc tkp_message]
        dict append arg message $msg
        dict append arg msgWidth 500
        dict append arg defaultButton btnOK
        dict append arg buttonList btnOK
        set dlg [GenDialog new \
            -parent $parent \
            -title [mc tkp_message] \
            -message $msg \
            -msgWidth 500 \
            -defaultButton btnOK \
            -buttonList btnOK]
        $dlg wait
    } else {
        puts $msg
    }
    return
}
