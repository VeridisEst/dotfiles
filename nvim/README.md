# Bediening

De leader-toets is **Spatie**. Druk hem in normale modus in en wacht kort voor de beschikbare combinaties.

| Toetsen | Actie |
| --- | --- |
| Spatie ? | Deze handleiding |
| Spatie w | Opslaan |
| Spatie e | Bestandsverkenner |
| Spatie f f | Bestand zoeken vanaf huidige map |
| Spatie f g | Tekst zoeken vanaf huidige map |
| Spatie f b | Wisselen tussen open bestanden |
| Spatie n o | Documentenoverzicht |
| Spatie n f | Bestand zoeken in documenten |
| Spatie n g | Tekst zoeken in documenten |
| Spatie n j | Dagboek vandaag |
| Spatie n w | Huidige weekplanning |
| Spatie t w | Werktaken rechts openen/sluiten |
| Spatie t p | Privétaken rechts openen/sluiten |
| Spatie t t | Taak onder cursor afvinken/terugzetten |
| Ctrl-w h/l | Naar linker/rechter venster |
| gf | Bestandspad/link onder cursor openen |
| Ctrl-o | Terug naar vorige locatie |
| z= | Spellingssuggesties |
| zg | Woord aan eigen woordenboek toevoegen |
| ]s / [s | Volgende/vorige spellingsmarkering |
| Spatie u s | Spelling aan/uit |
| Spatie u a | Automatische haakjes aan/uit |
| Spatie u f | Formatteren bij opslaan aan/uit |
| Spatie c f | Code formatteren met actieve taalserver |
| Spatie c a | Codeactie kiezen |
| Spatie c r | Symbool hernoemen |
| Spatie c d | Foutmelding bij cursor |
| gd / K | Definitie / uitleg van code |

In invoermodus: Ctrl-Space vraagt aanvullingen; Ctrl-n/p selecteert, Ctrl-y bevestigt, Ctrl-e sluit de lijst. Enter bevestigt alleen als je bewust een optie geselecteerd hebt; anders maak je gewoon een nieuwe regel. Tab blijft normaal inspringen. Snippets uit taalservers gebruiken Neovims ingebouwde snippetondersteuning.

## Schrijven

Markdown en tekst hebben NL/EN-spelling en visuele regelafbreking. Lange alinea’s krijgen geen automatische harde regeleinden. j/k volgen zichtbare regels; een aantal ervoor, zoals 3j, blijft echte regels volgen. Beide talen tegelijk betekent dat een geldig Engels woord niet als Nederlandse fout wordt gemarkeerd.

Er zijn precies twee takenlijsten: werk/taken.md en prive/taken.md. Schrijf een taak als `- [ ] Tekst`. Projecten, weekplanning en dagboek verwijzen naar die lijsten. Nieuwe dagboek- of weekdocumenten zijn nog niet opgeslagen: gebruik Spatie w.

De verkenner (mini.files) verschijnt als kolommen, niet als permanente boom. Met h/l ga je omhoog/naar binnen, q sluit de verkenner. Bestandswijzigingen in de verkenner worden met = gesynchroniseerd na bevestiging. Dat betreft lokale bestanden, geen GitHub-synchronisatie.

## Code

Python gebruikt pylsp, Black en Pyflakes; Ruby gebruikt Solargraph en RuboCop. Bij opslaan wordt alleen de opmaak aangepast. Foutmeldingen verschijnen als tekens in de marge; Spatie c d toont uitleg. Logische fouten worden niet stilzwijgend gecorrigeerd. Projectinstellingen kunnen de formattering beïnvloeden. Taalservers zien de geïnstalleerde omgeving; voor projectspecifieke Python-pakketten of Ruby-bundles kan aanvullende configuratie nodig zijn.

## Documenten en synchronisatie

`~/documenten` is standaard; NVIM_DOCUMENTS kan het pad veranderen. De installatie voegt ontbrekende sjablonen toe maar haalt geen persoonlijke bestanden op. Gebruik het aparte connect-documents.sh-script om de private repository te klonen. Git pull/commit/push doe je bewust zelf; er is geen verborgen automatische synchronisatie.

## Problemen

- `:checkhealth` controleert voorzieningen. `:messages` toont fouten.
- Controleer bij ontbrekende taalhulp of je de launcher `~/.local/bin/nvim` gebruikt en niet met `--no-tools` hebt geïnstalleerd.
- De spellingbestanden worden tijdens installatie gedownload en gecontroleerd. Bij een checksumfout stopt de installer; controleer de bron voordat je de checksum bijwerkt.
- Gebruik via SSH de plaktoets van je terminal. OSC 52-kopiëren vereist terminalondersteuning.
- Eigen wijzigingen aan deze configuratie eerst in Git bewaren; herinstallatie bewaart daarnaast een reservekopie.
