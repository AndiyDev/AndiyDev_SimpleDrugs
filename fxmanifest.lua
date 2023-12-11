fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.0'

author 'AndiyDev'
description 'Something that just works'

shared_script {
    --'@es_extended/import.lua',
    --'@ox_lib/init.lua',
    'Shared/*'
}

client_script 'Client/*'

server_script {
    --'@oxmysql/lib/MySQL.lua',
    'Server/*'
}