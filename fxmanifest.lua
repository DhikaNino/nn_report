fx_version "cerulean"

author "Dhika Nino"
description "Dhika Nino Report System"

version '1.0.0'

lua54 'yes'

games {
  "gta5",
}

ui_page 'web/build/index.html'

client_scripts {
	"client/**/*"
}


server_scripts {
	"server/**/*"
}

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*'
}

files {
	'web/build/index.html',
	'web/build/**/*',
}