-- ============================================================
-- WindUI 完整版（所有模块已补全）
-- 右上角按钮使用 macOS 红黄绿圆点风格
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ============================================================
-- 1. 形状系统（完整版）
-- ============================================================
local Shapes = {
    Circle = { Image = "rbxassetid://111665032676235", Rect = Rect.new(512,512,512,512), Radius = 512 },
    CircleOutline = { Image = "rbxassetid://108556680453287", Rect = Rect.new(512,512,512,512), Radius = 512 },
    CircleGlass = { Image = "rbxassetid://95600044758841", Rect = Rect.new(512,512,512,512), Radius = 512 },
    SquircleH = { Image = "rbxassetid://125083578015333", Rect = Rect.new(512,325,512,325), Radius = 325 },
    SquircleHOutline = { Image = "rbxassetid://107043713170567", Rect = Rect.new(512,325,512,325), Radius = 325 },
    SquircleHGlass = { Image = "rbxassetid://84819521201001", Rect = Rect.new(512,325,512,325), Radius = 325 },
    ["SquircleH-TL-TR"] = { Image = "rbxassetid://90680657206619", Rect = Rect.new(807,512,807,512), Radius = 325, AutoChange = false },
    ["SquircleH-BL-BR"] = { Image = "rbxassetid://99216342056719", Rect = Rect.new(0,512,0,512), Radius = 325, AutoChange = false },
    SquircleV = { Image = "rbxassetid://124965260437653", Rect = Rect.new(325,512,325,512), Radius = 325 },
    SquircleVOutline = { Image = "rbxassetid://88808835404198", Rect = Rect.new(325,512,325,512), Radius = 325 },
    SquircleVGlass = { Image = "rbxassetid://124982801466667", Rect = Rect.new(325,512,325,512), Radius = 325 },
    Squircle = { Image = "rbxassetid://89641024074289", Rect = Rect.new(460,460,460,460), Radius = 310 },
    SquircleOutline = { Image = "rbxassetid://74029063732681", Rect = Rect.new(512,512,512,512), Radius = 310 },
    SquircleGlass = { Image = "rbxassetid://131126436897551", Rect = Rect.new(512,512,512,512), Radius = 310 },
    ["Squircle-TL-TR"] = { Image = "rbxassetid://75712142040725", Rect = Rect.new(512,512,512,512), Radius = 310, AutoChange = false },
    ["Squircle-BL-BR"] = { Image = "rbxassetid://83676684425544", Rect = Rect.new(512,0,512,0), Radius = 310, AutoChange = false },
    Square = { Image = "rbxassetid://82909646051652", Rect = Rect.new(512,512,512,512), Radius = 512, AutoChange = false },
    ["Shadow-sm"] = { Image = "rbxassetid://8992230677", Rect = Rect.new(512,512,512,512), Radius = 512, AutoChange = false },
}

local function GetShape(shapeType)
    return Shapes[shapeType] or Shapes.Circle
end

function NewRoundFrame(radius, shapeType, props, children)
    local shape = shapeType or "Circle"
    local s = GetShape(shape)

    local r = Instance.new("ImageLabel")
    r.BackgroundTransparency = 1
    r.ScaleType = Enum.ScaleType.Slice
    r.SliceCenter = s.Rect
    r.SliceScale = math.max(radius / s.Radius, 0.0001)
    r.Image = s.Image
    r.Size = UDim2.new(1, 0, 1, 0)

    if props then
        for k, v in pairs(props) do
            if k ~= "ThemeTag" then
                r[k] = v
            end
        end
    end

    local currentShape = shapeType or "Circle"
    r:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if s.AutoChange == false then return end
        local size = r.AbsoluteSize
        if size.X == 0 or size.Y == 0 then return end

        if string.find(currentShape, "Squircle") then
            local isGlass = string.find(currentShape, "Glass") and "Glass" or ""
            local isOutline = string.find(currentShape, "Outline") and "Outline" or ""
            local rad = radius ~= 0 and radius or math.min(size.X, size.Y) / 2
            local ratio = Shapes.Squircle.Radius / 1024
            local threshold = rad / math.min(size.X, size.Y)
            local newShape

            if size.X > size.Y then
                newShape = threshold >= ratio and ("SquircleH" .. (isOutline or isGlass or ""))
                    or ("Squircle" .. (isOutline or isGlass or ""))
            elseif size.X < size.Y then
                newShape = threshold >= ratio and ("SquircleV" .. (isOutline or isGlass or ""))
                    or ("Squircle" .. (isOutline or isGlass or ""))
            else
                newShape = threshold >= ratio and ("Circle" .. (isOutline or isGlass or ""))
                    or ("Squircle" .. (isOutline or isGlass or ""))
            end

            if newShape ~= currentShape then
                local ns = GetShape(newShape)
                r.Image = ns.Image
                r.SliceCenter = ns.Rect
                r.SliceScale = math.max(radius / ns.Radius, 0.0001)
                currentShape = newShape
            end
        end
    end)

    if children then
        for _, child in ipairs(children) do
            if child then child.Parent = r end
        end
    end

    return r
end

-- ============================================================
-- 2. 主题系统（完整版）
-- ============================================================
local Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(28, 28, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 122, 255),
        Dialog = Color3.fromRGB(38, 38, 40),
        Outline = Color3.fromRGB(255, 255, 255),
        Placeholder = Color3.fromRGB(160, 160, 160),
        Button = Color3.fromRGB(82, 82, 91),
        Icon = Color3.fromRGB(160, 160, 170),
        Toggle = Color3.fromRGB(52, 199, 89),
        Slider = Color3.fromRGB(0, 145, 255),
        Checkbox = Color3.fromRGB(0, 145, 255),
        BackgroundTransparency = 0,
        PanelBackgroundTransparency = 0.92,
        ElementBackgroundTransparency = 0,
        PanelBackground = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(42, 42, 44),
        TabBackground = Color3.fromRGB(28, 28, 30),
        TabBackgroundHover = Color3.fromRGB(50, 50, 55),
        TabBackgroundActive = Color3.fromRGB(60, 60, 65),
        TabBackgroundHoverTransparency = 0.92,
        TabBackgroundActiveTransparency = 0.9,
        TabTextTransparency = 0.4,
        TabTextTransparencyActive = 0,
        TabIconTransparency = 0.4,
        TabIconTransparencyActive = 0.1,
        TabBorderTransparency = 1,
        TabBorderTransparencyActive = 0.75,
        TabBorder = Color3.fromRGB(255, 255, 255),
        WindowTopbarTitle = Color3.fromRGB(255, 255, 255),
        WindowTopbarAuthor = Color3.fromRGB(180, 180, 180),
        WindowTopbarIcon = Color3.fromRGB(200, 200, 200),
        WindowTopbarButtonIcon = Color3.fromRGB(180, 180, 180),
        WindowBackground = Color3.fromRGB(28, 28, 30),
        WindowShadow = Color3.fromRGB(0, 0, 0),
        TabTitle = Color3.fromRGB(255, 255, 255),
        TabIcon = Color3.fromRGB(200, 200, 200),
        ElementTitle = Color3.fromRGB(255, 255, 255),
        ElementDesc = Color3.fromRGB(180, 180, 180),
        ElementIcon = Color3.fromRGB(200, 200, 200),
        Notification = Color3.fromRGB(38, 38, 40),
        Notification2 = Color3.fromRGB(255, 255, 255),
        Notification2Transparency = 0.92,
        NotificationTitle = Color3.fromRGB(255, 255, 255),
        NotificationContent = Color3.fromRGB(200, 200, 200),
        NotificationDuration = Color3.fromRGB(255, 255, 255),
        NotificationDurationTransparency = 0.92,
        NotificationBorder = Color3.fromRGB(255, 255, 255),
        NotificationBorderTransparency = 0.75,
        Tooltip = Color3.fromRGB(76, 76, 76),
        TooltipText = Color3.fromRGB(255, 255, 255),
        TooltipSecondary = Color3.fromRGB(0, 122, 255),
        TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
        DialogBackground = Color3.fromRGB(38, 38, 40),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromRGB(255, 255, 255),
        DialogContent = Color3.fromRGB(200, 200, 200),
        DialogIcon = Color3.fromRGB(200, 200, 200),
        PopupBackground = Color3.fromRGB(38, 38, 40),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromRGB(255, 255, 255),
        PopupContent = Color3.fromRGB(200, 200, 200),
        PopupIcon = Color3.fromRGB(200, 200, 200),
        LabelBackground = Color3.fromRGB(0, 0, 0),
        LabelBackgroundTransparency = 0.83,
        ProgressBar = Color3.fromRGB(0, 122, 255),
        ProgressBarTrack = Color3.fromRGB(255, 255, 255),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromRGB(255, 255, 255),
        DropdownTabBackground = Color3.fromRGB(42, 42, 44),
        DropdownBackground = Color3.fromRGB(38, 38, 40),
        DropdownTabBorder = Color3.fromRGB(255, 255, 255),
        SearchBarBackground = Color3.fromRGB(38, 38, 40),
        SearchBarBorder = Color3.fromRGB(255, 255, 255),
        SearchBarBorderTransparency = 0.75,
        SectionIcon = Color3.fromRGB(200, 200, 200),
        SectionExpandIcon = Color3.fromRGB(200, 200, 200),
        SectionExpandIconTransparency = 0.4,
        SectionBox = Color3.fromRGB(255, 255, 255),
        SectionBoxTransparency = 0.95,
        SectionBoxBorder = Color3.fromRGB(255, 255, 255),
        SectionBoxBorderTransparency = 0.75,
        SectionBoxBackground = Color3.fromRGB(255, 255, 255),
        SectionBoxBackgroundTransparency = 0.97,
        ViewportBackground = Color3.fromRGB(42, 42, 44),
        ViewportBackgroundTransparency = 0,
        SliderIcon = Color3.fromRGB(144, 143, 149),
        Primary = Color3.fromRGB(0, 145, 255),
        ToggleBar = Color3.fromRGB(255, 255, 255),
        CheckboxIcon = Color3.fromRGB(255, 255, 255),
        CheckboxBorder = Color3.fromRGB(255, 255, 255),
        CheckboxBorderTransparency = 0.75,
        SliderThumb = Color3.fromRGB(255, 255, 255),
        ThemeTag = {},
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(240, 240, 242),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(0, 122, 255),
        Dialog = Color3.fromRGB(235, 235, 237),
        Outline = Color3.fromRGB(255, 255, 255),
        Placeholder = Color3.fromRGB(120, 120, 120),
        Button = Color3.fromRGB(24, 24, 27),
        Icon = Color3.fromRGB(82, 82, 91),
        Toggle = Color3.fromRGB(52, 199, 89),
        Slider = Color3.fromRGB(0, 145, 255),
        Checkbox = Color3.fromRGB(0, 145, 255),
        BackgroundTransparency = 0,
        PanelBackgroundTransparency = 0,
        ElementBackgroundTransparency = 0,
        PanelBackground = Color3.fromRGB(235, 235, 237),
        ElementBackground = Color3.fromRGB(255, 255, 255),
        TabBackground = Color3.fromRGB(240, 240, 242),
        TabBackgroundHover = Color3.fromRGB(225, 225, 228),
        TabBackgroundActive = Color3.fromRGB(215, 215, 220),
        TabBackgroundHoverTransparency = 0,
        TabBackgroundActiveTransparency = 0,
        TabTextTransparency = 0.3,
        TabTextTransparencyActive = 0,
        TabIconTransparency = 0.3,
        TabIconTransparencyActive = 0,
        TabBorderTransparency = 1,
        TabBorderTransparencyActive = 0.7,
        TabBorder = Color3.fromRGB(0, 0, 0),
        WindowTopbarTitle = Color3.fromRGB(0, 0, 0),
        WindowTopbarAuthor = Color3.fromRGB(120, 120, 120),
        WindowTopbarIcon = Color3.fromRGB(80, 80, 80),
        WindowTopbarButtonIcon = Color3.fromRGB(80, 80, 80),
        WindowBackground = Color3.fromRGB(240, 240, 242),
        WindowShadow = Color3.fromRGB(0, 0, 0),
        TabTitle = Color3.fromRGB(0, 0, 0),
        TabIcon = Color3.fromRGB(80, 80, 80),
        ElementTitle = Color3.fromRGB(0, 0, 0),
        ElementDesc = Color3.fromRGB(120, 120, 120),
        ElementIcon = Color3.fromRGB(80, 80, 80),
        Notification = Color3.fromRGB(235, 235, 237),
        Notification2 = Color3.fromRGB(255, 255, 255),
        Notification2Transparency = 0.9,
        NotificationTitle = Color3.fromRGB(0, 0, 0),
        NotificationContent = Color3.fromRGB(100, 100, 100),
        NotificationDuration = Color3.fromRGB(0, 0, 0),
        NotificationDurationTransparency = 0.9,
        NotificationBorder = Color3.fromRGB(0, 0, 0),
        NotificationBorderTransparency = 0.7,
        Tooltip = Color3.fromRGB(200, 200, 200),
        TooltipText = Color3.fromRGB(0, 0, 0),
        TooltipSecondary = Color3.fromRGB(0, 122, 255),
        TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
        DialogBackground = Color3.fromRGB(235, 235, 237),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromRGB(0, 0, 0),
        DialogContent = Color3.fromRGB(100, 100, 100),
        DialogIcon = Color3.fromRGB(80, 80, 80),
        PopupBackground = Color3.fromRGB(235, 235, 237),
        PopupBackgroundTransparency = 0,
        PopupTitle = Color3.fromRGB(0, 0, 0),
        PopupContent = Color3.fromRGB(100, 100, 100),
        PopupIcon = Color3.fromRGB(80, 80, 80),
        LabelBackground = Color3.fromRGB(200, 200, 200),
        LabelBackgroundTransparency = 0,
        ProgressBar = Color3.fromRGB(0, 122, 255),
        ProgressBarTrack = Color3.fromRGB(0, 0, 0),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromRGB(0, 0, 0),
        DropdownTabBackground = Color3.fromRGB(220, 220, 225),
        DropdownBackground = Color3.fromRGB(240, 240, 242),
        DropdownTabBorder = Color3.fromRGB(0, 0, 0),
        SearchBarBackground = Color3.fromRGB(235, 235, 237),
        SearchBarBorder = Color3.fromRGB(0, 0, 0),
        SearchBarBorderTransparency = 0.7,
        SectionIcon = Color3.fromRGB(80, 80, 80),
        SectionExpandIcon = Color3.fromRGB(80, 80, 80),
        SectionExpandIconTransparency = 0.3,
        SectionBox = Color3.fromRGB(0, 0, 0),
        SectionBoxTransparency = 0.95,
        SectionBoxBorder = Color3.fromRGB(0, 0, 0),
        SectionBoxBorderTransparency = 0.7,
        SectionBoxBackground = Color3.fromRGB(0, 0, 0),
        SectionBoxBackgroundTransparency = 0.97,
        ViewportBackground = Color3.fromRGB(220, 220, 225),
        ViewportBackgroundTransparency = 0,
        SliderIcon = Color3.fromRGB(100, 100, 105),
        Primary = Color3.fromRGB(0, 145, 255),
        ToggleBar = Color3.fromRGB(255, 255, 255),
        CheckboxIcon = Color3.fromRGB(255, 255, 255),
        CheckboxBorder = Color3.fromRGB(0, 0, 0),
        CheckboxBorderTransparency = 0.7,
        SliderThumb = Color3.fromRGB(255, 255, 255),
        ThemeTag = {},
    }
}

local CurrentTheme = Themes.Dark
local ThemeChangeCallbacks = {}

function SetTheme(name)
    local theme = Themes[name]
    if not theme then
        warn("[WindUI] Theme not found:", name)
        return
    end
    CurrentTheme = theme
    for _, callback in ipairs(ThemeChangeCallbacks) do
        SafeCallback(callback, name)
    end
end

function GetTheme()
    return CurrentTheme
end

function GetThemeColor(key, fallback)
    local value = CurrentTheme[key]
    if value ~= nil then
        return value
    end
    local darkValue = Themes.Dark[key]
    if darkValue ~= nil then
        return darkValue
    end
    return fallback or Color3.fromRGB(255, 0, 255)
end

function GetThemeTransparency(key, fallback)
    local value = CurrentTheme[key]
    if type(value) == "number" then
        return value
    end
    return fallback or 0
end

function OnThemeChange(callback)
    table.insert(ThemeChangeCallbacks, callback)
    return {
        Disconnect = function()
            for i, cb in ipairs(ThemeChangeCallbacks) do
                if cb == callback then
                    table.remove(ThemeChangeCallbacks, i)
                    break
                end
            end
        end
    }
end

function ApplyThemeTag(object, tag)
    if not tag then return end
    for property, key in pairs(tag) do
        if property == "ImageColor3" then
            object.ImageColor3 = GetThemeColor(key)
        elseif property == "TextColor3" then
            object.TextColor3 = GetThemeColor(key)
        elseif property == "BackgroundColor3" then
            object.BackgroundColor3 = GetThemeColor(key)
        elseif property == "ImageTransparency" then
            object.ImageTransparency = GetThemeTransparency(key)
        elseif property == "TextTransparency" then
            object.TextTransparency = GetThemeTransparency(key)
        elseif property == "BackgroundTransparency" then
            object.BackgroundTransparency = GetThemeTransparency(key)
        elseif property == "PlaceholderColor3" then
            if object.PlaceholderColor3 ~= nil then
                object.PlaceholderColor3 = GetThemeColor(key)
            end
        end
    end
end

-- ============================================================
-- 3. 图标系统（完整版）
-- ============================================================
local Icons = {
    search = "rbxassetid://92867583610071",
    x = "rbxassetid://110786993356448",
    check = "rbxassetid://93898873302694",
    plus = "rbxassetid://111774323017047",
    minus = "rbxassetid://118026365011536",
    ["chevron-down"] = "rbxassetid://134243273101015",
    ["chevron-up"] = "rbxassetid://122444883127455",
    ["chevron-left"] = "rbxassetid://73780377692148",
    ["chevron-right"] = "rbxassetid://92473583511724",
    maximize = "rbxassetid://76045941763188",
    minimize = "rbxassetid://118026365011536",
    close = "rbxassetid://110786993356448",
    home = "rbxassetid://98755624629571",
    settings = "rbxassetid://80758916183665",
    lock = "rbxassetid://134724289526879",
    unlock = "rbxassetid://93597915325122",
    user = "rbxassetid://81589895647169",
    folder = "rbxassetid://80846616596607",
    trash = "rbxassetid://106723740584310",
    edit = "rbxassetid://72037878096321",
    copy = "rbxassetid://78979572434545",
    link = "rbxassetid://131607023382430",
    external = "rbxassetid://129331830773832",
    download = "rbxassetid://134814648082393",
    upload = "rbxassetid://138212042425501",
    refresh = "rbxassetid://138133190015277",
    arrowLeft = "rbxassetid://102531941843733",
    arrowRight = "rbxassetid://113692007244654",
    arrowUp = "rbxassetid://89282378235317",
    arrowDown = "rbxassetid://98764963621439",
    ["mouse-pointer-click"] = "rbxassetid://107150227368485",
    ["square-mouse-pointer"] = "rbxassetid://76141850603920",
    ["toggle-right"] = "rbxassetid://90411952142550",
    ["sliders-horizontal"] = "rbxassetid://85538382643347",
    command = "rbxassetid://93648221906330",
    ["text-cursor-input"] = "rbxassetid://107551944047171",
    ["chevrons-up-down"] = "rbxassetid://131833120209646",
    terminal = "rbxassetid://106783148545356",
    palette = "rbxassetid://86350350950064",
    ["chart-bar"] = "rbxassetid://105389816384108",
    ["table-of-contents"] = "rbxassetid://135044763275414",
    type = "rbxassetid://133543553793564",
    frown = "rbxassetid://124407301067982",
    move = "rbxassetid://116138709011735",
    expand = "rbxassetid://137492887754537",
    bell = "rbxassetid://97392696311902",
    star = "rbxassetid://136141469398409",
    layers = "rbxassetid://81973586053257",
}

function GetIcon(name)
    return Icons[name] or "rbxassetid://92867583610071"
end

function SafeCallback(func, ...)
    if not func then return end
    local success, err = pcall(func, ...)
    if not success then
        warn("[WindUI] Callback error:", err)
    end
    return success
end

-- ============================================================
-- 4. 窗口系统（完整版，含 macOS 右上角按钮）
-- ============================================================
function CreateWindow(config)
    config = config or {}

    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local w = isMobile and viewport.X * 0.92 or math.min(config.Width or 580, viewport.X * 0.5)
    local h = isMobile and viewport.Y * 0.82 or math.min(config.Height or 440, viewport.Y * 0.6)
    local radius = isMobile and 20 or (config.Radius or 16)
    local titleHeight = isMobile and 56 or (config.TitleHeight or 52)
    local iconSize = config.IconSize or 22
    local dragFrameSize = 160
    local shadowSize = 60

    local theme = GetTheme()

    local gui = Instance.new("ScreenGui")
    gui.Name = "WindUI_Window"
    gui.ResetOnSpawn = false
    gui.Parent = config.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, w, 0, h)
    panel.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = false
    panel.Parent = gui

    local bg = NewRoundFrame(radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = theme.WindowBackground,
        ImageTransparency = 0,
        ZIndex = 1,
        Parent = panel,
    })

    local shadow = NewRoundFrame(radius, "Shadow-sm", {
        Size = UDim2.new(1, shadowSize * 2, 1, shadowSize * 2),
        Position = UDim2.new(0.5, -shadowSize, 0.5, -shadowSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = panel,
    })

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, titleHeight)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 2
    titleBar.Parent = panel

    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconContainer.Position = UDim2.new(0, 14, 0.5, 0)
    iconContainer.AnchorPoint = Vector2.new(0, 0.5)
    iconContainer.BackgroundTransparency = 1
    iconContainer.Parent = titleBar

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = GetIcon(config.Icon or "home")
    icon.ImageColor3 = theme.WindowTopbarIcon
    icon.Parent = iconContainer

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 14 + iconSize + 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "WindUI 窗口"
    titleLabel.TextColor3 = theme.WindowTopbarTitle
    titleLabel.TextSize = isMobile and 18 or 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.ZIndex = 3
    titleLabel.Parent = titleBar

    -- ============================================================
    -- 右上角控制按钮（macOS 红黄绿圆点风格）
    -- ============================================================
    local btnSize = isMobile and 40 or 36
    local spacing = isMobile and 6 or 9

    local rightContainer = Instance.new("Frame")
    rightContainer.Size = UDim2.new(0, btnSize * 3 + spacing * 2, 1, 0)
    rightContainer.Position = UDim2.new(1, -14, 0, 0)
    rightContainer.AnchorPoint = Vector2.new(1, 0)
    rightContainer.BackgroundTransparency = 1
    rightContainer.ZIndex = 3
    rightContainer.Parent = titleBar

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, spacing)
    listLayout.Parent = rightContainer

    local isMaximized = false
    local isMinimized = false
    local isClosing = false
    local prevSize, prevPos
    local maxBtn

    local function closeWindow()
        if isClosing then return end
        isClosing = true
        panel.Active = false
        local t = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, 0),
            Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0.5, 0),
        })
        t:Play()
        t.Completed:Connect(function()
            gui:Destroy()
            if config.OnClose then SafeCallback(config.OnClose) end
        end)
    end

    local function toggleMaximize()
        if isClosing then return end
        if isMinimized then panel.Visible = true isMinimized = false end
        if isMaximized then
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = prevSize,
                Position = prevPos,
            }):Play()
            isMaximized = false
            if maxBtn then maxBtn.Image = "rbxassetid://76045941763188" end
        else
            local bounds = { minX = 0, minY = 0, maxX = viewport.X, maxY = viewport.Y }
            local padding = isMobile and 8 or 20
            prevSize = panel.Size
            prevPos = panel.Position
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, bounds.maxX - padding * 2, 0, bounds.maxY - padding * 2),
                Position = UDim2.new(0, padding, 0, padding),
            }):Play()
            isMaximized = true
            if maxBtn then maxBtn.Image = "rbxassetid://121304296213645" end
        end
    end

    local function minimizeWindow()
        if isClosing or isMinimized then return end
        isMinimized = true
        local h = titleHeight
        TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, h),
            Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0.5, -h/2),
        }):Play()
        task.wait(0.3)
        panel.Visible = false
    end

    local function makeMacButton(img, layoutOrder, hoverColor, cb)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, btnSize, 0, btnSize)
        container.BackgroundTransparency = 1
        container.LayoutOrder = layoutOrder
        container.ZIndex = 3
        container.Parent = rightContainer

        local hoverBg = NewRoundFrame(999, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ZIndex = 0,
            Parent = container,
        })

        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Image = img
        btn.ImageColor3 = Color3.fromRGB(180, 180, 180)
        btn.ZIndex = 4
        btn.Parent = container

        btn.MouseEnter:Connect(function()
            TweenService:Create(hoverBg, TweenInfo.new(0.12), { ImageTransparency = 0.9 }):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), { ImageColor3 = hoverColor }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(hoverBg, TweenInfo.new(0.12), { ImageTransparency = 1 }):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), { ImageColor3 = Color3.fromRGB(180, 180, 180) }):Play()
        end)
        btn.MouseButton1Click:Connect(cb)

        return container, btn
    end

    local buttonDefs = {
        { name = "min",   image = "rbxassetid://118026365011536", order = 1, hover = Color3.fromRGB(255,200,50), callback = minimizeWindow },
        { name = "max",   image = "rbxassetid://76045941763188", order = 2, hover = Color3.fromRGB(50,200,100), callback = toggleMaximize },
        { name = "close", image = "rbxassetid://110786993356448", order = 3, hover = Color3.fromRGB(255,80,80), callback = closeWindow },
    }

    local buttonRefs = {}
    for _, def in ipairs(buttonDefs) do
        local container, btn = makeMacButton(def.image, def.order, def.hover, def.callback)
        buttonRefs[def.name] = { container = container, btn = btn }
    end
    maxBtn = buttonRefs.max.btn

    local function updateTitleSize()
        local rightWidth = rightContainer.AbsoluteSize.X
        titleLabel.Size = UDim2.new(1, -(14 + iconSize + 8 + rightWidth + 12), 1, 0)
    end
    rightContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTitleSize)
    task.spawn(updateTitleSize)

    -- ============================================================
    -- 侧边栏
    -- ============================================================
    local sideBarWidth = isMobile and 0 or (config.SideBarWidth or 200)
    local sideBar
    if sideBarWidth > 0 then
        sideBar = Instance.new("Frame")
        sideBar.Size = UDim2.new(0, sideBarWidth, 1, -titleHeight)
        sideBar.Position = UDim2.new(0, 0, 0, titleHeight)
        sideBar.BackgroundTransparency = 1
        sideBar.Visible = not isMobile
        sideBar.Parent = panel

        if not isMobile then
            local st = Instance.new("TextLabel")
            st.Size = UDim2.new(1, 0, 0, 30)
            st.Position = UDim2.new(0.5, 0, 0.5, -15)
            st.AnchorPoint = Vector2.new(0.5, 0.5)
            st.BackgroundTransparency = 1
            st.Text = "⚡ 侧边栏"
            st.TextColor3 = Color3.fromRGB(150,150,150)
            st.TextSize = 14
            st.Font = Enum.Font.GothamMedium
            st.TextTransparency = 0.5
            st.Parent = sideBar

            local div = Instance.new("Frame")
            div.Size = UDim2.new(0, 1, 1, -40)
            div.Position = UDim2.new(1, 0, 0, 20)
            div.BackgroundColor3 = Color3.fromRGB(255,255,255)
            div.BackgroundTransparency = 0.9
            div.Parent = sideBar
        end
    end

    -- ============================================================
    -- 内容区域
    -- ============================================================
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -(sideBarWidth or 0), 1, -titleHeight)
    content.Position = UDim2.new(0, (sideBarWidth or 0), 0, titleHeight)
    content.BackgroundTransparency = 1
    content.Parent = panel

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -20, 1, -20)
    contentContainer.Position = UDim2.new(0, 10, 0, 10)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = content

    -- ============================================================
    -- 底部拖动手柄
    -- ============================================================
    local dragFrame = NewRoundFrame(999, "Squircle", {
        ImageTransparency = 0.8,
        ImageColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(0, 0, 0, 4),
        Position = UDim2.new(0.5, 0, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0),
        ZIndex = 5,
        Parent = panel,
    })

    local dragButton = Instance.new("TextButton")
    dragButton.Size = UDim2.new(1, 12, 1, 12)
    dragButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    dragButton.AnchorPoint = Vector2.new(0.5, 0.5)
    dragButton.BackgroundTransparency = 1
    dragButton.Text = ""
    dragButton.Name = "Frame"
    dragButton.ZIndex = 6
    dragButton.Parent = dragFrame

    -- ============================================================
    -- 右下角缩放手柄
    -- ============================================================
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Size = UDim2.new(0, 36, 0, 36)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.ZIndex = 99
    resizeHandle.Active = true
    resizeHandle.Parent = panel

    local resizeImage = Instance.new("ImageLabel")
    resizeImage.Size = UDim2.new(0, 96, 0, 96)
    resizeImage.Position = UDim2.new(0.5, -16, 0.5, -16)
    resizeImage.AnchorPoint = Vector2.new(0.5, 0.5)
    resizeImage.BackgroundTransparency = 1
    resizeImage.Image = "rbxassetid://120997033468887"
    resizeImage.ImageColor3 = Color3.fromRGB(160, 160, 160)
    resizeImage.ImageTransparency = 0.7
    resizeImage.ZIndex = 100
    resizeImage.Parent = resizeHandle

    local maxOverlay = NewRoundFrame(radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 1,
        ImageColor3 = Color3.new(0, 0, 0),
        ZIndex = 999,
        Parent = panel,
    })

    -- ============================================================
    -- 拖拽/缩放逻辑（含边界限制）
    -- ============================================================
    local currentInput = nil
    local dragData = { active = false, input = nil, inputType = nil, start = Vector2.new(), startPos = nil, highlight = false }
    local resizeData = { active = false, input = nil, inputType = nil, start = Vector2.new(), startSize = nil }

    local minW = isMobile and 300 or 400
    local minH = isMobile and 240 or 300

    local function getScreenBounds()
        local vp = workspace.CurrentCamera.ViewportSize
        return { minX = 0, minY = 0, maxX = vp.X, maxY = vp.Y }
    end

    local function onDragStart(input, highlight)
        if isClosing or isMinimized or currentInput or isMaximized then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        currentInput = input
        dragData.active = true
        dragData.input = input
        dragData.inputType = input.UserInputType
        dragData.start = input.Position
        dragData.startPos = panel.Position
        dragData.highlight = highlight
        if highlight then TweenService:Create(dragFrame, TweenInfo.new(0.1), { ImageTransparency = 0.35 }):Play() end
    end

    local function onDragMove(input)
        if not dragData.active then return end
        local valid = false
        if dragData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseMovement then valid = true end
        elseif dragData.inputType == Enum.UserInputType.Touch then
            if input == dragData.input and input.UserInputType == Enum.UserInputType.Touch then valid = true end
        end
        if not valid then return end
        local delta = input.Position - dragData.start
        local bounds = getScreenBounds()
        local panelSize = panel.AbsoluteSize
        local newX = math.clamp(dragData.startPos.X.Offset + delta.X, bounds.minX, bounds.maxX - panelSize.X)
        local newY = math.clamp(dragData.startPos.Y.Offset + delta.Y, bounds.minY, bounds.maxY - panelSize.Y)
        panel.Position = UDim2.new(0, newX, 0, newY)
    end

    local function onDragEnd(input)
        if not dragData.active then return end
        local shouldEnd = false
        if dragData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then shouldEnd = true end
        elseif dragData.inputType == Enum.UserInputType.Touch then
            if input == dragData.input then shouldEnd = true end
        end
        if not shouldEnd then return end
        dragData.active = false
        currentInput = nil
        if dragData.highlight then TweenService:Create(dragFrame, TweenInfo.new(0.15), { ImageTransparency = 0.8 }):Play() end
        dragData.input = nil
        dragData.inputType = nil
        dragData.highlight = false
    end

    local function onResizeStart(input)
        if isClosing or isMinimized or currentInput or isMaximized then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        currentInput = input
        resizeData.active = true
        resizeData.input = input
        resizeData.inputType = input.UserInputType
        resizeData.start = input.Position
        resizeData.startSize = panel.Size
        TweenService:Create(resizeImage, TweenInfo.new(0.1), { ImageTransparency = 0.2 }):Play()
        TweenService:Create(resizeImage, TweenInfo.new(0.1), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end

    local function onResizeMove(input)
        if not resizeData.active then return end
        local valid = false
        if resizeData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseMovement then valid = true end
        elseif resizeData.inputType == Enum.UserInputType.Touch then
            if input == resizeData.input and input.UserInputType == Enum.UserInputType.Touch then valid = true end
        end
        if not valid then return end
        local delta = input.Position - resizeData.start
        local bounds = getScreenBounds()
        local newW = math.clamp(resizeData.startSize.X.Offset + delta.X, minW, maxWidth)
        local newH = math.clamp(resizeData.startSize.Y.Offset + delta.Y, minH, maxHeight)
        local currentPos = panel.Position
        local currentX = math.clamp(currentPos.X.Offset, bounds.minX, bounds.maxX - newW)
        local currentY = math.clamp(currentPos.Y.Offset, bounds.minY, bounds.maxY - newH)
        panel.Size = UDim2.new(0, newW, 0, newH)
        panel.Position = UDim2.new(0, currentX, 0, currentY)
    end

    local function onResizeEnd(input)
        if not resizeData.active then return end
        local shouldEnd = false
        if resizeData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then shouldEnd = true end
        elseif resizeData.inputType == Enum.UserInputType.Touch then
            if input == resizeData.input then shouldEnd = true end
        end
        if not shouldEnd then return end
        resizeData.active = false
        currentInput = nil
        TweenService:Create(resizeImage, TweenInfo.new(0.15), { ImageTransparency = 0.7 }):Play()
        TweenService:Create(resizeImage, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(160, 160, 160) }):Play()
        resizeData.input = nil
        resizeData.inputType = nil
        resizeData.startSize = nil
    end

    titleBar.InputBegan:Connect(function(input) onDragStart(input, false) end)
    dragButton.InputBegan:Connect(function(input) onDragStart(input, true) end)
    resizeHandle.InputBegan:Connect(onResizeStart)

    UserInputService.InputChanged:Connect(function(input)
        onDragMove(input)
        onResizeMove(input)
    end)
    UserInputService.InputEnded:Connect(function(input)
        onDragEnd(input)
        onResizeEnd(input)
    end)

    -- ============================================================
    -- 入场动画
    -- ============================================================
    panel.Size = UDim2.new(0, w, 0, 0)
    panel.Position = UDim2.new(0.5, -w/2, 0.5, 0)
    dragFrame.Size = UDim2.new(0, 0, 0, 4)

    task.spawn(function()
        task.wait(0.05)
        TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, w, 0, h),
            Position = UDim2.new(0.5, -w/2, 0.5, -h/2),
        }):Play()
        TweenService:Create(dragFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, dragFrameSize, 0, 4),
            ImageTransparency = 0.8,
        }):Play()
        task.wait(0.1)
        TweenService:Create(bg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 0,
        }):Play()
        TweenService:Create(shadow, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 1,
        }):Play()
    end)

    -- ============================================================
    -- 窗口 API
    -- ============================================================
    local window = {
        Panel = panel,
        Gui = gui,
        Content = contentContainer,
        SideBar = sideBar,
        TitleBar = titleBar,
        Close = closeWindow,
        Minimize = minimizeWindow,
        Maximize = toggleMaximize,
        IsMaximized = function() return isMaximized end,
        IsMinimized = function() return isMinimized end,
        GetContent = function() return contentContainer end,
        GetSideBar = function() return sideBar and sideBar:FindFirstChildOfClass("Frame") end,
        SetTitle = function(text) titleLabel.Text = text end,
        SetIcon = function(name) icon.Image = GetIcon(name) end,
        Center = function()
            if isMaximized then return end
            local bounds = getScreenBounds()
            local size = panel.AbsoluteSize
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, (bounds.maxX - size.X) / 2, 0, (bounds.maxY - size.Y) / 2),
            }):Play()
        end,
        SetSize = function(w, h)
            if isMaximized then return end
            panel.Size = UDim2.new(0, math.clamp(w, minWidth, maxWidth), 0, math.clamp(h, minHeight, maxHeight))
        end,
        Destroy = function()
            gui:Destroy()
            if config.OnDestroy then SafeCallback(config.OnDestroy) end
        end,
    }

    return window
end

-- ============================================================
-- 5. 标签页系统
-- ============================================================
local TabManager = {}
TabManager.__index = TabManager

function TabManager.new(window)
    local self = setmetatable({}, TabManager)
    self.Window = window
    self.Tabs = {}
    self.TabContainers = {}
    self.SelectedTab = nil
    self.TabCount = 0
    self.OnChangeCallback = nil

    local sideBar = window:GetSideBar()
    if not sideBar then error("窗口没有侧边栏") end

    self.TabList = Instance.new("Frame")
    self.TabList.Size = UDim2.new(1, 0, 0, 0)
    self.TabList.BackgroundTransparency = 1
    self.TabList.AutomaticSize = Enum.AutomaticSize.Y
    self.TabList.Parent = sideBar

    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.Padding = UDim.new(0, 4)
    self.TabLayout.Parent = self.TabList

    return self
end

function TabManager:AddTab(config)
    config = config or {}
    self.TabCount = self.TabCount + 1
    local index = self.TabCount
    local theme = GetTheme()

    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -8, 0, 36)
    tabButton.Position = UDim2.new(0, 4, 0, 0)
    tabButton.BackgroundTransparency = 1
    tabButton.Text = ""
    tabButton.LayoutOrder = index
    tabButton.Parent = self.TabList

    local tabBg = NewRoundFrame(10, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = tabButton,
    })

    local tabHover = NewRoundFrame(10, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = tabButton,
    })

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, -12, 1, 0)
    tabContent.Position = UDim2.new(0, 6, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = tabButton

    local icon
    if config.Icon then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = GetIcon(config.Icon)
        icon.ImageColor3 = theme.Icon
        icon.ImageTransparency = 0.4
        icon.Parent = tabContent
    end

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -(icon and 24 or 0), 1, 0)
    title.Position = UDim2.new(icon and 24 or 0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "标签页 " .. index
    title.TextColor3 = theme.Text
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.TextTransparency = 0.4
    title.Parent = tabContent

    local lockIcon
    if config.Locked then
        lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 14, 0, 14)
        lockIcon.Position = UDim2.new(1, -16, 0.5, 0)
        lockIcon.AnchorPoint = Vector2.new(1, 0.5)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = GetIcon("lock")
        lockIcon.ImageColor3 = theme.Icon
        lockIcon.ImageTransparency = 0.5
        lockIcon.Parent = tabContent
        title.Size = UDim2.new(1, -(icon and 24 or 0) - 18, 1, 0)
    end

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 0
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.ScrollingDirection = Enum.ScrollingDirection.Y
    container.Visible = false
    container.Parent = self.Window:GetContent()

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = container

    local tab = {
        Index = index,
        Title = config.Title or "标签页 " .. index,
        Icon = config.Icon,
        Locked = config.Locked or false,
        Button = tabButton,
        Container = container,
        ContentLayout = contentLayout,
        Elements = {},
        Selected = false,
        TabManager = self,
    }

    function tab:Select()
        if self.Locked then return end
        self.TabManager:SelectTab(self.Index)
    end

    function tab:SetTitle(newTitle)
        self.Title = newTitle
        title.Text = newTitle
    end

    function tab:SetLocked(locked)
        self.Locked = locked
        if lockIcon then lockIcon.Visible = locked end
        if locked then
            title.TextTransparency = 0.6
            if icon then icon.ImageTransparency = 0.6 end
        else
            title.TextTransparency = self.Selected and 0 or 0.4
            if icon then icon.ImageTransparency = self.Selected and 0.1 or 0.4 end
        end
    end

    function tab:GetContainer()
        return self.Container
    end

    function tab:GetLayout()
        return self.ContentLayout
    end

    function tab:Clear()
        for _, child in ipairs(self.Container:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        self.Elements = {}
    end

    tabButton.MouseEnter:Connect(function()
        if not tab.Locked then
            TweenService:Create(tabHover, TweenInfo.new(0.08), {
                ImageTransparency = 0.92,
                ImageColor3 = theme.TabBackgroundHover,
            }):Play()
        end
    end)
    tabButton.MouseLeave:Connect(function()
        TweenService:Create(tabHover, TweenInfo.new(0.08), { ImageTransparency = 1 }):Play()
    end)
    tabButton.MouseButton1Click:Connect(function()
        if not tab.Locked then
            tab:Select()
        end
    end)

    self.Tabs[index] = tab
    self.TabContainers[index] = container

    if not self.SelectedTab and not tab.Locked then
        self:SelectTab(index)
    end

    return tab
end

function TabManager:SelectTab(index)
    local tab = self.Tabs[index]
    if not tab or tab.Locked then return end

    for i, t in pairs(self.Tabs) do
        t.Selected = false
        if self.TabContainers[i] then self.TabContainers[i].Visible = false end
        local bg = t.Button:FindFirstChildOfClass("ImageLabel")
        if bg then bg.ImageTransparency = 1 end
        local titleLabel = t.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
        if titleLabel then titleLabel.TextTransparency = t.Locked and 0.6 or 0.4 end
        local icon = t.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("ImageLabel")
        if icon then icon.ImageTransparency = t.Locked and 0.6 or 0.4 end
    end

    tab.Selected = true
    self.SelectedTab = index
    if self.TabContainers[index] then self.TabContainers[index].Visible = true end

    local bg = tab.Button:FindFirstChildOfClass("ImageLabel")
    if bg then bg.ImageTransparency = 0.9 bg.ImageColor3 = GetThemeColor("TabBackgroundActive") end
    local titleLabel = tab.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
    if titleLabel then titleLabel.TextTransparency = 0 end
    local icon = tab.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("ImageLabel")
    if icon then icon.ImageTransparency = 0.1 end

    if self.OnChangeCallback then SafeCallback(self.OnChangeCallback, index, tab) end
end

function TabManager:GetContainer()
    return self.SelectedTab and self.TabContainers[self.SelectedTab]
end

function TabManager:GetSelectedTab()
    return self.SelectedTab and self.Tabs[self.SelectedTab]
end

function TabManager:GetAllTabs()
    return self.Tabs
end

function TabManager:OnChange(callback)
    self.OnChangeCallback = callback
end

function TabManager:EnableSearch(placeholder)
    if self.SearchBar then return end
    local sideBar = self.Window:GetSideBar()
    if not sideBar then return end

    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(1, -8, 0, 36)
    searchContainer.Position = UDim2.new(0, 4, 0, 0)
    searchContainer.BackgroundTransparency = 1
    searchContainer.LayoutOrder = -1
    searchContainer.Parent = sideBar

    local searchBg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.9,
        ImageColor3 = GetThemeColor("SearchBarBackground"),
        Parent = searchContainer,
    })

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 10, 0.5, 0)
    searchIcon.AnchorPoint = Vector2.new(0, 0.5)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = GetIcon("search")
    searchIcon.ImageColor3 = GetThemeColor("Icon")
    searchIcon.ImageTransparency = 0.5
    searchIcon.Parent = searchBg

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -36, 1, 0)
    searchBox.Position = UDim2.new(0, 32, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = placeholder or "搜索标签页..."
    searchBox.TextColor3 = GetThemeColor("Text")
    searchBox.PlaceholderColor3 = GetThemeColor("Placeholder")
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchBg

    local clearBtn = Instance.new("ImageButton")
    clearBtn.Size = UDim2.new(0, 16, 0, 16)
    clearBtn.Position = UDim2.new(1, -10, 0.5, 0)
    clearBtn.AnchorPoint = Vector2.new(1, 0.5)
    clearBtn.BackgroundTransparency = 1
    clearBtn.Image = GetIcon("x")
    clearBtn.ImageColor3 = GetThemeColor("Icon")
    clearBtn.ImageTransparency = 1
    clearBtn.Visible = false
    clearBtn.Parent = searchBg

    self.SearchBar = { Container = searchContainer, Box = searchBox, Clear = clearBtn }

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        local hasQuery = #query > 0
        clearBtn.Visible = hasQuery
        clearBtn.ImageTransparency = hasQuery and 0.5 or 1

        for i, tab in pairs(self.Tabs) do
            local title = tab.Title:lower()
            local visible = not hasQuery or string.find(title, query, 1, true) ~= nil
            tab.Button.Visible = visible
            if not visible and self.TabContainers[i] then
                if self.SelectedTab == i then self:SelectFirstVisible() end
            end
        end
        self:UpdateEmptyState()
    end)

    clearBtn.MouseButton1Click:Connect(function()
        searchBox.Text = ""
        clearBtn.Visible = false
        clearBtn.ImageTransparency = 1
    end)
end

function TabManager:SelectFirstVisible()
    for i, tab in pairs(self.Tabs) do
        if tab.Button.Visible and not tab.Locked then
            self:SelectTab(i)
            return
        end
    end
end

function TabManager:UpdateEmptyState()
    local hasVisible = false
    for _, tab in pairs(self.Tabs) do
        if tab.Button.Visible then hasVisible = true break end
    end

    if not hasVisible then
        if not self.EmptyState then
            local sideBar = self.Window:GetSideBar()
            if sideBar then
                self.EmptyState = Instance.new("TextLabel")
                self.EmptyState.Size = UDim2.new(1, -8, 0, 30)
                self.EmptyState.Position = UDim2.new(0, 4, 0, 0)
                self.EmptyState.BackgroundTransparency = 1
                self.EmptyState.Text = "🔍 没有匹配的标签页"
                self.EmptyState.TextColor3 = GetThemeColor("Placeholder")
                self.EmptyState.TextSize = 14
                self.EmptyState.Font = Enum.Font.GothamMedium
                self.EmptyState.TextTransparency = 0.5
                self.EmptyState.Parent = sideBar
            end
        else
            self.EmptyState.Visible = true
        end
    else
        if self.EmptyState then self.EmptyState.Visible = false end
    end
end

function TabManager:RemoveTab(index)
    local tab = self.Tabs[index]
    if not tab then return end
    tab.Button:Destroy()
    if self.TabContainers[index] then self.TabContainers[index]:Destroy() end
    self.Tabs[index] = nil
    self.TabContainers[index] = nil
    if self.SelectedTab == index then
        self.SelectedTab = nil
        for i, t in pairs(self.Tabs) do
            if not t.Locked then self:SelectTab(i) break end
        end
    end
end

-- ============================================================
-- 6. 基础元素
-- ============================================================
local Elements = {}

function Elements.Button(config)
    config = config or {}
    local theme = GetTheme()
    local button = Instance.new("TextButton")
    button.Size = config.Size or UDim2.new(0, 120, 0, 36)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = theme.Primary,
        ImageTransparency = 0,
        ZIndex = 0,
        Parent = button,
    })

    local hoverBg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = button,
    })

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "按钮"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Font = Enum.Font.GothamSemibold
    label.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(hoverBg, TweenInfo.new(0.12), { ImageTransparency = 0.9, ImageColor3 = theme.Primary }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(hoverBg, TweenInfo.new(0.12), { ImageTransparency = 1 }):Play()
    end)
    button.MouseButton1Click:Connect(function()
        SafeCallback(config.Callback)
    end)

    return { Main = button, Label = label, BG = bg }
end

function Elements.Toggle(config)
    config = config or {}
    local theme = GetTheme()
    local value = config.Value or false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Text or "开关"
    title.TextColor3 = theme.Text
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Parent = container

    local desc
    if config.Desc then
        desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 0)
        desc.BackgroundTransparency = 1
        desc.Text = config.Desc
        desc.TextColor3 = theme.Placeholder
        desc.TextSize = 12
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Font = Enum.Font.GothamMedium
        desc.TextTransparency = 0.3
        desc.AutomaticSize = Enum.AutomaticSize.Y
        desc.Parent = title
    end

    local toggle = NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, 36, 0, 32),
        ImageTransparency = 0.85,
        ImageColor3 = theme.Text,
        ZIndex = 1,
        Parent = container,
    })

    local fill = NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(value and 0.9 or 0.1, 0, 0.85, 0),
        Position = UDim2.new(value and 0.5 or 0.05, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ImageColor3 = value and theme.Toggle or Color3.fromRGB(100, 100, 100),
        ImageTransparency = value and 0.05 or 0.5,
        ZIndex = 2,
        Parent = toggle,
    })

    local thumb = NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(value and 1 or 0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(value and 1 or 0, 0.5),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.1,
        ZIndex = 3,
        Parent = toggle,
    })

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = container

    function hitbox:Set(v)
        value = v
        local targetX = v and 0.5 or 0.05
        local targetSize = v and 0.9 or 0.1
        local targetColor = v and theme.Toggle or Color3.fromRGB(100, 100, 100)
        TweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(targetX, 0, 0.5, 0),
            Size = UDim2.new(targetSize, 0, 0.85, 0),
            ImageColor3 = targetColor,
            ImageTransparency = v and 0.05 or 0.5,
        }):Play()
        TweenService:Create(thumb, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(v and 1 or 0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(v and 1 or 0, 0.5),
        }):Play()
        SafeCallback(config.Callback, v)
    end

    hitbox:Set(value)
    hitbox.MouseButton1Click:Connect(function() hitbox:Set(not value) end)

    return { Main = container, Set = hitbox.Set, Get = function() return value end }
end

function Elements.Slider(config)
    config = config or {}
    local theme = GetTheme()
    local min = config.Min or 0
    local max = config.Max or 100
    local value = math.clamp(config.Value or 50, min, max)
    local step = config.Step or 1

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Text or "滑块"
    title.TextColor3 = theme.Text
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Parent = container

    local track = NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, config.Width or 150, 0, 6),
        ImageTransparency = 0.8,
        ImageColor3 = theme.Placeholder,
        ZIndex = 1,
        Parent = container,
    })

    local progress = (value - min) / (max - min)
    local fill = NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(progress, 0, 1, 0),
        ImageColor3 = theme.Slider,
        ImageTransparency = 0.1,
        ZIndex = 2,
        Parent = track,
    })

    local thumb = NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(progress, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = theme.SliderThumb,
        ImageTransparency = 0.1,
        ZIndex = 3,
        Parent = track,
    })

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = theme.Text
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextTransparency = 0.5
    valueLabel.Parent = container

    local isDragging = false

    function container:Set(v)
        v = math.clamp(v, min, max)
        if step > 0 then v = math.floor((v - min) / step + 0.5) * step + min end
        value = v
        local p = (v - min) / (max - min)
        TweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(p, 0, 1, 0),
        }):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(p, 0, 0.5, 0),
        }):Play()
        valueLabel.Text = tostring(v)
        SafeCallback(config.Callback, v)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local relX = input.Position.X - track.AbsolutePosition.X
            local p = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            container:Set(min + p * (max - min))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relX = input.Position.X - track.AbsolutePosition.X
            local p = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            container:Set(min + p * (max - min))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    container:Set(value)
    return { Main = container, Set = container.Set, Get = function() return value end }
end

function Elements.Input(config)
    config = config or {}
    local theme = GetTheme()

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "输入"
    label.TextColor3 = theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Parent = container

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -(label.AbsoluteSize.X + 12), 1, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = config.Value or ""
    inputBox.PlaceholderText = config.Placeholder or "请输入..."
    inputBox.TextColor3 = theme.Text
    inputBox.PlaceholderColor3 = theme.Placeholder
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = container

    label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        inputBox.Size = UDim2.new(1, -(label.AbsoluteSize.X + 12), 1, 0)
    end)
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        SafeCallback(config.Callback, inputBox.Text)
    end)

    return { Main = container, InputBox = inputBox, Set = function(v) inputBox.Text = v end, Get = function() return inputBox.Text end }
end

-- ============================================================
-- 7. 高级元素
-- ============================================================
local AdvancedElements = {}

-- 7.1 Dropdown
function AdvancedElements.Dropdown(config)
    config = config or {}
    local theme = GetTheme()

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "下拉菜单"
    label.TextColor3 = theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -60, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = config.Placeholder or "请选择..."
    valueLabel.TextColor3 = theme.Text
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextTransparency = 0.3
    valueLabel.Parent = container

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.BackgroundTransparency = 1
    arrow.Image = GetIcon("chevron-down")
    arrow.ImageColor3 = theme.Icon
    arrow.ImageTransparency = 0.5
    arrow.Parent = container

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = container

    -- Dropdown 弹出列表
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(0, 0, 0, 0)
    dropdownContainer.Position = UDim2.new(0, 0, 0, 0)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Visible = false
    dropdownContainer.ZIndex = 100
    dropdownContainer.Parent = container

    local listBg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 0, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.DropdownBackground,
        ZIndex = 0,
        Parent = dropdownContainer,
    })

    local listScroller = Instance.new("ScrollingFrame")
    listScroller.Size = UDim2.new(1, -4, 0, 0)
    listScroller.Position = UDim2.new(0, 2, 0, 2)
    listScroller.BackgroundTransparency = 1
    listScroller.ScrollBarThickness = 0
    listScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroller.ScrollingDirection = Enum.ScrollingDirection.Y
    listScroller.ClipsDescendants = true
    listScroller.Parent = listBg

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = listScroller

    local options = config.Options or {}
    local value = config.Value
    local multiSelect = config.MultiSelect or false
    if multiSelect and type(value) ~= "table" then value = {} end

    local function updateOptions(opts)
        options = opts or options
        for _, child in ipairs(listScroller:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for i, option in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 30)
            btn.Position = UDim2.new(0, 4, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Text = option
            btn.TextColor3 = theme.Text
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = listScroller

            local isSelected = false
            if multiSelect then
                for _, v in ipairs(value) do if v == option then isSelected = true break end end
            else
                isSelected = (value == option)
            end

            if isSelected then
                btn.Text = "✓ " .. option
                btn.TextColor3 = theme.Primary
            end

            local hoverBg = NewRoundFrame(6, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ImageTransparency = 1,
                ZIndex = 0,
                Parent = btn,
            })

            btn.MouseEnter:Connect(function()
                TweenService:Create(hoverBg, TweenInfo.new(0.08), {
                    ImageTransparency = 0.9,
                    ImageColor3 = theme.TabBackgroundHover,
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(hoverBg, TweenInfo.new(0.08), { ImageTransparency = 1 }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                if multiSelect then
                    local found = false
                    for i, v in ipairs(value) do
                        if v == option then table.remove(value, i) found = true break end
                    end
                    if not found then table.insert(value, option) end
                    updateOptions()
                else
                    value = option
                    valueLabel.Text = option
                    dropdownContainer.Visible = false
                end
                SafeCallback(config.Callback, value)
            end)
        end

        local count = #options
        local height = math.min(count * 34 + 8, 200)
        listBg.Size = UDim2.new(1, 0, 0, height)
        listScroller.Size = UDim2.new(1, -4, 0, height - 4)
        if count == 0 then dropdownContainer.Visible = false end
    end

    local function updateValueDisplay()
        if multiSelect then
            local text = ""
            for i, v in ipairs(value) do
                text = text .. v
                if i < #value then text = text .. ", " end
            end
            valueLabel.Text = text ~= "" and text or config.Placeholder or "请选择..."
        else
            valueLabel.Text = value or config.Placeholder or "请选择..."
        end
    end

    function self:Open()
        if #options == 0 then return end
        dropdownContainer.Visible = true
        local absPos = container.AbsolutePosition
        local absSize = container.AbsoluteSize
        dropdownContainer.Position = UDim2.new(0, 0, 0, absSize.Y + 2)
        local viewport = workspace.CurrentCamera.ViewportSize
        local listHeight = listBg.AbsoluteSize.Y
        if absPos.Y + absSize.Y + listHeight + 10 > viewport.Y then
            dropdownContainer.Position = UDim2.new(0, 0, 0, -listHeight - 2)
        end
        listBg.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(listBg, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, math.min(#options * 34 + 8, 200)),
        }):Play()
        TweenService:Create(arrow, TweenInfo.new(0.15), { Rotation = 180 }):Play()
    end

    function self:Close()
        TweenService:Create(listBg, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0),
        }):Play()
        TweenService:Create(arrow, TweenInfo.new(0.15), { Rotation = 0 }):Play()
        task.wait(0.1)
        dropdownContainer.Visible = false
    end

    function self:Toggle()
        if dropdownContainer.Visible then self:Close() else self:Open() end
    end

    hitbox.MouseButton1Click:Connect(function() self:Toggle() end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownContainer.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = dropdownContainer.AbsolutePosition
            local absSize = dropdownContainer.AbsoluteSize
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                self:Close()
            end
        end
    end)

    updateOptions(options)
    updateValueDisplay()

    return { Main = container, Value = value, UpdateOptions = updateOptions, Open = self.Open, Close = self.Close, Toggle = self.Toggle }
end

-- 7.2 Colorpicker
function AdvancedElements.Colorpicker(config)
    config = config or {}
    local theme = GetTheme()
    local value = config.Value or Color3.fromRGB(0, 122, 255)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "颜色选择器"
    label.TextColor3 = theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.Parent = container

    local preview = NewRoundFrame(6, "Squircle", {
        Size = UDim2.new(0, 24, 0, 24),
        ImageColor3 = value,
        ImageTransparency = 0,
        ZIndex = 1,
        Parent = container,
    })

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = container

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 220, 0, 240)
    popup.Position = UDim2.new(0, 0, 1, 4)
    popup.BackgroundTransparency = 1
    popup.Visible = false
    popup.ZIndex = 100
    popup.Parent = container

    local popupBg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.DropdownBackground,
        ZIndex = 0,
        Parent = popup,
    })

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(1, -20, 0, 16)
    hueBar.Position = UDim2.new(0, 10, 0, 10)
    hueBar.BackgroundTransparency = 1
    hueBar.Parent = popupBg

    local hueGradient = Instance.new("UIGradient")
    local hueColors = {}
    for i = 0, 1, 0.01 do table.insert(hueColors, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1))) end
    hueGradient.Color = ColorSequence.new(hueColors)
    hueGradient.Parent = hueBar

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueBar

    local svPanel = Instance.new("Frame")
    svPanel.Size = UDim2.new(1, -20, 0, 120)
    svPanel.Position = UDim2.new(0, 10, 0, 36)
    svPanel.BackgroundTransparency = 1
    svPanel.Parent = popupBg

    local svImage = Instance.new("ImageLabel")
    svImage.Size = UDim2.new(1, 0, 1, 0)
    svImage.BackgroundTransparency = 1
    svImage.Image = "rbxassetid://4155801252"
    svImage.ImageColor3 = Color3.fromHSV(0, 1, 1)
    svImage.Parent = svPanel

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 4)
    svCorner.Parent = svPanel

    local previewLarge = Instance.new("Frame")
    previewLarge.Size = UDim2.new(0, 30, 0, 30)
    previewLarge.Position = UDim2.new(1, -40, 0, 170)
    previewLarge.BackgroundColor3 = value
    previewLarge.BackgroundTransparency = 0
    previewLarge.ZIndex = 1
    previewLarge.Parent = popupBg

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = previewLarge

    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.new(1, -50, 0, 30)
    hexInput.Position = UDim2.new(0, 10, 0, 170)
    hexInput.BackgroundTransparency = 0.9
    hexInput.BackgroundColor3 = theme.ElementBackground
    hexInput.Text = string.format("%02x%02x%02x", value.R * 255, value.G * 255, value.B * 255)
    hexInput.TextColor3 = theme.Text
    hexInput.TextSize = 14
    hexInput.Font = Enum.Font.GothamMedium
    hexInput.TextXAlignment = Enum.TextXAlignment.Center
    hexInput.Parent = popupBg

    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 4)
    hexCorner.Parent = hexInput

    local currentHue, currentSat, currentVal = ColorToHSV(value)
    local isDragging = false

    function self:UpdateColor(hue, sat, val)
        currentHue = hue or currentHue
        currentSat = sat or currentSat
        currentVal = val or currentVal
        local color = Color3.fromHSV(currentHue, currentSat, currentVal)
        value = color
        preview.ImageColor3 = color
        previewLarge.BackgroundColor3 = color
        svImage.ImageColor3 = Color3.fromHSV(currentHue, 1, 1)
        hexInput.Text = string.format("%02x%02x%02x", color.R * 255, color.G * 255, color.B * 255)
        SafeCallback(config.Callback, color)
    end

    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local relX = input.Position.X - hueBar.AbsolutePosition.X
            self:UpdateColor(math.clamp(relX / hueBar.AbsoluteSize.X, 0, 1))
        end
    end)

    svPanel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local relX = input.Position.X - svPanel.AbsolutePosition.X
            local relY = input.Position.Y - svPanel.AbsolutePosition.Y
            self:UpdateColor(nil, math.clamp(relX / svPanel.AbsoluteSize.X, 0, 1), 1 - math.clamp(relY / svPanel.AbsoluteSize.Y, 0, 1))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = input.Position.X - svPanel.AbsolutePosition.X
            local relY = input.Position.Y - svPanel.AbsolutePosition.Y
            self:UpdateColor(nil, math.clamp(relX / svPanel.AbsoluteSize.X, 0, 1), 1 - math.clamp(relY / svPanel.AbsoluteSize.Y, 0, 1))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        local success, color = pcall(function() return Color3.fromHex(hex) end)
        if success and color then
            local h, s, v = ColorToHSV(color)
            self:UpdateColor(h, s, v)
        else
            hexInput.Text = string.format("%02x%02x%02x", value.R * 255, value.G * 255, value.B * 255)
        end
    end)

    function self:Open()
        popup.Visible = true
        local absPos = container.AbsolutePosition
        local viewport = workspace.CurrentCamera.ViewportSize
        if absPos.Y + container.AbsoluteSize.Y + 250 > viewport.Y then
            popup.Position = UDim2.new(0, 0, 0, -250)
        else
            popup.Position = UDim2.new(0, 0, 1, 4)
        end
        popup.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(popup, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 240),
        }):Play()
    end

    function self:Close()
        TweenService:Create(popup, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
        }):Play()
        task.wait(0.1)
        popup.Visible = false
    end

    function self:Toggle()
        if popup.Visible then self:Close() else self:Open() end
    end

    hitbox.MouseButton1Click:Connect(function() self:Toggle() end)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and popup.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = popup.AbsolutePosition
            local absSize = popup.AbsoluteSize
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                self:Close()
            end
        end
    end)

    self:UpdateColor()
    return { Main = container, Value = value, Update = self.UpdateColor, Open = self.Open, Close = self.Close }
end

-- 7.3 Keybind
function AdvancedElements.Keybind(config)
    config = config or {}
    local theme = GetTheme()
    local value = config.Value or "F"
    local recording = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "键位绑定"
    label.TextColor3 = theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.Parent = container

    local keyDisplay = NewRoundFrame(6, "Squircle", {
        Size = UDim2.new(0, 60, 0, 28),
        ImageTransparency = 0.9,
        ImageColor3 = theme.Button,
        ZIndex = 1,
        Parent = container,
    })

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, 0, 1, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = value
    keyLabel.TextColor3 = theme.Text
    keyLabel.TextSize = 13
    keyLabel.Font = Enum.Font.GothamMedium
    keyLabel.ZIndex = 2
    keyLabel.Parent = keyDisplay

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = container

    function self:Set(key)
        value = key
        keyLabel.Text = key
        SafeCallback(config.Callback, key)
    end

    function self:Get()
        return value
    end

    function self:StartRecording()
        recording = true
        keyLabel.Text = "..."
        keyLabel.TextColor3 = theme.Primary
    end

    function self:StopRecording()
        recording = false
        keyLabel.Text = value
        keyLabel.TextColor3 = theme.Text
    end

    UserInputService.InputBegan:Connect(function(input)
        if not recording then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            if key ~= "Unknown" and key ~= "Escape" then
                self:Set(key)
                self:StopRecording()
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Set("鼠标左键")
            self:StopRecording()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            self:Set("鼠标右键")
            self:StopRecording()
        end
    end)

    hitbox.MouseButton1Click:Connect(function()
        if recording then self:StopRecording() else self:StartRecording() end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if recording and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = container.AbsolutePosition
            local absSize = container.AbsoluteSize
            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                self:StopRecording()
            end
        end
    end)

    return { Main = container, Set = self.Set, Get = self.Get }
end

-- 7.4 Code
function AdvancedElements.Code(config)
    config = config or {}
    local theme = GetTheme()
    local code = config.Code or ""

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, config.Height or 120)
    container.BackgroundTransparency = 1
    container.Parent = config.Parent

    local bg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 0, 30)
    title.Position = UDim2.new(0, 6, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = config.Text or "代码"
    title.TextColor3 = theme.Placeholder
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.TextTransparency = 0.3
    title.Parent = container

    local codeDisplay = Instance.new("TextLabel")
    codeDisplay.Size = UDim2.new(1, -12, 1, -40)
    codeDisplay.Position = UDim2.new(0, 6, 0, 34)
    codeDisplay.BackgroundTransparency = 1
    codeDisplay.Text = code
    codeDisplay.TextColor3 = theme.Text
    codeDisplay.TextSize = 13
    codeDisplay.TextXAlignment = Enum.TextXAlignment.Left
    codeDisplay.TextYAlignment = Enum.TextYAlignment.Top
    codeDisplay.Font = Enum.Font.Code
    codeDisplay.RichText = true
    codeDisplay.AutomaticSize = Enum.AutomaticSize.X
    codeDisplay.Parent = container

    local scroller = Instance.new("ScrollingFrame")
    scroller.Size = UDim2.new(1, 0, 1, -40)
    scroller.Position = UDim2.new(0, 0, 0, 34)
    scroller.BackgroundTransparency = 1
    scroller.ScrollBarThickness = 4
    scroller.ScrollBarImageTransparency = 0.8
    scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroller.ScrollingDirection = Enum.ScrollingDirection.X
    scroller.ClipsDescendants = true
    scroller.Parent = container

    codeDisplay.Parent = scroller
    codeDisplay:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        scroller.CanvasSize = UDim2.new(codeDisplay.AbsoluteSize.X + 12, 0, 0, 0)
    end)

    function self:Set(newCode)
        code = newCode
        codeDisplay.Text = newCode
    end

    function self:Get()
        return code
    end

    return { Main = container, Set = self.Set, Get = self.Get }
end

-- ============================================================
-- 8. 布局容器
-- ============================================================
local Layouts = {}

-- 8.1 Group
function Layouts.Group(config)
    config = config or {}
    local theme = GetTheme()

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = true
    container.Parent = config.Parent

    local bg = NewRoundFrame(config.Radius or 10, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground,
        ZIndex = 0,
        Parent = container,
    })

    local border = NewRoundFrame((config.Radius or 10) - 1, "SquircleOutline", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.9,
        ImageColor3 = theme.Outline,
        ZIndex = 0,
        Parent = container,
    })

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 1
    titleBar.Parent = container

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "分组"
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.ZIndex = 2
    titleLabel.Parent = titleBar

    local toggleBtn
    if config.Collapsible then
        toggleBtn = Instance.new("ImageButton")
        toggleBtn.Size = UDim2.new(0, 20, 0, 20)
        toggleBtn.Position = UDim2.new(1, -30, 0.5, 0)
        toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Image = GetIcon(config.Opened and "chevron-up" or "chevron-down")
        toggleBtn.ImageColor3 = theme.Icon
        toggleBtn.ImageTransparency = 0.5
        toggleBtn.ZIndex = 2
        toggleBtn.Parent = titleBar
        toggleBtn.MouseButton1Click:Connect(function() self:Toggle() end)
    end

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 32)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = container

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, config.Padding or 10)
    padding.PaddingBottom = UDim.new(0, config.Padding or 10)
    padding.PaddingLeft = UDim.new(0, config.Padding or 10)
    padding.PaddingRight = UDim.new(0, config.Padding or 10)
    padding.Parent = content

    local opened = config.Opened or true
    content.Visible = opened

    local self = {
        Main = container,
        Content = content,
        ContentLayout = contentLayout,
        TitleLabel = titleLabel,
        Elements = {},
    }

    function self:Add(element)
        if element.Parent then
            element.Parent = content
        elseif element.Main then
            element.Main.Parent = content
            table.insert(self.Elements, element)
        end
    end

    function self:GetContent() return content end
    function self:GetLayout() return contentLayout end

    function self:Toggle()
        opened = not opened
        content.Visible = opened
        if toggleBtn then
            toggleBtn.Image = GetIcon(opened and "chevron-up" or "chevron-down")
        end
    end

    function self:Open() if not opened then self:Toggle() end end
    function self:Close() if opened then self:Toggle() end end
    function self:SetTitle(title) self.Title = title titleLabel.Text = title end

    function self:Clear()
        for _, child in ipairs(content:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        self.Elements = {}
    end

    function self:Destroy() container:Destroy() end

    if not opened and config.Collapsible then
        content.Visible = false
        if toggleBtn then toggleBtn.Image = GetIcon("chevron-down") end
    end

    return self
end

-- 8.2 HStack
function Layouts.HStack(config)
    config = config or {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.Padding = UDim.new(0, config.Spacing or 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    contentLayout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, config.Padding or 4)
    padding.PaddingBottom = UDim.new(0, config.Padding or 4)
    padding.PaddingLeft = UDim.new(0, config.Padding or 4)
    padding.PaddingRight = UDim.new(0, config.Padding or 4)
    padding.Parent = container

    local self = { Main = container, ContentLayout = contentLayout, Elements = {} }

    function self:Add(element)
        if element.Parent then element.Parent = container
        elseif element.Main then element.Main.Parent = container; table.insert(self.Elements, element) end
    end

    function self:GetLayout() return contentLayout end
    function self:Clear()
        for _, child in ipairs(container:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
        end
        self.Elements = {}
    end
    function self:Destroy() container:Destroy() end

    return self
end

-- 8.3 VStack
function Layouts.VStack(config)
    config = config or {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, config.Spacing or 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, config.Padding or 4)
    padding.PaddingBottom = UDim.new(0, config.Padding or 4)
    padding.PaddingLeft = UDim.new(0, config.Padding or 4)
    padding.PaddingRight = UDim.new(0, config.Padding or 4)
    padding.Parent = container

    local self = { Main = container, ContentLayout = contentLayout, Elements = {} }

    function self:Add(element)
        if element.Parent then element.Parent = container
        elseif element.Main then element.Main.Parent = container; table.insert(self.Elements, element) end
    end

    function self:GetLayout() return contentLayout end
    function self:Clear()
        for _, child in ipairs(container:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
        end
        self.Elements = {}
    end
    function self:Destroy() container:Destroy() end

    return self
end

-- 8.4 Section
function Layouts.Section(config)
    config = config or {}
    local theme = GetTheme()

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = true
    container.Parent = config.Parent

    local bg = NewRoundFrame(config.Radius or 10, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.97,
        ImageColor3 = theme.SectionBoxBackground,
        ZIndex = 0,
        Parent = container,
    })

    local border = NewRoundFrame((config.Radius or 10) - 1, "SquircleOutline", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.9,
        ImageColor3 = theme.SectionBoxBorder,
        ZIndex = 0,
        Parent = container,
    })

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.ZIndex = 1
    header.Parent = container

    local headerContent = Instance.new("Frame")
    headerContent.Size = UDim2.new(1, -16, 1, 0)
    headerContent.Position = UDim2.new(0, 8, 0, 0)
    headerContent.BackgroundTransparency = 1
    headerContent.Parent = header

    local icon
    if config.Icon then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = GetIcon(config.Icon)
        icon.ImageColor3 = theme.SectionIcon
        icon.ImageTransparency = 0.3
        icon.ZIndex = 2
        icon.Parent = headerContent
    end

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 1, 0)
    titleLabel.Position = UDim2.new(icon and 28 or 0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "分区"
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.ZIndex = 2
    titleLabel.Parent = headerContent

    local descLabel
    if config.Desc and config.Desc ~= "" then
        descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 1, 0)
        descLabel.Position = UDim2.new(icon and 28 or 0, 0, 0, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = config.Desc
        descLabel.TextColor3 = theme.Placeholder
        descLabel.TextSize = 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Font = Enum.Font.GothamMedium
        descLabel.TextTransparency = 0.4
        descLabel.ZIndex = 2
        descLabel.Parent = headerContent
        titleLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 0.6, 0)
        descLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 0.4, 0)
        descLabel.Position = UDim2.new(icon and 28 or 0, 0, 0.6, 0)
    end

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 18, 0, 18)
    arrow.Position = UDim2.new(1, 0, 0.5, 0)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Image = GetIcon(config.Opened and "chevron-up" or "chevron-down")
    arrow.ImageColor3 = theme.SectionExpandIcon
    arrow.ImageTransparency = theme.SectionExpandIconTransparency or 0.4
    arrow.ZIndex = 2
    arrow.Parent = headerContent

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Visible = config.Opened or true
    content.Parent = container

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = content

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, config.Padding or 8)
    padding.PaddingBottom = UDim.new(0, config.Padding or 8)
    padding.PaddingLeft = UDim.new(0, config.Padding or 8)
    padding.PaddingRight = UDim.new(0, config.Padding or 8)
    padding.Parent = content

    local opened = config.Opened or true

    local self = {
        Main = container,
        Header = header,
        TitleLabel = titleLabel,
        DescLabel = descLabel,
        Content = content,
        ContentLayout = contentLayout,
        Arrow = arrow,
        Elements = {},
    }

    function self:Add(element)
        if element.Parent then element.Parent = content
        elseif element.Main then element.Main.Parent = content; table.insert(self.Elements, element) end
    end

    function self:GetContent() return content end
    function self:GetLayout() return contentLayout end

    function self:Toggle()
        opened = not opened
        content.Visible = opened
        arrow.Image = GetIcon(opened and "chevron-up" or "chevron-down")
        bg.ImageTransparency = opened and 0.97 or 0.99
        border.ImageTransparency = opened and 0.9 or 0.95
    end

    function self:Open() if not opened then self:Toggle() end end
    function self:Close() if opened then self:Toggle() end end
    function self:SetTitle(title) self.Title = title titleLabel.Text = title end
    function self:SetDesc(desc) self.Desc = desc if descLabel then descLabel.Text = desc descLabel.Visible = desc and desc ~= "" end end
    function self:SetIcon(iconName) self.Icon = iconName if icon then icon.Image = GetIcon(iconName) end end

    function self:Clear()
        for _, child in ipairs(content:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
        end
        self.Elements = {}
    end

    function self:Destroy() container:Destroy() end

    header.MouseButton1Click:Connect(function() self:Toggle() end)
    header.MouseEnter:Connect(function()
        TweenService:Create(bg, TweenInfo.new(0.08), { ImageTransparency = 0.95 }):Play()
    end)
    header.MouseLeave:Connect(function()
        TweenService:Create(bg, TweenInfo.new(0.08), { ImageTransparency = opened and 0.97 or 0.99 }):Play()
    end)

    return self
end

-- 8.5 Divider
function Layouts.Divider(config)
    config = config or {}
    local theme = GetTheme()

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = config.Parent

    local margin = config.Margin or 8
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -margin * 2, 0, config.Thickness or 1)
    line.Position = UDim2.new(0.5, 0, 0.5, 0)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = theme.Placeholder
    line.BackgroundTransparency = 0.8
    line.Parent = container

    if config.Label and config.Label ~= "" then
        line.Size = UDim2.new(1, -margin * 2 - 80, 0, config.Thickness or 1)
        line.Position = UDim2.new(0.5, -40, 0.5, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 80, 0, 20)
        label.Position = UDim2.new(0.5, 0, 0.5, 0)
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.BackgroundTransparency = 1
        label.Text = config.Label
        label.TextColor3 = theme.Placeholder
        label.TextSize = 12
        label.Font = Enum.Font.GothamMedium
        label.TextTransparency = 0.5
        label.ZIndex = 1
        label.Parent = container
    end

    local self = { Main = container }
    function self:Destroy() container:Destroy() end
    return self
end

-- 8.6 Space
function Layouts.Space(config)
    config = config or {}
    local container = Instance.new("Frame")
    container.Size = config.Size or UDim2.new(0, config.Width or 10, 0, config.Height or 10)
    container.BackgroundTransparency = 1
    container.LayoutOrder = config.LayoutOrder or 0
    container.Parent = config.Parent

    local self = { Main = container }
    function self:Destroy() container:Destroy() end
    return self
end

-- ============================================================
-- 9. 通知系统（完整版）
-- ============================================================
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new()
    local self = setmetatable({}, NotificationManager)
    self.Notifications = {}
    return self
end

function NotificationManager:Notify(config)
    config = config or {}
    local theme = GetTheme()

    local gui = Instance.new("ScreenGui")
    gui.Name = "WindUI_Notification"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 340, 0, 0)
    local posMap = {
        TopRight = UDim2.new(1, -12, 0, 12),
        TopLeft = UDim2.new(0, 12, 0, 12),
        BottomRight = UDim2.new(1, -12, 1, -12),
        BottomLeft = UDim2.new(0, 12, 1, -12),
    }
    local anchorMap = {
        TopRight = Vector2.new(1, 0),
        TopLeft = Vector2.new(0, 0),
        BottomRight = Vector2.new(1, 1),
        BottomLeft = Vector2.new(0, 1),
    }
    container.Position = posMap[config.Position] or posMap.TopRight
    container.AnchorPoint = anchorMap[config.Position] or Vector2.new(1, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = true
    container.ZIndex = 1000
    container.Parent = gui

    local bg = NewRoundFrame(12, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.05,
        ImageColor3 = theme.Notification,
        ZIndex = 0,
        Parent = container,
    })

    local icon
    if config.Icon then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.BackgroundTransparency = 1
        icon.Image = GetIcon(config.Icon)
        icon.ImageColor3 = theme.Icon
        icon.Parent = container
    end

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -(icon and 36 or 0) - 30, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "通知"
    title.TextColor3 = theme.NotificationTitle
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Parent = container

    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, -(icon and 36 or 0) - 30, 0, 0)
    content.BackgroundTransparency = 1
    content.Text = config.Content or ""
    content.TextColor3 = theme.NotificationContent
    content.TextSize = 14
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.Font = Enum.Font.GothamMedium
    content.TextTransparency = 0.3
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = title

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = theme.NotificationDuration
    progressBar.BackgroundTransparency = 0.8
    progressBar.Parent = container

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = theme.NotificationDuration
    progressFill.BackgroundTransparency = 0.6
    progressFill.Parent = progressBar

    container.Size = UDim2.new(0, 340, 0, 0)
    container.Visible = true

    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, container.AbsoluteSize.Y + 20),
    }):Play()

    local duration = config.Duration or 3
    if duration > 0 then
        TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0),
        }):Play()
        task.wait(duration + 0.5)
        TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 340, 0, 0),
        }):Play()
        task.wait(0.25)
        gui:Destroy()
    end

    local notification = { Hide = function() gui:Destroy() end }
    table.insert(self.Notifications, notification)
    return notification
end

function NotificationManager:ClearAll()
    for _, n in ipairs(self.Notifications) do n:Hide() end
    self.Notifications = {}
end

-- ============================================================
-- 10. 配置管理
-- ============================================================
local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(config)
    config = config or {}
    local self = setmetatable({}, ConfigManager)
    self.Name = config.Name or "config"
    self.Folder = config.Folder or "WindUI"
    self.AutoSave = config.AutoSave or false
    self.Data = {}
    self.Schemas = {}
    self.Handlers = {}

    if writefile and not isfolder(self.Folder) then
        makefolder(self.Folder)
    end

    if config.AutoLoad then self:Load() end
    return self
end

function ConfigManager:DefineSchema(schema)
    for key, defaultValue in pairs(schema) do
        self.Schemas[key] = defaultValue
        if self.Data[key] == nil then self.Data[key] = defaultValue end
    end
end

function ConfigManager:RegisterHandler(key, handler)
    self.Handlers[key] = handler
end

function ConfigManager:Get(key, defaultValue)
    if self.Data[key] ~= nil then return self.Data[key] end
    if self.Schemas[key] ~= nil then return self.Schemas[key] end
    return defaultValue
end

function ConfigManager:Set(key, value, save)
    if self.Handlers[key] then value = self.Handlers[key](value) end
    self.Data[key] = value
    if save or self.AutoSave then self:Save() end
    return value
end

function ConfigManager:Save()
    if not writefile then return false end
    local path = self.Folder .. "/" .. self.Name .. ".json"
    local data = { version = 1, data = self.Data, schemas = self.Schemas }
    local success, err = pcall(function() writefile(path, HttpService:JSONEncode(data)) end)
    if not success then warn("[Config] 保存失败:", err) end
    return success
end

function ConfigManager:Load()
    if not readfile then return false end
    local path = self.Folder .. "/" .. self.Name .. ".json"
    if not isfile(path) then return false end
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not success then warn("[Config] 加载失败:", data) return false end
    if data.data then
        for key, value in pairs(data.data) do self.Data[key] = value end
    end
    return true
end

function ConfigManager:Reset()
    self.Data = {}
    for key, defaultValue in pairs(self.Schemas) do self.Data[key] = defaultValue end
    self:Save()
end

function ConfigManager:BindToggle(element, key)
    local value = self:Get(key, element:Get())
    element:Set(value, false)
    local original = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if original then SafeCallback(original, newValue) end
    end
    return element
end

function ConfigManager:BindSlider(element, key)
    local value = self:Get(key, element:Get())
    element:Set(value, false)
    local original = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if original then SafeCallback(original, newValue) end
    end
    return element
end

function ConfigManager:BindInput(element, key)
    local value = self:Get(key, element:Get())
    element:Set(value)
    local original = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if original then SafeCallback(original, newValue) end
    end
    return element
end

function ConfigManager:BindDropdown(element, key)
    local value = self:Get(key, element.Value)
    element.Value = value
    local original = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if original then SafeCallback(original, newValue) end
    end
    return element
end

function ConfigManager:BindColorpicker(element, key)
    local value = self:Get(key, element.Value)
    element.Value = value
    local original = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if original then SafeCallback(original, newValue) end
    end
    return element
end

-- ============================================================
-- 11. 辅助函数
-- ============================================================
function ColorToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    if max ~= 0 then s = d / max end
    if d ~= 0 then
        if max == r then h = (g - b) / d
        elseif max == g then h = 2 + (b - r) / d
        else h = 4 + (r - g) / d end
        h = h / 6
        if h < 0 then h = h + 1 end
    end
    return h, s, v
end

-- ============================================================
-- 12. 主入口 WindUI
-- ============================================================
local WindUI = {}
WindUI.__index = WindUI
WindUI.Version = "1.0.0"

function WindUI.new(config)
    config = config or {}
    local self = setmetatable({}, WindUI)
    self.Config = config
    self.Windows = {}
    self.NotificationManager = NotificationManager.new()
    if config.Theme then SetTheme(config.Theme) end
    if config.Config then self.ConfigManager = ConfigManager.new(config.Config) end
    return self
end

function WindUI:CreateWindow(config)
    config = config or {}
    config.Parent = config.Parent or self.Config.Parent

    local window = CreateWindow(config)
    table.insert(self.Windows, window)

    local tabManager = TabManager.new(window)

    window.TabManager = tabManager
    window.AddTab = function(cfg) return tabManager:AddTab(cfg) end
    window.SelectTab = function(index) tabManager:SelectTab(index) end
    window.GetTab = function(index) return tabManager:GetTab(index) end

    window.AddButton = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Elements.Button(cfg)
    end
    window.AddToggle = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Elements.Toggle(cfg)
    end
    window.AddSlider = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Elements.Slider(cfg)
    end
    window.AddInput = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Elements.Input(cfg)
    end
    window.AddDropdown = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return AdvancedElements.Dropdown(cfg)
    end
    window.AddColorpicker = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return AdvancedElements.Colorpicker(cfg)
    end
    window.AddKeybind = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return AdvancedElements.Keybind(cfg)
    end
    window.AddCode = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return AdvancedElements.Code(cfg)
    end
    window.AddGroup = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Layouts.Group(cfg)
    end
    window.AddHStack = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Layouts.HStack(cfg)
    end
    window.AddVStack = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Layouts.VStack(cfg)
    end
    window.AddSection = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Layouts.Section(cfg)
    end
    window.AddDivider = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Layouts.Divider(cfg)
    end
    window.AddSpace = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetContainer()
        return Layouts.Space(cfg)
    end

    window.Notify = function(cfg) return self.NotificationManager:Notify(cfg) end

    if self.ConfigManager then
        window.BindToggle = function(element, key) return self.ConfigManager:BindToggle(element, key) end
        window.BindSlider = function(element, key) return self.ConfigManager:BindSlider(element, key) end
        window.BindInput = function(element, key) return self.ConfigManager:BindInput(element, key) end
        window.BindDropdown = function(element, key) return self.ConfigManager:BindDropdown(element, key) end
        window.BindColorpicker = function(element, key) return self.ConfigManager:BindColorpicker(element, key) end
    end

    window.SetTheme = function(themeName)
        SetTheme(themeName)
        self.Theme = themeName
        window:UpdateTheme()
    end

    task.spawn(function()
        task.wait(0.1)
        if tabManager:GetSelectedTab() == nil then
            for i, tab in pairs(tabManager:GetAllTabs()) do
                if not tab.Locked then tabManager:SelectTab(i) break end
            end
        end
    end)

    return window
end

function WindUI:GetWindows() return self.Windows end
function WindUI:GetWindow(index) return self.Windows[index] end
function WindUI:Notify(config) return self.NotificationManager:Notify(config) end
function WindUI:ClearNotifications() self.NotificationManager:ClearAll() end
function WindUI:GetConfig() return self.ConfigManager end
function WindUI:SaveConfig() if self.ConfigManager then return self.ConfigManager:Save() end return false end
function WindUI:LoadConfig() if self.ConfigManager then return self.ConfigManager:Load() end return false end

function WindUI:SetTheme(themeName)
    SetTheme(themeName)
    self.Theme = themeName
    for _, window in ipairs(self.Windows) do window:UpdateTheme() end
end

function WindUI:GetTheme() return GetTheme() end

function WindUI:Destroy()
    for _, window in ipairs(self.Windows) do window:Destroy() end
    self.Windows = {}
    self.NotificationManager:ClearAll()
end

-- ============================================================
-- 13. 示例窗口
-- ============================================================
local function CreateExample()
    local ui = WindUI.new({ Theme = "Dark" })

    local window = ui:CreateWindow({
        Title = "WindUI 示例",
        Author = "v1.0",
        Icon = "home",
        Width = 640,
        Height = 480,
        MinWidth = 400,
        MinHeight = 300,
        SideBarWidth = 200,
    })

    local tab = window:AddTab({ Title = "主页", Icon = "home" })

    window:AddButton({
        Text = "点击测试",
        Parent = tab:GetContainer(),
        Callback = function()
            window:Notify({
                Title = "成功！",
                Content = "UI 加载成功！",
                Icon = "check",
                Duration = 2,
            })
        end,
    })

    window:AddToggle({
        Text = "开关测试",
        Parent = tab:GetContainer(),
        Value = false,
    })

    window:AddSlider({
        Text = "音量",
        Min = 0,
        Max = 100,
        Value = 50,
        Parent = tab:GetContainer(),
    })

    window:AddInput({
        Text = "用户名",
        Placeholder = "请输入...",
        Parent = tab:GetContainer(),
    })

    return ui, window
end

-- ============================================================
-- 14. 自动运行
-- ============================================================
local ui, window = CreateExample()
_G.WindUI = ui
_G.Window = window

return WindUI
