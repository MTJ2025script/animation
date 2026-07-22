# MTJ Animation System

Professionelles FiveM-Animationssystem mit modernem Emote-Menü, robustem Sitzsystem und nativer **ox_target**-Integration.

---

## Features

| Feature | Details |
|---|---|
| 🎭 Emote-Menü | Modernes NUI-Menü mit Suche, Kategorien, Favoriten |
| ▶ Animationstypen | Normale Anims, Szenarien, Prop-Animationen |
| 🪑 Sitzsystem | Automatische Objekterkennung + konfigurierbare Offsets |
| 🎯 ox_target | Sitzen per Anvisieren (ox_target Integration) |
| ⌨️ Proximity-Taste | Fallback ohne ox_target via Taste `G` |
| ❤️ Favoriten | Gespeichert pro Spieler (Server-seitig) |
| 🌍 Lokalisierung | Deutsch & Englisch (`Config.Locale`) |
| 🛠 Dev-Modus | Offset-Editor via `/seatoffset` & `/seattest` |

---

## Installation

1. Resource in den FiveM-Server-Ordner kopieren: `resources/[local]/animation`
2. In `server.cfg` eintragen:
   ```
   ensure animation
   ```
3. Optional: `Config.Locale`, `Config.MenuKey`, `Config.UseOxTarget` in `config.lua` anpassen

### Abhängigkeiten

| Resource | Pflicht | Zweck |
|---|---|---|
| `ox_target` | Optional | Sitzen per Anvisieren |
| `ox_lib` | Optional | Schöne Benachrichtigungen |
| `es_extended` / `qb-core` | Optional | Framework-Notifikationen |

---

## Steuerung

| Aktion | Standard |
|---|---|
| Emote-Menü öffnen | `F3` |
| Sitzen (Proximity) | `G` |
| Aufstehen / Stoppen | `X` |
| Menü schließen | `Escape` |

---

## ox_target – Sitzen

Wenn `ox_target` installiert und `Config.UseOxTarget = true` gesetzt ist, werden automatisch alle konfigurierten Sitzmodelle als Target-Optionen registriert.

- Spieler visieren ein Sitzmöbel an → **„Sitzen"** erscheint
- Während des Sitzens erscheint **„Aufstehen"** als Target-Option
- Kein Key-Mapping nötig

---

## Neue Sitzmodelle ergänzen

### Schritt 1 – Modellname herausfinden

Mit MenyooSP, CodeWalker oder dem Dev-Modus:
```
Config.DevMode = true
```
Dann im Spiel `/seattest` neben einem Objekt ausführen.

### Schritt 2 – Eintrag in `config.lua`

```lua
Config.Seats[`dein_modellname`] = {
    type     = "scenario",          -- "scenario" oder "anim"
    scenario = "PROP_HUMAN_SEAT_CHAIR",  -- GTA-Szenario
    offset   = vec3(0.0, 0.0, 0.45),    -- x=seitlich, y=vor/zurück, z=höhe
    rotation = 180.0,               -- Drehung in Grad (meist 180°)
    label    = "Sitzen",            -- Text im ox_target-Menü
}
```

Für Sofas/Sessel ohne passendes Szenario:
```lua
Config.Seats[`prop_couch_custom`] = {
    type     = "anim",
    animDict = "timetable@ron@ig_5_p3",
    animName = "ig_5_p3_base",
    animFlag = 49,
    offset   = vec3(0.0, 0.0, 0.35),
    rotation = 180.0,
    label    = "Hinsetzen",
}
```

### Schritt 3 – Offset live testen (DevMode)

```
/seatoffset 0.0 0.0 0.45   -- Offset setzen
/seattest                   -- Auf nächstem Objekt testen
```

---

## Dateistruktur

```
animation/
├── fxmanifest.lua          – Resource-Manifest
├── config.lua              – Konfiguration (Emotes, Seats, Einstellungen)
├── client/
│   ├── main.lua            – Key-Bindings, Menü-Toggle, NUI-Callbacks
│   ├── emotes.lua          – Emote abspielen / stoppen / Props
│   ├── seats.lua           – Sitzsystem + ox_target-Registrierung
│   └── ui.lua              – Benachrichtigungen, Escape-Handler
├── server/
│   └── main.lua            – Favoriten-Persistenz
└── html/
    ├── index.html          – NUI Grundstruktur
    ├── style.css           – Modernes Dark Theme
    └── script.js           – UI-Logik (Suche, Kategorien, Favoriten)
```

---

## Konfiguration (Auszug)

```lua
Config.Locale       = 'de'     -- Sprache: 'de' oder 'en'
Config.MenuKey      = 'F3'     -- Emote-Menü öffnen
Config.SeatKey      = 'G'      -- Sitzen (Proximity)
Config.ExitKey      = 'X'      -- Aufstehen / Stoppen
Config.UseOxTarget  = true     -- ox_target aktivieren
Config.FallbackSeat = true     -- Fallback für unbekannte Objekte
Config.DevMode      = false    -- Offset-Editor aktivieren
```

---

## Lizenz

MIT – Frei verwendbar und anpassbar für eigene FiveM-Server.