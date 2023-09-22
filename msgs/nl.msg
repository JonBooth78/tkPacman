## msgs/nl.msg
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

# package require Tcl 8.5
# package require msgcat 1.4.2

## specify the locale in the next statement:
#   {} for any, en for English, en_us for US English, en_gb for UK English
#   nl for Dutch, or de_ch for Swiss German, etc.

set locale {nl}

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
{Toon pacman.&log}

mnuClean
{Cache schoonmaken}

mnuImport
{Lokaal pakket installeren}

mnuQuit
{&Verlaten}

mnuTools
{&Extra}

mnuOptions
{&Opties}

mnuIncrFont
{&Grotere karakters}

mnuDecrFont
{&Kleinere karakters}

mnuHelp
{&Help}

mnuLicense
{&Licentie}

mnuAbout
{&Over}

}

# Button defintions
::msgcat::mcmset $locale {

btnOK
{&OK}

btnCancel
{&Annuleren}

btnYes
{&Ja}

btnNo
{&Nee}

btnHelp
{&Help}

btnWrap
{&Regelterugloop}

btnSearch
{&Zoeken}

lbReadOnly
{ALLEEN LEZEN}

btnLegend
{&Legende}

btnWebsite
{&Website}

btnRefresh
{&Database
Synchroniseren}

btnSysUpgrade
{Systeem
&Opwaarderen}

rbAvailable
{Be&schikbare pakketten}

rbInstalled
{Ge-&installeerde pakketten}

btnClose
{&Sluiten}

mnuMark
{&Aanstippen}

mnToggle
{Aanstippen/Niet aanstippen}

mnMarkAll
{Alles aanstippen}

mnUnMarkAll
{Niets aanstippen}

btnApply
{Veranderingen
&Toepassen}

btnInstallFile
{&Lokaal
Pakket}

btnInfo
{I&nfo}

btnFiles
{&Bestanden}

btnApplyShort
{&Toepassen}

btnForget
{&Vergeten}

}

# Main window
::msgcat::mcmset $locale {
tkPacman
{tkPacman}


hdMark
{Stip}

hdName
{Naam}

hdDescription
{Beschrijving}

smallInfo
{naam          : %1$s
beschrijving  : %2$s
versie        : %3$s
geïnstalleerd : %4$s
groepen       : %5$s
opslag        : %6$s}


spaceDouble
{spatie, dubbele klik}

generalYes
{ja}

generalNo
{nee}

rbGroup
{&Groep}

rbRepo
{Opslag}

rbSearch
{&Woord}

rbOrphans
{Wezen}

rbExplicit
{Expliciet}

rbFilterOff
{&Uit}

rbUpgrades
{Opwaarderingen}

rbForeign
{Externe pakketten}

rbFileOwner
{Eigenaar bestand}

adviceTerm
{Misschien moet u nog een terminal emulator programma zoals 'xterm' of'lxterminal' installeren.

Of misschien moet u de optie 'terminal' nog aanpassen. Zie Extra -> Opties -> terminal.}

nrOfPackages
{Aantal pakketten}

packagesListed
{Gelijst: }

markedInstall
{Aangestipt voor installatie: }

markedRemoval
{Aangestipt voor verwijdering: }

packagesAvail
{Beschikbaar: }

packagesInstalled
{Geïnstalleerd: }

allAvailable
{Alle pakketten beschikbaar in opslag}

filterWordAvailable
{Alle beschikbare pakketten met het woord '%1$s' in 'naam' of 'beschrijving'}

filterGroupAvailable
{Alle beschikbare pakketten in groep '%1$s'}

allInstalled
{Alle geïnstalleerde pakketten}

filterWordInstalled
{Alle geïnstalleerde pakketten met het woord '%1$s' in 'naam' of 'beschrijving'}

filterGroupInstalled
{Alle geïnstalleerde pakketten in groep '%1$s'}

filterRepoAvailable
{Alle beschikbare pakketten in opslag '%1$s'}

filterRepoInstalled
{Alle geïnstalleerde pakketten van opslag '%1$s'}

filterOrphans
{Alle pakketten geïnstalleerd omwille van afhankelijkheid maar niet meer vereist}

filterExplicit
{Alle pakketten die expliciet geïnstalleerd zijn en niet vereist door een ander pakket}

filters
{Filters}

filterUpgrades
{Beschikbare opwaarderingen}

filterForeign
{Geïnstalleerde pakketten die niet beschikbaar zijn in de opslag}

filterFileowner
{Geïnstalleerd pakket dat eignaar is van '%1$s'}

manyItems
{U staat op het punt %1$s pakketten aan te stippen voor %2$s.

Bent u zeker dat u dat wilt doen?}

forInstallation
{installatie}

forRemoval
{verwijdering}


browser_failed
{Het commando %1$s is mislukt:
%2$s
Controleer de optie 'browser'.
Zie Extra -> Opties.}

about_tkp
{tkPacman versie %1$s

Copyright © Willem Herremans 2013

Dit programma is vrije software; u kunt het herverdelen en/of wijzigen onder de voorwaarden van de GNU General Public License zoals die gepubliceerd wordt door de Free Software Foundation; ofwel versie 2 van de licentie, ofwel (uw keuze) een latere versie.

Dit programma is verdeeld in de hoop dat het nuttig is, maar ZONDER ENIGE WAARBORG; zonder zelfs de impliciete waarborg van VERHANDELBAARHEID of GESCHIKTHEID VOOR EEN BEPAALD DOEL.

Zie 'Help -> Licentie' voor meer details.

De tkPacman website is te vinden op %5$s. Daar kunt u fouten rapporteren, nieuwe functies aanvragen en hulp krijgen.

tkPacman gebruikt %3$s als Tcl run time environment. The Tcl versie is %4$s.

tkPacman is geïnstalleerd in %2$s}

unappliedChanges {
Er zijn nog pakketten aangestipt voor %2$s:

%1$s

Wat wilt u doen met deze operatie?}

closeTerminal
{Druk op ENTER om de terminal te sluiten. }

runAsRoot
{tkPacman - Uitvoeren als root}

warningUpgrade
{De aanbevolen methode om het systeem op te waarderen is op de knop 'Systeem Opwaarderen' te drukken.

Alle hier gelijste pakketten aanstippen en dan op de knop 'Veranderingen Toepassen' drukken, is niet hetzelfde als op de knop 'Systeem Opwaarderen' drukken.}

}

# import window
::msgcat::mcmset $locale {
tkPacmanImport
{tkPacman - Installeer pakket van lokaal bestand}

lbImportFile
{Pakket bestand}

btnInstall
{&Installeer}

btnQuit
{&Verlaten}

}

# options.tcl
::msgcat::mcmset $locale {
optionsTitle
{tkPacman - Opties}

optHelpTitle
{tkPacman - Help voor optie %s}

opt_arrow_down
{Open selectiedialoog (pijl omlaag)}

opt_expand
{Toon optie in uitgebreid venster (Alt-x)}

opt_reset
{Standaard waarde van optie herstellen (Alt-r)}

opt_help
{Toon hulp voor deze optie (Alt-h)}

optHelp_browser
{Locatie van uw favoriete internet browser.

Standaard: xdg-open
}

optHelp_terminal {
Het commando waarmee het terminal programma zal worden opgeroepen
om pacman commando's uit te voeren.

De selectie dialoog laat u keizen uit de volgende commando's voor
het oproepen van een terminal programma:

    lxterminal --title=%t --command=%c
    xterm -title %t -e %c
    vte --name=%t --command=%c
    roxterminal --title=%t --execute %c

Bij het uitvoeren van deze commando's vervangt tkPacman %t door een
geschikte titel voor het terminal venster en %c door het commando dat
moet worden uitgevoerd in de terminal.

Van deze commando's is geweten dat ze werken. Als u liever een ander
terminal programma gebruikt, kunt u zelf een commando typen in plaats
van er een te kiezen uit de lijst.

lxterminal is de standaard keuze omdat deze zowel mooi is als weinig
afhankelijkheden heeft.

Ik heb andere, meer geavanceerde terminals zoals gnome-terminal, konsole
en xfce4-terminal geprobeerd, maar ik kon deze niet goed laten werken
in de context van tkPacman.}

optHelp_sudo {
Moet tkPacman 'sudo' gebruiken voor het uitvoeren van commando's als
'root'?

Zoniet, zal tkPacman 'su' gebruiken.

Standaard: Nee.}


optPasteFilename
{Bestandsnaam &plakken}

}

# generic.tcl
::msgcat::mcmset $locale {

searchEOT
{Einde van de tekst is bereikt.
De zoekfunctie zal nu terugkeren naar het begin van de tekst.}

lsbSearchFound
{'%s' gevonden}

lsbSearchNotFound
{Begin van de lijst}

mnuText
{&Tekst}

mnuTxtClose
{&Sluiten}

mnuExtra
{&Extra}

miscChoose
{tkPacman - Kies}

miscValues
{Waarden}

fsDirectory
{Map}

fsFilename
{Bestandsnaam}

btnUp
{&Omhoog}

fsSubdirectories
{Onderliggende mappen}

fsFiles
{Bestanden}

btnNewdir
{&Nieuwe onderliggende map}

fsFiletype
{Bestandstype}

fsLbNewDir
{NieuweMap}

btnShowHidden
{&Toon verborgen}

fsNewDir
{Maak nieuwe map}

fsLegend
{Legende}

fsh_arrow_up
{Ga naar ouder map (Alt-p)}

fsh_arrow_top
{Ga naar root map (Control-Home)}

fsh_home_dir
{Ga naar home map (Alt-Home)}

fsh_arrow_down
{Deze lijst heeft toetsenbord focus}

fsh_arrow_right
{Dit invoervak heeft toetsenbord focus}

fsSearch
{Zoek}

}

# misc.tcl
::msgcat::mcmset $locale {
tkp_message
{tkPacman - mededeling}

}

