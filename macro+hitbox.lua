 local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")
-- Settings initialization
getgenv().HitboxSize = Vector3.new(5, 5, 5)
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


local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")



-- Configuration

local GLITCH_FORCE = 200

local SHAKE_OFFSET = 1

local SLIPPERY_FACTOR = 0.03 -- Lower = More slippery/sliding

local DECAY_RATE = 0.92      -- How long the slide lasts after release

local isToggled = false

local isQHeld = false

local currentMomentum = Vector3.new(0, 0, 0)



-- Create Modern GUI

local screenGUII = Instance.new("ScreenGui", playerGui)

screenGUII.Name = "MacroGui"

screenGUII.ResetOnSpawn = false



local toggleButton = Instance.new("TextButton", screenGUII)

toggleButton.Size = UDim2.new(0, 120, 0, 50)

toggleButton.Position = UDim2.new(0.5, -60, 0.8, 0)

toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

toggleButton.Text = "MACRO: OFF"

toggleButton.Font = Enum.Font.GothamBold

toggleButton.TextSize = 16

toggleButton.BorderSizePixel = 0

Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 12)


local Players = game:GetService("Players")
local player = Players.LocalPlayer
local isToggled = false

-- Your IDs
local CUSTOM_IDS = {
    idle = "http://www.roblox.com/asset/?id=122257458498464",
    walk = "http://www.roblox.com/asset/?id=10921355261",
    run = "http://www.roblox.com/asset/?id=616163682",
    jump = "http://www.roblox.com/asset/?id=10921308158",
    fall = "http://www.roblox.com/asset/?id=10921307241"
}

local originalIDs = nil -- Stores originals once

local function setAnimations(useCustom)
    local char = player.Character
    if not char then return end
    local animate = char:WaitForChild("Animate", 5)
    if not animate then return end

    if useCustom then
        -- Save original IDs first time we turn it on
        if not originalIDs then
            originalIDs = {
                walk = animate.walk.WalkAnim.AnimationId,
                run = animate.run.RunAnim.AnimationId,
                jump = animate.jump.JumpAnim.AnimationId,
                fall = animate.fall.FallAnim.AnimationId,
                idle1 = animate.idle.Animation1.AnimationId,
                idle2 = animate.idle.Animation2.AnimationId
            }
        end
        -- Apply Custom
        animate.walk.WalkAnim.AnimationId = CUSTOM_IDS.walk
        animate.run.RunAnim.AnimationId = CUSTOM_IDS.run
        animate.jump.JumpAnim.AnimationId = CUSTOM_IDS.jump
        animate.fall.FallAnim.AnimationId = CUSTOM_IDS.fall
        if animate:FindFirstChild("idle") then
            animate.idle.Animation1.AnimationId = CUSTOM_IDS.idle
            animate.idle.Animation2.AnimationId = CUSTOM_IDS.idle
        end
    elseif originalIDs then
        -- Revert to Original
        animate.walk.WalkAnim.AnimationId = originalIDs.walk
        animate.run.RunAnim.AnimationId = originalIDs.run
        animate.jump.WalkAnim.AnimationId = originalIDs.jump -- Fixed typo
        animate.fall.FallAnim.AnimationId = originalIDs.fall
        if animate:FindFirstChild("idle") then
            animate.idle.Animation1.AnimationId = originalIDs.idle1
            animate.idle.Animation2.AnimationId = originalIDs.idle2
        end
    end
end

-- THIS IS THE FIX: This runs every time you respawn
player.CharacterAdded:Connect(function()
    if isToggled then
        task.wait(0.5) -- Small delay to ensure animations load
        setAnimations(true)
    end
end)

-- Toggle Button Logic
toggleButton.MouseButton1Click:Connect(function()
    isToggled = not isToggled
    toggleButton.Text = isToggled and "MACRO: ON" or "MACRO: OFF"
    toggleButton.BackgroundColor3 = isToggled and Color3.fromRGB(75, 181, 67) or Color3.fromRGB(40, 40, 40)
    
    getgenv().Enabled = isToggled
    
    if isToggled then
        setAnimations(true)
    else
        for _, p in ipairs(Players:GetPlayers()) do resetHitbox(p) end
        setAnimations(false)
    end
end)



-- Track Q key for PC

UserInputService.InputBegan:Connect(function(input, gpe)

    if gpe then return end

    if input.KeyCode == Enum.KeyCode.Q then isQHeld = true end

end)

UserInputService.InputEnded:Connect(function(input)

    if input.KeyCode == Enum.KeyCode.Q then isQHeld = false end

end)



-- Main Loop

RunService.RenderStepped:Connect(function()

    local character = player.Character

    local humanoid = character and character:FindFirstChild("Humanoid")

    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

   

    if not humanoid or not rootPart or humanoid.Health <= 0 then return end



    local moveDir = humanoid.MoveDirection

    local isMovingForward = moveDir.Magnitude > 0

   

    -- Activation: Mobile (Auto) vs PC (Hold Q)

    local shouldMacro = isToggled and isMovingForward and (UserInputService.TouchEnabled or isQHeld)



        if shouldMacro then

        -- Apply "Glitchy" Movement without breaking Camera

        local randomShake = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * SHAKE_OFFSET

       

        -- Use BodyGyro or just adjust the CFrame slightly differently

        -- By setting the CFrame's LookVector only and keeping the UpVector,

        -- we allow the camera to keep control.

        local targetLook = (moveDir + randomShake).Unit

        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + targetLook)



        -- Slippery Acceleration

        local targetVelocity = moveDir * GLITCH_FORCE

        currentMomentum = currentMomentum:Lerp(targetVelocity, SLIPPERY_FACTOR)

       

        rootPart.AssemblyLinearVelocity = Vector3.new(

            currentMomentum.X,

            rootPart.AssemblyLinearVelocity.Y,

            currentMomentum.Z

        )

    else



        -- Decay momentum for the "Tiny Slide" effect when stopping

        currentMomentum = currentMomentum * DECAY_RATE

        if currentMomentum.Magnitude > 0.1 then

            rootPart.AssemblyLinearVelocity = Vector3.new(

                currentMomentum.X,

                rootPart.AssemblyLinearVelocity.Y,

                currentMomentum.Z

            )

        end

    end

end)
