fx_version "adamant"

games { 'rdr3', 'gta5' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script {
	'client/*.lua',
}

server_script {
	'server/*.lua',
	'@oxmysql/lib/MySQL.lua'
}

shared_scripts {
    'config.lua',
}

files {
	'ui/hud.html',
	'ui/style.css',
	'ui/script.js',
  }
  ui_page 'ui/hud.html'

dependencies {
	'oxmysql',
	'vorp_core',
    'vorp_inventory',
}


author 'Shamey Winehouse'
description 'License: GPL-3.0-only'