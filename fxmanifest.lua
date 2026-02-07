fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'phils-stashcreator'
description 'Stash Creator for RSG-Core & RSG-Inventory'
version '1.0.0'
author 'phil'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'

dependencies {
    'rsg-core',
    'rsg-inventory',
    'ox_lib',
    'oxmysql'
}