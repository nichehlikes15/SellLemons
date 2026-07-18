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
local TycoonBalances = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonBalances)
local ClientTycoonRebirth = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonRebirth)
local Huge = require(ReplicatedStorage.Modules.Huge)
local ClientTycoonPowers = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonPowers)
local ClientTycoonBalances = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonBalances)

local Config = require(ReplicatedStorage.Config)

print("STATUS:", getgenv().UIRunning)
getgenv().farmsettings = {
    purchase = false,
    upgrade = false,
    rebirth = false,
    ascend = false
}

local tycoonNum
for _, v in pairs(workspace:GetChildren()) do
    if v.Name:find("Tycoon") and v:FindFirstChild("Owner").Value == plr then
        tycoonNum = v
    end
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

section1:label("Settings:")

section1:toggle("Auto Purchase", true, function(v)

    getgenv().farmsettings.purchase = v

    if not v then
        return
    end

    task.spawn(function()
        while getgenv().farmsettings.purchase and getgenv().UIRunning do
            local success, err = pcall(function()
                local tycoon = Tycoon.getLocal()

                if not tycoon then
                    return
                end

                local purchase = GetNextPurchase()

				if purchase.DisplayName == "Cup Stand" then
                    print("Wake Income Stream")
					tycoonNum.Remotes.WakeIncomeStream:InvokeServer("LemonStand")
				end

                if not purchase then
                    warn("No available purchases")
                    return
                end

                local balances = tycoon:GetComponent(ClientTycoonBalances)
                local cash = balances:GetCash()
                local price = purchase:GetPrice()

                if cash >= price then
                    purchase:TryPurchaseAsync()
                end
            end)

            if not success then
                warn("Purchase failed:", err)
            end

            task.wait(0.005)
        end
    end)
end)

local TARGET_MULTIPLIER = 100
section1:toggle("Auto Rebirth", false, function(v)
    getgenv().farmsettings.rebirth = v

    if not v then
        return
    end

    task.spawn(function()
        while getgenv().farmsettings.rebirth and getgenv().UIRunning do
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

                print("Investor multiplier:", Huge.formatShort(multiplier) .. "x")

                if multiplier >= Huge.toHuge(TARGET_MULTIPLIER) then
                    print("Auto rebirthing!")

                    local result = rebirth:RebirthAsync()

                    print("Result:", result)
                end
            end)

            if not success then
                warn("Rebirth failed:", err)
            end

            task.wait(1)
        end
    end)
end)

section1:toggle("Auto Evolution", false, function(v)
    getgenv().farmsettings.evolution = v

    if not v then
        return
    end

    task.spawn(function()
        while getgenv().farmsettings.evolution and getgenv().UIRunning do
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

                print("Evolution progress:", progress)

                if progress >= 1 then
                    print("Evolving!")

                    local oldEvolution = evolution:GetEvolution()
                    local newEvolution, investors = evolution:EvolveAsync()

                    print("Result:", newEvolution, investors)
                end
            end)

            if not success then
                warn("Evolution failed:", err)
            end

            task.wait(1)
        end
    end)
end)

section1:toggle("Auto Upgrade", false, function(v)
    getgenv().farmsettings.upgrade = v

    if not v then
        return
    end

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

        while getgenv().farmsettings.upgrade and getgenv().UIRunning do

            local earners = analyzer:GetEarners()

            for name, earner in pairs(earners) do

                if not getgenv().farmsettings.upgrade then
                    break
                end

                -- Same check as UIManagePageManage
                if earner:IsEnabled() then

                    local info = earner:GetNextUpgradeInfo()

                    -- Same check as UIManageTileEarner
                    if info and not info.Max then

                        local cash = balances:GetCash()

                        -- Huge numbers compare correctly because both are Huge values
                        if info.Price <= cash then
                            local success, err = pcall(function()
                                earner:Upgrade(info.Count, true)
                            end)

                            if not success then
                                warn("Upgrade failed:", name, err)
                            end

                            task.wait(0.05)
                        end
                    end
                end
            end

            task.wait(0.005)
        end
    end)
end)

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
