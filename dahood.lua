local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()


local Window = Library:CreateWindow({
    Title = "Da Hood",
    Footer = "version: V1",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tab = Window:AddTab("Main", "user")
local visuals = Tab:AddLeftGroupbox("Visuals")
local combat = Tab:AddRightGroupbox("Combat")
local players = Tab:AddLeftGroupbox("Player")

local ps = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = ps.LocalPlayer
local c = workspace.CurrentCamera

-- MASTER TOGGLES
getgenv().ChamsEnabled = false
getgenv().NameESPEnabled = false
getgenv().BoxESPEnabled = false

-- SHARED SETTINGS
local settings = {
    defaultcolor = Color3.fromRGB(255, 255, 255),
    teamcheck = false,
    teamcolor = false
}

-- MATH HELPER
local wtvp = function(...) 
    local a, b = c:WorldToViewportPoint(...) 
    return Vector2.new(a.X, a.Y), b, a.Z 
end

local espCache = {}

-- CORE CREATION FUNCTION
local function createEsp(p)
    if p == lp or espCache[p] then return end
    
    local data = {
        text = Drawing.new("Text"),
        box = Drawing.new("Square"),
        boxoutline = Drawing.new("Square")
    }

    -- Name Drawing Config
    data.text.Visible = false
    data.text.Center = true
    data.text.Size = 16.16
    data.text.Color = Color3.new(170,170,170)

    -- Box Drawing Config
    data.box.Thickness = 1
    data.box.Visible = false
    data.box.ZIndex = 2
    data.boxoutline.Thickness = 3
    data.boxoutline.Visible = false
    data.boxoutline.Color = Color3.new(0,0,0)

    espCache[p] = data
end

-- RENDER UPDATE
rs:BindToRenderStep("FinalESP", 200, function()
    for p, data in pairs(espCache) do
        local char = p.Character
        local head = char and char:FindFirstChild("Head")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Team Check Logic
        local isTeammate = settings.teamcheck and p.Team == lp.Team

        if char and head and hrp and not isTeammate then
            local pos, visible, depth = wtvp(hrp.Position)
            local headPos, headVisible = wtvp(head.Position)

            -- 1. CHAMS LOGIC
            local highlight = char:FindFirstChild("GlobalHighlight")
            if getgenv().ChamsEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight", char)
                    highlight.Name = "GlobalHighlight"
                end
                highlight.Enabled = true
                highlight.FillColor = settings.defaultcolor
            elseif highlight then
                highlight.Enabled = false
            end

            -- 2. NAME LOGIC
            if getgenv().NameESPEnabled and headVisible then
                data.text.Position = Vector2.new(headPos.X, headPos.Y - 27)
                data.text.Text = "[ " .. p.Name .. " ]"
                data.text.Visible = true
            else
                data.text.Visible = false
            end

            -- 3. BOX LOGIC
            if getgenv().BoxESPEnabled and visible then
                local scale = 1 / (depth * math.tan(math.rad(c.FieldOfView / 2)) * 2) * 1000
                local w, h = math.round(4 * scale), math.round(5 * scale)
                data.box.Size = Vector2.new(w, h)
                data.box.Position = Vector2.new(math.round(pos.X - w/2), math.round(pos.Y - h/2))
                data.box.Color = settings.teamcolor and p.TeamColor.Color or settings.defaultcolor
                data.box.Visible = true
                data.boxoutline.Size, data.boxoutline.Position = data.box.Size, data.box.Position
                data.boxoutline.Visible = true
            else
                data.box.Visible, data.boxoutline.Visible = false, false
            end
        else
            data.text.Visible = false
            data.box.Visible = false
            data.boxoutline.Visible = false
        end
    end
end)

-- BOOTSTRAP
for _, player in pairs(ps:GetPlayers()) do createEsp(player) end
ps.PlayerAdded:Connect(createEsp)
ps.PlayerRemoving:Connect(function(p) 
    if espCache[p] then 
        for _,v in pairs(espCache[p]) do v:Remove() end
        espCache[p] = nil 
    end 
end)

-- UI TOGGLES (Paste this part into your Window/Tab section)
visuals:AddToggle("Chams", { Text = "Chams", Default = false, Callback = function(v) getgenv().ChamsEnabled = v end })
visuals:AddToggle("Names", { Text = "Name ESP", Default = false, Callback = function(v) getgenv().NameESPEnabled = v end })
visuals:AddToggle("Boxes", { Text = "Box ESP", Default = false, Callback = function(v) getgenv().BoxESPEnabled = v end })
-- Services
local RunService = game:GetService("RunService");
local PlayersService = game:GetService("Players");

-- Variables
local Camera = workspace.CurrentCamera;
local Lines = {};
local Quads = {};
local Box3DEnabled = false -- Toggle Variable

-- Functions
local function HasCharacter(Player)
    return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= PlayersService.LocalPlayer;
end;

local function ClearDrawings()
    for i = 1, #Lines do
        local Line = rawget(Lines, i);
        if (Line) then Line:Remove(); end;
    end;
    Lines = {};

    for i = 1, #Quads do
        local Quad = rawget(Quads, i);
        if (Quad) then Quad:Remove(); end;
    end;
    Quads = {};
end

local function DrawQuad(PosA, PosB, PosC, PosD)
    local PosAScreen, PosAVisible = Camera:WorldToViewportPoint(PosA);
    local PosBScreen, PosBVisible = Camera:WorldToViewportPoint(PosB);
    local PosCScreen, PosCVisible = Camera:WorldToViewportPoint(PosC);
    local PosDScreen, PosDVisible = Camera:WorldToViewportPoint(PosD);

    if (not PosAVisible and not PosBVisible and not PosCVisible and not PosDVisible) then return; end;

    local Quad = Drawing.new("Quad");
    Quad.Thickness = .5;
    Quad.Color = Color3.fromRGB(255, 255, 255);
    Quad.Transparency = .25;
    Quad.Filled = true
    Quad.Visible = true;
    Quad.PointA = Vector2.new(PosAScreen.X, PosAScreen.Y);
    Quad.PointB = Vector2.new(PosBScreen.X, PosBScreen.Y);
    Quad.PointC = Vector2.new(PosCScreen.X, PosCScreen.Y);
    Quad.PointD = Vector2.new(PosDScreen.X, PosDScreen.Y);

    table.insert(Quads, Quad)
end

local function DrawLine(From, To)
    local FromScreen, FromVisible = Camera:WorldToViewportPoint(From);
    local ToScreen, ToVisible = Camera:WorldToViewportPoint(To);

    if (not FromVisible and not ToVisible) then return; end;

    local Line = Drawing.new("Line");
    Line.Thickness = 1;
    Line.From = Vector2.new(FromScreen.X, FromScreen.Y);
    Line.To = Vector2.new(ToScreen.X, ToScreen.Y);
    Line.Color = Color3.fromRGB(255, 255, 255);
    Line.Visible = true;

    table.insert(Lines, Line)
end

local function GetCorners(Part)
    local CF, Size, Corners = Part.CFrame, Part.Size / 2, {};
    for X = -1, 1, 2 do for Y = -1, 1, 2 do for Z = -1, 1, 2 do
        Corners[#Corners+1] = (CF * CFrame.new(Size * Vector3.new(X, Y, Z))).Position;      
    end; end; end;
    return Corners;
end;

local function DrawEsp(Player)
    local HRP = Player.Character.HumanoidRootPart;
    local CubeVertices = GetCorners({CFrame = HRP.CFrame * CFrame.new(0, -0.5, 0), Size = Vector3.new(3, 5, 3)});

    -- Bottom
    DrawLine(CubeVertices[1], CubeVertices[2]); DrawLine(CubeVertices[2], CubeVertices[6]);
    DrawLine(CubeVertices[6], CubeVertices[5]); DrawLine(CubeVertices[5], CubeVertices[1]);
    DrawQuad(CubeVertices[1], CubeVertices[2], CubeVertices[6], CubeVertices[5]);
    -- Sides
    DrawLine(CubeVertices[1], CubeVertices[3]); DrawLine(CubeVertices[2], CubeVertices[4]);
    DrawLine(CubeVertices[6], CubeVertices[8]); DrawLine(CubeVertices[5], CubeVertices[7]);
    DrawQuad(CubeVertices[2], CubeVertices[4], CubeVertices[8], CubeVertices[6]);
    DrawQuad(CubeVertices[1], CubeVertices[2], CubeVertices[4], CubeVertices[3]);
    DrawQuad(CubeVertices[1], CubeVertices[5], CubeVertices[7], CubeVertices[3]);
    DrawQuad(CubeVertices[5], CubeVertices[7], CubeVertices[8], CubeVertices[6]);
    -- Top
    DrawLine(CubeVertices[3], CubeVertices[4]); DrawLine(CubeVertices[4], CubeVertices[8]);
    DrawLine(CubeVertices[8], CubeVertices[7]); DrawLine(CubeVertices[7], CubeVertices[3]);
    DrawQuad(CubeVertices[3], CubeVertices[4], CubeVertices[8], CubeVertices[7]);
end;

-- Master Loop
RunService.RenderStepped:Connect(function()
    ClearDrawings() -- Always clear old drawings
    
    if Box3DEnabled then
        local Players = PlayersService:GetPlayers();
        for i = 1, #Players do
            local Player = rawget(Players, i);
            if HasCharacter(Player) then
                DrawEsp(Player);
            end;
        end;
    end
end);

-- Your GUI Toggle
visuals:AddToggle("Box3D", {
	Text = "3D Box ESP",
	Default = false,
	Callback = function(Value)
		Box3DEnabled = Value
        if not Value then
            ClearDrawings() -- Instant clear when toggled off
        end
	end,
})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Toggle Variable
local TracersEnabled = false

local espObjects = {}

-- Function to create ONLY the Tracer
local function createTracer(player)
    if player == LocalPlayer then return end
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.new(1, 1, 1)
    tracer.Thickness = 1.5
    tracer.Transparency = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp and TracersEnabled then
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                -- From: Bottom Center of Screen | To: Player Position
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
            -- If player leaves or character is destroyed, clean up
            if not character or not character.Parent and not TracersEnabled then
                tracer:Remove()
                connection:Disconnect()
            end
        end
    end)

    espObjects[player] = {
        tracer = tracer,
        connection = connection
    }
end

local function removeTracer(player)
    if espObjects[player] then
        if espObjects[player].tracer then espObjects[player].tracer:Remove() end
        if espObjects[player].connection then espObjects[player].connection:Disconnect() end
        espObjects[player] = nil
    end
end

-- Initialization
for _, player in pairs(Players:GetPlayers()) do
    createTracer(player)
end

Players.PlayerAdded:Connect(createTracer)
Players.PlayerRemoving:Connect(removeTracer)

-- Your GUI Toggle Integration
visuals:AddToggle("Tracers", {
    Text = "Tracers",
    Default = false,
    Callback = function(Value)
        TracersEnabled = Value
    end,
})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SkeletonSettings = {
    Color = Color3.new(1, 1, 1),
    Thickness = 2,
    Transparency = 1
}

-- Toggle Variable
local SkeletonEnabled = false

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local skeletons = {}

local function createLine()
    local line = Drawing.new("Line")
    return line
end

local function removeSkeleton(skeleton)
    for _, line in pairs(skeleton) do
        line:Remove()
    end
end

local function trackPlayer(plr)
    local skeleton = {}

    local function updateSkeleton()
        -- Added SkeletonEnabled check here
        if not SkeletonEnabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            for _, line in pairs(skeleton) do
                line.Visible = false
            end
            return
        end

        local character = plr.Character
        local humanoid = character:FindFirstChild("Humanoid")
        local joints = {}
        local connections = {}

        if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
            joints = {
                ["Head"] = character:FindFirstChild("Head"),
                ["UpperTorso"] = character:FindFirstChild("UpperTorso"),
                ["LowerTorso"] = character:FindFirstChild("LowerTorso"),
                ["LeftUpperArm"] = character:FindFirstChild("LeftUpperArm"),
                ["LeftLowerArm"] = character:FindFirstChild("LeftLowerArm"),
                ["LeftHand"] = character:FindFirstChild("LeftHand"),
                ["RightUpperArm"] = character:FindFirstChild("RightUpperArm"),
                ["RightLowerArm"] = character:FindFirstChild("RightLowerArm"),
                ["RightHand"] = character:FindFirstChild("RightHand"),
                ["LeftUpperLeg"] = character:FindFirstChild("LeftUpperLeg"),
                ["LeftLowerLeg"] = character:FindFirstChild("LeftLowerLeg"),
                ["RightUpperLeg"] = character:FindFirstChild("RightUpperLeg"),
                ["RightLowerLeg"] = character:FindFirstChild("RightLowerLeg"),
            }
            connections = {
                { "Head", "UpperTorso" },
                { "UpperTorso", "LowerTorso" },
                { "LowerTorso", "LeftUpperLeg" },
                { "LeftUpperLeg", "LeftLowerLeg" },
                { "LowerTorso", "RightUpperLeg" },
                { "RightUpperLeg", "RightLowerLeg" },
                { "UpperTorso", "LeftUpperArm" },
                { "LeftUpperArm", "LeftLowerArm" },
                { "LeftLowerArm", "LeftHand" },
                { "UpperTorso", "RightUpperArm" },
                { "RightUpperArm", "RightLowerArm" },
                { "RightLowerArm", "RightHand" },
            }
        elseif humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
            joints = {
                ["Head"] = character:FindFirstChild("Head"),
                ["Torso"] = character:FindFirstChild("Torso"),
                ["LeftLeg"] = character:FindFirstChild("Left Leg"),
                ["RightLeg"] = character:FindFirstChild("Right Leg"),
                ["LeftArm"] = character:FindFirstChild("Left Arm"),
                ["RightArm"] = character:FindFirstChild("Right Arm"),
            }
            connections = {
                { "Head", "Torso" },
                { "Torso", "LeftArm" },
                { "Torso", "RightArm" },
                { "Torso", "LeftLeg" },
                { "Torso", "RightLeg" },
            }
        end

        for index, connection in ipairs(connections) do
            local jointA = joints[connection[1]]
            local jointB = joints[connection[2]]

            if jointA and jointB then
                local posA, onScreenA = camera:WorldToViewportPoint(jointA.Position)
                local posB, onScreenB = camera:WorldToViewportPoint(jointB.Position)

                local line = skeleton[index] or createLine()
                skeleton[index] = line

                line.Color = SkeletonSettings.Color
                line.Thickness = SkeletonSettings.Thickness
                line.Transparency = SkeletonSettings.Transparency

                if onScreenA and onScreenB then
                    line.From = Vector2.new(posA.X, posA.Y)
                    line.To = Vector2.new(posB.X, posB.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            elseif skeleton[index] then
                skeleton[index].Visible = false
            end
        end
    end

    skeletons[plr] = skeleton

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if plr and plr.Parent then
            updateSkeleton()
        else
            removeSkeleton(skeleton)
            conn:Disconnect()
        end
    end)
end

local function untrackPlayer(plr)
    if skeletons[plr] then
        removeSkeleton(skeletons[plr])
        skeletons[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then trackPlayer(plr) end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then trackPlayer(plr) end
end)

Players.PlayerRemoving:Connect(untrackPlayer)

-- Your GUI Toggle Integration
visuals:AddToggle("SkeletonESP", {
    Text = "Skeleton ESP",
    Default = false,
    Callback = function(Value)
        SkeletonEnabled = Value
    end,
})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Toggle Variable
local DistanceEnabled = false

local distanceCache = {}

local function createDistance(p)
    if p == lp then return end
    
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 14
    text.Color = Color3.fromRGB(255, 255, 255)

    distanceCache[p] = text
end

local function removeDistance(p)
    if distanceCache[p] then
        distanceCache[p]:Remove()
        distanceCache[p] = nil
    end
end

-- Render Loop
RunService.RenderStepped:Connect(function()
    for p, text in pairs(distanceCache) do
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local lhrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

        if hrp and lhrp and DistanceEnabled then
            local pos, onscreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onscreen then
                -- Calculate Distance in Studs
                local dist = math.floor((lhrp.Position - hrp.Position).Magnitude)
                
                -- Position text below the player
                text.Position = Vector2.new(pos.X, pos.Y + 25)
                text.Text = tostring(dist) .. " studs"
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end
end)

-- Player Management
for _, player in pairs(Players:GetPlayers()) do createDistance(player) end
Players.PlayerAdded:Connect(createDistance)
Players.PlayerRemoving:Connect(removeDistance)

-- Your GUI Toggle Integration
visuals:AddToggle("DistanceESP", {
    Text = "Distance ESP",
    Default = false,
    Callback = function(Value)
        DistanceEnabled = Value
    end,
})

local UserInputService = game:GetService("UserInputService")

-- Global variable to hold the speed dynamically (default to a slow 2.5)
_G.FlySpeed = 2.5

local flyKeyDownConnect, flyKeyUpConnect

-- 1. Create the Fly Toggle
local FlyXToggle = players:AddToggle("FlyXToggle", {
    Text = "Fly (X)",
    Default = false,
    Callback = function(Value)
        local plr = game.Players.LocalPlayer
        local mouse = plr:GetMouse()
        local localplayer = plr

        if Value then
            if workspace:FindFirstChild("Core") then
                workspace.Core:Destroy()
            end

            local Core = Instance.new("Part")
            Core.Name = "Core"
            Core.Size = Vector3.new(0.05, 0.05, 0.05)

            task.spawn(function()
                Core.Parent = workspace
                local Weld = Instance.new("Weld", Core)
                Weld.Part0 = Core
                Weld.Part1 = localplayer.Character.LowerTorso
                Weld.C0 = CFrame.new(0, 0, 0)
            end)

            workspace:WaitForChild("Core")

            local torso = workspace.Core
            _G.FlyingActive = true
            
            local keys = {a = false, d = false, w = false, s = false}

            local function start()
                local pos = Instance.new("BodyPosition", torso)
                local gyro = Instance.new("BodyGyro", torso)
                pos.Name = "EPIXPOS"
                pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
                pos.position = torso.Position
                gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                gyro.cframe = torso.CFrame
                
                repeat
                    task.wait()
                    if localplayer.Character and localplayer.Character:FindFirstChild("Humanoid") then
                        localplayer.Character.Humanoid.PlatformStand = true
                    end
                    local new = gyro.cframe - gyro.cframe.p + pos.position
                    
                    -- Read the dynamic slider speed value instantly
                    local currentSpeed = _G.FlySpeed
                    
                    if not keys.w and not keys.s and not keys.a and not keys.d then
                        currentSpeed = math.max(0.5, _G.FlySpeed * 0.5) -- Slower drift when keys are released
                    end
                    
                    if keys.w then
                        new = new + workspace.CurrentCamera.CoordinateFrame.lookVector * currentSpeed
                    end
                    if keys.s then
                        new = new - workspace.CurrentCamera.CoordinateFrame.lookVector * currentSpeed
                    end
                    if keys.d then
                        new = new * CFrame.new(currentSpeed, 0, 0)
                    end
                    if keys.a then
                        new = new * CFrame.new(-currentSpeed, 0, 0)
                    end
                    
                    pos.position = new.p
                    gyro.cframe = workspace.CurrentCamera.CoordinateFrame
                until _G.FlyingActive == false or not torso or not torso.Parent
                
                if gyro then gyro:Destroy() end
                if pos then pos:Destroy() end
                if localplayer.Character and localplayer.Character:FindFirstChild("Humanoid") then
                    localplayer.Character.Humanoid.PlatformStand = false
                end
            end

            flyKeyDownConnect = mouse.KeyDown:Connect(function(key)
                if not torso or not torso.Parent then 
                    _G.FlyingActive = false 
                    if flyKeyDownConnect then flyKeyDownConnect:Disconnect() end
                    if flyKeyUpConnect then flyKeyUpConnect:Disconnect() end
                    return 
                end
                if key == "w" then keys.w = true
                elseif key == "s" then keys.s = true
                elseif key == "a" then keys.a = true
                elseif key == "d" then keys.d = true
                elseif key == "x" then
                    if FlyXToggle and FlyXToggle.SetValue then
                        FlyXToggle:SetValue(not FlyXToggle.Value)
                    end
                end
            end)

            flyKeyUpConnect = mouse.KeyUp:Connect(function(key)
                if key == "w" then keys.w = false
                elseif key == "s" then keys.s = false
                elseif key == "a" then keys.a = false
                elseif key == "d" then keys.d = false
                end
            end)

            start()
        else
            _G.FlyingActive = false
            if flyKeyDownConnect then flyKeyDownConnect:Disconnect() end
            if flyKeyUpConnect then flyKeyUpConnect:Disconnect() end
            if workspace:FindFirstChild("Core") then
                workspace.Core:Destroy()
            end
            local plr = game.Players.LocalPlayer
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.PlatformStand = false
            end
        end
    end,
})

-- 2. Create the Fly Speed Slider directly underneath the toggle
local FlySpeedSlider = players:AddSlider("FlySpeedSlider", {
    Text = "Fly Speed",
    Min = 0.5,          -- Lowest possible speed configuration
    Max = 20,           -- Highest possible speed configuration
    Default = 2.5,      -- Safe slow default speed
    Rounding = 1,       -- Rounds to 1 decimal place (e.g., 2.5, 3.2)
    Callback = function(Value)
        _G.FlySpeed = Value
    end,
})

-- 3. Ingame Keybind Trigger (X)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        if FlyXToggle and FlyXToggle.SetValue then
            FlyXToggle:SetValue(not FlyXToggle.Value)
        end
    end
end)


-- Settings initialization
getgenv().HitboxSize = Vector3.new(2, 2, 2)
getgenv().HitboxTransparency = 0.5 -- Default transparency
getgenv().TargetPart = "HumanoidRootPart"
getgenv().Enabled = false 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function resetHitbox(player)
    if player.Character then
        local targetPart = player.Character:FindFirstChild(getgenv().TargetPart)
        if targetPart and targetPart:IsA("BasePart") then
            targetPart.Size = Vector3.new(2, 2, 1)
            targetPart.Transparency = 1
        end
    end
end

local function updateHitbox(player)
    if getgenv().Enabled and player ~= LocalPlayer and player.Character then
        local targetPart = player.Character:FindFirstChild(getgenv().TargetPart)
        if targetPart and targetPart:IsA("BasePart") then
            targetPart.Size = getgenv().HitboxSize
            targetPart.CanCollide = false
            targetPart.Transparency = getgenv().HitboxTransparency -- Uses the global variable
        end
    end
end

-- Fast refresh loop
task.spawn(function()
    while true do
        if getgenv().Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                updateHitbox(player)
            end
        end
        task.wait(0.5) 
    end
end)

-- 1. Enable Toggle
combat:AddToggle("HitboxToggle", {
    Text = "Enable Hitbox",
    Default = false,
    Callback = function(Value)
        getgenv().Enabled = Value
        if not Value then
            for _, player in ipairs(Players:GetPlayers()) do
                resetHitbox(player)
            end
        end
    end,
})

-- 2. Size Slider
combat:AddSlider("HitboxSizeSlider", {
    Text = "Hitbox Size",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        getgenv().HitboxSize = Vector3.new(Value, Value, Value)
    end,
})

-- 3. Transparency Slider
combat:AddSlider("HitboxTransSlider", {
    Text = "Hitbox Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 1, -- Set to 1 or 2 for decimals like 0.55
    Callback = function(Value)
        getgenv().HitboxTransparency = Value
    end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Global Settings
getgenv().Multiplier = 0.02
getgenv().CFrameSpeedEnabled = false

-- 1. CFrame Guns FIX Function
local function ApplyGunsFix()
    local character = lp.Character or lp.CharacterAdded:Wait()
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
            v:Destroy()
        end
    end
end

-- 2. Master Speed Loop
RunService.Stepped:Connect(function()
    if getgenv().CFrameSpeedEnabled then
        local character = lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")

        if hrp and humanoid and humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * getgenv().Multiplier)
        end
    end
end)


local UserInputService = game:GetService("UserInputService")

-- 1. Create your toggle
local SpeedToggle = players:AddToggle("CFrameSpeedToggle", {
    Text = "Speed (C)",
    Default = false,
    Callback = function(Value)
        getgenv().CFrameSpeedEnabled = Value
    end,
})



-- 2. Toggle the value using :SetValue() on keypress
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.C then
        if SpeedToggle and SpeedToggle.SetValue then
            -- Read the current value and invert it inside :SetValue()
            SpeedToggle:SetValue(not SpeedToggle.Value)
        end
    end
end)



-- Speed Slider
players:AddSlider("SpeedSlider", {
    Text = "Speed Multiplier",
    Default = 0.02,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Callback = function(Value)
        getgenv().Multiplier = Value
    end,
})

repeat task.wait() until game:IsLoaded()

local Optimized = true
local AllHookProperty = {false, false, false}

local AbyssSettings = {
    Loaded = false,
    NoRotation = {
        Enabled = false
    },
    SpeedGlitch = {
        Enabled = false,
        SpeedMultiplier = 8
    },
    Disabler = {
        CFrameDetection = false,
        Ban = false,
        Crash = false
    }
}

local AbyssStorage = {
    GetStrafeAngle = 0,
    Side = "Right",
    StoredRange = 10,
    HeldSpace = false,
    GetPrediction = 0.165,
    Instance = {},
    Equipable = false,
    FPSBeat = 0,
    GetTime = 0,
    Macro = false,
    Angle = 0 
}

local Service = setmetatable({}, {
    __index = function(t, k)
        return game:GetService(k)
    end
})

local RunService = Service.RunService
local Players = Service.Players
local LocalPlayer = Players.LocalPlayer
local UIs = Service.UserInputService
local CurrentCamera = workspace.CurrentCamera

local IsNetwork = function(GetPlayer)
    return GetPlayer and GetPlayer.Character and GetPlayer.Character:FindFirstChild("HumanoidRootPart") ~= nil and GetPlayer.Character:FindFirstChild("Humanoid") ~= nil and GetPlayer.Character:FindFirstChild("Head") ~= nil and true or false
end

-- UI Setup
local FakeMacro = players:AddToggle("FakeMacro", {
    Text = "Legit Macro (Q)",
    Default = false,
    Callback = function(State)
        AbyssSettings.SpeedGlitch.Enabled = State
    end,
})

players:AddSlider("FakeMacroS", {
    Text = "Macro Speed",
    Default = 180,  
    Min = 100,      
    Max = 250,      
    Rounding = 0,    
    Callback = function(State)
        AbyssSettings.SpeedGlitch.SpeedMultiplier = State
    end,
})

-- [REMOVED UIs.InputBegan AND InputEnded EVENT LISTENERS]

-- Heartbeat loop
RunService.Heartbeat:Connect(function()
    if IsNetwork(LocalPlayer) then
        
        -- REAL-TIME CHECK: Dynamically updates AbyssStorage.Macro by checking if 'Q' is physically held down
        -- Also checks if the player is typing in chat (GetFocusedTextBox) to prevent macroing while talking
        if UIs:IsKeyDown(Enum.KeyCode.Q) and not UIs:GetFocusedTextBox() then
            AbyssStorage.Macro = true
        else
            AbyssStorage.Macro = false
        end

        if AbyssSettings.SpeedGlitch.Enabled and AbyssStorage.Macro then
            if LocalPlayer.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                local CamLook = CurrentCamera.CFrame.lookVector
                local FlatDirection = Vector3.new(CamLook.X, 0, CamLook.Z).Unit
                
                LocalPlayer.Character.HumanoidRootPart.Velocity = FlatDirection * AbyssSettings.SpeedGlitch.SpeedMultiplier
                
                if AbyssStorage.Angle == 1 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(45), 0)
                    AbyssStorage.Angle = 0
                else
                    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(-45), 0)
                    AbyssStorage.Angle = 1
                end
            end
        end

        if not AbyssStorage.Macro then
            if AbyssSettings.NoRotation.Enabled then
                LocalPlayer.Character.Humanoid.AutoRotate = false
            else
                LocalPlayer.Character.Humanoid.AutoRotate = true
            end
        end
    end       
end)

-- Anti-cheat Bypass / Namecall Hook
local HookNamecall
HookNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Args = {...}
    local Method = getnamecallmethod()

    if tostring(self) == "MainEvent" and tostring(Method) == "FireServer" then
        if Args[1] == "CHECKER_1" or Args[1] == "OneMoreTime" then
            if AbyssSettings.Disabler.Ban then
                AllHookProperty[1] = true
            end
            return
        end
        if Args[1] == "TeleportDetect" then
            if AbyssSettings.Disabler.CFrameDetection then
                AllHookProperty[2] = true
            end
            return
        end
    elseif getfenv(2).crash then
        hookfunction(getfenv(2).crash, function()
            if AbyssSettings.Disabler.Crash then
                AllHookProperty[3] = true
            end
            return
        end)
    end

    return HookNamecall(self, ...)
end)

-- AutoRotate flipper thread
task.spawn(function()
    while task.wait(0.05) do
        if AbyssSettings.SpeedGlitch.Enabled and AbyssStorage.Macro then
            LocalPlayer.Character.Humanoid.AutoRotate = not LocalPlayer.Character.Humanoid.AutoRotate
        end
    end
end)

Library:Notify({
    Title = "Da Hood Script",
    Description = "script has succesfully loaded, RightCTRL To Close!",
    Time = 10,
})
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Ignore the keypress if you are actively typing in the chat
    if gameProcessed then return end
    
    -- Detect when Right Control is pressed
    if input.KeyCode == Enum.KeyCode.RightControl then
        -- Find the Obsidian UI container inside CoreGui safely
        local ObsidianUI = game:GetService("CoreGui"):FindFirstChild("HiddenUI") 
            and game:GetService("CoreGui").HiddenUI:FindFirstChild("Obsidian")
            
        if ObsidianUI and ObsidianUI:IsA("ScreenGui") then
            -- Flip the visibility state (true becomes false, false becomes true)
            ObsidianUI.Enabled = not ObsidianUI.Enabled
        end
    end
end)
