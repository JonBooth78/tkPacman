# config.tcl

namespace eval config {
    proc initConfig {} {
        variable installDir
        variable licenseDir
        variable languageDir
        variable version {1.0.6}
        variable website {http://sourceforge.net/projects/tkpacman/}
        set installDir [file dirname [file normalize [info script]]]
        # puts "installDir = $installDir"
        # puts [file normalize [info script]]
        set licenseDir {/usr/share/licenses/common/GPL2}
        set languageDir [file join $installDir {msgs}]
        return
    }
}

