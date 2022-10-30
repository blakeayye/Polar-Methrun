# Polar-Methrun
First Script

Head over to your qb-core/server/players.lua and paste the following PlayerData in

PlayerData.metadata['methrun'] = PlayerData.metadata['methrun'] or 0


Add the following code to your Renewed-Weaponscarry/client/main.lua under local props

 ["pack1"]                     = { carry = true,   model = "prop_cs_box_clothes",   bone = 28422, x = 0.01,  y = -0.02, z = -0.14, xr = 0.0, yr = 0.0,   zr = 0.0,    blockAttack = true, blockCar = true, blockRun = false},
  ["pack2"]                     = { carry = true,   model = "prop_cs_cardbox_01",    bone = 28422, x = 0.01,  y = -0.02, z = -0.12, xr = 0.0, yr = 0.0,   zr = 0.0,    blockAttack = true, blockCar = true, blockRun = false},
  ["pack3"]                     = { carry = true,   model = "prop_hat_box_06",       bone = 28422, x = 0.01,  y = -0.02, z = -0.17, xr = 0.0, yr = 0.0,   zr = -90.0,  blockAttack = true, blockCar = true, blockRun = false},
