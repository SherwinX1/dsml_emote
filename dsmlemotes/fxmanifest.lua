fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

name "dsmlemotes"
author "DSML"
description "DSML Emote System - Kibook animation core + custom Western NUI + VORP compatibility"
version "1.0.0"

server_scripts {
	"config/config.lua",
	"config/emotes.lua",
	"config/scenarios.lua",
	"config/shared.lua",
	"config/walkstyles.lua",
	"server/vorp.lua",
	"server/persistence.lua",
	"server/shared_emotes.lua",
	"server/walkstyle.lua",
	"server/main.lua"
}

client_scripts {
	"config/config.lua",
	"config/emotes.lua",
	"config/scenarios.lua",
	"config/shared.lua",
	"config/walkstyles.lua",
	"client/vorp.lua",
	"client/animation.lua",
	"client/safety.lua",
	"client/favorites.lua",
	"client/shared_emotes.lua",
	"client/walkstyle.lua",
	"client/menu.lua",
	"client/commands.lua",
	"client/main.lua"
}

ui_page "html/index.html"

-- React + Vite build output (source in ui-src/, build with: npm install && npm run build)
files {
	"html/index.html",
	"html/bundle/*"
}
