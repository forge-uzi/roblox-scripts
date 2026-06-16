local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SWFL SCRIPT",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "SWFL SCRIPT",
   LoadingSubtitle = "by Sxrfwr",
   ShowText = "SWFL SCRIPT", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

})

local Tab = Window:CreateTab("Player", "rewind")
local VehicleTab = Window:CreateTab("Vehicles", 4483362458)

local TargetWalkSpeed = 16
local TargetJumpPower = 50
local InfiniteJumpEnabled = false

-- Persistent Loop to force values against anti-cheats
task.spawn(function()
    while task.wait() do
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if humanoid.WalkSpeed ~= TargetWalkSpeed then
                    humanoid.WalkSpeed = TargetWalkSpeed
                end
                humanoid.UseJumpPower = true
                if humanoid.JumpPower ~= TargetJumpPower then
                    humanoid.JumpPower = TargetJumpPower
                end
            end
        end
    end
end)

-- Infinite Jump Core Physics
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- UI Controls Configuration
local WalkSpeedSlider = Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 16,
    Flag = "WalkSpeedFlag",
    Callback = function(Value)
        TargetWalkSpeed = Value
    end,
})

local JumpPowerSlider = Tab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerFlag",
    Callback = function(Value)
        TargetJumpPower = Value
    end,
})

local InfiniteJumpToggle = Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpFlag",
    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end,
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local velocityEnabled = true
local flightEnabled = false
local flightSpeed = 1
local velocityMult = 0.025
local velocityMult2 = 0.150
local velocityEnabledKeyCode = Enum.KeyCode.W
local qbEnabledKeyCode = Enum.KeyCode.S
local stopKeyCode = Enum.KeyCode.P

-- Vehicle Locating Logic
local function GetVehicleFromDescendant(Descendant)
    return Descendant:FindFirstAncestor(LocalPlayer.Name .. "'s Car") 
        or (Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent) 
        or Descendant:FindFirstAncestorWhichIsA("Model")
end

-- Function to adjust car suspension properties
local function TuneSuspension(property, value)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    local SeatPart = Humanoid and Humanoid.SeatPart
    
    if SeatPart and SeatPart:IsA("VehicleSeat") then
        local Vehicle = GetVehicleFromDescendant(SeatPart)
        if Vehicle then
            -- Loop through every item in the car to find the springs
            for _, object in pairs(Vehicle:GetDescendants()) do
                if object:IsA("SpringConstraint") then
                    object[property] = value
                end
            end
        end
    end
end

-- Function to adjust wheel offset (Track Width / Spacers)
local function TuneWheelOffset(value)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    local SeatPart = Humanoid and Humanoid.SeatPart
    
    if SeatPart and SeatPart:IsA("VehicleSeat") then
        local Vehicle = GetVehicleFromDescendant(SeatPart)
        if Vehicle then
            for _, object in pairs(Vehicle:GetDescendants()) do
                -- Many chassis use CylindricalConstraints for the wheels
                if object:IsA("CylindricalConstraint") then
                    -- Adjusting the attachment offset shifts the wheel outward
                    if object.Attachment0 then
                        object.Attachment0.Position = Vector3.new(value, object.Attachment0.Position.Y, object.Attachment0.Position.Z)
                    end
                end
            end
        end
    end
end

-- Function to adjust Camber Angle (Tilting the wheels)
local function TuneCamber(angleDegrees)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    local SeatPart = Humanoid and Humanoid.SeatPart
    
    if SeatPart and SeatPart:IsA("VehicleSeat") then
        local Vehicle = GetVehicleFromDescendant(SeatPart)
        if Vehicle then
            for _, object in pairs(Vehicle:GetDescendants()) do
                if object:IsA("Attachment") and (object.Name:find("Wheel") or object.Name:find("Hub")) then
                    -- Reset and apply a fresh rotation angle to the attachment
                    local currentPos = object.Position
                    object.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, 0, math.rad(angleDegrees))
                end
            end
        end
    end
end
-- Flight System Core
RunService.Stepped:Connect(function()
    local Character = LocalPlayer.Character
    if flightEnabled and Character then
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        local SeatPart = Humanoid and Humanoid.SeatPart
        if SeatPart and SeatPart:IsA("VehicleSeat") then
            local Vehicle = GetVehicleFromDescendant(SeatPart)
            if Vehicle and Vehicle:IsA("Model") then
                Character.Parent = Vehicle
                local PrimaryPart = Vehicle.PrimaryPart or SeatPart
                Vehicle.PrimaryPart = PrimaryPart
                
                local cf = PrimaryPart.CFrame
                local move = Vector3.new(
                    (UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and flightSpeed or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed/2 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and flightSpeed/2 or 0),
                    (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and flightSpeed or 0)
                )
                Vehicle:SetPrimaryPartCFrame(CFrame.new(cf.Position, cf.Position + workspace.CurrentCamera.CFrame.LookVector) * CFrame.new(move))
                SeatPart.AssemblyLinearVelocity = Vector3.zero
                SeatPart.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end)

-- Unified Loops for Accel & Brake Keybinds
task.spawn(function()
    while task.wait() do
        if velocityEnabled and UserInputService:IsKeyDown(velocityEnabledKeyCode) and not UserInputService:GetFocusedTextBox() then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
            local SeatPart = Humanoid and Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                SeatPart.AssemblyLinearVelocity *= Vector3.new(1 + velocityMult, 1, 1 + velocityMult)
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if velocityEnabled and UserInputService:IsKeyDown(qbEnabledKeyCode) and not UserInputService:GetFocusedTextBox() then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
            local SeatPart = Humanoid and Humanoid.SeatPart
            if SeatPart and SeatPart:IsA("VehicleSeat") then
                SeatPart.AssemblyLinearVelocity *= Vector3.new(1 - velocityMult2, 1, 1 - velocityMult2)
            end
        end
    end
end)

-- Hard Stop Keybind Listener
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and velocityEnabled and input.KeyCode == stopKeyCode then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
        local SeatPart = Humanoid and Humanoid.SeatPart
        if SeatPart and SeatPart:IsA("VehicleSeat") then
            SeatPart.AssemblyLinearVelocity = Vector3.zero
            SeatPart.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

-- Rayfield Vehicle UI Construction
VehicleTab:CreateToggle({Name = "Keybinds Active", CurrentValue = true, Flag = "velEn", Callback = function(v) velocityEnabled = v end})
VehicleTab:CreateToggle({Name = "Flight Enabled", CurrentValue = false, Flag = "fltEn", Callback = function(v) flightEnabled = v end})
VehicleTab:CreateSlider({Name = "Flight Speed", Range = {0, 800}, Increment = 10, CurrentValue = 100, Flag = "fltSpd", Callback = function(v) flightSpeed = v/100 end})
VehicleTab:CreateSlider({Name = "Accel Mult (Thousandths)", Range = {0, 50}, Increment = 1, CurrentValue = 25, Flag = "velMult", Callback = function(v) velocityMult = v/1000 end})
VehicleTab:CreateKeybind({Name = "Accel Key", CurrentKeybind = "W", Flag = "velKey", Callback = function(k) velocityEnabledKeyCode = Enum.KeyCode[k] end})
VehicleTab:CreateSlider({Name = "Brake Force", Range = {0, 300}, Increment = 5, CurrentValue = 150, Flag = "velMult2", Callback = function(v) velocityMult2 = v/1000 end})
VehicleTab:CreateKeybind({Name = "Brake Key", CurrentKeybind = "S", Flag = "qbKey", Callback = function(k) qbEnabledKeyCode = Enum.KeyCode[k] end})
VehicleTab:CreateKeybind({Name = "Stop Key", CurrentKeybind = "P", Flag = "stopKey", Callback = function(k) stopKeyCode = Enum.KeyCode[k] end})
-- Ride Height Slider (Slammed vs Lifted)
VehicleTab:CreateSlider({
    Name = "Car Height (Stance)",
    Range = {1, 5},
    Increment = 0.1,
    CurrentValue = 2.5,
    Flag = "CarHeightFlag",
    Callback = function(Value)
        TuneSuspension("FreeLength", Value)
    end,
})

-- Stiffness Slider (Prevents bottoming out)
VehicleTab:CreateSlider({
    Name = "Suspension Stiffness",
    Range = {1000, 500000},
    Increment = 500,
    CurrentValue = 15000,
    Flag = "SuspensionStiffFlag",
    Callback = function(Value)
        TuneSuspension("Stiffness", Value)
    end,
})

local Locations = {
    ["Car Dealership"] = Vector3.new(8963.7138671875, 26.060230255126953, 3099.975341796875), -- Replace with actual SWFL coordinates
    ["Starblocks"] = Vector3.new(9518.466796875, 24.1849365234375, -4124.6904296875),
    ["Police Station"] = Vector3.new(5867.7529296875, 24.184932708740234, 610.9223022460938),
    ["Spawn"] = Vector3.new(-2449.219970703125, 25.059921264648438, -271.57598876953125),
    ["Sussys Mechanic"] = Vector3.new(9190.560546875, 24.182689666748047, -1318.718505859375)
}

local LocationNames = {}
for name, _ in pairs(Locations) do
    table.insert(LocationNames, name)
end

Tab:CreateDropdown({
    Name = "Teleport to Location",
    Options = LocationNames,
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Option)
        local targetPos = Locations[Option[1]]
        local player = game.Players.LocalPlayer
        if player and player.Character and targetPos then
            player.Character:MoveTo(targetPos)
        end
    end,
})

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local PlayerDropdown = Tab:CreateDropdown({
    Name = "Teleport to Player",
    Options = GetPlayerNames(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "PlayerTPDropdown",
    Callback = function(Option)
        local targetPlayer = game.Players:FindFirstChild(Option[1])
        if targetPlayer and targetPlayer.Character then
            local targetPivot = targetPlayer.Character:GetPivot()
            game.Players.LocalPlayer.Character:PivotTo(targetPivot)
        end
    end,
})

-- Auto-refresh the player list when someone joins or leaves
game.Players.PlayerAdded:Connect(function() PlayerDropdown:Refresh(GetPlayerNames(), true) end)
game.Players.PlayerRemoving:Connect(function() PlayerDropdown:Refresh(GetPlayerNames(), true) end)

local FullbrightEnabled = false
local Lighting = game:GetService("Lighting")

-- Save the game's original lighting defaults
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd

Tab:CreateToggle({
    Name = "Fullbright / Clear Vision",
    CurrentValue = false,
    Flag = "FullbrightFlag",
    Callback = function(Value)
        FullbrightEnabled = Value
    end,
})

task.spawn(function()
    while task.wait(1) do
        if FullbrightEnabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14 -- Forces local time to 2:00 PM
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = true
        end
    end
end)

local function GetPlayerNames()
    local names = {"LocalPlayer"}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local SpectateDropdown = Tab:CreateDropdown({
    Name = "Spectate Player Camera",
    Options = GetPlayerNames(),
    CurrentOption = "LocalPlayer",
    MultipleOptions = false,
    Flag = "SpectateDropdownFlag",
    Callback = function(Option)
        local targetName = Option[1]
        local camera = workspace.CurrentCamera
        
        if targetName == "LocalPlayer" or not targetName then
            camera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        else
            local targetPlayer = game.Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character then
                local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    camera.CameraSubject = humanoid
                end
            end
        end
    end,
})


