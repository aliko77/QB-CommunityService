fx_version 'cerulean'
game 'gta5'

author 'alispw77'
description 'QB Community Service'
version '1.0.0'

server_script 'server.lua'

client_script 'client.lua'

shared_scripts {
	'config.lua',
    '@qb-core/import.lua'
}

ui_page 'web/ui.html'

files {
    'web/*.*'
}