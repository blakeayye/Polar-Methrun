local QBCore = exports[Config.CoreName]:GetCoreObject()

local CurrentRuns = {}

local usedPlates = {}


local function Notifications(src, type, msg, group)
    if Config.RenewedPhone then
    if group then
        exports['qb-phone']:pNotifyGroup(group,
            "Package Delivery",
            msg,
            "fas fa-recycle",
            "#2193eb",
            7500
        )
    else
        TriggerClientEvent('QBCore:Notify', src, msg, type)
    end
    else
        TriggerClientEvent('QBCore:Notify', src, msg, type)
    end
end






































-- RANDOM PLATE
local function RandomPlate()
    local string = Config.licenseplate ..QBCore.Shared.RandomInt(4)
    if usedPlates[string] then
        return RandomPlate()
    else
        usedPlates[string] = true
        return string
    end
    if Config.Debug then
        print("gave random plate")
    end
end

-- VEHICLE SPAWNING
local function SpawnVehicle(carType, location, group, coords)
    if Config.Debug then
        print("server vehicle tryna spawn")
    end
    local CreateAutomobile = joaat('CREATE_AUTOMOBILE')
    local car = Citizen.InvokeNative(CreateAutomobile, joaat(carType), coords, true, false)

    while not DoesEntityExist(car) do
        Wait(25)
    end
    
    local NetID = NetworkGetNetworkIdFromEntity(car)
    local plate = RandomPlate()
    SetVehicleNumberPlateText(car, plate)

    local m = exports['qb-phone']:getGroupMembers(group)
    for i=1, #m do
        TriggerClientEvent("Polar-MethRun:client:NewPlace", m[i], location, NetID, plate)
    end
    if Config.Debug then
        print("server vehicle spawned")
    end
    return NetID, plate
    
end



-- START JOB ON PHONE
RegisterNetEvent('Polar-MethRun:server:StartJob', function(run, coords)
    if Config.Debug then
        print("server job tryna start")
    end
   --[[ QBCore.Functions.Progressbar('blake', Config.Progressbar, Config.BuyInfoWait, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = Config.ProgressbarAnimDict,
        anim = Config.ProgressbarAnim,
        flags = Config.ProgressbarAnimFlags,
    }, ]]
    local src = source
    if not run or not coords then return end

    local ped = GetPlayerPed(src)
    if #(GetEntityCoords(ped) - vector3(Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z)) > 5 then return end

    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end
    local group = exports['qb-phone']:GetGroupByMembers(src) or exports['qb-phone']:CreateGroup(src, Config.GroupName..Player.PlayerData.citizenid)

    if not group then return end

    local Size = exports['qb-phone']:getGroupSize(group)

    if Size > Config.GroupLimit then TriggerClientEvent('QBCore:Notify', src, Config.GroupMax, Config.ErrorColor) return end

    if exports['qb-phone']:getJobStatus(group) ~= "WAITING" then TriggerClientEvent('QBCore:Notify', src, Config.GroupBusy, Config.ErrorColor) return end
    if not exports['qb-phone']:isGroupLeader(src, group) then TriggerClientEvent('QBCore:Notify', src, Config.GroupLeaderError, Config.ErrorColor) return end

    if CurrentRuns[group] then TriggerClientEvent('QBCore:Notify', src, Config.GroupAlreadyRun, Config.ErrorColor) return end

    local deliverData = Player.PlayerData.metadata["methrun"] or 0
    if Config.Route[run] > deliverData then TriggerClientEvent('QBCore:Notify', src, "You don't have enough deliveries to do this route!", Config.ErrorColor) return end

    local v = Config.StopsAmt
    local maxRuns = run == "small" and math.random(v["small"].min, v["small"].max) or run == "medium" and math.random(v["medium"].min, v["medium"].max) or math.random(v["large"].min, v["large"].max)

    local stop = math.random(1, #Config.Stops)
    local location = Config.Stops[stop]
    local vehicle, plate = SpawnVehicle(Config.MethVehicle, location, group, coords)
    if not vehicle or not plate then TriggerClientEvent('QBCore:Notify', src, Config.PlateVehicleNotWork, Config.ErrorColor) return end

   local packages = math.random(Config.Deliver.min, Config.Deliver.max) * Size
    local finalNumber = packages < Config.MaxDeliver and packages or Config.MaxDeliver
    CurrentRuns[group] = {
        status = run,
        runsLeft = maxRuns,
        totalRuns = maxRuns,
        runsDone = 0,
        currentLocation = location,
        Delivered = 0,
        packages = finalNumber,
        car = vehicle,
        plate = plate,
        history = {
            [stop] = true,
        },
        Stages = {
            {name = (Config.PhoneStage1):format(0, maxRuns), isDone = false, id = 1},
            {name = Config.PhoneStage2, isDone = false, id = 2}

        }
    }
    
    -- phone job status
    exports['qb-phone']:setJobStatus(group, (Config.PhoneJobStatus):format(run), CurrentRuns[group].Stages)

    -- cooldown trigger
    TriggerServerEvent('Polar-MethRun:server:cooldown')

    -- spawning of guars and civilian peds
   
    TriggerClientEvent('spawnpeds')
    if Config.Debug then
        print("job started")
    end
end)





-- COOLDOWN
RegisterNetEvent('Polar-MethRun:server:cooldown', function()
    Cooldown = true
    if Config.Debug then
        print("cooldown started")
    end
    local timer = Config.Cooldown * 1000
    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            Cooldown = false
        end
        if Config.Debug then
            print("cooldown finished")
        end
    end

    BCore.Functions.CreateCallback("Polar-MethRun:server:cooldown2",function(source, cb)
    
        if Cooldown then
            cb(true)
        else
            cb(false) 
        end
    end)
end)

-- DELIVERING PACKAGES
QBCore.Functions.CreateCallback("Polar-MethRun:server:DropOffPackage", function(source, cb)
    if Config.Debug then
        print("package tryna dropoff")
    end
    local src = source

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local group = exports['qb-phone']:GetGroupByMembers(src)

    if not group then return cb(false) end

    local vehCoords = GetEntityCoords(NetworkGetEntityFromNetworkId(CurrentRuns[group].car))

    if #(coords - vehCoords) > 10 then return cb(false) end
    CurrentRuns[group].Delivered = CurrentRuns[group].Delivered + 1
    if CurrentRuns[group].packages == 0 then
        CurrentRuns[group].runsLeft = CurrentRuns[group].runsLeft - 1
        CurrentRuns[group].runsDone = CurrentRuns[group].runsDone + 1
        if CurrentRuns[group].runsLeft == 0 then
            local m = exports['qb-phone']:getGroupMembers(group)
            for i=1, #m do
                TriggerClientEvent('Polar-MethRun:client:JobDone', m[i])
            end

            CurrentRuns[group].Stages = {
                {name = (Config.GroupStage1):format(CurrentRuns[group].runsDone, CurrentRuns[group].totalRuns), isDone = true, id = 1},
                {name = Config.GroupStage2, isDone = false, id = 2}
            }

            Notifications(_, _, Config.GroupFinished, group)
            CreateFinishPed()
            CreateBlip(Config.PackagePedLocations[pedLocation].x, Config.PackagePedLocations[pedLocation].y, Config.PackagePedLocations[pedLocation].z, Config.PickupPackagesBlipSprite, Config.PickupPackagesBlipLabel)

        else
            local stop = math.random(1, #Config.Stops)
            while CurrentRuns[group].history[stop] do
                stop = math.random(1, #Config.Stops)
                Wait(10)
            end
            local location = Config.Stops[stop]
            CurrentRuns[group].history[stop] = true

            CurrentRuns[group].currentLocation = location

            local packages = math.random(Config.Deliver.min, Config.Deliver.max) * exports['qb-phone']:getGroupSize(group)
            local finalNumber = packages < Config.MaxDeliver and packages or Config.MaxDeliver
            CurrentRuns[group].packages = finalNumber

            CurrentRuns[group].Stages = {
                {name = (Config.GroupStage1):format(CurrentRuns[group].runsDone, CurrentRuns[group].totalRuns), isDone = false, id = 1},
                {name = Config.GroupStage2, isDone = false, id = 2}
            }

            local m = exports['qb-phone']:getGroupMembers(group)
            for i=1, #m do
                TriggerClientEvent('Polar-MethRun:client:NewPlace', m[i], location)
            end
            Notifications(_, _, Config.NewPlace, group)
        end
    end

    exports['qb-phone']:setJobStatus(group, (Config.GroupStatus):format(CurrentRuns[group].status), CurrentRuns[group].Stages)

    cb(true)
    if Config.Debug then
        print("package drop offed")
    end
end)


AddEventHandler('qb-phone:server:GroupDeleted', function(group, players)
    if not CurrentRuns[group] then return end
    if CurrentRuns[group].plate then usedPlates[CurrentRuns[group].plate] = nil end
    CurrentRuns[group] = nil
    for i=1, #players do
        TriggerClientEvent("Polar-MethRun:client:ResetClient", players[i])
    end
    if Config.Debug then
        print("group deleted")
    end
end)



-- GROUP JOB PAY
RegisterNetEvent('Polar-MethRun:server:FinishJob', function()
    if Config.Debug then
        print("job tryna finish")
    end
    local src = source

    local group = exports['qb-phone']:GetGroupByMembers(src)

    if not group then return end

    local ped = GetPlayerPed(src)

    if Config.LeaderReturn and not exports['qb-phone']:isGroupLeader(src, group) then TriggerClientEvent('QBCore:Notify', src, Config.GroupLeaderError, Config.ErrorColor) return end

    if #(GetEntityCoords(ped) - vector3(Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z)) > 5 then return end

    local m = exports['qb-phone']:getGroupMembers(group)
    local groupSize = exports['qb-phone']:getGroupSize(group)
    local buff = groupSize >= Config.GroupPayLimit and Config.GroupPay or 1.0
    local pay = ((CurrentRuns[group].Delivered * Config.PriceBrackets[CurrentRuns[group].status]) * buff) / groupSize
    local MetaData = CurrentRuns[group].Delivered / groupSize

    local MaterialCheck = MetaData >= Config.MaterialCheck and math.floor(MetaData / Config.MaterialCheck) or 0

    if not m then return end
    if pay > 0 then
        for i=1, #m do
            if m[i] then
                local Player = QBCore.Functions.GetPlayer(m[i])
                local CID = Player.PlayerData.citizenid
                local deliverData = Player.PlayerData.metadata["methrun"] or 0

                local payBonus = Config.Buffs and exports[Config.BuffExport]:HasBuff(CID, Config.BuffType) and Config.BuffPay or 1.0
                local final = pay * payBonus

                Player.Functions.SetMetaData('methrun', deliverData + MetaData)
                Player.Functions.AddMoney(Config.Money, final, Config.AddMoneyNotification)
                local chance = math.random(1, 500)
                if chance < 26 then
                    Player.Functions.AddItem("safecracker", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["safecracker"], "add")-- 50%
                --[[elseif chance >=27 and chance <75 then 
                    Player.Functions.AddItem("cryptostick", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add")-- 50%
                elseif chance >=76 and chance <150 then
                    Player.Functions.AddItem("cryptostick", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add") -- 50%]]
                elseif chance >=27 and chance <300 then
                    Player.Functions.AddItem("recyclablematerial", random.math(1,5), false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["recyclablematerial"], "add") -- 50%
                --[[elseif chance >=301 and chance <700 then
                    Player.Functions.AddItem("cryptostick", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add") -- 50%
                elseif chance >=701 and chance <1500 then
                    Player.Functions.AddItem("cryptostick", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add") -- 50%
                elseif chance >=1501 and chance <4500 then
                    Player.Functions.AddItem("cryptostick", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add") -- 50%
                elseif chance >=4501 and chance <10000 then
                    Player.Functions.AddItem("cryptostick", math.random(1,5), false) -- 50%
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add") -- 50%]]
                end
               --[[ if Config.MaterialTicket and MaterialCheck > 0 then
                    if Player.Functions.AddItem('matticket', MaterialCheck) then
                        TriggerClientEvent('inventory:client:ItemBox', Player.PlayerData.source, QBCore.Shared.Items['matticket'], "add", MaterialCheck)
                     end
                end]]

                if Config.RenewedBanking then
                    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
                    local text = Config.Message ..CurrentRuns[group].Delivered.. Config.Delivered
                    exports['Renewed-Banking']:handleTransaction(CID, Config.Header, final, text, Config.Text, name, "deposit")
                end

                TriggerClientEvent('Polar-MethRun:client:ResetClient', m[i])
            end
        end
        if Config.Debug then
            print("job finished")
        end
    else
        for i=1, #m do
            if m[i] then
                TriggerClientEvent('Polar-MethRun:client:ResetClient', m[i])
            end
        end
        if Config.Debug then
            print("job finished 2")
        end
    end

    DeleteEntity(NetworkGetEntityFromNetworkId(CurrentRuns[group].car))
    usedPlates[CurrentRuns[group].plate] = nil
    CurrentRuns[group] = nil

    if exports['qb-phone']:isGroupTemp(group) then
        exports['qb-phone']:DestroyGroup(group)
    else
        exports['qb-phone']:resetJobStatus(group)
    end
end)


QBCore.Functions.CreateCallback('Polar-MethRun:server:CanGrabPackage', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end


    local group = exports['qb-phone']:GetGroupByMembers(src)

    if not group or not CurrentRuns[group] then return cb(false) end

    local NetID = CurrentRuns[group].car

    if not NetID then return end

    local vehicle = NetworkGetEntityFromNetworkId(NetID)

    local ped = GetPlayerPed(src)

    if #(GetEntityCoords(vehicle) - GetEntityCoords(ped)) > 5.0 then return cb(false) end


    if CurrentRuns[group].packages <= 0 then
        cb(false)
    else
        CurrentRuns[group].packages = CurrentRuns[group].packages - 1
        cb(true, CurrentRuns[group].packages)

        if CurrentRuns[group].packages == 0 then
            Notifications(_, _, "Last package for this location", group)
        else
            Notifications(_, _, ("%s Packages Left"):format(CurrentRuns[group].packages), group)
        end
    end
end)
