## generic.tcl

##
# Class Class_with_getvar
#   This class is meant to be used as a superclass. It adds method "getvar"
#   to its subclasses which allows to retrieve the value of any of the
#   object's instance variables.
#
# Instance variables: none
#
# Constructor arguments: none
##

oo::class create Class_with_getvar {

    constructor {} {
        return
    }

    destructor {
        return
    }
}

##
# Class_with_getvar getvar
#
# arguments:
#   varName: the name of the instance variable the value of which
#       has to be retrieved.
#
# returns: the value of instance variable with name 'varName'
##

oo::define Class_with_getvar {
    method getvar {varName} {
        my variable $varName
        set value [subst $[subst $varName]]
        # eval "set value \$$varName"
        return $value
    }
}



##
# A GenDialog object displays a toplevel window containing a message
# and a number of buttons. The "wait" method waits for the user to press
# one of the buttons and returns the label of the pressed button.
#
# A GenDialog object is created as follows:
#
# GenDialog new ?option? .... ?option?
# where option is any of the following
#    -parent $parent: the toplevel parent window
#    -title $title: the title to give to the toplevel window that is created
#    -message $message: the text to display on the window. This is the translated
#            text.
#    -msgWidth $msgWidth: the width in pixels of the message
#    -defaultButton $defaultButton: the untranslated label of the default button, i.e.
#            the button that initially gets the focus
#    -buttonList $buttonList: the list of untranslated labels for the buttons that
#            will be displayed.
#
# These objects can be in 1 of 3 modes: normal, wait, callback.
# 1. normal mode: after creating the object it is in 'normal' mode. The
#       object will be destroyed when the object's window is destroyed.
# 2. wait mode: After creating the object, call the object's wait method.
#       This method does not return before the dialog window is destroyed.
#       It returns the result. The object is destroyed after returning from
#       the wait method.
# 3. callback mode: After creating the object call method defineCallBack.
#       It defines a script that will be executed when the window is
#       destroyed. This script MUST either call the getResult method,
#       which in turn destroys the object, or destroy the object.
##

oo::class create GenDialog {
    superclass Class_with_getvar
    variable window buttonPressed mode callback

    constructor {args} {
        # default values for options
        set parent {.}
        set title "GenDialog"
        set message "No message defined"
        set msgWidth 200
        set defaultButton btnOK
        set buttonList btnOK
        # set options from args
        dict for {option value} $args {
            if {$option in {-parent -title -message -msgWidth -defaultButton -buttonList}} then {
                set [string range $option 1 end] $value
            } else {
                puts "GenDialog: '$option' unknown option"
            }
        }
        set mode "normal"
        set callback {}
        set window [toplevel \
            [appendToPath $parent [namespace tail [string tolower [self namespace]]]]]
        set buttonPressed {}
        wm title $window $title
        wm transient $window $parent
        set x [expr [winfo rootx $parent] + 100]
        set y [expr [winfo rooty $parent] + 50]
        wm geometry $window "+${x}+${y}"
        set msg [message ${window}.msg \
            -width $msgWidth \
            -justify left \
            -text $message]
        set frm [ttk::frame ${window}.frm]
        set row 0
        foreach btnLabel $buttonList {
            set btn [defineButton $frm.$btnLabel $window $btnLabel \
                [list [self object] onButton $btnLabel]]
            grid $btn -row 0 -column $row
            incr row
        }
        pack $msg -side top -expand 1 -fill both -padx {10 10} -pady {10 10}
        pack $frm -side top -pady {0 10}
        if {$defaultButton in $buttonList} then {
            focus $frm.$defaultButton
        }
        bindToplevelOnly $window <Destroy> [list [self object] onDestroy]
        bind $window <KeyPress-Escape> [list destroy $window]
    }

    destructor {
        return
    }
}

##
# method onDestroy
#   This method is an event procedure that is meant to be bound to
#   the destroy event of the toplevel window. If the method 'wait' was
#   not previously called, it destroys the object.
#
# arguments: none
##

oo::define GenDialog {
    method onDestroy {} {
        if {$mode eq "normal"} then {
            # neither wait, nor defineCallBack was called. Just destroy object.
            after idle [list [self object] destroy]
        } elseif {$mode eq "callback"} then {
            eval $callback
            # It is up to the object's creator to destroy the object
            # e.g. by calling getResult
        } else {
            # wait mode: don't do anything. The wait method was called
            # which will destroy the object.
        }
        return
    }
}

##
# method onButton
#   This method is an event procedure that is meant to be called when
#   one of the dialogue buttons is pressed. It registers which button
#   has been pressed and then destroys the window, but not the object.
#
# arguments:
#   - btnLabel: the text that will be returned to the user of the object
#       by the wait method.
##

oo::define GenDialog {
    method onButton {btnLabel} {
        set buttonPressed $btnLabel
        destroy $window
        return
    }
}

##
# method wait
#   This method lets the calling procedure wait until the user has
#   pressed one of the dialogue's buttons or until the window is
#   destroyed. It returns the label of the button that was pressed, or
#   the empty string. The object is automatically destroyed after returning
#   from wait.
##

oo::define GenDialog {
    method wait {} {
        set mode "wait"
        tkwait window $window
        after idle [list [self object] destroy]
        return $buttonPressed
    }
}

##
# GenDialog defineCallBack $script
#   This method sets $script as call back script to be called when the
#   toplevel window is destroyed. It sets the GenDialog object in
#   callback mode.
# arguments:
#   - script: this script should call the getResult method to
#       to get the result from the dialogue.
##

oo::define GenDialog {
    method defineCallBack {script} {
        set callback $script
        set mode "callback"
        return
    }
}

##
# method getResult
#   This method should be called from the callback script that was defined
#   by method defineCallBack. It returns the label of the button that was pressed, or
#   the empty string. The object is automatically destroyed after returning
#   from getResult.
##

oo::define GenDialog {
    method getResult {} {
        after idle [list [self object] destroy]
        return $buttonPressed
    }
}


##
# Class GenForm
#
# A GenForm object displays a toplevel window which enables the user to
# see and modify a number of data.
#
# A GenForm object is created as follows:
#
#      GenForm new $parent $title $dataList
#
#      where: $parent: is the parent's window path
#
#             $title: title for window
#
#             $dataList is a list containing an item for each data item
#                 that is displayed on the window, and where each item
#                 is a dict with the folling keys:
#                     -name: data item's name which must be unique
#                            within this dialog
#                     -type: the data item's type, which must be one of
#                            string, bool, password
#                     -value: the data item's initial value
#                     -valuelist: a list of allowed values. If this
#                            list is not empty, a combox is used, else
#                            a normal text entry is used.
#
# These objects can be in 1 of 3 modes: normal, wait, callback
#
# 1. normal mode: after creating the object it is in 'normal' mode.
# 2. wait mode: After creating the object, call the object's wait method.
#       This method does not return before the form window is destroyed.
#       It returns the result. The object is destroyed after returning from
#       the wait method.
# 3. callback mode: After creating the object call method defineCallBack.
#       It defines a script that will be executed when the window is
#       destroyed. This script MUST either call the getResult method,
#       which in turn destroys the object, or destroy the object.
##

oo::class create GenForm {
    superclass Class_with_getvar
    variable data window pressedOK frm1 callback mode

    constructor {parent title dataList} {
        set pressedOK 0
        set mode "normal"
        set callback {}
        set window [toplevel \
            [appendToPath $parent [namespace tail [string tolower [self namespace]]]]]
        wm transient $window $parent
        set x [expr [winfo rootx $parent] + 100]
        set y [expr [winfo rooty $parent] + 50]
        wm geometry $window "+${x}+${y}"
        wm title $window $title
        set frm1 [ttk::frame ${window}.frm1]
        set entrywidth 40
        set idx 0
        foreach item $dataList {
            set name [dict get $item name]
            set type [dict get $item type]
            set value [dict get $item value]
            set valuelist [dict get $item valuelist]
            set data($name) $value
            set label [ttk::label $frm1.lb$idx -text $name \
                -compound right -image ::img::empty_5_9]
            set varName [my varname data($name)]
            if {$type eq "bool"} then {
                set control [ttk::checkbutton $frm1.cont$idx \
                    -variable $varName \
                    -onvalue 1 -offvalue 0]
                set sticky w
                set focusWidget $control
            } elseif {$type eq "password"} then {
                set control [entry $frm1.cont$idx \
                    -textvariable $varName -width $entrywidth \
                    -show "*"]
                set sticky we
                set focusWidget $control
            } elseif {($type eq "filename") || ([llength $valuelist] > 0)} then {
                set varName [my varname data($name)]
                if {$type eq "filename"} then {
                    set filetypes [dict get $item filetypes]
                    set cmd [list [self object] onSelectFile $varName $filetypes]
                } else {
                    set cmd [list [self object] onSelectValue $varName $name $valuelist]
                }
                set control [ttk::frame $frm1.cont$idx -takefocus 0]
                set entry [entry $control.file$idx -textvariable $varName \
                    -width $entrywidth]
                $entry configure -state {readonly}
                set btn [ttk::button $control.sel$idx \
                    -image ::img::arrow_down \
                    -takefocus 0 \
                    -command $cmd]
                bind $entry <Alt-KeyPress-s> [list $btn invoke]
                bind $entry <KeyPress-Down> [list $btn invoke]
                pack $entry -side left -expand 1 -fill x
                pack $btn -side left -fill both
                set sticky we
                set focusWidget $entry
            } else {
                set control [entry $frm1.cont$idx -width $entrywidth \
                    -textvariable [my varname data($name)]]
                set sticky we
                set focusWidget $control
            }
            bind $focusWidget <FocusIn> \
                [list $label configure -compound right -image ::img::arrow_right]
            bind $focusWidget <FocusOut> \
                [list $label configure -compound right -image ::img::empty_5_9]
            if {$idx == 0} then {
                focus $focusWidget
            }
            grid $label -column 0 -row $idx -sticky $sticky
            grid $control -column 1 -row $idx -sticky $sticky
            incr idx
        }
        grid columnconfigure $frm1 1 -weight 1
        pack $frm1 -side top -padx {10 10} -pady {10 10} -fill x
        set frm2 [ttk::frame ${window}.frm2]
        set btnOK [defineButton $frm2.ok $window btnOK [list [self object] onOK]]
        set btnCancel [defineButton $frm2.cancel $window btnCancel \
            [list [self object] onCancel]]
        pack $btnCancel -side right
        pack $btnOK -side right
        pack $frm2 -side top -fill x -padx {10 10} -pady {0 10}
        bindToplevelOnly $window <Destroy> [list [self object] onDestroy]
        bind $window <KeyPress-Escape> [list destroy $window]
        # bind $window <KeyPress-Down> {focus [tk_focusNext [focus]]}
        # bind $window <KeyPress-Up> {focus [tk_focusPrev [focus]]}
        bind $window <KeyPress-Return> [list [self object] onOK]
    }

    destructor {
    }
}

##
# method onDestroy
#   This method is an event procedure which is meant to be bound
#   to the destroy event of the toplevel window. It destroys the
#   object if the 'wait' method was not previously called.
##

oo::define GenForm {
    method onDestroy {} {
        if {$mode eq "normal"} then {
            after idle [list [self object] destroy]
        } elseif {$mode eq "callback"} then {
            eval $callback
            # object should be destroyed by callback by calling getResult
        } else {
            # mode eq wait: do nothing. Object is destroyed by wait method
        }
        return
    }
}

##
# method wait $resultVar
#   This method is called to wait for the result of the user input.
#
# arguments:
#   - resultVar: the name of the result array which will contain the
#       user input after returning from the wait method.
#
# returns: a boolean which indicates whether or not the OK button
#   was pressed.
##

oo::define GenForm {
    method wait {resultVar} {
        upvar $resultVar result
        set mode "wait"
        tkwait window $window
        array set result [array get data]
        after idle [list [self object] destroy]
        return $pressedOK
    }
}


##
# method getResult $resultVar
#   This method is called to get the result. After calling this method
#   the GenForm object is destroyed. It should be called by the script
#   defined as 'callback' script with the defineCallBack method.
#
# arguments:
#   - resultVar: the name of the result array which will contain the
#       user input after returning from the wait method.
#
# returns: a boolean which indicates whether or not the OK button
#   was pressed.
##

oo::define GenForm {
    method getResult {resultVar} {
        upvar $resultVar result
        array set result [array get data]
        after idle [list [self object] destroy]
        return $pressedOK
    }
}

##
# method onOK
#   This method is an event procedure which is meant to be called
#   when the user has pressed the OK button. It registers that the
#   user has pressed OK and destroys the window.
#
# arguments: none
##

oo::define GenForm {
    method onOK {} {
        set pressedOK 1
        destroy $window
        return
    }
}

##
# method onCancel
#   This method is an event procedure which is meant to be called
#   when the user has pressed the Cancel button. It registers that
#   the user has pressed Cancel and destroys the window.
#
# arguments: none
##

oo::define GenForm {
    method onCancel {} {
        set pressedOK 0
        destroy $window
        return
    }
}

##
# method displayHelpText
#   This method can be used to display a help text for the user
#   at the top of the window.
#
# arguments:
#   - helpText: the text to be displayed.
##

oo::define GenForm {
    method displayHelpText {helpText} {
        set lbHelp [ttk::label ${window}.lbHelp -text $helpText \
            -padding {10 10 10 10}]
        pack $lbHelp -side top -before $frm1
        return
    }
}


##
# GenForm defineCallBack $callBackScript
#   This method sets $callBackScript as script to be called when the
#   toplevel window is destroyed. It sets the GenForm object in
#   callback mode.
# arguments:
#   - callBackScript: this script should call the getResult method to
#       to get the result from the form.
##

oo::define GenForm {
    method defineCallBack {callBackScript} {
        set mode "callback"
        set callback $callBackScript
        return
    }
}

oo::define GenForm {
    method onSelectFile {filenameName filetypes} {
        upvar $filenameName filename
        if {[string length $filename]} then {
            set fullpath [file normalize $filename]
            set directory [file dirname $fullpath]
            set tailname [file tail $fullpath]
        } else {
            set directory [tkpOptions getOption fileselection lastdir]
            set tailname {}
        }
        set fs [FileSelection new -parent $window -directory $directory \
            -filename $tailname -filetypes $filetypes]
        set newfile [$fs wait]
        if {$newfile ne {}} then {
            set filename $newfile
        }
        return
    }
}

oo::define GenForm {
    method onSelectValue {dataName name valuelist} {
        upvar $dataName data
        set selected [lsearch -exact $valuelist $data]
        if {$selected < 0} then {
            set selected 0
        }
        set lsb [ListBox new $window [mc miscChoose $name] $name \
            $valuelist $selected]
        if {[$lsb wait result]} then {
            set data $result
        }
        return
    }
}

##
# A TextEdit object displays a window in which the user can see
# and possibly edit a text. To create a TextEdit object use:
#
#     TextEdit new $parent $title $initialText $readOnly
#
# where: - $parent is the widget pathname of the parent window
#        - $title is the window title
#        - $initialText: is the text that will be displayed initially
#        - $readOnly: 0 or 1, indicating whether the user is allowed
#                     to edit the text.
#
# After creating the object, there are 3 possible modes of use.
#
# 1. Normal mode:  In this mode, the initial text is displayed, but
#                  it is not possible to get any result. You don't
#                  have to worry about deleting the object. It is
#                  deleted automatically when the user presses OK or
#                  Cancel, or when he destroys the window. This mode
#                  is only usefull for readOnly text.
#
# 2. Wait mode:    In this mode, after creating the object, you call
#                  the object's "wait" method. This method does not
#                  return before the user has pressed OK or Cancel, or
#                  has destroyed the window. The wait method should be
#                  called as follows:
#
#                  textEditObject wait textVarName
#
#                  It returns 1 or 0 edpending on whether OK or Cancel
#                  was pressed, and it stores the result in the variable
#                  with the name textVarName. You don't have to worry
#                  about deleting the object. It is automatically deleted
#                  after returning from the wait method.
#
# 3. CallBack mode: In this mode, after creating the object, you call
#                  the object's "defineCallBack" method. This method is
#                  called as follows:
#
#                  textEditObject defineCallBack callBackScript
#
#                  This callBackScript must call the object's getText
#                  method as follows:
#
#                  textEditObject getText textVarName
#
#                  It returns 1 or 0 depending on whether OK or Cancel
#                  was pressed, and it stores the result in the variable
#                  with the name textVarName. After returning from this
#                  method, the textEditObject no longer exists. So, you
#                  can call this method only once.
#
# You can also add custom menus to the this widget using the method
# addMenuItem
#
#  textEditObject addMenuItem $btnLabel $type $arg
#
# where $type is either command or cascade
#
# $arg is then either a script to be called when the menuitem is invoked,
# or the name of a menu in case of cascade.
#
# In case of command, you can use %T to represent the text widget's pathname.
#
# If you want to destroy the object, do not call object destroy, but
# call the destroyWindow method instead.
#
# Instance variables:
#   - window: the Tk path of the toplevel window associated with
#       the TextEdit object
#   - menubar: the Tk path of the menubar on the TextEdit window
#   - readOnly: boolean indicating whether this TextEdit is readonly
#   - txtWidget: Tk path of the text widget
#   - actualText: variable that is set to the text in the text widget
#       after the user has pressed OK.
#   - wrap: boolean that is bound to the 'Wrap' checkbutton. When true
#       the text widget's word wrap is switched on. When false, lines
#       are not wrapped at the widget boundery.
#   - btnFrame: the Tk path of the frame containing the buttons.
#   - entSearch: the Tk path of the entry for entering the search pattern.
#   - pressedOK: boolean: 1 user has pressed OK, 0 user has not pressed OK
#   - mode: one of {normal wait callback}
#   - callback: the callback script as defined by the user in the
#       defineCallBack method.
##

oo::class create TextEdit {
    superclass Class_with_getvar
    variable window menubar readOnly txtWidget actualText wrap btnFrame \
        entSearch pressedOK mode callback


    constructor {parent title initialText c_readOnly} {
        set actualText {}
        set wrap "none"
        set mode "normal"
        set callback {}
        set pressedOK 0
        set readOnly $c_readOnly
        my setupWindow $parent $title $initialText
    }

    destructor {
    }
}

##
# TextEdit setupWindow $parent $title $initialText
#   This method sets up the TextEdit window and its widgets.
# arguments:
#   - parent: Tk path of the parent window
#   - title: window title
#   - initialText: the text that is displayed initially.
##

oo::define TextEdit {
    method setupWindow {parent title initialText} {
        set window [toplevel [appendToPath $parent [namespace tail [string tolower [self namespace]]]]]
        wm title $window $title
        wm geometry $window [join [geometry::getSize text] {x}]
        set menubar [my setupMenus]
        $window configure -menu $menubar
        set txtWidget [text $window.txt -width 1 -height 1 -wrap $wrap]
        $txtWidget tag configure blue -foreground {medium blue}
        $txtWidget tag configure red -foreground {red4}
        $txtWidget tag configure green -foreground {green4}
        if {$readOnly} then {
            $txtWidget configure -background $::readonlyBackground
        }
        set vsb [ttk::scrollbar $window.vsb -orient vertical \
            -command [list $txtWidget yview]]
        set hsb [ttk::scrollbar $window.hsb -orient horizontal \
            -command [list $txtWidget xview]]
        $txtWidget configure \
            -yscrollcommand [list $vsb set] \
            -xscrollcommand [list $hsb set]
        $txtWidget insert end $initialText
        $txtWidget mark set insert 1.0
        $txtWidget yview 0
        set btnFrame [ttk::frame $window.btnFrame]
        if {!$readOnly} then {
            set btnOK [defineButton $btnFrame.btnOK $window btnOK \
                [list [self object] onOK]]
        } else {
            set lbReadOnly [ttk::label $btnFrame.rdonly \
                -text [mc lbReadOnly] -foreground {medium blue}]
            $txtWidget configure -state disabled
        }
        set btnCancel [defineButton $btnFrame.btnCancel $window btnCancel \
            [list [self object] onCancel]]
        set btnWrap [defineCheckbutton $btnFrame.btnWrap $window btnWrap \
            [list [self object] onWrap] [my varname wrap] word none]
        set searchFrm [ttk::frame $btnFrame.search]
        set btnSearch [defineButton $searchFrm.btn $window btnSearch \
            [list [self object] onSearch]]
        set entSearch [entry $searchFrm.ent]
        bind $entSearch <KeyPress-Return> [list [self object] onSearch]
        pack $btnSearch -side right
        pack $entSearch -side right -expand 1 -fill both
        grid $txtWidget -column 0 -row 1 -sticky wens
        grid $vsb -column 1 -row 1 -sticky ns
        grid $hsb -column 0 -row 2 -sticky we
        grid $btnFrame -column 0 -columnspan 2 -row 3 -sticky we \
            -pady {10 10} -padx {10 10}
        grid [ttk::sizegrip ${window}.sg] -column 0 -columnspan 2 \
            -row 4 -sticky e
        grid columnconfigure $window 0 -weight 1
        grid rowconfigure $window 1 -weight 1
        pack $btnCancel -side right
        if {!$readOnly} then {
            pack $btnOK -side right
        } else {
            pack $lbReadOnly -side right
        }
        pack $searchFrm -side right -expand 1 -fill x
        pack $btnWrap -side right
        set tpOnly [bindToplevelOnly $window <Destroy> [list [self object] onDestroy]]
        bind $tpOnly <Configure> {geometry::setSize text {%w %h}}
        bind $window <KeyPress-Escape> [list destroy $window]
        focus $txtWidget
        return
    }
}

##
# TextEdit setupMenus
#   This method defines the TextEdit menus
##

oo::define TextEdit {
    method setupMenus {} {
        set menu [menu ${window}.menubar -tearoff 0]
        set mnuText [menu ${menu}.text -tearoff 0]
        #::addMenuItem $mnuText mnuTxtSave command [list [self object] onSave]
        #::addMenuItem $mnuText mnuTxtPrint command [list [self object] onPrint]
        ::addMenuItem $mnuText mnuTxtClose command [list destroy $window]
        $mnuText entryconfigure 0 -accelerator {Esc}
        ::addMenuItem $menu mnuText cascade $mnuText
        return $menu
    }
}

##
# TextEdit onDestroy
#   This method is an event procedure which is meant to be called
#   when the window is destroyed.
##

oo::define TextEdit {
    method onDestroy {} {
        switch $mode {
            normal {
                after idle [list [self object] destroy]
            }
            callback {
                eval $callback
                # It is up to the creator of the object to destroy it
                # e.g. by calling method getText
            }
            default {
                # wait was called, which will destroy the object.
            }
        }
        return
    }
}

##
# TextEdit onPrint
#   This method is called when the user activates the Print menu.
#   It calls the printTextWidget procedure
##

#oo::define TextEdit {
    #method onPrint {} {
        #printTextWidget $txtWidget $window
        #return
    #}
#}

##
# TextEdit onSave
#   This method is called when the user activates the Save menu.
##

#oo::define TextEdit {
    #method onSave {} {
        #saveTxtFromWidget $txtWidget $window
        #return
    #}
#}

##
# TextEdit onWrap
#   This method is called when the user clicks the 'Wrap' checkbutton.
##

oo::define TextEdit {
    method onWrap {} {
        $txtWidget configure -wrap $wrap
        return
    }
}

##
# TextEdit gotoBegin
#   This method can be called to set the cursor to begin of the text.
##

oo::define TextEdit {
    method gotoBegin {} {
        $txtWidget mark set insert 1.0
        $txtWidget yview 0
        return
    }
}

##
# TextEdit onSearch
#   This method is ab event procedure that is meant to be called
#   when the user presses the Search button.
##

oo::define TextEdit {
    method onSearch {} {
        focus $entSearch
        set pattern [$entSearch get]
        if {[string length $pattern]} then {
            set searchPosition [$txtWidget index insert]
            $txtWidget tag delete match
            set searchPosition [$txtWidget search -nocase \
                $pattern $searchPosition end]
            if {$searchPosition ne {}} then {
                set endmatch [$txtWidget index \
                    "$searchPosition +[string length $pattern] chars"]
                $txtWidget tag add match $searchPosition $endmatch
                $txtWidget tag configure match -background yellow
                $txtWidget mark set insert $endmatch
                $txtWidget see insert
            } else {
                tkp_message [mc searchEOT] $window
                $txtWidget mark set insert 1.0
                $txtWidget see insert
            }
        }
        return
    }
}

##
# TextEdit onOK
#   This method is an event procedure that is called when the user
#   presses OK. It copies the text from the text widget in the
#   'actualText' instance variable and destroys the toplevel window.
##

oo::define TextEdit {
    method onOK {} {
        set pressedOK 1
        set actualText [$txtWidget get 1.0 "end - 1 chars"]
        destroy $window
        return
    }
}

##
# TextEdit onCancel
#   This method is an event procedure that is called when the user
#   pressed Cancel. It destroys the toplevel window.
##

oo::define TextEdit {
    method onCancel {} {
        set pressedOK 0
        set actualText {}
        destroy $window
        return
    }
}

##
# TextEdit addMenuItem $itemLabel $itemType $argument
#   This method can be called to add a menu item to the TextEdit window.
# arguments:
#   - itemLabel: the text for the label of the menu item
#   - itemType: one of {command cascade}
#   - argument:
#       - if $itemType == 'command':
#           A script to be called when the item is activated. In this
#           script '%T' can be used to represent the text widget's
#           Tk path.
#       - if $itemType == 'cascade':
#           The Tk path of another menu.
##

oo::define TextEdit {
    method addMenuItem {itemLabel itemType argument} {
        set argument [string map [list %T $txtWidget] $argument]
        ::addMenuItem $menubar $itemLabel $itemType $argument
        return
    }
}

##
# TextEdit getText $textVar
#   This method should be called in 'callback' mode. It copies the
#   actualText instance variable to the variable with name $textVar.
# arguments:
#   - textVar: the name of the variable that will receive the text.
# returns: 1 if the user has pressed OK, 0 if the user did not press
#   OK. In the latter case the $textVar variable is not modified.
##

oo::define TextEdit {
    method getText {textVar} {
        upvar $textVar result
        if {$pressedOK} then {
            set result $actualText
        }
        after idle [list [self object] destroy]
        return $pressedOK
    }
}

##
# TextEdit setText $textVar
#   This method copies the text in the variable with name $textVar
#   to the TextEdit's text widget.
# arguments:
#   - textvar: the name of the variable that contains the text.
##

oo::define TextEdit {
    method setText {textVar} {
        upvar $textVar text
        if {$readOnly} then {
            $txtWidget configure -state normal
        }
        $txtWidget delete 1.0 end
        $txtWidget insert end $text
        if {$readOnly} then {
            $txtWidget configure -state disabled
        }
        return
    }
}

##
# TextEdit appendText $text $colour
#   This method appends $text to the TextEdit's text widget.
# arguments:
#   - textvar: the name of the variable that contains the text.
#   - colour: one of {red green blue black}
##

oo::define TextEdit {
    method appendText {text colour} {
        if {$readOnly} then {
            $txtWidget configure -state normal
        }
        if {$colour in {red green blue}} then {
            $txtWidget insert end $text $colour
        } else {
            $txtWidget insert end $text
        }
        if {$readOnly} then {
            $txtWidget configure -state disabled
        }
        return
    }
}

##
# TextEdit wait $textVar
#   This method waits for the TextEdit's toplevel window to be destroyed.
#   If the user has pressed OK, the text is copied from the text widget
#   to the variable with name $textVar
# arguments:
#   - textVar: the name of the variable that will receive the text from
#       the text widget
# returns: 1 if user pressed OK, 0 if user did not press OK
##

oo::define TextEdit {
    method wait {textVar} {
        upvar $textVar result
        set mode "wait"
        tkwait window $window
        set result $actualText
        after idle [list [self object] destroy]
        return $pressedOK
    }
}

##
# TextEdit defineCallBack $callBackScript
#   This method sets $callBackScript as script to be called when the
#   toplevel window is destroyed. It sets the TextEdit object in
#   'callback' mode.
# arguments:
#   - callBackScript: this script should call the getText method to
#       to get the text from the text widget.
##

oo::define TextEdit {
    method defineCallBack {callBackScript} {
        set callback $callBackScript
        set mode "callback"
        return
    }
}

##
# TextEdit destroyWindow
#   This method destroys the TextEdit's toplevel window.
##

oo::define TextEdit {
    method destroyWindow {} {
        destroy $window
        return
    }
}

oo::define TextEdit {
    method displayHelpText {helpText} {
        set txtHelp [ttk::label [appendToPath $window help] -text $helpText]
        grid $txtHelp -row 0 -column 0 -columnspan 2 -sticky we
        return
    }
}

##
# A ListBox object creates a toplevel window with a multicolumn listbox
# (ttk::treeview control) to allow the user to select a value from
# a list of values. Additionally, it has an entry and a button which
# allows the user to search for a particular string in the listbox
# values.
#
# To create a ListBox object call
#
# ListBox new $parent $title $headerlist $valuelist $selected
#
# where: -parent is the pathname of the parent toplevel window.
#        -title: the toplevel's title
#        -headerlist: the list of column headers. The length of
#         this list determines the number of columns
#        -valuelist: the list of values for the listbox where each item
#         is a list containing a value for each column
#        -selected: the index of the initially selected listbox item
#
# ListBox tries to estimate an optimum columnwidth and window size.
#
# After creating the ListBox object, call the wait method to
# get the user's choice:
#
# listBoxObject wait result
#
# where result is the name of the variable that will receive the
# selected value(s). The return value of the wait method is 1 or 0
# depending on whether the user has really selected a value or
# just destroyed the window.
#
# If you want to destroy the object, do not call delete object, but
# call the destroyWindow method instead.
##

oo::class create ListBox {
    superclass Class_with_getvar
    variable window valuelist lsb entSearch mode callback itemSelected \
        selectedValues statusfield stringFound

    constructor {parent title headerlist c_valuelist selected} {
        set valuelist $c_valuelist
        set mode "normal"
        set callback {}
        set itemSelected 0
        set selectedValues {}
        set stringFound 0
        set window [toplevel [appendToPath $parent \
            [namespace tail [string tolower [self namespace]]]]]
        wm transient $window $parent
        set x [expr [winfo rootx $parent] + 100]
        set y [expr [winfo rooty $parent] + 50]
        wm geometry $window "+${x}+${y}"
        wm title $window $title
        set frmSearch [ttk::frame $window.frmSearch]
        set entSearch [entry $frmSearch.ent]
        set btnSearch [defineButton $frmSearch.btn $window btnSearch \
            [list [self object] onSearch]]
        bind $entSearch <KeyPress-Return> [list [self object] onSearch]
        pack $btnSearch -side right
        pack $entSearch -side right -expand 1 -fill both
        set frmLsb [ttk::frame $window.frmlsb]
        set columnlist {}
        for {set idx 0} {$idx < [llength $headerlist]} {incr idx} {
            lappend columnlist col$idx
        }
        set lsb [ttk::treeview $frmLsb.lsb -columns $columnlist \
            -selectmode browse -show headings]
        set idx 0
        foreach heading $headerlist {
            $lsb heading col$idx -text $heading
            $lsb column col$idx -width [my estimateColumnWidth $idx]
            incr idx
        }
        set idx 0
        set selItem "I0"
        foreach tuple $valuelist {
            set item [$lsb insert {} end -id "I$idx" -values $tuple]
            if {$idx == $selected} then {
                set selItem $item
            }
            incr idx
        }
        set vsb [ttk::scrollbar $frmLsb.vsb -orient vertical \
            -command [list $lsb yview]]
        $lsb configure -yscrollcommand [list $vsb set]
        grid $lsb -column 0 -row 0 -sticky wens
        grid $vsb -column 1 -row 0 -sticky ns
        grid columnconfigure $frmLsb 0 -weight 1
        grid rowconfigure $frmLsb 0 -weight 1
        set btnBar [ttk::frame $window.btnBar]
        set btnOK [defineButton $btnBar.btnOK $window btnOK \
            [list [self object] onSelection]]
        $btnOK configure -style TButton
        set btnCancel [defineButton $btnBar.btnCancel $window btnCancel \
            [list destroy $window]]
        $btnCancel configure -style TButton
        grid $btnOK -column 0 -row 0
        grid $btnCancel -column 1 -row 0
        grid anchor $btnBar center
        set statusbar [ttk::frame $window.sb]
        set statusfield [ttk::label $statusbar.sf]
        set grip [ttk::sizegrip $statusbar.sg]
        grid $statusfield -column 0 -row 0
        grid $grip -column 1 -row 0 -sticky e
        grid columnconfigure $statusbar 0 -weight 1
        pack $frmSearch -side top -fill x -pady 10 -padx 10
        pack $frmLsb -side top -expand 1 -fill both
        pack $btnBar -side top -fill x -ipady 10 -ipadx 10
        pack $statusbar -side top -fill x
        bindToplevelOnly $window <Destroy> [list [self object] onDestroy]
        # bind $lsb <1> [list after idle [list [self object] onSelection]]
        # Note: The above binding has the annoying side effect that
        # the user cannot adjust the column widths without destroying
        # the window. That is why it has been commented out.
        bind $lsb <KeyPress-Return> [list after idle [list [self object] onSelection]]
        bind $window <KeyPress-Escape> [list destroy $window]
        update
        focus $window
        focus $lsb
        # next "if" statement has been added for bug 1073
        if {[llength $valuelist] > 0} then {
            $lsb see $selItem
            $lsb selection set $selItem
            $lsb focus $selItem
        }
        return
    }

    destructor {
        return
    }
}

##
# ListBox estimateColumnWidth $column
#   This method estimates the required column width for column $column.
# arguments:
#   - column: the index of the column [0 .. (nrOfColumns - 1)]
# returns: required column width in pixels.
##

oo::define ListBox {
    method estimateColumnWidth {column} {
        set nrOfChars 0
        set text {}
        foreach tuple $valuelist {
            set stringLength [string length [lindex $tuple $column]]
            if {$stringLength > $nrOfChars} then {
                set nrOfChars $stringLength
                set text [lindex $tuple $column]
            }
        }
        set width [font measure TkTextFont -displayof $window " $text "]
        return $width
    }
}

##
# ListBox onDestroy
#   This method is an event procedure that is meant to be called
#   when the listbox window is destroyed
##

oo::define ListBox {
    method onDestroy {} {
        if {$mode eq "normal"} then {
            after idle [list [self object] destroy]
        } elseif {$mode eq "callback"} then {
            eval $callback
            # It is up to the object's creator to destroy the object
            # e.g. by calling getResult
        } else {
            # wait mode: don't do anything. The wait method was called
            # which will destroy the object.
        }
        return
    }
}

##
# ListBox destroyWindow
#   This method destroys the ListBox's window.
##

oo::define ListBox {
    method destroyWindow {} {
        destroy $window
        return
    }
}

##
# ListBox onSelection
#   This method is an event procedure that is meant to be called
#   when an item of the treeview widget is selected.
#   It sets the instance variables itemSelected and selectedValues.
##

oo::define ListBox {
    method onSelection {} {
        set itemSelected 1
        set selectedValues [$lsb item [$lsb selection] -values]
        destroy $window
        return
    }
}

##
# ListBox wait $resultName
#   This method waits for the ListBox's window to be destroyed.
#   It copies the instance variable selectedValues in the variable
#   with name $resultName.
# arguments:
#   - resultName: the name of the variable in which the list of selected
#       values are store
# returns: 1 if an item was selected, 0 if no item was selected
##

oo::define ListBox {
    method wait {resultName} {
        upvar $resultName result
        set mode "wait"
        tkwait window $window
        set result $selectedValues
        after idle [list [self object] destroy]
        return $itemSelected
    }
}


##
# ListBox defineCallBack $script
#   This method sets $script as call back script to be called when the
#   toplevel window is destroyed. It sets the ListBox object in
#   callback mode.
# arguments:
#   - script: this script should call the getResult method to
#       to get the result from the ListBox.
##

oo::define ListBox {
    method defineCallBack {script} {
        set callback $script
        set mode "callback"
        return
    }
}

##
# ListBox getResult $resultName
#   This method should be called by the callback script.
#   It copies the instance variable selectedValues in the variable
#   with name $resultName.
# arguments:
#   - resultName: the name of the variable in which the list of selected
#       values are store
# returns: 1 if an item was selected, 0 if no item was selected
##

oo::define ListBox {
    method getResult {resultName} {
        upvar $resultName result
        set result $selectedValues
        after idle [list [self object] destroy]
        return $itemSelected
    }
}

##
# ListBox onSearch
#   This method is an event procedure that is called when the Search
#   button is pressed. It search the list for the instance variable
#   $searchString and moves the focus to the item that matches.
##

oo::define ListBox {
    method onSearch {} {
        focus $entSearch
        set searchString [$entSearch get]
        if {[string length $searchString]} then {
            set currentValues [$lsb item [$lsb selection] -values]
            set startIndex [lsearch -exact $valuelist $currentValues]
            if {$stringFound} then {
                set startIndex [expr $startIndex + 1]
            }
            set newIndex [lsearch -nocase -glob -start $startIndex \
                $valuelist "*${searchString}*"]
            if {$newIndex >= 0} then {
                set stringFound 1
                $lsb selection set "I${newIndex}"
                $lsb focus "I${newIndex}"
                $lsb see "I${newIndex}"
                $statusfield configure -text [mc lsbSearchFound $searchString]
            } else {
                set stringFound 0
                $lsb selection set "I0"
                $lsb focus "I0"
                $lsb see "I0"
                $statusfield configure -text [mc lsbSearchNotFound]
            }
        }
        return
    }
}


##
# A FileSelection object creates a toplevel window which allows the
# user to select a filename or a directory name. It has the following
# features:
#   - a readonly text entry which displays the full path of the
#     currently selected directory;
#   - a text entry which displays the currently selected filename which
#     is to be appended to the name of the current directory to get
#     the fully qualified selected filename;
#   - a listbox at the left which displays the subdirectories of the
#     currently selected directory;
#   - a listbox at the right which displays the files in the currently
#     selected directory;
#   - a dropdown listbox which allows the user to select a file type pattern.
#
# To create a FileSelection object call
#
# FileSelection new ?options?
#
# where options can be one or more of:
#   -parent $parent : where $parent is the Tk path of the parent widget
#   -directory $directory : where $directory is the fully qualified
#       pathname of the initial directory
#   -filename $filename : where $filename is the tail of the initial filename
#   -title $title : where $title is the text to be used as title for the
#       toplevel
#   -filetypes $filetypes : where $filetypes is a list of file patterns
#       in which each file pattern is a list of the form
#
#       typeName {extension ?extension ...?}
#
#       typeName is the name of the file type described by this file pattern
#           and is the text string that appears in the File types listbox.
#       extension is of the form '*.txt', '*.sql', ...etc.
#
#       The default values is [list [list "All files" "*"]]
#
#       example: -filetypes {{{Databases} {*.db *.sqlite}} {{All files} {*}}}
#
# After creating a FileSelection object you can call either the 'wait'
# method or the 'defineCallBack' method. The call back script should
# call the getResult method. Both the 'wait' and the 'getResult' methods
# destroy the object.
#
# Instance variables:
#   - window: the the Tk path of the toplevel window associated with the
#        object
#   - parent: the Tk path of the parent window
#   - directory: the currently selected directory (fully qualified path)
#   - filename: the tail of the currently selected filename
#   - title: the title displayed on the toplevel window
#   - filetypes: value of the -filetypes option
#   - typesForCombo: same as 'filetypes' but in a format suitable for displaying
#        in the combo widget
#   - showHidden: boolean indicating whether to show hidden files
#   - tvDir: treeview widget for subdirectories
#   - tvFiles: treeview widget for files
#   - dirItems: the list of itemnames in tvDir
#   - fileItems: the list of itemnames in tvFiles
#   - dirList: the list of subdirectories in tvDir
#   - fileList: the list of filenames in tvFiles
#   - mode: one of normal, wait or callback
#   - filter: filter used in glob command
#   - pressedOK: boolean wihc is true when OK button has been pressed
#   - callback: the callback script
#   - fromDir: the subdirectory from which the "Up" button was pressed.
#       It is used by refreshListboxes to set the selection to that
#       subdirectory after the user has pressed "Up".
#   - entDir: the entry for the directory name
#   - entFilename: the entry for the filename
##

oo::class create FileSelection {
    variable window parent directory filename title filetypes typesForCombo \
        showHidden tvDir tvFiles dirItems fileItems dirList fileList mode \
        filter pressedOK callback fromDir entDir entFilename

    constructor {args} {
        set parent {}
        set directory [tkpOptions getOption fileselection lastdir]
        set filename {}
        set title {Select filename}
        set showHidden 0
        set mode normal
        set pressedOK 0
        set callback {}
        set fromDir {}
        set allFiles [list "All files" [list "*"]]
        set filetypes [list $allFiles]
        set filter {*}
        dict for {option value} $args {
            if {$option eq {-parent}} then {
                set parent $value
            } elseif {$option eq {-directory}} then {
                if {![catch {file normalize $value} dirname] \
                    && [file exists $dirname] \
                    && [file isdirectory $dirname]} then {
                        set directory $dirname
                }
            } elseif {$option eq {-filename}} then {
                set filename $value
            } elseif {$option eq {-title}} then {
                set title $value
            } elseif {$option eq {-filetypes}} then {
                set filetypes $value
                set filter [lindex $filetypes 0 1]
                #puts $filter
            } else {
                puts "FileSelection '$option': unknown option"
            }
        }
        set typesForCombo {}
        foreach typespec $filetypes {
            lappend typesForCombo "[lindex $typespec 0] ([join [lindex $typespec 1] ", "])"
        }
        my initWindow
        update
        my refreshListboxes
        return
    }

    destructor {
        if {$pressedOK} then {
            tkpOptions setOption fileselection lastdir $directory
            tkpOptions saveOptions
        }
        return
    }
}


##
# FileSection refreshListBoxes
#     This method refreshes the listboxes with the subdirectories and files
##

oo::define FileSelection {
    method refreshListboxes {} {
        # puts $filter
        global tcl_platform
        set dirList {}
        set dirItems {}
        set fileList {}
        set fileItems {}
        if {($directory eq {}) && ($tcl_platform(platform) eq {windows})} then {
            set dirList [lsort [file volumes]]
            set fileList {}
        } else {
            if {[catch {glob -tails -directory $directory -types d *} dirList]} then {
                set dirList {}
            }
            if {$showHidden} then {
                if {![catch {glob -tails -directory $directory -types {d hidden} *} hidden]} then {
                    set dirList [concat $dirList $hidden]
                }
            }
            set dirList [lsort $dirList]
            if {[catch {glob -tails -directory $directory -types f {*}$filter} fileList]} then {
                set fileList {}
            }
            if {$showHidden} then {
                if {![catch {glob -tails -directory $directory -types {f hidden} {*}$filter} hidden]} then {
                    set fileList [concat $fileList $hidden]
                }
            }
            set fileList [lsort $fileList]
        }
        $tvDir delete [$tvDir children {}]
        foreach dir $dirList {
            lappend dirItems [$tvDir insert {} end -values [list $dir]]
        }
        if {[llength $dirItems] > 0} then {
            if {[string length $fromDir] > 0} then {
                set dirIndex [lsearch $dirList $fromDir]
                if {$dirIndex >= 0} then {
                    set item [lindex $dirItems $dirIndex]
                } else {
                    set item [lindex $dirItems 0]
                }
            } else {
                set item [lindex $dirItems 0]
            }
            update
            $tvDir selection set $item
            $tvDir focus $item
            $tvDir see $item
        }
        bind $tvFiles <<TreeviewSelect>> {}
        $tvFiles delete [$tvFiles children {}]
        foreach file $fileList {
            lappend fileItems [$tvFiles insert {} end -values [list $file]]
        }
        if {[llength $fileItems] > 0} then {
            if {[string length $filename] > 0} then {
                set fileIndex [lsearch $fileList $filename]
                if {$fileIndex >= 0} then {
                    set item [lindex $fileItems $fileIndex]
                } else {
                    set item [lindex $fileItems 0]
                }
            } else {
                set item [lindex $fileItems 0]
            }
            update
            $tvFiles selection set $item
            $tvFiles focus $item
            $tvFiles see $item
            my changeFile
        }
        update
        bind $tvFiles <<TreeviewSelect>> [list [self object] changeFile]
        set fromDir {}
        $entDir xview moveto 1
        #foreach tag [bind $tvDir] {
            #puts "$tag [bind $tvDir $tag]"
        #}
        return
    }
}

##
# FileSelection onDestroy
#    This method is an event procedure that is meant to be called
#    when the toplevel window is destroyed.
##

oo::define FileSelection {
    method onDestroy {} {
        if {$mode eq "normal"} then {
            # neither wait, nor defineCallBack was called. Just destroy object.
            after idle [list [self object] destroy]
        } elseif {$mode eq "callback"} then {
            eval $callback
            # It is up to the object's creator to destroy the object
            # e.g. by calling getResult
        } else {
            # wait mode: don't do anything. The wait method was called
            # which will destroy the object.
        }
        return
    }
}

##
# FileSelection onOK
#   Event procedure to be called when OK button is pressed.
##

oo::define FileSelection {
    method onOK {} {
        set pressedOK 1
        #if {[string length $filename] == 0} then {
            #my changeFile
        #}
        update
        destroy $window
        return
    }
}

##
# FileSelection onFiletypeChange $combo
#   Event procedure to be called when a new value is selected
#   in the combo widget.
# Arguments:
#   - combo: the Tk path of the combo widget
##

oo::define FileSelection {
    method onFiletypeChange {combo} {
        set filter [lindex $filetypes [$combo current] 1]
        my refreshListboxes
        return
    }
}

##
# FileSelection wait
#   This method waits for the destruction of the toplevel window and
#   returns the fully qualified filename that was selected. If the
#   window was destroyed without the user pressing OK, it returns
#   an empty string
##

oo::define FileSelection {
    method wait {} {
        set mode wait
        tkwait window $window
        if {$pressedOK} then {
            set path [file join $directory $filename]
        } else {
            set path {}
        }
        after idle [list [self object] destroy]
        return $path
    }
}

##
# FileSelection defineCallBack $script
#   This method sets $script as callback
#   $script must call the getResult method.
##

oo::define FileSelection {
    method defineCallBack {script} {
        set callback $script
        set mode "callback"
        return
    }
}

##
# FileSelection getResult
#   This method returns the fully qualified pathname of the selected
#   file and destroys the object. If the window is destroyed without
#   the user pressing OK, it returns an empty string.
##

oo::define FileSelection {
    method getResult {} {
        if {$pressedOK} then {
            set path [file join $directory $filename]
        } else {
            set path {}
        }
        after idle [list [self object] destroy]
        return $path
    }
}

##
# FilesSelection onUp
#   Event procedure called when the user presses the Up button. It
#   opens the parent directory of the current directory.
##

oo::define FileSelection {
    method onUp {} {
        global tcl_platform
        set fromDir [file tail $directory]
        set newdir [file dirname $directory]
        if {($newdir eq $directory) && ($tcl_platform(platform) eq {windows})} then {
            set directory {}
        } else {
            set directory $newdir
        }
        my refreshListboxes
        return
    }
}


##
# FilesSelection onHome
#   Event procedure called when the user presses the Home button. It
#   opens the user's home directory
##

oo::define FileSelection {
    method onHome {} {
        set directory [file normalize ~]
        my refreshListboxes
        return
    }
}


##
# FilesSelection onHome
#   Event procedure called when the user presses the Home button. It
#   opens the user's home directory
##

oo::define FileSelection {
    method onRoot {} {
        global tcl_platform
        if {$tcl_platform(platform) eq "windows"} then {
            set directory {}
        } else {
            set directory "/"
        }
        my refreshListboxes
        return
    }
}


##
# FileSelection changeDir
#   Event procedure called when the user clicks on a subdirectory.
#   It opens that directory and refreshes the list boxes.
##

oo::define FileSelection {
    method changeDir {} {
        set dir [lindex [$tvDir item [$tvDir selection] -values] 0]
        if {$dir eq {.}} then {
            # do nothing
        } elseif {$dir eq {..}} then {
            my onUp
        } else {
            set directory [file join $directory $dir]
            my refreshListboxes
        }
        return
    }
}

##
# FileSelection onNew
#   Event procedure called when the user presses the New button.
#   It lets the user specify the name of a new subdirectory and opens
#   that directory.
##

oo::define FileSelection {
    method onNew {} {
        set dataList {}
        set dataDict [dict create \
            name [mc fsLbNewDir] \
            type string \
            value {} \
            valuelist {}]
        lappend dataList $dataDict
        set dlg [GenForm new $window [mc fsNewDir] $dataList]
        if {[$dlg wait result]} then {
            set fullpath [file join $directory $result([mc fsLbNewDir])]
            if {![catch {file mkdir $fullpath} error]} then {
                set directory $fullpath
                my refreshListboxes
            } else {
                tkp_message $error $window
            }
        }
        return
    }
}

##
# FileSelection changeFile
#   Event procedure called when the user presses a filename on the listbox.
##

oo::define FileSelection {
    method changeFile {} {
        set filename [lindex [$tvFiles item [$tvFiles selection] -values] 0]
        # focus $entFilename
        return
    }
}

oo::define FileSelection {
    method search {tvName listName itemListName searchEntry} {
        upvar $tvName tv
        upvar $listName list
        upvar $itemListName items
        set searchString [$searchEntry get]
        if {([string length $searchString] > 0) && ([llength $list] > 2)} then {
            set curItem [$tv selection]
            set startIdx [lsearch -exact $items $curItem]
            incr startIdx
            set foundIdx [lsearch -nocase -glob -start $startIdx $list "*${searchString}*"]
            if {$foundIdx >= 0} then {
                set newItem [lindex $items $foundIdx]
            } else {
                set newItem [lindex $items 0]
            }
            $tv selection set $newItem
            $tv see $newItem
            $tv focus $newItem
        }
        return
    }
}

oo::define FileSelection {
    method onHelp {} {
        set llist {}
        foreach icon {arrow_up arrow_top home_dir arrow_down arrow_right} {
            lappend llist [list ::img::$icon [mc fsh_$icon]]
        }
        set legend [Legend new $window [mc fsLegend] $llist]
        return
    }
}


##
# FileSelection initWindow
#   Sets up the toplevel window and all its widgets.
##

oo::define FileSelection {
    method initWindow {} {
        set window [toplevel [appendToPath ${parent} [namespace tail [string tolower [self namespace]]]]]
        wm transient $window $parent
        wm title $window $title
        # fPath
        set fPath [ttk::frame $window.fpath -takefocus 0]
        set lblDir [ttk::label $fPath.lblpath -text [mc fsDirectory]]
        set entDir [entry $fPath.entpath -takefocus 0 \
            -width 50 -textvariable [my varname directory]]
        $entDir configure -state "readonly"
        set lblFilename [ttk::label $fPath.lblfilename -text [mc fsFilename] \
            -compound right -image ::img::empty_5_9]
        set entFilename [entry $fPath.entfilename -textvariable [my varname filename]]
        set btnUp [ttk::button $fPath.btnup -image ::img::arrow_up \
            -takefocus 0 \
            -command [list [self object] onUp]]
        set btnRoot [ttk::button $fPath.btnroot -image ::img::arrow_top \
            -takefocus 0 \
            -command [list [self object] onRoot]]
        set btnHome [ttk::button $fPath.btnhome -image ::img::home_dir \
            -takefocus 0 \
            -command [list [self object] onHome]]
        grid $lblDir -row 0 -column 0
        grid $entDir -row 0 -column 1 -sticky we
        grid $lblFilename -row 1 -column 0
        grid $entFilename -row 1 -column 1 -sticky we
        grid $btnUp -row 0 -column 2 -sticky wens
        grid $btnRoot -row 0 -column 3 -sticky wens
        grid $btnHome -row 0 -column 4 -sticky wens
        grid columnconfigure $fPath 1 -weight 1
        # fListboxes
        set fListboxes [ttk::frame $window.flbx]
        # dir search
        set fDirSearch [ttk::frame $fListboxes.fds]
        set lblDirSearch [ttk::label $fDirSearch.lbl -text [mc fsSearch] \
            -compound right -image ::img::empty_5_9]
        set entDirSearch [entry $fDirSearch.ent]
        bind $entDirSearch <FocusIn> \
            [list $lblDirSearch configure -compound right -image ::img::arrow_right]
        bind $entDirSearch <FocusOut> \
            [list $lblDirSearch configure -compound right -image ::img::empty_5_9]
        bind $entDirSearch <KeyPress-Return> \
            [list [self object] search \
                [my varname tvDir] \
                [my varname dirList] \
                [my varname dirItems] \
                $entDirSearch]
        pack $lblDirSearch -side left -padx {10 0}
        pack $entDirSearch -side left -expand 1 -fill x
        # dir listbox
        set tvDir [ttk::treeview $fListboxes.tvdir -columns {directories} \
            -show headings -selectmode browse -takefocus 1]
        $tvDir heading directories -text [mc fsSubdirectories] \
            -image ::img::empty_9_5
        set hsDir [ttk::scrollbar $fListboxes.hsdir -orient horizontal -command [list $tvDir xview]]
        $tvDir configure -xscrollcommand [list $hsDir set]
        set vsDir [ttk::scrollbar $fListboxes.vsdir -orient vertical -command [list $tvDir yview]]
        $tvDir configure -yscrollcommand [list $vsDir set]
        # file search
        set fFileSearch [ttk::frame $fListboxes.ffs]
        set lblFileSearch [ttk::label $fFileSearch.lbl -text [mc fsSearch] \
            -compound right -image ::img::empty_5_9]
        set entFileSearch [entry $fFileSearch.ent]
        bind $entFileSearch <FocusIn> \
            [list $lblFileSearch configure -compound right -image ::img::arrow_right]
        bind $entFileSearch <FocusOut> \
            [list $lblFileSearch configure -compound right -image ::img::empty_5_9]
        bind $entFileSearch <KeyPress-Return> \
            [list [self object] search \
                [my varname tvFiles] \
                [my varname fileList] \
                [my varname fileItems] \
                $entFileSearch]
        pack $lblFileSearch -side left -padx {10 0}
        pack $entFileSearch -side left -expand 1 -fill x
        # files listbox
        set tvFiles [ttk::treeview $fListboxes.tvfiles -columns {files} \
            -show headings -selectmode browse -takefocus 1]
        $tvFiles heading files -text [mc fsFiles] -image ::img::empty_9_5
        set hsFiles [ttk::scrollbar $fListboxes.hsfiles -orient horizontal -command [list $tvFiles xview]]
        $tvFiles configure -xscrollcommand [list $hsFiles set]
        set vsFiles [ttk::scrollbar $fListboxes.vsfiles -orient vertical -command [list $tvFiles yview]]
        $tvFiles configure -yscrollcommand [list $vsFiles set]
        grid $fDirSearch -row 0 -column 0 -sticky we
        grid $fFileSearch -row 0 -column 2 -sticky we
        grid $tvDir -row 1 -column 0 -sticky wens
        grid $vsDir -row 1 -column 1 -sticky ns
        grid $tvFiles -row 1 -column 2 -sticky wens
        grid $vsFiles -row 1 -column 3 -sticky ns
        grid $hsDir -row 2 -column 0 -sticky we
        grid $hsFiles -row 2 -column 2 -sticky we
        grid columnconfigure $fListboxes 0 -weight 1
        grid columnconfigure $fListboxes 2 -weight 1
        grid rowconfigure $fListboxes 0 -weight 1
        # fFilter
        set fFilter [ttk::frame $window.ffilter -takefocus 0]
        set btnNewdir [defineButton $fFilter.btnnewdir $window btnNewdir \
            [list [self object] onNew]]
        set lblFiletypes [ttk::label $fFilter.lblfiletypes -text [mc fsFiletype] \
            -compound right -image ::img::empty_5_9]
        set cmbFiletypes [ttk::combobox $fFilter.cmbFiletypes -values $typesForCombo]
        $cmbFiletypes current 0
        $cmbFiletypes state readonly
        pack [ttk::frame $fFilter.space1 -takefocus 0] -side left -expand 1
        pack $btnNewdir -side left
        pack [ttk::frame $fFilter.space2 -takefocus 0] -side left -expand 1
        pack $lblFiletypes -side left
        pack $cmbFiletypes -side left
        pack [ttk::frame $fFilter.space3 -takefocus 0] -side left -expand 1
        # fAccept
        set fAccept [ttk::frame $window.faccept -takefocus 0]
        set btnLegend [defineButton $fAccept.btnLegend $window btnLegend \
            [list [self object] onHelp]]
        set btnCancel [defineButton $fAccept.btncancel $window btnCancel \
            [list destroy $window]]
        set btnOK [defineButton $fAccept.btnok $window btnOK \
            [list [self object] onOK]]
        # $btnOK configure -takefocus 1
        set chkHidden [defineCheckbutton $fAccept.chkhidden $window btnShowHidden \
            [list [self object] refreshListboxes] [my varname showHidden] 1 0]
        pack $chkHidden -side left
        pack [ttk::frame $fAccept.space -takefocus 0] -side left -expand 1
        pack $btnLegend -side left
        pack $btnCancel -side left
        pack $btnOK -side left
        # pack frames
        pack $fPath -side top -fill x -padx 10 -pady 10
        pack $fListboxes -side top -expand 1 -fill both
        pack $fFilter -side top -fill x -pady 10
        pack $fAccept -side top -fill x -padx 10 -pady 10
        # bind
        bind $window <Alt-KeyPress-u> [list $btnUp invoke]
        # bind $window <KeyPress-Prior> [list $btnUp invoke]
        bind $window <Alt-KeyPress-p> [list $btnUp invoke]
        bind $window <Alt-KeyPress-Home> [list $btnHome invoke]
        bind $window <Control-KeyPress-Home> [list $btnRoot invoke]
        bind $cmbFiletypes <<ComboboxSelected>> \
            [list [self object] onFiletypeChange $cmbFiletypes]
        bind $tvDir <Double-Button-1> [list [self object] changeDir]
        bind $tvDir <KeyPress-Return> [list [self object] changeDir]
        bind $entFilename <KeyPress-Return> [list [self object] onOK]
        bind $window <KeyPress-Escape> [list destroy $window]
        # bind $window <KeyPress-Return> [list [self object] onReturn]
        bind $window <KeyPress-question> [list [self object] onHelp]
        bind $window <KeyPress-F1> [list [self object] onHelp]
        bind $entFilename <FocusIn> \
            [list $lblFilename configure -compound right -image ::img::arrow_right]
        bind $entFilename <FocusOut> \
            [list $lblFilename configure -compound right -image ::img::empty_5_9]
        bind $cmbFiletypes <FocusIn> \
            [list $lblFiletypes configure -compound right -image ::img::arrow_right]
        bind $cmbFiletypes <FocusOut> \
            [list $lblFiletypes configure -compound right -image ::img::empty_5_9]
        bind $tvDir <FocusIn> \
            [list $tvDir heading directories -image ::img::arrow_down]
        bind $tvDir <FocusOut> \
            [list $tvDir heading directories -image ::img::empty_9_5]
        bind $tvFiles <FocusIn> \
            [list $tvFiles heading files -image ::img::arrow_down]
        bind $tvFiles <FocusOut> \
            [list $tvFiles heading files -image ::img::empty_9_5]
        focus $entFilename
        $lblFilename configure -compound right -image ::img::arrow_right
        #bind $window <KeyPress-Tab> {puts [focus]}
        bindToplevelOnly $window <Destroy> [list [self object] onDestroy]
        return
    }
}

proc fileSelectionFunction {args} {
    set fs [FileSelection new {*}$args]
    set filename [$fs wait]
    return $filename
}

oo::class create Legend {
    variable window

    constructor {parent title llist} {
        set window [toplevel \
            [appendToPath $parent [namespace tail [string tolower [self namespace]]]]]
        wm title $window $title
        wm transient $window $parent
        set idx 0
        foreach legend $llist {
            lassign $legend image text
            set lbl [ttk::label ${window}.${idx} -text $text \
                -compound left -image $image]
            pack $lbl -side top -anchor w -padx 20 -pady {10 0}
            incr idx
        }
        set btnOK [defineButton $window.btnok $window btnOK \
            [list destroy $window]]
        pack $btnOK -side top -anchor center -pady 20
        bind $window <KeyPress-Return> [list destroy $window]
        bind $window <KeyPress-Escape> [list destroy $window]
        bindToplevelOnly $window <Destroy> [list [self object] destroy]
        focus $btnOK
        return
    }

    destructor {
        return
    }
}
