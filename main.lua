if game.GameId == 7395930870 then
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService") --Used for ServerHop Feature
    local TeleportService = game:GetService("TeleportService") --Used for ServerHop Feature
    
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

    local introPurchased = false
    
    local function GetTycoon(player)
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name:find("Tycoon") then
                local owner = v:FindFirstChild("Owner")

                if owner and owner.Value == player then
                    return v
                end
            end
        end
    end

    local tycoonNum = GetTycoon(plr)

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

    Library:Notify({
        Title = "Welcome!",
        Content = "If you enjoy this script, please consider giving it a like. It really helps support future updates. ❤️",
        Duration = 15
    })

    local function RestoreSettings(settings)
        Options.Power.Value = settings.power
        Options.Upgrade.Value = settings.upgrade
        Options.Rebirth.Value = settings.rebirth
        Options.Evolution.Value = settings.evolution
    end

    local selectedPlayer = plr
    local selectedTycoon = GetTycoon(plr)

    local statConnections = {}

    local function updatePlayerList()
        local playerList = {}

        for _, player in ipairs(Players:GetPlayers()) do
            table.insert(playerList, player.Name)
        end

        return playerList
    end

    local PlayersDropdown = Tabs.Stats:CreateDropdown(
        "Players",
        {
            Title = "Choose Player",
            Values = updatePlayerList(),
            Multi = false,
            Default = plr.Name
        }
    )

    local RebirthStat = Tabs.Stats:CreateParagraph(
        "RebirthStat",
        {
            Title = "Total Rebirth:",
            Content = ""
        }
    )

    local EvolveStat = Tabs.Stats:CreateParagraph(
        "EvolveStat",
        {
            Title = "Total Evolves:",
            Content = ""
        }
    )

    local AscendStat = Tabs.Stats:CreateParagraph(
        "AscendStat",
        {
            Title = "Ascension:",
            Content = ""
        }
    )

    local function UpdateStats()
        if not selectedTycoon then
            return
        end

        local values = selectedTycoon.Values.Values

        RebirthStat:SetValue(tostring(values:GetAttribute("TotalRebirths") or 0))
        EvolveStat:SetValue(tostring(values:GetAttribute("TotalEvolves") or 0))
        AscendStat:SetValue(tostring(values:GetAttribute("Ascension") or 0))
    end

    local function ConnectPlayer(player)
        for _, connection in ipairs(statConnections) do
            connection:Disconnect()
        end

        table.clear(statConnections)

        selectedPlayer = player
        selectedTycoon = GetTycoon(player)

        if not selectedTycoon then
            RebirthStat:SetValue("N/A")
            EvolveStat:SetValue("N/A")
            AscendStat:SetValue("N/A")
            return
        end

        local values = selectedTycoon.Values.Values

        UpdateStats()

        table.insert(statConnections,
            values:GetAttributeChangedSignal("TotalRebirths"):Connect(UpdateStats)
        )

        table.insert(statConnections,
            values:GetAttributeChangedSignal("TotalEvolves"):Connect(UpdateStats)
        )

        table.insert(statConnections,
            values:GetAttributeChangedSignal("Ascension"):Connect(UpdateStats)
        )
    end

    PlayersDropdown:OnChanged(function(value)
        local player = Players:FindFirstChild(value)

        if player then
            ConnectPlayer(player)
        end
    end)

    local function RefreshDropdown()
        PlayersDropdown:SetValues(updatePlayerList())
    end

    Players.PlayerAdded:Connect(RefreshDropdown)
    Players.PlayerRemoving:Connect(RefreshDropdown)

    ConnectPlayer(plr)

    local function GetNextPurchase()
        local tycoon = Tycoon.getLocal()
    
        if not tycoon then
            Library:Notify({
                Title = "Error",
                Content = "No tycoon has been found for you, please either wait or rejoin the game.",
                Duration = 7
            })

            return nil
        end
    
        local analyzer = tycoon:GetComponent(TycoonAnalyzer)
    
        if not analyzer then
            Library:Notify({
                Title = "Error",
                Content = "Missing crucial game files",
                Duration = 7
            })
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
                Library:Notify({
                    Title = "Error",
                    Content = "Missing crucial game files",
                    Duration = 7
                })
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
                                        Library:Notify({
                                            Title = "Error",
                                            Content = "Upgrade failed, check console for logs and error",
                                            Duration = 7
                                        })
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
    
    
                        if multiplier >= Huge.toHuge(tonumber(Options.RebirthMultiplier.Value)) then
    
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
                                            Library:Notify({
                                                Title = "Error",
                                                Content = "Power upgrade failed, check console for logs",
                                                Duration = 7
                                            })
                                            warn("Failed upgrading:", powerName, err)
                                        end
                                    end
                                end
                            end
                        end
                    end)
    
                    if not success then
                        Library:Notify({
                            Title = "Error",
                            Content = "Rebirth failed, check console for logs",
                            Duration = 7
                        })
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
                        Library:Notify({
                            Title = "Error",
                            Content = "Evolution failed, check console for logs",
                            Duration = 7
                        })
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
                    Library:Notify({
                        Title = "Error",
                        Content = "Intro staircase purchase has timed out",
                        Duration = 4
                    })
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
                        Library:Notify({
                            Title = "Error",
                            Content = "Auto purchase failed, check console for logs",
                            Duration = 7
                        })
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
                            Library:Notify({
                                Title = "Error",
                                Content = "Final Staircase button not found",
                                Duration = 7
                            })
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
                        Library:Notify({
                            Title = "Error",
                            Content = "Ascend failed, check console for logs and error",
                            Duration = 7
                        })
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

    local RebirthMultiplier = Tabs.Farm:CreateInput("RebirthMultiplier", {
        Title = "Rebirth Multiplier",
        Default = 100,
        Placeholder = "100",
        Numeric = true,
        Finished = true,
    })

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

    Tabs.Settings:CreateButton({
        Title = "Server Hop",
        Description = "Join a different server",
        Callback = function()
            local success, response = pcall(function()
                return game:HttpGet(
                    ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
                    :format(game.PlaceId)
                )
            end)

            if not success then
                Library:Notify({
                    Title = "Error",
                    Content = "Server hop failed, failed to fetch server list",
                    Duration = 7
                })
                warn("Failed to fetch server list.")
                return
            end

            local servers = HttpService:JSONDecode(response)

            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        server.id,
                        game.Players.LocalPlayer
                    )
                    break
                end
            end
        end
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
