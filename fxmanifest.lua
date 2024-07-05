fx_version 'cerulean'
game 'gta5'

author 'Virgil'
description 'Container Robbery Script'
version '1.0.0'

lua54 'yes' 

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/container_shell.ytyp'
