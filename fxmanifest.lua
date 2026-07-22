fx_version 'cerulean'
game 'gta5'

author 'MTJ2025script'
description 'Professional FiveM Animation & Emote System with Seating + ox_target support'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/emotes.lua',
    'client/seats.lua',
    'client/ui.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

lua54 'yes'
