local QBCore = exports['qb-core']:GetCoreObject()
local mainBlip = nil
local doinJob = false -- to decide weather or not we doing job
local CurrentCops = 0
local CachedNet = nil -- NetID Handler from serverside.
local blip = nil -- Blip Handler
local pZone = nil -- PolyZone
local inZone = false -- In zone or not
local curLocation = nil -- Current location
local prop = nil -- just the prop shit
-- animations
local function LoadAnimation(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
    Citzen.Wait(5)
end

-- npcs
local npcs = {
    ['npcguards'] = {},
    ['npccivilians'] = {}
}
--Vehicle spawn location
local function GetSpawn()
    for _, v in pairs(Config.CarSpawns) do
        if not IsAnyVehicleNearPoint(v.x, v.y, v.z, 4) then
            return v
        end
    end
end

-- car trunk target
local function canDropOffPackage(car)
    local coords, _ = GetModelDimensions(GetEntityModel(car))
    local tempCoords =  GetOffsetFromEntityInWorldCoords(car, 0.0, coords.y - 0.5, 0.0)
    return #(tempCoords - GetEntityCoords(PlayerPedId())) <= 2.3
end


-- Client Check for start job abuse
RegisterNetEvent('Polar-MethRun:client:clientChecks', function(data)
    local coords = GetSpawn()

    if not coords then return QBCore.Functions.Notify(Config.CarInWay, Config.ErrorColor, 10000) end

    -- cooldown
    if Cooldown then 
        Notifications(_, _, Config.CooldownNotification, group)
    else TriggerServerEvent('Polar-MethRun:server:StartJob', data.size, coords) end
   
end)

-- PED SPAWNING
RegisterNetEvent('spawnpeds', function()
    SpawnGuards()
    SpawnCivilians()
end)

-- PLAYER LOAD INTO SERVER
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
    task = nil
    Citizen.Wait(2000)
    if QBCore.Functions.HasItem(Config.DeliveryItem) then 
        startBox()
    end
   
end)




-- PLAYER DONE/LEAVE SERVER
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    task = nil
    DeletePed()
    DeleteBlip()
    --ResetVar()
end)

-- PLAYER JOB UPDATES
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)



-- BOX ANIMATION
RegisterNetEvent('Polar-MethRun:client:startBoxAnim', function()
    local hasItem = QBCore.Functions.HasItem(Config.DeliveryItem)
    if hasItem then 
        stopBox()
        Citizen.Wait(500)
        startBox()
    else
        stopBox()
    end
end)



RegisterNetEvent('Polar-MethRun:client:RequestJob', function()
    local menu = {}
    local PlayerData = QBCore.Functions.GetPlayerData()
    local data = PlayerData.metadata["delivery"]
    exports[Config.Menu]:openMenu({
        {
            header = Config.RequestingJobHeader,
            isMenuHeader = true,
        },
        {
            id = 1,
            header = Config.SMALLheader,
            txt = (Config.SMALLtext):format(Config.StopsAmt["small"].min, Config.StopsAmt["small"].max),
            icon = Config.SMALLicon,
            disabled = data and data < Config.Route["small"],
            params = {
            event = "Polar-MethRun:client:clientChecks",
            args = {
                size = "small",
            }
        },
        },
        {
            id = 2,
            header = Config.MEDIUMheader,
            txt = (Config.MEDIUMtext):format(Config.StopsAmt["medium"].min, Config.StopsAmt["medium"].max),
            icon = Config.MEDIUMicon,
            disabled = data and data < Config.Route["small"],
            params = {
            event = "Polar-MethRun:client:clientChecks",
            args = {
                size = "small",
            }
        }
        },
        {
            id = 3,
            header = Config.LARGEheader,
            txt = (Config.LARGEtext):format(Config.StopsAmt["large"].min, Config.StopsAmt["large"].max),
            icon = Config.LARGEicon,
            disabled = data and data < Config.Route["large"],
            params = {
            event = "Polar-MethRun:client:clientChecks",
            args = {
                size = "large",
            }
        }
        },
    })

    local function Listen4Control()
        CreateThread(function()
            while inZone do
                if IsControlJustPressed(0, 38) then
                    TriggerEvent('Polar-MethRun:client:DeliverPackage')
                end
                Wait(1)
            end
        end)
    end
    -- NEW LOCATION
    RegisterNetEvent('Polar-MethRun:client:NewPlace', function(location, NetID, plate)
        if NetID and plate then
            CachedNet = NetID
            local vehicle = NetToVeh(NetID)
            if Config.PsFuel then exports['ps-fuel'] : SetFuel(car, 100.0) end
            if Config.LegacyFuel then exports['LegacyFuel'] : SetFuel(car, 100.0) end
            if Config.RenewedFuel then exports['Renewed-Fuel']:SetFuel(car, 100.0) end
            TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
        end
        
        curLocation = location
        
        if blip then RemoveBlip(blip) end
        if pZone then exports['qb-core']:HideText() pZone:destroy() inZone = false pZone = nil end
        if not doinJob then doinJob = true end
    
        blip = AddBlipForCoord(curLocation)
        SetBlipSprite(blip, 50)
        SetBlipScale(blip, 0.7)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Drop Off")
        EndTextCommandSetBlipName(blip)
        SetBlipColour(blip, 28)
        SetBlipRoute(blip, true)
    
        pZone = CircleZone:Create(curLocation, 1.5, {
            name="Deliver_ZonePostOP",
            useZ = true,
            debugPoly = false,
        })
    
        pZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inZone = true
                if prop == nil then return end
                exports['qb-core']:DrawText(Config.DeliveryDrawText,Config.DeliveryDrawTextLocation)
                Listen4Control()
            else
                inZone = false
                exports['qb-core']:HideText()
            end
        end)
    end)
end)
    
RegisterNetEvent('Polar-MethRun:client:JobDone', function()
    if pZone then exports['qb-core']:HideText() pZone:destroy() inZone = false pZone = nil end
    if blip then RemoveBlip(blip) blip = nil end

    SetNewWaypoint(Config.PackagePedLocations.x, Config.PackagePedLocations.y)
end)

RegisterNetEvent('Polar-MethRun:client:ResetClient', function()
    if blip then RemoveBlip(blip) blip = nil end

    CachedNet = nil
    curLocation = nil
    prop = nil
    doinJob = false
end)



















-- CASE GPS
local function GPS()
    if QBCore.Functions.GetPlayerData().job.name == 'police' then
        TriggerEvent('Polar-MethRun:client:POLGPS')
        CARGPS = AddBlipForEntity(PlayerPedId())
        SetBlipSprite(CARGPS, 161)
        SetBlipScale(CARGPS, 1.4)
        PulseBlip(CARGPS)
        SetBlipColour(CARGPS, 2)
        SetBlipAsShortRange(CARGPS, true)
        QBCore.Functions.Notify(Lang:t("success.case_beep"), 'success')
    end
end


--[[
CreateThread(function()
    local mainBlip = AddBlipForCoord(Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z)
    SetBlipSprite(mainBlip, 616)
    SetBlipDisplay(mainBlip, 4)
    SetBlipScale(mainBlip, 0.6)
    SetBlipAsShortRange(mainBlip, true)
    SetBlipColour(mainBlip, 24)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("BLAKE GAY")
    EndTextCommandSetBlipName(mainBlip)

    Wait(2500) -- QB target sometimes dosnt load it straight away and fucks it up, so I just wait a bit.

    
    exports['qb-target']:SpawnPed({
        model = Config.Ped,
        coords = Config.PedLocation,
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = Config.Animation,
        target = {
            options = {
                {
                    event = "Polar-MethRun:client:OpenMainMenu",
                    icon = Config.IconLabelPed,
                    label = Config.TargetLabel,
                    
                }
            },
            distance = 2.5,
        },
       
        
    })
    if Config.Debug then
        print("ped spawned")
    end

-- vehicle target
    if Config.Debug then
        print("vehicle tryna spawn")
    end

    exports['qb-target']:AddGlobalVehicle({
        options = {
          {
            type = "client",
            event = "Renewed-Deliveries:client:TakePackage",
            icon = 'fas fa-box',
            label = 'Take Package',
            canInteract = function(entity)
                if not doinJob then return false end
                if GetEntityModel(entity) ~= joaat("boxville4") and GetEntityModel(entity) ~= joaat("pounder") then return false end
                if GetVehicleDoorLockStatus(entity) ~= 1 then return false end
                if prop then return false end
                if GetVehicleEngineHealth(entity) <= 0 then return false end
                if #(GetEntityCoords(PlayerPedId()) - curLocation) > 80.0 then return false end
                return canTakePackage(entity)
            end,
            print("vehicle spawned first")
          }
        },
        distance = 1.0,
    })
    if Config.Debug then
        print("vehicle spawned")
    end
end)]]


CreateThread(function()

    Wait(2500) -- QB target sometimes dosnt load it straight away and fucks it up, so I just wait a bit.

    -- ped spawner
    exports[Config.Target]:SpawnPed({
        model = Config.Ped2,
        coords = Config.PedLocation,
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        scenario = Config.Animation,
        target = {
        options = {
            {
            event = "Polar-MethRun:client:OpenMainMenu",
            icon = Config.IconLabelPed,
            label = Config.TargetLabel,
            }
        },
            distance = 2.5,
        },
    })

    -- global vehicle target
    exports[Config.Target]:AddGlobalVehicle({
        options = {
          {
            type = "client",
            event = "Polar-MethRun:client:TakePackage",
            icon = 'fas fa-box',
            label = 'Take Package',
            canInteract = function(entity)
                if not doinJob then return false end
                if GetEntityModel(entity) ~= joaat("boxville4") and GetEntityModel(entity) ~= joaat("pounder") then return false end
                if GetVehicleDoorLockStatus(entity) ~= 1 then return false end
                if prop then return false end
                if GetVehicleEngineHealth(entity) <= 0 then return false end
                if #(GetEntityCoords(PlayerPedId()) - curLocation) > 80.0 then return false end
                return canTakePackage(entity)
            end,
          }
        },
        distance = 1.0,
    })
end)


local randomTable = {
    "pack1",
    "pack2",
    "pack3",
}


-- VEHICLE GPS
RegisterNetEvent('Polar-MethRun:client:POLGPS', function()
    if not isLoggedIn then return end
    local PlayerJob = QBCore.Functions.GetPlayerData().job
    if PlayerJob.name == "police" and PlayerJob.onduty then
        local bank
        bank = "Fleeca"
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        local vehicleCoords = GetEntityCoords(MissionVehicle)
        local s1, s2 = GetStreetNameAtCoord(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
        local street1 = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        local streetLabel = street1
        if street2 then streetLabel = streetLabel .. " " .. street2 end
        local plate = GetVehicleNumberPlateText(MissionVehicle)


        -- POLICE ALERT
        TriggerServerEvent('police:server:policeAlert', "Theft (Tracker active)")
        exports['ps-dispatch']:DrugBoatRobbery()
        exports["ps-dispatch"]:CustomAlert({ coords = vector3(442.44, -979.91, 30.69), message = "Theft (Tracker active)", dispatchCode = "10-60", description = "Tracked vehicle is being stolen", radius = 0, sprite = 205, color = 2, scale = 1.0, length = 5, })
        if Config.Debug then
            print("police alert send")
        end
    end
end)










local function SpawnGuards()
    if Config.Debug then
        print("guards tryna spawn")
    end
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, 'PLAYER')
    AddRelationshipGroup('npcguards')
    
    local listOfGuardPositions = nil
    if Config.Jobs[currentJobId].GuardPositions ~= nil then
        listOfGuardPositions = shallowCopy(Config.Jobs[currentJobId].GuardPositions) -- these are used if random positions
    end
    
    for k, v in pairs(Config.Jobs[currentJobId].Guards) do
        local guardPosition = v.coords
        if guardPosition == nil then
            if listOfGuardPositions == nil then
                print('Someone made an oopsie when making guard positions!')
            else
                local random = math.random(1,#listOfGuardPositions)
                guardPosition = listOfGuardPositions[random]
                table.remove(listOfGuardPositions,random)
            end
        end
        local accuracy = Config.DefaultValues.accuracy
        if v.accuracy then
            accuracy = v.accuracy
        end
        local armor =  Config.DefaultValues.armor
        if v.armor then
            armor = v.armor
        end
        -- print('Guard location: ', guardPosition)
        loadModel(v.model)
        npcs['npcguards'][k] = CreatePed(26, GetHashKey(v.model), guardPosition, true, true)
        NetworkRegisterEntityAsNetworked(npcs['npcguards'][k])
        local networkID = NetworkGetNetworkIdFromEntity(npcs['npcguards'][k])
        if Config.Debug then
            print('networkid: ', networkID)
        end
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(npcs['npcguards'][k], 0)
        SetPedRandomProps(npcs['npcguards'][k])
        SetEntityAsMissionEntity(npcs['npcguards'][k])
        SetEntityVisible(npcs['npcguards'][k], true)
        SetPedRelationshipGroupHash(npcs['npcguards'][k], 'npcguards')
        SetPedAccuracy(npcs['npcguards'][k], accuracy)
        SetPedArmour(npcs['npcguards'][k], armor)
        SetPedCanSwitchWeapon(npcs['npcguards'][k], true)
        SetPedDropsWeaponsWhenDead(npcs['npcguards'][k], false)
        SetPedFleeAttributes(npcs['npcguards'][k], 0, false)
        local weapon = 'WEAPON_PISTOL'
        if v.weapon then
            weapon = v.weapon
        end
        GiveWeaponToPed(npcs['npcguards'][k], v.weapon, 255, false, false)
        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(npcs['npcguards'][k], 10.0, 10.0, 1)
        end
        Wait(1000) -- cheap way to fix npcs not spawning
    end

    SetRelationshipBetweenGroups(0, 'npcguards', 'npcguards')
    SetRelationshipBetweenGroups(5, 'npcguards', 'PLAYER')
    SetRelationshipBetweenGroups(5, 'PLAYER', 'npcguards')
    if Config.Debug then
        print("guards spawned")
    end
end

local function SpawnCivilians()
    if Config.Debug then
        print("civs tryna spawn")
    end
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, 'PLAYER')
    AddRelationshipGroup('npccivilians')
    
    if Config.Jobs[currentJobId].Civilians then

        local listOfCivilianPositions = nil
        if Config.Jobs[currentJobId].CivilianPositions ~= nil then
            listOfCivilianPositions = shallowCopy(Config.Jobs[currentJobId].CivilianPositions) -- these are used if random positions
        end
        
        for k, v in pairs(Config.Jobs[currentJobId].Civilians) do
            local civPosition = v.coords
            if civPosition == nil then
                if listOfCivilianPositions == nil then
                    print('Someone made an oopsie when making civilian positions!')
                else
                    local random = math.random(1,#listOfCivilianPositions)
                    civPosition = listOfCivilianPositions[random]
                    table.remove(listOfCivilianPositions,random)
                end
            end
            -- print('Civ location: ', civPosition)
            loadModel(v.model)
            npcs['npccivilians'][k] = CreatePed(26, GetHashKey(v.model), civPosition, true, true)
            NetworkRegisterEntityAsNetworked(npcs['npccivilians'][k])
            local networkID = NetworkGetNetworkIdFromEntity(npcs['npccivilians'][k])
            SetNetworkIdCanMigrate(networkID, true)
            SetNetworkIdExistsOnAllMachines(networkID, true)
            SetPedRandomComponentVariation(npcs['npccivilians'][k], 0)
            SetPedRandomProps(npcs['npccivilians'][k])
            SetEntityAsMissionEntity(npcs['npccivilians'][k])
            SetEntityVisible(npcs['npccivilians'][k], true)
            SetPedRelationshipGroupHash(npcs['npccivilians'][k], 'npccivilians')
            SetPedArmour(npcs['npccivilians'][k], 10)
            SetPedFleeAttributes(npcs['npccivilians'][k], 0, true)

            local animation = Config.CivilianAnimation
            if v.animation then
                animation = v.animation
            end
            TaskStartScenarioInPlace(npcs['npccivilians'][k],  animation, 0, true)
            Wait(1000) -- cheap way to fix npcs not spawning
        end

        SetRelationshipBetweenGroups(3, 'npccivilians', 'npccivilians')
        SetRelationshipBetweenGroups(3, 'npccivilians', 'PLAYER')
        SetRelationshipBetweenGroups(3, 'PLAYER', 'npccivilians')
    end
    if Config.Debug then
        print("civs spawned")
    end
end




-- PED AND BLIP SPAWN/DELETE
local function CreateBlip(x, y, z, id, text)
	blip = AddBlipForCoord(x, y, z)    
    SetBlipSprite(blip, id)
    SetBlipScale(blip, Config.BlipScale)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

local function DeleteBlip()
	if DoesBlipExist(blip) then
		RemoveBlip(blip)
	end
end

local function DeletePed()
    if packagePed ~= nil then
        SetEntityAsNoLongerNeeded(packagePed)
    else 
        Citizen.Wait(10)
    end
end 



local function CreateFinishPed()
    local packagePedHash = GetHashKey(Config.PackagePed)
    pedLocation = math.random(1, #Config.PackagePedLocations)
    QBCore.Functions.LoadModel(packagePedHash)
    packagePed = CreatePed(28, packagePedHash, Config.PackagePedLocations[pedLocation].x, Config.PackagePedLocations[pedLocation].y, Config.PackagePedLocations[pedLocation].z - 1, Config.PackagePedLocations[pedLocation].w, false, false)
    SetEntityInvincible(packagePed, true)
    FreezeEntityPosition(packagePed, true)
    SetBlockingOfNonTemporaryEvents(packagePed, true)	
    if Config.Debug then
        print("finish ped spawned")
    end	
end









RegisterNetEvent('Polar-MethRun:client:OpenMainMenu', function()
    exports[Config.Menu]:openMenu({
        {
            header = Config.MenuHeader,
            isMenuHeader = true,
        },
        {
            id = 1,
            header = Config.RequestJobHeader,
            txt = Config.RequestJobText,
            params = {
                event = 'Polar-MethRun:client:RequestJob',
            }
        },
        {
            id = 2,
            header = Config.MenuHeaderExit,
            txt = Config.MenuTextExit,
            params = {
                event = 'qb-menu:client:closeMenu',
                
            }
        },
    })
end)











local function ToggleDoor(vehicle, door)
    if GetVehicleDoorLockStatus(vehicle) ~= 2 then
        if GetVehicleDoorAngleRatio(vehicle, door) > 0.0 then
            SetVehicleDoorShut(vehicle, door, false)
        else
            SetVehicleDoorOpen(vehicle, door, false)
        end
    end
end

local function destroyProp(entity)
    SetEntityAsMissionEntity(entity)
    Citizen.Wait(5)
    DetachEntity(entity, true, true)
    Citizen.Wait(5)
    DeleteObject(entity)
end

local function startBox()
    local pos = GetEntityCoords(PlayerPedId(), true)
    RequestAnimDict('anim@heists@box_carry@')
    while (not HasAnimDictLoaded('anim@heists@box_carry@')) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)
    RequestModel('prop_cs_cardbox_01')
    while not HasModelLoaded('prop_cs_cardbox_01') do
        Citizen.Wait(0)
    end
    boxProp = CreateObject('prop_cs_cardbox_01', pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(boxProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
end

local function stopBox()
    if DoesEntityExist(boxProp) then 
        ClearPedTasks(PlayerPedId())
        destroyProp(boxProp)
    end
end

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end 













-- PROJECT SLOTH MINIGAMES

local function MinigameFailiure()
    Notifications(_, _, Config.MinigameFailed, group)
end

local function StartMinigame()
    if Config.Jobs[currentJobId].Items.FetchItemMinigame then
        local type = Config.Jobs[currentJobId].Items.FetchItemMinigame.Type
        local variables = Config.Jobs[currentJobId].Items.FetchItemMinigame.Variables
        if type == "Circle" then
            exports['ps-ui']:Circle(function(success)
                if success then
                    MinigameSuccess()
                    Notifications(_, _, Config.MinigameSuccess, group)
                else
                    MinigameFailiure()
                end
            end, variables[1], variables[2]) -- NumberOfCircles, MS
        elseif type == "Maze" then
            exports['ps-ui']:Maze(function(success)
                if success then
                    MinigameSuccess()
                    Notifications(_, _, Config.MinigameSuccess, group)
                else
                    MinigameFailiure()
                end
            end, variables[1]) -- Hack Time Limit
        elseif type == "VarHack" then
            exports['ps-ui']:VarHack(function(success)
                if success then
                    MinigameSuccess()
                    Notifications(_, _, Config.MinigameSuccess, group)
                else
                    MinigameFailiure()
                end
             end, variables[1], variables[2]) -- Number of Blocks, Time (seconds)
        elseif type == "Thermite" then 
            exports["ps-ui"]:Thermite(function(success)
                if success then
                    MinigameSuccess()
                    Notifications(_, _, Config.MinigameSuccess, group)
                else
                    MinigameFailiure()
                end
            end, variables[1], variables[2], variables[3]) -- Time, Gridsize (5, 6, 7, 8, 9, 10), IncorrectBlocks
        elseif type == "Scrambler" then
            exports['ps-ui']:Scrambler(function(success)
                if success then
                    MinigameSuccess()
                    Notifications(_, _, Config.MinigameSuccess, group)
                else
                    MinigameFailiure()
                end
            end, variables[1], variables[2], variables[3]) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
        end
    else
        exports["ps-ui"]:Thermite(function(success)
            if success then
                MinigameSuccess()
                Notifications(_, _, Config.MinigameSuccess, group)
            else
                MinigameFailiure()
            end
        end, 8, 5, 3) -- Success       
    end
end


if Config.Debug then
    RegisterNetEvent('Polar-Methrun:client:debug', function()
        print("server debug triggered")


        --TriggerClientEvent('Polar-Methrun:client:debug')

    end)
end
