--[[
    UI Library - Synapse Style
    Source file for GitHub hosting
    Load via: loadstring(game:HttpGet("YOUR_GITHUB_RAW_URL"))()
]]

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

-- // Local Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local ViewportSize = Camera.ViewportSize

-- // Helpers
local UDim2_new = UDim2.new
local UDim_new = UDim.new
local Vector2_new = Vector2.new
local Color3_fromRGB = Color3.fromRGB
local Color3_new = Color3.new
local Instance_new = Instance.new
local math_floor = math.floor
local math_clamp = math.clamp
local math_tan = math.tan
local math_rad = math.rad
local table_insert = table.insert
local string_format = string.format

-- // Themes
local Themes = {
    Default = {
        accent = Color3_fromRGB(128, 128, 242),
        risky = Color3_fromRGB(200, 0, 0),
        background = Color3_fromRGB(36, 36, 36),
        outline = Color3_fromRGB(45, 45, 45),
        active = Color3_fromRGB(255, 255, 255),
        inactive = Color3_fromRGB(128, 128, 128),
    },
    Fatality = {
        accent = Color3_fromRGB(130, 0, 69),
        risky = Color3_fromRGB(200, 0, 0),
        background = Color3_fromRGB(36, 36, 36),
        outline = Color3_fromRGB(45, 45, 45),
        active = Color3_fromRGB(255, 255, 255),
        inactive = Color3_fromRGB(120, 120, 120),
    },
    GameSense = {
        accent = Color3_fromRGB(180, 228, 128),
        risky = Color3_fromRGB(200, 0, 0),
        background = Color3_fromRGB(36, 36, 36),
        outline = Color3_fromRGB(45, 45, 45),
        active = Color3_fromRGB(255, 255, 255),
        inactive = Color3_fromRGB(120, 120, 120),
    },
    Quantum = {
        accent = Color3_fromRGB(195, 0, 0),
        risky = Color3_fromRGB(200, 0, 0),
        background = Color3_fromRGB(36, 36, 36),
        outline = Color3_fromRGB(45, 45, 45),
        active = Color3_fromRGB(255, 255, 255),
        inactive = Color3_fromRGB(120, 120, 120),
    },
    Blue = {
        accent = Color3_fromRGB(0, 190, 255),
        risky = Color3_fromRGB(200, 0, 0),
        background = Color3_fromRGB(36, 36, 36),
        outline = Color3_fromRGB(45, 45, 45),
        active = Color3_fromRGB(255, 255, 255),
        inactive = Color3_fromRGB(120, 120, 120),
    },
}

-- // UI Library Table
local UI = {
    autoload = true,
    font = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
    font_size = 12,
    ui_key = Enum.KeyCode.Delete,
    currentTheme = "Default",
    themes = Themes,
    flags = {},
    pages = {},
    sections = {},
    instancemap = {},
    notifications = {},
    un_named_flags = 0,
    page_amount = 0,
    language = "English",
    shared = { initialized = false, fps = 0, ping = 0 },
    holder = nil,
}

UI.__index = UI

-- // Theme Functions
function UI:LoadTheme(themeName)
    if self.themes[themeName] then
        self.currentTheme = themeName
        for obj, data in pairs(self.instancemap) do
            UI:AttachTheme(obj, data.Properties)
        end
    end
end

function UI:AttachTheme(obj, props)
    local activeTheme = self.currentTheme or "Default"
    self.instancemap[obj] = { Instance = obj, Properties = props }

    for property, themeKey in pairs(props) do
        if self.themes[activeTheme] and self.themes[activeTheme][themeKey] then
            local targetValue = self.themes[activeTheme][themeKey]
            if property == "ImageColor3" or property == "TextColor3" or property == "ScrollBarImageColor3" then
                if obj[property] ~= targetValue then
                    TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                        [property] = targetValue
                    }):Play()
                end
            else
                obj[property] = targetValue
            end
        end
    end
end

function UI:GetSelectedThemeAndAccent()
    local activeTheme = self.currentTheme or "Default"
    local accentColor = self.themes[activeTheme].accent
    return activeTheme, accentColor
end

-- // Flag Helpers
function UI.next_flag()
    UI.un_named_flags = UI.un_named_flags + 1
    return string.format("%.14g", UI.un_named_flags)
end

function UI:RGBA(r, g, b, alpha)
    local rgb = Color3_fromRGB(r, g, b)
    local mt = table.clone(getrawmetatable(rgb))
    setreadonly(mt, false)
    local old = mt.__index
    mt.__index = newcclosure(function(self, key)
        if key:lower() == "transparency" then
            return alpha
        end
        return old(self, key)
    end)
    setrawmetatable(rgb, mt)
    return rgb
end

-- // Config Save/Load
function UI:GetConfig()
    local Config = ""
    for Index, Value in pairs(self.flags) do
        if Index ~= "ConfigConfig_List" and Index ~= "ConfigConfig_Load" and Index ~= "ConfigConfig_Save" then
            local Value2 = Value
            local Final = ""
            if typeof(Value2) == "Color3" then
                local hue, sat, val = Value2:ToHSV()
                Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, 1)
            elseif typeof(Value2) == "table" and Value2.Color and Value2.Transparency then
                local hue, sat, val = Value2.Color:ToHSV()
                Final = ("rgb(%s,%s,%s,%s)"):format(hue, sat, val, Value2.Transparency)
            elseif typeof(Value2) == "table" and Value2.Mode then
                local Values = Value2.current
                Final = ("key(%s,%s,%s)"):format(Values[1] or "nil", Values[2] or "nil", Value2.Mode)
            elseif Value2 ~= nil then
                if typeof(Value2) == "boolean" then
                    Value2 = ("bool(%s)"):format(tostring(Value2))
                elseif typeof(Value2) == "table" then
                    local New = "table("
                    for _, Value3 in pairs(Value2) do
                        New = New .. Value3 .. ","
                    end
                    if New:sub(#New) == "," then
                        New = New:sub(0, #New - 1)
                    end
                    Value2 = New .. ")"
                elseif typeof(Value2) == "string" then
                    Value2 = ("string(%s)"):format(Value2)
                elseif typeof(Value2) == "number" then
                    Value2 = ("number(%s)"):format(Value2)
                end
                Final = Value2
            end
            Config = Config .. Index .. ": " .. tostring(Final) .. "\n"
        end
    end
    return Config
end

function UI:LoadConfig(Config)
    local Table = string.split(Config, "\n")
    local Table2 = {}
    for _, Value in pairs(Table) do
        local Table3 = string.split(Value, ":")
        if Table3[1] ~= "ConfigConfig_List" and #Table3 >= 2 then
            local Value = Table3[2]:sub(2, #Table3[2])
            if Value:sub(1, 3) == "rgb" then
                local Table4 = string.split(Value:sub(5, #Value - 1), ",")
                Value = Table4
            elseif Value:sub(1, 3) == "key" then
                local Table4 = string.split(Value:sub(5, #Value - 1), ",")
                if Table4[1] == "nil" and Table4[2] == "nil" then
                    Table4[1] = nil
                    Table4[2] = nil
                end
                Value = Table4
            elseif Value:sub(1, 4) == "bool" then
                local Bool = Value:sub(6, #Value - 1)
                Value = Bool == "true"
            elseif Value:sub(1, 5) == "table" then
                local Table4 = string.split(Value:sub(7, #Value - 1), ",")
                Value = Table4
            elseif Value:sub(1, 6) == "string" then
                local String = Value:sub(8, #Value - 1)
                Value = String
            elseif Value:sub(1, 6) == "number" then
                local Number = tonumber(Value:sub(8, #Value - 1))
                Value = Number
            end
            Table2[Table3[1]] = Value
        end
    end
    for i, v in pairs(Table2) do
        if flags[i] then
            if typeof(flags[i]) == "table" then
                flags[i]:Set(v)
            else
                flags[i](v)
            end
        end
    end
end

function UI:IsMouseOverFrame(Frame)
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
        return true
    end
    return false
end

-- // Notification System
function UI:Notification(message, duration, color)
    duration = duration or 5
    color = color or Color3_fromRGB(255, 255, 255)
    
    local notification = { Objects = {} }
    local notif_ui = Instance_new("ScreenGui")
    notif_ui.Name = "notification"
    notif_ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notif_ui.IgnoreGuiInset = true
    notif_ui.Parent = CoreGui
    
    local base_position = Vector2.new(25, 65 + (#UI.notifications * 25))
    
    local notifcontainer = Instance_new("Frame")
    notifcontainer.Name = "container"
    notifcontainer.Position = UDim2_new(0, base_position.X, 0, base_position.Y)
    notifcontainer.AutomaticSize = Enum.AutomaticSize.X
    notifcontainer.Size = UDim2_new(0, 0, 0, 18)
    notifcontainer.BackgroundTransparency = 1
    notifcontainer.BorderSizePixel = 0
    notifcontainer.ZIndex = 99999999
    notifcontainer.Parent = notif_ui
    notification.Container = notifcontainer
    
    local outline = Instance_new("Frame")
    outline.Name = "outline"
    outline.AutomaticSize = Enum.AutomaticSize.X
    outline.BorderColor3 = Color3_fromRGB(0, 0, 0)
    outline.Position = UDim2_new(0.01, 0, 0.02, 0)
    outline.Size = UDim2_new(0, 0, 0, 18)
    outline.Parent = notifcontainer
    outline.BackgroundTransparency = 1
    table.insert(notification.Objects, outline)
    UI:AttachTheme(outline, { BackgroundColor3 = "background" })
    
    local inline = Instance_new("Frame")
    inline.Name = "inline"
    inline.BackgroundColor3 = Color3_fromRGB(5, 5, 5)
    inline.BorderColor3 = Color3_fromRGB(0, 0, 0)
    inline.BorderSizePixel = 0
    inline.Position = UDim2_new(0, 1, 0, 0)
    inline.Size = UDim2_new(1, 0, 1, -1)
    inline.BackgroundTransparency = 1
    inline.Parent = outline
    table.insert(notification.Objects, inline)
    UI:AttachTheme(inline, { BackgroundColor3 = "background" })
    
    local value = Instance_new("TextLabel")
    value.Name = "text"
    value.Text = message
    value.TextColor3 = Color3_fromRGB(255, 255, 255)
    value.TextStrokeTransparency = 0
    value.TextXAlignment = Enum.TextXAlignment.Left
    value.AutomaticSize = Enum.AutomaticSize.X
    value.BackgroundTransparency = 1
    value.Size = UDim2_new(0, 0, 1, 0)
    value.TextTransparency = 1
    value.Parent = inline
    value.FontFace = UI.font
    value.TextSize = UI.font_size
    table.insert(notification.Objects, value)
    
    local uipadding = Instance_new("UIPadding")
    uipadding.PaddingLeft = UDim_new(0, 5)
    uipadding.PaddingRight = UDim_new(0, 5)
    uipadding.PaddingTop = UDim_new(0, 1)
    uipadding.Parent = value
    
    local time_line = Instance_new("Frame")
    time_line.Name = "timeline"
    time_line.BorderSizePixel = 0
    time_line.Size = UDim2_new(0, 0, 1, 0)
    time_line.Parent = outline
    time_line.BackgroundTransparency = 1
    time_line.BackgroundColor3 = color
    time_line.ZIndex = -1
    table.insert(notification.Objects, time_line)
    
    function notification:remove()
        local index = table.find(UI.notifications, notification)
        if index then
            for _, v in ipairs(notification.Objects) do
                if v:IsA("Frame") or v:IsA("ImageLabel") then
                    TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                elseif v:IsA("TextLabel") then
                    TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
                end
            end
            task.wait(0.5)
            table.remove(UI.notifications, index)
            notif_ui:Destroy()
            
            for i = index, #UI.notifications do
                local notif = UI.notifications[i]
                local newPosition = UDim2_new(0, base_position.X, 0, base_position.Y + (i - 1) * 25)
                TweenService:Create(notif.Container, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPosition}):Play()
            end
        end
    end
    
    task.spawn(function()
        outline.AnchorPoint = Vector2.new(1, 0)
        for _, v in next, notification.Objects do
            if v:IsA("Frame") or v:IsA("ImageLabel") then
                TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
            end
        end
        TweenService:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {AnchorPoint = Vector2.new(0, 0)}):Play()
        TweenService:Create(value, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        TweenService:Create(time_line, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2_new(1, 0, 1, 0)}):Play()
        task.wait(duration)
        notification:remove()
    end)
    
    table.insert(UI.notifications, notification)
    return notification
end

-- // Color Picker
function UI:NewPicker(name, default, defaultalpha, parent, count, flag, callback)
    local Icon = Instance_new("TextButton")
    local color_name = Instance_new("TextLabel")
    local Outline4 = Instance_new("Frame")
    local ColorWindow = Instance_new("Frame")
    local ColorInline = Instance_new("Frame")
    local Color = Instance_new("TextButton")
    local Sat = Instance_new("ImageLabel")
    local Val = Instance_new("ImageLabel")
    local Hue = Instance_new("ImageButton")
    local Alpha = Instance_new("ImageButton")
    local Color_Circle = Instance_new("TextButton")
    local Alpha_Bg = Instance_new("ImageLabel")
    local text_color = Instance_new("TextButton")
    local text_color2 = Instance_new("TextButton")
    
    Icon.Name = "Icon_Colorpicker"
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundColor3 = default
    Icon.BorderColor3 = Color3_fromRGB(36, 36, 36)
    Icon.BorderSizePixel = 1
    local spacing = 3
    if count == 1 then
        Icon.Position = UDim2_new(1, -(count * 18), 0.5, 0)
    else
        Icon.Position = UDim2_new(1, -(count * 16) - (count * spacing), 0.5, 0)
    end
    Icon.Size = UDim2_new(0, 16, 0, 16)
    Icon.Text = ""
    Icon.ZIndex = 99
    Icon.AutoButtonColor = false
    Icon.Parent = parent
    
    Instance_new("UICorner", { Parent = Icon, CornerRadius = UDim_new(1, 0) })
    
    Outline4.Name = "Outline"
    Outline4.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    Outline4.BackgroundTransparency = 1
    Outline4.BorderColor3 = Color3_fromRGB(0, 0, 0)
    Outline4.BorderSizePixel = 0
    Outline4.Position = UDim2_new(0, -1, 0, -1)
    Outline4.Size = UDim2_new(1, 2, 1, 2)
    Outline4.ZIndex = 99
    Outline4.Parent = Icon
    
    ColorWindow.Name = "ColorWindow"
    ColorWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    ColorWindow.BorderColor3 = Color3_fromRGB(0, 0, 0)
    ColorWindow.Position = UDim2_new(1, 0, 1, 2)
    ColorWindow.AnchorPoint = Vector2.new(1, 0)
    ColorWindow.Size = UDim2_new(0, 180, 0, 220)
    ColorWindow.ZIndex = 99
    ColorWindow.Visible = false
    ColorWindow.Parent = Icon
    UI:AttachTheme(ColorWindow, { BackgroundColor3 = "outline" })
    Instance_new("UICorner", { Parent = ColorWindow, CornerRadius = UDim_new(0, 6) })
    
    ColorInline.Name = "ColorInline"
    ColorInline.BorderColor3 = Color3_fromRGB(0, 0, 0)
    ColorInline.BorderSizePixel = 0
    ColorInline.Position = UDim2_new(0, 1, 0, 1)
    ColorInline.Size = UDim2_new(1, -2, 1, -2)
    ColorInline.BackgroundTransparency = 1
    ColorInline.Parent = ColorWindow
    UI:AttachTheme(ColorInline, { BackgroundColor3 = "background" })
    Instance_new("UICorner", { Parent = ColorInline, CornerRadius = UDim_new(0, 6) })
    
    color_name.BackgroundTransparency = 1
    color_name.Text = name
    color_name.TextXAlignment = Enum.TextXAlignment.Left
    color_name.TextColor3 = Color3_fromRGB(255, 255, 255)
    color_name.Position = UDim2_new(0, 8, 0, 5)
    color_name.Size = UDim2_new(1, -10, 0, 20)
    color_name.TextSize = UI.font_size
    color_name.FontFace = UI.font
    color_name.TextStrokeTransparency = 0
    color_name.Parent = ColorInline
    
    text_color.Name = "Text Color"
    text_color.FontFace = UI.font
    text_color.TextColor3 = Color3_fromRGB(155, 155, 155)
    text_color.Parent = ColorInline
    text_color.TextStrokeTransparency = 0
    text_color.TextSize = UI.font_size
    text_color.AutoButtonColor = false
    text_color.Position = UDim2_new(0, 7, 1, -17)
    text_color.Size = UDim2_new(0, 76, 0, 12)
    UI:AttachTheme(text_color, { BackgroundColor3 = "background" })
    UI:AttachTheme(text_color, { BorderColor3 = "outline" })
    
    text_color2.Name = "Text Color 2"
    text_color2.FontFace = UI.font
    text_color2.TextColor3 = Color3_fromRGB(155, 155, 155)
    text_color2.Parent = ColorInline
    text_color2.TextStrokeTransparency = 0
    text_color2.TextSize = UI.font_size
    text_color2.AutoButtonColor = false
    text_color2.Position = UDim2_new(0, 90, 1, -17)
    text_color2.Size = UDim2_new(0, 80, 0, 12)
    UI:AttachTheme(text_color2, { BackgroundColor3 = "background" })
    UI:AttachTheme(text_color2, { BorderColor3 = "outline" })
    
    local text_color_outline = Instance_new("Frame")
    text_color_outline.Name = "Outline"
    text_color_outline.BackgroundTransparency = 1
    text_color_outline.BorderColor3 = Color3_fromRGB(0, 0, 0)
    text_color_outline.BorderSizePixel = 0
    text_color_outline.Position = UDim2_new(0, -1, 0, -1)
    text_color_outline.Size = UDim2_new(1, 2, 1, 2)
    text_color_outline.ZIndex = 99
    text_color_outline.Parent = text_color
    local text_color_outline2 = text_color_outline:Clone()
    text_color_outline2.Parent = text_color2
    
    Color.Name = "Color"
    Color.FontFace = UI.font
    Color.Text = ""
    Color.TextColor3 = Color3_fromRGB(0, 0, 0)
    Color.TextSize = UI.font_size
    Color.AutoButtonColor = false
    Color.BackgroundColor3 = default
    Color.Position = UDim2_new(0, 6, 0, 30)
    Color.Size = UDim2_new(0, 145, 1, -74)
    UI:AttachTheme(Color, { BorderColor3 = "background" })
    Instance_new("UICorner", { Parent = Color, CornerRadius = UDim_new(0, 7) })
    Color.Parent = ColorInline
    
    Color_Circle.Name = "CircleButton"
    Color_Circle.FontFace = UI.font
    Color_Circle.Text = ""
    Color_Circle.TextColor3 = Color3_fromRGB(0, 0, 0)
    Color_Circle.TextSize = UI.font_size
    Color_Circle.AutoButtonColor = false
    Color_Circle.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    Color_Circle.Position = UDim2_new(0.5, -25, 0.5, -25)
    Color_Circle.Size = UDim2_new(0, 7, 0, 7)
    Color_Circle.Parent = Color
    Color_Circle.ZIndex = 9
    UI:AttachTheme(Color_Circle, { BorderColor3 = "background" })
    Instance_new("UICorner", { Parent = Color_Circle, CornerRadius = UDim_new(1, 0) })
    
    Sat.Name = "Sat"
    Sat.Image = "http://www.roblox.com/asset/?id=14684562507"
    Sat.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    Sat.BackgroundTransparency = 1
    Sat.BorderColor3 = Color3_fromRGB(0, 0, 0)
    Sat.BorderSizePixel = 0
    Sat.Size = UDim2_new(1, 0, 1, 0)
    Sat.Parent = Color
    Instance_new("UICorner", { Parent = Sat, CornerRadius = UDim_new(0, 6) })
    
    Val.Name = "Val"
    Val.Image = "http://www.roblox.com/asset/?id=14684563800"
    Val.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    Val.BackgroundTransparency = 1
    Val.BorderColor3 = Color3_fromRGB(0, 0, 0)
    Val.BorderSizePixel = 0
    Val.Size = UDim2_new(1, 0, 1, 0)
    Val.Parent = Color
    Instance_new("UICorner", { Parent = Val, CornerRadius = UDim_new(0, 6) })
    
    local Outline = Instance_new("Frame")
    Outline.Name = "Outline"
    Outline.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    Outline.BackgroundTransparency = 1
    Outline.BorderColor3 = Color3_fromRGB(0, 0, 0)
    Outline.BorderSizePixel = 0
    Outline.Position = UDim2_new(0, -1, 0, -1)
    Outline.Size = UDim2_new(1, 2, 1, 2)
    Outline.Parent = Color
    
    Alpha.Name = "Alpha"
    Alpha.Image = "http://www.roblox.com/asset/?id=15486053510"
    Alpha.AutoButtonColor = false
    Alpha.BackgroundTransparency = 1
    Alpha.ImageTransparency = 0.03
    Alpha.BorderSizePixel = 0
    Alpha.Position = UDim2_new(1, -18, 0, 30)
    Alpha.Size = UDim2_new(0, 10, 1, -74)
    Alpha.Parent = ColorInline
    UI:AttachTheme(Alpha, { BackgroundColor3 = "background" })
    Instance_new("UICorner", { Parent = Alpha, CornerRadius = UDim_new(0, 5) })
    
    Alpha_Bg.Name = "alpha_bg"
    Alpha_Bg.ZIndex = -1
    Alpha_Bg.Image = "http://www.roblox.com/asset/?id=4879903999"
    Alpha_Bg.BackgroundTransparency = 1
    Alpha_Bg.ScaleType = Enum.ScaleType.Crop
    Alpha_Bg.ImageColor3 = Color3_fromRGB(255, 255, 255)
    Alpha_Bg.BorderSizePixel = 0
    Alpha_Bg.Position = UDim2_new(1, -18, 0, 68)
    Alpha_Bg.Size = UDim2_new(0, 10, 1, -114)
    Alpha_Bg.Parent = ColorInline
    Instance_new("UICorner", { Parent = Alpha_Bg, CornerRadius = UDim_new(0, 5) })
    
    local Outline1 = Instance_new("Frame")
    Outline1.Name = "Outline"
    Outline1.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    Outline1.BackgroundTransparency = 1
    Outline1.BorderColor3 = Color3_fromRGB(0, 0, 0)
    Outline1.BorderSizePixel = 0
    Outline1.Position = UDim2_new(0, -1, 0, -1)
    Outline1.Size = UDim2_new(1, 2, 1, 2)
    Outline1.Parent = Alpha
    
    Hue.Name = "Hue"
    Hue.Image = "http://www.roblox.com/asset/?id=138435236878653"
    Hue.AutoButtonColor = false
    Hue.BackgroundColor3 = Color3_fromRGB(200, 200, 200)
    Hue.BorderColor3 = Color3_fromRGB(17, 17, 17)
    Hue.Position = UDim2_new(0, 7, 1, -35)
    Hue.Size = UDim2_new(0, 164, 0, 10)
    Hue.Parent = ColorInline
    UI:AttachTheme(Hue, { BackgroundColor3 = "background" })
    Instance_new("UICorner", { Parent = Hue, CornerRadius = UDim_new(0, 5) })
    
    local Outline2 = Instance_new("Frame")
    Outline2.Name = "Outline"
    Outline2.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    Outline2.BackgroundTransparency = 1
    Outline2.BorderColor3 = Color3_fromRGB(0, 0, 0)
    Outline2.BorderSizePixel = 0
    Outline2.Position = UDim2_new(0, -1, 0, -1)
    Outline2.Size = UDim2_new(1, 2, 1, 2)
    Outline2.Parent = Hue
    
    -- // Color Picker Logic
    local mouseover = false
    local hue, sat, val = default:ToHSV()
    local hsv = default:ToHSV()
    local alpha = defaultalpha
    local slidingsaturation = false
    local slidinghue = false
    local slidingalpha = false
    
    local function update()
        local real_pos = UserInputService:GetMouseLocation()
        local mouse_position = Vector2_new(real_pos.X - 3, real_pos.Y - 55)
        local relative_palette = (mouse_position - Color.AbsolutePosition)
        local relative_hue = (mouse_position - Hue.AbsolutePosition)
        local relative_opacity = (mouse_position - Alpha.AbsolutePosition)
        
        if slidingsaturation then
            sat = math_clamp(1 - relative_palette.X / Color.AbsoluteSize.X, 0, 1)
            val = math_clamp(1 - relative_palette.Y / Color.AbsoluteSize.Y, 0, 1)
        elseif slidinghue then
            hue = math_clamp(1 - (relative_hue.X / Hue.AbsoluteSize.X), 0, 1)
        elseif slidingalpha then
            alpha = math_clamp(relative_opacity.X / Alpha.AbsoluteSize.X, 0, 1)
        end
        
        hsv = Color3_fromHSV(hue, sat, val)
        Color.BackgroundColor3 = Color3_fromHSV(hue, 1, 1)
        Icon.BackgroundColor3 = hsv
        Color_Circle.Position = UDim2_new(1 - sat, 0, 1 - val, -5)
        
        if flag then
            UI.flags[flag] = UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)
        end
        
        local r, g, b = math_floor(hsv.r * 255), math_floor(hsv.g * 255), math_floor(hsv.b * 255)
        local rgbColor = Color3_fromRGB(r, g, b)
        Alpha.ImageColor3 = rgbColor
        text_color.Text = string_format("#%02x%02x%02x", r, g, b)
        text_color2.Text = string_format("%d, %d, %d", r, g, b)
        
        if callback then callback(UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)) end
    end
    
    local function set(color, a)
        if type(color) == "table" then
            a = color[4]
            color = Color3_fromHSV(color[1], color[2], color[3])
        end
        if type(color) == "string" then
            color = Color3_fromHex(color)
        end
        hue, sat, val = color:ToHSV()
        alpha = a or 1
        hsv = Color3_fromHSV(hue, sat, val)
        Icon.BackgroundColor3 = hsv
        Color.BackgroundColor3 = Color3_fromHSV(hue, 1, 1)
        local r, g, b = math_floor(hsv.r * 255), math_floor(hsv.g * 255), math_floor(hsv.b * 255)
        local rgbColor = Color3_fromRGB(r, g, b)
        Alpha.ImageColor3 = rgbColor
        text_color.Text = string_format("#%02x%02x%02x", r, g, b)
        text_color2.Text = string_format("%d, %d, %d", r, g, b)
        if flag then
            UI.flags[flag] = UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)
        end
        if callback then callback(UI:RGBA(hsv.r * 255, hsv.g * 255, hsv.b * 255, alpha)) end
    end
    
    flags[flag] = set
    set(default, defaultalpha)
    
    Sat.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingsaturation = true
            update()
        end
    end)
    Sat.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingsaturation = false
            update()
        end
    end)
    Hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidinghue = true
            update()
        end
    end)
    Hue.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidinghue = false
            update()
        end
    end)
    Alpha.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingalpha = true
            update()
        end
    end)
    Alpha.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slidingalpha = false
            update()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if slidingalpha then update() end
            if slidinghue then update() end
            if slidingsaturation then update() end
        end
    end)
    
    UserInputService.InputBegan:Connect(function(Input)
        if ColorWindow.Visible and Input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not UI:IsMouseOverFrame(ColorWindow) and not UI:IsMouseOverFrame(Icon) and not UI:IsMouseOverFrame(parent) then
                ColorWindow.Visible = false
                parent.ZIndex = 1
            end
        end
    end)
    
    Icon.MouseButton1Down:Connect(function()
        ColorWindow.Visible = true
        parent.ZIndex = 5
        slidinghue, slidingsaturation, slidingalpha = false, false, false
    end)
    
    local colorpickertypes = {}
    function colorpickertypes:Set(color, newalpha)
        set(color, newalpha)
    end
    
    return colorpickertypes, ColorWindow
end

-- // Window
function UI:window(options)
    local window = {
        name = options.Name or options.name or "visual enhancements",
        size = options.Size or options.size or UDim2_new(0, 770, 0, 500),
        position = options.position == "left" and Enum.TextXAlignment.Left or options.position == "center" and Enum.TextXAlignment.Center or options.position == "right" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
        dragging = { false, UDim2_new(0, 0, 0, 0) },
        page_amount = options.Amount or options.amount or 5,
        elements = {},
        sections = {},
        pages = {},
    }
    
    local menu = Instance_new("ScreenGui")
    menu.Name = "visual menu"
    menu.Parent = CoreGui
    menu.IgnoreGuiInset = Enum.ScreenInsets.DeviceSafeInsets
    menu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    menu.DisplayOrder = 10
    UI.menu_gui = menu
    
    local background = Instance_new("TextButton")
    background.Name = "background"
    background.Parent = menu
    background.Text = ""
    background.AutoButtonColor = false
    background.AnchorPoint = Vector2_new(0.5, 0.5)
    background.Position = UDim2_new(0.5, 0, 0.5, 0)
    background.BorderSizePixel = 1
    background.Size = window.size
    background.ZIndex = 9999
    UI:AttachTheme(background, { BackgroundColor3 = "background" })
    UI:AttachTheme(background, { BorderColor3 = "outline" })
    
    local background2 = Instance_new("Frame")
    background2.Name = "background2"
    background2.Parent = background
    background2.AnchorPoint = Vector2_new(0.5, 0.5)
    background2.Position = UDim2_new(0.5, 0, 0.5, 0)
    background2.Size = UDim2_new(1, 0, 1, 0)
    background2.BorderColor3 = Color3_fromRGB(40, 40, 40)
    background2.BorderSizePixel = 2
    background2.ZIndex = -1
    UI:AttachTheme(background2, { BackgroundColor3 = "background" })
    
    local tabs_holder = Instance_new("Frame")
    tabs_holder.Name = "tabs_holder"
    tabs_holder.BackgroundTransparency = 1
    tabs_holder.BorderColor3 = Color3_fromRGB(0, 0, 0)
    tabs_holder.BorderSizePixel = 0
    tabs_holder.Size = UDim2_new(0, 80, 0, 500)
    tabs_holder.Parent = background
    UI:AttachTheme(tabs_holder, { BackgroundColor3 = "background" })
    
    local page_holder = Instance_new("Frame")
    page_holder.Name = "page_holder"
    page_holder.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    background2.BackgroundTransparency = 1.000
    page_holder.BorderColor3 = Color3_fromRGB(255, 255, 255)
    page_holder.BorderSizePixel = 0
    page_holder.Position = UDim2_new(0.138, 0, 0, 13)
    page_holder.Size = UDim2_new(0, 640, 0, 470)
    page_holder.Parent = background
    
    window.elements = {
        tab_holder = tabs_holder,
        holder = page_holder,
        base = background,
    }
    
    function window:update_tabs()
        for _, page in pairs(window.pages) do
            page:Turn(page.open)
        end
    end
    
    -- Dragging
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.dragging[1], window.dragging[2] = true, UserInputService:GetMouseLocation()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.dragging[1] = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if window.dragging[1] and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse_pos = UserInputService:GetMouseLocation()
            local x_pos = math_clamp(background.Position.X.Offset + (mouse_pos.X - window.dragging[2].X), -ViewportSize.X / 2 + background.AbsoluteSize.X / 2, ViewportSize.X / 2 - background.AbsoluteSize.X / 2)
            local y_pos = math_clamp(background.Position.Y.Offset + (mouse_pos.Y - window.dragging[2].Y), -ViewportSize.Y / 2 + background.AbsoluteSize.Y / 2, ViewportSize.Y / 2 - background.AbsoluteSize.Y / 2)
            background.Position = UDim2_new(background.Position.X.Scale, x_pos, background.Position.Y.Scale, y_pos)
            window.dragging[2] = mouse_pos
        end
    end)
    
    -- Keybind List
    function window:keybind_list()
        local NKeyList = { Keybinds = {} }
        UI.keybind_list = NKeyList
        
        local keybind = Instance_new("ScreenGui")
        keybind.Name = "KeyBind List"
        keybind.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        keybind.IgnoreGuiInset = Enum.ScreenInsets.DeviceSafeInsets
        keybind.DisplayOrder = 10
        UI.keybind_screen_gui = keybind
        
        local Background = Instance_new("Frame")
        Background.Name = "Background"
        Background.BorderColor3 = Color3_fromRGB(11, 11, 11)
        Background.BorderSizePixel = 2
        Background.Position = UDim2_new(0.01, 0, 0.488, 0)
        Background.Size = UDim2_new(0, 164, 0, 24)
        Background.Visible = false
        Background.AutomaticSize = Enum.AutomaticSize.XY
        Background.Parent = keybind
        UI:AttachTheme(Background, { BackgroundColor3 = "background" })
        
        local stroke = Instance_new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        stroke.Color = Color3_fromRGB(71, 71, 71)
        stroke.Thickness = 1
        stroke.Parent = Background
        
        local TopLine = Instance_new("Frame")
        TopLine.Name = "TopLine"
        TopLine.BorderColor3 = Color3_fromRGB(25, 25, 25)
        TopLine.Position = UDim2_new(0, 0, 0, 0)
        TopLine.Size = UDim2_new(1, 0, 0, 1)
        TopLine.Visible = true
        TopLine.AutomaticSize = Enum.AutomaticSize.XY
        TopLine.Parent = Background
        UI:AttachTheme(TopLine, { BackgroundColor3 = "accent" })
        
        local Name_Holder = Instance_new("Frame")
        Name_Holder.Name = "Name_Holder"
        Name_Holder.BackgroundTransparency = 1
        Name_Holder.Position = UDim2_new(0, 0, 0, 0)
        Name_Holder.Visible = true
        Name_Holder.Size = UDim2_new(0, 170, 0.4, 0)
        Name_Holder.AutomaticSize = Enum.AutomaticSize.XY
        Name_Holder.Parent = Background
        
        local Name = Instance_new("TextLabel")
        Name.Name = "Name_List"
        Name.Parent = Name_Holder
        Name.BackgroundTransparency = 1
        Name.BorderColor3 = Color3_fromRGB(25, 25, 25)
        Name.BorderSizePixel = 0
        Name.Size = UDim2_new(1, 0, 0, 25)
        Name.FontFace = UI.font
        Name.Text = "KeyBind List"
        Name.TextStrokeTransparency = 0
        Name.TextColor3 = Color3_fromRGB(255, 255, 255)
        Name.TextSize = UI.font_size
        Name.RichText = true
        
        local Tab = Instance_new("Frame")
        Tab.Name = "Tab"
        Tab.Visible = true
        Tab.Parent = Background
        Tab.BackgroundTransparency = 1.000
        Tab.BorderColor3 = Color3_fromRGB(25, 25, 25)
        Tab.Position = UDim2_new(0, 0, 0, 25)
        Tab.Size = UDim2_new(1, 0, 0, -20)
        Tab.AutomaticSize = Enum.AutomaticSize.Y
        UI:AttachTheme(Tab, { BackgroundColor3 = "background" })
        
        local UIListLayout = Instance_new("UIListLayout")
        UIListLayout.Parent = Tab
        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim_new(0, 5)
        
        function NKeyList:SetVisible(State)
            Background.Visible = State
        end
        
        function NKeyList:NewKey(Key, Name)
            local KName = Instance_new("TextLabel")
            local KeyValue = {}
            KName.Name = "Name"
            KName.Parent = Tab
            KName.AnchorPoint = Vector2_new(0.5, 0.5)
            KName.BackgroundColor3 = Color3_fromRGB(11, 11, 11)
            KName.BackgroundTransparency = 1
            KName.BorderColor3 = Color3_fromRGB(25, 25, 25)
            KName.BorderSizePixel = 0
            KName.Position = UDim2_new(0.5, 0, -1.85000002, 0)
            KName.Size = UDim2_new(0, 0, 0, 0)
            KName.FontFace = UI.font
            KName.TextColor3 = Color3_fromRGB(255, 255, 255)
            KName.TextSize = UI.font_size
            KName.AutomaticSize = Enum.AutomaticSize.XY
            
            function KeyValue:SetVisible(State)
                KName.Visible = State
            end
            function KeyValue:Update(NKey, NewName)
                KName.Text = string_format("%s: [%s]", NewName, tostring(NKey))
            end
            return KeyValue
        end
        return NKeyList
    end
    window:keybind_list()
    
    UI.holder = background
    UI.page_amount = window.page_amount
    return setmetatable(window, UI)
end

-- // Tabs
function UI:tabs(properties)
    if not properties then properties = {} end
    local page = {
        name = properties.Name or properties.name or "page",
        scrollable = properties.Scrollable or properties.scrollable,
        window = self,
        open = false,
        sections = {},
        pages = {},
        elements = {},
        icon = properties.icon or properties.Icon or "",
        size = properties.size or properties.Size or UDim2_new(0, 60, 0, 60),
    }
    
    if not page.window.elements.tab_holder:FindFirstChild("UIListLayout") then
        Instance_new("UIListLayout", {
            Name = "UIListLayout",
            Padding = UDim_new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }).Parent = page.window.elements.tab_holder
    end
    
    local tab_button = Instance_new("TextButton")
    tab_button.Name = page.name
    tab_button.Text = ""
    tab_button.BackgroundTransparency = 1
    tab_button.Size = page.size
    tab_button.AutoButtonColor = false
    tab_button.Parent = page.window.elements.tab_holder
    
    local tab_icon = Instance_new("ImageLabel")
    tab_icon.Name = "icon"
    tab_icon.BackgroundTransparency = 1
    tab_icon.BorderSizePixel = 0
    tab_icon.Size = UDim2_new(1, 0, 1, 0)
    tab_icon.Image = page.icon
    tab_icon.Parent = tab_button
    
    local page_frame = Instance_new("ScrollingFrame")
    page_frame.Name = page.name
    page_frame.BackgroundTransparency = 1
    page_frame.BorderSizePixel = 0
    page_frame.Size = UDim2_new(1, 0, 1, 0)
    page_frame.CanvasSize = UDim2_new(0, 0, 0, 0)
    page_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page_frame.ScrollBarThickness = 2
    page_frame.Visible = false
    page_frame.Parent = page.window.elements.holder
    UI:AttachTheme(page_frame, { ScrollBarImageColor3 = "accent" })
    
    local page_list = Instance_new("UIListLayout")
    page_list.Name = "UIListLayout"
    page_list.Padding = UDim_new(0, 8)
    page_list.SortOrder = Enum.SortOrder.LayoutOrder
    page_list.FillDirection = Enum.FillDirection.Vertical
    page_list.Parent = page_frame
    
    local page_padding = Instance_new("UIPadding")
    page_padding.PaddingLeft = UDim_new(0, 10)
    page_padding.PaddingRight = UDim_new(0, 10)
    page_padding.PaddingTop = UDim_new(0, 10)
    page_padding.PaddingBottom = UDim_new(0, 10)
    page_padding.Parent = page_frame
    
    function page:Turn(state)
        page.open = state
        page_frame.Visible = state
        tab_button.BackgroundTransparency = state and 0.8 or 1
    end
    
    tab_button.MouseButton1Click:Connect(function()
        for _, p in pairs(page.window.pages) do
            p:Turn(false)
        end
        page:Turn(true)
    end)
    
    table.insert(page.window.pages, page)
    page_amount = page_amount + 1
    return setmetatable(page, { __index = UI.sections or {} })
end

-- // Sections
UI.sections = {}
UI.sections.__index = UI.sections

function UI.sections:section(options)
    local section = {
        name = options.Name or options.name or "section",
        risky = options.Risky or options.risky or false,
        side = options.Side or options.side or "left",
        page = self,
        elements = {},
    }
    
    local section_frame = Instance_new("Frame")
    section_frame.Name = section.name
    section_frame.BackgroundTransparency = 1
    section_frame.BorderSizePixel = 0
    section_frame.Size = UDim2_new(1, 0, 0, 20)
    section_frame.AutomaticSize = Enum.AutomaticSize.Y
    section_frame.Parent = self.page.elements.holder
    
    local section_list = Instance_new("UIListLayout")
    section_list.Padding = UDim_new(0, 6)
    section_list.SortOrder = Enum.SortOrder.LayoutOrder
    section_list.FillDirection = Enum.FillDirection.Vertical
    section_list.Parent = section_frame
    
    local section_padding = Instance_new("UIPadding")
    section_padding.PaddingLeft = UDim_new(0, 10)
    section_padding.PaddingRight = UDim_new(0, 10)
    section_padding.PaddingTop = UDim_new(0, 8)
    section_padding.PaddingBottom = UDim_new(0, 8)
    section_padding.Parent = section_frame
    
    local section_title = Instance_new("TextLabel")
    section_title.Name = "Title"
    section_title.BackgroundTransparency = 1
    section_title.Text = section.name
    section_title.TextColor3 = Color3_fromRGB(255, 255, 255)
    section_title.TextXAlignment = Enum.TextXAlignment.Left
    section_title.Size = UDim2_new(1, 0, 0, 20)
    section_title.FontFace = UI.font
    section_title.TextSize = UI.font_size
    section_title.TextStrokeTransparency = 0
    section_title.Parent = section_frame
    
    function section:toggle(toggle_options)
        local toggle = {
            name = toggle_options.Name or toggle_options.name or "Toggle",
            description = toggle_options.Description or toggle_options.description or "",
            default = toggle_options.Default or toggle_options.default or false,
            risky = toggle_options.Risky or toggle_options.risky or false,
            flag = toggle_options.Flag or toggle_options.flag or UI.next_flag(),
            callback = toggle_options.Callback or toggle_options.callback or function() end,
        }
        
        local toggle_frame = Instance_new("Frame")
        toggle_frame.Name = toggle.name
        toggle_frame.BackgroundTransparency = 1
        toggle_frame.BorderSizePixel = 0
        toggle_frame.Size = UDim2_new(1, 0, 0, 24)
        toggle_frame.Parent = section_frame
        
        local toggle_list = Instance_new("UIListLayout")
        toggle_list.Padding = UDim_new(0, 4)
        toggle_list.FillDirection = Enum.FillDirection.Horizontal
        toggle_list.VerticalAlignment = Enum.VerticalAlignment.Center
        toggle_list.Parent = toggle_frame
        
        local toggle_button = Instance_new("TextButton")
        toggle_button.Name = "Toggle"
        toggle_button.BackgroundColor3 = Color3_fromRGB(45, 45, 45)
        toggle_button.BorderSizePixel = 0
        toggle_button.Size = UDim2_new(0, 16, 0, 16)
        toggle_button.Text = ""
        toggle_button.AutoButtonColor = false
        toggle_button.Parent = toggle_frame
        UI:AttachTheme(toggle_button, { BackgroundColor3 = "background" })
        Instance_new("UICorner", { Parent = toggle_button, CornerRadius = UDim_new(0, 4) })
        
        local toggle_outline = Instance_new("Frame")
        toggle_outline.Name = "Outline"
        toggle_outline.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
        toggle_outline.BackgroundTransparency = 1
        toggle_outline.BorderColor3 = Color3_fromRGB(0, 0, 0)
        toggle_outline.BorderSizePixel = 0
        toggle_outline.Position = UDim2_new(0, -1, 0, -1)
        toggle_outline.Size = UDim2_new(1, 2, 1, 2)
        toggle_outline.ZIndex = 2
        toggle_outline.Parent = toggle_button
        UI:AttachTheme(toggle_outline, { BackgroundColor3 = "outline" })
        
        local toggle_label = Instance_new("TextLabel")
        toggle_label.Name = "Label"
        toggle_label.BackgroundTransparency = 1
        toggle_label.Text = toggle.name
        toggle_label.TextColor3 = Color3_fromRGB(255, 255, 255)
        toggle_label.TextXAlignment = Enum.TextXAlignment.Left
        toggle_label.Size = UDim2_new(1, -24, 0, 16)
        toggle_label.Position = UDim2_new(0, 24, 0, 0)
        toggle_label.FontFace = UI.font
        toggle_label.TextSize = UI.font_size
        toggle_label.TextStrokeTransparency = 0
        toggle_label.Parent = toggle_frame
        
        if toggle_options.Description then
            local toggle_desc = Instance_new("TextLabel")
            toggle_desc.Name = "Description"
            toggle_desc.BackgroundTransparency = 1
            toggle_desc.Text = toggle_options.Description
            toggle_desc.TextColor3 = Color3_fromRGB(128, 128, 128)
            toggle_desc.TextXAlignment = Enum.TextXAlignment.Left
            toggle_desc.Size = UDim2_new(1, -24, 0, 12)
            toggle_desc.Position = UDim2_new(0, 24, 0, 18)
            toggle_desc.FontFace = UI.font
            toggle_desc.TextSize = 10
            toggle_desc.TextStrokeTransparency = 0
            toggle_desc.Parent = toggle_frame
        end
        
        local state = toggle.default
        toggle_button.BackgroundColor3 = state and UI.themes[UI.currentTheme or "Default"].accent or Color3_fromRGB(45, 45, 45)
        
        local function set_state(new_state)
            state = new_state
            if state then
                TweenService:Create(toggle_button, TweenInfo.new(0.2), {BackgroundColor3 = UI.themes[UI.currentTheme or "Default"].accent}):Play()
            else
                TweenService:Create(toggle_button, TweenInfo.new(0.2), {BackgroundColor3 = Color3_fromRGB(45, 45, 45)}):Play()
            end
            UI.flags[toggle.flag] = state
            if toggle.callback then toggle.callback(state) end
        end
        
        toggle_button.MouseButton1Click:Connect(function()
            set_state(not state)
        end)
        
        if state then set_state(true) end
        
        local toggle_api = {}
        function toggle_api:Set(value) set_state(value) end
        function toggle_api:Get() return state end
        function toggle_api:SetCallback(cb) toggle.callback = cb end
        
        table.insert(section.elements, toggle_api)
        return toggle_api
    end
    
    function section:dropdown(dropdown_options)
        local dropdown = {
            name = dropdown_options.Name or dropdown_options.name or "Dropdown",
            description = dropdown_options.Description or dropdown_options.description or "",
            options = dropdown_options.Options or dropdown_options.options or {},
            max = dropdown_options.Max or dropdown_options.max or #dropdown_options.Options,
            default = dropdown_options.Default or dropdown_options.default or "",
            flag = dropdown_options.Flag or dropdown_options.flag or UI.next_flag(),
            callback = dropdown_options.Callback or dropdown_options.callback or function() end,
        }
        
        local dropdown_frame = Instance_new("Frame")
        dropdown_frame.Name = dropdown.name
        dropdown_frame.BackgroundTransparency = 1
        dropdown_frame.BorderSizePixel = 0
        dropdown_frame.Size = UDim2_new(1, 0, 0, 40)
        dropdown_frame.Parent = section_frame
        
        local dropdown_list = Instance_new("UIListLayout")
        dropdown_list.Padding = UDim_new(0, 4)
        dropdown_list.FillDirection = Enum.FillDirection.Vertical
        dropdown_list.VerticalAlignment = Enum.VerticalAlignment.Center
        dropdown_list.Parent = dropdown_frame
        
        local dropdown_label = Instance_new("TextLabel")
        dropdown_label.Name = "Label"
        dropdown_label.BackgroundTransparency = 1
        dropdown_label.Text = dropdown.name
        dropdown_label.TextColor3 = Color3_fromRGB(255, 255, 255)
        dropdown_label.TextXAlignment = Enum.TextXAlignment.Left
        dropdown_label.Size = UDim2_new(1, 0, 0, 16)
        dropdown_label.FontFace = UI.font
        dropdown_label.TextSize = UI.font_size
        dropdown_label.TextStrokeTransparency = 0
        dropdown_label.Parent = dropdown_frame
        
        local dropdown_button = Instance_new("TextButton")
        dropdown_button.Name = "Dropdown"
        dropdown_button.BackgroundColor3 = Color3_fromRGB(45, 45, 45)
        dropdown_button.BorderSizePixel = 0
        dropdown_button.Size = UDim2_new(1, 0, 0, 20)
        dropdown_button.Text = dropdown.default
        dropdown_button.AutoButtonColor = false
        dropdown_button.Parent = dropdown_frame
        UI:AttachTheme(dropdown_button, { BackgroundColor3 = "background" })
        Instance_new("UICorner", { Parent = dropdown_button, CornerRadius = UDim_new(0, 4) })
        
        if dropdown_options.Description then
            local dropdown_desc = Instance_new("TextLabel")
            dropdown_desc.Name = "Description"
            dropdown_desc.BackgroundTransparency = 1
            dropdown_desc.Text = dropdown_options.Description
            dropdown_desc.TextColor3 = Color3_fromRGB(128, 128, 128)
            dropdown_desc.TextXAlignment = Enum.TextXAlignment.Left
            dropdown_desc.Size = UDim2_new(1, 0, 0, 12)
            dropdown_desc.Position = UDim2_new(0, 0, 0, 22)
            dropdown_desc.FontFace = UI.font
            dropdown_desc.TextSize = 10
            dropdown_desc.TextStrokeTransparency = 0
            dropdown_desc.Parent = dropdown_frame
        end
        
        UI.flags[dropdown.flag] = dropdown.default
        
        local dropdown_api = {}
        function dropdown_api:Set(value)
            dropdown.default = value
            dropdown_button.Text = value
            UI.flags[dropdown.flag] = value
            if dropdown.callback then dropdown.callback(value) end
        end
        function dropdown_api:Get() return dropdown.default end
        function dropdown_api:SetCallback(cb) dropdown.callback = cb end
        
        table.insert(section.elements, dropdown_api)
        return dropdown_api
    end
    
    function section:slider(slider_options)
        local slider = {
            name = slider_options.Name or slider_options.name or "Slider",
            description = slider_options.Description or slider_options.description or "",
            min = slider_options.Min or slider_options.min or 0,
            max = slider_options.Max or slider_options.max or 100,
            default = slider_options.Default or slider_options.default or 0,
            decimals = slider_options.Decimals or slider_options.decimals or 1,
            suffix = slider_options.Suffix or slider_options.suffix or "",
            flag = slider_options.Flag or slider_options.flag or UI.next_flag(),
            callback = slider_options.Callback or slider_options.callback or function() end,
        }
        
        local slider_frame = Instance_new("Frame")
        slider_frame.Name = slider.name
        slider_frame.BackgroundTransparency = 1
        slider_frame.BorderSizePixel = 0
        slider_frame.Size = UDim2_new(1, 0, 0, 40)
        slider_frame.Parent = section_frame
        
        local slider_list = Instance_new("UIListLayout")
        slider_list.Padding = UDim_new(0, 4)
        slider_list.FillDirection = Enum.FillDirection.Vertical
        slider_list.VerticalAlignment = Enum.VerticalAlignment.Center
        slider_list.Parent = slider_frame
        
        local slider_label = Instance_new("TextLabel")
        slider_label.Name = "Label"
        slider_label.BackgroundTransparency = 1
        slider_label.Text = slider.name
        slider_label.TextColor3 = Color3_fromRGB(255, 255, 255)
        slider_label.TextXAlignment = Enum.TextXAlignment.Left
        slider_label.Size = UDim2_new(1, 0, 0, 16)
        slider_label.FontFace = UI.font
        slider_label.TextSize = UI.font_size
        slider_label.TextStrokeTransparency = 0
        slider_label.Parent = slider_frame
        
        local slider_button = Instance_new("TextButton")
        slider_button.Name = "Slider"
        slider_button.BackgroundColor3 = Color3_fromRGB(45, 45, 45)
        slider_button.BorderSizePixel = 0
        slider_button.Size = UDim2_new(1, 0, 0, 16)
        slider_button.Text = tostring(slider.default) .. slider.suffix
        slider_button.AutoButtonColor = false
        slider_button.Parent = slider_frame
        UI:AttachTheme(slider_button, { BackgroundColor3 = "background" })
        Instance_new("UICorner", { Parent = slider_button, CornerRadius = UDim_new(0, 4) })
        
        if slider_options.Description then
            local slider_desc = Instance_new("TextLabel")
            slider_desc.Name = "Description"
            slider_desc.BackgroundTransparency = 1
            slider_desc.Text = slider_options.Description
            slider_desc.TextColor3 = Color3_fromRGB(128, 128, 128)
            slider_desc.TextXAlignment = Enum.TextXAlignment.Left
            slider_desc.Size = UDim2_new(1, 0, 0, 12)
            slider_desc.Position = UDim2_new(0, 0, 0, 22)
            slider_desc.FontFace = UI.font
            slider_desc.TextSize = 10
            slider_desc.TextStrokeTransparency = 0
            slider_desc.Parent = slider_frame
        end
        
        UI.flags[slider.flag] = slider.default
        
        local slider_api = {}
        function slider_api:Set(value)
            slider.default = value
            slider_button.Text = tostring(value) .. slider.suffix
            UI.flags[slider.flag] = value
            if slider.callback then slider.callback(value) end
        end
        function slider_api:Get() return slider.default end
        function slider_api:SetCallback(cb) slider.callback = cb end
        
        table.insert(section.elements, slider_api)
        return slider_api
    end
    
    function section:colorpicker(color_options)
        local colorpicker = {
            name = color_options.Name or color_options.name or "Color Picker",
            description = color_options.Description or color_options.description or "",
            flag = color_options.Flag or color_options.flag or UI.next_flag(),
            default = color_options.Default or color_options.default or Color3_fromRGB(255, 255, 255),
            callback = color_options.Callback or color_options.callback or function() end,
        }
        
        local colorpicker_frame = Instance_new("Frame")
        colorpicker_frame.Name = colorpicker.name
        colorpicker_frame.BackgroundTransparency = 1
        colorpicker_frame.BorderSizePixel = 0
        colorpicker_frame.Size = UDim2_new(1, 0, 0, 20)
        colorpicker_frame.Parent = section_frame
        
        local colorpicker_list = Instance_new("UIListLayout")
        colorpicker_list.Padding = UDim_new(0, 4)
        colorpicker_list.FillDirection = Enum.FillDirection.Horizontal
        colorpicker_list.VerticalAlignment = Enum.VerticalAlignment.Center
        colorpicker_list.Parent = colorpicker_frame
        
        local colorpicker_label = Instance_new("TextLabel")
        colorpicker_label.Name = "Label"
        colorpicker_label.BackgroundTransparency = 1
        colorpicker_label.Text = colorpicker.name
        colorpicker_label.TextColor3 = Color3_fromRGB(255, 255, 255)
        colorpicker_label.TextXAlignment = Enum.TextXAlignment.Left
        colorpicker_label.Size = UDim2_new(1, -20, 0, 16)
        colorpicker_label.FontFace = UI.font
        colorpicker_label.TextSize = UI.font_size
        colorpicker_label.TextStrokeTransparency = 0
        colorpicker_label.Parent = colorpicker_frame
        
        local color_icon = Instance_new("TextButton")
        color_icon.Name = "Color"
        color_icon.BackgroundColor3 = colorpicker.default
        color_icon.BorderColor3 = Color3_fromRGB(36, 36, 36)
        color_icon.BorderSizePixel = 1
        color_icon.Position = UDim2_new(1, -18, 0.5, 0)
        color_icon.Size = UDim2_new(0, 16, 0, 16)
        color_icon.Text = ""
        color_icon.ZIndex = 99
        color_icon.AutoButtonColor = false
        color_icon.Parent = colorpicker_frame
        Instance_new("UICorner", { Parent = color_icon, CornerRadius = UDim_new(1, 0) })
        
        UI.flags[colorpicker.flag] = UI:RGBA(colorpicker.default.R * 255, colorpicker.default.G * 255, colorpicker.default.B * 255, 1)
        
        local colorpicker_api = {}
        function colorpicker_api:Set(color)
            colorpicker.default = color
            color_icon.BackgroundColor3 = color
            UI.flags[colorpicker.flag] = UI:RGBA(color.R * 255, color.G * 255, color.B * 255, 1)
            if colorpicker.callback then colorpicker.callback(UI:RGBA(color.R * 255, color.G * 255, color.B * 255, 1)) end
        end
        function colorpicker_api:Get() return colorpicker.default end
        function colorpicker_api:SetCallback(cb) colorpicker.callback = cb end
        
        table.insert(section.elements, colorpicker_api)
        return colorpicker_api
    end
    
    function section:button(button_options)
        local button = {
            name = button_options.Name or button_options.name or "Button",
            description = button_options.Description or button_options.description or "",
            callback = button_options.Callback or button_options.callback or function() end,
        }
        
        local button_frame = Instance_new("Frame")
        button_frame.Name = button.name
        button_frame.BackgroundTransparency = 1
        button_frame.BorderSizePixel = 0
        button_frame.Size = UDim2_new(1, 0, 0, 24)
        button_frame.Parent = section_frame
        
        local button_list = Instance_new("UIListLayout")
        button_list.Padding = UDim_new(0, 4)
        button_list.FillDirection = Enum.FillDirection.Horizontal
        button_list.VerticalAlignment = Enum.VerticalAlignment.Center
        button_list.Parent = button_frame
        
        local button_label = Instance_new("TextLabel")
        button_label.Name = "Label"
        button_label.BackgroundTransparency = 1
        button_label.Text = button.name
        button_label.TextColor3 = Color3_fromRGB(255, 255, 255)
        button_label.TextXAlignment = Enum.TextXAlignment.Left
        button_label.Size = UDim2_new(1, -70, 0, 16)
        button_label.FontFace = UI.font
        button_label.TextSize = UI.font_size
        button_label.TextStrokeTransparency = 0
        button_label.Parent = button_frame
        
        local button_click = Instance_new("TextButton")
        button_click.Name = "Button"
        button_click.BackgroundColor3 = Color3_fromRGB(45, 45, 45)
        button_click.BorderSizePixel = 0
        button_click.Size = UDim2_new(0, 60, 0, 18)
        button_click.Text = button.name
        button_click.AutoButtonColor = false
        button_click.Parent = button_frame
        UI:AttachTheme(button_click, { BackgroundColor3 = "background" })
        Instance_new("UICorner", { Parent = button_click, CornerRadius = UDim_new(0, 4) })
        
        button_click.MouseButton1Click:Connect(function()
            if button.callback then button.callback() end
        end)
        
        if button_options.Description then
            local button_desc = Instance_new("TextLabel")
            button_desc.Name = "Description"
            button_desc.BackgroundTransparency = 1
            button_desc.Text = button_options.Description
            button_desc.TextColor3 = Color3_fromRGB(128, 128, 128)
            button_desc.TextXAlignment = Enum.TextXAlignment.Left
            button_desc.Size = UDim2_new(1, -70, 0, 12)
            button_desc.Position = UDim2_new(0, 0, 0, 18)
            button_desc.FontFace = UI.font
            button_desc.TextSize = 10
            button_desc.TextStrokeTransparency = 0
            button_desc.Parent = button_frame
        end
    end
    
    function section:keybind(keybind_options)
        local keybind = {
            name = keybind_options.Name or keybind_options.name or "Keybind",
            description = keybind_options.Description or keybind_options.description or "",
            flag = keybind_options.Flag or keybind_options.flag or UI.next_flag(),
            mode = keybind_options.Mode or keybind_options.mode or "Toggle",
            usekey = keybind_options.Usekey or keybind_options.usekey or false,
            default = keybind_options.Default or keybind_options.default or Enum.KeyCode.Unknown,
            callback = keybind_options.Callback or keybind_options.callback or function() end,
        }
        
        local keybind_frame = Instance_new("Frame")
        keybind_frame.Name = keybind.name
        keybind_frame.BackgroundTransparency = 1
        keybind_frame.BorderSizePixel = 0
        keybind_frame.Size = UDim2_new(1, 0, 0, 24)
        keybind_frame.Parent = section_frame
        
        local keybind_list = Instance_new("UIListLayout")
        keybind_list.Padding = UDim_new(0, 4)
        keybind_list.FillDirection = Enum.FillDirection.Horizontal
        keybind_list.VerticalAlignment = Enum.VerticalAlignment.Center
        keybind_list.Parent = keybind_frame
        
        local keybind_label = Instance_new("TextLabel")
        keybind_label.Name = "Label"
        keybind_label.BackgroundTransparency = 1
        keybind_label.Text = keybind.name
        keybind_label.TextColor3 = Color3_fromRGB(255, 255, 255)
        keybind_label.TextXAlignment = Enum.TextXAlignment.Left
        keybind_label.Size = UDim2_new(1, -70, 0, 16)
        keybind_label.FontFace = UI.font
        keybind_label.TextSize = UI.font_size
        keybind_label.TextStrokeTransparency = 0
        keybind_label.Parent = keybind_frame
        
        local keybind_button = Instance_new("TextButton")
        keybind_button.Name = "Keybind"
        keybind_button.BackgroundColor3 = Color3_fromRGB(45, 45, 45)
        keybind_button.BorderSizePixel = 0
        keybind_button.Size = UDim2_new(0, 60, 0, 18)
        keybind_button.Text = keybind.default.Name or "Unknown"
        keybind_button.AutoButtonColor = false
        keybind_button.Parent = keybind_frame
        UI:AttachTheme(keybind_button, { BackgroundColor3 = "background" })
        Instance_new("UICorner", { Parent = keybind_button, CornerRadius = UDim_new(0, 4) })
        
        if keybind_options.Description then
            local keybind_desc = Instance_new("TextLabel")
            keybind_desc.Name = "Description"
            keybind_desc.BackgroundTransparency = 1
            keybind_desc.Text = keybind_options.Description
            keybind_desc.TextColor3 = Color3_fromRGB(128, 128, 128)
            keybind_desc.TextXAlignment = Enum.TextXAlignment.Left
            keybind_desc.Size = UDim2_new(1, -70, 0, 12)
            keybind_desc.Position = UDim2_new(0, 0, 0, 18)
            keybind_desc.FontFace = UI.font
            keybind_desc.TextSize = 10
            keybind_desc.TextStrokeTransparency = 0
            keybind_desc.Parent = keybind_frame
        end
        
        local listening = false
        keybind_button.MouseButton1Click:Connect(function()
            listening = true
            keybind_button.Text = "..."
            local input_conn
            input_conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    keybind.default = input.KeyCode
                    keybind_button.Text = input.KeyCode.Name
                    input_conn:Disconnect()
                end
            end)
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if not listening and input.KeyCode == keybind.default then
                if keybind.callback then keybind.callback(input.KeyCode) end
            end
        end)
    end
    
    table.insert(page.sections, section)
    return section
end

-- // Menu, Extra, Configs, Themes shortcuts
function UI:Menu(tab) end
function UI:Extra(tab) end
function UI:Configs(tab) end
function UI:Themes(tab) end

-- // Return UI
return UI