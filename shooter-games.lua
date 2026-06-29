local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({


    Title = 'Shooter Game Fucker',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})


local Tabs = {
   
    Main = Window:AddTab('Main'),
 
}


local visual = Tabs.Main:AddLeftGroupbox('visuals')
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local highlightsEnabled = false -- Initial state
local highlightFolder = {} -- To track highlights

local function updateHighlights(enabled)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			local highlight = player.Character:FindFirstChild("PlayerHighlight")
			if highlight then
				highlight.Enabled = enabled
			elseif enabled then
				-- Re-create if it was deleted
				local newHighlight = Instance.new("Highlight")
				newHighlight.Name = "PlayerHighlight"
				newHighlight.FillColor = Color3.fromRGB(255, 0, 4)
				newHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				newHighlight.FillTransparency = 0.5
				newHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				newHighlight.Parent = player.Character
			end
		end
	end
end

local function applyHighlight(player)
	player.CharacterAdded:Connect(function(character)
		local highlight = Instance.new("Highlight")
		highlight.Name = "PlayerHighlight"
		highlight.FillColor = Color3.fromRGB(255, 0, 4)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Enabled = highlightsEnabled -- Match current state
		highlight.Parent = character
	end)
end

-- Initialize for existing players
for _, player in pairs(Players:GetPlayers()) do
	applyHighlight(player)
	-- Create initial highlight
	if player.Character then
		local h = Instance.new("Highlight")
		h.Name = "PlayerHighlight"
		h.FillColor = Color3.fromRGB(255, 0, 4)
		h.OutlineColor = Color3.fromRGB(255, 255, 255)
		h.FillTransparency = 0.5
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = player.Character
	end
end

Players.PlayerAdded:Connect(applyHighlight)


visual:AddToggle('chams', {
    Text = 'Chams',
    Default = true, 
    Tooltip = 'chams', 

    Callback = function(Value)
      highlightsEnabled = Value
       updateHighlights(highlightsEnabled)
    end
})



visual:AddLabel('Chams Color'):AddColorPicker('ChamsColor', {
    Default = Color3.new(0, 1, 0), -- Bright green
    Title = 'Chams Color', -- Optional. Allows you to have a custom color picker title (when you open it)
    Transparency = 0, -- Optional. Enables transparency changing for this color picker (leave as nil to disable)

    Callback = function(Value)
        print('[cb] Color changed!', Value)
    end
})

