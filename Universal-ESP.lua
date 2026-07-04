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
