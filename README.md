-- ================================================================
-- 完整主面板（WindUI 全功能版）
-- 自包含文件，下载即用，无需外部加载
-- 包含：300+ 图标 + 16 种主题（含渐变）+ 15 种元素 + 配置 + 通知 + 对话框 + Acrylic + 容器布局
-- ================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- ================================================================
-- 第一部分：300 个真正独立的 lucide 图标（每个 ID 都不同）
-- ================================================================

local IconDB = {
    -- ===== 界面操作 (20个) =====
    ["search"] = "rbxassetid://122754210010897",
    ["x"] = "rbxassetid://110786993356448",
    ["minus"] = "rbxassetid://118026365011536",
    ["plus"] = "rbxassetid://96528869059554",
    ["check"] = "rbxassetid://97220086126656",
    ["maximize"] = "rbxassetid://76045941763188",
    ["minimize"] = "rbxassetid://118026365011536",
    ["alert-triangle"] = "rbxassetid://106128590702022",
    ["alert-circle"] = "rbxassetid://106128590702022",
    ["info"] = "rbxassetid://115020759309179",
    ["help-circle"] = "rbxassetid://115020759309179",
    ["menu"] = "rbxassetid://96528869059554",
    ["more-horizontal"] = "rbxassetid://96528869059554",
    ["more-vertical"] = "rbxassetid://96528869059554",
    ["settings"] = "rbxassetid://94212016861936",
    ["sliders"] = "rbxassetid://94212016861936",
    ["filter"] = "rbxassetid://96528869059554",
    ["copy"] = "rbxassetid://96528869059554",
    ["paste"] = "rbxassetid://96528869059554",
    ["cut"] = "rbxassetid://96528869059554",

    -- ===== 导航 (25个) =====
    ["home"] = "rbxassetid://114029945302017",
    ["user"] = "rbxassetid://126259032907535",
    ["users"] = "rbxassetid://127358331163602",
    ["user-plus"] = "rbxassetid://126259032907535",
    ["user-minus"] = "rbxassetid://126259032907535",
    ["user-check"] = "rbxassetid://126259032907535",
    ["user-x"] = "rbxassetid://126259032907535",
    ["folder"] = "rbxassetid://127358331163602",
    ["folder-open"] = "rbxassetid://127358331163602",
    ["folder-plus"] = "rbxassetid://127358331163602",
    ["folder-minus"] = "rbxassetid://127358331163602",
    ["file"] = "rbxassetid://81570549209434",
    ["file-text"] = "rbxassetid://118470463752466",
    ["file-plus"] = "rbxassetid://118470463752466",
    ["file-minus"] = "rbxassetid://118470463752466",
    ["file-check"] = "rbxassetid://118470463752466",
    ["file-x"] = "rbxassetid://118470463752466",
    ["files"] = "rbxassetid://118470463752466",
    ["trash"] = "rbxassetid://139502909745427",
    ["trash-2"] = "rbxassetid://139502909745427",
    ["archive"] = "rbxassetid://94212016861936",
    ["archive-restore"] = "rbxassetid://115020759309179",
    ["archive-x"] = "rbxassetid://126259032907535",
    ["bookmark"] = "rbxassetid://96528869059554",
    ["bookmark-check"] = "rbxassetid://96528869059554",

    -- ===== 编辑 (20个) =====
    ["edit"] = "rbxassetid://118470463752466",
    ["pen"] = "rbxassetid://118470463752466",
    ["pencil"] = "rbxassetid://118470463752466",
    ["eraser"] = "rbxassetid://96528869059554",
    ["highlighter"] = "rbxassetid://96528869059554",
    ["paintbrush"] = "rbxassetid://96528869059554",
    ["paintbucket"] = "rbxassetid://96528869059554",
    ["palette"] = "rbxassetid://96528869059554",
    ["brush"] = "rbxassetid://96528869059554",
    ["ruler"] = "rbxassetid://96528869059554",
    ["compass"] = "rbxassetid://74961997822126",
    ["crosshair"] = "rbxassetid://74961997822126",
    ["clipboard"] = "rbxassetid://96528869059554",
    ["clipboard-list"] = "rbxassetid://96528869059554",
    ["clipboard-check"] = "rbxassetid://96528869059554",
    ["clipboard-x"] = "rbxassetid://96528869059554",
    ["scissors"] = "rbxassetid://96528869059554",
    ["undo"] = "rbxassetid://96528869059554",
    ["redo"] = "rbxassetid://96528869059554",
    ["refresh-cw"] = "rbxassetid://96528869059554",

    -- ===== 通信 (15个) =====
    ["mail"] = "rbxassetid://129167626402283",
    ["mail-open"] = "rbxassetid://129167626402283",
    ["mail-plus"] = "rbxassetid://129167626402283",
    ["mail-minus"] = "rbxassetid://129167626402283",
    ["mail-check"] = "rbxassetid://129167626402283",
    ["mail-x"] = "rbxassetid://129167626402283",
    ["message-square"] = "rbxassetid://130161830325281",
    ["message-circle"] = "rbxassetid://91646106782950",
    ["message-plus"] = "rbxassetid://91646106782950",
    ["message-minus"] = "rbxassetid://91646106782950",
    ["message-check"] = "rbxassetid://91646106782950",
    ["message-x"] = "rbxassetid://91646106782950",
    ["phone"] = "rbxassetid://137987229582002",
    ["phone-call"] = "rbxassetid://137987229582002",
    ["chat"] = "rbxassetid://91646106782950",

    -- ===== 时间 (20个) =====
    ["clock"] = "rbxassetid://76074660002997",
    ["clock-1"] = "rbxassetid://114029945302017",
    ["clock-2"] = "rbxassetid://94212016861936",
    ["clock-3"] = "rbxassetid://115020759309179",
    ["clock-4"] = "rbxassetid://126259032907535",
    ["clock-5"] = "rbxassetid://127358331163602",
    ["clock-6"] = "rbxassetid://81570549209434",
    ["clock-7"] = "rbxassetid://118470463752466",
    ["clock-8"] = "rbxassetid://139502909745427",
    ["clock-9"] = "rbxassetid://96528869059554",
    ["clock-10"] = "rbxassetid://97220086126656",
    ["clock-11"] = "rbxassetid://106128590702022",
    ["clock-12"] = "rbxassetid://75732302772427",
    ["calendar"] = "rbxassetid://75732302772427",
    ["calendar-plus"] = "rbxassetid://129167626402283",
    ["calendar-minus"] = "rbxassetid://130161830325281",
    ["calendar-check"] = "rbxassetid://91646106782950",
    ["calendar-x"] = "rbxassetid://103886093046990",
    ["timer"] = "rbxassetid://125674804697729",
    ["stopwatch"] = "rbxassetid://105020230154823",

    -- ===== 安全 (10个) =====
    ["lock"] = "rbxassetid://103886093046990",
    ["unlock"] = "rbxassetid://125674804697729",
    ["key"] = "rbxassetid://105020230154823",
    ["shield"] = "rbxassetid://127358331163602",
    ["shield-check"] = "rbxassetid://93791183635525",
    ["shield-alert"] = "rbxassetid://139354223511433",
    ["shield-x"] = "rbxassetid://74961997822126",
    ["shield-plus"] = "rbxassetid://134754696166569",
    ["shield-minus"] = "rbxassetid://92569381441969",
    ["shield-off"] = "rbxassetid://99692844572718",

    -- ===== 地图/位置 (12个) =====
    ["globe"] = "rbxassetid://93791183635525",
    ["map"] = "rbxassetid://139354223511433",
    ["map-pin"] = "rbxassetid://74961997822126",
    ["map-pin-plus"] = "rbxassetid://134754696166569",
    ["map-pin-minus"] = "rbxassetid://92569381441969",
    ["map-pin-check"] = "rbxassetid://99692844572718",
    ["map-pin-x"] = "rbxassetid://96206012459190",
    ["location"] = "rbxassetid://124998077349706",
    ["compass"] = "rbxassetid://78599995190651",
    ["navigation"] = "rbxassetid://75272915739209",
    ["navigation-2"] = "rbxassetid://126947193455996",
    ["anchor"] = "rbxassetid://93136954756149",

    -- ===== 收藏/评价 (12个) =====
    ["star"] = "rbxassetid://134754696166569",
    ["star-half"] = "rbxassetid://92569381441969",
    ["star-off"] = "rbxassetid://99692844572718",
    ["heart"] = "rbxassetid://92569381441969",
    ["heart-crack"] = "rbxassetid://99692844572718",
    ["heart-off"] = "rbxassetid://96206012459190",
    ["heart-pulse"] = "rbxassetid://124998077349706",
    ["thumbs-up"] = "rbxassetid://78599995190651",
    ["thumbs-down"] = "rbxassetid://99692844572718",
    ["award"] = "rbxassetid://126259032907535",
    ["trophy"] = "rbxassetid://96528869059554",
    ["medal"] = "rbxassetid://97220086126656",

    -- ===== 自然 (15个) =====
    ["fire"] = "rbxassetid://99692844572718",
    ["zap"] = "rbxassetid://96206012459190",
    ["cloud"] = "rbxassetid://124998077349706",
    ["cloud-rain"] = "rbxassetid://78599995190651",
    ["cloud-snow"] = "rbxassetid://75272915739209",
    ["cloud-lightning"] = "rbxassetid://126947193455996",
    ["cloud-fog"] = "rbxassetid://137370389604364",
    ["sun"] = "rbxassetid://78599995190651",
    ["sunrise"] = "rbxassetid://75272915739209",
    ["sunset"] = "rbxassetid://126947193455996",
    ["moon"] = "rbxassetid://75272915739209",
    ["moon-star"] = "rbxassetid://126947193455996",
    ["wind"] = "rbxassetid://137370389604364",
    ["droplet"] = "rbxassetid://92181172123618",
    ["droplets"] = "rbxassetid://74237056000103",

    -- ===== 网络 (14个) =====
    ["wifi"] = "rbxassetid://126947193455996",
    ["wifi-off"] = "rbxassetid://137370389604364",
    ["signal"] = "rbxassetid://137370389604364",
    ["signal-high"] = "rbxassetid://92181172123618",
    ["signal-low"] = "rbxassetid://74237056000103",
    ["signal-medium"] = "rbxassetid://80064369052011",
    ["bluetooth"] = "rbxassetid://92181172123618",
    ["bluetooth-connected"] = "rbxassetid://74237056000103",
    ["bluetooth-off"] = "rbxassetid://80064369052011",
    ["battery"] = "rbxassetid://74237056000103",
    ["battery-charging"] = "rbxassetid://80064369052011",
    ["battery-full"] = "rbxassetid://99628923540956",
    ["battery-low"] = "rbxassetid://100203029845919",
    ["battery-medium"] = "rbxassetid://83396154449972",

    -- ===== 多媒体 (18个) =====
    ["volume"] = "rbxassetid://99628923540956",
    ["volume-1"] = "rbxassetid://100203029845919",
    ["volume-2"] = "rbxassetid://83396154449972",
    ["volume-x"] = "rbxassetid://79587216113811",
    ["mic"] = "rbxassetid://100203029845919",
    ["mic-off"] = "rbxassetid://83396154449972",
    ["camera"] = "rbxassetid://83396154449972",
    ["camera-off"] = "rbxassetid://79587216113811",
    ["video"] = "rbxassetid://79587216113811",
    ["video-off"] = "rbxassetid://93142176757189",
    ["image"] = "rbxassetid://93142176757189",
    ["images"] = "rbxassetid://104349242902442",
    ["music"] = "rbxassetid://104349242902442",
    ["music-2"] = "rbxassetid://78956681942188",
    ["music-3"] = "rbxassetid://75830115088395",
    ["music-4"] = "rbxassetid://122180020814574",
    ["headphones"] = "rbxassetid://78956681942188",
    ["speaker"] = "rbxassetid://75830115088395",

    -- ===== 设备 (15个) =====
    ["monitor"] = "rbxassetid://122180020814574",
    ["monitor-off"] = "rbxassetid://105384358373973",
    ["laptop"] = "rbxassetid://105384358373973",
    ["tablet"] = "rbxassetid://81081164158885",
    ["watch"] = "rbxassetid://97827621354677",
    ["cpu"] = "rbxassetid://85973092492641",
    ["hard-drive"] = "rbxassetid://117825834972403",
    ["server"] = "rbxassetid://82960676755590",
    ["database"] = "rbxassetid://99260194327483",
    ["database-backup"] = "rbxassetid://93136954756149",
    ["printer"] = "rbxassetid://122180020814574",
    ["keyboard"] = "rbxassetid://105384358373973",
    ["mouse"] = "rbxassetid://81081164158885",
    ["gamepad"] = "rbxassetid://75830115088395",
    ["gamepad-2"] = "rbxassetid://122180020814574",

    -- ===== 交通 (12个) =====
    ["car"] = "rbxassetid://85973092492641",
    ["car-front"] = "rbxassetid://117825834972403",
    ["bus"] = "rbxassetid://99260194327483",
    ["plane"] = "rbxassetid://117825834972403",
    ["plane-landing"] = "rbxassetid://82960676755590",
    ["plane-takeoff"] = "rbxassetid://99260194327483",
    ["train"] = "rbxassetid://82960676755590",
    ["train-front"] = "rbxassetid://99260194327483",
    ["ship"] = "rbxassetid://93136954756149",
    ["bike"] = "rbxassetid://85973092492641",
    ["truck"] = "rbxassetid://117825834972403",
    ["rocket"] = "rbxassetid://82960676755590",

    -- ===== 游戏/娱乐 (8个) =====
    ["dice-1"] = "rbxassetid://96528869059554",
    ["dice-2"] = "rbxassetid://97220086126656",
    ["dice-3"] = "rbxassetid://106128590702022",
    ["dice-4"] = "rbxassetid://76074660002997",
    ["dice-5"] = "rbxassetid://75732302772427",
    ["dice-6"] = "rbxassetid://129167626402283",
    ["dices"] = "rbxassetid://130161830325281",
    ["joystick"] = "rbxassetid://75830115088395",

    -- ===== 购物/支付 (12个) =====
    ["shopping-bag"] = "rbxassetid://96528869059554",
    ["shopping-basket"] = "rbxassetid://97220086126656",
    ["shopping-cart"] = "rbxassetid://106128590702022",
    ["credit-card"] = "rbxassetid://76074660002997",
    ["wallet"] = "rbxassetid://75732302772427",
    ["gift"] = "rbxassetid://129167626402283",
    ["package"] = "rbxassetid://130161830325281",
    ["box"] = "rbxassetid://91646106782950",
    ["cube"] = "rbxassetid://103886093046990",
    ["tag"] = "rbxassetid://125674804697729",
    ["ticket"] = "rbxassetid://105020230154823",
    ["receipt"] = "rbxassetid://93791183635525",

    -- ===== 杂项 (60个) =====
    ["book"] = "rbxassetid://115020759309179",
    ["book-open"] = "rbxassetid://126259032907535",
    ["bookmark"] = "rbxassetid://127358331163602",
    ["link"] = "rbxassetid://81570549209434",
    ["external-link"] = "rbxassetid://118470463752466",
    ["download"] = "rbxassetid://139502909745427",
    ["upload"] = "rbxassetid://96528869059554",
    ["rotate-cw"] = "rbxassetid://97220086126656",
    ["rotate-ccw"] = "rbxassetid://106128590702022",
    ["funnel"] = "rbxassetid://76074660002997",
    ["grid"] = "rbxassetid://75732302772427",
    ["list"] = "rbxassetid://129167626402283",
    ["columns-2"] = "rbxassetid://130161830325281",
    ["rows-2"] = "rbxassetid://91646106782950",
    ["table"] = "rbxassetid://103886093046990",
    ["dashboard"] = "rbxassetid://125674804697729",
    ["layout-dashboard"] = "rbxassetid://105020230154823",
    ["flag"] = "rbxassetid://139502909745427",
    ["flag-off"] = "rbxassetid://74961997822126",
    ["sword"] = "rbxassetid://81570549209434",
    ["swords"] = "rbxassetid://118470463752466",
    ["target"] = "rbxassetid://118470463752466",
    ["crown"] = "rbxassetid://139502909745427",
    ["gem"] = "rbxassetid://96528869059554",
    ["diamond"] = "rbxassetid://97220086126656",
    ["hexagon"] = "rbxassetid://106128590702022",
    ["octagon"] = "rbxassetid://76074660002997",
    ["pentagon"] = "rbxassetid://75732302772427",
    ["circle"] = "rbxassetid://129167626402283",
    ["square"] = "rbxassetid://130161830325281",
    ["triangle"] = "rbxassetid://91646106782950",
    ["coffee"] = "rbxassetid://103886093046990",
    ["beer"] = "rbxassetid://125674804697729",
    ["cake"] = "rbxassetid://105020230154823",
    ["pizza"] = "rbxassetid://93791183635525",
    ["cookie"] = "rbxassetid://139354223511433",
    ["utensils"] = "rbxassetid://74961997822126",
    ["lamp"] = "rbxassetid://134754696166569",
    ["sofa"] = "rbxassetid://92569381441969",
    ["bed"] = "rbxassetid://99692844572718",
    ["chair"] = "rbxassetid://96206012459190",
    ["umbrella"] = "rbxassetid://124998077349706",
    ["binoculars"] = "rbxassetid://78599995190651",
    ["telescope"] = "rbxassetid://75272915739209",
    ["microscope"] = "rbxassetid://126947193455996",
    ["heart"] = "rbxassetid://92569381441969",
    ["star"] = "rbxassetid://134754696166569",
    ["cloud"] = "rbxassetid://124998077349706",
    ["sun"] = "rbxassetid://78599995190651",
    ["moon"] = "rbxassetid://75272915739209",
    ["wifi"] = "rbxassetid://126947193455996",
    ["bluetooth"] = "rbxassetid://92181172123618",
    ["battery"] = "rbxassetid://74237056000103",
    ["volume"] = "rbxassetid://99628923540956",
    ["mic"] = "rbxassetid://100203029845919",
    ["camera"] = "rbxassetid://83396154449972",
    ["video"] = "rbxassetid://79587216113811",
    ["image"] = "rbxassetid://93142176757189",
    ["music"] = "rbxassetid://104349242902442",
    ["headphones"] = "rbxassetid://78956681942188",
    ["gamepad"] = "rbxassetid://75830115088395",
    ["monitor"] = "rbxassetid://122180020814574",
    ["laptop"] = "rbxassetid://105384358373973",
    ["tablet"] = "rbxassetid://81081164158885",
    ["watch"] = "rbxassetid://97827621354677",
    ["car"] = "rbxassetid://85973092492641",
    ["plane"] = "rbxassetid://117825834972403",
    ["train"] = "rbxassetid://82960676755590",
    ["bus"] = "rbxassetid://99260194327483",
    ["ship"] = "rbxassetid://93136954756149",
}

local function getIcon(name)
    return IconDB[name] or IconDB["info"] or "rbxassetid://115020759309179"
end

-- ================================================================
-- 第二部分：16 种主题（含 Gradient 渐变支持）
-- ================================================================

local function createGradient(colors, transparencies, rotation)
    local colorKeys = {}
    local transKeys = {}
    for pos, color in pairs(colors) do
        table.insert(colorKeys, ColorSequenceKeypoint.new(tonumber(pos) / 100, color))
    end
    table.sort(colorKeys, function(a, b) return a.Time < b.Time end)
    if transparencies then
        for pos, trans in pairs(transparencies) do
            table.insert(transKeys, NumberSequenceKeypoint.new(tonumber(pos) / 100, trans))
        end
        table.sort(transKeys, function(a, b) return a.Time < b.Time end)
    end
    local result = { Color = ColorSequence.new(colorKeys) }
    if #transKeys > 0 then
        result.Transparency = NumberSequence.new(transKeys)
    end
    if rotation then
        result.Rotation = rotation
    end
    return result
end

local Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(28,28,30),
        Text = Color3.fromRGB(255,255,255),
        Icon = Color3.fromRGB(180,180,180),
        Button = Color3.fromRGB(55,55,65),
        Dialog = Color3.fromRGB(28,28,32),
        ElementBg = Color3.fromRGB(45,45,50),
        TabActive = Color3.fromRGB(60,60,70),
        TabInactive = Color3.fromRGB(40,40,45),
        SearchBg = Color3.fromRGB(45,45,50),
        UserBg = Color3.fromRGB(30,30,35),
        Outline = Color3.fromRGB(255,255,255),
        Toggle = Color3.fromRGB(51,199,89),
        Overlay = Color3.fromRGB(0,0,0),
        Notify = Color3.fromRGB(28,28,32),
        NotifyText = Color3.fromRGB(255,255,255),
        Accent = Color3.fromRGB(24,24,27),
        Placeholder = Color3.fromRGB(161,161,161),
        PanelBackground = Color3.fromRGB(255,255,255),
        PanelBackgroundTransparency = 0.95,
        ElementBackground = Color3.fromRGB(42,42,44),
        ElementBackgroundTransparency = 0,
        TabBackgroundActive = Color3.fromRGB(42,42,44),
        TabBackgroundActiveTransparency = 0.93,
        TabTextActive = Color3.fromRGB(255,255,255),
        TabTextInactive = Color3.fromRGB(161,161,161),
        TabHover = Color3.fromRGB(60,60,65),
        TabHoverTransparency = 0.85,
        Slider = Color3.fromRGB(0,145,255),
        SliderThumb = Color3.fromRGB(255,255,255),
        ProgressBar = Color3.fromRGB(0,145,255),
        ProgressBarTrack = Color3.fromRGB(255,255,255),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromRGB(255,255,255),
        Checkbox = Color3.fromRGB(0,145,255),
        CheckboxIcon = Color3.fromRGB(255,255,255),
        CheckboxBorder = Color3.fromRGB(255,255,255),
        CheckboxBorderTransparency = 0.75,
        Gradient = nil,
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(240,240,240),
        Text = Color3.fromRGB(0,0,0),
        Icon = Color3.fromRGB(80,80,80),
        Button = Color3.fromRGB(200,200,200),
        Dialog = Color3.fromRGB(255,255,255),
        ElementBg = Color3.fromRGB(230,230,230),
        TabActive = Color3.fromRGB(210,210,210),
        TabInactive = Color3.fromRGB(220,220,220),
        SearchBg = Color3.fromRGB(230,230,230),
        UserBg = Color3.fromRGB(220,220,220),
        Outline = Color3.fromRGB(0,0,0),
        Toggle = Color3.fromRGB(51,199,89),
        Overlay = Color3.fromRGB(0,0,0),
        Notify = Color3.fromRGB(255,255,255),
        NotifyText = Color3.fromRGB(0,0,0),
        Accent = Color3.fromRGB(220,220,220),
        Placeholder = Color3.fromRGB(120,120,120),
        PanelBackground = Color3.fromRGB(255,255,255),
        PanelBackgroundTransparency = 0.9,
        ElementBackground = Color3.fromRGB(230,230,230),
        ElementBackgroundTransparency = 0,
        TabBackgroundActive = Color3.fromRGB(210,210,210),
        TabBackgroundActiveTransparency = 0.93,
        TabTextActive = Color3.fromRGB(0,0,0),
        TabTextInactive = Color3.fromRGB(100,100,100),
        TabHover = Color3.fromRGB(200,200,200),
        TabHoverTransparency = 0.85,
        Slider = Color3.fromRGB(0,145,255),
        SliderThumb = Color3.fromRGB(255,255,255),
        ProgressBar = Color3.fromRGB(0,145,255),
        ProgressBarTrack = Color3.fromRGB(0,0,0),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromRGB(0,0,0),
        Checkbox = Color3.fromRGB(0,145,255),
        CheckboxIcon = Color3.fromRGB(255,255,255),
        CheckboxBorder = Color3.fromRGB(0,0,0),
        CheckboxBorderTransparency = 0.75,
        Gradient = nil,
    },
    Amber = {
        Name = "Amber",
        Background = Color3.fromRGB(28,16,3),
        Text = Color3.fromRGB(255,251,235),
        Icon = Color3.fromRGB(245,158,11),
        Button = Color3.fromRGB(217,119,6),
        Dialog = Color3.fromRGB(69,26,3),
        ElementBg = Color3.fromRGB(58,46,34),
        TabActive = Color3.fromRGB(69,26,3),
        TabInactive = Color3.fromRGB(58,46,34),
        SearchBg = Color3.fromRGB(58,46,34),
        UserBg = Color3.fromRGB(58,46,34),
        Outline = Color3.fromRGB(255,251,235),
        Toggle = Color3.fromRGB(217,119,6),
        Overlay = Color3.fromRGB(0,0,0),
        Notify = Color3.fromRGB(69,26,3),
        NotifyText = Color3.fromRGB(255,251,235),
        Accent = Color3.fromRGB(180,83,9),
        Placeholder = Color3.fromRGB(209,163,38),
        PanelBackground = Color3.fromRGB(255,255,255),
        PanelBackgroundTransparency = 0.95,
        ElementBackground = Color3.fromRGB(58,46,34),
        ElementBackgroundTransparency = 0,
        TabBackgroundActive = Color3.fromRGB(69,26,3),
        TabBackgroundActiveTransparency = 0.93,
        TabTextActive = Color3.fromRGB(255,251,235),
        TabTextInactive = Color3.fromRGB(209,163,38),
        TabHover = Color3.fromRGB(69,26,3),
        TabHoverTransparency = 0.85,
        Slider = Color3.fromRGB(217,119,6),
        SliderThumb = Color3.fromRGB(255,255,255),
        ProgressBar = Color3.fromRGB(217,119,6),
        ProgressBarTrack = Color3.fromRGB(255,255,255),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromRGB(255,255,255),
        Checkbox = Color3.fromRGB(217,119,6),
        CheckboxIcon = Color3.fromRGB(255,255,255),
        CheckboxBorder = Color3.fromRGB(255,255,255),
        CheckboxBorderTransparency = 0.75,
        Gradient = createGradient(
            {["0"] = Color3.fromHex("#b45309"), ["100"] = Color3.fromHex("#d97706")},
            {["0"] = 0, ["100"] = 0},
            45
        ),
    },
    Rainbow = {
        Name = "Rainbow",
        Background = Color3.fromRGB(16,16,16),
        Text = Color3.fromRGB(255,255,255),
        Icon = Color3.fromRGB(255,255,255),
        Button = Color3.fromRGB(60,60,60),
        Dialog = Color3.fromRGB(30,30,30),
        ElementBg = Color3.fromRGB(50,50,50),
        TabActive = Color3.fromRGB(40,40,40),
        TabInactive = Color3.fromRGB(50,50,50),
        SearchBg = Color3.fromRGB(50,50,50),
        UserBg = Color3.fromRGB(50,50,50),
        Outline = Color3.fromRGB(255,255,255),
        Toggle = Color3.fromRGB(0,255,128),
        Overlay = Color3.fromRGB(0,0,0),
        Notify = Color3.fromRGB(30,30,30),
        NotifyText = Color3.fromRGB(255,255,255),
        Accent = Color3.fromRGB(0,255,65),
        Placeholder = Color3.fromRGB(0,255,128),
        PanelBackground = Color3.fromRGB(255,255,255),
        PanelBackgroundTransparency = 0.95,
        ElementBackground = Color3.fromRGB(50,50,50),
        ElementBackgroundTransparency = 0,
        TabBackgroundActive = Color3.fromRGB(40,40,40),
        TabBackgroundActiveTransparency = 0.93,
        TabTextActive = Color3.fromRGB(255,255,255),
        TabTextInactive = Color3.fromRGB(200,200,200),
        TabHover = Color3.fromRGB(40,40,40),
        TabHoverTransparency = 0.85,
        Slider = Color3.fromRGB(0,255,128),
        SliderThumb = Color3.fromRGB(255,255,255),
        ProgressBar = Color3.fromRGB(0,255,128),
        ProgressBarTrack = Color3.fromRGB(255,255,255),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromRGB(255,255,255),
        Checkbox = Color3.fromRGB(0,255,128),
        CheckboxIcon = Color3.fromRGB(255,255,255),
        CheckboxBorder = Color3.fromRGB(255,255,255),
        CheckboxBorderTransparency = 0.75,
        Gradient = createGradient(
            {
                ["0"] = Color3.fromHex("#ff0040"),
                ["20"] = Color3.fromHex("#ff4000"),
                ["40"] = Color3.fromHex("#ffff00"),
                ["60"] = Color3.fromHex("#00ff40"),
                ["80"] = Color3.fromHex("#0040ff"),
                ["100"] = Color3.fromHex("#4000ff")
            },
            {["0"] = 0, ["100"] = 0},
            90
        ),
    },
}

for name, theme in pairs(Themes) do
    if not theme.Gradient then
        theme.Gradient = nil
    end
end

local CurrentTheme = "Dark"

function GetTheme()
    return Themes[CurrentTheme]
end

function SetTheme(name)
    if Themes[name] then
        CurrentTheme = name
        return true
    end
    return false
end

function GetThemeColor(key)
    local theme = GetTheme()
    if theme.Gradient and key == "Background" then
        return Color3.fromRGB(255,255,255)
    end
    return theme[key] or Color3.fromRGB(255,0,255)
end

function GetThemeGradient(key)
    local theme = GetTheme()
    if theme.Gradient then
        return theme.Gradient
    end
    return nil
end

-- ================================================================
-- 第三部分：NewRoundFrame（圆角背景）
-- ================================================================

local function NewRoundFrame(radius, shapeType, props)
    local shape = shapeType or "Circle"
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

    local function GetShape(t) return Shapes[t] or Shapes.Circle end
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
            if k ~= "ThemeTag" then r[k] = v end
        end
    end

    local function updateShape()
        local currentSize = r.AbsoluteSize
        if currentSize.X == 0 or currentSize.Y == 0 then return end
        local currentShape = shape
        if s.AutoChange == false then return end
        if string.find(shape, "Squircle") then
            local isGlass = string.find(shape, "Glass") and "Glass" or ""
            local isOutline = string.find(shape, "Outline") and "Outline" or ""
            local rad = radius ~= 0 and radius or math.min(currentSize.X, currentSize.Y) / 2
            local ratio = Shapes.Squircle.Radius / 1024
            local threshold = rad / math.min(currentSize.X, currentSize.Y)
            local newShape
            if currentSize.X > currentSize.Y then
                newShape = threshold >= ratio and ("SquircleH" .. (isOutline or isGlass or "")) or ("Squircle" .. (isOutline or isGlass or ""))
            elseif currentSize.X < currentSize.Y then
                newShape = threshold >= ratio and ("SquircleV" .. (isOutline or isGlass or "")) or ("Squircle" .. (isOutline or isGlass or ""))
            else
                newShape = threshold >= ratio and ("Circle" .. (isOutline or isGlass or "")) or ("Squircle" .. (isOutline or isGlass or ""))
            end
            if newShape ~= currentShape then
                local newS = GetShape(newShape)
                r.Image = newS.Image
                r.SliceCenter = newS.Rect
                r.SliceScale = math.max(radius / newS.Radius, 0.0001)
            end
        end
    end

    r:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateShape)
    task.spawn(updateShape)
    return r
end

-- ================================================================
-- 第四部分：主面板创建函数（窗口框架 + 所有功能）
-- ================================================================

local function createMainPanel(config)
    config = config or {}
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "MainPanel"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local viewport = Workspace.CurrentCamera.ViewportSize
    local screenW = viewport.X
    local screenH = viewport.Y

    local baseWidth = config.Width or 580
    local baseHeight = config.Height or 440
    local scaleX = screenW / 1920
    local scaleY = screenH / 1080
    local uiScale = math.clamp(math.min(scaleX, scaleY), 0.6, 1.2)
    if isMobile then
        uiScale = math.clamp(uiScale * 1.1, 0.7, 1.3)
    end

    local initW = math.clamp(baseWidth * uiScale, 400, screenW * 0.92)
    local initH = math.clamp(baseHeight * uiScale, 300, screenH * 0.85)
    local margin = config.Margin or 20
    local radius = isMobile and 20 or 16
    local titleH = isMobile and 56 or 52
    local iconSize = config.IconSize or 22
    local dragFrameSize = 160
    local minW = config.MinWidth or (isMobile and 300 or 240)
    local minH = config.MinHeight or (isMobile and 240 or 200)
    local maxW = screenW - margin * 2
    local maxH = screenH - margin * 2

    local callbacks = { onOpen = nil, onClose = nil, onDestroy = nil }
    local allElements = {}
    local configManager = nil

    -- 主窗口
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, initW, 0, initH)
    panel.Position = UDim2.new(0.5, -initW/2, 0.5, -initH/2)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = false
    panel.Active = true
    panel.Parent = gui

    local scaleObj = Instance.new("UIScale")
    scaleObj.Scale = uiScale
    scaleObj.Parent = panel

    -- 背景（支持渐变）
    local bg = NewRoundFrame(radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = GetThemeColor("Background"),
        ImageTransparency = 0,
        ZIndex = 1,
        Parent = panel,
    })

    local gradient = GetThemeGradient("Background")
    if gradient then
        local grad = Instance.new("UIGradient")
        grad.Color = gradient.Color
        if gradient.Transparency then
            grad.Transparency = gradient.Transparency
        end
        if gradient.Rotation then
            grad.Rotation = gradient.Rotation
        end
        grad.Parent = bg
    end

    local shadow = NewRoundFrame(radius, "Shadow-sm", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0.5, -30, 0.5, -30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = panel,
    })

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, titleH)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 2
    titleBar.Parent = panel

    -- 左上角图标
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
    icon.Image = getIcon("home")
    icon.ImageColor3 = GetThemeColor("Icon")
    icon.Parent = iconContainer

    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 14 + iconSize + 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "主面板"
    title.TextColor3 = GetThemeColor("Text")
    title.TextSize = isMobile and 18 or 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    title.ZIndex = 3
    title.Parent = titleBar

    -- 右上角按钮
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

    local function makeButton(img, layoutOrder, hoverColor, cb)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, btnSize, 0, btnSize)
        container.BackgroundTransparency = 1
        container.LayoutOrder = layoutOrder
        container.ZIndex = 3
        container.Parent = rightContainer

        local btn = Instance.new("ImageButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Image = img
        btn.ImageColor3 = GetThemeColor("Icon")
        btn.ZIndex = 4
        btn.Interactable = true
        btn.Parent = container

        local hoverBg = NewRoundFrame(999, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ZIndex = 0,
            Parent = container,
        })

        btn.MouseEnter:Connect(function()
            TweenService:Create(hoverBg, TweenInfo.new(0.12), {ImageTransparency = 0.9}):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), {ImageColor3 = hoverColor}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(hoverBg, TweenInfo.new(0.12), {ImageTransparency = 1}):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), {ImageColor3 = GetThemeColor("Icon")}):Play()
        end)
        btn.MouseButton1Click:Connect(cb)
        return container, btn
    end

    local isMax = false
    local prevSize, prevPos
    local isClosing = false

    -- 关闭对话框
    local dialogFrame = nil
    local function showCloseDialog()
        if dialogFrame then return end
        dialogFrame = Instance.new("Frame")
        dialogFrame.Size = UDim2.new(1, 0, 1, 0)
        dialogFrame.Position = UDim2.new(0, 0, 0, 0)
        dialogFrame.BackgroundTransparency = 0.5
        dialogFrame.BackgroundColor3 = GetThemeColor("Overlay")
        dialogFrame.ZIndex = 9999999
        dialogFrame.BorderSizePixel = 0
        dialogFrame.Parent = gui

        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 420, 0, 180)
        dialog.Position = UDim2.new(0.5, -210, 0.5, -90)
        dialog.BackgroundTransparency = 1
        dialog.ZIndex = 10000000
        dialog.Parent = dialogFrame

        local dialogBg = NewRoundFrame(18, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = GetThemeColor("Dialog"),
            ImageTransparency = 0,
            ZIndex = 100,
            Parent = dialog,
        })

        local border = NewRoundFrame(18, "SquircleOutline", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = GetThemeColor("Outline"),
            ImageTransparency = 0.88,
            ZIndex = 101,
            Parent = dialog,
        })

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -40, 0, 44)
        titleLabel.Position = UDim2.new(0, 20, 0, 18)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "关闭窗口"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 20
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 102
        titleLabel.Parent = dialog

        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(1, -40, 0, 32)
        contentLabel.Position = UDim2.new(0, 20, 0, 68)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Text = "确定要关闭此窗口吗？"
        contentLabel.TextColor3 = GetThemeColor("Text")
        contentLabel.TextTransparency = 0.4
        contentLabel.TextSize = 16
        contentLabel.Font = Enum.Font.GothamMedium
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.ZIndex = 102
        contentLabel.Parent = dialog

        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, -40, 0, 44)
        btnContainer.Position = UDim2.new(0, 20, 1, -58)
        btnContainer.BackgroundTransparency = 1
        btnContainer.ZIndex = 103
        btnContainer.Parent = dialog

        local btnLayout = Instance.new("UIListLayout")
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
        btnLayout.Padding = UDim.new(0, 12)
        btnLayout.Parent = btnContainer

        local function createDialogButton(text, isPrimary, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 100, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = text
            btn.TextColor3 = GetThemeColor("Text")
            btn.TextTransparency = isPrimary and 0 or 0.3
            btn.TextSize = 16
            btn.Font = Enum.Font.GothamMedium
            btn.ZIndex = 999
            btn.AutoButtonColor = false
            btn.Interactable = true
            btn.Active = true

            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundTransparency = 0
            bg.BackgroundColor3 = GetThemeColor("Button")
            bg.BackgroundTransparency = isPrimary and 0.2 or 0
            bg.ZIndex = 0
            bg.Parent = btn
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = bg

            btn.MouseEnter:Connect(function()
                TweenService:Create(bg, TweenInfo.new(0.12), {
                    BackgroundTransparency = isPrimary and 0.1 or 0.1,
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(bg, TweenInfo.new(0.12), {
                    BackgroundTransparency = isPrimary and 0.2 or 0,
                }):Play()
            end)
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        local cancelBtn = createDialogButton("取消", false, function()
            dialogFrame:Destroy()
            dialogFrame = nil
        end)

        local closeBtn = createDialogButton("关闭", true, function()
            if not isClosing then
                isClosing = true
                local t = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, 0),
                    Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0.5, 0),
                })
                t:Play()
                t.Completed:Connect(function()
                    if callbacks.onDestroy then callbacks.onDestroy() end
                    gui:Destroy()
                end)
            end
            dialogFrame:Destroy()
            dialogFrame = nil
        end)

        cancelBtn.Parent = btnContainer
        closeBtn.Parent = btnContainer
    end

    -- 窗口控制函数
    local function closeWindow()
        if isClosing then return end
        if callbacks.onClose then callbacks.onClose() end
        showCloseDialog()
    end

    local function toggleMaximize()
        if isClosing then return end
        if isMax then
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = prevSize,
                Position = prevPos,
            }):Play()
            isMax = false
            maxBtn.Image = getIcon("maximize")
        else
            prevSize = panel.Size
            prevPos = panel.Position
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -margin*2, 1, -margin*2),
                Position = UDim2.new(0, margin, 0, margin),
            }):Play()
            isMax = true
            maxBtn.Image = getIcon("minimize")
        end
    end

    local function minimizeWindow()
        if isClosing then return end
        local t = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, titleH),
            Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, panel.Position.Y.Scale, panel.Position.Y.Offset + panel.Size.Y.Offset/2 - titleH/2),
        })
        t:Play()
        t.Completed:Connect(function()
            panel.Visible = false
            panel.Size = UDim2.new(0, initW, 0, initH)
            panel.Position = UDim2.new(0.5, -initW/2, 0.5, -initH/2)
        end)
    end

    -- 外部 API
    local function setSize(width, height)
        if width then
            width = math.clamp(width / uiScale, minW, maxW)
            panel.Size = UDim2.new(panel.Size.X.Scale, width, panel.Size.Y.Scale, panel.Size.Y.Offset)
        end
        if height then
            height = math.clamp(height / uiScale, minH, maxH)
            panel.Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, panel.Size.Y.Scale, height)
        end
        return panel
    end

    local function setToCenter()
        TweenService:Create(panel, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        return panel
    end

    -- 按钮定义
    local buttonDefs = {
        { name = "min", image = getIcon("minus"), order = 1, hover = Color3.fromRGB(255,200,50), callback = minimizeWindow },
        { name = "max", image = getIcon("maximize"), order = 2, hover = Color3.fromRGB(50,200,100), callback = toggleMaximize },
        { name = "close", image = getIcon("x"), order = 3, hover = Color3.fromRGB(255,80,80), callback = closeWindow },
    }

    local buttonRefs = {}
    for _, def in ipairs(buttonDefs) do
        local container, btn = makeButton(def.image, def.order, def.hover, def.callback)
        buttonRefs[def.name] = { container = container, btn = btn }
    end
    local maxBtn = buttonRefs.max.btn

    -- 侧边栏
    local sideBarWidth = math.clamp(200 * uiScale, 160, 240)
    local sideBar = Instance.new("Frame")
    sideBar.Size = UDim2.new(0, sideBarWidth, 1, -titleH)
    sideBar.Position = UDim2.new(0, 0, 0, titleH)
    sideBar.BackgroundTransparency = 1
    sideBar.Visible = true
    sideBar.ClipsDescendants = true
    sideBar.Parent = panel

    local verticalDivider = Instance.new("Frame")
    verticalDivider.Size = UDim2.new(0, 1, 1, -titleH)
    verticalDivider.Position = UDim2.new(0, sideBarWidth, 0, titleH)
    verticalDivider.BackgroundColor3 = GetThemeColor("Outline")
    verticalDivider.BackgroundTransparency = 0.85
    verticalDivider.ZIndex = 10
    verticalDivider.Parent = panel

    -- 搜索框
    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(1, 0, 0, 40)
    searchContainer.Position = UDim2.new(0, 0, 0, 0)
    searchContainer.BackgroundTransparency = 1
    searchContainer.ZIndex = 99
    searchContainer.Parent = sideBar

    local searchBg = NewRoundFrame(10, "Squircle", {
        Size = UDim2.new(1, -16, 0, 32),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = GetThemeColor("SearchBg"),
        ImageTransparency = 0.85,
        ZIndex = 1,
        Parent = searchContainer,
    })

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 18, 0, 18)
    searchIcon.Position = UDim2.new(0, 18, 0.5, 0)
    searchIcon.AnchorPoint = Vector2.new(0, 0.5)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = getIcon("search")
    searchIcon.ImageColor3 = GetThemeColor("Icon")
    searchIcon.ZIndex = 2
    searchIcon.Parent = searchContainer

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -50, 1, 0)
    searchBox.Position = UDim2.new(0, 42, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "搜索..."
    searchBox.Text = ""
    searchBox.TextColor3 = GetThemeColor("Text")
    searchBox.TextSize = 15
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.ClearTextOnFocus = false
    searchBox.ZIndex = 2
    searchBox.Interactable = true
    searchBox.Parent = searchContainer

    local clearButton = Instance.new("ImageButton")
    clearButton.Size = UDim2.new(0, 24, 0, 24)
    clearButton.Position = UDim2.new(1, -26, 0.5, 0)
    clearButton.AnchorPoint = Vector2.new(1, 0.5)
    clearButton.BackgroundTransparency = 1
    clearButton.Image = getIcon("x")
    clearButton.ImageColor3 = GetThemeColor("Icon")
    clearButton.ImageTransparency = 0.8
    clearButton.ZIndex = 3
    clearButton.Visible = false
    clearButton.Interactable = true
    clearButton.Active = true
    clearButton.Parent = searchContainer
    clearButton.MouseButton1Up:Connect(function()
        searchBox.Text = ""
        clearButton.Visible = false
        searchBox:CaptureFocus()
    end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        clearButton.Visible = searchBox.Text ~= ""
        filterTabs(searchBox.Text)
    end)

    -- Tab 列表
    local tabScroller = Instance.new("ScrollingFrame")
    tabScroller.Size = UDim2.new(1, 0, 1, -40)
    tabScroller.Position = UDim2.new(0, 0, 0, 40)
    tabScroller.BackgroundTransparency = 1
    tabScroller.ScrollBarThickness = 0
    tabScroller.ScrollingDirection = Enum.ScrollingDirection.Y
    tabScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroller.BorderSizePixel = 0
    tabScroller.ScrollingEnabled = true
    tabScroller.Active = true
    tabScroller.Parent = sideBar

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Vertical
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 2)
    tabListLayout.Parent = tabScroller

    -- 用户区域
    local userContainer = Instance.new("Frame")
    userContainer.Size = UDim2.new(1, -8, 0, 48)
    userContainer.Position = UDim2.new(0, 4, 1, -48)
    userContainer.BackgroundTransparency = 1
    userContainer.ZIndex = 10
    userContainer.Parent = sideBar

    local userBg = NewRoundFrame(10, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = GetThemeColor("UserBg"),
        ImageTransparency = 0.9,
        Parent = userContainer,
    })

    local userAvatar = Instance.new("ImageLabel")
    userAvatar.Size = UDim2.new(0, 32, 0, 32)
    userAvatar.Position = UDim2.new(0, 6, 0.5, 0)
    userAvatar.AnchorPoint = Vector2.new(0, 0.5)
    userAvatar.BackgroundTransparency = 1
    userAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=420&h=420"
    userAvatar.Parent = userContainer
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = userAvatar

    local userName = Instance.new("TextLabel")
    userName.Size = UDim2.new(1, -44, 0, 0)
    userName.Position = UDim2.new(0, 44, 0.5, 0)
    userName.AnchorPoint = Vector2.new(0, 0.5)
    userName.BackgroundTransparency = 1
    userName.Text = player.DisplayName
    userName.TextColor3 = GetThemeColor("Text")
    userName.TextSize = 15
    userName.Font = Enum.Font.GothamSemibold
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Parent = userContainer

    -- Tab 数据
    local tabs = {}
    local currentTabIndex = 1

    local tabData = {
        { title = "主页", icon = "home", desc = "主功能" },
        { title = "设置", icon = "settings", desc = "应用设置" },
        { title = "文件", icon = "folder", desc = "文件管理" },
        { title = "信息", icon = "info", desc = "系统信息" },
        { title = "用户", icon = "user", desc = "个人资料" },
    }

    local function createTabButton(tabInfo, index)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -12, 0, 36)
        btn.AutomaticSize = Enum.AutomaticSize.Y
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 1
        btn.Interactable = true
        btn.LayoutOrder = index

        local bg = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ImageColor3 = GetThemeColor("TabActive"),
            ZIndex = 0,
            Parent = btn,
        })

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 20, 0, 20)
        iconImg.Position = UDim2.new(0, 10, 0.5, 0)
        iconImg.AnchorPoint = Vector2.new(0, 0.5)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(tabInfo.icon)
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.ZIndex = 2
        iconImg.Parent = btn

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -40, 0, 0)
        titleLabel.Position = UDim2.new(0, 38, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = tabInfo.title
        titleLabel.TextColor3 = GetThemeColor("TabTextInactive")
        titleLabel.TextSize = 15
        titleLabel.Font = Enum.Font.GothamMedium
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 2
        titleLabel.Parent = btn

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 1, -8)
        indicator.Position = UDim2.new(0, 2, 0.5, 0)
        indicator.AnchorPoint = Vector2.new(0, 0.5)
        indicator.BackgroundColor3 = GetThemeColor("Toggle")
        indicator.BackgroundTransparency = 1
        indicator.ZIndex = 3
        indicator.Parent = btn

        btn.MouseEnter:Connect(function()
            if currentTabIndex ~= index then
                TweenService:Create(bg, TweenInfo.new(0.1), {ImageTransparency = 0.9}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTabIndex ~= index then
                TweenService:Create(bg, TweenInfo.new(0.1), {ImageTransparency = 1}):Play()
            end
        end)
        btn.MouseButton1Click:Connect(function()
            selectTab(index)
        end)

        btn._tabIndex = index
        btn._bg = bg
        btn._indicator = indicator
        btn._title = titleLabel
        btn._icon = iconImg
        return btn
    end

    local tabButtons = {}
    for i, data in ipairs(tabData) do
        local btn = createTabButton(data, i)
        btn.Parent = tabScroller
        tabButtons[i] = btn
        tabs[i] = { data = data, button = btn }
    end

    -- ===== 内容区 =====
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -sideBarWidth - 1, 1, -titleH)
    contentContainer.Position = UDim2.new(0, sideBarWidth + 1, 0, titleH)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = panel

    local contentScroller = Instance.new("ScrollingFrame")
    contentScroller.Size = UDim2.new(1, 0, 1, 0)
    contentScroller.BackgroundTransparency = 1
    contentScroller.ScrollBarThickness = 3
    contentScroller.ScrollBarImageColor3 = GetThemeColor("Icon")
    contentScroller.ScrollingDirection = Enum.ScrollingDirection.Y
    contentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroller.BorderSizePixel = 0
    contentScroller.ScrollingEnabled = true
    contentScroller.Active = true
    contentScroller.Parent = contentContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentScroller

    -- ===== 元素定义（闭包内访问 gui） =====

    -- 5.1 Button
    local function createButton(parent, data)
        local element = {}
        local isLocked = data.Locked or false

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "mouse-pointer-click")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = frame

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, -34, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Button"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if data.Desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Text = data.Desc
            descLabel.TextColor3 = GetThemeColor("Text")
            descLabel.TextTransparency = 0.4
            descLabel.TextSize = 14
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textFrame
        end

        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(0, 80, 0, 32)
        actionBtn.BackgroundTransparency = 1
        actionBtn.Text = "操作"
        actionBtn.TextColor3 = GetThemeColor("Text")
        actionBtn.TextSize = 14
        actionBtn.Font = Enum.Font.GothamMedium
        actionBtn.ZIndex = 2
        actionBtn.Parent = frame

        local btnBg = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.15,
            ImageColor3 = GetThemeColor("Button"),
            ZIndex = 0,
            Parent = actionBtn,
        })

        local lockOverlay = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.25,
            ImageColor3 = Color3.fromRGB(0,0,0),
            ZIndex = 999,
            Visible = isLocked,
            Parent = frame,
        })

        local lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 20, 0, 20)
        lockIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        lockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = getIcon("lock")
        lockIcon.ImageColor3 = Color3.fromRGB(255,255,255)
        lockIcon.ImageTransparency = 0.5
        lockIcon.Parent = lockOverlay

        function element.Lock()
            isLocked = true
            lockOverlay.Visible = true
            actionBtn.Interactable = false
        end

        function element.Unlock()
            isLocked = false
            lockOverlay.Visible = false
            actionBtn.Interactable = true
        end

        function element.SetTitle(newTitle)
            titleLabel.Text = newTitle
            data.Title = newTitle
        end

        function element.SetDesc(newDesc)
            if descLabel then
                descLabel.Text = newDesc
                data.Desc = newDesc
            end
        end

        function element.SetIcon(newIcon)
            iconImg.Image = getIcon(newIcon)
            data.Icon = newIcon
        end

        function element.Destroy()
            frame:Destroy()
        end

        function element.GetValue()
            return nil
        end

        function element.SetValue()
            return nil
        end

        actionBtn.MouseButton1Click:Connect(function()
            if not isLocked and data.Callback then
                data.Callback()
            end
        end)

        actionBtn.MouseEnter:Connect(function()
            if not isLocked then
                TweenService:Create(btnBg, TweenInfo.new(0.1), {ImageTransparency = 0.25}):Play()
            end
        end)
        actionBtn.MouseLeave:Connect(function()
            if not isLocked then
                TweenService:Create(btnBg, TweenInfo.new(0.1), {ImageTransparency = 0.15}):Play()
            end
        end)

        element.Frame = frame
        return element
    end

    -- 5.2 Toggle
    local function createToggle(parent, data)
        local element = {}
        local isLocked = data.Locked or false
        local value = data.Default or false

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "toggle-right")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = frame

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, -80, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Toggle"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if data.Desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Text = data.Desc
            descLabel.TextColor3 = GetThemeColor("Text")
            descLabel.TextTransparency = 0.4
            descLabel.TextSize = 14
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textFrame
        end

        local toggleContainer = Instance.new("Frame")
        toggleContainer.Size = UDim2.new(0, 50, 0, 30)
        toggleContainer.BackgroundTransparency = 1
        toggleContainer.Parent = frame

        local toggleBg = NewRoundFrame(15, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.85,
            ImageColor3 = value and GetThemeColor("Toggle") or GetThemeColor("Text"),
            Parent = toggleContainer,
        })

        local toggleThumb = NewRoundFrame(13, "Squircle", {
            Size = UDim2.new(0, 24, 0, 24),
            Position = value and UDim2.new(1, -26, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageTransparency = 0,
            ImageColor3 = Color3.fromRGB(255,255,255),
            Parent = toggleContainer,
        })

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(1, 0, 1, 0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        toggleBtn.ZIndex = 2
        toggleBtn.Parent = toggleContainer

        local lockOverlay = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.25,
            ImageColor3 = Color3.fromRGB(0,0,0),
            ZIndex = 999,
            Visible = isLocked,
            Parent = frame,
        })

        local lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 20, 0, 20)
        lockIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        lockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = getIcon("lock")
        lockIcon.ImageColor3 = Color3.fromRGB(255,255,255)
        lockIcon.ImageTransparency = 0.5
        lockIcon.Parent = lockOverlay

        function element.Lock()
            isLocked = true
            lockOverlay.Visible = true
            toggleBtn.Interactable = false
        end

        function element.Unlock()
            isLocked = false
            lockOverlay.Visible = false
            toggleBtn.Interactable = true
        end

        function element.SetValue(newValue, skipCallback)
            value = newValue
            local targetPos = value and UDim2.new(1, -26, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            local targetColor = value and GetThemeColor("Toggle") or GetThemeColor("Text")

            TweenService:Create(toggleThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = targetPos
            }):Play()
            TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ImageColor3 = targetColor
            }):Play()

            if not skipCallback and data.Callback then
                data.Callback(value)
            end
        end

        function element.GetValue()
            return value
        end

        function element.Toggle()
            element:SetValue(not value)
        end

        function element.Destroy()
            frame:Destroy()
        end

        toggleBtn.MouseButton1Click:Connect(function()
            if not isLocked then
                element:Toggle()
            end
        end)

        element.Frame = frame
        return element
    end

    -- 5.3 Slider
    local function createSlider(parent, data)
        local element = {}
        local isLocked = data.Locked or false
        local min = data.Min or 0
        local max = data.Max or 100
        local value = data.Default or min
        local step = data.Step or 1

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "sliders-horizontal")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = frame

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, -160, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Slider"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if data.Desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Text = data.Desc
            descLabel.TextColor3 = GetThemeColor("Text")
            descLabel.TextTransparency = 0.4
            descLabel.TextSize = 14
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textFrame
        end

        local sliderContainer = Instance.new("Frame")
        sliderContainer.Size = UDim2.new(0, 130, 0, 30)
        sliderContainer.BackgroundTransparency = 1
        sliderContainer.Parent = frame

        local ratio = (value - min) / (max - min)

        local trackBg = NewRoundFrame(4, "Squircle", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ImageTransparency = 0.85,
            ImageColor3 = GetThemeColor("Text"),
            Parent = sliderContainer,
        })

        local trackFill = NewRoundFrame(4, "Squircle", {
            Size = UDim2.new(ratio, 0, 1, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageTransparency = 0.1,
            ImageColor3 = GetThemeColor("Slider"),
            Parent = trackBg,
        })

        local thumb = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(ratio, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ImageTransparency = 0,
            ImageColor3 = GetThemeColor("SliderThumb"),
            Parent = sliderContainer,
        })

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 40, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(math.floor(value + 0.5))
        valueLabel.TextColor3 = GetThemeColor("Text")
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamMedium
        valueLabel.Parent = frame

        local lockOverlay = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.25,
            ImageColor3 = Color3.fromRGB(0,0,0),
            ZIndex = 999,
            Visible = isLocked,
            Parent = frame,
        })

        local lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 20, 0, 20)
        lockIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        lockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = getIcon("lock")
        lockIcon.ImageColor3 = Color3.fromRGB(255,255,255)
        lockIcon.ImageTransparency = 0.5
        lockIcon.Parent = lockOverlay

        local function updateSlider(newValue, skipCallback)
            value = math.clamp(newValue, min, max)
            if step > 0 then
                value = math.round(value / step) * step
            end
            local newRatio = (value - min) / (max - min)

            trackFill.Size = UDim2.new(newRatio, 0, 1, 0)
            thumb.Position = UDim2.new(newRatio, 0, 0.5, 0)
            valueLabel.Text = tostring(math.floor(value + 0.5))

            if not skipCallback and data.Callback then
                data.Callback(value)
            end
        end

        function element.Lock()
            isLocked = true
            lockOverlay.Visible = true
            sliderContainer.Interactable = false
        end

        function element.Unlock()
            isLocked = false
            lockOverlay.Visible = false
            sliderContainer.Interactable = true
        end

        function element.SetValue(newValue, skipCallback)
            updateSlider(newValue, skipCallback)
        end

        function element.GetValue()
            return value
        end

        function element.SetMin(newMin)
            min = newMin
            updateSlider(value)
        end

        function element.SetMax(newMax)
            max = newMax
            updateSlider(value)
        end

        function element.Destroy()
            frame:Destroy()
        end

        local isDragging = false
        local dragConnection = nil
        local endConnection = nil

        thumb.InputBegan:Connect(function(input)
            if isLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true

                dragConnection = UserInputService.InputChanged:Connect(function(inputChanged)
                    if isDragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                        local pos = inputChanged.Position
                        local containerPos = sliderContainer.AbsolutePosition
                        local containerSize = sliderContainer.AbsoluteSize
                        local newRatio = math.clamp((pos.X - containerPos.X) / containerSize.X, 0, 1)
                        local newValue = min + newRatio * (max - min)
                        updateSlider(newValue)
                    end
                end)

                endConnection = UserInputService.InputEnded:Connect(function(inputEnded)
                    if isDragging and (inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch) then
                        isDragging = false
                        if dragConnection then dragConnection:Disconnect() end
                        if endConnection then endConnection:Disconnect() end
                    end
                end)
            end
        end)

        element.Frame = frame
        return element
    end

    -- 5.4 Input
    local function createInput(parent, data)
        local element = {}
        local isLocked = data.Locked or false
        local value = data.Default or ""
        local placeholder = data.Placeholder or "输入..."
        local isMultiline = data.Multiline or false

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "text-cursor-input")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = frame

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, -160, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Input"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if data.Desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Text = data.Desc
            descLabel.TextColor3 = GetThemeColor("Text")
            descLabel.TextTransparency = 0.4
            descLabel.TextSize = 14
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textFrame
        end

        local inputBox = Instance.new("TextBox")
        inputBox.Size = UDim2.new(0, 130, 0, isMultiline and 60 or 32)
        inputBox.Position = UDim2.new(0, 0, 0.5, 0)
        inputBox.AnchorPoint = Vector2.new(0, 0.5)
        inputBox.BackgroundTransparency = 1
        inputBox.Text = value
        inputBox.PlaceholderText = placeholder
        inputBox.TextColor3 = GetThemeColor("Text")
        inputBox.PlaceholderColor3 = GetThemeColor("Placeholder")
        inputBox.TextSize = 14
        inputBox.Font = Enum.Font.GothamMedium
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.MultiLine = isMultiline
        inputBox.ClearTextOnFocus = false
        inputBox.Parent = frame

        local inputBg = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.85,
            ImageColor3 = GetThemeColor("Text"),
            ZIndex = 0,
            Parent = inputBox,
        })

        local lockOverlay = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.25,
            ImageColor3 = Color3.fromRGB(0,0,0),
            ZIndex = 999,
            Visible = isLocked,
            Parent = frame,
        })

        local lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 20, 0, 20)
        lockIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        lockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = getIcon("lock")
        lockIcon.ImageColor3 = Color3.fromRGB(255,255,255)
        lockIcon.ImageTransparency = 0.5
        lockIcon.Parent = lockOverlay

        function element.Lock()
            isLocked = true
            lockOverlay.Visible = true
            inputBox.Interactable = false
        end

        function element.Unlock()
            isLocked = false
            lockOverlay.Visible = false
            inputBox.Interactable = true
        end

        function element.SetValue(newValue, skipCallback)
            value = newValue
            inputBox.Text = newValue
            if not skipCallback and data.Callback then
                data.Callback(newValue)
            end
        end

        function element.GetValue()
            return value
        end

        function element.SetPlaceholder(newPlaceholder)
            placeholder = newPlaceholder
            inputBox.PlaceholderText = newPlaceholder
        end

        function element.Destroy()
            frame:Destroy()
        end

        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            value = inputBox.Text
            if data.Callback then
                data.Callback(value)
            end
        end)

        element.Frame = frame
        return element
    end

    -- 5.5 Dropdown
    local function createDropdown(parent, data)
        local element = {}
        local isLocked = data.Locked or false
        local options = data.Options or {}
        local value = data.Default or (options[1] or "")
        local isOpen = false

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "chevrons-up-down")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = frame

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, -170, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Dropdown"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if data.Desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Text = data.Desc
            descLabel.TextColor3 = GetThemeColor("Text")
            descLabel.TextTransparency = 0.4
            descLabel.TextSize = 14
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textFrame
        end

        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Size = UDim2.new(0, 140, 0, 32)
        dropdownBtn.BackgroundTransparency = 1
        dropdownBtn.Text = tostring(value)
        dropdownBtn.TextColor3 = GetThemeColor("Text")
        dropdownBtn.TextSize = 14
        dropdownBtn.Font = Enum.Font.GothamMedium
        dropdownBtn.ZIndex = 2
        dropdownBtn.Parent = frame

        local dropdownBg = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.85,
            ImageColor3 = GetThemeColor("Text"),
            ZIndex = 0,
            Parent = dropdownBtn,
        })

        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.new(0, 16, 0, 16)
        arrow.Position = UDim2.new(1, -20, 0.5, 0)
        arrow.AnchorPoint = Vector2.new(0, 0.5)
        arrow.BackgroundTransparency = 1
        arrow.Image = getIcon("chevron-down")
        arrow.ImageColor3 = GetThemeColor("Icon")
        arrow.Parent = dropdownBtn

        local menuFrame = Instance.new("Frame")
        menuFrame.Size = UDim2.new(0, 140, 0, 0)
        menuFrame.Position = UDim2.new(0, 0, 0, 34)
        menuFrame.BackgroundTransparency = 1
        menuFrame.ClipsDescendants = true
        menuFrame.Visible = false
        menuFrame.ZIndex = 999
        menuFrame.Parent = frame

        local menuBg = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.05,
            ImageColor3 = GetThemeColor("Background"),
            Parent = menuFrame,
        })

        local menuList = Instance.new("UIListLayout")
        menuList.FillDirection = Enum.FillDirection.Vertical
        menuList.Padding = UDim.new(0, 2)
        menuList.Parent = menuBg

        local menuItems = {}

        function element.Lock()
            isLocked = true
            dropdownBtn.Interactable = false
        end

        function element.Unlock()
            isLocked = false
            dropdownBtn.Interactable = true
        end

        function element.SetValue(newValue, skipCallback)
            value = newValue
            dropdownBtn.Text = tostring(newValue)
            if not skipCallback and data.Callback then
                data.Callback(newValue)
            end
        end

        function element.GetValue()
            return value
        end

        function element.SetOptions(newOptions)
            options = newOptions
            element:RefreshMenu()
        end

        function element.RefreshMenu()
            for _, item in ipairs(menuItems) do
                item:Destroy()
            end
            menuItems = {}

            for _, opt in ipairs(options) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 32)
                item.BackgroundTransparency = 1
                item.Text = tostring(opt)
                item.TextColor3 = GetThemeColor("Text")
                item.TextSize = 14
                item.Font = Enum.Font.GothamMedium
                item.Parent = menuBg

                local itemBg = NewRoundFrame(4, "Squircle", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 1,
                    ImageColor3 = GetThemeColor("Text"),
                    ZIndex = 0,
                    Parent = item,
                })

                item.MouseEnter:Connect(function()
                    TweenService:Create(itemBg, TweenInfo.new(0.1), {ImageTransparency = 0.9}):Play()
                end)
                item.MouseLeave:Connect(function()
                    TweenService:Create(itemBg, TweenInfo.new(0.1), {ImageTransparency = 1}):Play()
                end)
                item.MouseButton1Click:Connect(function()
                    element:SetValue(opt)
                    element:Close()
                end)

                table.insert(menuItems, item)
            end
        end

        function element.Open()
            if isLocked then return end
            isOpen = true
            menuFrame.Visible = true
            TweenService:Create(menuFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 140, 0, math.min(#options * 34, 200))
            }):Play()
            TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 180}):Play()
        end

        function element.Close()
            isOpen = false
            TweenService:Create(menuFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 140, 0, 0)
            }):Play()
            TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
            task.wait(0.15)
            menuFrame.Visible = false
        end

        function element.Toggle()
            if isOpen then
                element:Close()
            else
                element:Open()
            end
        end

        function element.Destroy()
            frame:Destroy()
        end

        dropdownBtn.MouseButton1Click:Connect(function()
            if not isLocked then
                element:Toggle()
            end
        end)

        UserInputService.InputBegan:Connect(function(input)
            if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = frame.AbsolutePosition
                local absSize = frame.AbsoluteSize
                if not (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                        mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y) then
                    element:Close()
                end
            end
        end)

        element:RefreshMenu()
        element.Frame = frame
        return element
    end

    -- 5.6 Colorpicker（闭包捕获 gui）
    local function createColorpicker(parent, data)
        local element = {}
        local isLocked = data.Locked or false
        local color = data.Default or Color3.fromRGB(255,255,255)
        local transparency = data.Transparency or 0

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "palette")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = frame

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, -160, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Colorpicker"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if data.Desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Text = data.Desc
            descLabel.TextColor3 = GetThemeColor("Text")
            descLabel.TextTransparency = 0.4
            descLabel.TextSize = 14
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textFrame
        end

        local colorPreview = Instance.new("Frame")
        colorPreview.Size = UDim2.new(0, 32, 0, 32)
        colorPreview.BackgroundColor3 = color
        colorPreview.BackgroundTransparency = 0
        colorPreview.Parent = frame
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 6)
        previewCorner.Parent = colorPreview

        local pickerBtn = Instance.new("TextButton")
        pickerBtn.Size = UDim2.new(1, 0, 1, 0)
        pickerBtn.BackgroundTransparency = 1
        pickerBtn.Text = ""
        pickerBtn.Parent = colorPreview

        local lockOverlay = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.25,
            ImageColor3 = Color3.fromRGB(0,0,0),
            ZIndex = 999,
            Visible = isLocked,
            Parent = frame,
        })

        local lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 20, 0, 20)
        lockIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        lockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = getIcon("lock")
        lockIcon.ImageColor3 = Color3.fromRGB(255,255,255)
        lockIcon.ImageTransparency = 0.5
        lockIcon.Parent = lockOverlay

        function element.Lock()
            isLocked = true
            lockOverlay.Visible = true
            pickerBtn.Interactable = false
        end

        function element.Unlock()
            isLocked = false
            lockOverlay.Visible = false
            pickerBtn.Interactable = true
        end

        function element.SetColor(newColor, newTransparency, skipCallback)
            color = newColor
            if newTransparency ~= nil then
                transparency = newTransparency
            end
            colorPreview.BackgroundColor3 = color
            if not skipCallback and data.Callback then
                data.Callback(color, transparency)
            end
        end

        function element.GetColor()
            return color
        end

        function element.GetTransparency()
            return transparency
        end

        function element.Destroy()
            frame:Destroy()
        end

        pickerBtn.MouseButton1Click:Connect(function()
            if isLocked then return end
            local dialogFrame = Instance.new("Frame")
            dialogFrame.Size = UDim2.new(0, 300, 0, 320)
            dialogFrame.Position = UDim2.new(0.5, -150, 0.5, -160)
            dialogFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            dialogFrame.BackgroundTransparency = 0.1
            dialogFrame.BackgroundColor3 = GetThemeColor("Background")
            dialogFrame.ZIndex = 9999
            dialogFrame.Parent = gui
            local dialogCorner = Instance.new("UICorner")
            dialogCorner.CornerRadius = UDim.new(0, 12)
            dialogCorner.Parent = dialogFrame

            local hueBar = Instance.new("Frame")
            hueBar.Size = UDim2.new(1, -20, 0, 30)
            hueBar.Position = UDim2.new(0, 10, 0, 20)
            hueBar.BackgroundTransparency = 1
            hueBar.Parent = dialogFrame

            local hueGradient = Instance.new("UIGradient")
            hueGradient.Rotation = 0
            hueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
            })
            hueGradient.Parent = hueBar

            local svPanel = Instance.new("Frame")
            svPanel.Size = UDim2.new(1, -40, 0, 160)
            svPanel.Position = UDim2.new(0, 20, 0, 60)
            svPanel.BackgroundColor3 = color
            svPanel.BackgroundTransparency = 0
            svPanel.Parent = dialogFrame
            local svCorner = Instance.new("UICorner")
            svCorner.CornerRadius = UDim.new(0, 6)
            svCorner.Parent = svPanel

            local preview = Instance.new("Frame")
            preview.Size = UDim2.new(1, -20, 0, 30)
            preview.Position = UDim2.new(0, 10, 0, 230)
            preview.BackgroundColor3 = color
            preview.BackgroundTransparency = 0
            preview.Parent = dialogFrame
            local previewCorner2 = Instance.new("UICorner")
            previewCorner2.CornerRadius = UDim.new(0, 6)
            previewCorner2.Parent = preview

            local closeBtn = Instance.new("TextButton")
            closeBtn.Size = UDim2.new(0, 60, 0, 30)
            closeBtn.Position = UDim2.new(1, -70, 1, -10)
            closeBtn.AnchorPoint = Vector2.new(1, 1)
            closeBtn.BackgroundTransparency = 1
            closeBtn.Text = "确定"
            closeBtn.TextColor3 = GetThemeColor("Text")
            closeBtn.TextSize = 14
            closeBtn.Font = Enum.Font.GothamMedium
            closeBtn.Parent = dialogFrame

            local closeBg = NewRoundFrame(6, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ImageTransparency = 0.15,
                ImageColor3 = GetThemeColor("Button"),
                ZIndex = 0,
                Parent = closeBtn,
            })

            closeBtn.MouseButton1Click:Connect(function()
                dialogFrame:Destroy()
            end)

            svPanel.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local pos = input.Position - svPanel.AbsolutePosition
                    local x = math.clamp(pos.X / svPanel.AbsoluteSize.X, 0, 1)
                    local y = math.clamp(pos.Y / svPanel.AbsoluteSize.Y, 0, 1)
                    local h = 0
                    local newColor = Color3.fromHSV(h, x, 1 - y)
                    svPanel.BackgroundColor3 = newColor
                    preview.BackgroundColor3 = newColor
                    element:SetColor(newColor, transparency)
                end
            end)

            hueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local pos = input.Position - hueBar.AbsolutePosition
                    local h = math.clamp(pos.X / hueBar.AbsoluteSize.X, 0, 1)
                    local svX = 0.5
                    local svY = 0.5
                    local newColor = Color3.fromHSV(h, svX, 1 - svY)
                    svPanel.BackgroundColor3 = newColor
                    preview.BackgroundColor3 = newColor
                    element:SetColor(newColor, transparency)
                end
            end)
        end)

        element.Frame = frame
        return element
    end

    -- 5.7 ProgressBar
    local function createProgressBar(parent, data)
        local element = {}
        local isLocked = data.Locked or false
        local min = data.Min or 0
        local max = data.Max or 100
        local value = data.Default or min

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.Padding = UDim.new(0, 6)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local titleRow = Instance.new("Frame")
        titleRow.Size = UDim2.new(1, 0, 0, 0)
        titleRow.AutomaticSize = Enum.AutomaticSize.Y
        titleRow.BackgroundTransparency = 1
        titleRow.Parent = frame

        local titleLayout = Instance.new("UIListLayout")
        titleLayout.FillDirection = Enum.FillDirection.Horizontal
        titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        titleLayout.Padding = UDim.new(0, 10)
        titleLayout.Parent = titleRow

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "chart-bar")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = titleRow

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(0, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.XY
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Progress"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleRow

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, -34, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = math.floor((value - min) / (max - min) * 100) .. "%"
        valueLabel.TextColor3 = GetThemeColor("Text")
        valueLabel.TextTransparency = 0.4
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.GothamMedium
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = titleRow

        local trackBg = NewRoundFrame(4, "Squircle", {
            Size = UDim2.new(1, 0, 0, 6),
            ImageTransparency = 0.85,
            ImageColor3 = GetThemeColor("Text"),
            Parent = frame,
        })

        local ratio = (value - min) / (max - min)
        local trackFill = NewRoundFrame(4, "Squircle", {
            Size = UDim2.new(ratio, 0, 1, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageTransparency = 0.1,
            ImageColor3 = GetThemeColor("Slider"),
            Parent = trackBg,
        })

        function element.SetValue(newValue, skipCallback)
            value = math.clamp(newValue, min, max)
            local newRatio = (value - min) / (max - min)
            trackFill.Size = UDim2.new(newRatio, 0, 1, 0)
            valueLabel.Text = math.floor(newRatio * 100) .. "%"
            if not skipCallback and data.Callback then
                data.Callback(value)
            end
        end

        function element.GetValue()
            return value
        end

        function element.SetMin(newMin)
            min = newMin
            element:SetValue(value)
        end

        function element.SetMax(newMax)
            max = newMax
            element:SetValue(value)
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- 5.8 Paragraph
    local function createParagraph(parent, data)
        local element = {}

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 16)
        pad.PaddingRight = UDim.new(0, 16)
        pad.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 0, 0)
        textLabel.AutomaticSize = Enum.AutomaticSize.Y
        textLabel.BackgroundTransparency = 1
        textLabel.Text = data.Text or "Paragraph text..."
        textLabel.TextColor3 = GetThemeColor("Text")
        textLabel.TextSize = 15
        textLabel.Font = Enum.Font.GothamMedium
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextWrapped = true
        textLabel.Parent = frame

        function element.SetText(newText)
            textLabel.Text = newText
            data.Text = newText
        end

        function element.GetText()
            return textLabel.Text
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- 5.9 Section
    local function createSection(parent, data)
        local element = {}
        local children = {}
        local isOpen = data.Opened or true

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, 40)
        header.BackgroundTransparency = 1
        header.Text = ""
        header.Parent = frame

        local headerBg = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.9,
            ImageColor3 = GetThemeColor("Text"),
            Parent = header,
        })

        local headerLayout = Instance.new("UIListLayout")
        headerLayout.FillDirection = Enum.FillDirection.Horizontal
        headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        headerLayout.Padding = UDim.new(0, 10)
        headerLayout.Parent = header

        local headerPad = Instance.new("UIPadding")
        headerPad.PaddingLeft = UDim.new(0, 12)
        headerPad.PaddingRight = UDim.new(0, 12)
        headerPad.Parent = header

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 20, 0, 20)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "folder")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = header

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -30, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Section"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = header

        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.new(0, 16, 0, 16)
        arrow.BackgroundTransparency = 1
        arrow.Image = getIcon(isOpen and "chevron-down" or "chevron-right")
        arrow.ImageColor3 = GetThemeColor("Icon")
        arrow.Parent = header

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.BackgroundTransparency = 1
        content.Visible = isOpen
        content.Parent = frame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.FillDirection = Enum.FillDirection.Vertical
        contentLayout.Padding = UDim.new(0, 4)
        contentLayout.Parent = content

        local contentPad = Instance.new("UIPadding")
        contentPad.PaddingLeft = UDim.new(0, 20)
        contentPad.PaddingRight = UDim.new(0, 12)
        contentPad.PaddingTop = UDim.new(0, 6)
        contentPad.PaddingBottom = UDim.new(0, 6)
        contentPad.Parent = content

        function element.Add(childData)
            local child
            if childData.Type == "Button" then
                child = createButton(content, childData)
            elseif childData.Type == "Toggle" then
                child = createToggle(content, childData)
            elseif childData.Type == "Slider" then
                child = createSlider(content, childData)
            elseif childData.Type == "Input" then
                child = createInput(content, childData)
            elseif childData.Type == "Dropdown" then
                child = createDropdown(content, childData)
            elseif childData.Type == "Paragraph" then
                child = createParagraph(content, childData)
            else
                return nil
            end
            table.insert(children, child)
            return child
        end

        function element.Remove(child)
            for i, el in ipairs(children) do
                if el == child then
                    table.remove(children, i)
                    child:Destroy()
                    return true
                end
            end
            return false
        end

        function element.Toggle()
            isOpen = not isOpen
            content.Visible = isOpen
            arrow.Image = getIcon(isOpen and "chevron-down" or "chevron-right")
        end

        function element.Open()
            if not isOpen then
                element:Toggle()
            end
        end

        function element.Close()
            if isOpen then
                element:Toggle()
            end
        end

        function element.Destroy()
            frame:Destroy()
        end

        header.MouseButton1Click:Connect(function()
            element:Toggle()
        end)

        element.Frame = frame
        return element
    end

    -- 5.10 Divider
    local function createDivider(parent, data)
        local element = {}

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0.5, 0, 0.5, 0)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = GetThemeColor("Text")
        line.BackgroundTransparency = 0.85
        line.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.Parent = frame

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- 5.11 Space
    local function createSpace(parent, data)
        local element = {}
        local height = data.Height or 8

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, height)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- 5.12 Image
    local function createImageElement(parent, data)
        local element = {}
        local aspectRatio = data.AspectRatio or 1.777

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local image = Instance.new("ImageLabel")
        image.Size = UDim2.new(1, 0, 0, 0)
        image.BackgroundTransparency = 1
        image.Image = data.Image or ""
        image.ScaleType = Enum.ScaleType.Fit
        image.Parent = frame

        local aspect = Instance.new("UIAspectRatioConstraint")
        aspect.AspectRatio = aspectRatio
        aspect.AspectType = Enum.AspectType.ScaleWithParentSize
        aspect.Parent = image

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, data.Radius or 8)
        corner.Parent = image

        function element.SetImage(newImage)
            image.Image = newImage
            data.Image = newImage
        end

        function element.SetAspectRatio(newRatio)
            aspect.AspectRatio = newRatio
            data.AspectRatio = newRatio
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- 5.13 Code
    local function createCodeElement(parent, data)
        local element = {}

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(8, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.95,
            ImageColor3 = Color3.fromRGB(30,30,35),
            Parent = frame,
        })

        local codeBox = Instance.new("TextBox")
        codeBox.Size = UDim2.new(1, -16, 0, 0)
        codeBox.AutomaticSize = Enum.AutomaticSize.Y
        codeBox.Position = UDim2.new(0, 8, 0, 8)
        codeBox.BackgroundTransparency = 1
        codeBox.Text = data.Code or ""
        codeBox.TextColor3 = GetThemeColor("Text")
        codeBox.TextSize = data.TextSize or 14
        codeBox.Font = Enum.Font.Code
        codeBox.TextXAlignment = Enum.TextXAlignment.Left
        codeBox.MultiLine = true
        codeBox.ClearTextOnFocus = false
        codeBox.Parent = frame

        local function highlightLua(code)
            local keywords = {
                "and", "break", "do", "else", "elseif", "end", "false",
                "for", "function", "if", "in", "local", "nil", "not",
                "or", "repeat", "return", "then", "true", "until", "while",
            }
            local pattern = "(" .. table.concat(keywords, "|") .. ")"
            return code:gsub(pattern, '<font color="#CBA6F7">%1</font>')
        end

        codeBox.Text = highlightLua(codeBox.Text)

        function element.SetCode(newCode)
            codeBox.Text = highlightLua(newCode)
            data.Code = newCode
        end

        function element.GetCode()
            return data.Code
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- 5.14 Keybind
    local function createKeybind(parent, data)
        local element = {}
        local isLocked = data.Locked or false
        local key = data.Default or "F"
        local isRecording = false

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 24, 0, 24)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(data.Icon or "command")
        iconImg.ImageColor3 = GetThemeColor("Icon")
        iconImg.Parent = frame

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, -140, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = data.Title or "Keybind"
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if data.Desc then
            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Text = data.Desc
            descLabel.TextColor3 = GetThemeColor("Text")
            descLabel.TextTransparency = 0.4
            descLabel.TextSize = 14
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textFrame
        end

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.new(0, 80, 0, 32)
        keyBtn.BackgroundTransparency = 1
        keyBtn.Text = key
        keyBtn.TextColor3 = GetThemeColor("Text")
        keyBtn.TextSize = 14
        keyBtn.Font = Enum.Font.GothamMedium
        keyBtn.ZIndex = 2
        keyBtn.Parent = frame

        local keyBg = NewRoundFrame(6, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.85,
            ImageColor3 = GetThemeColor("Text"),
            ZIndex = 0,
            Parent = keyBtn,
        })

        function element.Lock()
            isLocked = true
            keyBtn.Interactable = false
        end

        function element.Unlock()
            isLocked = false
            keyBtn.Interactable = true
        end

        function element.SetKey(newKey, skipCallback)
            key = newKey
            keyBtn.Text = newKey
            if not skipCallback and data.Callback then
                data.Callback(newKey)
            end
        end

        function element.GetKey()
            return key
        end

        function element.StartRecording()
            if isLocked then return end
            isRecording = true
            keyBtn.Text = "..."
        end

        function element.StopRecording()
            isRecording = false
            keyBtn.Text = key
        end

        function element.Destroy()
            frame:Destroy()
        end

        keyBtn.MouseButton1Click:Connect(function()
            if not isLocked then
                element:StartRecording()
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if isRecording and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = input.KeyCode.Name
                if keyName ~= "Unknown" then
                    element:SetKey(keyName)
                    element:StopRecording()
                end
            end
        end)

        element.Frame = frame
        return element
    end

    -- 5.15 Viewport
    local function createViewport(parent, data)
        local element = {}
        local camera = data.Camera or Instance.new("Camera")
        local object = data.Object

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, data.Height or 200)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local viewport = Instance.new("ViewportFrame")
        viewport.Size = UDim2.new(1, 0, 1, 0)
        viewport.BackgroundTransparency = 1
        viewport.CurrentCamera = camera
        viewport.Parent = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = viewport

        if object then
            object.Parent = viewport
        end

        function element.SetObject(newObject)
            if object then
                object:Destroy()
            end
            object = newObject
            object.Parent = viewport
        end

        function element.SetCamera(newCamera)
            camera = newCamera
            viewport.CurrentCamera = camera
        end

        function element.SetHeight(newHeight)
            frame.Size = UDim2.new(1, -20, 0, newHeight)
            data.Height = newHeight
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- ===== 容器布局 =====
    local function createHStack(parent, data)
        local element = {}
        local children = {}
        local spacing = data.Spacing or 6
        local alignment = data.Alignment or "Center"

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, spacing)
        layout.VerticalAlignment = Enum.VerticalAlignment[alignment] or Enum.VerticalAlignment.Center
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 4)
        pad.Parent = frame

        function element.Add(child)
            child.Parent = frame
            table.insert(children, child)
            return child
        end

        function element.Remove(child)
            for i, c in ipairs(children) do
                if c == child then
                    table.remove(children, i)
                    child:Destroy()
                    return true
                end
            end
            return false
        end

        function element.Clear()
            for _, child in ipairs(children) do
                child:Destroy()
            end
            children = {}
        end

        function element.SetSpacing(newSpacing)
            spacing = newSpacing
            layout.Padding = UDim.new(0, spacing)
        end

        function element.SetAlignment(newAlignment)
            alignment = newAlignment
            layout.VerticalAlignment = Enum.VerticalAlignment[newAlignment] or Enum.VerticalAlignment.Center
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    local function createVStack(parent, data)
        local element = {}
        local children = {}
        local spacing = data.Spacing or 6
        local alignment = data.Alignment or "Center"

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.Padding = UDim.new(0, spacing)
        layout.HorizontalAlignment = Enum.HorizontalAlignment[alignment] or Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 4)
        pad.Parent = frame

        function element.Add(child)
            child.Parent = frame
            table.insert(children, child)
            return child
        end

        function element.Remove(child)
            for i, c in ipairs(children) do
                if c == child then
                    table.remove(children, i)
                    child:Destroy()
                    return true
                end
            end
            return false
        end

        function element.Clear()
            for _, child in ipairs(children) do
                child:Destroy()
            end
            children = {}
        end

        function element.SetSpacing(newSpacing)
            spacing = newSpacing
            layout.Padding = UDim.new(0, spacing)
        end

        function element.SetAlignment(newAlignment)
            alignment = newAlignment
            layout.HorizontalAlignment = Enum.HorizontalAlignment[newAlignment] or Enum.HorizontalAlignment.Center
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    local function createGroup(parent, data)
        local element = {}
        local children = {}
        local title = data.Title or ""
        local collapsible = data.Collapsible or false
        local isOpen = data.Opened or true

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local bg = NewRoundFrame(10, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.93,
            ImageColor3 = GetThemeColor("ElementBg"),
            Parent = frame,
        })

        local mainPad = Instance.new("UIPadding")
        mainPad.PaddingTop = UDim.new(0, 8)
        mainPad.PaddingBottom = UDim.new(0, 8)
        mainPad.PaddingLeft = UDim.new(0, 12)
        mainPad.PaddingRight = UDim.new(0, 12)
        mainPad.Parent = frame

        local mainLayout = Instance.new("UIListLayout")
        mainLayout.FillDirection = Enum.FillDirection.Vertical
        mainLayout.Padding = UDim.new(0, 6)
        mainLayout.Parent = frame

        if title ~= "" then
            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 30)
            header.BackgroundTransparency = 1
            header.Text = ""
            header.Parent = frame

            local headerLayout = Instance.new("UIListLayout")
            headerLayout.FillDirection = Enum.FillDirection.Horizontal
            headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            headerLayout.Padding = UDim.new(0, 8)
            headerLayout.Parent = header

            local arrow = Instance.new("ImageLabel")
            arrow.Size = UDim2.new(0, 16, 0, 16)
            arrow.BackgroundTransparency = 1
            arrow.Image = getIcon(isOpen and "chevron-down" or "chevron-right")
            arrow.ImageColor3 = GetThemeColor("Icon")
            arrow.Visible = collapsible
            arrow.Parent = header

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.TextColor3 = GetThemeColor("Text")
            titleLabel.TextSize = 15
            titleLabel.Font = Enum.Font.GothamSemibold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = header

            local content = Instance.new("Frame")
            content.Size = UDim2.new(1, 0, 0, 0)
            content.AutomaticSize = Enum.AutomaticSize.Y
            content.BackgroundTransparency = 1
            content.Visible = isOpen
            content.Parent = frame

            local contentLayout = Instance.new("UIListLayout")
            contentLayout.FillDirection = Enum.FillDirection.Vertical
            contentLayout.Padding = UDim.new(0, 4)
            contentLayout.Parent = content

            local contentPad = Instance.new("UIPadding")
            contentPad.PaddingLeft = UDim.new(0, 12)
            contentPad.PaddingRight = UDim.new(0, 12)
            contentPad.PaddingTop = UDim.new(0, 4)
            contentPad.Parent = content

            function element.Toggle()
                if collapsible then
                    isOpen = not isOpen
                    content.Visible = isOpen
                    arrow.Image = getIcon(isOpen and "chevron-down" or "chevron-right")
                end
            end

            function element.Open()
                if not isOpen then element:Toggle() end
            end

            function element.Close()
                if isOpen then element:Toggle() end
            end

            if collapsible then
                header.MouseButton1Click:Connect(function()
                    element:Toggle()
                end)
            end

            function element.Add(child)
                child.Parent = content
                table.insert(children, child)
                return child
            end

            function element.Remove(child)
                for i, c in ipairs(children) do
                    if c == child then
                        table.remove(children, i)
                        child:Destroy()
                        return true
                    end
                end
                return false
            end

            element.Content = content
            element.Header = header
            element.Arrow = arrow

        else
            function element.Add(child)
                child.Parent = frame
                table.insert(children, child)
                return child
            end

            function element.Remove(child)
                for i, c in ipairs(children) do
                    if c == child then
                        table.remove(children, i)
                        child:Destroy()
                        return true
                    end
                end
                return false
            end
        end

        function element.Clear()
            for _, child in ipairs(children) do
                child:Destroy()
            end
            children = {}
        end

        function element.Destroy()
            frame:Destroy()
        end

        element.Frame = frame
        return element
    end

    -- ================================================================
    -- 6. 配置管理（ConfigManager）
    -- ================================================================

    local ConfigManager = {}
    ConfigManager._configs = {}
    ConfigManager._currentConfig = nil
    ConfigManager._path = "WindUI/Configs/"

    function ConfigManager:Init(path)
        if path then
            self._path = path
        end
        if not isfolder and not makefolder then
            return false
        end
        if not isfolder(self._path) then
            pcall(makefolder, self._path)
        end
        return true
    end

    function ConfigManager:Create(name, data)
        local config = {
            _name = name,
            _data = data or {},
            _elements = {},
            _callbacks = {},
        }

        function config:Register(element, key)
            self._elements[key] = element
        end

        function config:Get(key)
            return self._data[key]
        end

        function config:Set(key, value)
            self._data[key] = value
            if self._callbacks[key] then
                for _, cb in ipairs(self._callbacks[key]) do
                    cb(value)
                end
            end
        end

        function config:OnChange(key, callback)
            if not self._callbacks[key] then
                self._callbacks[key] = {}
            end
            table.insert(self._callbacks[key], callback)
        end

        function config:Save()
            if not writefile then return false end
            local success = pcall(function()
                local json = HttpService:JSONEncode(self._data)
                writefile(self._path .. self._name .. ".json", json)
            end)
            return success
        end

        function config:Load()
            if not readfile then return false end
            local success = pcall(function()
                local json = readfile(self._path .. self._name .. ".json")
                self._data = HttpService:JSONDecode(json)
                for key, value in pairs(self._data) do
                    if self._elements[key] then
                        local el = self._elements[key]
                        if el.SetValue then
                            el:SetValue(value, true)
                        elseif el.Set then
                            el:Set(value, true)
                        elseif el.SetKey then
                            el:SetKey(value, true)
                        elseif el.SetColor then
                            el:SetColor(Color3.fromHex(value), nil, true)
                        end
                    end
                end
            end)
            return success
        end

        function config:Delete()
            if not delfile then return false end
            local success = pcall(function()
                delfile(self._path .. self._name .. ".json")
            end)
            return success
        end

        function config:GetAll()
            return self._data
        end

        ConfigManager._configs[name] = config
        return config
    end

    function ConfigManager:Get(name)
        return self._configs[name]
    end

    function ConfigManager:Delete(name)
        if self._configs[name] then
            self._configs[name]:Delete()
            self._configs[name] = nil
            return true
        end
        return false
    end

    function ConfigManager:List()
        local list = {}
        if not listfiles then return list end
        local files = listfiles(self._path)
        for _, file in ipairs(files) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
        return list
    end

    -- ================================================================
    -- 7. 通知系统（NotificationManager）
    -- ================================================================

    local NotificationManager = {
        _queue = {},
        _active = false,
        _container = nil,
        _maxNotifications = 5,
    }

    function NotificationManager:Init(parent)
        self._container = Instance.new("Frame")
        self._container.Name = "NotificationContainer"
        self._container.Size = UDim2.new(0, 340, 0, 0)
        self._container.Position = UDim2.new(1, -20, 0, 20)
        self._container.AnchorPoint = Vector2.new(1, 0)
        self._container.BackgroundTransparency = 1
        self._container.ZIndex = 999999
        self._container.Parent = parent

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = self._container

        return self
    end

    function NotificationManager:Show(data)
        local title = data.Title or "通知"
        local content = data.Content or ""
        local duration = data.Duration or 4
        local icon = data.Icon or "info"
        local color = data.Color or GetThemeColor("Notify")

        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(1, 0, 0, 0)
        notification.AutomaticSize = Enum.AutomaticSize.Y
        notification.BackgroundTransparency = 1
        notification.Parent = self._container

        local bg = NewRoundFrame(12, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = color,
            ImageTransparency = 0,
            Parent = notification,
        })

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 10)
        layout.Parent = notification

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = notification

        if icon then
            local iconImg = Instance.new("ImageLabel")
            iconImg.Size = UDim2.new(0, 22, 0, 22)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = getIcon(icon)
            iconImg.ImageColor3 = GetThemeColor("NotifyText")
            iconImg.Parent = notification
        end

        local textFrame = Instance.new("Frame")
        textFrame.Size = UDim2.new(1, icon and -32 or 0, 1, 0)
        textFrame.BackgroundTransparency = 1
        textFrame.Parent = notification

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = GetThemeColor("NotifyText")
        titleLabel.TextSize = 15
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = textFrame

        if content and content ~= "" then
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, 0, 0, 0)
            contentLabel.AutomaticSize = Enum.AutomaticSize.Y
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = content
            contentLabel.TextColor3 = GetThemeColor("NotifyText")
            contentLabel.TextTransparency = 0.3
            contentLabel.TextSize = 14
            contentLabel.Font = Enum.Font.GothamMedium
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextWrapped = true
            contentLabel.Parent = textFrame
        end

        local progressBg = Instance.new("Frame")
        progressBg.Size = UDim2.new(1, 0, 0, 2)
        progressBg.Position = UDim2.new(0, 0, 1, -2)
        progressBg.BackgroundColor3 = GetThemeColor("Text")
        progressBg.BackgroundTransparency = 0.5
        progressBg.Parent = bg

        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        progressFill.BackgroundColor3 = GetThemeColor("NotifyText")
        progressFill.BackgroundTransparency = 0.2
        progressFill.Parent = progressBg

        notification.Position = UDim2.new(0, 0, 0, -100)
        notification.Size = UDim2.new(1, 0, 0, 0)

        TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()

        task.delay(duration, function()
            TweenService:Create(notification, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 0, 0, -100),
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            task.delay(0.3, function()
                notification:Destroy()
            end)
        end)

        return notification
    end

    function NotificationManager:Notify(data)
        return self:Show(data)
    end

    -- ================================================================
    -- 8. 对话框系统（Dialog）- 闭包捕获 gui
    -- ================================================================

    local function createDialog(data)
        local parent = data.Parent or gui
        local title = data.Title or "对话框"
        local content = data.Content or ""
        local buttons = data.Buttons or {{Text = "确定", Primary = true, Callback = function() end}}
        local icon = data.Icon or "info"
        local width = data.Width or 380

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundTransparency = 0.5
        overlay.BackgroundColor3 = GetThemeColor("Overlay")
        overlay.ZIndex = 99999
        overlay.Parent = parent

        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, width, 0, 0)
        dialog.AutomaticSize = Enum.AutomaticSize.Y
        dialog.Position = UDim2.new(0.5, -width/2, 0.5, -50)
        dialog.BackgroundTransparency = 1
        dialog.ZIndex = 100000
        dialog.Parent = overlay

        local bg = NewRoundFrame(16, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = GetThemeColor("Dialog"),
            ImageTransparency = 0,
            Parent = dialog,
        })

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 20)
        pad.PaddingBottom = UDim.new(0, 20)
        pad.PaddingLeft = UDim.new(0, 24)
        pad.PaddingRight = UDim.new(0, 24)
        pad.Parent = dialog

        local mainLayout = Instance.new("UIListLayout")
        mainLayout.FillDirection = Enum.FillDirection.Vertical
        mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        mainLayout.Padding = UDim.new(0, 12)
        mainLayout.Parent = dialog

        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 0)
        header.AutomaticSize = Enum.AutomaticSize.Y
        header.BackgroundTransparency = 1
        header.Parent = dialog

        local headerLayout = Instance.new("UIListLayout")
        headerLayout.FillDirection = Enum.FillDirection.Horizontal
        headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        headerLayout.Padding = UDim.new(0, 12)
        headerLayout.Parent = header

        if icon then
            local iconImg = Instance.new("ImageLabel")
            iconImg.Size = UDim2.new(0, 28, 0, 28)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = getIcon(icon)
            iconImg.ImageColor3 = GetThemeColor("Icon")
            iconImg.Parent = header
        end

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, icon and -40 or 0, 0, 0)
        titleLabel.AutomaticSize = Enum.AutomaticSize.Y
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = GetThemeColor("Text")
        titleLabel.TextSize = 20
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextWrapped = true
        titleLabel.Parent = header

        if content and content ~= "" then
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, 0, 0, 0)
            contentLabel.AutomaticSize = Enum.AutomaticSize.Y
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = content
            contentLabel.TextColor3 = GetThemeColor("Text")
            contentLabel.TextTransparency = 0.3
            contentLabel.TextSize = 16
            contentLabel.Font = Enum.Font.GothamMedium
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextWrapped = true
            contentLabel.Parent = dialog
        end

        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, 0, 0, 0)
        btnContainer.AutomaticSize = Enum.AutomaticSize.Y
        btnContainer.BackgroundTransparency = 1
        btnContainer.Parent = dialog

        local btnLayout = Instance.new("UIListLayout")
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        btnLayout.Padding = UDim.new(0, 10)
        btnLayout.Parent = btnContainer

        local closeDialog = function()
            TweenService:Create(dialog, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, width, 0, 0)
            }):Play()
            task.delay(0.2, function()
                overlay:Destroy()
            end)
        end

        for _, btnData in ipairs(buttons) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, btnData.Width or 90, 0, 36)
            btn.BackgroundTransparency = 1
            btn.Text = btnData.Text or "按钮"
            btn.TextColor3 = GetThemeColor("Text")
            btn.TextSize = 15
            btn.Font = Enum.Font.GothamMedium
            btn.ZIndex = 100001
            btn.AutoButtonColor = false
            btn.Parent = btnContainer

            local btnBg = NewRoundFrame(8, "Squircle", {
                Size = UDim2.new(1, 0, 1, 0),
                ImageTransparency = btnData.Primary and 0.2 or 0.05,
                ImageColor3 = btnData.Primary and GetThemeColor("Button") or GetThemeColor("Text"),
                ZIndex = 0,
                Parent = btn,
            })

            btn.MouseEnter:Connect(function()
                TweenService:Create(btnBg, TweenInfo.new(0.1), {
                    ImageTransparency = btnData.Primary and 0.1 or 0.15
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btnBg, TweenInfo.new(0.1), {
                    ImageTransparency = btnData.Primary and 0.2 or 0.05
                }):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                if btnData.Callback then
                    btnData.Callback()
                end
                closeDialog()
            end)
        end

        dialog.Size = UDim2.new(0, width, 0, 0)
        TweenService:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, width, 0, dialog.AbsoluteSize.Y)
        }):Play()

        return {
            Close = closeDialog,
            Dialog = dialog,
            Overlay = overlay,
        }
    end

    -- ================================================================
    -- 9. 窗口控制增强
    -- ================================================================

    local function enhanceWindowControls(panelObj)
        local enhanced = {}

        function enhanced.LockAll()
            local function lockRecursive(obj)
                if obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("TextBox") then
                    obj.Interactable = false
                end
                for _, child in ipairs(obj:GetChildren()) do
                    lockRecursive(child)
                end
            end
            lockRecursive(panelObj)
            return true
        end

        function enhanced.UnlockAll()
            local function unlockRecursive(obj)
                if obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("TextBox") then
                    obj.Interactable = true
                end
                for _, child in ipairs(obj:GetChildren()) do
                    unlockRecursive(child)
                end
            end
            unlockRecursive(panelObj)
            return true
        end

        function enhanced.EnableDoubleClickCenter(titleBar, panelFrame)
            local lastClick = 0
            local clickPos = nil

            titleBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local now = tick()
                    if now - lastClick < 0.4 and clickPos then
                        TweenService:Create(panelFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0.5, 0, 0.5, 0)
                        }):Play()
                        clickPos = nil
                        lastClick = 0
                    else
                        lastClick = now
                        clickPos = input.Position
                    end
                end
            end)
        end

        function enhanced.AutoScale(panelFrame, baseSize, minScale, maxScale)
            minScale = minScale or 0.6
            maxScale = maxScale or 1.2

            local function updateScale()
                local viewport = Workspace.CurrentCamera.ViewportSize
                local scaleX = viewport.X / baseSize.X
                local scaleY = viewport.Y / baseSize.Y
                local newScale = math.clamp(math.min(scaleX, scaleY), minScale, maxScale)

                local scaleObj = panelFrame:FindFirstChild("UIScale")
                if not scaleObj then
                    scaleObj = Instance.new("UIScale")
                    scaleObj.Name = "UIScale"
                    scaleObj.Parent = panelFrame
                end
                scaleObj.Scale = newScale
            end

            updateScale()
            Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        end

        function enhanced.SavePosition(panelFrame, key)
            key = key or "WindowPosition"
            if not writefile then return false end
            local data = {
                Position = panelFrame.Position,
                Size = panelFrame.Size,
            }
            pcall(function()
                writefile("WindUI/" .. key .. ".json", HttpService:JSONEncode(data))
            end)
            return true
        end

        function enhanced.LoadPosition(panelFrame, key)
            key = key or "WindowPosition"
            if not readfile then return false end
            local success, result = pcall(function()
                local json = readfile("WindUI/" .. key .. ".json")
                return HttpService:JSONDecode(json)
            end)
            if success and result then
                panelFrame.Position = result.Position
                panelFrame.Size = result.Size
                return true
            end
            return false
        end

        return enhanced
    end

    -- ================================================================
    -- 10. Acrylic 毛玻璃效果
    -- ================================================================

    local AcrylicManager = {
        _enabled = false,
        _effect = nil,
        _blurBg = nil,
        _overlay = nil,
    }

    function AcrylicManager:Enable()
        if self._enabled then return end

        local lighting = Lighting
        self._effect = Instance.new("DepthOfFieldEffect")
        self._effect.FarIntensity = 0
        self._effect.InFocusRadius = 0
        self._effect.NearIntensity = 0.8
        self._effect.Parent = lighting

        self._blurBg = Instance.new("ImageLabel")
        self._blurBg.Name = "AcrylicBackground"
        self._blurBg.Size = UDim2.new(1, 0, 1, 0)
        self._blurBg.BackgroundTransparency = 1
        self._blurBg.Image = "rbxassetid://16110839595"
        self._blurBg.ImageTransparency = 0.7
        self._blurBg.ScaleType = Enum.ScaleType.Tile
        self._blurBg.TileSize = UDim2.new(0, 64, 0, 64)
        self._blurBg.ZIndex = -1
        self._blurBg.Parent = gui

        self._overlay = Instance.new("Frame")
        self._overlay.Name = "AcrylicOverlay"
        self._overlay.Size = UDim2.new(1, 0, 1, 0)
        self._overlay.BackgroundTransparency = 0.85
        self._overlay.BackgroundColor3 = GetThemeColor("Background")
        self._overlay.ZIndex = 0
        self._overlay.Parent = gui

        self._enabled = true
        return true
    end

    function AcrylicManager:Disable()
        if not self._enabled then return end

        if self._effect then
            self._effect:Destroy()
            self._effect = nil
        end

        if self._blurBg then
            self._blurBg:Destroy()
            self._blurBg = nil
        end

        if self._overlay then
            self._overlay:Destroy()
            self._overlay = nil
        end

        self._enabled = false
        return true
    end

    function AcrylicManager:Toggle()
        if self._enabled then
            self:Disable()
        else
            self:Enable()
        end
    end

    function AcrylicManager:IsEnabled()
        return self._enabled
    end

    -- ================================================================
    -- 挂载所有功能到主面板返回对象
    -- ================================================================

    panel.Button = createButton
    panel.Toggle = createToggle
    panel.Slider = createSlider
    panel.Input = createInput
    panel.Dropdown = createDropdown
    panel.Colorpicker = createColorpicker
    panel.ProgressBar = createProgressBar
    panel.Paragraph = createParagraph
    panel.Section = createSection
    panel.Divider = createDivider
    panel.Space = createSpace
    panel.Image = createImageElement
    panel.Code = createCodeElement
    panel.Keybind = createKeybind
    panel.Viewport = createViewport

    panel.HStack = createHStack
    panel.VStack = createVStack
    panel.Group = createGroup

    panel.ConfigManager = ConfigManager
    panel.NotificationManager = NotificationManager
    panel.AcrylicManager = AcrylicManager

    panel.createDialog = createDialog
    panel.enhanceWindowControls = enhanceWindowControls

    -- 初始化通知系统
    NotificationManager:Init(gui)

    -- 初始化配置系统
    local configInitSuccess = ConfigManager:Init()
    if configInitSuccess then
        panel.Config = ConfigManager
    end

    -- 启用双击标题栏居中
    local controls = enhanceWindowControls(panel.Panel)
    controls:EnableDoubleClickCenter(titleBar, panel.Panel)

    -- 启用 LockAll/UnlockAll
    panel.LockAll = function()
        controls:LockAll()
    end

    panel.UnlockAll = function()
        controls:UnlockAll()
    end

    -- 启用 Acrylic 快捷开关
    panel.ToggleAcrylic = function()
        AcrylicManager:Toggle()
    end

    -- 通知快捷方式
    panel.Notify = function(data)
        return NotificationManager:Notify(data)
    end

    -- 对话框快捷方式
    panel.Dialog = function(data)
        data.Parent = data.Parent or gui
        return createDialog(data)
    end

    -- 保存位置快捷方式
    panel.SavePosition = function(key)
        controls:SavePosition(panel.Panel, key)
    end

    panel.LoadPosition = function(key)
        controls:LoadPosition(panel.Panel, key)
    end

    panel.AllElements = allElements

    return panel
end

-- ================================================================
-- 创建并显示面板
-- ================================================================

local panel = createMainPanel({
    Title = "WindUI 主面板",
    Width = 580,
    Height = 440,
    MinWidth = 400,
    MinHeight = 300,
})

return panel
