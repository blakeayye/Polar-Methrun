fx_version 'cerulean'

game 'gta5'

description "Qbcore Methruns By Blake"

version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua',
}

client_scripts{
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua' -- Globbing method for multiple files
}

server_scripts{
    'server/*.lua',
}


escrow_ignore {
    'config.lua',
    'locales.lua',
}

dependency 'qb-target'
dependency 'ps-ui'
dependency '/assetpacks'