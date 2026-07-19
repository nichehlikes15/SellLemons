local CalmLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/nichehlikes15/robloxui/refs/heads/main/main.lua"))()

local window = CalmLib:win("Sell Lemons")
local section1 = window:tab("Autofarm", "rbxassetid://109121102062195")
local section2 = window:tab("Settings", "rbxassetid://99579688577014")

local plr = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tycoon = require(ReplicatedStorage.Modules.Tycoon.Tycoon)
local TycoonAnalyzer = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonAnalyzer)
local Balance = require(ReplicatedStorage.Balance)
local ClientTycoonEvolution = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonEvolution)
local ClientTycoonAscension = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonAscension)
local TycoonBalances = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonBalances)
local ClientTycoonRebirth = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonRebirth)
local Huge = require(ReplicatedStorage.Modules.Huge)
local ClientTycoonPowers = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonPowers)
local ClientTycoonBalances = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonBalances)

local Config = require(ReplicatedStorage.Config)

local TARGET_MULTIPLIER = 100000
local introPurchased = false

print("STATUS:", getgenv().UIRunning)
getgenv().farmsettings = {
    purchase = false,
    power = false,
    upgrade = false,
    rebirth = false,
    evolution = false,
    ascend = false
}

local tycoonNum
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:find("Tycoon") and v:FindFirstChild("Owner").Value == plr then
        tycoonNum = v
    end
end

local function RestoreSettings(originalSettings)
    getgenv().farmsettings.power = originalSettings.power
    getgenv().farmsettings.upgrade = originalSettings.upgrade
    getgenv().farmsettings.rebirth = originalSettings.rebirth
    getgenv().farmsettings.evolution = originalSettings.evolution

    print("Previous settings restored.")
end

local function GetNextPurchase()
    local tycoon = Tycoon.getLocal()

    if not tycoon then
        warn("No tycoon found")
        return nil
    end

    local analyzer = tycoon:GetComponent(TycoonAnalyzer)

    if not analyzer then
        warn("No TycoonAnalyzer found")
        return nil
    end

    local purchases = analyzer:GetPurchases()

    for _, purchaseName in ipairs(Balance.PurchaseOrder) do

        local purchase = purchases[purchaseName]

        if purchase
            and purchase:IsEnabled()
            and not purchase:IsPurchased() then

            return purchase
        end
    end

    return nil
end

local function startAutoUpgrade()
    task.spawn(function()

        local tycoon

        repeat
            task.wait(0.5)
            tycoon = Tycoon.getLocal()
        until tycoon

        local analyzer = tycoon:GetComponent(TycoonAnalyzer)
        local balances = tycoon:GetComponent(ClientTycoonBalances)

        if not analyzer or not balances then
            warn("Missing Tycoon components")
            return
        end

        while getgenv().UIRunning do
            if getgenv().farmsettings.upgrade then

                local earners = analyzer:GetEarners()

                for name, earner in pairs(earners) do

                    if earner:IsEnabled() then

                        local info = earner:GetNextUpgradeInfo()

                        if info and not info.Max then

                            local cash = balances:GetCash()

                            if info.Price <= cash then
                                local success, err = pcall(function()
                                    earner:Upgrade(info.Count, true)
                                end)

                                if not success then
                                    warn("Upgrade failed:", name, err)
                                end

                                task.wait(0.005)
                            end
                        end
                    end
                end
            end

            task.wait(0.005)
        end
    end)
end

local function startAutoRebirth()
    task.spawn(function()
        while getgenv().UIRunning do
            if getgenv().farmsettings.rebirth then
                local success, err = pcall(function()
                    local tycoon = Tycoon.getLocal()

                    if not tycoon then
                        return
                    end

                    local balances = tycoon:GetComponent(TycoonBalances)
                    local rebirth = tycoon:GetComponent(ClientTycoonRebirth)

                    if not balances or not rebirth then
                        return
                    end

                    local currentInvestors = balances:GetInvestors()
                    local potentialInvestors = rebirth:GetPotentialInvestors()

                    local multiplier = Huge.divide(
                        potentialInvestors,
                        Huge.max(currentInvestors, Huge.toHuge(100))
                    )

                    --print("Investor multiplier:", Huge.formatShort(multiplier) .. "x")

                    if multiplier >= Huge.toHuge(TARGET_MULTIPLIER) then
                        --print("Auto rebirthing!")

                        rebirth:RebirthAsync()

                        if getgenv().farmsettings.power then
                            local powers = tycoon:GetComponent(ClientTycoonPowers)
                            local balance = tycoon:GetComponent(ClientTycoonBalances)

                            local currentInvestors = balance:GetInvestors()
                            local safeAmount = Huge.multiply(currentInvestors, Huge.toHuge(0.5))

                            for powerName, _ in Config.Powers do
                                local upgradePrice = powers:GetUpgradePrice(powerName)

                                if upgradePrice and upgradePrice <= safeAmount then
                                    local success, err = pcall(function()
                                        powers:UpgradeAsync(powerName)
                                    end)

                                    if not success then
                                        warn("Failed upgrading:", powerName, err)
                                    end
                                end
                            end
                        end

                        --print("Result:", result)
                    end
                end)

                if not success then
                    warn("Rebirth failed:", err)
                end
            end

            task.wait(1)
        end
    end)
end

local function startAutoEvolution()
    task.spawn(function()
        while getgenv().UIRunning do
            if getgenv().farmsettings.evolution then
                local success, err = pcall(function()
                    local tycoon = Tycoon.getLocal()

                    if not tycoon then
                        return
                    end

                    local evolution = tycoon:GetComponent(ClientTycoonEvolution)

                    if not evolution then
                        warn("No evolution component")
                        return
                    end

                    local progress, bonus = evolution:GetEvolutionProgress()

                    --print("Evolution progress:", progress)

                    if progress >= 1 then
                        --print("Evolving!")

                        local oldEvolution = evolution:GetEvolution()
                        local newEvolution, investors = evolution:EvolveAsync()

                        --print("Result:", newEvolution, investors)
                    end
                end)

                if not success then
                    warn("Evolution failed:", err)
                end
            end

            task.wait(1)
        end
    end)
end

local function startIntroPurchase(tycoon)
    local analyzer = tycoon:GetComponent(TycoonAnalyzer)
    local balances = tycoon:GetComponent(ClientTycoonBalances)

    if not analyzer or not balances then return end

    local purchases = analyzer:GetPurchases()
    local introPurchase = purchases["StaircaseIntro"]

    if not introPurchase then return end

    if introPurchase:IsPurchased() then
        introPurchased = true
        return
    end

    print(introPurchase:IsPurchased())
    local introPrice = introPurchase:GetPrice()
    local cash = balances:GetCash()

    if cash >= introPrice then
        local originalSettings = {
            power = getgenv().farmsettings.power,
            upgrade = getgenv().farmsettings.upgrade,
            rebirth = getgenv().farmsettings.rebirth,
            evolution = getgenv().farmsettings.evolution,
        }

        getgenv().farmsettings.power = false
        getgenv().farmsettings.upgrade = false
        getgenv().farmsettings.rebirth = false
        getgenv().farmsettings.evolution = false

        task.wait(1.5)
        local introPrice = introPurchase:GetPrice()
        local cash = balances:GetCash()
    
        if cash >= introPrice then
            print("enough")

            local timeout = tick() + 15

            repeat
                task.wait(0.1)

                pcall(function()
                    introPurchase:TryPurchaseAsync()
                end)

                purchases = analyzer:GetPurchases()
                introPurchase = purchases["StaircaseIntro"]

            until not introPurchase or introPurchase:IsPurchased() or tick() > timeout

            if tick() > timeout then
                warn("Intro purchase timed out.")
            end

            print("Intro staircase bought!")
            RestoreSettings(originalSettings)
        else
            print("not enough")
            RestoreSettings(originalSettings)
        end
    end
end

local function startAutoPurchase()
    task.spawn(function()
        while getgenv().UIRunning do
            if getgenv().farmsettings.purchase then
                local success, err = pcall(function()
                    local tycoon = Tycoon.getLocal()
                    if not tycoon then
                        return
                    end

                    if not introPurchased then
                        startIntroPurchase(tycoon)
                    end

                    local balances = tycoon:GetComponent(ClientTycoonBalances)
                    local purchase = GetNextPurchase()

                    if not purchase then return end

                    if purchase.DisplayName == "Cup Stand" or purchase.DisplayName == "Juicer" then
                        tycoonNum.Remotes.WakeIncomeStream:InvokeServer("LemonStand")
                    end

                    local cash = balances:GetCash()
                    local price = purchase:GetPrice()

                    if cash >= price then
                        purchase:TryPurchaseAsync()
                    end
                end)

                if not success then
                    warn("Auto Purchase Error:", err)
                end
            end

            task.wait(0.005)
        end
    end)
end

local function startAutoAscend()
    task.spawn(function()
        while getgenv().UIRunning do
            if getgenv().farmsettings.ascend then

                local success, err = pcall(function()

                    local tycoon = Tycoon.getLocal()

                    if not tycoon then
                        print("error")
                        return
                    end

                    local analyzer = tycoon:GetComponent(TycoonAnalyzer)
                    local balance = tycoon:GetComponent(ClientTycoonBalances)
                    local ascension = tycoon:GetComponent(ClientTycoonAscension)

                    if not analyzer or not balance or not ascension then
                        print("error")
                        return
                    end

                    local purchases = analyzer:GetPurchases()
                    local finalPurchase = purchases["StaircaseStepFinal"]

                    if not finalPurchase then
                        warn("Final staircase not found")
                        return
                    end

                    local price = finalPurchase:GetPrice()
                    local cash = balance:GetCash()

                    -- We can afford final ascend requirement
                    if cash >= price then --and not finalPurchase:IsPurchased() then

                        print("Buying final staircase")

                        local originalSettings = {
                            power = getgenv().farmsettings.power,
                            upgrade = getgenv().farmsettings.upgrade,
                            rebirth = getgenv().farmsettings.rebirth,
                            evolution = getgenv().farmsettings.evolution
                        }

                        -- Disable all other settings except for purchase
                        getgenv().farmsettings.purchase = true
                        getgenv().farmsettings.power = false
                        getgenv().farmsettings.upgrade = false
                        getgenv().farmsettings.rebirth = false
                        getgenv().farmsettings.evolution = false

                        print("Enough")
                        local broke = false
                        repeat
                            task.wait(0.2)

                            local price = finalPurchase:GetPrice()
                            local cash = balance:GetCash()

                            if cash >= price then
                                purchases = analyzer:GetPurchases()
                                finalPurchase = purchases["StaircaseStepFinal"]
                            else
                                print("Found out there is not enough in loop")
                                RestoreSettings(originalSettings)
                                broke = true
                            end

                        until finalPurchase:IsPurchased() or broke


                        print("Final staircase bought, ascending")

                        local oldAscension = ascension:GetAscension()
                        ascension:AscendAsync()


                        -- Wait for ascension to increase
                        local x = 0
                        repeat
                            task.wait(0.5)
                            print("waiting")
                            x = x + 1
                            if x % 5 == 0 then
                                print("retrying")
                                oldAscension = ascension:GetAscension()
                                ascension:AscendAsync()
                            end
                        until ascension:GetAscension() > oldAscension or x == 26

                        print("Ascended, restoring settings")

                        introPurchased = false
                        RestoreSettings(originalSettings)
                    end

                end)

                if not success then
                    warn("Ascend failed:", err)
                end
            end

            task.wait(0.05)
        end
    end)
end

section1:label("Settings:")

section1:toggle("Auto Purchase", true, function(v)
    getgenv().farmsettings.purchase = v
end)

section1:toggle("Auto Power", false, function(v)
    getgenv().farmsettings.power = v
end)

section1:toggle("Auto Upgrade", false, function(v)
    getgenv().farmsettings.upgrade = v
end)

section1:toggle("Auto Rebirth", false, function(v)
    getgenv().farmsettings.rebirth = v
end)

section1:toggle("Auto Evolution", false, function(v)
    getgenv().farmsettings.evolution = v
end)

section1:toggle("Auto Ascend", false, function(v)
    getgenv().farmsettings.ascend = v
end)

startAutoPurchase()
startAutoUpgrade()
startAutoRebirth()
startAutoEvolution()
startAutoAscend()

getgenv().antiafk = true

plr.Idled:Connect(function()
    if not getgenv().antiafk then return end
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Settings
section2:toggle("Disable 3D Rendering", false, function(v)
    game:GetService("RunService"):Set3dRenderingEnabled(not v)
end)

section2:toggle("Anti AFK", true, function(v)
    getgenv().antiafk = v
end)
