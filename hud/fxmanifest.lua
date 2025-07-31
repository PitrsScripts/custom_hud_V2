fx_version 'cerulean'
game 'gta5'

author 'Pitrs'
description 'Custom ESX HUD'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

despencies {
    'ox_lib',
    'oxmysql',
    'es_extended',
    'esx_status',
    'esx_basicneeds',
}
