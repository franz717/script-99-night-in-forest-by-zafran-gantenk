-- Load Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Buat Window
local Window = OrionLib:MakeWindow({
    Name = "99 Night in the Forest - Cheat Menu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NightForestConfig"
})

-- Tabs
local MainTab = Window:MakeTab({
    Name = "Main Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Variabel
local noclipEnabled = false
local flyEnabled = false
local flySpeed = 5
local autoGunEnabled = false
local selectedPlayer = nil

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

------------------------------------------------
-- NoClip
------------------------------------------------
MainTab:AddToggle({
    Name = "NoClip (tembus tembok)",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
    end
})

MainTab:AddButton({
    Name = "Aktifkan Noclip Sekali",
    Callback = function()
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
})

RunService.Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

------------------------------------------------
-- Fly
------------------------------------------------
local flyVelocity
MainTab:AddToggle({
    Name = "Fly Mode",
    Default = false,
    Callback = function(state)
        flyEnabled = state
        if flyEnabled then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                flyVelocity = Instance.new("BodyVelocity")
                flyVelocity.Velocity = Vector3.new(0,0,0)
                flyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
                flyVelocity.Parent = hrp
            end
        else
            if flyVelocity then
                flyVelocity:Destroy()
                flyVelocity = nil
            end
        end
    end
})

MainTab:AddButton({
    Name = "Aktifkan Fly Sekali",
    Callback = function()
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tempFly = Instance.new("BodyVelocity")
            tempFly.Velocity = Vector3.new(0,50,0)
            tempFly.MaxForce = Vector3.new(1e5,1e5,1e5)
            tempFly.Parent = hrp
            task.delay(1, function()
                tempFly:Destroy()
            end)
        end
    end
})

MainTab:AddSlider({
    Name = "Fly Speed",
    Min = 1,
    Max = 100,
    Default = 5,
    Increment = 1,
    ValueName = "speed",
    Callback = function(value)
        flySpeed = value
    end
})

RunService.RenderStepped:Connect(function()
    if flyEnabled and flyVelocity and player.Character then
        local moveDirection = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + player.Character.HumanoidRootPart.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - player.Character.HumanoidRootPart.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - player.Character.HumanoidRootPart.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + player.Character.HumanoidRootPart.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0,1,0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0,1,0)
        end
        flyVelocity.Velocity = moveDirection * flySpeed
    end
end)

------------------------------------------------
-- Auto Kill Aura Gun
------------------------------------------------
MainTab:AddToggle({
    Name = "Auto Kill Aura Gun",
    Default = false,
    Callback = function(state)
        autoGunEnabled = state
    end
})

MainTab:AddButton({
    Name = "Auto Kill Aura Gun Sekali",
    Callback = function()
        local gun = player.Character:FindFirstChildOfClass("Tool")
        if gun and gun:FindFirstChild("Activate") then
            gun:Activate()
        end
    end
})

RunService.RenderStepped:Connect(function()
    if autoGunEnabled then
        local gun = player.Character:FindFirstChildOfClass("Tool")
        if gun and gun:FindFirstChild("Activate") then
            gun:Activate()
        end
        if gun and gun:FindFirstChild("Reload") then
            gun:Reload()
        end
    end
end)

------------------------------------------------
-- Go to Player (Dropdown)
------------------------------------------------
local playerList = {}
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        table.insert(playerList, plr.Name)
    end
end

TeleportTab:AddDropdown({
    Name = "Go to Player",
    Default = "",
    Options = playerList,
    Callback = function(value)
        local target = Players:FindFirstChild(value)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            player.Character:PivotTo(target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0))
        end
    end
})

Players.PlayerAdded:Connect(function(plr)
    table.insert(playerList, plr.Name)
end)

Players.PlayerRemoving:Connect(function(plr)
    for i, name in ipairs(playerList) do
        if name == plr.Name then
            table.remove(playerList, i)
            break
        end
    end
end)

------------------------------------------------
-- Teleport to Spawn (Api Unggun)
------------------------------------------------
TeleportTab:AddButton({
    Name = "Teleport to Spawn (Api Unggun)",
    Callback = function()
        local campfire = workspace:FindFirstChild("Campfire") or workspace:FindFirstChild("Fire") or workspace:FindFirstChild("SpawnCamp")
        if campfire and campfire:IsA("BasePart") then
            player.Character:PivotTo(campfire.CFrame + Vector3.new(0,3,0))
        else
            OrionLib:MakeNotification({
                Name = "Gagal",
                Content = "Api unggun tidak ditemukan!",
                Time = 3
            })
        end
    end
})

-- Selesai
OrionLib:Init()
