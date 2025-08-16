-- [99 Malam Script Hub]
-- By ChatGPT, Orion UI

-- Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/GRPGaming/Key-System/refs/heads/Xycer-Hub-Script/ZusumeLib(Slider)')))()
local Window = OrionLib:MakeWindow({Name = "99 Malam Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "MalamHub"})

-- Notifikasi Pembuka
OrionLib:MakeNotification({
    Name = "H4x FranzBravo",
    Content = "Script berhasil dijalankan!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-----------------------------------------
-- Tab: Main
-----------------------------------------
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Go to Player
MainTab:AddTextbox({
    Name = "Go To Player",
    Default = "",
    TextDisappear = true,
    Callback = function(playerName)
        local target = Players:FindFirstChild(playerName)
        if target and target.Character then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Player tidak ditemukan!",
                Time = 3
            })
        end
    end      
})

-- Teleport to Camp Fire (cek level minimal 2)
local function teleportToCampFire()
    local campfire = nil
    local level = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj:FindFirstChildOfClass("TextLabel") then
            local label = obj:FindFirstChildOfClass("TextLabel")
            local text = string.lower(label.Text)
            if string.find(text, "perkembangan level") then
                campfire = obj.Parent
                local lvl = string.match(text, "level%s*(%d+)")
                if lvl then
                    level = tonumber(lvl) or 0
                end
                break
            end
        end
    end
    if campfire and level >= 2 then
        LocalPlayer.Character:MoveTo(campfire.Position + Vector3.new(0, 5, 0))
    else
        OrionLib:MakeNotification({
            Name = "Teleport Gagal",
            Content = "Api unggun harus level 2 atau lebih!",
            Time = 3
        })
    end
end

MainTab:AddButton({
    Name = "Teleport to Camp Fire",
    Callback = teleportToCampFire
})

-----------------------------------------
-- Tab: Movement
-----------------------------------------
local MoveTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Fly (template dari Infinite Yield)
getgenv().FlySpeed = 50
MoveTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(state)
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            OrionLib:MakeNotification({Name="Fly", Content="Tekan E untuk toggle fly", Time=5})
        end
    end
})

MoveTab:AddSlider({
    Name = "FlySpeed",
    Min = 1,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0,255,0),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(v)
        getgenv().FlySpeed = v
    end    
})

-- SpeedHack
getgenv().WalkSpeedValue = 16
MoveTab:AddToggle({
    Name = "SpeedHack",
    Default = false,
    Callback = function(state)
        if state then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

MoveTab:AddSlider({
    Name = "Speed",
    Min = 1,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255,0,0),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(v)
        getgenv().WalkSpeedValue = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end    
})

-----------------------------------------
-- Tab: Misc
-----------------------------------------
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local itemName = ""
local itemCount = "1"

MiscTab:AddTextbox({
    Name = "Nama Barang",
    Default = "",
    TextDisappear = false,
    Callback = function(txt)
        itemName = txt
    end
})

MiscTab:AddTextbox({
    Name = "Berapa",
    Default = "1",
    TextDisappear = false,
    Callback = function(txt)
        itemCount = txt
    end
})

MiscTab:AddButton({
    Name = "Duplicate (Visual)",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Duplicate Visual",
            Content = "Nama Barang: "..itemName.." | Jumlah: "..itemCount,
            Time = 5
        })
    end
})

-----------------------------------------
OrionLib:Init()

