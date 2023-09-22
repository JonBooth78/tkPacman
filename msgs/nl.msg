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
{Cache opruimen}

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

mnuHelpFile
{&Toon hulp}

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

btnError
{Fouten}

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
depot         : %6$s}


spaceDouble
{spatie, dubbele klik}

initPackList
{

    Pakkettenlijst laden}


generalYes
{ja}

generalNo
{nee}

rbGroup
{&Groep}

rbRepo
{Depot}

rbSearch
{&Woord}

rbOrphans
{Wezen}

rbExplicit
{Expliciet}

rbFilterOff
{&Uit}

rbPending
{Aangestipt}

rbUpgrades
{Opwaarderingen}

rbForeign
{Externe pakketten}

rbFileOwner
{Eigenaar bestand}

adviceTerm
{Er was een probleem met het uitvoeren van een pacman commando als root.

Dit zou kunnen betekenen dat u de opties 'terminal' of 'runasroot'
(zie menu Extra -> Opties) moet aanpassen of dat u nog een pakket moet
installeren om een commando te kunnen uitvoeren dat opgeroepen wordt
door de 'terminal' of 'runasroot' opties.

De bovenstaande informatie kan u helpen dit probleem op te lossen.
}

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
{Alle pakketten beschikbaar in depots}

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
{Alle beschikbare pakketten in depot '%1$s'}

filterRepoInstalled
{Alle geïnstalleerde pakketten van depot '%1$s'}

filterOrphans
{Alle pakketten geïnstalleerd omwille van afhankelijkheid maar niet meer vereist}

filterExplicit
{Alle pakketten die expliciet geïnstalleerd zijn en niet vereist door een ander pakket}

filters
{Filters}

filterPendingInstallation
{Alle pakketten die aangstipt zijn voor installatie}

filterPendingRemoval
{All pakketten die aangestipt zijn voor verwijdering}

filterUpgrades
{Beschikbare opwaarderingen}

filterForeign
{Geïnstalleerde pakketten die niet beschikbaar zijn in de depots}

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

De filter 'Opwaarderingen' is vooral bedoeld om selectief bepaalde pakketten op te waarderen.}

browserAsRoot
{tkPacman weigert de web browser uit te voeren als root}

errorLog
{tkPacman - Foutberichten}

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
    xfce4-terminal --disable-server --title=%t --command=%c
    konsole --nofork --caption %t -e %c
    roxterm --title=%t --execute %c
    vte --name=%t --command=%c
    xterm -title %t -e %c

Bij het uitvoeren van deze commando's vervangt tkPacman %t door een
geschikte titel voor het terminal venster en %c door het commando dat
moet worden uitgevoerd in de terminal.

Van deze commando's is geweten dat ze werken. Als u liever een ander
terminal programma gebruikt, kunt u zelf een commando typen in plaats
van er een te kiezen uit de lijst.

De standaard keuze is de eerste van de bovenstaande keuzelijst die
werkelijk geïnstalleerd is.

Ik heb ook geprobeerd gnome-terminal te laten werken, maar die
begint altijd op de achtergrond te lopen waardoor deze niet bruikbaar
is in de context van tkPacman.}

optHelp_runasroot {
Het commando dat tkPacman moet gebruiken om pacman commando's uit te
voeren als 'root'.

Deze string kan speciale symbolen bevatten die door tkPacman zullen
geïnterpreteerd worden.

%p zal vervangen worden door het uit te voeren pacman commando.

%close zal vervangen worden door een bericht dat de gebruiker uitnodigt
om de ENTER toets te drukken om het terminal venster te sluiten.

%terminal(cmdlist) zal de commando's van het argument 'cmdlist' uitvoeren
in het terminal emulatie programma dat gedefinieerd wordt door
optie 'terminal'. De commando's in 'cmdlist' moeten gescheiden worden
door ';'.

Door de drop down box te gebruiken, kunt u kiezen uit de volgende
'runasroot' commando's:

 1. %terminal(echo "%p" ; su --command="%p" ; read -p "%close")
 2. sudo --askpass %terminal(echo "%p" ; %p ; read -p "%close")
 3. gksu --description pacman %terminal(echo "%p" ; %p ; read -p "%close")
 4. kdesu %terminal(echo "%p" ; %p ; read -p "%close")

Keuze 1 is de standaard keuze. Ze vereist dat u het 'root' wachtwoord
invoert bij elk pacman commando.

Keuze 2 is de aanbevolen keuze. Ze vereist het pakket 'sudo' en
en een geconfigureerd '/etc/sudoers' bestand. Ze heeft het voordeel dat
uw wachtwoord een zekere tijd onthouden wordt door sudo (standaard 5
minuten). Gedurende deze tijd kunt u een ander pacman commando uitvoeren
zonder uw wachtwoord te moeten invoeren. Normaal vereist sudo dat u uw
eigen wachtwoord invoert in plaats van het 'root' wachtwoord.

Keuze 3 vereist het pakket 'gksu'. gksu kan het 'root' wachtwoord
onthouden gedurende de sessie of zelfs opslaan in de gnome keyring.
Deze keuze minimaliseert het aantal keren dat u het 'root' wachtwoord
moet invoeren, maar ze is minder veilig, omdat alle commando's
als 'root' kunnen uitgevoerd worden gedurende de hele tijd dat u
aangemeld bent bij uw normale account.

Keuze 4 vereist het pakket 'kdebase-runtime'. kdesu is gelijkaardig
aan gksu, maar behoort tot de KDE desktop.

Van deze runasroot commando's is geweten dat ze werken. Als u liever
een ander runasroot commando gebruikt, kunt u het typen in plaats
van een te kiezen uit de lijst.

Standaard: Het eerste commando van de lijst.}

optHelp_allerrors
{Deze optie bepaalt of tkPacman alle fouten toont of alleen de meest
relevante.

Standaard: Niet alle fouten}

optPasteFilename
{Bestandsnaam &plakken}


optSelectbrowser
{Kies browser}

optSelecttmpdir
{Kies tijdelijke map}

optHelp_tmpdir
{Wanneer tkPacman een pacman commando uitvoert als root maakt het
twee tijdelijke scripts aan, 'tkpacman-xterm.sh' en 'tkpacman-cmd.sh', in
de map bepaald door deze optie.}

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
{Nieuwe Map}

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

