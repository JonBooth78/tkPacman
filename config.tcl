# config.tcl

namespace eval config {
    proc initConfig {} {
        variable installDir
        variable licenseDir
        variable languageDir
        variable docDir
        variable version {1.2.0}
        variable website {http://sourceforge.net/projects/tkpacman/}
        set installDir [file dirname [file normalize [info script]]]
        # puts "installDir = $installDir"
        # puts [file normalize [info script]]
        set licenseDir {/usr/share/licenses/common/GPL2}
        set languageDir [file join $installDir {msgs}]
        set docDir [file join $installDir doc]
        if {![file exists $docDir]} then {
            set docDir {/usr/share/doc/tkpacman}
        }
        return
    }
}

