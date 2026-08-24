-- ============================================================
-- 第一段：WindUI 核心工具库 + 主题系统
-- 版本：补全版 v1.0
-- 说明：无外部依赖，完全自包含
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalizationService = game:GetService("LocalizationService")

-- ============================================================
-- 1. 工具函数（原 Creator 模块）
-- ============================================================
local Creator = {}

-- 颜色工具
function Creator.Color3ToHex(color)
    local function component(c)
        return string.format("%02x", math.floor(c * 255 + 0.5))
    end
    return component(color.R) .. component(color.G) .. component(color.B)
end

function Creator.HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 0,
        tonumber(hex:sub(3, 4), 16) or 0,
        tonumber(hex:sub(5, 6), 16) or 0
    )
end

function Creator.GetPerceivedBrightness(color)
    return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
end

function Creator.GetTextColorForBackground(color, threshold)
    threshold = threshold or 0.5
    if Creator.GetPerceivedBrightness(color) > threshold then
        return Color3.fromRGB(20, 20, 20)
    else
        return Color3.fromRGB(240, 240, 240)
    end
end

function Creator.ColorToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    if max ~= 0 then s = d / max end
    if d ~= 0 then
        if max == r then
            h = (g - b) / d
        elseif max == g then
            h = 2 + (b - r) / d
        else
            h = 4 + (r - g) / d
        end
        h = h / 6
        if h < 0 then h = h + 1 end
    end
    return h, s, v
end

function Creator.HSVToColor(h, s, v)
    return Color3.fromHSV(h, s, v)
end

-- 生成唯一 ID
function Creator.GenerateGUID()
    return HttpService:GenerateGUID(false)
end

-- 安全回调
function Creator.SafeCallback(func, ...)
    if not func then return end
    local success, err = pcall(func, ...)
    if not success then
        warn("[WindUI] Callback error:", err)
    end
    return success
end

-- 获取字体（无外部依赖，使用 Roblox 内置字体）
function Creator.GetFont(weight, style)
    return Font.new(
        "rbxasset://fonts/families/GothamSSm.json",
        weight or Enum.FontWeight.Regular,
        style or Enum.FontStyle.Normal
    )
end

-- ============================================================
-- 2. 形状系统（原 NewRoundFrame 完整版）
-- ============================================================
local Shapes = {
    Circle = { Image = "rbxassetid://111665032676235", Rect = Rect.new(512, 512, 512, 512), Radius = 512 },
    CircleOutline = { Image = "rbxassetid://108556680453287", Rect = Rect.new(512, 512, 512, 512), Radius = 512 },
    CircleGlass = { Image = "rbxassetid://95600044758841", Rect = Rect.new(512, 512, 512, 512), Radius = 512 },
    SquircleH = { Image = "rbxassetid://125083578015333", Rect = Rect.new(512, 325, 512, 325), Radius = 325 },
    SquircleHOutline = { Image = "rbxassetid://107043713170567", Rect = Rect.new(512, 325, 512, 325), Radius = 325 },
    SquircleHGlass = { Image = "rbxassetid://84819521201001", Rect = Rect.new(512, 325, 512, 325), Radius = 325 },
    ["SquircleH-TL-TR"] = { Image = "rbxassetid://90680657206619", Rect = Rect.new(807, 512, 807, 512), Radius = 325, AutoChange = false },
    ["SquircleH-BL-BR"] = { Image = "rbxassetid://99216342056719", Rect = Rect.new(0, 512, 0, 512), Radius = 325, AutoChange = false },
    SquircleV = { Image = "rbxassetid://124965260437653", Rect = Rect.new(325, 512, 325, 512), Radius = 325 },
    SquircleVOutline = { Image = "rbxassetid://88808835404198", Rect = Rect.new(325, 512, 325, 512), Radius = 325 },
    SquircleVGlass = { Image = "rbxassetid://124982801466667", Rect = Rect.new(325, 512, 325, 512), Radius = 325 },
    Squircle = { Image = "rbxassetid://89641024074289", Rect = Rect.new(460, 460, 460, 460), Radius = 310 },
    SquircleOutline = { Image = "rbxassetid://74029063732681", Rect = Rect.new(512, 512, 512, 512), Radius = 310 },
    SquircleGlass = { Image = "rbxassetid://131126436897551", Rect = Rect.new(512, 512, 512, 512), Radius = 310 },
    ["Squircle-TL-TR"] = { Image = "rbxassetid://75712142040725", Rect = Rect.new(512, 512, 512, 512), Radius = 310, AutoChange = false },
    ["Squircle-BL-BR"] = { Image = "rbxassetid://83676684425544", Rect = Rect.new(512, 0, 512, 0), Radius = 310, AutoChange = false },
    Square = { Image = "rbxassetid://82909646051652", Rect = Rect.new(512, 512, 512, 512), Radius = 512, AutoChange = false },
    ["Shadow-sm"] = { Image = "rbxassetid://8992230677", Rect = Rect.new(512, 512, 512, 512), Radius = 512, AutoChange = false },
}

function Creator.GetShape(shapeType)
    return Shapes[shapeType] or Shapes.Circle
end

function Creator.NewRoundFrame(radius, shapeType, props, children, noScale)
    local shape = shapeType or "Circle"
    local s = Creator.GetShape(shape)

    local r = Instance.new("ImageLabel")
    r.BackgroundTransparency = 1
    r.ScaleType = Enum.ScaleType.Slice
    r.SliceCenter = s.Rect
    r.SliceScale = math.max(radius / s.Radius, 0.0001)
    r.Image = s.Image
    r.Size = UDim2.new(1, 0, 1, 0)

    if props then
        for k, v in pairs(props) do
            if k ~= "ThemeTag" and k ~= "Children" then
                r[k] = v
            end
        end
    end

    -- 自动形状切换（仅在非固定形状时启用）
    local currentShape = shapeType or "Circle"
    local function updateShape()
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
                local ns = Creator.GetShape(newShape)
                r.Image = ns.Image
                r.SliceCenter = ns.Rect
                r.SliceScale = math.max(radius / ns.Radius, 0.0001)
                currentShape = newShape
            end
        end
    end

    r:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateShape)
    task.spawn(updateShape)

    if children then
        for _, child in ipairs(children) do
            if child then child.Parent = r end
        end
    end

    return r
end

-- ============================================================
-- 3. 主题系统
-- ============================================================
local Themes = {}

-- 暗色主题（默认）
Themes.Dark = {
    Name = "Dark",
    -- 基础颜色
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
    -- 透明度
    BackgroundTransparency = 0,
    PanelBackgroundTransparency = 0.92,
    ElementBackgroundTransparency = 0,
    -- 组件专用
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
    -- 窗口组件
    WindowTopbarTitle = Color3.fromRGB(255, 255, 255),
    WindowTopbarAuthor = Color3.fromRGB(180, 180, 180),
    WindowTopbarIcon = Color3.fromRGB(200, 200, 200),
    WindowTopbarButtonIcon = Color3.fromRGB(180, 180, 180),
    WindowBackground = Color3.fromRGB(28, 28, 30),
    WindowShadow = Color3.fromRGB(0, 0, 0),
    -- 标签页
    TabTitle = Color3.fromRGB(255, 255, 255),
    TabIcon = Color3.fromRGB(200, 200, 200),
    -- 元素
    ElementTitle = Color3.fromRGB(255, 255, 255),
    ElementDesc = Color3.fromRGB(180, 180, 180),
    ElementIcon = Color3.fromRGB(200, 200, 200),
    -- 通知
    Notification = Color3.fromRGB(38, 38, 40),
    Notification2 = Color3.fromRGB(255, 255, 255),
    Notification2Transparency = 0.92,
    NotificationTitle = Color3.fromRGB(255, 255, 255),
    NotificationContent = Color3.fromRGB(200, 200, 200),
    NotificationDuration = Color3.fromRGB(255, 255, 255),
    NotificationDurationTransparency = 0.92,
    NotificationBorder = Color3.fromRGB(255, 255, 255),
    NotificationBorderTransparency = 0.75,
    -- 工具提示
    Tooltip = Color3.fromRGB(76, 76, 76),
    TooltipText = Color3.fromRGB(255, 255, 255),
    TooltipSecondary = Color3.fromRGB(0, 122, 255),
    TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
    -- 对话框
    DialogBackground = Color3.fromRGB(38, 38, 40),
    DialogBackgroundTransparency = 0,
    DialogTitle = Color3.fromRGB(255, 255, 255),
    DialogContent = Color3.fromRGB(200, 200, 200),
    DialogIcon = Color3.fromRGB(200, 200, 200),
    -- 弹出框
    PopupBackground = Color3.fromRGB(38, 38, 40),
    PopupBackgroundTransparency = 0,
    PopupTitle = Color3.fromRGB(255, 255, 255),
    PopupContent = Color3.fromRGB(200, 200, 200),
    PopupIcon = Color3.fromRGB(200, 200, 200),
    -- 标签
    LabelBackground = Color3.fromRGB(0, 0, 0),
    LabelBackgroundTransparency = 0.83,
    -- 进度条
    ProgressBar = Color3.fromRGB(0, 122, 255),
    ProgressBarTrack = Color3.fromRGB(255, 255, 255),
    ProgressBarTrackTransparency = 0.9,
    ProgressBarText = Color3.fromRGB(255, 255, 255),
    -- 下拉菜单
    DropdownTabBackground = Color3.fromRGB(42, 42, 44),
    DropdownBackground = Color3.fromRGB(38, 38, 40),
    DropdownTabBorder = Color3.fromRGB(255, 255, 255),
    -- 搜索栏
    SearchBarBackground = Color3.fromRGB(38, 38, 40),
    SearchBarBorder = Color3.fromRGB(255, 255, 255),
    SearchBarBorderTransparency = 0.75,
    -- 分节
    SectionIcon = Color3.fromRGB(200, 200, 200),
    SectionExpandIcon = Color3.fromRGB(200, 200, 200),
    SectionExpandIconTransparency = 0.4,
    SectionBox = Color3.fromRGB(255, 255, 255),
    SectionBoxTransparency = 0.95,
    SectionBoxBorder = Color3.fromRGB(255, 255, 255),
    SectionBoxBorderTransparency = 0.75,
    SectionBoxBackground = Color3.fromRGB(255, 255, 255),
    SectionBoxBackgroundTransparency = 0.97,
    -- 视口
    ViewportBackground = Color3.fromRGB(42, 42, 44),
    ViewportBackgroundTransparency = 0,
    -- 滑块图标
    SliderIcon = Color3.fromRGB(144, 143, 149),
    -- 主色
    Primary = Color3.fromRGB(0, 145, 255),
    -- 切换栏
    ToggleBar = Color3.fromRGB(255, 255, 255),
    -- 复选框
    CheckboxIcon = Color3.fromRGB(255, 255, 255),
    CheckboxBorder = Color3.fromRGB(255, 255, 255),
    CheckboxBorderTransparency = 0.75,
    -- 滑块拇指
    SliderThumb = Color3.fromRGB(255, 255, 255),
    -- 主题标签
    ThemeTag = {},
}

-- 亮色主题
Themes.Light = {
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

-- 当前主题
local CurrentTheme = Themes.Dark
local ThemeChangeCallbacks = {}

function Creator.SetTheme(themeName)
    local theme = Themes[themeName]
    if not theme then
        warn("[WindUI] Theme not found:", themeName)
        return
    end
    CurrentTheme = theme
    for _, callback in ipairs(ThemeChangeCallbacks) do
        Creator.SafeCallback(callback, themeName)
    end
end

function Creator.GetTheme()
    return CurrentTheme
end

function Creator.GetThemeColor(key, fallback)
    local value = CurrentTheme[key]
    if value ~= nil then
        return value
    end
    -- 尝试从暗色主题获取
    local darkValue = Themes.Dark[key]
    if darkValue ~= nil then
        return darkValue
    end
    return fallback or Color3.fromRGB(255, 0, 255) -- 醒目粉色表示缺失
end

function Creator.GetThemeTransparency(key, fallback)
    local value = CurrentTheme[key]
    if type(value) == "number" then
        return value
    end
    return fallback or 0
end

function Creator.OnThemeChange(callback)
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

-- 主题颜色应用到对象
function Creator.ApplyThemeTag(object, tag)
    if not tag then return end
    for property, key in pairs(tag) do
        if property == "ImageColor3" then
            object.ImageColor3 = Creator.GetThemeColor(key)
        elseif property == "TextColor3" then
            object.TextColor3 = Creator.GetThemeColor(key)
        elseif property == "BackgroundColor3" then
            object.BackgroundColor3 = Creator.GetThemeColor(key)
        elseif property == "ImageTransparency" then
            object.ImageTransparency = Creator.GetThemeTransparency(key)
        elseif property == "TextTransparency" then
            object.TextTransparency = Creator.GetThemeTransparency(key)
        elseif property == "BackgroundTransparency" then
            object.BackgroundTransparency = Creator.GetThemeTransparency(key)
        elseif property == "PlaceholderColor3" then
            if object.PlaceholderColor3 ~= nil then
                object.PlaceholderColor3 = Creator.GetThemeColor(key)
            end
        elseif property == "BorderColor3" then
            if object.BorderColor3 ~= nil then
                object.BorderColor3 = Creator.GetThemeColor(key)
            end
        elseif property == "BorderTransparency" then
            if object.BorderTransparency ~= nil then
                object.BorderTransparency = Creator.GetThemeTransparency(key)
            end
        end
    end
end

-- ============================================================
-- 4. 图标系统（简化版，使用内置图标）
-- ============================================================
local Icons = {
    -- 通用
    search = "rbxassetid://92867583610071",
    x = "rbxassetid://110786993356448",
    check = "rbxassetid://93898873302694",
    plus = "rbxassetid://111774323017047",
    minus = "rbxassetid://118026365011536",
    "chevron-down" = "rbxassetid://134243273101015",
    "chevron-up" = "rbxassetid://122444883127455",
    "chevron-left" = "rbxassetid://73780377692148",
    "chevron-right" = "rbxassetid://92473583511724",
    maximize = "rbxassetid://76045941763188",
    minimize = "rbxassetid://118026365011536",
    close = "rbxassetid://110786993356448",
    expand = "rbxassetid://137492887754537",
    move = "rbxassetid://116138709011735",
    lock = "rbxassetid://134724289526879",
    unlock = "rbxassetid://93597915325122",
    user = "rbxassetid://81589895647169",
    settings = "rbxassetid://80758916183665",
    home = "rbxassetid://98755624629571",
    folder = "rbxassetid://80846616596607",
    file = "rbxassetid://74748492079329",
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
    -- 按钮专用
    "mouse-pointer-click" = "rbxassetid://107150227368485",
    "square-mouse-pointer" = "rbxassetid://76141850603920",
    "toggle-right" = "rbxassetid://90411952142550",
    "sliders-horizontal" = "rbxassetid://85538382643347",
    "command" = "rbxassetid://93648221906330",
    "text-cursor-input" = "rbxassetid://107551944047171",
    "chevrons-up-down" = "rbxassetid://131833120209646",
    "terminal" = "rbxassetid://106783148545356",
    "palette" = "rbxassetid://86350350950064",
    "chart-bar" = "rbxassetid://105389816384108",
    "table-of-contents" = "rbxassetid://135044763275414",
    "type" = "rbxassetid://133543553793564",
    "frown" = "rbxassetid://124407301067982",
}

function Creator.GetIcon(name)
    return Icons[name] or "rbxassetid://92867583610071"
end

-- 创建图标图像
function Creator.CreateIcon(iconName, size, color)
    local img = Instance.new("ImageLabel")
    img.Size = size or UDim2.new(0, 20, 0, 20)
    img.BackgroundTransparency = 1
    img.Image = Creator.GetIcon(iconName)
    if color then
        img.ImageColor3 = color
    end
    return img
end

-- ============================================================
-- 5. 工具函数导出
-- ============================================================
Creator.Shapes = Shapes
Creator.Icons = Icons
Creator.TweenService = TweenService
Creator.UserInputService = UserInputService
Creator.RunService = RunService
Creator.Players = Players

-- 导出模块
return Creator
-- ============================================================
-- 第二段：WindUI 窗口系统
-- 依赖：第一段（Creator 模块）
-- 功能：窗口创建、拖动、缩放、边界限制、控制按钮
-- ============================================================

local Creator = require(script.Parent.Creator)  -- 如果作为模块使用
-- 如果是在同一个文件，直接使用上面的 Creator

-- ============================================================
-- 窗口主函数
-- ============================================================
function Creator.CreateWindow(config)
    config = config or {}

    -- 获取屏幕信息
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    -- 窗口尺寸
    local defaultWidth = isMobile and viewport.X * 0.92 or (config.Width or 580)
    local defaultHeight = isMobile and viewport.Y * 0.82 or (config.Height or 440)
    local minWidth = isMobile and 300 or (config.MinWidth or 400)
    local minHeight = isMobile and 240 or (config.MinHeight or 300)
    local maxWidth = isMobile and viewport.X * 0.96 or (config.MaxWidth or viewport.X * 0.8)
    local maxHeight = isMobile and viewport.Y * 0.92 or (config.MaxHeight or viewport.Y * 0.85)

    -- 主题颜色
    local theme = Creator.GetTheme()
    local bgColor = config.BackgroundColor or theme.WindowBackground or Color3.fromRGB(28, 28, 30)
    local textColor = theme.Text or Color3.fromRGB(255, 255, 255)
    local accentColor = theme.Accent or Color3.fromRGB(0, 122, 255)

    -- UI 参数
    local radius = isMobile and 20 or (config.Radius or 16)
    local titleHeight = isMobile and 56 or (config.TitleHeight or 52)
    local iconSize = config.IconSize or 22
    local dragFrameSize = config.DragFrameSize or 160
    local shadowSize = 60

    -- ============================================================
    -- 创建 GUI 容器
    -- ============================================================
    local gui = Instance.new("ScreenGui")
    gui.Name = "WindUI_Window"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = config.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")

    -- ============================================================
    -- 主面板
    -- ============================================================
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, defaultWidth, 0, defaultHeight)
    panel.Position = UDim2.new(0.5, -defaultWidth/2, 0.5, -defaultHeight/2)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = false
    panel.Parent = gui
    panel.ZIndex = 1

    -- ============================================================
    -- 窗口背景（带圆角）
    -- ============================================================
    local bg = Creator.NewRoundFrame(radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = bgColor,
        ImageTransparency = 0,
        ZIndex = 0,
        Parent = panel,
    })

    -- ============================================================
    -- 阴影（可调节透明度）
    -- ============================================================
    local shadow = Creator.NewRoundFrame(radius, "Shadow-sm", {
        Size = UDim2.new(1, shadowSize * 2, 1, shadowSize * 2),
        Position = UDim2.new(0.5, -shadowSize, 0.5, -shadowSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageTransparency = 0.6,
        ZIndex = -1,
        Parent = panel,
    })
    if config.ShadowTransparency ~= nil then
        shadow.ImageTransparency = config.ShadowTransparency
    end

    -- ============================================================
    -- 标题栏（可拖动区域）
    -- ============================================================
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, titleHeight)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 10
    titleBar.Parent = panel

    -- ============================================================
    -- 窗口图标（左上角）
    -- ============================================================
    local iconContainer = Instance.new("Frame")
    iconContainer.Size = UDim2.new(0, iconSize, 0, iconSize)
    iconContainer.Position = UDim2.new(0, 14, 0.5, 0)
    iconContainer.AnchorPoint = Vector2.new(0, 0.5)
    iconContainer.BackgroundTransparency = 1
    iconContainer.ZIndex = 11
    iconContainer.Parent = titleBar

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = config.Icon or Creator.GetIcon("home")
    icon.ImageColor3 = theme.WindowTopbarIcon or Color3.fromRGB(200, 200, 200)
    icon.ZIndex = 12
    icon.Parent = iconContainer

    -- ============================================================
    -- 标题文字
    -- ============================================================
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 14 + iconSize + 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "WindUI 窗口"
    titleLabel.TextColor3 = theme.WindowTopbarTitle or Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = isMobile and 18 or 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.ZIndex = 11
    titleLabel.Parent = titleBar
    titleLabel.AutomaticSize = Enum.AutomaticSize.X

    -- ============================================================
    -- 作者/副标题（可选）
    -- ============================================================
    local authorLabel
    if config.Author then
        authorLabel = Instance.new("TextLabel")
        authorLabel.Size = UDim2.new(0, 0, 1, 0)
        authorLabel.Position = UDim2.new(0, 14 + iconSize + 8, 0, 0)
        authorLabel.BackgroundTransparency = 1
        authorLabel.Text = config.Author
        authorLabel.TextColor3 = theme.WindowTopbarAuthor or Color3.fromRGB(180, 180, 180)
        authorLabel.TextSize = isMobile and 13 or 11
        authorLabel.TextXAlignment = Enum.TextXAlignment.Left
        authorLabel.Font = Enum.Font.GothamMedium
        authorLabel.ZIndex = 11
        authorLabel.Parent = titleBar
        authorLabel.AutomaticSize = Enum.AutomaticSize.X

        -- 调整标题位置，为副标题腾出空间
        titleLabel.Position = UDim2.new(0, 14 + iconSize + 8, 0, -8)
        authorLabel.Position = UDim2.new(0, 14 + iconSize + 8, 0, 12)
    end

    -- ============================================================
    -- 右侧控制按钮（关闭、最大化、最小化）
    -- ============================================================
    local btnSize = isMobile and 40 or 36
    local spacing = isMobile and 6 or 9
    local btnIconSize = isMobile and 18 or 16

    local rightContainer = Instance.new("Frame")
    rightContainer.Size = UDim2.new(0, btnSize * 3 + spacing * 2 + 14, 1, 0)
    rightContainer.Position = UDim2.new(1, -14, 0, 0)
    rightContainer.AnchorPoint = Vector2.new(1, 0)
    rightContainer.BackgroundTransparency = 1
    rightContainer.ZIndex = 11
    rightContainer.Parent = titleBar

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, spacing)
    listLayout.Parent = rightContainer

    -- 创建按钮的辅助函数
    local function makeControlButton(image, layoutOrder, hoverColor, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, btnSize, 0, btnSize)
        container.BackgroundTransparency = 1
        container.LayoutOrder = layoutOrder
        container.ZIndex = 12
        container.Parent = rightContainer

        local hoverBg = Creator.NewRoundFrame(999, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ZIndex = 0,
            Parent = container,
        })

        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Image = image
        btn.ImageColor3 = theme.WindowTopbarButtonIcon or Color3.fromRGB(180, 180, 180)
        btn.ZIndex = 13
        btn.Parent = container

        -- 悬停效果
        btn.MouseEnter:Connect(function()
            TweenService:Create(hoverBg, TweenInfo.new(0.12), { ImageTransparency = 0.9 }):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), { ImageColor3 = hoverColor }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(hoverBg, TweenInfo.new(0.12), { ImageTransparency = 1 }):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), {
                ImageColor3 = theme.WindowTopbarButtonIcon or Color3.fromRGB(180, 180, 180)
            }):Play()
        end)

        btn.MouseButton1Click:Connect(callback)

        return container, btn
    end

    -- ============================================================
    -- 窗口状态变量
    -- ============================================================
    local isMaximized = false
    local isMinimized = false
    local isClosing = false
    local prevSize, prevPos
    local maxBtn

    -- ============================================================
    -- 边界限制工具函数
    -- ============================================================
    local function getScreenBounds()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        return {
            minX = 0,
            minY = 0,
            maxX = viewportSize.X,
            maxY = viewportSize.Y,
        }
    end

    local function clampPosition(position, size)
        local bounds = getScreenBounds()
        local absSize = size or panel.AbsoluteSize
        return {
            X = math.clamp(position.X, bounds.minX, bounds.maxX - absSize.X),
            Y = math.clamp(position.Y, bounds.minY, bounds.maxY - absSize.Y),
        }
    end

    local function getPanelPosition()
        -- 将 UDim2 位置转换为绝对坐标
        local absPos = panel.AbsolutePosition
        return { X = absPos.X, Y = absPos.Y }
    end

    local function setPanelPosition(x, y)
        panel.Position = UDim2.new(0, x, 0, y)
    end

    -- ============================================================
    -- 关闭窗口（带动画）
    -- ============================================================
    local function closeWindow()
        if isClosing then return end
        isClosing = true

        -- 禁用交互
        panel.Active = false

        local t = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, 0),
            Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0.5, 0),
        })
        t:Play()
        t.Completed:Connect(function()
            gui:Destroy()
            if config.OnClose then
                Creator.SafeCallback(config.OnClose)
            end
        end)
    end

    -- ============================================================
    -- 最小化（带动画）
    -- ============================================================
    local function minimizeWindow()
        if isClosing or isMinimized then return end
        isMinimized = true

        local h = titleHeight
        local t = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, h),
            Position = UDim2.new(
                panel.Position.X.Scale,
                panel.Position.X.Offset,
                0.5,
                -h/2
            ),
        })
        t:Play()
        t.Completed:Connect(function()
            panel.Visible = false
            isMinimized = true
        end)
    end

    -- ============================================================
    -- 最大化/还原
    -- ============================================================
    local function toggleMaximize()
        if isClosing then return end

        if isMinimized then
            panel.Visible = true
            isMinimized = false
            -- 恢复尺寸后继续执行最大化逻辑
        end

        if isMaximized then
            -- 还原
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = prevSize,
                Position = prevPos,
            }):Play()
            isMaximized = false
            if maxBtn then
                maxBtn.Image = Creator.GetIcon("maximize")
            end
        else
            -- 最大化
            local bounds = getScreenBounds()
            local padding = isMobile and 8 or 20

            prevSize = panel.Size
            prevPos = panel.Position

            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, bounds.maxX - padding * 2, 0, bounds.maxY - padding * 2),
                Position = UDim2.new(0, padding, 0, padding),
            }):Play()
            isMaximized = true
            if maxBtn then
                maxBtn.Image = Creator.GetIcon("minimize")
            end
        end
    end

    -- ============================================================
    -- 创建控制按钮
    -- ============================================================
    -- 关闭按钮
    local _, closeBtn = makeControlButton(
        Creator.GetIcon("close"),
        3,
        Color3.fromRGB(255, 80, 80),
        closeWindow
    )

    -- 最大化按钮
    local maxContainer, maxBtnLocal = makeControlButton(
        Creator.GetIcon("maximize"),
        2,
        Color3.fromRGB(50, 200, 100),
        toggleMaximize
    )
    maxBtn = maxBtnLocal

    -- 最小化按钮
    makeControlButton(
        Creator.GetIcon("minimize"),
        1,
        Color3.fromRGB(255, 200, 50),
        minimizeWindow
    )

    -- ============================================================
    -- 动态调整标题宽度
    -- ============================================================
    local function updateTitleSize()
        local rightWidth = rightContainer.AbsoluteSize.X
        local leftOffset = 14 + iconSize + 8
        local available = panel.AbsoluteSize.X - leftOffset - rightWidth - 12

        if authorLabel then
            titleLabel.Size = UDim2.new(0, math.max(available, 50), 0, 0)
            authorLabel.Size = UDim2.new(0, math.max(available, 50), 0, 0)
        else
            titleLabel.Size = UDim2.new(0, math.max(available, 50), 0, 0)
        end
    end

    rightContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTitleSize)
    panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTitleSize)
    task.spawn(updateTitleSize)

    -- ============================================================
    -- 侧边栏（可选）
    -- ============================================================
    local sideBar
    local sideBarWidth = isMobile and 0 or (config.SideBarWidth or 200)

    if sideBarWidth > 0 then
        sideBar = Instance.new("ScrollingFrame")
        sideBar.Size = UDim2.new(0, sideBarWidth, 1, -titleHeight)
        sideBar.Position = UDim2.new(0, 0, 0, titleHeight)
        sideBar.BackgroundTransparency = 1
        sideBar.ScrollBarThickness = 0
        sideBar.CanvasSize = UDim2.new(0, 0, 0, 0)
        sideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sideBar.ScrollingDirection = Enum.ScrollingDirection.Y
        sideBar.ClipsDescendants = true
        sideBar.Parent = panel

        -- 侧边栏内容容器
        local sideContent = Instance.new("Frame")
        sideContent.Size = UDim2.new(1, 0, 0, 0)
        sideContent.BackgroundTransparency = 1
        sideContent.AutomaticSize = Enum.AutomaticSize.Y
        sideContent.Parent = sideBar

        local sideLayout = Instance.new("UIListLayout")
        sideLayout.Padding = UDim.new(0, 4)
        sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sideLayout.Parent = sideContent

        -- 侧边栏分割线
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(0, 1, 1, -40)
        divider.Position = UDim2.new(1, 0, 0, 20)
        divider.BackgroundColor3 = theme.Outline or Color3.fromRGB(255, 255, 255)
        divider.BackgroundTransparency = 0.9
        divider.Parent = panel

        -- 占位标签
        local placeholder = Instance.new("TextLabel")
        placeholder.Size = UDim2.new(1, 0, 0, 30)
        placeholder.Position = UDim2.new(0.5, 0, 0.5, 0)
        placeholder.AnchorPoint = Vector2.new(0.5, 0.5)
        placeholder.BackgroundTransparency = 1
        placeholder.Text = "⚡ 侧边栏"
        placeholder.TextColor3 = theme.Placeholder or Color3.fromRGB(150, 150, 150)
        placeholder.TextSize = 14
        placeholder.Font = Enum.Font.GothamMedium
        placeholder.TextTransparency = 0.5
        placeholder.Parent = sideContent
    end

    -- ============================================================
    -- 内容区域
    -- ============================================================
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -(sideBarWidth or 0), 1, -titleHeight)
    content.Position = UDim2.new(0, (sideBarWidth or 0), 0, titleHeight)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = panel

    -- 内容区域占位
    local contentPlaceholder = Instance.new("TextLabel")
    contentPlaceholder.Size = UDim2.new(1, 0, 1, 0)
    contentPlaceholder.BackgroundTransparency = 1
    contentPlaceholder.Text = "📋 主面板内容区域"
    contentPlaceholder.TextColor3 = theme.Placeholder or Color3.fromRGB(180, 180, 180)
    contentPlaceholder.TextSize = isMobile and 20 or 18
    contentPlaceholder.Font = Enum.Font.GothamMedium
    contentPlaceholder.TextTransparency = 0.4
    contentPlaceholder.Parent = content

    -- 内容容器（用于后续添加元素）
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -20, 1, -20)
    contentContainer.Position = UDim2.new(0, 10, 0, 10)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = content

    -- ============================================================
    -- 底部拖动手柄（DragFrame）
    -- ============================================================
    local dragFrame = Creator.NewRoundFrame(999, "Squircle", {
        ImageTransparency = 0.8,
        ImageColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(0, dragFrameSize, 0, 4),
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
    resizeImage.ImageColor3 = theme.Icon or Color3.fromRGB(160, 160, 160)
    resizeImage.ImageTransparency = 0.7
    resizeImage.ZIndex = 100
    resizeImage.Parent = resizeHandle

    -- 最大化/还原时的遮罩
    local maxOverlay = Creator.NewRoundFrame(radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 1,
        ImageColor3 = Color3.new(0, 0, 0),
        ZIndex = 999,
        Parent = panel,
    })

    -- ============================================================
    -- 统一输入系统（含边界限制）
    -- ============================================================
    local currentInput = nil

    -- 拖拽状态
    local dragData = {
        active = false,
        input = nil,
        inputType = nil,
        start = Vector2.new(),
        startPos = nil,
        highlight = false,
    }

    -- 缩放状态
    local resizeData = {
        active = false,
        input = nil,
        inputType = nil,
        start = Vector2.new(),
        startSize = nil,
        startPos = nil,
    }

    -- ============================================================
    -- 拖拽逻辑（含边界限制）
    -- ============================================================
    local function onDragStart(input, highlight)
        if isClosing or isMinimized then return end
        if currentInput then return end
        if isMaximized then return end  -- 最大化时禁止拖动

        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and
           input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        currentInput = input
        dragData.active = true
        dragData.input = input
        dragData.inputType = input.UserInputType
        dragData.start = input.Position
        dragData.startPos = panel.Position
        dragData.highlight = highlight

        if highlight then
            TweenService:Create(dragFrame, TweenInfo.new(0.1), { ImageTransparency = 0.35 }):Play()
        end
    end

    local function onDragMove(input)
        if not dragData.active then return end

        local valid = false
        if dragData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                valid = true
            end
        elseif dragData.inputType == Enum.UserInputType.Touch then
            if input == dragData.input and input.UserInputType == Enum.UserInputType.Touch then
                valid = true
            end
        end

        if not valid then return end

        local delta = input.Position - dragData.start
        local newX = dragData.startPos.X.Offset + delta.X
        local newY = dragData.startPos.Y.Offset + delta.Y

        -- 边界限制
        local bounds = getScreenBounds()
        local panelSize = panel.AbsoluteSize

        -- 确保窗口不超出屏幕边界
        newX = math.clamp(newX, bounds.minX, bounds.maxX - panelSize.X)
        newY = math.clamp(newY, bounds.minY, bounds.maxY - panelSize.Y)

        panel.Position = UDim2.new(0, newX, 0, newY)
    end

    local function onDragEnd(input)
        if not dragData.active then return end

        local shouldEnd = false
        if dragData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                shouldEnd = true
            end
        elseif dragData.inputType == Enum.UserInputType.Touch then
            if input == dragData.input then
                shouldEnd = true
            end
        end

        if not shouldEnd then return end

        dragData.active = false
        currentInput = nil

        if dragData.highlight then
            TweenService:Create(dragFrame, TweenInfo.new(0.15), { ImageTransparency = 0.8 }):Play()
        end

        dragData.input = nil
        dragData.inputType = nil
        dragData.highlight = false
    end

    -- ============================================================
    -- 缩放逻辑（含边界限制）
    -- ============================================================
    local function onResizeStart(input)
        if isClosing or isMinimized then return end
        if currentInput then return end
        if isMaximized then return end  -- 最大化时禁止缩放

        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and
           input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        currentInput = input
        resizeData.active = true
        resizeData.input = input
        resizeData.inputType = input.UserInputType
        resizeData.start = input.Position
        resizeData.startSize = panel.Size
        resizeData.startPos = panel.Position

        TweenService:Create(resizeImage, TweenInfo.new(0.1), { ImageTransparency = 0.2 }):Play()
        TweenService:Create(resizeImage, TweenInfo.new(0.1), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    end

    local function onResizeMove(input)
        if not resizeData.active then return end

        local valid = false
        if resizeData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                valid = true
            end
        elseif resizeData.inputType == Enum.UserInputType.Touch then
            if input == resizeData.input and input.UserInputType == Enum.UserInputType.Touch then
                valid = true
            end
        end

        if not valid then return end

        local delta = input.Position - resizeData.start
        local newW = math.clamp(
            resizeData.startSize.X.Offset + delta.X,
            minWidth,
            maxWidth
        )
        local newH = math.clamp(
            resizeData.startSize.Y.Offset + delta.Y,
            minHeight,
            maxHeight
        )

        -- 缩放时保持窗口左上角位置不变，但确保右下角不超出屏幕
        local bounds = getScreenBounds()
        local currentPos = panel.Position
        local currentX = currentPos.X.Offset
        local currentY = currentPos.Y.Offset

        -- 如果窗口超出右边界，自动调整位置
        if currentX + newW > bounds.maxX then
            currentX = bounds.maxX - newW
        end
        -- 如果窗口超出下边界，自动调整位置
        if currentY + newH > bounds.maxY then
            currentY = bounds.maxY - newH
        end
        -- 确保左上角不超出边界
        currentX = math.max(currentX, bounds.minX)
        currentY = math.max(currentY, bounds.minY)

        panel.Size = UDim2.new(0, newW, 0, newH)
        panel.Position = UDim2.new(0, currentX, 0, currentY)
    end

    local function onResizeEnd(input)
        if not resizeData.active then return end

        local shouldEnd = false
        if resizeData.inputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                shouldEnd = true
            end
        elseif resizeData.inputType == Enum.UserInputType.Touch then
            if input == resizeData.input then
                shouldEnd = true
            end
        end

        if not shouldEnd then return end

        resizeData.active = false
        currentInput = nil

        TweenService:Create(resizeImage, TweenInfo.new(0.15), { ImageTransparency = 0.7 }):Play()
        TweenService:Create(resizeImage, TweenInfo.new(0.15), { ImageColor3 = theme.Icon or Color3.fromRGB(160, 160, 160) }):Play()

        resizeData.input = nil
        resizeData.inputType = nil
        resizeData.startSize = nil
        resizeData.startPos = nil
    end

    -- ============================================================
    -- 注册输入事件
    -- ============================================================
    -- 标题栏拖拽（不显示高亮）
    titleBar.InputBegan:Connect(function(input)
        onDragStart(input, false)
    end)

    -- 底部手柄拖拽（显示高亮）
    dragButton.InputBegan:Connect(function(input)
        onDragStart(input, true)
    end)

    -- 缩放手柄
    resizeHandle.InputBegan:Connect(onResizeStart)

    -- 全局输入跟踪
    UserInputService.InputChanged:Connect(function(input)
        onDragMove(input)
        onResizeMove(input)
    end)

    UserInputService.InputEnded:Connect(function(input)
        onDragEnd(input)
        onResizeEnd(input)
    end)

    -- ============================================================
    -- 窗口尺寸变化时重新应用边界
    -- ============================================================
    panel:GetPropertyChangedSignal("Size"):Connect(function()
        if not isMaximized and not dragData.active and not resizeData.active then
            -- 被动尺寸变化时（如屏幕旋转），确保窗口在屏幕内
            local bounds = getScreenBounds()
            local pos = panel.Position
            local size = panel.AbsoluteSize

            local newX = math.clamp(pos.X.Offset, bounds.minX, bounds.maxX - size.X)
            local newY = math.clamp(pos.Y.Offset, bounds.minY, bounds.maxY - size.Y)

            if newX ~= pos.X.Offset or newY ~= pos.Y.Offset then
                panel.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)

    -- ============================================================
    -- 双击标题栏居中（原版功能）
    -- ============================================================
    local lastClickTime = 0
    local clickCount = 0

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local currentTime = tick()
            if currentTime - lastClickTime < 0.4 then
                clickCount = clickCount + 1
                if clickCount >= 2 and not isMaximized and not isMinimized and not isClosing then
                    -- 双击居中
                    local bounds = getScreenBounds()
                    local size = panel.AbsoluteSize
                    local newX = (bounds.maxX - size.X) / 2
                    local newY = (bounds.maxY - size.Y) / 2
                    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, newX, 0, newY),
                    }):Play()
                    clickCount = 0
                end
            else
                clickCount = 1
            end
            lastClickTime = currentTime
        end
    end)

    -- ============================================================
    -- 入场动画
    -- ============================================================
    panel.Size = UDim2.new(0, defaultWidth, 0, 0)
    panel.Position = UDim2.new(0.5, -defaultWidth/2, 0.5, 0)
    dragFrame.Size = UDim2.new(0, 0, 0, 4)

    task.spawn(function()
        task.wait(0.05)
        TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, defaultWidth, 0, defaultHeight),
            Position = UDim2.new(0.5, -defaultWidth/2, 0.5, -defaultHeight/2),
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
            ImageTransparency = config.ShadowTransparency or 0.6,
        }):Play()
    end)

    -- ============================================================
    -- 窗口对象 API
    -- ============================================================
    local window = {
        -- 核心属性
        Panel = panel,
        Gui = gui,
        Content = contentContainer,
        TitleBar = titleBar,
        SideBar = sideBar,

        -- 控制方法
        Close = closeWindow,
        Minimize = minimizeWindow,
        Maximize = toggleMaximize,

        -- 状态查询
        IsMaximized = function() return isMaximized end,
        IsMinimized = function() return isMinimized end,
        IsClosing = function() return isClosing end,

        -- 尺寸控制
        SetSize = function(w, h)
            if isMaximized then return end
            local newW = math.clamp(w, minWidth, maxWidth)
            local newH = math.clamp(h, minHeight, maxHeight)
            panel.Size = UDim2.new(0, newW, 0, newH)
        end,

        GetSize = function()
            return panel.Size.X.Offset, panel.Size.Y.Offset
        end,

        -- 位置控制（带边界限制）
        SetPosition = function(x, y)
            if isMaximized then return end
            local bounds = getScreenBounds()
            local size = panel.AbsoluteSize
            local newX = math.clamp(x, bounds.minX, bounds.maxX - size.X)
            local newY = math.clamp(y, bounds.minY, bounds.maxY - size.Y)
            panel.Position = UDim2.new(0, newX, 0, newY)
        end,

        GetPosition = function()
            return panel.Position.X.Offset, panel.Position.Y.Offset
        end,

        -- 居中
        Center = function()
            if isMaximized then return end
            local bounds = getScreenBounds()
            local size = panel.AbsoluteSize
            local newX = (bounds.maxX - size.X) / 2
            local newY = (bounds.maxY - size.Y) / 2
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, newX, 0, newY),
            }):Play()
        end,

        -- 设置标题
        SetTitle = function(text)
            titleLabel.Text = text
        end,

        -- 设置图标
        SetIcon = function(iconName)
            icon.Image = Creator.GetIcon(iconName)
        end,

        -- 获取内容容器（用于添加 UI 元素）
        GetContent = function()
            return contentContainer
        end,

        -- 获取侧边栏（用于添加标签页等）
        GetSideBar = function()
            return sideBar and sideBar:FindFirstChildOfClass("Frame")
        end,

        -- 主题更新
        UpdateTheme = function()
            local newTheme = Creator.GetTheme()
            bg.ImageColor3 = newTheme.WindowBackground or Color3.fromRGB(28, 28, 30)
            titleLabel.TextColor3 = newTheme.WindowTopbarTitle or Color3.fromRGB(255, 255, 255)
            icon.ImageColor3 = newTheme.WindowTopbarIcon or Color3.fromRGB(200, 200, 200)
            if authorLabel then
                authorLabel.TextColor3 = newTheme.WindowTopbarAuthor or Color3.fromRGB(180, 180, 180)
            end
        end,

        -- 销毁
        Destroy = function()
            gui:Destroy()
            if config.OnDestroy then
                Creator.SafeCallback(config.OnDestroy)
            end
        end,
    }

    -- 主题变化时更新窗口
    Creator.OnThemeChange(function()
        window:UpdateTheme()
    end)

    -- 屏幕尺寸变化时重新检查边界
    RunService.RenderStepped:Connect(function()
        if not isMaximized and not dragData.active and not resizeData.active then
            local bounds = getScreenBounds()
            local pos = panel.Position
            local size = panel.AbsoluteSize

            -- 检查窗口是否在屏幕内，如果不在则自动调整
            if pos.X.Offset + size.X > bounds.maxX or pos.X.Offset < bounds.minX or
               pos.Y.Offset + size.Y > bounds.maxY or pos.Y.Offset < bounds.minY then
                local newX = math.clamp(pos.X.Offset, bounds.minX, bounds.maxX - size.X)
                local newY = math.clamp(pos.Y.Offset, bounds.minY, bounds.maxY - size.Y)
                panel.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)

    return window
end

-- 导出窗口创建函数
return Creator
-- ============================================================
-- 第三段：WindUI 标签页系统（Tabs）
-- 依赖：第一段（Creator）+ 第二段（Window）
-- 功能：标签页创建、切换、搜索、锁定
-- ============================================================

local Creator = require(script.Parent.Creator)  -- 如果作为模块使用
-- 如果是在同一个文件，直接使用上面的 Creator

-- ============================================================
-- 标签页管理器
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

    -- 获取主题颜色
    local theme = Creator.GetTheme()

    -- 侧边栏容器
    local sideBar = window:GetSideBar()
    if not sideBar then
        error("窗口没有侧边栏，无法创建标签页")
    end

    -- 创建标签页列表容器
    self.TabList = Instance.new("Frame")
    self.TabList.Size = UDim2.new(1, 0, 0, 0)
    self.TabList.BackgroundTransparency = 1
    self.TabList.AutomaticSize = Enum.AutomaticSize.Y
    self.TabList.Parent = sideBar

    self.TabLayout = Instance.new("UIListLayout")
    self.TabLayout.Padding = UDim.new(0, 4)
    self.TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.TabLayout.Parent = self.TabList

    -- 搜索框（可选）
    self.SearchBar = nil
    self.SearchResults = {}

    return self
end

-- ============================================================
-- 创建标签页
-- ============================================================
function TabManager:AddTab(config)
    config = config or {}

    self.TabCount = self.TabCount + 1
    local index = self.TabCount

    local theme = Creator.GetTheme()

    -- ============================================================
    -- 标签页按钮（在侧边栏中）
    -- ============================================================
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -8, 0, 36)
    tabButton.Position = UDim2.new(0, 4, 0, 0)
    tabButton.BackgroundTransparency = 1
    tabButton.Text = ""
    tabButton.ZIndex = 2
    tabButton.LayoutOrder = index
    tabButton.Parent = self.TabList

    -- 标签页背景（带圆角）
    local tabBg = Creator.NewRoundFrame(
        (config.Radius or 10),
        "Squircle",
        {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ZIndex = 0,
            Parent = tabButton,
        }
    )

    -- 标签页悬停/选中背景
    local tabHover = Creator.NewRoundFrame(
        (config.Radius or 10),
        "Squircle",
        {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ZIndex = 0,
            Parent = tabButton,
        }
    )

    -- 标签页内容
    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, -12, 1, 0)
    tabContent.Position = UDim2.new(0, 6, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = tabButton

    -- 标签页图标
    local icon
    if config.Icon then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = Creator.GetIcon(config.Icon)
        icon.ImageColor3 = theme.TabIcon or Color3.fromRGB(200, 200, 200)
        icon.ImageTransparency = 0.4
        icon.ZIndex = 1
        icon.Parent = tabContent
    end

    -- 标签页标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -(icon and 24 or 0), 1, 0)
    title.Position = UDim2.new(icon and 24 or 0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "标签页 " .. index
    title.TextColor3 = theme.TabTitle or Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.TextTransparency = 0.4
    title.ZIndex = 1
    title.Parent = tabContent

    -- 标签页锁定图标
    local lockIcon
    if config.Locked then
        lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 14, 0, 14)
        lockIcon.Position = UDim2.new(1, -16, 0.5, 0)
        lockIcon.AnchorPoint = Vector2.new(1, 0.5)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = Creator.GetIcon("lock")
        lockIcon.ImageColor3 = theme.Icon or Color3.fromRGB(160, 160, 160)
        lockIcon.ImageTransparency = 0.5
        lockIcon.ZIndex = 1
        lockIcon.Parent = tabContent

        title.Size = UDim2.new(1, -(icon and 24 or 0) - 18, 1, 0)
    end

    -- ============================================================
    -- 标签页内容容器（在主内容区域）
    -- ============================================================
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.ScrollingDirection = Enum.ScrollingDirection.Y
    container.ClipsDescendants = true
    container.Visible = false
    container.Parent = self.Window:GetContent()

    -- 内容布局
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = container

    -- 内边距
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = container

    -- ============================================================
    -- 标签页对象
    -- ============================================================
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

        -- 主题标签
        ThemeTag = config.ThemeTag or {},

        -- 自定义数据
        Data = config.Data or {},
    }

    -- ============================================================
    -- 标签页方法
    -- ============================================================

    -- 选中标签页
    function tab:Select()
        if self.Locked then return end
        self.TabManager:SelectTab(self.Index)
    end

    -- 添加元素到标签页
    function tab:AddElement(element)
        if not element or not element.Parent then
            warn("[Tab] 无效的元素")
            return
        end
        element.Parent = self.Container
        table.insert(self.Elements, element)
    end

    -- 清空标签页内容
    function tab:Clear()
        for _, child in ipairs(self.Container:GetChildren()) do
            if child:IsA("UIListLayout") or child:IsA("UIPadding") then
                -- 保留布局和边距
            else
                child:Destroy()
            end
        end
        self.Elements = {}
    end

    -- 设置标题
    function tab:SetTitle(newTitle)
        self.Title = newTitle
        title.Text = newTitle
    end

    -- 设置锁定状态
    function tab:SetLocked(locked)
        self.Locked = locked
        if lockIcon then
            lockIcon.Visible = locked
        end
        if locked then
            title.TextTransparency = 0.6
            if icon then
                icon.ImageTransparency = 0.6
            end
        else
            title.TextTransparency = self.Selected and 0 or 0.4
            if icon then
                icon.ImageTransparency = self.Selected and 0.1 or 0.4
            end
        end
    end

    -- 获取内容容器
    function tab:GetContainer()
        return self.Container
    end

    -- 获取布局
    function tab:GetLayout()
        return self.ContentLayout
    end

    -- ============================================================
    -- 标签页交互事件
    -- ============================================================

    -- 悬停效果
    tabButton.MouseEnter:Connect(function()
        if not self.Locked then
            TweenService:Create(tabHover, TweenInfo.new(0.08), {
                ImageTransparency = 0.92,
                ImageColor3 = theme.TabBackgroundHover or Color3.fromRGB(50, 50, 55),
            }):Play()
        end
    end)

    tabButton.MouseLeave:Connect(function()
        TweenService:Create(tabHover, TweenInfo.new(0.08), {
            ImageTransparency = 1,
        }):Play()
    end)

    -- 点击切换
    tabButton.MouseButton1Click:Connect(function()
        if not self.Locked then
            self:Select()
        end
    end)

    -- ============================================================
    -- 存储标签页
    -- ============================================================
    self.Tabs[index] = tab
    self.TabContainers[index] = container

    -- 如果这是第一个标签页，自动选中
    if not self.SelectedTab and not self.Locked then
        self:SelectTab(index)
    end

    return tab
end

-- ============================================================
-- 选择标签页
-- ============================================================
function TabManager:SelectTab(index)
    local tab = self.Tabs[index]
    if not tab then return end
    if tab.Locked then return end

    local theme = Creator.GetTheme()

    -- 取消所有标签页的选中状态
    for i, t in pairs(self.Tabs) do
        t.Selected = false

        -- 隐藏所有容器
        if self.TabContainers[i] then
            self.TabContainers[i].Visible = false
        end

        -- 重置按钮样式
        local bg = t.Button:FindFirstChildOfClass("ImageLabel")
        if bg then
            bg.ImageTransparency = 1
        end

        -- 重置文字透明度
        local titleLabel = t.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
        if titleLabel then
            titleLabel.TextTransparency = t.Locked and 0.6 or 0.4
        end

        -- 重置图标透明度
        local icon = t.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("ImageLabel")
        if icon then
            icon.ImageTransparency = t.Locked and 0.6 or 0.4
        end
    end

    -- 选中当前标签页
    tab.Selected = true
    self.SelectedTab = index

    -- 显示容器
    if self.TabContainers[index] then
        self.TabContainers[index].Visible = true
    end

    -- 高亮按钮
    local bg = tab.Button:FindFirstChildOfClass("ImageLabel")
    if bg then
        bg.ImageTransparency = 0.9
        bg.ImageColor3 = theme.TabBackgroundActive or Color3.fromRGB(60, 60, 65)
    end

    -- 更新文字透明度
    local titleLabel = tab.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
    if titleLabel then
        titleLabel.TextTransparency = 0
    end

    -- 更新图标透明度
    local icon = tab.Button:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("ImageLabel")
    if icon then
        icon.ImageTransparency = 0.1
    end

    -- 触发回调
    if self.OnChangeCallback then
        Creator.SafeCallback(self.OnChangeCallback, index, tab)
    end
end

-- ============================================================
-- 标签页搜索
-- ============================================================
function TabManager:EnableSearch(placeholder)
    if self.SearchBar then return end

    local sideBar = self.Window:GetSideBar()
    if not sideBar then return end

    -- 创建搜索框容器
    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(1, -8, 0, 36)
    searchContainer.Position = UDim2.new(0, 4, 0, 0)
    searchContainer.BackgroundTransparency = 1
    searchContainer.LayoutOrder = -1  -- 在最前面
    searchContainer.Parent = sideBar

    -- 搜索框背景
    local searchBg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.9,
        ImageColor3 = Creator.GetThemeColor("SearchBarBackground") or Color3.fromRGB(38, 38, 40),
        Parent = searchContainer,
    })

    -- 搜索图标
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 10, 0.5, 0)
    searchIcon.AnchorPoint = Vector2.new(0, 0.5)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = Creator.GetIcon("search")
    searchIcon.ImageColor3 = Creator.GetThemeColor("Icon") or Color3.fromRGB(160, 160, 160)
    searchIcon.ImageTransparency = 0.5
    searchIcon.Parent = searchBg

    -- 搜索输入框
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -36, 1, 0)
    searchBox.Position = UDim2.new(0, 32, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = placeholder or "搜索标签页..."
    searchBox.TextColor3 = Creator.GetThemeColor("Text") or Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderColor3 = Creator.GetThemeColor("Placeholder") or Color3.fromRGB(160, 160, 160)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchBg

    -- 清除按钮
    local clearBtn = Instance.new("ImageButton")
    clearBtn.Size = UDim2.new(0, 16, 0, 16)
    clearBtn.Position = UDim2.new(1, -10, 0.5, 0)
    clearBtn.AnchorPoint = Vector2.new(1, 0.5)
    clearBtn.BackgroundTransparency = 1
    clearBtn.Image = Creator.GetIcon("x")
    clearBtn.ImageColor3 = Creator.GetThemeColor("Icon") or Color3.fromRGB(160, 160, 160)
    clearBtn.ImageTransparency = 1
    clearBtn.Visible = false
    clearBtn.Parent = searchBg

    self.SearchBar = {
        Container = searchContainer,
        Box = searchBox,
        Clear = clearBtn,
    }

    -- 搜索逻辑
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        local hasQuery = #query > 0

        clearBtn.Visible = hasQuery
        clearBtn.ImageTransparency = hasQuery and 0.5 or 1

        for i, tab in pairs(self.Tabs) do
            local title = tab.Title:lower()
            local visible = not hasQuery or string.find(title, query, 1, true) ~= nil

            tab.Button.Visible = visible
            -- 如果标签页被隐藏，同时隐藏其容器（但保留数据）
            if not visible and self.TabContainers[i] then
                if self.SelectedTab == i then
                    -- 如果当前选中的标签页被隐藏，切换到第一个可见的
                    self:SelectFirstVisible()
                end
            end
        end

        -- 如果没有可见标签页，显示空状态
        self:UpdateEmptyState()
    end)

    clearBtn.MouseButton1Click:Connect(function()
        searchBox.Text = ""
        clearBtn.Visible = false
        clearBtn.ImageTransparency = 1
    end)

    -- 调整布局顺序
    local layout = sideBar:FindFirstChildOfClass("UIListLayout")
    if layout then
        -- 重新排序
    end
end

-- ============================================================
-- 辅助方法
-- ============================================================

-- 选择第一个可见的标签页
function TabManager:SelectFirstVisible()
    for i, tab in pairs(self.Tabs) do
        if tab.Button.Visible and not tab.Locked then
            self:SelectTab(i)
            return
        end
    end
end

-- 更新空状态
function TabManager:UpdateEmptyState()
    local hasVisible = false
    for _, tab in pairs(self.Tabs) do
        if tab.Button.Visible then
            hasVisible = true
            break
        end
    end

    -- 如果没有可见标签页，显示空状态
    if not hasVisible then
        -- 创建或显示空状态标签
        if not self.EmptyState then
            local sideBar = self.Window:GetSideBar()
            if sideBar then
                self.EmptyState = Instance.new("TextLabel")
                self.EmptyState.Size = UDim2.new(1, -8, 0, 30)
                self.EmptyState.Position = UDim2.new(0, 4, 0, 0)
                self.EmptyState.BackgroundTransparency = 1
                self.EmptyState.Text = "🔍 没有匹配的标签页"
                self.EmptyState.TextColor3 = Creator.GetThemeColor("Placeholder") or Color3.fromRGB(160, 160, 160)
                self.EmptyState.TextSize = 14
                self.EmptyState.Font = Enum.Font.GothamMedium
                self.EmptyState.TextTransparency = 0.5
                self.EmptyState.Parent = sideBar
            end
        else
            self.EmptyState.Visible = true
        end
    else
        if self.EmptyState then
            self.EmptyState.Visible = false
        end
    end
end

-- ============================================================
-- 设置回调
-- ============================================================
function TabManager:OnChange(callback)
    self.OnChangeCallback = callback
end

-- ============================================================
-- 获取标签页
-- ============================================================
function TabManager:GetTab(index)
    return self.Tabs[index]
end

function TabManager:GetSelectedTab()
    return self.SelectedTab and self.Tabs[self.SelectedTab]
end

function TabManager:GetAllTabs()
    return self.Tabs
end

-- ============================================================
-- 删除标签页
-- ============================================================
function TabManager:RemoveTab(index)
    local tab = self.Tabs[index]
    if not tab then return end

    -- 销毁按钮
    tab.Button:Destroy()

    -- 销毁容器
    if self.TabContainers[index] then
        self.TabContainers[index]:Destroy()
    end

    -- 从表中移除
    self.Tabs[index] = nil
    self.TabContainers[index] = nil

    -- 如果删除的是当前选中的标签页，切换到下一个
    if self.SelectedTab == index then
        self.SelectedTab = nil
        for i, t in pairs(self.Tabs) do
            if not t.Locked then
                self:SelectTab(i)
                break
            end
        end
    end
end

-- ============================================================
-- 导出
-- ============================================================
return TabManager
-- ============================================================
-- 第四段：WindUI 基础元素
-- 依赖：第一段（Creator）+ 第二段（Window）+ 第三段（Tabs）
-- 功能：Button, Toggle, Slider, Input
-- ============================================================

local Creator = require(script.Parent.Creator)  -- 如果作为模块使用
-- 如果是在同一个文件，直接使用上面的 Creator

-- ============================================================
-- 元素基类（共享功能）
-- ============================================================
local ElementBase = {}

function ElementBase:ApplyTheme()
    local theme = Creator.GetTheme()
    -- 子类重写此方法
end

function ElementBase:SetEnabled(enabled)
    self.Enabled = enabled
    if self.Main then
        self.Main.Active = enabled
        self.Main.Visible = enabled
    end
end

function ElementBase:GetEnabled()
    return self.Enabled
end

-- ============================================================
-- 1. Button（按钮）
-- ============================================================
local Button = {}
Button.__index = Button

function Button.new(config)
    config = config or {}

    local self = setmetatable({}, Button)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "按钮"
    self.Icon = config.Icon
    self.Callback = config.Callback or function() end
    self.Variant = config.Variant or "Primary"  -- Primary, Secondary, Danger, Ghost
    self.Size = config.Size or UDim2.new(0, 120, 0, 36)
    self.Enabled = config.Enabled ~= false
    self.Radius = config.Radius or 8
    self.Parent = config.Parent or nil

    -- 颜色映射
    local variantColors = {
        Primary = { bg = theme.Primary or Color3.fromRGB(0, 122, 255), text = Color3.fromRGB(255, 255, 255) },
        Secondary = { bg = theme.Button or Color3.fromRGB(82, 82, 91), text = Color3.fromRGB(255, 255, 255) },
        Danger = { bg = Color3.fromRGB(255, 59, 48), text = Color3.fromRGB(255, 255, 255) },
        Ghost = { bg = Color3.fromRGB(255, 255, 255), text = theme.Text or Color3.fromRGB(255, 255, 255) },
    }

    local colors = variantColors[self.Variant] or variantColors.Primary

    -- ============================================================
    -- 创建按钮
    -- ============================================================
    local button = Instance.new("TextButton")
    button.Size = self.Size
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.Active = self.Enabled
    button.ZIndex = 1
    if self.Parent then
        button.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(self.Radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = colors.bg,
        ImageTransparency = self.Variant == "Ghost" and 1 or 0,
        ZIndex = 0,
        Parent = button,
    })

    -- 悬停背景
    local hoverBg = Creator.NewRoundFrame(self.Radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = button,
    })

    -- 内容容器
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -12, 1, 0)
    content.Position = UDim2.new(0, 6, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = button

    -- 图标
    local icon
    if self.Icon then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = Creator.GetIcon(self.Icon)
        icon.ImageColor3 = colors.text
        icon.ZIndex = 1
        icon.Parent = content
    end

    -- 文字
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -(icon and 24 or 0), 1, 0)
    label.Position = UDim2.new(icon and 24 or 0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = self.Text
    label.TextColor3 = colors.text
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Font = Enum.Font.GothamSemibold
    label.ZIndex = 1
    label.Parent = content

    -- ============================================================
    -- 交互事件
    -- ============================================================

    -- 悬停
    button.MouseEnter:Connect(function()
        if not self.Enabled then return end
        if self.Variant == "Ghost" then
            TweenService:Create(hoverBg, TweenInfo.new(0.12), {
                ImageTransparency = 0.9,
                ImageColor3 = theme.Button or Color3.fromRGB(82, 82, 91),
            }):Play()
        else
            TweenService:Create(hoverBg, TweenInfo.new(0.12), {
                ImageTransparency = 0.9,
                ImageColor3 = colors.bg,
            }):Play()
        end
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(hoverBg, TweenInfo.new(0.12), {
            ImageTransparency = 1,
        }):Play()
    end)

    -- 点击
    button.MouseButton1Click:Connect(function()
        if self.Enabled then
            Creator.SafeCallback(self.Callback)
        end
    end)

    -- ============================================================
    -- 按钮方法
    -- ============================================================

    function self:SetText(text)
        self.Text = text
        label.Text = text
    end

    function self:SetIcon(iconName)
        self.Icon = iconName
        if icon then
            icon.Image = Creator.GetIcon(iconName)
        end
    end

    function self:SetEnabled(enabled)
        self.Enabled = enabled
        button.Active = enabled
        label.TextTransparency = enabled and 0 or 0.5
        if icon then
            icon.ImageTransparency = enabled and 0 or 0.5
        end
    end

    function self:SetVariant(variant)
        self.Variant = variant
        local newColors = variantColors[variant] or variantColors.Primary
        bg.ImageColor3 = newColors.bg
        label.TextColor3 = newColors.text
        if icon then
            icon.ImageColor3 = newColors.text
        end
        if variant == "Ghost" then
            bg.ImageTransparency = 1
        else
            bg.ImageTransparency = 0
        end
    end

    function self:GetMain()
        return button
    end

    self.Main = button
    self.Label = label
    self.IconImage = icon
    self.BG = bg

    return self
end

-- ============================================================
-- 2. Toggle（开关）
-- ============================================================
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(config)
    config = config or {}

    local self = setmetatable({}, Toggle)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "开关"
    self.Desc = config.Desc
    self.Value = config.Value or false
    self.Callback = config.Callback or function() end
    self.Enabled = config.Enabled ~= false
    self.Size = config.Size or UDim2.new(1, -20, 0, 36)
    self.Radius = config.Radius or 8
    self.Parent = config.Parent or nil

    -- ============================================================
    -- 创建开关
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = self.Size
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(self.Radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 内容布局
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container

    -- 文字区域
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -60, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.AutomaticSize = Enum.AutomaticSize.Y
    textContainer.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Text
    title.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Parent = textContainer

    local desc
    if self.Desc then
        desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, 0, 0, 0)
        desc.BackgroundTransparency = 1
        desc.Text = self.Desc
        desc.TextColor3 = theme.Placeholder or Color3.fromRGB(160, 160, 160)
        desc.TextSize = 12
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Font = Enum.Font.GothamMedium
        desc.TextTransparency = 0.3
        desc.AutomaticSize = Enum.AutomaticSize.Y
        desc.Parent = textContainer

        local textLayout = Instance.new("UIListLayout")
        textLayout.Padding = UDim.new(0, 2)
        textLayout.Parent = textContainer
    end

    -- 开关主体
    local toggleSize = 36
    local toggle = Creator.NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, toggleSize, 0, toggleSize - 4),
        ImageTransparency = 0.85,
        ImageColor3 = theme.Text or Color3.fromRGB(255, 255, 255),
        ZIndex = 1,
        Parent = container,
    })

    -- 开关内部填充
    local fill = Creator.NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(self.Value and 0.9 or 0.1, 0, 0.85, 0),
        Position = UDim2.new(self.Value and 0.5 or 0.05, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ImageColor3 = self.Value and theme.Toggle or Color3.fromRGB(100, 100, 100),
        ImageTransparency = self.Value and 0.05 or 0.5,
        ZIndex = 2,
        Parent = toggle,
    })

    -- 开关滑块
    local thumb = Creator.NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, toggleSize - 8, 0, toggleSize - 8),
        Position = UDim2.new(self.Value and 1 or 0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(self.Value and 1 or 0, 0.5),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.1,
        ZIndex = 3,
        Parent = toggle,
    })

    -- 点击区域
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Active = self.Enabled
    hitbox.Parent = container

    -- ============================================================
    -- 切换逻辑
    -- ============================================================
    function self:Set(value, animate)
        animate = animate ~= false
        self.Value = value

        if animate then
            local targetX = value and 0.5 or 0.05
            local targetSize = value and 0.9 or 0.1
            local targetColor = value and theme.Toggle or Color3.fromRGB(100, 100, 100)
            local targetTrans = value and 0.05 or 0.5

            TweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(targetX, 0, 0.5, 0),
                Size = UDim2.new(targetSize, 0, 0.85, 0),
                ImageColor3 = targetColor,
                ImageTransparency = targetTrans,
            }):Play()

            TweenService:Create(thumb, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(value and 1 or 0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(value and 1 or 0, 0.5),
            }):Play()
        else
            fill.Position = UDim2.new(value and 0.5 or 0.05, 0, 0.5, 0)
            fill.Size = UDim2.new(value and 0.9 or 0.1, 0, 0.85, 0)
            fill.ImageColor3 = value and theme.Toggle or Color3.fromRGB(100, 100, 100)
            fill.ImageTransparency = value and 0.05 or 0.5
            thumb.Position = UDim2.new(value and 1 or 0, 0, 0.5, 0)
            thumb.AnchorPoint = Vector2.new(value and 1 or 0, 0.5)
        end

        Creator.SafeCallback(self.Callback, value)
    end

    function self:Toggle()
        self:Set(not self.Value)
    end

    function self:Get()
        return self.Value
    end

    function self:SetEnabled(enabled)
        self.Enabled = enabled
        hitbox.Active = enabled
        container.Active = enabled
        if not enabled then
            title.TextTransparency = 0.5
            if desc then
                desc.TextTransparency = 0.6
            end
        else
            title.TextTransparency = 0
            if desc then
                desc.TextTransparency = 0.3
            end
        end
    end

    -- ============================================================
    -- 事件绑定
    -- ============================================================
    hitbox.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Toggle()
        end
    end)

    -- 悬停效果
    hitbox.MouseEnter:Connect(function()
        if self.Enabled then
            TweenService:Create(bg, TweenInfo.new(0.08), {
                ImageTransparency = 0.9,
            }):Play()
        end
    end)

    hitbox.MouseLeave:Connect(function()
        TweenService:Create(bg, TweenInfo.new(0.08), {
            ImageTransparency = 0.95,
        }):Play()
    end)

    -- ============================================================
    -- 初始化
    -- ============================================================
    self:Set(self.Value, false)

    self.Main = container
    self.Title = title
    self.Desc = desc
    self.Hitbox = hitbox
    self.Fill = fill
    self.Thumb = thumb

    return self
end

-- ============================================================
-- 3. Slider（滑块）
-- ============================================================
local Slider = {}
Slider.__index = Slider

function Slider.new(config)
    config = config or {}

    local self = setmetatable({}, Slider)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "滑块"
    self.Desc = config.Desc
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Value = config.Value or 50
    self.Step = config.Step or 1
    self.Callback = config.Callback or function() end
    self.Enabled = config.Enabled ~= false
    self.Width = config.Width or 150
    self.Parent = config.Parent or nil

    -- 限制初始值
    self.Value = math.clamp(self.Value, self.Min, self.Max)

    -- ============================================================
    -- 创建滑块
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 内容布局
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container

    -- 文字区域
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(0, 80, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.AutomaticSize = Enum.AutomaticSize.X
    textContainer.Parent = container

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Text
    title.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Parent = textContainer

    -- 滑块轨道
    local track = Creator.NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, self.Width, 0, 6),
        ImageTransparency = 0.8,
        ImageColor3 = theme.Placeholder or Color3.fromRGB(160, 160, 160),
        ZIndex = 1,
        Parent = container,
    })

    -- 滑块填充
    local fill = Creator.NewRoundFrame(999, "Squircle", {
        Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0),
        ImageColor3 = theme.Slider or Color3.fromRGB(0, 145, 255),
        ImageTransparency = 0.1,
        ZIndex = 2,
        Parent = track,
    })

    -- 滑块手柄
    local thumb = Creator.NewRoundFrame(999, "Squircle", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = theme.SliderThumb or Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.1,
        ZIndex = 3,
        Parent = track,
    })

    -- 数值显示
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(self.Value)
    valueLabel.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextTransparency = 0.5
    valueLabel.Parent = container

    -- ============================================================
    -- 滑块逻辑
    -- ============================================================
    local isDragging = false
    local dragStart = nil
    local startValue = nil

    function self:Set(value, animate)
        animate = animate ~= false
        value = math.clamp(value, self.Min, self.Max)
        -- 按步长取整
        if self.Step > 0 then
            value = math.floor((value - self.Min) / self.Step + 0.5) * self.Step + self.Min
        end
        self.Value = value

        local progress = (value - self.Min) / (self.Max - self.Min)

        if animate then
            TweenService:Create(fill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(progress, 0, 1, 0),
            }):Play()
            TweenService:Create(thumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(progress, 0, 0.5, 0),
            }):Play()
        else
            fill.Size = UDim2.new(progress, 0, 1, 0)
            thumb.Position = UDim2.new(progress, 0, 0.5, 0)
        end

        valueLabel.Text = tostring(value)
        Creator.SafeCallback(self.Callback, value)
    end

    function self:Get()
        return self.Value
    end

    function self:SetMin(min)
        self.Min = min
        if self.Value < min then
            self:Set(min)
        end
    end

    function self:SetMax(max)
        self.Max = max
        if self.Value > max then
            self:Set(max)
        end
    end

    -- ============================================================
    -- 交互事件
    -- ============================================================

    -- 鼠标按下开始拖动
    track.InputBegan:Connect(function(input)
        if not self.Enabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startValue = self.Value

            -- 直接跳转到点击位置
            local relativeX = input.Position.X - track.AbsolutePosition.X
            local progress = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
            local newValue = self.Min + progress * (self.Max - self.Min)
            self:Set(newValue, true)
        end
    end)

    -- 拖动移动
    UserInputService.InputChanged:Connect(function(input)
        if not isDragging or not self.Enabled then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           (input.UserInputType == Enum.UserInputType.Touch and input == dragStart) then
            local relativeX = input.Position.X - track.AbsolutePosition.X
            local progress = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
            local newValue = self.Min + progress * (self.Max - self.Min)
            self:Set(newValue, true)
        end
    end)

    -- 停止拖动
    UserInputService.InputEnded:Connect(function(input)
        if isDragging then
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end
    end)

    -- 滚轮调节
    track.MouseWheelForward:Connect(function()
        if self.Enabled then
            self:Set(self.Value + self.Step * 2)
        end
    end)

    track.MouseWheelBackward:Connect(function()
        if self.Enabled then
            self:Set(self.Value - self.Step * 2)
        end
    end)

    -- ============================================================
    -- 主题更新
    -- ============================================================
    self.Main = container
    self.Title = title
    self.Track = track
    self.Fill = fill
    self.Thumb = thumb
    self.ValueLabel = valueLabel

    return self
end

-- ============================================================
-- 4. Input（输入框）
-- ============================================================
local Input = {}
Input.__index = Input

function Input.new(config)
    config = config or {}

    local self = setmetatable({}, Input)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "输入框"
    self.Desc = config.Desc
    self.Placeholder = config.Placeholder or "请输入..."
    self.Value = config.Value or ""
    self.Callback = config.Callback or function() end
    self.Enabled = config.Enabled ~= false
    self.MultiLine = config.MultiLine or false
    self.Parent = config.Parent or nil
    self.Width = config.Width or 160

    -- ============================================================
    -- 创建输入框
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, self.MultiLine and 80 or 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = self.MultiLine and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 内容布局（横向）
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, self.MultiLine and 8 or 0)
    padding.PaddingBottom = UDim.new(0, self.MultiLine and 8 or 0)
    padding.Parent = container

    -- 文字标签
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = self.Text
    label.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Parent = container

    -- 输入框
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -label.AbsoluteSize.X - 12, 1, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = self.Value
    inputBox.PlaceholderText = self.Placeholder
    inputBox.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderColor3 = theme.Placeholder or Color3.fromRGB(160, 160, 160)
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.MultiLine = self.MultiLine
    inputBox.ClearTextOnFocus = false
    inputBox.Active = self.Enabled
    inputBox.Parent = container

    -- 调整宽度
    label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        inputBox.Size = UDim2.new(1, -(label.AbsoluteSize.X + 12), 1, 0)
    end)

    -- ============================================================
    -- 输入框逻辑
    -- ============================================================
    function self:Set(value)
        self.Value = value
        inputBox.Text = value
        Creator.SafeCallback(self.Callback, value)
    end

    function self:Get()
        return self.Value
    end

    function self:SetPlaceholder(text)
        self.Placeholder = text
        inputBox.PlaceholderText = text
    end

    function self:SetEnabled(enabled)
        self.Enabled = enabled
        inputBox.Active = enabled
        label.TextTransparency = enabled and 0 or 0.5
        inputBox.TextTransparency = enabled and 0 or 0.5
    end

    -- ============================================================
    -- 事件绑定
    -- ============================================================

    -- 实时回调（输入变化时）
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        if self.Enabled then
            self.Value = inputBox.Text
            Creator.SafeCallback(self.Callback, inputBox.Text)
        end
    end)

    -- 失焦回调
    inputBox.FocusLost:Connect(function()
        if self.Enabled then
            Creator.SafeCallback(self.Callback, inputBox.Text, true)
        end
    end)

    -- 悬停效果
    container.MouseEnter:Connect(function()
        if self.Enabled then
            TweenService:Create(bg, TweenInfo.new(0.08), {
                ImageTransparency = 0.9,
            }):Play()
        end
    end)

    container.MouseLeave:Connect(function()
        TweenService:Create(bg, TweenInfo.new(0.08), {
            ImageTransparency = 0.95,
        }):Play()
    end)

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.Label = label
    self.InputBox = inputBox

    return self
end

-- ============================================================
-- 元素工厂（统一导出）
-- ============================================================
local Elements = {
    Button = Button,
    Toggle = Toggle,
    Slider = Slider,
    Input = Input,
}

-- 添加到 Creator 中
Creator.Elements = Elements

return Elements
-- ============================================================
-- 第五段：WindUI 高级元素
-- 依赖：第一段（Creator）+ 第二段（Window）+ 第三段（Tabs）
-- 功能：Dropdown, Colorpicker, Keybind, Code
-- ============================================================

local Creator = require(script.Parent.Creator)  -- 如果作为模块使用
-- 如果是在同一个文件，直接使用上面的 Creator

-- ============================================================
-- 1. Dropdown（下拉菜单）
-- ============================================================
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(config)
    config = config or {}

    local self = setmetatable({}, Dropdown)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "下拉菜单"
    self.Desc = config.Desc
    self.Options = config.Options or {}
    self.Value = config.Value or nil
    self.Placeholder = config.Placeholder or "请选择..."
    self.Callback = config.Callback or function() end
    self.Enabled = config.Enabled ~= false
    self.Width = config.Width or 150
    self.Parent = config.Parent or nil
    self.MultiSelect = config.MultiSelect or false

    -- 如果有多选，值用表存储
    if self.MultiSelect and type(self.Value) ~= "table" then
        self.Value = {}
    end

    -- ============================================================
    -- 创建下拉菜单
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 内容布局
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container

    -- 文字标签
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = self.Text
    label.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Parent = container

    -- 值显示
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -60, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = self.Placeholder
    valueLabel.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextTransparency = 0.3
    valueLabel.Parent = container

    -- 下拉箭头
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.BackgroundTransparency = 1
    arrow.Image = Creator.GetIcon("chevron-down")
    arrow.ImageColor3 = theme.Icon or Color3.fromRGB(160, 160, 160)
    arrow.ImageTransparency = 0.5
    arrow.Parent = container

    -- 点击区域
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Active = self.Enabled
    hitbox.Parent = container

    -- ============================================================
    -- 下拉菜单列表（弹出层）
    -- ============================================================
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(0, 0, 0, 0)
    dropdownContainer.Position = UDim2.new(0, 0, 0, 0)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Visible = false
    dropdownContainer.ZIndex = 100
    dropdownContainer.Parent = container

    local listBg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 0, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.DropdownBackground or Color3.fromRGB(38, 38, 40),
        ZIndex = 0,
        Parent = dropdownContainer,
    })

    local listScroller = Instance.new("ScrollingFrame")
    listScroller.Size = UDim2.new(1, -4, 0, 0)
    listScroller.Position = UDim2.new(0, 2, 0, 2)
    listScroller.BackgroundTransparency = 1
    listScroller.ScrollBarThickness = 0
    listScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    listScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroller.ScrollingDirection = Enum.ScrollingDirection.Y
    listScroller.ClipsDescendants = true
    listScroller.Parent = listBg

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listScroller

    -- ============================================================
    -- 更新下拉列表
    -- ============================================================
    function self:UpdateOptions(options)
        self.Options = options or self.Options

        -- 清空列表
        for _, child in ipairs(listScroller:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        -- 创建选项按钮
        for i, option in ipairs(self.Options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 30)
            btn.Position = UDim2.new(0, 4, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Text = option
            btn.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.GothamMedium
            btn.ZIndex = 1
            btn.Parent = listScroller

            -- 是否选中
            local isSelected = false
            if self.MultiSelect then
                for _, v in ipairs(self.Value) do
                    if v == option then
                        isSelected = true
                        break
                    end
                end
            else
                isSelected = (self.Value == option)
            end

            if isSelected then
                btn.Text = "✓ " .. option
                btn.TextColor3 = theme.Primary or Color3.fromRGB(0, 122, 255)
            end

            -- 悬停效果
            local hoverBg = Creator.NewRoundFrame(6, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ImageTransparency = 1,
                ZIndex = 0,
                Parent = btn,
            })

            btn.MouseEnter:Connect(function()
                TweenService:Create(hoverBg, TweenInfo.new(0.08), {
                    ImageTransparency = 0.9,
                    ImageColor3 = theme.TabBackgroundHover or Color3.fromRGB(50, 50, 55),
                }):Play()
            end)

            btn.MouseLeave:Connect(function()
                TweenService:Create(hoverBg, TweenInfo.new(0.08), {
                    ImageTransparency = 1,
                }):Play()
            end)

            -- 点击选择
            btn.MouseButton1Click:Connect(function()
                if not self.Enabled then return end
                if self.MultiSelect then
                    -- 多选模式
                    local found = false
                    for i, v in ipairs(self.Value) do
                        if v == option then
                            table.remove(self.Value, i)
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(self.Value, option)
                    end
                    self:UpdateOptions()
                else
                    -- 单选模式
                    self.Value = option
                    self:UpdateValueDisplay()
                    self:Close()
                end
                Creator.SafeCallback(self.Callback, self.Value)
            end)
        end

        -- 更新列表高度
        local count = #self.Options
        local height = math.min(count * 34 + 8, 200)
        listBg.Size = UDim2.new(1, 0, 0, height)
        listScroller.Size = UDim2.new(1, -4, 0, height - 4)

        -- 如果列表为空，隐藏
        if count == 0 then
            dropdownContainer.Visible = false
        end
    end

    -- ============================================================
    -- 更新值显示
    -- ============================================================
    function self:UpdateValueDisplay()
        if self.MultiSelect then
            local text = ""
            for i, v in ipairs(self.Value) do
                text = text .. v
                if i < #self.Value then
                    text = text .. ", "
                end
            end
            if text == "" then
                text = self.Placeholder
            end
            valueLabel.Text = text
        else
            valueLabel.Text = self.Value or self.Placeholder
        end
    end

    -- ============================================================
    -- 打开/关闭
    -- ============================================================
    function self:Open()
        if not self.Enabled then return end
        if #self.Options == 0 then return end

        dropdownContainer.Visible = true

        -- 计算位置
        local absPos = container.AbsolutePosition
        local absSize = container.AbsoluteSize

        dropdownContainer.Position = UDim2.new(0, 0, 0, absSize.Y + 2)

        -- 确保不超出屏幕
        local viewport = workspace.CurrentCamera.ViewportSize
        local listHeight = listBg.AbsoluteSize.Y

        if absPos.Y + absSize.Y + listHeight + 10 > viewport.Y then
            -- 向上弹出
            dropdownContainer.Position = UDim2.new(0, 0, 0, -listHeight - 2)
        end

        -- 动画
        listBg.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(listBg, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, math.min(#self.Options * 34 + 8, 200)),
        }):Play()

        TweenService:Create(arrow, TweenInfo.new(0.15), {
            Rotation = 180,
        }):Play()
    end

    function self:Close()
        TweenService:Create(listBg, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0),
        }):Play()

        TweenService:Create(arrow, TweenInfo.new(0.15), {
            Rotation = 0,
        }):Play()

        task.wait(0.1)
        dropdownContainer.Visible = false
    end

    function self:Toggle()
        if dropdownContainer.Visible then
            self:Close()
        else
            self:Open()
        end
    end

    -- ============================================================
    -- 交互事件
    -- ============================================================
    hitbox.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Toggle()
        end
    end)

    -- 点击外部关闭
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dropdownContainer.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = dropdownContainer.AbsolutePosition
                local absSize = dropdownContainer.AbsoluteSize

                if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
                   mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                    -- 点击在外部，关闭
                    self:Close()
                end
            end
        end
    end)

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.Hitbox = hitbox
    self.ValueLabel = valueLabel
    self.DropdownContainer = dropdownContainer

    self:UpdateOptions(self.Options)
    self:UpdateValueDisplay()

    return self
end

-- ============================================================
-- 2. Colorpicker（颜色选择器）
-- ============================================================
local Colorpicker = {}
Colorpicker.__index = Colorpicker

function Colorpicker.new(config)
    config = config or {}

    local self = setmetatable({}, Colorpicker)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "颜色选择器"
    self.Desc = config.Desc
    self.Value = config.Value or Color3.fromRGB(0, 122, 255)
    self.Callback = config.Callback or function() end
    self.Enabled = config.Enabled ~= false
    self.Parent = config.Parent or nil

    -- ============================================================
    -- 创建颜色选择器
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 内容布局
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container

    -- 文字标签
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = self.Text
    label.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.Parent = container

    -- 颜色预览
    local preview = Creator.NewRoundFrame(6, "Squircle", {
        Size = UDim2.new(0, 24, 0, 24),
        ImageColor3 = self.Value,
        ImageTransparency = 0,
        ZIndex = 1,
        Parent = container,
    })

    -- 点击区域
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Active = self.Enabled
    hitbox.Parent = container

    -- ============================================================
    -- 颜色选择器弹出面板
    -- ============================================================
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 220, 0, 240)
    popup.Position = UDim2.new(0, 0, 1, 4)
    popup.BackgroundTransparency = 1
    popup.Visible = false
    popup.ZIndex = 100
    popup.Parent = container

    local popupBg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.DropdownBackground or Color3.fromRGB(38, 38, 40),
        ZIndex = 0,
        Parent = popup,
    })

    -- 色相条（HSV）
    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(1, -20, 0, 16)
    hueBar.Position = UDim2.new(0, 10, 0, 10)
    hueBar.BackgroundTransparency = 1
    hueBar.Parent = popupBg

    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 0
    local hueColors = {}
    for i = 0, 1, 0.01 do
        table.insert(hueColors, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
    end
    hueGradient.Color = ColorSequence.new(hueColors)
    hueGradient.Parent = hueBar

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueBar

    -- 饱和度/明度面板
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

    -- 颜色预览（大）
    local previewLarge = Instance.new("Frame")
    previewLarge.Size = UDim2.new(0, 30, 0, 30)
    previewLarge.Position = UDim2.new(1, -40, 0, 170)
    previewLarge.BackgroundColor3 = self.Value
    previewLarge.BackgroundTransparency = 0
    previewLarge.ZIndex = 1
    previewLarge.Parent = popupBg

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = previewLarge

    -- 十六进制输入框
    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.new(1, -50, 0, 30)
    hexInput.Position = UDim2.new(0, 10, 0, 170)
    hexInput.BackgroundTransparency = 0.9
    hexInput.BackgroundColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44)
    hexInput.Text = Creator.Color3ToHex(self.Value)
    hexInput.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    hexInput.TextSize = 14
    hexInput.Font = Enum.Font.GothamMedium
    hexInput.TextXAlignment = Enum.TextXAlignment.Center
    hexInput.Parent = popupBg

    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 4)
    hexCorner.Parent = hexInput

    -- ============================================================
    -- 颜色选择逻辑
    -- ============================================================
    local currentHue = 0
    local currentSat = 1
    local currentVal = 1
    local isDragging = false

    -- 解析初始颜色
    local h, s, v = Creator.ColorToHSV(self.Value)
    currentHue = h or 0
    currentSat = s or 1
    currentVal = v or 1

    function self:UpdateColor(hue, sat, val)
        hue = hue or currentHue
        sat = sat or currentSat
        val = val or currentVal

        currentHue = hue
        currentSat = sat
        currentVal = val

        local color = Color3.fromHSV(hue, sat, val)
        self.Value = color

        -- 更新预览
        preview.ImageColor3 = color
        previewLarge.BackgroundColor3 = color
        svImage.ImageColor3 = Color3.fromHSV(hue, 1, 1)

        -- 更新十六进制
        hexInput.Text = Creator.Color3ToHex(color)

        -- 回调
        Creator.SafeCallback(self.Callback, color)
    end

    -- 色相条点击
    hueBar.InputBegan:Connect(function(input)
        if not self.Enabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            local relativeX = input.Position.X - hueBar.AbsolutePosition.X
            local hue = math.clamp(relativeX / hueBar.AbsoluteSize.X, 0, 1)
            self:UpdateColor(hue)
        end
    end)

    -- 色相条拖动
    UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            local relativeX = input.Position.X - hueBar.AbsolutePosition.X
            local hue = math.clamp(relativeX / hueBar.AbsoluteSize.X, 0, 1)
            self:UpdateColor(hue)
        end
    end)

    -- SV面板点击
    svPanel.InputBegan:Connect(function(input)
        if not self.Enabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local relativeX = input.Position.X - svPanel.AbsolutePosition.X
            local relativeY = input.Position.Y - svPanel.AbsolutePosition.Y
            local sat = math.clamp(relativeX / svPanel.AbsoluteSize.X, 0, 1)
            local val = 1 - math.clamp(relativeY / svPanel.AbsoluteSize.Y, 0, 1)
            self:UpdateColor(nil, sat, val)
        end
    end)

    -- SV面板拖动
    UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            local relativeX = input.Position.X - svPanel.AbsolutePosition.X
            local relativeY = input.Position.Y - svPanel.AbsolutePosition.Y
            local sat = math.clamp(relativeX / svPanel.AbsoluteSize.X, 0, 1)
            local val = 1 - math.clamp(relativeY / svPanel.AbsoluteSize.Y, 0, 1)
            self:UpdateColor(nil, sat, val)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    -- 十六进制输入
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        local success, color = pcall(function()
            return Color3.fromHex(hex)
        end)
        if success and color then
            local h, s, v = Creator.ColorToHSV(color)
            self:UpdateColor(h, s, v)
        else
            hexInput.Text = Creator.Color3ToHex(self.Value)
        end
    end)

    -- ============================================================
    -- 打开/关闭
    -- ============================================================
    function self:Open()
        if not self.Enabled then return end
        popup.Visible = true

        -- 确保不超出屏幕
        local absPos = container.AbsolutePosition
        local viewport = workspace.CurrentCamera.ViewportSize

        if absPos.Y + container.AbsoluteSize.Y + 250 > viewport.Y then
            popup.Position = UDim2.new(0, 0, 0, -250)
        else
            popup.Position = UDim2.new(0, 0, 1, 4)
        end

        -- 动画
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
        if popup.Visible then
            self:Close()
        else
            self:Open()
        end
    end

    -- ============================================================
    -- 交互事件
    -- ============================================================
    hitbox.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Toggle()
        end
    end)

    -- 点击外部关闭
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if popup.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = popup.AbsolutePosition
                local absSize = popup.AbsoluteSize

                if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
                   mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                    self:Close()
                end
            end
        end
    end)

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.Hitbox = hitbox

    return self
end

-- ============================================================
-- 3. Keybind（键位绑定）
-- ============================================================
local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(config)
    config = config or {}

    local self = setmetatable({}, Keybind)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "键位绑定"
    self.Desc = config.Desc
    self.Value = config.Value or "F"
    self.Callback = config.Callback or function() end
    self.Enabled = config.Enabled ~= false
    self.Recording = false
    self.Parent = config.Parent or nil

    -- ============================================================
    -- 创建键位绑定
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 内容布局
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container

    -- 文字标签
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = self.Text
    label.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.Parent = container

    -- 键位显示
    local keyDisplay = Creator.NewRoundFrame(6, "Squircle", {
        Size = UDim2.new(0, 60, 0, 28),
        ImageTransparency = 0.9,
        ImageColor3 = theme.Button or Color3.fromRGB(82, 82, 91),
        ZIndex = 1,
        Parent = container,
    })

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, 0, 1, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = self.Value
    keyLabel.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    keyLabel.TextSize = 13
    keyLabel.Font = Enum.Font.GothamMedium
    keyLabel.ZIndex = 2
    keyLabel.Parent = keyDisplay

    -- 点击区域
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Active = self.Enabled
    hitbox.Parent = container

    -- ============================================================
    -- 键位绑定逻辑
    -- ============================================================
    function self:Set(key)
        self.Value = key
        keyLabel.Text = key
        Creator.SafeCallback(self.Callback, key)
    end

    function self:Get()
        return self.Value
    end

    function self:StartRecording()
        if not self.Enabled then return end
        self.Recording = true
        keyLabel.Text = "..."
        keyLabel.TextColor3 = theme.Primary or Color3.fromRGB(0, 122, 255)
    end

    function self:StopRecording()
        self.Recording = false
        keyLabel.Text = self.Value
        keyLabel.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    end

    -- 键盘监听
    UserInputService.InputBegan:Connect(function(input)
        if not self.Recording then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            -- 忽略特殊键
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

    -- 点击开始录制
    hitbox.MouseButton1Click:Connect(function()
        if self.Enabled then
            if self.Recording then
                self:StopRecording()
            else
                self:StartRecording()
            end
        end
    end)

    -- 点击外部取消录制
    UserInputService.InputBegan:Connect(function(input)
        if self.Recording and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = container.AbsolutePosition
            local absSize = container.AbsoluteSize

            if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
               mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
                self:StopRecording()
            end
        end
    end)

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.Hitbox = hitbox
    self.KeyDisplay = keyDisplay
    self.KeyLabel = keyLabel

    return self
end

-- ============================================================
-- 4. Code（代码高亮显示）
-- ============================================================
local Code = {}
Code.__index = Code

function Code.new(config)
    config = config or {}

    local self = setmetatable({}, Code)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "代码"
    self.Code = config.Code or ""
    self.Language = config.Language or "lua"
    self.Height = config.Height or 120
    self.Parent = config.Parent or nil

    -- 简单语法高亮
    local keywords = {
        lua = {
            "and", "break", "do", "else", "elseif", "end", "false",
            "for", "function", "goto", "if", "in", "local", "nil",
            "not", "or", "repeat", "return", "then", "true", "until", "while",
            "print", "error", "pcall", "xpcall", "assert", "select",
            "tostring", "tonumber", "type", "typeof", "rawget", "rawset",
        },
        rbx = {
            "game", "workspace", "script", "Instance", "CFrame", "Vector3",
            "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
            "Enum", "TweenInfo", "Rect", "Region3", "Axes", "OverlapParams",
        },
    }

    local colors = {
        keyword = Color3.fromRGB(200, 160, 255),
        string = Color3.fromRGB(160, 255, 160),
        comment = Color3.fromRGB(150, 150, 150),
        number = Color3.fromRGB(255, 200, 150),
        function_call = Color3.fromRGB(150, 200, 255),
        operator = Color3.fromRGB(150, 220, 210),
        rbx = Color3.fromRGB(255, 180, 180),
    }

    -- 高亮函数
    local function highlight(code)
        local result = {}
        local i = 1
        local len = #code

        while i <= len do
            local char = code:sub(i, i)

            -- 字符串
            if char == '"' or char == "'" then
                local start = i
                i = i + 1
                while i <= len do
                    if code:sub(i, i) == char and code:sub(i-1, i-1) ~= "\\" then
                        break
                    end
                    i = i + 1
                end
                local str = code:sub(start, i)
                table.insert(result, string.format(
                    '<font color="#%s">%s</font>',
                    Creator.Color3ToHex(colors.string),
                    str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
                ))
                i = i + 1
                continue
            end

            -- 注释
            if char == "-" and code:sub(i+1, i+1) == "-" then
                local start = i
                while i <= len and code:sub(i, i) ~= "\n" do
                    i = i + 1
                end
                local comment = code:sub(start, i-1)
                table.insert(result, string.format(
                    '<font color="#%s">%s</font>',
                    Creator.Color3ToHex(colors.comment),
                    comment:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
                ))
                continue
            end

            -- 数字
            if char:match("[%d]") then
                local start = i
                while i <= len and code:sub(i, i):match("[%d%.]") do
                    i = i + 1
                end
                local num = code:sub(start, i-1)
                table.insert(result, string.format(
                    '<font color="#%s">%s</font>',
                    Creator.Color3ToHex(colors.number),
                    num
                ))
                continue
            end

            -- 单词
            if char:match("[%a_]") then
                local start = i
                while i <= len and code:sub(i, i):match("[%w_]") do
                    i = i + 1
                end
                local word = code:sub(start, i-1)

                local isKeyword = false
                local color = colors.keyword

                -- 检查关键字
                if self.Language == "lua" then
                    for _, kw in ipairs(keywords.lua) do
                        if kw == word then
                            isKeyword = true
                            color = colors.keyword
                            break
                        end
                    end
                    if not isKeyword then
                        for _, kw in ipairs(keywords.rbx) do
                            if kw == word then
                                isKeyword = true
                                color = colors.rbx
                                break
                            end
                        end
                    end
                end

                if isKeyword then
                    table.insert(result, string.format(
                        '<font color="#%s">%s</font>',
                        Creator.Color3ToHex(color),
                        word
                    ))
                else
                    table.insert(result, word)
                end
                continue
            end

            -- 运算符
            if char:match("[+%-*/^=<>~%%#]") then
                local start = i
                while i <= len and code:sub(i, i):match("[+%-*/^=<>~%%#]") do
                    i = i + 1
                end
                local op = code:sub(start, i-1)
                table.insert(result, string.format(
                    '<font color="#%s">%s</font>',
                    Creator.Color3ToHex(colors.operator),
                    op
                ))
                continue
            end

            -- 普通字符
            table.insert(result, char)
            i = i + 1
        end

        return table.concat(result)
    end

    -- ============================================================
    -- 创建代码显示
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, self.Height)
    container.BackgroundTransparency = 1
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 0, 30)
    title.Position = UDim2.new(0, 6, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = self.Text
    title.TextColor3 = theme.Placeholder or Color3.fromRGB(160, 160, 160)
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamMedium
    title.TextTransparency = 0.3
    title.Parent = container

    -- 代码显示
    local codeDisplay = Instance.new("TextLabel")
    codeDisplay.Size = UDim2.new(1, -12, 1, -40)
    codeDisplay.Position = UDim2.new(0, 6, 0, 34)
    codeDisplay.BackgroundTransparency = 1
    codeDisplay.Text = highlight(self.Code)
    codeDisplay.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    codeDisplay.TextSize = 13
    codeDisplay.TextXAlignment = Enum.TextXAlignment.Left
    codeDisplay.TextYAlignment = Enum.TextYAlignment.Top
    codeDisplay.Font = Enum.Font.Code
    codeDisplay.RichText = true
    codeDisplay.AutomaticSize = Enum.AutomaticSize.X
    codeDisplay.Parent = container

    -- 滚动容器
    local scroller = Instance.new("ScrollingFrame")
    scroller.Size = UDim2.new(1, 0, 1, -40)
    scroller.Position = UDim2.new(0, 0, 0, 34)
    scroller.BackgroundTransparency = 1
    scroller.ScrollBarThickness = 4
    scroller.ScrollBarImageTransparency = 0.8
    scroller.CanvasSize = UDim2.new(codeDisplay.AbsoluteSize.X + 12, 0, 0, 0)
    scroller.ScrollingDirection = Enum.ScrollingDirection.X
    scroller.ClipsDescendants = true
    scroller.Parent = container

    codeDisplay.Parent = scroller

    -- 更新滚动区域
    codeDisplay:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        scroller.CanvasSize = UDim2.new(codeDisplay.AbsoluteSize.X + 12, 0, 0, 0)
    end)

    -- ============================================================
    -- 更新代码
    -- ============================================================
    function self:Set(code)
        self.Code = code
        codeDisplay.Text = highlight(code)
    end

    function self:Get()
        return self.Code
    end

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.Display = codeDisplay

    return self
end

-- ============================================================
-- 元素工厂（统一导出）
-- ============================================================
local AdvancedElements = {
    Dropdown = Dropdown,
    Colorpicker = Colorpicker,
    Keybind = Keybind,
    Code = Code,
}

-- 添加到 Creator 中
Creator.AdvancedElements = AdvancedElements

return AdvancedElements
-- ============================================================
-- 第六段：WindUI 布局容器
-- 依赖：第一段（Creator）+ 第二段（Window）+ 第三段（Tabs）
-- 功能：Group, HStack, VStack, Section
-- ============================================================

local Creator = require(script.Parent.Creator)  -- 如果作为模块使用
-- 如果是在同一个文件，直接使用上面的 Creator

-- ============================================================
-- 1. Group（分组容器）
-- 用于将相关元素组合在一起，带边框和标题
-- ============================================================
local Group = {}
Group.__index = Group

function Group.new(config)
    config = config or {}

    local self = setmetatable({}, Group)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Title = config.Title or "分组"
    self.Parent = config.Parent or nil
    self.Radius = config.Radius or 10
    self.Padding = config.Padding or 10
    self.Collapsible = config.Collapsible or false
    self.Opened = config.Opened or true
    self.Elements = {}

    -- ============================================================
    -- 创建分组容器
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = true
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景
    local bg = Creator.NewRoundFrame(self.Radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.95,
        ImageColor3 = theme.ElementBackground or Color3.fromRGB(42, 42, 44),
        ZIndex = 0,
        Parent = container,
    })

    -- 边框
    local border = Creator.NewRoundFrame(self.Radius - 1, "SquircleOutline", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.9,
        ImageColor3 = theme.Outline or Color3.fromRGB(255, 255, 255),
        ZIndex = 0,
        Parent = container,
    })

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 1
    titleBar.Parent = container

    -- 标题文字
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.ZIndex = 2
    titleLabel.Parent = titleBar

    -- 折叠按钮
    local toggleBtn
    if self.Collapsible then
        toggleBtn = Instance.new("ImageButton")
        toggleBtn.Size = UDim2.new(0, 20, 0, 20)
        toggleBtn.Position = UDim2.new(1, -30, 0.5, 0)
        toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Image = Creator.GetIcon(self.Opened and "chevron-up" or "chevron-down")
        toggleBtn.ImageColor3 = theme.Icon or Color3.fromRGB(160, 160, 160)
        toggleBtn.ImageTransparency = 0.5
        toggleBtn.ZIndex = 2
        toggleBtn.Parent = titleBar

        -- 点击切换
        toggleBtn.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
    end

    -- 内容容器
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 32)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = container

    -- 内容布局
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = content

    -- 内边距
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, self.Padding)
    padding.PaddingBottom = UDim.new(0, self.Padding)
    padding.PaddingLeft = UDim.new(0, self.Padding)
    padding.PaddingRight = UDim.new(0, self.Padding)
    padding.Parent = content

    -- ============================================================
    -- 容器方法
    -- ============================================================

    -- 添加元素
    function self:Add(element)
        if not element then return end
        if element.Parent then
            element.Parent = content
        elseif element.Main then
            element.Main.Parent = content
            table.insert(self.Elements, element)
        else
            warn("[Group] 无效的元素")
        end
    end

    -- 获取内容容器
    function self:GetContent()
        return content
    end

    -- 获取布局
    function self:GetLayout()
        return contentLayout
    end

    -- 折叠/展开
    function self:Toggle()
        self.Opened = not self.Opened
        content.Visible = self.Opened
        if toggleBtn then
            toggleBtn.Image = Creator.GetIcon(self.Opened and "chevron-up" or "chevron-down")
        end
    end

    function self:Open()
        self.Opened = true
        content.Visible = true
        if toggleBtn then
            toggleBtn.Image = Creator.GetIcon("chevron-up")
        end
    end

    function self:Close()
        self.Opened = false
        content.Visible = false
        if toggleBtn then
            toggleBtn.Image = Creator.GetIcon("chevron-down")
        end
    end

    -- 设置标题
    function self:SetTitle(title)
        self.Title = title
        titleLabel.Text = title
    end

    -- 清空内容
    function self:Clear()
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("UIListLayout") or child:IsA("UIPadding") then
                -- 保留布局
            else
                child:Destroy()
            end
        end
        self.Elements = {}
    end

    -- 销毁
    function self:Destroy()
        container:Destroy()
    end

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.TitleLabel = titleLabel
    self.Content = content
    self.ContentLayout = contentLayout

    -- 如果默认折叠，设置状态
    if not self.Opened and self.Collapsible then
        content.Visible = false
        if toggleBtn then
            toggleBtn.Image = Creator.GetIcon("chevron-down")
        end
    end

    return self
end

-- ============================================================
-- 2. HStack（水平堆栈）
-- 水平排列子元素，自动均匀分布
-- ============================================================
local HStack = {}
HStack.__index = HStack

function HStack.new(config)
    config = config or {}

    local self = setmetatable({}, HStack)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Parent = config.Parent or nil
    self.Spacing = config.Spacing or 6
    self.Padding = config.Padding or 4
    self.Elements = {}

    -- ============================================================
    -- 创建水平堆栈
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 内容布局
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.Padding = UDim.new(0, self.Spacing)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    contentLayout.Parent = container

    -- 内边距
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, self.Padding)
    padding.PaddingBottom = UDim.new(0, self.Padding)
    padding.PaddingLeft = UDim.new(0, self.Padding)
    padding.PaddingRight = UDim.new(0, self.Padding)
    padding.Parent = container

    -- ============================================================
    -- 容器方法
    -- ============================================================

    -- 添加元素
    function self:Add(element)
        if not element then return end
        if element.Parent then
            element.Parent = container
        elseif element.Main then
            element.Main.Parent = container
            table.insert(self.Elements, element)
        else
            warn("[HStack] 无效的元素")
        end
    end

    -- 获取布局
    function self:GetLayout()
        return contentLayout
    end

    -- 清空内容
    function self:Clear()
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("UIListLayout") or child:IsA("UIPadding") then
                -- 保留布局
            else
                child:Destroy()
            end
        end
        self.Elements = {}
    end

    -- 销毁
    function self:Destroy()
        container:Destroy()
    end

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.ContentLayout = contentLayout

    return self
end

-- ============================================================
-- 3. VStack（垂直堆栈）
-- 垂直排列子元素，自动均匀分布
-- ============================================================
local VStack = {}
VStack.__index = VStack

function VStack.new(config)
    config = config or {}

    local self = setmetatable({}, VStack)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Parent = config.Parent or nil
    self.Spacing = config.Spacing or 6
    self.Padding = config.Padding or 4
    self.Elements = {}

    -- ============================================================
    -- 创建垂直堆栈
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 内容布局
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, self.Spacing)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Parent = container

    -- 内边距
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, self.Padding)
    padding.PaddingBottom = UDim.new(0, self.Padding)
    padding.PaddingLeft = UDim.new(0, self.Padding)
    padding.PaddingRight = UDim.new(0, self.Padding)
    padding.Parent = container

    -- ============================================================
    -- 容器方法
    -- ============================================================

    -- 添加元素
    function self:Add(element)
        if not element then return end
        if element.Parent then
            element.Parent = container
        elseif element.Main then
            element.Main.Parent = container
            table.insert(self.Elements, element)
        else
            warn("[VStack] 无效的元素")
        end
    end

    -- 获取布局
    function self:GetLayout()
        return contentLayout
    end

    -- 清空内容
    function self:Clear()
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("UIListLayout") or child:IsA("UIPadding") then
                -- 保留布局
            else
                child:Destroy()
            end
        end
        self.Elements = {}
    end

    -- 销毁
    function self:Destroy()
        container:Destroy()
    end

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.ContentLayout = contentLayout

    return self
end

-- ============================================================
-- 4. Section（分区）
-- 可折叠的大分区，用于组织多个元素组
-- ============================================================
local Section = {}
Section.__index = Section

function Section.new(config)
    config = config or {}

    local self = setmetatable({}, Section)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Title = config.Title or "分区"
    self.Desc = config.Desc or ""
    self.Icon = config.Icon
    self.Parent = config.Parent or nil
    self.Radius = config.Radius or 10
    self.Padding = config.Padding or 8
    self.Opened = config.Opened or true
    self.Elements = {}

    -- ============================================================
    -- 创建分区
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = true
    if self.Parent then
        container.Parent = self.Parent
    end

    -- 背景（只有边框，没有填充）
    local bg = Creator.NewRoundFrame(self.Radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.97,
        ImageColor3 = theme.SectionBoxBackground or Color3.fromRGB(255, 255, 255),
        ZIndex = 0,
        Parent = container,
    })

    -- 边框
    local border = Creator.NewRoundFrame(self.Radius - 1, "SquircleOutline", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.9,
        ImageColor3 = theme.SectionBoxBorder or Color3.fromRGB(255, 255, 255),
        ZIndex = 0,
        Parent = container,
    })

    -- ============================================================
    -- 标题栏（可点击折叠）
    -- ============================================================
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.ZIndex = 1
    header.Parent = container

    -- 标题内容
    local headerContent = Instance.new("Frame")
    headerContent.Size = UDim2.new(1, -16, 1, 0)
    headerContent.Position = UDim2.new(0, 8, 0, 0)
    headerContent.BackgroundTransparency = 1
    headerContent.Parent = header

    -- 图标
    local icon
    if self.Icon then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = Creator.GetIcon(self.Icon)
        icon.ImageColor3 = theme.SectionIcon or Color3.fromRGB(200, 200, 200)
        icon.ImageTransparency = 0.3
        icon.ZIndex = 2
        icon.Parent = headerContent
    end

    -- 标题文字
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 1, 0)
    titleLabel.Position = UDim2.new(icon and 28 or 0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = theme.Text or Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.ZIndex = 2
    titleLabel.Parent = headerContent

    -- 描述文字
    local descLabel
    if self.Desc and self.Desc ~= "" then
        descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 1, 0)
        descLabel.Position = UDim2.new(icon and 28 or 0, 0, 0, 0)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = self.Desc
        descLabel.TextColor3 = theme.Placeholder or Color3.fromRGB(160, 160, 160)
        descLabel.TextSize = 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Font = Enum.Font.GothamMedium
        descLabel.TextTransparency = 0.4
        descLabel.ZIndex = 2
        descLabel.Parent = headerContent

        -- 调整标题位置
        titleLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 0.6, 0)
        descLabel.Size = UDim2.new(1, -(icon and 28 or 0) - 30, 0.4, 0)
        descLabel.Position = UDim2.new(icon and 28 or 0, 0, 0.6, 0)
    end

    -- 折叠箭头
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 18, 0, 18)
    arrow.Position = UDim2.new(1, 0, 0.5, 0)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Image = Creator.GetIcon(self.Opened and "chevron-up" or "chevron-down")
    arrow.ImageColor3 = theme.SectionExpandIcon or Color3.fromRGB(200, 200, 200)
    arrow.ImageTransparency = theme.SectionExpandIconTransparency or 0.4
    arrow.ZIndex = 2
    arrow.Parent = headerContent

    -- ============================================================
    -- 内容区域
    -- ============================================================
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Visible = self.Opened
    content.Parent = container

    -- 内容布局
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = content

    -- 内边距
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, self.Padding)
    padding.PaddingBottom = UDim.new(0, self.Padding)
    padding.PaddingLeft = UDim.new(0, self.Padding)
    padding.PaddingRight = UDim.new(0, self.Padding)
    padding.Parent = content

    -- ============================================================
    -- 容器方法
    -- ============================================================

    -- 添加元素
    function self:Add(element)
        if not element then return end
        if element.Parent then
            element.Parent = content
        elseif element.Main then
            element.Main.Parent = content
            table.insert(self.Elements, element)
        else
            warn("[Section] 无效的元素")
        end
    end

    -- 获取内容容器
    function self:GetContent()
        return content
    end

    -- 获取布局
    function self:GetLayout()
        return contentLayout
    end

    -- 折叠/展开
    function self:Toggle()
        self.Opened = not self.Opened
        content.Visible = self.Opened
        arrow.Image = Creator.GetIcon(self.Opened and "chevron-up" or "chevron-down")

        -- 更新背景尺寸
        if self.Opened then
            bg.ImageTransparency = 0.97
            border.ImageTransparency = 0.9
        else
            bg.ImageTransparency = 0.99
            border.ImageTransparency = 0.95
        end
    end

    function self:Open()
        if not self.Opened then
            self:Toggle()
        end
    end

    function self:Close()
        if self.Opened then
            self:Toggle()
        end
    end

    -- 设置标题
    function self:SetTitle(title)
        self.Title = title
        titleLabel.Text = title
    end

    -- 设置描述
    function self:SetDesc(desc)
        self.Desc = desc
        if descLabel then
            descLabel.Text = desc
            descLabel.Visible = desc and desc ~= ""
        end
    end

    -- 设置图标
    function self:SetIcon(iconName)
        self.Icon = iconName
        if icon then
            icon.Image = Creator.GetIcon(iconName)
            icon.Visible = true
        elseif iconName then
            icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.Position = UDim2.new(0, 0, 0.5, 0)
            icon.AnchorPoint = Vector2.new(0, 0.5)
            icon.BackgroundTransparency = 1
            icon.Image = Creator.GetIcon(iconName)
            icon.ImageColor3 = theme.SectionIcon or Color3.fromRGB(200, 200, 200)
            icon.ImageTransparency = 0.3
            icon.ZIndex = 2
            icon.Parent = headerContent

            -- 调整标题位置
            titleLabel.Position = UDim2.new(28, 0, 0, 0)
            if descLabel then
                descLabel.Position = UDim2.new(28, 0, 0.6, 0)
            end
        end
    end

    -- 清空内容
    function self:Clear()
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("UIListLayout") or child:IsA("UIPadding") then
                -- 保留布局
            else
                child:Destroy()
            end
        end
        self.Elements = {}
    end

    -- 销毁
    function self:Destroy()
        container:Destroy()
    end

    -- ============================================================
    -- 交互事件
    -- ============================================================
    header.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- 悬停效果
    header.MouseEnter:Connect(function()
        TweenService:Create(bg, TweenInfo.new(0.08), {
            ImageTransparency = 0.95,
        }):Play()
    end)

    header.MouseLeave:Connect(function()
        TweenService:Create(bg, TweenInfo.new(0.08), {
            ImageTransparency = self.Opened and 0.97 or 0.99,
        }):Play()
    end)

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.Header = header
    self.TitleLabel = titleLabel
    self.DescLabel = descLabel
    self.Content = content
    self.ContentLayout = contentLayout
    self.Arrow = arrow

    return self
end

-- ============================================================
-- 5. Divider（分割线）
-- ============================================================
local Divider = {}
Divider.__index = Divider

function Divider.new(config)
    config = config or {}

    local self = setmetatable({}, Divider)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Parent = config.Parent or nil
    self.Thickness = config.Thickness or 1
    self.Margin = config.Margin or 8
    self.Label = config.Label or ""

    -- ============================================================
    -- 创建分割线
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    if self.Parent then
        container.Parent = self.Parent
    end

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -self.Margin * 2, 0, self.Thickness)
    line.Position = UDim2.new(0.5, 0, 0.5, 0)
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = theme.Placeholder or Color3.fromRGB(160, 160, 160)
    line.BackgroundTransparency = 0.8
    line.Parent = container

    -- 如果有标签，创建带文字的分割线
    if self.Label and self.Label ~= "" then
        line.Size = UDim2.new(1, -self.Margin * 2 - 80, 0, self.Thickness)
        line.Position = UDim2.new(0.5, -40, 0.5, 0)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 80, 0, 20)
        label.Position = UDim2.new(0.5, 0, 0.5, 0)
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.BackgroundTransparency = 1
        label.Text = self.Label
        label.TextColor3 = theme.Placeholder or Color3.fromRGB(160, 160, 160)
        label.TextSize = 12
        label.Font = Enum.Font.GothamMedium
        label.TextTransparency = 0.5
        label.ZIndex = 1
        label.Parent = container
    end

    -- ============================================================
    -- 容器方法
    -- ============================================================
    function self:Destroy()
        container:Destroy()
    end

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container

    return self
end

-- ============================================================
-- 6. Space（空白占位）
-- ============================================================
local Space = {}
Space.__index = Space

function Space.new(config)
    config = config or {}

    local self = setmetatable({}, Space)

    -- 配置参数
    self.Parent = config.Parent or nil
    self.Size = config.Size or UDim2.new(0, 10, 0, 0)
    self.Height = config.Height or 10
    self.Width = config.Width or 10

    -- ============================================================
    -- 创建空白占位
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = self.Size
    container.BackgroundTransparency = 1
    container.LayoutOrder = config.LayoutOrder or 0
    if self.Parent then
        container.Parent = self.Parent
    end

    -- ============================================================
    -- 容器方法
    -- ============================================================
    function self:Destroy()
        container:Destroy()
    end

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container

    return self
end

-- ============================================================
-- 布局容器工厂（统一导出）
-- ============================================================
local Layouts = {
    Group = Group,
    HStack = HStack,
    VStack = VStack,
    Section = Section,
    Divider = Divider,
    Space = Space,
}

-- 添加到 Creator 中
Creator.Layouts = Layouts

return Layouts
-- ============================================================
-- 第七段：WindUI 通知系统 + Tooltip + 配置管理
-- 依赖：第一段（Creator）+ 第二段（Window）
-- 功能：通知弹出、Tooltip 提示、配置保存/加载
-- ============================================================

local Creator = require(script.Parent.Creator)  -- 如果作为模块使用
-- 如果是在同一个文件，直接使用上面的 Creator

-- ============================================================
-- 1. 通知系统（Notification）
-- ============================================================
local Notification = {}
Notification.__index = Notification

function Notification.new(config)
    config = config or {}

    local self = setmetatable({}, Notification)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Title = config.Title or "通知"
    self.Content = config.Content or ""
    self.Icon = config.Icon
    self.Duration = config.Duration or 3  -- 秒
    self.Callback = config.Callback or function() end
    self.Position = config.Position or "TopRight"  -- TopRight, TopLeft, BottomRight, BottomLeft
    self.Parent = config.Parent or nil

    -- 如果 Parent 是 nil，使用 PlayerGui
    if not self.Parent then
        local gui = Instance.new("ScreenGui")
        gui.Name = "WindUI_Notifications"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        self.Parent = gui
        self.IsRoot = true
    end

    -- 获取屏幕尺寸
    local viewport = workspace.CurrentCamera.ViewportSize

    -- ============================================================
    -- 创建通知容器
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 340, 0, 0)
    container.Position = self:GetPosition()
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = true
    container.ZIndex = 1000
    container.Parent = self.Parent

    -- 背景
    local bg = Creator.NewRoundFrame(12, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.05,
        ImageColor3 = theme.Notification or Color3.fromRGB(38, 38, 40),
        ZIndex = 0,
        Parent = container,
    })

    -- 边框（轻微描边）
    local border = Creator.NewRoundFrame(11, "SquircleOutline", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.9,
        ImageColor3 = theme.NotificationBorder or Color3.fromRGB(255, 255, 255),
        ZIndex = 0,
        Parent = container,
    })

    -- 内容布局
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, 12)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = container

    -- 图标
    local icon
    if self.Icon then
        icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.BackgroundTransparency = 1
        icon.Image = Creator.GetIcon(self.Icon)
        icon.ImageColor3 = theme.NotificationIcon or theme.Icon or Color3.fromRGB(200, 200, 200)
        icon.ZIndex = 1
        icon.Parent = container
    end

    -- 文字区域
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -(icon and 36 or 0) - 30, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.AutomaticSize = Enum.AutomaticSize.Y
    textContainer.Parent = container

    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.Title
    title.TextColor3 = theme.NotificationTitle or Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Parent = textContainer

    -- 内容
    local content = Instance.new("TextLabel")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Text = self.Content
    content.TextColor3 = theme.NotificationContent or Color3.fromRGB(200, 200, 200)
    content.TextSize = 14
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.Font = Enum.Font.GothamMedium
    content.TextTransparency = 0.3
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = textContainer

    -- 关闭按钮
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -4, 0, 4)
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = Creator.GetIcon("x")
    closeBtn.ImageColor3 = theme.Icon or Color3.fromRGB(160, 160, 160)
    closeBtn.ImageTransparency = 0.5
    closeBtn.ZIndex = 2
    closeBtn.Parent = container

    -- 进度条
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = theme.NotificationDuration or Color3.fromRGB(255, 255, 255)
    progressBar.BackgroundTransparency = 0.8
    progressBar.ZIndex = 1
    progressBar.Parent = container

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, 0, 1, 0)
    progressBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    progressBg.BackgroundTransparency = 0.95
    progressBg.Parent = progressBar

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = theme.NotificationDuration or Color3.fromRGB(255, 255, 255)
    progressFill.BackgroundTransparency = 0.6
    progressFill.Parent = progressBg

    -- ============================================================
    -- 位置计算
    -- ============================================================
    function self:GetPosition()
        local posMap = {
            TopRight = UDim2.new(1, -12, 0, 12),
            TopLeft = UDim2.new(0, 12, 0, 12),
            BottomRight = UDim2.new(1, -12, 1, -12),
            BottomLeft = UDim2.new(0, 12, 1, -12),
        }
        return posMap[self.Position] or posMap.TopRight
    end

    function self:GetAnchor()
        local anchorMap = {
            TopRight = Vector2.new(1, 0),
            TopLeft = Vector2.new(0, 0),
            BottomRight = Vector2.new(1, 1),
            BottomLeft = Vector2.new(0, 1),
        }
        return anchorMap[self.Position] or Vector2.new(1, 0)
    end

    container.AnchorPoint = self:GetAnchor()

    -- ============================================================
    -- 显示/隐藏动画
    -- ============================================================
    local isVisible = false
    local isDestroying = false

    function self:Show()
        if isVisible then return end
        isVisible = true

        -- 从隐藏状态显示
        container.Size = UDim2.new(0, 340, 0, 0)
        container.Visible = true

        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, container.AbsoluteSize.Y + 20),
        }):Play()

        -- 进度条动画
        if self.Duration > 0 then
            TweenService:Create(progressFill, TweenInfo.new(self.Duration, Enum.EasingStyle.Linear), {
                Size = UDim2.new(0, 0, 1, 0),
            }):Play()
        end
    end

    function self:Hide(callback)
        if isDestroying then return end
        isDestroying = true

        TweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 340, 0, 0),
        }):Play()

        task.wait(0.25)
        container:Destroy()
        if self.IsRoot then
            self.Parent:Destroy()
        end
        if callback then
            Creator.SafeCallback(callback)
        end
        Creator.SafeCallback(self.Callback)
    end

    -- ============================================================
    -- 交互事件
    -- ============================================================
    -- 关闭按钮
    closeBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    -- 点击通知本身（如果有回调）
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Hide()
        end
    end)

    -- 悬停时暂停进度条
    container.MouseEnter:Connect(function()
        progressFill.Parent = nil
    end)

    container.MouseLeave:Connect(function()
        if progressFill.Parent then return end
        progressFill.Parent = progressBg
        local remaining = progressFill.AbsoluteSize.X / progressBg.AbsoluteSize.X
        TweenService:Create(progressFill, TweenInfo.new(self.Duration * remaining, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0),
        }):Play()
    end)

    -- ============================================================
    -- 自动关闭
    -- ============================================================
    task.spawn(function()
        if self.Duration > 0 then
            task.wait(self.Duration + 0.5)
            if not isDestroying and isVisible then
                self:Hide()
            end
        end
    end)

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.ProgressFill = progressFill

    -- 延迟显示（让布局计算完成）
    task.spawn(function()
        task.wait(0.05)
        self:Show()
    end)

    return self
end

-- ============================================================
-- 通知管理器
-- ============================================================
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new()
    local self = setmetatable({}, NotificationManager)
    self.Notifications = {}
    self.Parent = nil
    return self
end

function NotificationManager:SetParent(parent)
    self.Parent = parent
end

function NotificationManager:Notify(config)
    config.Parent = self.Parent
    local notification = Notification.new(config)
    table.insert(self.Notifications, notification)

    -- 添加关闭回调移除自己
    local originalHide = notification.Hide
    notification.Hide = function(_, callback)
        for i, n in ipairs(self.Notifications) do
            if n == notification then
                table.remove(self.Notifications, i)
                break
            end
        end
        originalHide(callback)
    end

    return notification
end

function NotificationManager:ClearAll()
    for _, notification in ipairs(self.Notifications) do
        notification:Hide()
    end
    self.Notifications = {}
end

-- ============================================================
-- 2. Tooltip（提示框）
-- ============================================================
local Tooltip = {}
Tooltip.__index = Tooltip

function Tooltip.new(config)
    config = config or {}

    local self = setmetatable({}, Tooltip)
    local theme = Creator.GetTheme()

    -- 配置参数
    self.Text = config.Text or "提示"
    self.Delay = config.Delay or 0.5  -- 延迟显示（秒）
    self.Duration = config.Duration or 3  -- 显示时长
    self.Parent = config.Parent or nil
    self.Target = config.Target  -- 目标元素

    -- 如果没有指定父级，使用 PlayerGui
    if not self.Parent then
        local gui = Instance.new("ScreenGui")
        gui.Name = "WindUI_Tooltips"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        self.Parent = gui
        self.IsRoot = true
    end

    -- ============================================================
    -- 创建 Tooltip
    -- ============================================================
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.ZIndex = 2000
    container.Parent = self.Parent

    -- 背景
    local bg = Creator.NewRoundFrame(6, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageTransparency = 0.1,
        ImageColor3 = theme.Tooltip or Color3.fromRGB(76, 76, 76),
        ZIndex = 0,
        Parent = container,
    })

    -- 文字
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, -8)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = self.Text
    label.TextColor3 = theme.TooltipText or Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Font = Enum.Font.GothamMedium
    label.ZIndex = 1
    label.Parent = container

    -- ============================================================
    -- 显示/隐藏
    -- ============================================================
    local isVisible = false
    local isHovering = false
    local hideTask = nil

    function self:Show()
        if isVisible then return end

        -- 更新文字
        label.Text = self.Text

        -- 计算位置（在目标上方居中）
        if self.Target then
            local targetPos = self.Target.AbsolutePosition
            local targetSize = self.Target.AbsoluteSize
            local tooltipSize = container.AbsoluteSize

            if tooltipSize.X == 0 or tooltipSize.Y == 0 then
                -- 如果尺寸还没计算，等待一帧
                task.wait()
                tooltipSize = container.AbsoluteSize
            end

            local x = targetPos.X + targetSize.X / 2 - tooltipSize.X / 2
            local y = targetPos.Y - tooltipSize.Y - 8

            -- 确保不超出屏幕
            local viewport = workspace.CurrentCamera.ViewportSize
            x = math.clamp(x, 10, viewport.X - tooltipSize.X - 10)
            y = math.clamp(y, 10, viewport.Y - tooltipSize.Y - 10)

            container.Position = UDim2.new(0, x, 0, y)
        end

        -- 显示动画
        container.Visible = true
        container.Size = UDim2.new(0, 0, 0, 0)

        TweenService:Create(container, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, label.TextBounds.X + 24, 0, label.TextBounds.Y + 16),
        }):Play()

        isVisible = true

        -- 自动隐藏
        if self.Duration > 0 then
            if hideTask then
                task.cancel(hideTask)
            end
            hideTask = task.spawn(function()
                task.wait(self.Duration)
                if isVisible then
                    self:Hide()
                end
            end)
        end
    end

    function self:Hide()
        if not isVisible then return end
        isVisible = false

        if hideTask then
            task.cancel(hideTask)
            hideTask = nil
        end

        container.Visible = false
        container.Size = UDim2.new(0, 0, 0, 0)
    end

    function self:SetText(text)
        self.Text = text
        if isVisible then
            label.Text = text
            -- 重新计算尺寸
            task.wait()
            container.Size = UDim2.new(0, label.TextBounds.X + 24, 0, label.TextBounds.Y + 16)
        end
    end

    function self:Destroy()
        self:Hide()
        container:Destroy()
        if self.IsRoot then
            self.Parent:Destroy()
        end
    end

    -- ============================================================
    -- 绑定到目标元素
    -- ============================================================
    if self.Target then
        local hoverTimer = nil

        self.Target.MouseEnter:Connect(function()
            isHovering = true
            hoverTimer = task.spawn(function()
                task.wait(self.Delay)
                if isHovering then
                    self:Show()
                end
            end)
        end)

        self.Target.MouseLeave:Connect(function()
            isHovering = false
            if hoverTimer then
                task.cancel(hoverTimer)
                hoverTimer = nil
            end
            self:Hide()
        end)
    end

    -- ============================================================
    -- 初始化
    -- ============================================================
    self.Main = container
    self.Label = label

    return self
end

-- ============================================================
-- 3. 配置管理（Config）
-- ============================================================
local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(config)
    config = config or {}

    local self = setmetatable({}, ConfigManager)

    -- 配置参数
    self.Name = config.Name or "config"
    self.Folder = config.Folder or "WindUI"
    self.AutoSave = config.AutoSave or false
    self.Data = {}
    self.Schemas = {}
    self.Handlers = {}

    -- 创建存储路径
    if writefile and not isfolder(self.Folder) then
        makefolder(self.Folder)
    end

    -- 自动加载
    if config.AutoLoad then
        self:Load()
    end

    return self
end

-- ============================================================
-- Schema 定义
-- ============================================================
function ConfigManager:DefineSchema(schema)
    for key, defaultValue in pairs(schema) do
        self.Schemas[key] = defaultValue
        if self.Data[key] == nil then
            self.Data[key] = defaultValue
        end
    end
end

-- ============================================================
-- 注册处理器
-- ============================================================
function ConfigManager:RegisterHandler(key, handler)
    self.Handlers[key] = handler
end

-- ============================================================
-- 读取/写入
-- ============================================================
function ConfigManager:Get(key, defaultValue)
    if self.Data[key] ~= nil then
        return self.Data[key]
    end
    if self.Schemas[key] ~= nil then
        return self.Schemas[key]
    end
    return defaultValue
end

function ConfigManager:Set(key, value, save)
    if self.Handlers[key] then
        value = self.Handlers[key](value)
    end
    self.Data[key] = value
    if save or self.AutoSave then
        self:Save()
    end
    return value
end

-- ============================================================
-- 保存/加载
-- ============================================================
function ConfigManager:Save()
    if not writefile then return false end

    local path = self.Folder .. "/" .. self.Name .. ".json"
    local data = {
        version = 1,
        data = self.Data,
        schemas = self.Schemas,
    }

    local success, err = pcall(function()
        writefile(path, HttpService:JSONEncode(data))
    end)

    if not success then
        warn("[Config] 保存失败:", err)
        return false
    end
    return true
end

function ConfigManager:Load()
    if not readfile then return false end

    local path = self.Folder .. "/" .. self.Name .. ".json"
    if not isfile(path) then return false end

    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)

    if not success then
        warn("[Config] 加载失败:", data)
        return false
    end

    if data.data then
        for key, value in pairs(data.data) do
            self.Data[key] = value
        end
    end

    return true
end

function ConfigManager:Reset()
    self.Data = {}
    for key, defaultValue in pairs(self.Schemas) do
        self.Data[key] = defaultValue
    end
    self:Save()
end

-- ============================================================
-- 元素绑定辅助
-- ============================================================
function ConfigManager:BindToggle(element, key)
    -- 从配置恢复值
    local value = self:Get(key, element:Get())
    element:Set(value, false)

    -- 监听变化并保存
    local originalCallback = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if originalCallback then
            Creator.SafeCallback(originalCallback, newValue)
        end
    end

    return element
end

function ConfigManager:BindSlider(element, key)
    local value = self:Get(key, element:Get())
    element:Set(value, false)

    local originalCallback = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if originalCallback then
            Creator.SafeCallback(originalCallback, newValue)
        end
    end

    return element
end

function ConfigManager:BindInput(element, key)
    local value = self:Get(key, element:Get())
    element:Set(value)

    local originalCallback = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if originalCallback then
            Creator.SafeCallback(originalCallback, newValue)
        end
    end

    return element
end

function ConfigManager:BindDropdown(element, key)
    local value = self:Get(key, element.Value)
    element.Value = value
    element:UpdateValueDisplay()

    local originalCallback = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if originalCallback then
            Creator.SafeCallback(originalCallback, newValue)
        end
    end

    return element
end

function ConfigManager:BindColorpicker(element, key)
    local value = self:Get(key, element.Value)
    element.Value = value
    element:UpdateColor()

    local originalCallback = element.Callback
    element.Callback = function(newValue)
        self:Set(key, newValue)
        if originalCallback then
            Creator.SafeCallback(originalCallback, newValue)
        end
    end

    return element
end

-- ============================================================
-- 导出模块
-- ============================================================
local UIComponents = {
    Notification = Notification,
    NotificationManager = NotificationManager,
    Tooltip = Tooltip,
    ConfigManager = ConfigManager,
}

-- 添加到 Creator 中
Creator.UIComponents = UIComponents

return UIComponents
-- ============================================================
-- 第八段：WindUI 主入口 + 初始化 + 完整示例
-- 这是整个库的整合层，将所有模块串联起来
-- ============================================================

-- ============================================================
-- 1. 主入口模块（WindUI）
-- ============================================================

local WindUI = {}
WindUI.__index = WindUI

-- 所有子模块
local Creator = require(script.Parent.Creator)
local Elements = require(script.Parent.Elements)
local AdvancedElements = require(script.Parent.AdvancedElements)
local Layouts = require(script.Parent.Layouts)
local UIComponents = require(script.Parent.UIComponents)

-- 版本信息
WindUI.Version = "1.0.0"

-- ============================================================
-- 初始化
-- ============================================================
function WindUI.new(config)
    config = config or {}

    local self = setmetatable({}, WindUI)

    -- 存储配置
    self.Config = config
    self.Windows = {}
    self.Tabs = {}
    self.Elements = {}
    self.NotificationManager = nil
    self.ConfigManager = nil

    -- 主题
    self.Theme = config.Theme or "Dark"
    Creator.SetTheme(self.Theme)

    -- 创建通知管理器
    self.NotificationManager = UIComponents.NotificationManager.new()

    -- 创建配置管理器（可选）
    if config.Config then
        self.ConfigManager = UIComponents.ConfigManager.new(config.Config)
    end

    return self
end

-- ============================================================
-- 创建窗口
-- ============================================================
function WindUI:CreateWindow(config)
    config = config or {}
    config.Parent = config.Parent or self.Config.Parent

    local window = Creator.CreateWindow(config)

    -- 存储窗口引用
    table.insert(self.Windows, window)

    -- 创建标签页管理器
    local tabManager = require(script.Parent.Tabs).new(window)

    -- 添加辅助方法
    window.TabManager = tabManager
    window.AddTab = function(cfg)
        return tabManager:AddTab(cfg)
    end
    window.SelectTab = function(index)
        tabManager:SelectTab(index)
    end
    window.GetTab = function(index)
        return tabManager:GetTab(index)
    end

    -- 添加快捷元素创建方法
    window.AddButton = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Elements.Button.new(cfg)
    end
    window.AddToggle = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Elements.Toggle.new(cfg)
    end
    window.AddSlider = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Elements.Slider.new(cfg)
    end
    window.AddInput = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Elements.Input.new(cfg)
    end
    window.AddDropdown = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return AdvancedElements.Dropdown.new(cfg)
    end
    window.AddColorpicker = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return AdvancedElements.Colorpicker.new(cfg)
    end
    window.AddKeybind = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return AdvancedElements.Keybind.new(cfg)
    end
    window.AddCode = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return AdvancedElements.Code.new(cfg)
    end
    window.AddGroup = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Layouts.Group.new(cfg)
    end
    window.AddHStack = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Layouts.HStack.new(cfg)
    end
    window.AddVStack = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Layouts.VStack.new(cfg)
    end
    window.AddSection = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Layouts.Section.new(cfg)
    end
    window.AddDivider = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Layouts.Divider.new(cfg)
    end
    window.AddSpace = function(cfg)
        cfg.Parent = cfg.Parent or tabManager:GetSelectedTab():GetContainer()
        return Layouts.Space.new(cfg)
    end

    -- 通知方法
    window.Notify = function(cfg)
        cfg.Parent = self.NotificationManager.Parent
        return self.NotificationManager:Notify(cfg)
    end

    -- 配置绑定方法
    window.BindToggle = function(element, key)
        if self.ConfigManager then
            return self.ConfigManager:BindToggle(element, key)
        end
        return element
    end
    window.BindSlider = function(element, key)
        if self.ConfigManager then
            return self.ConfigManager:BindSlider(element, key)
        end
        return element
    end
    window.BindInput = function(element, key)
        if self.ConfigManager then
            return self.ConfigManager:BindInput(element, key)
        end
        return element
    end
    window.BindDropdown = function(element, key)
        if self.ConfigManager then
            return self.ConfigManager:BindDropdown(element, key)
        end
        return element
    end
    window.BindColorpicker = function(element, key)
        if self.ConfigManager then
            return self.ConfigManager:BindColorpicker(element, key)
        end
        return element
    end

    -- 主题切换
    window.SetTheme = function(themeName)
        Creator.SetTheme(themeName)
        self.Theme = themeName
        window:UpdateTheme()
    end

    -- 默认选中第一个标签页
    task.spawn(function()
        task.wait(0.1)
        if tabManager:GetSelectedTab() == nil then
            for i, tab in pairs(tabManager:GetAllTabs()) do
                if not tab.Locked then
                    tabManager:SelectTab(i)
                    break
                end
            end
        end
    end)

    return window
end

-- ============================================================
-- 获取窗口
-- ============================================================
function WindUI:GetWindows()
    return self.Windows
end

function WindUI:GetWindow(index)
    return self.Windows[index]
end

-- ============================================================
-- 通知
-- ============================================================
function WindUI:Notify(config)
    return self.NotificationManager:Notify(config)
end

function WindUI:ClearNotifications()
    self.NotificationManager:ClearAll()
end

-- ============================================================
-- 配置
-- ============================================================
function WindUI:GetConfig()
    return self.ConfigManager
end

function WindUI:SaveConfig()
    if self.ConfigManager then
        return self.ConfigManager:Save()
    end
    return false
end

function WindUI:LoadConfig()
    if self.ConfigManager then
        return self.ConfigManager:Load()
    end
    return false
end

-- ============================================================
-- 主题
-- ============================================================
function WindUI:SetTheme(themeName)
    Creator.SetTheme(themeName)
    self.Theme = themeName
    for _, window in ipairs(self.Windows) do
        window:UpdateTheme()
    end
end

function WindUI:GetTheme()
    return self.Theme
end

function WindUI:GetThemeColors()
    return Creator.GetTheme()
end

-- ============================================================
-- 销毁
-- ============================================================
function WindUI:Destroy()
    for _, window in ipairs(self.Windows) do
        window:Destroy()
    end
    self.Windows = {}
    self.NotificationManager:ClearAll()
end

-- ============================================================
-- 2. 完整使用示例
-- ============================================================

-- 这个函数演示了如何使用 WindUI 创建完整的界面
function WindUI:CreateExample()
    -- 创建 WindUI 实例
    local ui = WindUI.new({
        Theme = "Dark",
        Config = {
            Name = "example_config",
            Folder = "WindUI",
            AutoSave = true,
        }
    })

    -- 创建窗口
    local window = ui:CreateWindow({
        Title = "WindUI 示例",
        Author = "WindUI v1.0",
        Icon = "home",
        Width = 640,
        Height = 480,
        MinWidth = 400,
        MinHeight = 300,
        SideBarWidth = 200,
        ShadowTransparency = 0.5,
    })

    -- ============================================================
    -- 添加标签页
    -- ============================================================

    -- 标签页 1：基础元素
    local tab1 = window:AddTab({
        Title = "基础元素",
        Icon = "home",
        Locked = false,
    })

    -- 添加基础元素到标签页 1
    local btn1 = window:AddButton({
        Text = "点击我",
        Icon = "mouse-pointer-click",
        Variant = "Primary",
        Parent = tab1:GetContainer(),
        Callback = function()
            window:Notify({
                Title = "按钮点击",
                Content = "你点击了按钮！",
                Icon = "check",
                Duration = 2,
            })
        end,
    })

    local btn2 = window:AddButton({
        Text = "危险按钮",
        Variant = "Danger",
        Parent = tab1:GetContainer(),
        Callback = function()
            window:Notify({
                Title = "危险操作",
                Content = "这只是一个演示通知",
                Icon = "x",
                Duration = 3,
            })
        end,
    })

    -- 开关
    local toggle1 = window:AddToggle({
        Text = "启用功能",
        Desc = "这是一个开关示例",
        Value = true,
        Parent = tab1:GetContainer(),
        Callback = function(value)
            window:Notify({
                Title = "开关状态",
                Content = "开关已" .. (value and "开启" or "关闭"),
                Duration = 1.5,
            })
        end,
    })

    -- 滑块
    local slider1 = window:AddSlider({
        Text = "音量",
        Min = 0,
        Max = 100,
        Value = 50,
        Step = 5,
        Parent = tab1:GetContainer(),
        Callback = function(value)
            -- 更新显示
        end,
    })

    -- 输入框
    local input1 = window:AddInput({
        Text = "用户名",
        Placeholder = "请输入用户名...",
        Value = "",
        Parent = tab1:GetContainer(),
        Callback = function(value)
            -- 实时更新
        end,
    })

    -- ============================================================
    -- 标签页 2：高级元素
    -- ============================================================

    local tab2 = window:AddTab({
        Title = "高级元素",
        Icon = "settings",
        Locked = false,
    })

    -- 下拉菜单
    local dropdown1 = window:AddDropdown({
        Text = "选择选项",
        Options = {"选项 A", "选项 B", "选项 C", "选项 D"},
        Value = "选项 A",
        Parent = tab2:GetContainer(),
        Callback = function(value)
            window:Notify({
                Title = "选择了",
                Content = "你选择了: " .. value,
                Duration = 2,
            })
        end,
    })

    -- 多选下拉
    local dropdown2 = window:AddDropdown({
        Text = "多选",
        Options = {"苹果", "香蕉", "橙子", "草莓", "蓝莓"},
        Value = {"苹果", "香蕉"},
        MultiSelect = true,
        Parent = tab2:GetContainer(),
        Callback = function(value)
            local text = table.concat(value, ", ")
            if text == "" then text = "未选择" end
            window:Notify({
                Title = "已选择",
                Content = text,
                Duration = 2,
            })
        end,
    })

    -- 颜色选择器
    local colorpicker1 = window:AddColorpicker({
        Text = "选择颜色",
        Value = Color3.fromRGB(0, 122, 255),
        Parent = tab2:GetContainer(),
        Callback = function(color)
            -- 颜色更新
        end,
    })

    -- 键位绑定
    local keybind1 = window:AddKeybind({
        Text = "快捷键",
        Value = "F",
        Parent = tab2:GetContainer(),
        Callback = function(key)
            window:Notify({
                Title = "按键触发",
                Content = "按下了: " .. key,
                Duration = 1.5,
            })
        end,
    })

    -- 代码显示
    local code1 = window:AddCode({
        Text = "Lua 示例",
        Code = [[
function hello(name)
    print("Hello, " .. name .. "!")
    return true
end

-- 调用函数
hello("World")
]],
        Height = 120,
        Parent = tab2:GetContainer(),
    })

    -- ============================================================
    -- 标签页 3：布局容器
    -- ============================================================

    local tab3 = window:AddTab({
        Title = "布局",
        Icon = "layers",
        Locked = false,
    })

    -- 分组
    local group1 = window:AddGroup({
        Title = "设置组",
        Collapsible = true,
        Opened = true,
        Parent = tab3:GetContainer(),
    })

    -- 在分组中添加元素
    local groupToggle = window:AddToggle({
        Text = "启用高级模式",
        Value = false,
        Parent = group1:GetContent(),
    })

    local groupSlider = window:AddSlider({
        Text = "高级参数",
        Min = 0,
        Max = 100,
        Value = 75,
        Parent = group1:GetContent(),
    })

    -- 水平堆栈
    local hstack = window:AddHStack({
        Spacing = 6,
        Padding = 4,
        Parent = tab3:GetContainer(),
    })

    local hBtn1 = window:AddButton({
        Text = "左",
        Variant = "Secondary",
        Parent = hstack:GetLayout(),
    })

    local hBtn2 = window:AddButton({
        Text = "中",
        Variant = "Primary",
        Parent = hstack:GetLayout(),
    })

    local hBtn3 = window:AddButton({
        Text = "右",
        Variant = "Secondary",
        Parent = hstack:GetLayout(),
    })

    -- 分区
    local section1 = window:AddSection({
        Title = "高级设置",
        Desc = "这些是高级选项，请谨慎修改",
        Icon = "settings",
        Opened = false,
        Parent = tab3:GetContainer(),
    })

    local sectionToggle = window:AddToggle({
        Text = "实验性功能",
        Value = false,
        Parent = section1:GetContent(),
    })

    local sectionInput = window:AddInput({
        Text = "自定义参数",
        Placeholder = "输入值...",
        Parent = section1:GetContent(),
    })

    -- 分割线
    window:AddDivider({
        Label = "分割线",
        Parent = tab3:GetContainer(),
    })

    -- 空白占位
    window:AddSpace({
        Height = 10,
        Parent = tab3:GetContainer(),
    })

    -- 最后一个按钮
    window:AddButton({
        Text = "保存所有设置",
        Variant = "Primary",
        Parent = tab3:GetContainer(),
        Callback = function()
            ui:SaveConfig()
            window:Notify({
                Title = "保存成功",
                Content = "所有设置已保存到配置文件",
                Icon = "check",
                Duration = 2,
            })
        end,
    })

    -- ============================================================
    -- 标签页 4：通知 + Tooltip
    -- ============================================================

    local tab4 = window:AddTab({
        Title = "通知 & Tooltip",
        Icon = "bell",
        Locked = false,
    })

    -- 通知按钮
    window:AddButton({
        Text = "显示通知",
        Variant = "Primary",
        Parent = tab4:GetContainer(),
        Callback = function()
            window:Notify({
                Title = "通知示例",
                Content = "这是一条来自 WindUI 的通知消息！",
                Icon = "bell",
                Duration = 3,
            })
        end,
    })

    -- 自定义通知
    window:AddButton({
        Text = "自定义通知",
        Variant = "Secondary",
        Parent = tab4:GetContainer(),
        Callback = function()
            window:Notify({
                Title = "自定义通知",
                Content = "这条通知有自定义图标和更长的显示时间",
                Icon = "star",
                Duration = 5,
            })
        end,
    })

    -- Tooltip 示例
    local tooltipTarget = window:AddButton({
        Text = "悬停查看提示",
        Variant = "Secondary",
        Parent = tab4:GetContainer(),
    })

    -- 创建 Tooltip
    UIComponents.Tooltip.new({
        Text = "这是一个 Tooltip 提示",
        Target = tooltipTarget.Main,
        Delay = 0.5,
        Duration = 3,
    })

    -- ============================================================
    -- 窗口事件
    -- ============================================================

    window.OnOpen = function()
        print("[WindUI] 窗口已打开")
    end

    window.OnClose = function()
        print("[WindUI] 窗口已关闭")
    end

    window.OnDestroy = function()
        print("[WindUI] 窗口已销毁")
    end

    -- ============================================================
    -- 返回 UI 实例
    -- ============================================================

    return ui, window
end

-- ============================================================
-- 自动运行示例（如果直接执行此脚本）
-- ============================================================

if script and script.Name == "Main" then
    -- 检查是否在 Studio 或游戏环境中
    local success, err = pcall(function()
        local ui, window = WindUI:CreateExample()
        print("[WindUI] 示例已启动！")
        print("[WindUI] 版本:", WindUI.Version)

        -- 将 UI 暴露到全局以便调试
        _G.WindUI = ui
        _G.Window = window

        -- 窗口打开后自动显示通知
        task.wait(1)
        window:Notify({
            Title = "欢迎使用 WindUI",
            Content = "版本 " .. WindUI.Version .. " 已加载完成",
            Icon = "home",
            Duration = 3,
        })
    end)

    if not success then
        warn("[WindUI] 启动失败:", err)
    end
end

-- ============================================================
-- 导出模块
-- ============================================================

return WindUI
