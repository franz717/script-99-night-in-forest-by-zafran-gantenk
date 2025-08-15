-- Orion Library Loader
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/GRPGaming/Key-System/refs/heads/Xycer-Hub-Script/ZusumeLib(Slider)"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

-- Main Window
local Window = OrionLib:MakeWindow({
    Name = "99 night in forest by frvnz",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "99Night"
})

----------------------------------------------------------------------
-- TAB: MAIN
----------------------------------------------------------------------
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- NoClip
local noclip = false
MainTab:AddToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(state)
        noclip = state
    end
})
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Fly (Infinite Yield style)
local flying = false
local flyspeed = 50
local BV, BG

local function startFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    BV = Instance.new("BodyVelocity")
    BV.Velocity = Vector3.zero
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Parent = hrp

    BG = Instance.new("BodyGyro")
    BG.CFrame = hrp.CFrame
    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.Parent = hrp

    flying = true
end

local function stopFly()
    flying = false
    if BV then BV:Destroy() BV = nil end
    if BG then BG:Destroy() BG = nil end
end

MainTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(state)
        if state then startFly() else stopFly() end
    end
})

MainTab:AddSlider({
    Name = "FlySpeed",
    Min = 1,
    Max = 100,
    Default = flyspeed,
    Callback = function(val)
        flyspeed = val
    end
})

RunService.RenderStepped:Connect(function()
    if flying and LocalPlayer.Character and BV and BG then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local camCF = Workspace.CurrentCamera.CFrame
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        BV.Velocity = moveDir * flyspeed
        BG.CFrame = camCF
    end
end)

-- SpeedHack
local walkspeed = 16
MainTab:AddToggle({
    Name = "SpeedHack",
    Default = false,
    Callback = function(state)
        if state then
            LocalPlayer.Character.Humanoid.WalkSpeed = walkspeed
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

MainTab:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 100,
    Default = walkspeed,
    Callback = function(val)
        walkspeed = val
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

-- Auto Kill Aura Gun
local autoGun = false
MainTab:AddToggle({
    Name = "Auto Kill Aura Gun",
    Default = false,
    Callback = function(state)
        autoGun = state
    end
})

RunService.RenderStepped:Connect(function()
    if autoGun then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("RemoteEvent") then
            tool.RemoteEvent:FireServer()
        end
    end
end)

----------------------------------------------------------------------
-- TAB: TELEPORT
----------------------------------------------------------------------
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Go to Player
local playersList = {}
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        table.insert(playersList, plr.Name)
    end
end

local selectedPlayer = nil
TeleportTab:AddDropdown({
    Name = "Go to Player",
    Default = playersList[1],
    Options = playersList,
    Callback = function(val)
        selectedPlayer = val
        local target = Players:FindFirstChild(val)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

-- Teleport to Spawn (Api Unggun Level >= 2)
TeleportTab:AddButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local campfire = Workspace:FindFirstChild("Campfire")
        if campfire and campfire:FindFirstChild("Level") and campfire.Level.Value >= 2 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = campfire.CFrame + Vector3.new(0, 5, 0)
        else
            OrionLib:MakeNotification({
                Name = "Teleport Gagal",
                Content = "Api unggun harus level 2 atau lebih!",
                Time = 3
            })
        end
    end
})

----------------------------------------------------------------------
-- TAB: MISC
----------------------------------------------------------------------
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MiscTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

MiscTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        local servers = {}
        local cursor
        repeat
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            if cursor then
                url = url.."&cursor="..cursor
            end
            local data = HttpService:JSONDecode(game:HttpGet(url))
            for _, server in pairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            cursor = data.nextPageCursor
        until not cursor or #servers >= 1

        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(#servers)], LocalPlayer)
        else
            OrionLib:MakeNotification({
                Name = "Server Hop",
                Content = "Tidak ada server lain yang ditemukan.",
                Time = 3
            })
        end
    end
})

MiscTab:AddButton({
    Name = "Leave Game",
    Callback = function()
        game:Shutdown()
    end
})

----------------------------------------------------------------------
-- Start UI
----------------------------------------------------------------------
OrionLib:Init()
