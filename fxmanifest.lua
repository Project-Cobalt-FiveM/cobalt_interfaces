fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'cobalt_interfaces'
author 'Project Cobalt'
description 'Notifications, progress bar, text UI, skill check, context menu, radial menu and dialogs'
version '1.0.0'

dependencies {
    'ox_lib',
}

shared_script '@ox_lib/init.lua'
client_script 'client/init.lua'
server_script 'server/init.lua'

ox_lib 'locale'

ui_page '_nui/build/index.html'

files {
    'config.lua',
    'client/*.lua',
    'imports/*.lua',
    'locales/*.json',
    '_nui/build/index.html',
    '_nui/build/assets/*',
}
