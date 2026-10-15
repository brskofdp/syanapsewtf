--[[
    Exemple.lua - Example usage of the UI Library
    
    INSTRUCTIONS:
    1. Upload source.lua to GitHub (raw.githubusercontent.com/username/repo/main/source.lua)
    2. Replace YOUR_GITHUB_RAW_URL below with your actual raw GitHub link
    3. Run this script in your Roblox executor (Synapse X, Script Ware, etc.)
]]

-- // Load UI Library from GitHub Raw Link
-- Replace this URL with your own GitHub raw link to source.lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/brskofdp/syanapsewtf/refs/heads/main/source.lua", true))()

-- // Create Window
local window = UI:window({
    Name = "My Script UI",
    Size = UDim2.new(0, 700, 0, 450),
})

-- // Create Tabs
local tabs = {
    combat = window:tabs({ name = "Combat", scrollable = true, icon = "http://www.roblox.com/asset/?id=101187718648966", size = UDim2.new(0, 22, 0, 25) }),
    visuals = window:tabs({ name = "Visuals", scrollable = true, icon = "http://www.roblox.com/asset/?id=7035631382", size = UDim2.new(0, 28, 0, 31) }),
    misc = window:tabs({ name = "Misc", scrollable = true, icon = "http://www.roblox.com/asset/?id=484211948", size = UDim2.new(0, 28, 0, 28) }),
    settings = window:tabs({ name = "Settings", scrollable = false, icon = "http://www.roblox.com/asset/?id=11663743444", size = UDim2.new(0, 28, 0, 28) }),
}

-- // Shortcut references to tabs
local combat = tabs.combat
local visuals = tabs.visuals
local misc = tabs.misc
local settings = tabs.settings

-- // ===== COMBAT TAB =====
do
    local aimbot = combat:section({ name = "Aimbot", side = "left" })
    
    aimbot:toggle({
        name = "Enabled",
        description = "Enables aim assist",
        default = false,
        flag = "EnableAimbot",
        callback = function(state)
            print("Aimbot:", state)
        end
    })
    
    aimbot:toggle({
        name = "Wall Check",
        description = "Ignore hidden players",
        default = false,
        flag = "WallCheck",
    })
    
    aimbot:dropdown({
        name = "Target Bone",
        description = "Select target bone",
        options = {"Head", "UpperTorso", "LowerTorso"},
        default = "Head",
        flag = "AimbotBone",
    })
    
    aimbot:slider({
        name = "Max Distance",
        min = 100,
        max = 2500,
        default = 500,
        decimals = 0.1,
        suffix = "studs",
        flag = "AimbotDistance",
        callback = function(value)
            print("Max Distance:", value)
        end
    })
end

do
    local fov = combat:section({ name = "FOV", side = "center" })
    
    fov:toggle({
        name = "FOV Circle",
        default = false,
        flag = "EnableFOV",
    })
    
    fov:slider({
        name = "FOV Radius",
        min = 30,
        max = 750,
        default = 120,
        decimals = 1,
        suffix = "px",
        flag = "FOVRadius",
    })
    
    fov:colorpicker({
        name = "FOV Color",
        flag = "FOVColor",
        default = Color3.fromRGB(128, 128, 242),
        callback = function(color)
            print("FOV Color:", color)
        end
    })
end

do
    local trigger = combat:section({ name = "Trigger", side = "right" })
    
    trigger:toggle({
        name = "Autoshoot",
        default = false,
        flag = "AutoShoot",
    })
    
    trigger:keybind({
        name = "Autoshoot Key",
        flag = "AutoShootKey",
        default = Enum.KeyCode.V,
        mode = "Toggle",
        usekey = false,
    })
end

-- // ===== VISUALS TAB =====
do
    local esp = visuals:section({ name = "ESP", side = "left" })
    
    esp:toggle({
        name = "Enable ESP",
        default = false,
        flag = "EnableESP",
    })
    
    esp:toggle({
        name = "Names",
        default = false,
        flag = "ESPNames",
    })
    
    esp:toggle({
        name = "Distance",
        default = false,
        flag = "ESPDistance",
    })
    
    esp:toggle({
        name = "Boxes",
        default = false,
        flag = "ESPBoxes",
    })
    
    esp:toggle({
        name = "Chams",
        default = false,
        flag = "ESPChams",
    })
    
    esp:colorpicker({
        name = "ESP Color",
        flag = "ESPColor",
        default = Color3.fromRGB(255, 255, 255),
    })
end

do
    local world = visuals:section({ name = "World", side = "center" })
    
    world:toggle({
        name = "Ambience",
        default = false,
        flag = "WorldAmbience",
    })
    
    world:colorpicker({
        name = "Ambience Color",
        flag = "WorldColor",
        default = Color3.fromRGB(1, 1, 1),
    })
    
    world:toggle({
        name = "Full Bright",
        default = false,
        flag = "FullBright",
        callback = function(state)
            game:GetService("Lighting").Brightness = state and 3 or 1
            game:GetService("Lighting").ClockTime = state and 12 or 14
        end
    })
end

-- // ===== MISC TAB =====
do
    local character = misc:section({ name = "Character", side = "left" })
    
    character:toggle({
        name = "Noclip",
        default = false,
        flag = "Noclip",
    })
    
    character:keybind({
        name = "Noclip Key",
        flag = "NoclipKey",
        default = Enum.KeyCode.N,
        mode = "Toggle",
    })
    
    character:toggle({
        name = "Speed Hack",
        default = false,
        flag = "SpeedHack",
    })
    
    character:slider({
        name = "WalkSpeed",
        min = 16,
        max = 100,
        default = 16,
        suffix = "",
        flag = "WalkSpeedValue",
        callback = function(value)
            local char = game:GetService("Players").LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = value
            end
        end
    })
end

do
    local anti = misc:section({ name = "Anti", side = "right" })
    
    anti:toggle({
        name = "Anti Afk",
        default = false,
        flag = "AntiAfk",
    })
    
    anti:toggle({
        name = "Anti Fling",
        default = false,
        flag = "AntiFling",
    })
end

-- // ===== SETTINGS TAB =====
do
    local menu_section = settings:section({ name = "Menu", side = "left" })
    
    menu_section:keybind({
        name = "Menu Key",
        description = "Open/Close menu",
        flag = "MenuKey",
        default = Enum.KeyCode.Delete,
        mode = "Toggle",
        usekey = false,
        callback = function(key)
            print("Menu key:", key)
        end
    })
    
    menu_section:dropdown({
        name = "Theme",
        options = {"Default", "Fatality", "GameSense", "Quantum", "Blue"},
        default = "Default",
        flag = "UITheme",
        callback = function(theme)
            UI:LoadTheme(theme)
        end
    })
end

do
    local config_section = settings:section({ name = "Configs", side = "center" })
    
    config_section:button({
        name = "Save Config",
        callback = function()
            local config = UI:GetConfig()
            writefile("MyScriptConfig.txt", config)
            UI:Notification("Config saved!", 3, Color3.fromRGB(0, 255, 0))
        end
    })
    
    config_section:button({
        name = "Load Config",
        callback = function()
            if isfile("MyScriptConfig.txt") then
                local config = readfile("MyScriptConfig.txt")
                UI:LoadConfig(config)
                UI:Notification("Config loaded!", 3, Color3.fromRGB(0, 255, 0))
            else
                UI:Notification("No config found!", 3, Color3.fromRGB(255, 0, 0))
            end
        end
    })
end

-- // Initialize
UI:Notification("UI Library loaded successfully!", 3, Color3.fromRGB(0, 255, 0))
print("=== UI Example Loaded ===")
print("Flags table:", UI.flags)
