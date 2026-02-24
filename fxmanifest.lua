fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.3'

author 'AndiyDev'
description 'Something that just works'

shared_script {
    --'@es_extended/import.lua',
    '@ox_lib/init.lua',
    'Shared/config.lua'
}

client_scripts {
    'Bridge/bridge_cl.lua',
    'Client/main.lua'
}

server_scripts {
    'Bridge/bridge_sv.lua',
    'Server/main.lua'
}