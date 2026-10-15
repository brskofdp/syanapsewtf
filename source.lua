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

-- // Helper: create instance with properties table
local function create_instance(class_name, properties, parent)
    local inst = Instance_new(class_name)
    if properties then
        for prop, val in pairs(properties) do
            inst[prop] = val
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

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
    
    local base_position = Vector2_new(25, 65 + (#UI.notifications * 25))
    
    local notifcontainer = create_instance("Frame", {
        Name = "container",
        Position = UDim2_new(0, base_position.X, 0, base_position.Y),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2_new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 99999999,
    }, notif_ui)
    notification.Container = notifcontainer
    
    local outline = create_instance("Frame", {
        Name = "outline",
        AutomaticSize = Enum.AutomaticSize.X,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        Position = UDim2_new(0.01, 0, 0.02, 0),
        Size = UDim2_new(0, 0, 0, 18),
        Parent = notifcontainer,
        BackgroundTransparency = 1,
    })
    table.insert(notification.Objects, outline)
    UI:AttachTheme(outline, { BackgroundColor3 = "background" })
    
    local inline = create_instance("Frame", {
        Name = "inline",
        BackgroundColor3 = Color3_fromRGB(5, 5, 5),
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2_new(0, 1, 0, 0),
        Size = UDim2_new(1, 0, 1, -1),
        BackgroundTransparency = 1,
        Parent = outline,
    })
    table.insert(notification.Objects, inline)
    UI:AttachTheme(inline, { BackgroundColor3 = "background" })
    
    local value = create_instance("TextLabel", {
        Name = "text",
        Text = message,
        TextColor3 = Color3_fromRGB(255, 255, 255),
        TextStrokeTransparency = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Size = UDim2_new(0, 0, 1, 0),
        TextTransparency = 1,
        Parent = inline,
        FontFace = UI.font,
        TextSize = UI.font_size,
    })
    table.insert(notification.Objects, value)
    
    local uipadding = create_instance("UIPadding", {
        PaddingLeft = UDim_new(0, 5),
        PaddingRight = UDim_new(0, 5),
        PaddingTop = UDim_new(0, 1),
        Parent = value,
    })
    
    local time_line = create_instance("Frame", {
        Name = "timeline",
        BorderSizePixel = 0,
        Size = UDim2_new(0, 0, 1, 0),
        Parent = outline,
        BackgroundTransparency = 1,
        BackgroundColor3 = color,
        ZIndex = -1,
    })
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
        outline.AnchorPoint = Vector2_new(1, 0)
        for _, v in next, notification.Objects do
            if v:IsA("Frame") or v:IsA("ImageLabel") then
                TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
            end
        end
        TweenService:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {AnchorPoint = Vector2_new(0, 0)}):Play()
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
    local Icon = create_instance("TextButton", {
        Name = "Icon_Colorpicker",
        AnchorPoint = Vector2_new(0, 0.5),
        BackgroundColor3 = default,
        BorderColor3 = Color3_fromRGB(36, 36, 36),
        BorderSizePixel = 1,
        Text = "",
        ZIndex = 99,
        AutoButtonColor = false,
        Parent = parent,
    }, parent)
    if count == 1 then
        Icon.Position = UDim2_new(1, -(count * 18), 0.5, 0)
    else
        local spacing = 3
        Icon.Position = UDim2_new(1, -(count * 16) - (count * spacing), 0.5, 0)
    end
    Icon.Size = UDim2_new(0, 16, 0, 16)
    
    create_instance("UICorner", { Parent = Icon, CornerRadius = UDim_new(1, 0) })
    
    local Outline4 = create_instance("Frame", {
        Name = "Outline",
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2_new(0, -1, 0, -1),
        Size = UDim2_new(1, 2, 1, 2),
        ZIndex = 99,
        Parent = Icon,
    })
    
    local ColorWindow = create_instance("Frame", {
        Name = "ColorWindow",
        AnchorPoint = Vector2_new(0.5, 0.5),
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        Position = UDim2_new(1, 0, 1, 2),
        AnchorPoint = Vector2_new(1, 0),
        Size = UDim2_new(0, 180, 0, 220),
        ZIndex = 99,
        Visible = false,
        Parent = Icon,
    })
    UI:AttachTheme(ColorWindow, { BackgroundColor3 = "outline" })
    create_instance("UICorner", { Parent = ColorWindow, CornerRadius = UDim_new(0, 6) })
    
    local ColorInline = create_instance("Frame", {
        Name = "ColorInline",
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2_new(0, 1, 0, 1),
        Size = UDim2_new(1, -2, 1, -2),
        BackgroundTransparency = 1,
        Parent = ColorWindow,
    })
    UI:AttachTheme(ColorInline, { BackgroundColor3 = "background" })
    create_instance("UICorner", { Parent = ColorInline, CornerRadius = UDim_new(0, 6) })
    
    local color_name = create_instance("TextLabel", {
        BackgroundTransparency = 1,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Color3_fromRGB(255, 255, 255),
        Position = UDim2_new(0, 8, 0, 5),
        Size = UDim2_new(1, -10, 0, 20),
        TextSize = UI.font_size,
        FontFace = UI.font,
        TextStrokeTransparency = 0,
        Parent = ColorInline,
    })
    
    local text_color = create_instance("TextButton", {
        Name = "Text Color",
        FontFace = UI.font,
        TextColor3 = Color3_fromRGB(155, 155, 155),
        Parent = ColorInline,
        TextStrokeTransparency = 0,
        TextSize = UI.font_size,
        AutoButtonColor = false,
        Position = UDim2_new(0, 7, 1, -17),
        Size = UDim2_new(0, 76, 0, 12),
    })
    UI:AttachTheme(text_color, { BackgroundColor3 = "background" })
    UI:AttachTheme(text_color, { BorderColor3 = "outline" })
    
    local text_color2 = create_instance("TextButton", {
        Name = "Text Color 2",
        FontFace = UI.font,
        TextColor3 = Color3_fromRGB(155, 155, 155),
        Parent = ColorInline,
        TextStrokeTransparency = 0,
        TextSize = UI.font_size,
        AutoButtonColor = false,
        Position = UDim2_new(0, 90, 1, -17),
        Size = UDim2_new(0, 80, 0, 12),
    })
    UI:AttachTheme(text_color2, { BackgroundColor3 = "background" })
    UI:AttachTheme(text_color2, { BorderColor3 = "outline" })
    
    local text_color_outline = create_instance("Frame", {
        Name = "Outline",
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2_new(0, -1, 0, -1),
        Size = UDim2_new(1, 2, 1, 2),
        ZIndex = 99,
        Parent = text_color,
    })
    local text_color_outline2 = text_color_outline:Clone()
    text_color_outline2.Parent = text_color2
    
    local Color = create_instance("TextButton", {
        Name = "Color",
        FontFace = UI.font,
        Text = "",
        TextColor3 = Color3_fromRGB(0, 0, 0),
        TextSize = UI.font_size,
        AutoButtonColor = false,
        BackgroundColor3 = default,
        Position = UDim2_new(0, 6, 0, 30),
        Size = UDim2_new(0, 145, 1, -74),
        Parent = ColorInline,
    })
    UI:AttachTheme(Color, { BorderColor3 = "background" })
    create_instance("UICorner", { Parent = Color, CornerRadius = UDim_new(0, 7) })
    
    local Color_Circle = create_instance("TextButton", {
        Name = "CircleButton",
        FontFace = UI.font,
        Text = "",
        TextColor3 = Color3_fromRGB(0, 0, 0),
        TextSize = UI.font_size,
        AutoButtonColor = false,
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        Position = UDim2_new(0.5, -25, 0.5, -25),
        Size = UDim2_new(0, 7, 0, 7),
        Parent = Color,
        ZIndex = 9,
    })
    UI:AttachTheme(Color_Circle, { BorderColor3 = "background" })
    create_instance("UICorner", { Parent = Color_Circle, CornerRadius = UDim_new(1, 0) })
    
    local Sat = create_instance("ImageLabel", {
        Name = "Sat",
        Image = "http://www.roblox.com/asset/?id=14684562507",
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2_new(1, 0, 1, 0),
        Parent = Color,
    })
    create_instance("UICorner", { Parent = Sat, CornerRadius = UDim_new(0, 6) })
    
    local Val = create_instance("ImageLabel", {
        Name = "Val",
        Image = "http://www.roblox.com/asset/?id=14684563800",
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2_new(1, 0, 1, 0),
        Parent = Color,
    })
    create_instance("UICorner", { Parent = Val, CornerRadius = UDim_new(0, 6) })
    
    local Outline = create_instance("Frame", {
        Name = "Outline",
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2_new(0, -1, 0, -1),
        Size = UDim2_new(1, 2, 1, 2),
        Parent = Color,
    })
    
    local Alpha = create_instance("ImageButton", {
        Name = "Alpha",
        Image = "http://www.roblox.com/asset/?id=15486053510",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        ImageTransparency = 0.03,
        BorderSizePixel = 0,
        Position = UDim2_new(1, -18, 0, 30),
        Size = UDim2_new(0, 10, 1, -74),
        Parent = ColorInline,
    })
    UI:AttachTheme(Alpha, { BackgroundColor3 = "background" })
    create_instance("UICorner", { Parent = Alpha, CornerRadius = UDim_new(0, 5) })
    
    local Alpha_Bg = create_instance("ImageLabel", {
        Name = "alpha_bg",
        ZIndex = -1,
        Image = "http://www.roblox.com/asset/?id=4879903999",
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
        ImageColor3 = Color3_fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2_new(1, -18, 0, 68),
        Size = UDim2_new(0, 10, 1, -114),
        Parent = ColorInline,
    })
    create_instance("UICorner", { Parent = Alpha_Bg, CornerRadius = UDim_new(0, 5) })
    
    local Outline1 = create_instance("Frame", {
        Name = "Outline",
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2_new(0, -1, 0, -1),
        Size = UDim2_new(1, 2, 1, 2),
        Parent = Alpha,
    })
    
    local Hue = create_instance("ImageButton", {
        Name = "Hue",
        Image = "http://www.roblox.com/asset/?id=138435236878653",
        AutoButtonColor = false,
        BackgroundColor3 = Color3_fromRGB(200, 200, 200),
        BorderColor3 = Color3_fromRGB(17, 17, 17),
        Position = UDim2_new(0, 7, 1, -35),
        Size = UDim2_new(0, 164, 0, 10),
        Parent = ColorInline,
    })
    UI:AttachTheme(Hue, { BackgroundColor3 = "background" })
    create_instance("UICorner", { Parent = Hue, CornerRadius = UDim_new(0, 5) })
    
    local Outline2 = create_instance("Frame", {
        Name = "Outline",
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2_new(0, -1, 0, -1),
        Size = UDim2_new(1, 2, 1, 2),
        Parent = Hue,
    })
    
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
    
    local background = create_instance("TextButton", {
        Name = "background",
        Parent = menu,
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2_new(0.5, 0.5),
        Position = UDim2_new(0.5, 0, 0.5, 0),
        BorderSizePixel = 1,
        Size = window.size,
        ZIndex = 9999,
    }, menu)
    UI:AttachTheme(background, { BackgroundColor3 = "background" })
    UI:AttachTheme(background, { BorderColor3 = "outline" })
    
    local background2 = create_instance("Frame", {
        Name = "background2",
        Parent = background,
        AnchorPoint = Vector2_new(0.5, 0.5),
        Position = UDim2_new(0.5, 0, 0.5, 0),
        Size = UDim2_new(1, 0, 1, 0),
        BorderColor3 = Color3_fromRGB(40, 40, 40),
        BorderSizePixel = 2,
        ZIndex = -1,
    }, background)
    UI:AttachTheme(background2, { BackgroundColor3 = "background" })
    
    local tabs_holder = create_instance("Frame", {
        Name = "tabs_holder",
        BackgroundTransparency = 1,
        BorderColor3 = Color3_fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2_new(0, 80, 0, 500),
        Parent = background,
    })
    UI:AttachTheme(tabs_holder, { BackgroundColor3 = "background" })
    
    local page_holder = create_instance("Frame", {
        Name = "page_holder",
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 1.000,
        BorderColor3 = Color3_fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2_new(0.138, 0, 0, 13),
        Size = UDim2_new(0, 640, 0, 470),
        Parent = background,
    })
    
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
        
        local Background = create_instance("Frame", {
            Name = "Background",
            BorderColor3 = Color3_fromRGB(11, 11, 11),
            BorderSizePixel = 2,
            Position = UDim2_new(0.01, 0, 0.488, 0),
            Size = UDim2_new(0, 164, 0, 24),
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.XY,
            Parent = keybind,
        })
        UI:AttachTheme(Background, { BackgroundColor3 = "background" })
        
        local stroke = Instance_new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        stroke.Color = Color3_fromRGB(71, 71, 71)
        stroke.Thickness = 1
        stroke.Parent = Background
        
        local TopLine = create_instance("Frame", {
            Name = "TopLine",
            BorderColor3 = Color3_fromRGB(25, 25, 25),
            Position = UDim2_new(0, 0, 0, 0),
            Size = UDim2_new(1, 0, 0, 1),
            Visible = true,
            AutomaticSize = Enum.AutomaticSize.XY,
            Parent = Background,
        })
        UI:AttachTheme(TopLine, { BackgroundColor3 = "accent" })
        
        local Name_Holder = create_instance("Frame", {
            Name = "Name_Holder",
            BackgroundTransparency = 1,
            Position = UDim2_new(0, 0, 0, 0),
            Visible = true,
            Size = UDim2_new(0, 170, 0.4, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            Parent = Background,
        })
        
        local Name = create_instance("TextLabel", {
            Name = "Name_List",
            Parent = Name_Holder,
            BackgroundTransparency = 1,
            BorderColor3 = Color3_fromRGB(25, 25, 25),
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 25),
            FontFace = UI.font,
            Text = "KeyBind List",
            TextStrokeTransparency = 0,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextSize = UI.font_size,
            RichText = true,
        })
        
        local Tab = create_instance("Frame", {
            Name = "Tab",
            Visible = true,
            Parent = Background,
            BackgroundTransparency = 1.000,
            BorderColor3 = Color3_fromRGB(25, 25, 25),
            Position = UDim2_new(0, 0, 0, 25),
            Size = UDim2_new(1, 0, 0, -20),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        UI:AttachTheme(Tab, { BackgroundColor3 = "background" })
        
        local UIListLayout = create_instance("UIListLayout", {
            Parent = Tab,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim_new(0, 5),
        })
        
        function NKeyList:SetVisible(State)
            Background.Visible = State
        end
        
        function NKeyList:NewKey(Key, Name)
            local KName = create_instance("TextLabel", {
                Name = "Name",
                Parent = Tab,
                AnchorPoint = Vector2_new(0.5, 0.5),
                BackgroundColor3 = Color3_fromRGB(11, 11, 11),
                BackgroundTransparency = 1,
                BorderColor3 = Color3_fromRGB(25, 25, 25),
                BorderSizePixel = 0,
                Position = UDim2_new(0.5, 0, -1.85000002, 0),
                Size = UDim2_new(0, 0, 0, 0),
                FontFace = UI.font,
                TextColor3 = Color3_fromRGB(255, 255, 255),
                TextSize = UI.font_size,
                AutomaticSize = Enum.AutomaticSize.XY,
            }, Tab)
            
            local KeyValue = {}
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
        create_instance("UIListLayout", {
            Name = "UIListLayout",
            Padding = UDim_new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }, page.window.elements.tab_holder)
    end
    
    local tab_button = create_instance("TextButton", {
        Name = page.name,
        Text = "",
        BackgroundTransparency = 1,
        Size = page.size,
        AutoButtonColor = false,
        Parent = page.window.elements.tab_holder,
    })
    
    local tab_icon = create_instance("ImageLabel", {
        Name = "icon",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2_new(1, 0, 1, 0),
        Image = page.icon,
        Parent = tab_button,
    })
    
    local page_frame = create_instance("ScrollingFrame", {
        Name = page.name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2_new(1, 0, 1, 0),
        CanvasSize = UDim2_new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        Visible = false,
        Parent = page.window.elements.holder,
    })
    UI:AttachTheme(page_frame, { ScrollBarImageColor3 = "accent" })
    
    local page_list = create_instance("UIListLayout", {
        Name = "UIListLayout",
        Padding = UDim_new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Parent = page_frame,
    })
    
    local page_padding = create_instance("UIPadding", {
        PaddingLeft = UDim_new(0, 10),
        PaddingRight = UDim_new(0, 10),
        PaddingTop = UDim_new(0, 10),
        PaddingBottom = UDim_new(0, 10),
        Parent = page_frame,
    })
    
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
    
    local section_frame = create_instance("Frame", {
        Name = section.name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2_new(1, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.page.elements.holder,
    })
    
    local section_list = create_instance("UIListLayout", {
        Padding = UDim_new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Parent = section_frame,
    })
    
    local section_padding = create_instance("UIPadding", {
        PaddingLeft = UDim_new(0, 10),
        PaddingRight = UDim_new(0, 10),
        PaddingTop = UDim_new(0, 8),
        PaddingBottom = UDim_new(0, 8),
        Parent = section_frame,
    })
    
    local section_title = create_instance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Text = section.name,
        TextColor3 = Color3_fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2_new(1, 0, 0, 20),
        FontFace = UI.font,
        TextSize = UI.font_size,
        TextStrokeTransparency = 0,
        Parent = section_frame,
    })
    
    function section:toggle(toggle_options)
        local toggle = {
            name = toggle_options.Name or toggle_options.name or "Toggle",
            description = toggle_options.Description or toggle_options.description or "",
            default = toggle_options.Default or toggle_options.default or false,
            risky = toggle_options.Risky or toggle_options.risky or false,
            flag = toggle_options.Flag or toggle_options.flag or UI.next_flag(),
            callback = toggle_options.Callback or toggle_options.callback or function() end,
        }
        
        local toggle_frame = create_instance("Frame", {
            Name = toggle.name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 24),
            Parent = section_frame,
        })
        
        local toggle_list = create_instance("UIListLayout", {
            Padding = UDim_new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = toggle_frame,
        })
        
        local toggle_button = create_instance("TextButton", {
            Name = "Toggle",
            BackgroundColor3 = Color3_fromRGB(45, 45, 45),
            BorderSizePixel = 0,
            Size = UDim2_new(0, 16, 0, 16),
            Text = "",
            AutoButtonColor = false,
            Parent = toggle_frame,
        })
        UI:AttachTheme(toggle_button, { BackgroundColor3 = "background" })
        create_instance("UICorner", { Parent = toggle_button, CornerRadius = UDim_new(0, 4) })
        
        local toggle_outline = create_instance("Frame", {
            Name = "Outline",
            BackgroundColor3 = Color3_fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3_fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2_new(0, -1, 0, -1),
            Size = UDim2_new(1, 2, 1, 2),
            ZIndex = 2,
            Parent = toggle_button,
        })
        UI:AttachTheme(toggle_outline, { BackgroundColor3 = "outline" })
        
        local toggle_label = create_instance("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Text = toggle.name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2_new(1, -24, 0, 16),
            Position = UDim2_new(0, 24, 0, 0),
            FontFace = UI.font,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            Parent = toggle_frame,
        })
        
        if toggle_options.Description then
            local toggle_desc = create_instance("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Text = toggle_options.Description,
                TextColor3 = Color3_fromRGB(128, 128, 128),
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2_new(1, -24, 0, 12),
                Position = UDim2_new(0, 24, 0, 18),
                FontFace = UI.font,
                TextSize = 10,
                TextStrokeTransparency = 0,
                Parent = toggle_frame,
            })
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
        
        table_insert(section.elements, toggle_api)
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
        
        local dropdown_frame = create_instance("Frame", {
            Name = dropdown.name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 40),
            Parent = section_frame,
        })
        
        local dropdown_list = create_instance("UIListLayout", {
            Padding = UDim_new(0, 4),
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = dropdown_frame,
        })
        
        local dropdown_label = create_instance("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Text = dropdown.name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2_new(1, 0, 0, 16),
            FontFace = UI.font,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            Parent = dropdown_frame,
        })
        
        local dropdown_button = create_instance("TextButton", {
            Name = "Dropdown",
            BackgroundColor3 = Color3_fromRGB(45, 45, 45),
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 20),
            Text = dropdown.default,
            AutoButtonColor = false,
            Parent = dropdown_frame,
        })
        UI:AttachTheme(dropdown_button, { BackgroundColor3 = "background" })
        create_instance("UICorner", { Parent = dropdown_button, CornerRadius = UDim_new(0, 4) })
        
        if dropdown_options.Description then
            local dropdown_desc = create_instance("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Text = dropdown_options.Description,
                TextColor3 = Color3_fromRGB(128, 128, 128),
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2_new(1, 0, 0, 12),
                Position = UDim2_new(0, 0, 0, 22),
                FontFace = UI.font,
                TextSize = 10,
                TextStrokeTransparency = 0,
                Parent = dropdown_frame,
            })
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
        
        table_insert(section.elements, dropdown_api)
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
        
        local slider_frame = create_instance("Frame", {
            Name = slider.name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 40),
            Parent = section_frame,
        })
        
        local slider_list = create_instance("UIListLayout", {
            Padding = UDim_new(0, 4),
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = slider_frame,
        })
        
        local slider_label = create_instance("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Text = slider.name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2_new(1, 0, 0, 16),
            FontFace = UI.font,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            Parent = slider_frame,
        })
        
        local slider_button = create_instance("TextButton", {
            Name = "Slider",
            BackgroundColor3 = Color3_fromRGB(45, 45, 45),
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 16),
            Text = tostring(slider.default) .. slider.suffix,
            AutoButtonColor = false,
            Parent = slider_frame,
        })
        UI:AttachTheme(slider_button, { BackgroundColor3 = "background" })
        create_instance("UICorner", { Parent = slider_button, CornerRadius = UDim_new(0, 4) })
        
        if slider_options.Description then
            local slider_desc = create_instance("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Text = slider_options.Description,
                TextColor3 = Color3_fromRGB(128, 128, 128),
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2_new(1, 0, 0, 12),
                Position = UDim2_new(0, 0, 0, 22),
                FontFace = UI.font,
                TextSize = 10,
                TextStrokeTransparency = 0,
                Parent = slider_frame,
            })
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
        
        table_insert(section.elements, slider_api)
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
        
        local colorpicker_frame = create_instance("Frame", {
            Name = colorpicker.name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 20),
            Parent = section_frame,
        })
        
        local colorpicker_list = create_instance("UIListLayout", {
            Padding = UDim_new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = colorpicker_frame,
        })
        
        local colorpicker_label = create_instance("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Text = colorpicker.name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2_new(1, -20, 0, 16),
            FontFace = UI.font,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            Parent = colorpicker_frame,
        })
        
        local color_icon = create_instance("TextButton", {
            Name = "Color",
            BackgroundColor3 = colorpicker.default,
            BorderColor3 = Color3_fromRGB(36, 36, 36),
            BorderSizePixel = 1,
            Position = UDim2_new(1, -18, 0.5, 0),
            Size = UDim2_new(0, 16, 0, 16),
            Text = "",
            ZIndex = 99,
            AutoButtonColor = false,
            Parent = colorpicker_frame,
        })
        create_instance("UICorner", { Parent = color_icon, CornerRadius = UDim_new(1, 0) })
        
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
        
        table_insert(section.elements, colorpicker_api)
        return colorpicker_api
    end
    
    function section:button(button_options)
        local button = {
            name = button_options.Name or button_options.name or "Button",
            description = button_options.Description or button_options.description or "",
            callback = button_options.Callback or button_options.callback or function() end,
        }
        
        local button_frame = create_instance("Frame", {
            Name = button.name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 24),
            Parent = section_frame,
        })
        
        local button_list = create_instance("UIListLayout", {
            Padding = UDim_new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = button_frame,
        })
        
        local button_label = create_instance("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Text = button.name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2_new(1, -70, 0, 16),
            FontFace = UI.font,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            Parent = button_frame,
        })
        
        local button_click = create_instance("TextButton", {
            Name = "Button",
            BackgroundColor3 = Color3_fromRGB(45, 45, 45),
            BorderSizePixel = 0,
            Size = UDim2_new(0, 60, 0, 18),
            Text = button.name,
            AutoButtonColor = false,
            Parent = button_frame,
        })
        UI:AttachTheme(button_click, { BackgroundColor3 = "background" })
        create_instance("UICorner", { Parent = button_click, CornerRadius = UDim_new(0, 4) })
        
        button_click.MouseButton1Click:Connect(function()
            if button.callback then button.callback() end
        end)
        
        if button_options.Description then
            local button_desc = create_instance("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Text = button_options.Description,
                TextColor3 = Color3_fromRGB(128, 128, 128),
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2_new(1, -70, 0, 12),
                Position = UDim2_new(0, 0, 0, 18),
                FontFace = UI.font,
                TextSize = 10,
                TextStrokeTransparency = 0,
                Parent = button_frame,
            })
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
        
        local keybind_frame = create_instance("Frame", {
            Name = keybind.name,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2_new(1, 0, 0, 24),
            Parent = section_frame,
        })
        
        local keybind_list = create_instance("UIListLayout", {
            Padding = UDim_new(0, 4),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = keybind_frame,
        })
        
        local keybind_label = create_instance("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Text = keybind.name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2_new(1, -70, 0, 16),
            FontFace = UI.font,
            TextSize = UI.font_size,
            TextStrokeTransparency = 0,
            Parent = keybind_frame,
        })
        
        local keybind_button = create_instance("TextButton", {
            Name = "Keybind",
            BackgroundColor3 = Color3_fromRGB(45, 45, 45),
            BorderSizePixel = 0,
            Size = UDim2_new(0, 60, 0, 18),
            Text = keybind.default.Name or "Unknown",
            AutoButtonColor = false,
            Parent = keybind_frame,
        })
        UI:AttachTheme(keybind_button, { BackgroundColor3 = "background" })
        create_instance("UICorner", { Parent = keybind_button, CornerRadius = UDim_new(0, 4) })
        
        if keybind_options.Description then
            local keybind_desc = create_instance("TextLabel", {
                Name = "Description",
                BackgroundTransparency = 1,
                Text = keybind_options.Description,
                TextColor3 = Color3_fromRGB(128, 128, 128),
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2_new(1, -70, 0, 12),
                Position = UDim2_new(0, 0, 0, 18),
                FontFace = UI.font,
                TextSize = 10,
                TextStrokeTransparency = 0,
                Parent = keybind_frame,
            })
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
    
    table_insert(page.sections, section)
    return section
end

-- // Menu, Extra, Configs, Themes shortcuts
function UI:Menu(tab) end
function UI:Extra(tab) end
function UI:Configs(tab) end
function UI:Themes(tab) end

-- // Return UI
return UI
