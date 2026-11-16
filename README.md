# Neovim en documenten

Een zelfstandige Neovim-configuratie voor schrijven, Markdown, configuratiebestanden en Python/Ruby. Eerst bedoeld voor Debian in WSL, ook bruikbaar op Debian Linux en via SSH. Geen LazyVim, LuaSnip of automatische documentsynchronisatie.

## Installeren met één commando

Voer dit uit als je gewone gebruiker in Debian/WSL, met Bash en curl beschikbaar:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VeridisEst/dotfiles/main/install.sh)
```

De installer vraagt zo nodig je sudo-wachtwoord voor systeempakketten. Hij installeert eerst Neovim **v0.12.6**, zeven plugins op exacte commits, NL/EN-spelling en een lege documentstructuur in `~/documenten`. Zodra **EDITOR KLAAR** verschijnt, werkt `~/.local/bin/nvim`. Daarna volgt de grotere installatie van Python/Ruby-codehulp. Een fout daarbij laat de editor bruikbaar en geeft een niet-nul foutcode terug.

In een nieuwe Bash-terminal staat `~/.local/bin` vooraan in PATH. Voor de huidige terminal: `export PATH="$HOME/.local/bin:$PATH"; hash -r`. Een installatiescript kan het zoekpad van zijn bovenliggende shell niet aanpassen. Bij een bestaande alias of shellfunctie voor nvim gebruik je het volledige pad of pas je die zelf aan.

Wil je eerst alleen schrijven en bestanden bewerken, zonder de zware programmeerhulpmiddelen?

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VeridisEst/dotfiles/main/install.sh) --no-tools
```

De basis heeft zeven kleine plugins. De meeste extra pakketten horen bij Python/Ruby, taalservers en het bouwen van Ruby-afhankelijkheden. APT installeert alleen noodzakelijke afhankelijkheden (`--no-install-recommends`); Linux-klembordpakketten alleen bij een gedetecteerde grafische Linux-sessie, niet in WSL. Bestaande pakketten worden door APT hergebruikt. Er wordt geen algemene systeemupgrade uitgevoerd.

Elke uitvoering schrijft een log in `~/.local/state/veridis-neovim/`. Bij een fout worden stap, foutcode en logpad getoond. Stuur de laatste regels van dat log voor diagnose. Herhaal het standaardcommando om later de codehulp toe te voegen of een afgebroken installatie te hervatten.

De installer leest of schrijft **niet** in de private documentenrepository. Er is geen automatische pull, commit of push.

## Je documenten afzonderlijk koppelen

De inhoud staat in [de private documentenrepository](https://github.com/VeridisEst/documenten). Na de editorinstallatie en GitHub-aanmelding:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VeridisEst/dotfiles/main/scripts/connect-documents.sh)
```

Voeg `--ssh` toe als GitHub SSH op dit apparaat al werkt. HTTPS vereist een bestaande GitHub-aanmeldmethode zoals Git Credential Manager of `gh auth login` (gh wordt niet geïnstalleerd). Dit script kloont eerst succesvol en bewaart daarna een bestaande lokale documentenmap als `documenten.backup.DATUM`. Eigen inhoud daarin blijft bewaard, maar wordt niet automatisch overgenomen of geüpload. Een reeds aanwezige Git-repository wordt niet gewijzigd. Ophalen/publiceren blijft bewust handmatig; zie de README van documenten.

## Wat je krijgt

- NL/EN-spelling in Markdown en tekst; suggesties met `z=`, eigen woorden toevoegen met `zg`.
- Aanvulling uit het huidige document, woordenboeken, bestandspaden en taalservers.
- Geen automatisch gekozen aanvulling; selecteer met Ctrl-n/Ctrl-p en bevestig met Ctrl-y of Enter. Tab blijft inspringen, behalve binnen een actieve ingebouwde snippet.
- Haakjes en aanhalingstekens sluiten automatisch. Zelf het sluitteken typen springt over het bestaande teken heen.
- Automatisch inspringen; Python en Ruby formatteren bij opslaan zodra de taalserver gereed is. Codeacties worden alleen op verzoek uitgevoerd.
- Bestandenkiezer, zoeken, verkenner, statusregel en sneltoetshulp; geen Nerd Font vereist.
- Overzicht, dagboek, weekplanning en aparte werk/privé-takenlijsten in een rechtervenster.

Volledige bediening: [Neovim-handleiding](nvim/README.md).

## Installatiepaden en bestaande instellingen

- `~/.local/bin/nvim`: launcher; een bestaande launcher wordt eerst geback-upt.
- `~/.config/veridis-nvim`: configuratie. Bij herinstallatie ontstaat een gedateerde reservekopie.
- `~/.local/share/veridis-neovim/releases/`: vaste Neovim-, plugin- en toolinstallaties.
- `~/.local/share/veridis-nvim`, `~/.local/state/veridis-nvim`, `~/.cache/veridis-nvim`: editorgegevens.
- `~/documenten`: alleen ontbrekende sjabloonbestanden worden toegevoegd. Bestaande documenten worden nooit overschreven.

De launcher gebruikt `NVIM_APPNAME=veridis-nvim`. Je oude `~/.config/nvim` en oude plugininstallatie blijven ongemoeid en worden niet geladen. XDG_CONFIG_HOME en XDG_DATA_HOME worden ondersteund. Start niet met sudo: dan installeer je voor root.

## Andere Linux-systemen, server en maatwerk

Ondersteund: Linux x86_64/arm64 met een glibc die bij het officiële Neovim-archief past; geen Alpine/musl, macOS of native Windows-installer. De testmatrix omvat Debian 12/13 en Ubuntu 22.04/24.04. Op andere distributies installeer je zelf Git, curl, tar, gzip, Python 3.9+ met venv/pip, Ruby 3.0+ met gem en ontwikkelheaders, een C/C++-compiler, make, pkg-config, libyaml/libffi/zlib-headers en ripgrep. Gebruik daarna `--no-system`. Gebruik `--no-tools` voor een editor zonder geïnstalleerde Python/Ruby-taalservers.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VeridisEst/dotfiles/main/install.sh) --no-system
```

Een andere documentmap: voeg `--documents-dir /pad` toe en zet `export NVIM_DOCUMENTS=/pad` in je shellinstellingen. Zonder die variabele gebruikt Neovim `~/documenten`.

Klembord: WSL gebruikt clip.exe/PowerShell, Linux detecteert wl-clipboard of xclip. Via SSH wordt OSC 52 gebruikt voor kopiëren als je terminal (en eventueel tmux) dat ondersteunt. Plakken vanaf je eigen computer doe je met de plaktoets van de terminal. Vim `p` gebruikt in SSH het lokaal bijgehouden register; er is geen blokkerende klembordaanvraag naar de terminal.

## Versies, bijwerken en terugzetten

Neovim en woordenboeken worden met SHA-256 gecontroleerd; plugincommits staan in [plugins.json](nvim/plugins.json). Rechtstreekse taaltoolversies staan in [tools](tools). Hun transitieve pip/gem-afhankelijkheden en systeempakketten worden door de package managers opgelost en zijn **niet volledig gelockt**; de werkelijk geïnstalleerde versies worden per release opgeslagen. Dit is dus een vaste editorbasis, geen bit-identieke kopie van het hele besturingssysteem.

Updates gebeuren bewust door de versiebestanden aan te passen en de tests te laten slagen. Herhaal daarna het installatiecommando. Het script start geen algemene systeemupgrade. Gebruik `--ref TAG` om een gepubliceerde tag te installeren, of clone een specifieke commit en voer `bash install.sh --source "$PWD"` uit. Bewaar lokale aanpassingen in Git voordat je opnieuw installeert.

Terugzetten: herstel je vorige launcher en de bijpassende `veridis-nvim.backup.*`-configuratie. Oude releasefolders worden niet automatisch verwijderd. Je oorspronkelijke Neovim start je via het oorspronkelijke binaire pad, zonder NVIM_APPNAME. Verwijder geen documentmappen om de editor terug te zetten.

## Tests

`tests/smoke.lua` controleert opstarten, plugins, spelling, taken, inspringing en dubbele sluittekens. `tests/lsp.lua` start beide taalservers en vraagt echte formattering aan. `tests/install.sh` test een basisinstallatie, een bewust opgewekte codehulp-fout (code 73) waarbij Neovim moet blijven werken, herstel, herinstallatie met behoud van documenten, configback-up en SSH-opstarten. De GitHub Actions-workflow draait deze tests op Debian 12/13 en Ubuntu 22.04/24.04. Dit zijn Linux-containerproeven; de WSL-Windows-klembordkoppeling en de terminalondersteuning voor OSC 52 moeten op het eigen apparaat worden gecontroleerd.

De map `debian/` bevat het oude algemene setupscript en is geen onderdeel van deze nieuwe installer.
