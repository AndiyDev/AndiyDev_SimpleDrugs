fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.1'

author 'AndiyDev'
description 'Something that just works'

shared_script {
    --'@es_extended/import.lua',
    '@ox_lib/init.lua',
    'Shared/*'
}

client_scripts {
    'Bridge/bridge_cl.lua',
    'client/main.lua'
}

server_scripts {
    'Bridge/bridge_sv.lua',
    'server/main.lua'
}