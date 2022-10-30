Config = Config or {}

Config.CoreName = 'qb-core'
Config.Target = 'qb-target'
Config.Menu = 'qb-menu'
Config.Debug = true
 
Config.Cooldown = 60 -- in minutes

Config.RenewedBanking = true

--(IF BOTH FALSE THEN WILL SEND THROUGH QB NOTIFICATIONS)
-- Sends Messages Through the Employment Database
Config.RenewedPhone = true
-- Sends Messages through Mail
Config.QbPhone = false -- (any phone that is labled qb-phone. Uses mail to send)


-- The amount of groups stacks the Config.Deliver so if its a 2 man job its then 8, 16 per location 3 would be 16, 32 etc.
Config.Deliver = {min = 4, max = 8} -- How many packages bags per location?
Config.MaxDeliver = 32 -- How many MAXIMUM Packages per location?

-- GROUP JOBS
Config.GroupLimit = 4 -- How many people can be in a group during the runs?
Config.GroupPay = 1.5 -- How much more you get paid for doing a group run (5% more)
Config.GroupPayLimit = 3 -- How many people to get the Config.GroupPay bonus?
Config.LeaderReturn = true -- If you want to make it so ONLY the group leader can return the truck then enable this
Config.GroupStatus = "Package Delivery Route"
Config.GroupStage1 = "Go to the Dropoff"
Config.GroupStage2 = "All Finished"
Config.GroupFinished = "Delivery Complete, Meet with Ricardo for your payment"
Config.GroupName = "Package Delivery "
Config.GroupNotificationStart = "Package Delivery"
-- ERRORS
Config.GroupMax = "Your Group has too many people in it"
Config.GroupBusy = "Your Group is currently busy with another job"
Config.CarInWay = "Someones car is in the Way!, Either move it or Wait"
Config.ErrorColor =  "error" -- (error, success)
Config.GroupLeaderError = "I cannot give or finish the job if you're not the group leader..."
Config.GroupAlreadyRun = "Your group is already doing a run!"
Config.PlateVehicleNotWork = "Error try again!"

-- BUFFS
Config.Buffs = true -- Do u use ps or tnj buffs then enable this
Config.BuffExport = "ps-buffs" -- Some people still use tnj-buffs some uses ps-buffs they are the just edit the BuffExport to whatever you use
Config.BuffType = "luck" -- What buff type do u use for players to recieve more money? (any buff words as it uses HasBuff(CID, Config.BuffType))
Config.BuffPay = 1.15 -- How much more do they get paid for having the buff? (15% more)

-- PROGRESSBAR
Config.Progressbar = 'Reasoning with Miguel'
Config.ProgressbarAnimDict = 'misscarsteal4@actor'
Config.ProgressbarAnim = 'actor_berating_loop'
Config.ProgressbarAnimFlags = 49

-- GAS
Config.LegacyFuel = false
Config.PsFuel = true
Config.RenewedFuel = false 

Config.AddMoneyNotification = "Package Delivery"
Config.Money = "cash" -- (cash, bank, crypto)

Config.DeliveryDrawText = "[E] Deliver Package"
Config.DeliveryDrawTextLocation = 'left'
-- METH GUARDS
Config.DefaultValues = {
    armor = 100, -- health
    accuracy = 60, -- weapon accuracy
}
local MethGuards = {
    -- GROUND
        { coords = vector4(3820.32, 4458.0, 3.57, 230.37),  model = 'g_m_y_lost_01', weapon = 'WEAPON_smg'},
        { coords = vector4(3819.05, 4464.62, 3.61, 162.91), model = 'g_m_y_lost_03', weapon = 'WEAPON_microsmg'},
        { coords = vector4(3810.61, 4469.97, 3.97, 110.91), model = 'g_m_y_lost_02', weapon = 'WEAPON_assaultrifle'},
        { coords = vector4(3803.51, 4464.97, 4.81, 18.9), model = 'g_m_y_lost_01', weapon = 'WEAPON_smg'},
        { coords = vector4(3809.33, 4455.14, 4.13, 352.57), model = 'g_m_y_lost_03', weapon = 'WEAPON_smg'},
        { coords = vector4(3800.44, 4452.45, 4.54, 309.68), model = 'g_m_y_lost_02', weapon = 'WEAPON_smg'},
        { coords = vector4(3799.84, 4474.73, 5.99, 108.55), model = 'g_m_y_lost_01', weapon = 'WEAPON_smg'},
        { coords = vector4(3820.13, 4483.23, 5.99, 66.19), model = 'g_m_y_lost_03', weapon = 'WEAPON_assaultrifle'},
        { coords = vector4(3849.42, 4463.54, 2.7, 59.84),  model = 'g_m_y_lost_02', weapon = 'WEAPON_microsmg'},
        { coords = vector4(3829.66, 4458.0, 2.75, 88.73),  model = 'g_m_y_lost_01', weapon = 'WEAPON_microsmg'},

        -- BRIDGE
        { coords = vector4(3786.54, 4464.37, 5.97, 89.05),  model = 'g_m_y_lost_02', weapon = 'WEAPON_smg'},
        { coords = vector4(3476.35, 4650.87, 55.18, 344.47),  model = 'g_m_y_lost_01', weapon = 'WEAPON_smg'},
        { coords = vector4(3488.36, 4642.55, 55.95, 14.72),  model = 'g_m_y_lost_02', weapon = 'WEAPON_smg'},
        { coords = vector4(3491.79, 4655.3, 54.3, 27.11),  model = 'g_m_y_lost_02', weapon = 'WEAPON_smg'},
        { coords = vector4(3495.24, 4672.08, 52.81, 55.79),  model = 'g_m_y_lost_01', weapon = 'WEAPON_smg'},
        { coords = vector4(3474.61, 4660.47, 54.42, 347.16),  model = 'g_m_y_lost_01', weapon = 'WEAPON_smg'},

        -- ROOF
        { coords = vector4(3829.73, 4438.97, 7.89, 17.18),  model = 'g_m_y_lost_01', weapon = 'WEAPON_assaultrifle'},
        { coords = vector4(3821.25, 4438.71, 8.12, 38.67),  model = 'g_m_y_lost_03', weapon = 'WEAPON_assaultrifle'},
        --BOAT
        { coords = vector4(3820.21, 4451.37, 5.06, 33.13),  model = 'g_m_y_lost_02', weapon = 'WEAPON_assaultrifle'},
        { coords = vector4(3831.19, 4450.34, 5.47, 16.81),  model = 'g_m_y_lost_03', weapon = 'WEAPON_smg'},
        { coords = vector4(3823.77, 4471.73, 5.19, 179.88),  model = 'g_m_y_lost_02', weapon = 'WEAPON_smg'},
        { coords = vector4(3830.72, 4479.63, 7.37, 312.49),  model = 'g_m_y_lost_03', weapon = 'WEAPON_assaultrifle'},

        { coords = vector4(3838.24, 4468.96, 1.35, 101.94),  model = 'g_m_y_lost_01', weapon = 'WEAPON_microsmg'},
        { coords = vector4(3799.57, 4439.08, 4.97, 317.84),  model = 'g_m_y_lost_01', weapon = 'WEAPON_smg'},
        { coords = vector4(3786.54, 4448.74, 4.93, 54.42),  model = 'g_m_y_lost_02', weapon = 'WEAPON_smg'},
        { coords = vector4(3781.56, 4479.63, 6.21, 117.56),  model = 'g_m_y_lost_03', weapon = 'WEAPON_smg'},
        { coords = vector4(3788.17, 4499.86, 7.14, 103.92),  model = 'g_m_y_lost_01', weapon = 'WEAPON_assaultrifle'},
        { coords = vector4(3795.26, 4492.27, 5.95, 151.09),  model = 'g_m_y_lost_03', weapon = 'WEAPON_microsmg'},
        { coords = vector4(3819.54, 4493.15, 4.26, 357.57),  model = 'g_m_y_lost_03', weapon = 'WEAPON_smg'},
        { coords = vector4(3830.43, 4473.99, 3.04, 140.7),  model = 'g_m_y_lost_02', weapon = 'WEAPON_smg'},
        { coords = vector4(3826.35, 4470.67, 3.46, 193.02),  model = 'g_m_y_lost_01', weapon = 'WEAPON_microsmg'},
}

local MethCivilians = {
    { coords = vector4(334.42, -210.84, 54.09, 93.23), model = 'mp_m_boatstaff_01' }, -- Config.CivilianAnimation is used
    { coords = vector4(327.07, -209.98, 54.09, 78.87), model = 'a_f_y_beach_01', animation = 'WORLD_HUMAN_SUNBATHE' }, -- optional
    { coords = vector4(326.6, -214.55, 54.09, 261.56), model = 'a_f_y_beach_01', animation = 'WORLD_HUMAN_SUNBATHE_BACK' },
}

Config.CivilianAnimation = "CODE_HUMAN_COWER" -- animation for civilians spawned

-- RENEWED BANKING transaction id
Config.Message = "I love you so much"
Config.Text = "Delivered Enriques Packages"
Config.Header = "Lost Santos Underground"
Config.Delivered = "Packages"

Config.PhoneJobStatus = "Package Delivery"
Config.PhoneStage1 = "Go pickup the Vehicle"
Config.PhoneStage2 = "Dropoff the goods to the location"
-- RENEWED DELIVERY NOTIFICATIONS
Config.NewPlace = "Delivery complete for this location headover to the next!"
-- ONLY FOR QB PHONE
Config.EmailName = "Rico"
Config.EmailMessage = "Thank you for delivering my packages"
Config.EmailHeader = "Package Delivery"

-- ONLY FOR NOTIFICATIONS (FALSE ON BOTH QB PHONE AND RENEWED PHONE)
Config.NOTIFICATIONSTART = "Head over and pickup the vehicle"
Config.NOTIFICATIONSECOND = "Go Deliver my packages"
Config.NOTIFICATIONLAST = "Thank you for delivering my packages, now return the vehicle"

-- WHAT ITEMS
Config.DeliveryItem = 'package' -- item used when delivering
Config.StartItem = 'methbatch' -- item used to start the meth run
Config.StartItemAmount = 5 -- Amount of config.startitem needed to start the meth run

-- VEHICLE STUFF
Config.MethVehicle = "karuma" -- vehicle spawn name for meth run car

Config.CarSpawns = { -- meth run vehicle spawn locations
    vector4(-327.6, -1524.25, 27.25, 267.9),
    vector4(-312.48, -1529.22, 27.27, 263.87),
    vector4(-310.77, -1520.05, 27.4, 261.97),
    vector4(-345.13, -1530.91, 27.42, 269.2)
}

-- talk labels on ped
Config.TargetLabel = "Talk" 
Config.IconLabelPed = 'fa-solid fa-bolt'

-- drop off target labels on vehicle
Config.DropOffLabel = "Drop Off Package"
Config.IconLabelCar = 'fas fa-box'

-- start ped location
Config.Ped2 = "a_f_y_beach_01"
Config.PedLocation =  vector4(-1182.49, -446.21, 43.94, 235.38)


Config.Animation = 'WORLD_HUMAN_AA_COFFEE'

-- vehicle license plate
Config.licenseplate = 'METH'

-- finished meth run location
Config.PackagePedLocations = {
    vector4(329.12, -221.42, 54.09, 6.8),
    vector4(334.96, -216.98, 54.09, 40.65),
}
Config.PackagePed = "s_m_y_garbage"
Config.AnimationFinish = 'WORLD_HUMAN_AA_COFFEE'


-- AMOUNT FOR EACH SET (STARTS SMALL THEN GOES TO LARGE)
Config.Route = {
    ["small"] = 0,
    ["medium"] = 150,
    ["large"] = 300,
}

Config.StopsAmt = {
    ["small"] = {min = 1, max = 2},
    ["medium"] = {min = 2, max = 4},
    ["large"] = {min = 4, max = 8},
}



Config.CarSpawn = vector4(315.64, -237.53, 53.97, 158.66)

-- PACKAGE DELIVERY LOCATIONS
Config.Stops = {

    vector3(1163.8, -314.32, 69.21),
    vector3(-1825.8, 801.07, 138.11),
    vector3(-705.66, -904.7, 19.22),
    vector3(1704.83, 4917.42, 42.06),
    vector3(-40.77, -1751.47, 29.42),

   
    vector3(1956.16, 3746.78, 32.35),
    vector3(549.89, 2663.37, 42.16),
    vector3(-3250.15, 1000.92, 12.83),
    vector3(374.71, 334.0, 103.57),
    vector3(1731.33, 6422.11, 35.04),
    vector3(2549.64, 381.36, 108.62),
    vector3(2671.25, 3283.34, 55.24),
    vector3(24.46, -1339.5, 29.51),
    vector3(-3046.31, 582.2, 7.91),


    
    vector3(-661.54, -900.69, 24.61),
    vector3(-1065.95, -1545.94, 4.9),
}

Config.PackageGrabTime = math.random(4000, 6000) -- Progress bar time when picking up packages.
Config.DeliverTime = math.random(4000, 6000) -- Progress bar time when dropping package into buyer's vehicle.
Config.BuyInfoWait = math.random(4000, 6000)
Config.JobVehicleWait = math.random(10000, 15000)
Config.PackagePedWaitTime = math.random(10000, 15000)
Config.SellLocationWait = math.random(10000, 15000)
Config.BuyerSpawnWait = math.random(15000, 25000)





-- MENU BUTTONS

Config.MenuHeader = "Delivery Man"

Config.RequestJobHeader = "Request Job"
Config.RequestJobText = "Request a Delivery Job"

Config.MenuHeaderExit = "Exit"
Config.MenuTextExit = "fa-solid fa-circle-xmark"

-- JOB REQUEST MENU BUTTONS
Config.RequestingJobHeader = "Package Delivery"

Config.SMALLheader = "Small Route"
Config.SMALLtext = "Get a route with %s-%s Delivery Locations"
Config.SMALLicon = "fa-solid fa-user"

Config.MEDIUMheader = "Medium Route"
Config.MEDIUMtext = "Get a route with %s-%s Delivery Locations"
Config.MEDIUMicon = "fa-solid fa-user"

Config.LARGEheader = "Large Route"
Config.LARGEtext = "Get a route with %s-%s Delivery Locations"
Config.LARGEicon = "fa-solid fa-user"

Config.CooldownNotification = 'youre on cooldown'


-- MINIGAME NOTIFICATIONS
Config.MinigameFailed = 'You failed the minigame'
Config.MinigameSuccess = 'You beat the minigame'