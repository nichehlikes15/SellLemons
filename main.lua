if game.GameId == 7395930870 then
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
    
    local tycoonNum
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name:find("Tycoon") and v:FindFirstChild("Owner").Value == plr then
            tycoonNum = v
        end
    end

    local Library =
        loadstring(
        game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau")
    )()
    local SaveManager =
        loadstring(
        game:HttpGetAsync(
            "https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"
        )
    )()
    local InterfaceManager =
        loadstring(
        game:HttpGetAsync(
            "https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"
        )
    )()
    local Window =
        Library:CreateWindow {
        Title = "Sell Lemons",
        SubTitle = "by Nichehlikes15 | Discord",
        TabWidth = 160,
        Size = UDim2.fromOffset(830, 525),
        Resize = true,
        MinSize = Vector2.new(470, 380),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    }
    local Tabs = {
        Farm = Window:CreateTab {
            Title = "Farm",
            Icon = "circle-dollar-sign"
        },
        Stats = Window:CreateTab {
            Title = "Players Stats",
            Icon = "chart-no-axes-column"
        },
        Settings = Window:CreateTab {
            Title = "Settings",
            Icon = "settings"
        }
    }
    local Options = Library.Options
    local UIActive = true

    Library.Unloaded = function()
        UIActive = false
    end
    
    local RebirthStat = Tabs.Stats:CreateParagraph(
        "RebirthStat",
        {
            Title = "Total Rebirth:",
            Content = tycoonNum.Values.Values:GetAttribute("TotalRebirths")
        }
    )
    tycoonNum.Values.Values:GetAttributeChangedSignal("TotalRebirths"):Connect(function()
        RebirthStat:SetValue(tostring(tycoonNum.Values.Values:GetAttribute("TotalRebirths") or 0))
    end)
    
    local EvolveStat = Tabs.Stats:CreateParagraph(
        "EvolveStat",
        {
            Title = "Total Evolves:",
            Content = tycoonNum.Values.Values:GetAttribute("TotalEvolves")
        }
    )
    tycoonNum.Values.Values:GetAttributeChangedSignal("TotalEvolves"):Connect(function()
        EvolveStat:SetValue(tostring(tycoonNum.Values.Values:GetAttribute("TotalEvolves") or 0))
    end)
    
    local AscendStat = Tabs.Stats:CreateParagraph(
        "AscendStat",
        {
            Title = "Ascend:",
            Content = tycoonNum.Values.Values:GetAttribute("Ascension")
        }
    )
    tycoonNum.Values.Values:GetAttributeChangedSignal("Ascension"):Connect(function()
        AscendStat:SetValue(tostring(tycoonNum.Values.Values:GetAttribute("Ascension") or 0))
    end)

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
    
            while UIActive do
                if Options.Upgrade.Value then
    
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
            while UIActive do
                if Options.Rebirth.Value then
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
    
    
                        if multiplier >= Huge.toHuge(TARGET_MULTIPLIER) then
    
                            rebirth:RebirthAsync()
    
                            if Options.Power.Value then
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
            while UIActive do
                if Options.Evolution.Value then
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
    
    
                        if progress >= 1 then
    
                            local oldEvolution = evolution:GetEvolution()
                            local newEvolution, investors = evolution:EvolveAsync()
    
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
    
        local introPrice = introPurchase:GetPrice()
        local cash = balances:GetCash()
    
        if cash >= introPrice then
            local originalSettings = {
                power = Options.Power.Value,
                upgrade = Options.Upgrade.Value,
                rebirth = Options.Rebirth.Value,
                evolution = Options.Evolution.Value,
            }
    
            Options.Power.Value = false
            Options.Upgrade.Value = false
            Options.Rebirth.Value = false
            Options.Evolution.Value = false
    
            task.wait(1.5)
            local introPrice = introPurchase:GetPrice()
            local cash = balances:GetCash()
        
            if cash >= introPrice then
    
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
    
                RestoreSettings(originalSettings)
            else
                RestoreSettings(originalSettings)
            end
        end
    end
    
    local function startAutoPurchase()
        task.spawn(function()
            while UIActive do
                if Options.Purchase.Value then
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
            while UIActive do
                if Options.Ascend.Value then
    
                    local success, err = pcall(function()
    
                        local tycoon = Tycoon.getLocal()
    
                        if not tycoon then
                            return
                        end
    
                        local analyzer = tycoon:GetComponent(TycoonAnalyzer)
                        local balance = tycoon:GetComponent(ClientTycoonBalances)
                        local ascension = tycoon:GetComponent(ClientTycoonAscension)
    
                        if not analyzer or not balance or not ascension then
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
    
    
                            local originalSettings = {
                                power = Options.Power.Value,
                                upgrade = Options.Upgrade.Value,
                                rebirth = Options.Rebirth.Value,
                                evolution = Options.Evolution.Value
                            }
    
                            -- Disable all other settings except for purchase
                            Options.Purchase.Value = true
                            Options.Power.Value = false
                            Options.Upgrade.Value = false
                            Options.Rebirth.Value = false
                            Options.Evolution.Value = false
    
                            local broke = false
                            repeat
                                task.wait(0.2)
    
                                local price = finalPurchase:GetPrice()
                                local cash = balance:GetCash()
    
                                if cash >= price then
                                    purchases = analyzer:GetPurchases()
                                    finalPurchase = purchases["StaircaseStepFinal"]
                                else
                                    RestoreSettings(originalSettings)
                                    broke = true
                                end
    
                            until finalPurchase:IsPurchased() or broke
    
    
    
                            local oldAscension = ascension:GetAscension()
                            ascension:AscendAsync()
    
    
                            -- Wait for ascension to increase
                            local x = 0
                            repeat
                                task.wait(0.5)
                                x = x + 1
                                if x % 5 == 0 then
                                    oldAscension = ascension:GetAscension()
                                    ascension:AscendAsync()
                                end
                            until ascension:GetAscension() > oldAscension or x == 26
    
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

    local Purchase =
        Tabs.Farm:CreateToggle("Purchase",{
            Title = "Auto Purchase",
            Default = false
        })
    Purchase:OnChanged(function()
        startAutoPurchase()
    end)

    local Power =
        Tabs.Farm:CreateToggle("Power",{
            Title = "Auto Power",
            SubTitle = "Requies Auto Rebirth Enabled",
            Default = false
        })

    local Upgrade =
        Tabs.Farm:CreateToggle("Upgrade",{
            Title = "Auto Upgrade",
            Default = false
        })
    Upgrade:OnChanged(function()
        startAutoUpgrade()
    end)

    local Rebirth =
        Tabs.Farm:CreateToggle("Rebirth",{
            Title = "Auto Rebirth",
            Default = false
        })
    Rebirth:OnChanged(function()
        startAutoRebirth()
    end)

    local Evolution =
        Tabs.Farm:CreateToggle("Evolution",{
            Title = "Auto Evolution",
            Default = false
        })
    Evolution:OnChanged(function()
        startAutoEvolution()
    end)

    local Ascend =
        Tabs.Farm:CreateToggle("Ascend",{
            Title = "Auto Ascend",
            Default = false
        })
    Ascend:OnChanged(function()
        startAutoAscend()
    end)

    local Render =
        Tabs.Settings:CreateToggle("Render",{
            Title = "Disable 3D Rendering",
            Default = false
        })

    Render:OnChanged(function()
        game:GetService("RunService"):Set3dRenderingEnabled(
            not Options.Render.Value
        )
    end)

    local AntiAFK =
        Tabs.Settings:CreateToggle("AntiAFK",{
            Title = "Anti AFK",
            Default = true
        })

    Window:SelectTab(1)

    SaveManager:SetLibrary(Library)
    InterfaceManager:SetLibrary(Library)

    SaveManager:IgnoreThemeSettings()

    InterfaceManager:SetFolder("SellLemons")
    SaveManager:SetFolder("SellLemons")

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    SaveManager:LoadAutoloadConfig()
else
    warn("This is the wrong game, please ensure the game ID is: 79268393072444, you game:", game.gameId)
end
