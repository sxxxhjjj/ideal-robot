--[[
    WindUI 简化版 v1.0
    基于 WindUI v1.6.66 精简重构
    固定3个Tab、深色主题、中文界面、自动配置保存
    15个公开API函数
]]

-- ============================================================
-- 环境初始化（适配注入器）
-- ============================================================
repeat task.wait() until game
repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or clonereference or function(...) return ... end

-- 服务引用
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Lighting = cloneref(game:GetService("Lighting"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- 主题配置（深色主题，固定）
-- ============================================================
local Theme = {
    Background = Color3.fromHex("#1a1a1f"),
    BackgroundTransparency = 0.08,
    Panel = Color3.fromHex("#202027"),
    PanelTransparency = 0.05,
    Dialog = Color3.fromHex("#252530"),
    Text = Color3.fromHex("#ffffff"),
    TextDim = Color3.fromHex("#9a9aa8"),
    Icon = Color3.fromHex("#c8c8d0"),
    Accent = Color3.fromHex("#4a7dff"),
    AccentDim = Color3.fromHex("#3a5dc0"),
    Border = Color3.fromHex("#3a3a48"),
    Hover = Color3.fromHex("#2e2e3a"),
    Press = Color3.fromHex("#383848"),
    Success = Color3.fromHex("#4ade80"),
    Warning = Color3.fromHex("#fbbf24"),
    Error = Color3.fromHex("#f87171"),
    Sidebar = Color3.fromHex("#16161c"),
    SidebarTransparency = 0.1,
    Topbar = Color3.fromHex("#1e1e26"),
    TopbarTransparency = 0.05,
    Scrollbar = Color3.fromHex("#4a4a5a"),
    InputBackground = Color3.fromHex("#2a2a35"),
    SliderBackground = Color3.fromHex("#353545"),
    ToggleOff = Color3.fromHex("#454555"),
    CodeBackground = Color3.fromHex("#15151c"),
}

-- ============================================================
-- 图标库（约150个常用图标，lucide风格）
-- ============================================================
local Icons = {
    -- 基础操作
    home = "rbxassetid://71348687817487",
    search = "rbxassetid://68318662334227",
    settings = "rbxassetid://74233618679614",
    user = "rbxassetid://93218563817320",
    users = "rbxassetid://76149283773964",
    menu = "rbxassetid://84624861491380",
    x = "rbxassetid://88180227660436",
    check = "rbxassetid://107952773815140",
    chevronDown = "rbxassetid://99665345506183",
    chevronUp = "rbxassetid://102643772650308",
    chevronLeft = "rbxassetid://82795521413147",
    chevronRight = "rbxassetid://92048254407464",
    plus = "rbxassetid://97855225784263",
    minus = "rbxassetid://107522792007414",
    moreHorizontal = "rbxassetid://72076657808380",
    moreVertical = "rbxassetid://103513347084804",

    -- 箭头
    arrowUp = "rbxassetid://89282378235317",
    arrowDown = "rbxassetid://98764963621439",
    arrowLeft = "rbxassetid://102531941843733",
    arrowRight = "rbxassetid://113692007244654",
    arrowUpRight = "rbxassetid://129280608535523",
    arrowUpDown = "rbxassetid://81019887641527",
    refresh = "rbxassetid://102253651881128",
    rotate = "rbxassetid://90282693641741",

    -- 媒体
    play = "rbxassetid://124435834080533",
    pause = "rbxassetid://70605517284830",
    stop = "rbxassetid://86752027321482",
    volume2 = "rbxassetid://109264124432049",
    volume1 = "rbxassetid://95588426112386",
    volumeX = "rbxassetid://92683234972579",
    music = "rbxassetid://103184351522068",
    video = "rbxassetid://107447532820240",
    image = "rbxassetid://71779114614378",
    camera = "rbxassetid://118358207445582",

    -- 编辑
    edit = "rbxassetid://81435193442136",
    copy = "rbxassetid://94408179097685",
    trash = "rbxassetid://82431679861460",
    save = "rbxassetid://108311503384073",
    download = "rbxassetid://88617978848415",
    upload = "rbxassetid://95667161815464",
    share = "rbxassetid://114063895556765",
    link = "rbxassetid://86531615415977",
    filter = "rbxassetid://106631474924056",
    sort = "rbxassetid://107940237146009",

    -- 状态
    info = "rbxassetid://91782564046169",
    helpCircle = "rbxassetid://81840021668279",
    alertCircle = "rbxassetid://123918102207140",
    alertTriangle = "rbxassetid://112674705841212",
    checkCircle = "rbxassetid://92455013600713",
    xCircle = "rbxassetid://90767043015246",
    lock = "rbxassetid://79587216113811",
    unlock = "rbxassetid://89642174475360",
    eye = "rbxassetid://100374471206057",
    eyeOff = "rbxassetid://78560046118930",

    -- 通信
    bell = "rbxassetid://97392696311902",
    messageSquare = "rbxassetid://79114633544155",
    mail = "rbxassetid://93086006468704",
    phone = "rbxassetid://91726662362587",
    send = "rbxassetid://84260846038286",

    -- 文件
    file = "rbxassetid://78624534143711",
    folder = "rbxassetid://97402125207079",
    folderOpen = "rbxassetid://76303524414300",
    archive = "rbxassetid://122180020814574",
    clipboard = "rbxassetid://94408179097685",
    list = "rbxassetid://118470463752466",

    -- 布局
    layoutGrid = "rbxassetid://97220086126656",
    layoutList = "rbxassetid://74961997822126",
    columns = "rbxassetid://93791183635525",
    rows = "rbxassetid://81570549209434",
    maximize = "rbxassetid://110096882363637",
    minimize = "rbxassetid://97726529032925",
    maximize2 = "rbxassetid://93142176757189",

    -- 界面元素
    toggleLeft = "rbxassetid://106631474924056",
    toggleRight = "rbxassetid://124998077349706",
    slider = "rbxassetid://103886093046990",
    mousePointer = "rbxassetid://81081164158885",
    keyboard = "rbxassetid://108818207813537",
    palette = "rbxassetid://75272915739209",
    type = "rbxassetid://111491496660216",

    -- 工具
    wrench = "rbxassetid://96528869059554",
    hammer = "rbxassetid://73167696981648",
    shield = "rbxassetid://100203029845919",
    zap = "rbxassetid://102881251417484",
    target = "rbxassetid://78599995190651",
    crosshair = "rbxassetid://112674705841212",
    compass = "rbxassetid://125674804697729",

    -- 物品
    package = "rbxassetid://132405197863294",
    box = "rbxassetid://122438676546804",
    gift = "rbxassetid://77014333795836",
    trophy = "rbxassetid://132740088158419",
    star = "rbxassetid://88552752106723",
    heart = "rbxassetid://94612128913941",
    thumbsUp = "rbxassetid://105384358373973",

    -- 人物/角色
    userCheck = "rbxassetid://116620312917084",
    userPlus = "rbxassetid://100325578561866",
    userX = "rbxassetid://122931434733842",
    userMinus = "rbxassetid://140321561183881",
    crown = "rbxassetid://82004462003936",

    -- 其他
    globe = "rbxassetid://90282693641741",
    map = "rbxassetid://102930322246035",
    calendar = "rbxassetid://126259032907535",
    clock = "rbxassetid://76437352099157",
    timer = "rbxassetid://80468822979214",
    sun = "rbxassetid://8296067675590",
    moon = "rbxassetid://93136954756149",
    cloud = "rbxassetid://96965448419685",
    flame = "rbxassetid://105850162318915",
    droplet = "rbxassetid://80902539995520",
    wind = "rbxassetid://97904885874823",
    leaf = "rbxassetid://100277767266983",

    -- 游戏相关
    gamepad2 = "rbxassetid://108311503384073",
    sword = "rbxassetid://92181172123618",
    shieldCheck = "rbxassetid://76078495178149",
    coins = "rbxassetid://127139803581141",
    gem = "rbxassetid://137370389604364",

    -- 开发相关
    code = "rbxassetid://109208148317037",
    terminal = "rbxassetid://92569381441969",
    bug = "rbxassetid://75272915739209",
    gitBranch = "rbxassetid://83396154449972",
    database = "rbxassetid://104840231536668",
    server = "rbxassetid://124677132511270",
    cpu = "rbxassetid://70906718268972",
    hardDrive = "rbxassetid://105934079398915",
    wifi = "rbxassetid://96315134002985",
    bluetooth = "rbxassetid://90506573139443",
    battery = "rbxassetid://70765800346189",
    batteryCharging = "rbxassetid://80139357470047",
    batteryFull = "rbxassetid://70906718268972",
    batteryLow = "rbxassetid://139659256984314",
    batteryMedium = "rbxassetid://105934079398915",
    plug = "rbxassetid://91931341486966",
    power = "rbxassetid://115230083817257",

    -- 医疗
    heartPulse = "rbxassetid://82004462003936",
    activity = "rbxassetid://94212016861936",
    pill = "rbxassetid://129660129590770",
    syringe = "rbxassetid://86922213051957",
    stethoscope = "rbxassetid://76031400297942",
}

-- ============================================================
-- NewRoundFrame 样式系统（17种形状）
-- ============================================================
local RoundFrame = {}
RoundFrame.__index = RoundFrame

local Shapes = {
    Circle = {
        Image = "rbxassetid://111665032676235",
        Rect = Rect.new(512, 512, 512, 512),
        Radius = 512,
    },
    CircleOutline = {
        Image = "rbxassetid://108556680453287",
        Rect = Rect.new(512, 512, 512, 512),
        Radius = 512,
    },
    CircleGlass = {
        Image = "rbxassetid://95600044758841",
        Rect = Rect.new(512, 512, 512, 512),
        Radius = 512,
    },
    SquircleH = {
        Image = "rbxassetid://125083578015333",
        Rect = Rect.new(512, 325, 512, 325),
        Radius = 325,
    },
    SquircleHOutline = {
        Image = "rbxassetid://107043713170567",
        Rect = Rect.new(512, 325, 512, 325),
        Radius = 325,
    },
    SquircleHGlass = {
        Image = "rbxassetid://84819521201001",
        Rect = Rect.new(512, 325, 512, 325),
        Radius = 325,
    },
    SquircleV = {
        Image = "rbxassetid://124965260437653",
        Rect = Rect.new(325, 512, 325, 512),
        Radius = 325,
    },
    SquircleVOutline = {
        Image = "rbxassetid://88808835404198",
        Rect = Rect.new(325, 512, 325, 512),
        Radius = 325,
    },
    SquircleVGlass = {
        Image = "rbxassetid://124982801466667",
        Rect = Rect.new(325, 512, 325, 512),
        Radius = 325,
    },
    Squircle = {
        Image = "rbxassetid://89641024074289",
        Rect = Rect.new(460, 460, 460, 460),
        Radius = 310,
    },
    SquircleOutline = {
        Image = "rbxassetid://74029063732681",
        Rect = Rect.new(512, 512, 512, 512),
        Radius = 310,
    },
    SquircleGlass = {
        Image = "rbxassetid://131126436897551",
        Rect = Rect.new(512, 512, 512, 512),
        Radius = 310,
    },
    ["SquircleH-TL-TR"] = {
        Image = "rbxassetid://90680657206619",
        Rect = Rect.new(807, 512, 807, 512),
        Radius = 325,
        AutoChange = false,
    },
    ["SquircleH-BL-BR"] = {
        Image = "rbxassetid://99216342056719",
        Rect = Rect.new(0, 512, 0, 512),
        Radius = 325,
        AutoChange = false,
    },
    ["Squircle-TL-TR"] = {
        Image = "rbxassetid://75712142040725",
        Rect = Rect.new(512, 512, 512, 512),
        Radius = 310,
        AutoChange = false,
    },
    ["Squircle-BL-BR"] = {
        Image = "rbxassetid://83676684425544",
        Rect = Rect.new(512, 0, 512, 0),
        Radius = 310,
        AutoChange = false,
    },
    Square = {
        Image = "rbxassetid://82909646051652",
        Rect = Rect.new(512, 512, 512, 512),
        Radius = 512,
        AutoChange = false,
    },
}

local ShapeAliases = {
    ["Glass-0.7"] = "SquircleGlass",
    ["Glass-1"] = "SquircleGlass",
    ["Glass-1.4"] = "SquircleGlass",
    ["Squircle-Outline"] = "SquircleOutline",
}

local function GetShape(shapeName)
    return Shapes[ShapeAliases[shapeName] or shapeName] or Shapes.Circle
end

function RoundFrame.new(props)
    local self = setmetatable({}, RoundFrame)
    self.Radius = props.Radius or 0
    self.Type = props.Type or "Circle"
    self.IsButton = props.IsButton or false

    local className = self.IsButton and "ImageButton" or "ImageLabel"
    local instance = Instance.new(className)
    instance.BackgroundTransparency = 1
    instance.ScaleType = props.ScaleType ~= false and Enum.ScaleType.Slice or nil
    instance.SliceScale = 1

    -- 应用属性
    for k, v in pairs(props) do
        if k ~= "Radius" and k ~= "Type" and k ~= "IsButton" and k ~= "ScaleType" then
            instance[k] = v
        end
    end

    self.Instance = instance
    self:SetRadius(self.Radius)
    self:SetType(self.Type)

    return self
end

function RoundFrame:SetRadius(radius)
    self.Radius = radius
    local shape = GetShape(self.Type)
    self.Instance.SliceScale = math.max(radius / shape.Radius, 0.0001)
    return self
end

function RoundFrame:SetType(shapeType)
    self.Type = shapeType
    local shape = GetShape(shapeType)
    self.Instance.Image = shape.Image
    self.Instance.SliceCenter = shape.Rect
    self:SetRadius(self.Radius)
    return self
end

function RoundFrame:GetRadius()
    return self.Radius
end

function RoundFrame:GetType()
    return self.Type
end

-- ============================================================
-- 工具函数
-- ============================================================
local function Create(className, props, parent)
    local instance = Instance.new(className)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if parent then
        instance.Parent = parent
    end
    return instance
end

local function CreateIcon(iconName, size, color, parent)
    local iconId = Icons[iconName] or Icons.info
    local iconLabel = Create("ImageLabel", {
        Size = size or UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        Image = iconId,
        ImageColor3 = color or Theme.Icon,
        ResampleMode = Enum.ResamplerMode.Pixelated,
    }, parent)
    return iconLabel
end

local function Tween(instance, props, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(instance, tweenInfo, props)
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function Color3ToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

-- ============================================================
-- 配置管理（自动保存/加载）
-- ============================================================
local ConfigManager = {}
ConfigManager.__index = ConfigManager

local CONFIG_FOLDER = "WindUI"
local CONFIG_FILE = "WindUI/主面板/配置.json"

-- 默认配置
local DefaultConfig = {
    WindowSize = { X = 580, Y = 440 },
    WindowPosition = nil, -- nil表示居中
    Scale = 1,
    Tabs = {
        {
            Name = "基础控件",
            Controls = {
                toggleEnabled = false,
                sliderVolume = 50,
                inputUsername = "",
                dropdownTheme = "深色",
            }
        },
        {
            Name = "高级控件",
            Controls = {
                colorPicker = "#4a7dff",
                keybind = Enum.KeyCode.F,
            }
        },
        {
            Name = "其他",
            Controls = {}
        }
    }
}

function ConfigManager.new()
    local self = setmetatable({}, ConfigManager)
    self.Config = self:Load()
    self.SaveDebounce = false
    return self
end

function ConfigManager:Load()
    local success, result = pcall(function()
        if isfile and isfile(CONFIG_FILE) then
            local json = readfile(CONFIG_FILE)
            local data = HttpService:JSONDecode(json)
            -- 合并默认值，确保新增字段有默认值
            return self:MergeDefaults(data, DefaultConfig)
        end
    end)
    if success and result then
        return result
    end
    -- 深拷贝默认配置
    return HttpService:JSONDecode(HttpService:JSONEncode(DefaultConfig))
end

function ConfigManager:MergeDefaults(data, defaults)
    local result = {}
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if data[k] ~= nil and type(data[k]) == "table" then
                result[k] = self:MergeDefaults(data[k], v)
            else
                result[k] = HttpService:JSONDecode(HttpService:JSONEncode(v))
            end
        else
            if data[k] ~= nil then
                result[k] = data[k]
            else
                result[k] = v
            end
        end
    end
    return result
end

function ConfigManager:Save()
    if self.SaveDebounce then return end
    self.SaveDebounce = true
    task.delay(0.3, function()
        self.SaveDebounce = false
        pcall(function()
            if writefile then
                -- 确保目录存在
                if makefolder then
                    if not isfolder(CONFIG_FOLDER) then
                        makefolder(CONFIG_FOLDER)
                    end
                    if not isfolder("WindUI/主面板") then
                        makefolder("WindUI/主面板")
                    end
                end
                local json = HttpService:JSONEncode(self.Config)
                writefile(CONFIG_FILE, json)
            end
        end)
    end)
end

function ConfigManager:Get(path)
    local keys = {}
    for key in string.gmatch(path, "[^%.]+") do
        table.insert(keys, key)
    end
    local current = self.Config
    for _, key in ipairs(keys) do
        if current[key] ~= nil then
            current = current[key]
        else
            return nil
        end
    end
    return current
end

function ConfigManager:Set(path, value)
    local keys = {}
    for key in string.gmatch(path, "[^%.]+") do
        table.insert(keys, key)
    end
    local current = self.Config
    for i = 1, #keys - 1 do
        local key = keys[i]
        if current[key] == nil or type(current[key]) ~= "table" then
            current[key] = {}
        end
        current = current[key]
    end
    current[keys[#keys]] = value
    self:Save()
end

-- ============================================================
-- 通知系统
-- ============================================================
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(parent)
    local self = setmetatable({}, NotificationManager)
    self.Parent = parent
    self.Notifications = {}

    -- 通知容器
    self.Container = Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -20, 1, -20),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    self.ListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = self.Container,
    })

    return self
end

function NotificationManager:Notify(title, text, notificationType, duration)
    notificationType = notificationType or "info"
    duration = duration or 3

    local iconName = "info"
    local accentColor = Theme.Accent
    if notificationType == "success" then
        iconName = "checkCircle"
        accentColor = Theme.Success
    elseif notificationType == "warning" then
        iconName = "alertTriangle"
        accentColor = Theme.Warning
    elseif notificationType == "error" then
        iconName = "xCircle"
        accentColor = Theme.Error
    end

    -- 通知卡片
    local notifFrame = RoundFrame.new({
        Name = "Notification",
        Radius = 10,
        Type = "SquircleH",
        Size = UDim2.new(0, 280, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ImageColor3 = Theme.Panel,
        ImageTransparency = Theme.PanelTransparency,
        Parent = self.Container,
    })

    -- 边框
    local border = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.5,
        Thickness = 1,
        Parent = notifFrame.Instance,
    })

    -- 阴影
    local shadow = Create("UICorner", {
        CornerRadius = UDim.new(0, 0),
        Parent = notifFrame.Instance,
    })

    -- 内部布局
    local innerPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = notifFrame.Instance,
    })

    local innerLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = notifFrame.Instance,
    })

    -- 图标
    local iconBg = RoundFrame.new({
        Name = "IconBg",
        Radius = 8,
        Type = "Circle",
        Size = UDim2.new(0, 32, 0, 32),
        ImageColor3 = accentColor,
        ImageTransparency = 0.85,
        LayoutOrder = 1,
        Parent = notifFrame.Instance,
    })

    local icon = CreateIcon(iconName, UDim2.new(0, 18, 0, 18), accentColor, iconBg.Instance)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)

    -- 文字区域
    local textContainer = Create("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(1, -42, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = notifFrame.Instance,
    })

    local textLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = textContainer,
    })

    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = title or "通知",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = textContainer,
    })

    local textLabel = Create("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 2,
        Parent = textContainer,
    })

    -- 进度条
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.5,
        LayoutOrder = 3,
        Parent = textContainer,
    })

    local progressFill = Create("Frame", {
        Name = "ProgressFill",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        Parent = progressBar,
    })

    -- 进入动画
    notifFrame.Instance.Position = UDim2.new(1, 20, 0, 0)
    notifFrame.Instance.AnchorPoint = Vector2.new(0, 0)
    notifFrame.Instance.Visible = true

    local enterTween = Tween(notifFrame.Instance, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    enterTween:Play()

    -- 进度条动画
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    local progressTween = Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    progressTween:Play()

    -- 自动消失
    task.delay(duration, function()
        local exitTween = Tween(notifFrame.Instance, { Position = UDim2.new(1, 20, 0, 0) }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        exitTween:Play()
        exitTween.Completed:Connect(function()
            notifFrame.Instance:Destroy()
        end)
    end)

    return notifFrame
end

-- ============================================================
-- 工具提示系统
-- ============================================================
local TooltipManager = {}
TooltipManager.__index = TooltipManager

function TooltipManager.new(screenGui)
    local self = setmetatable({}, TooltipManager)
    self.ScreenGui = screenGui
    self.CurrentTooltip = nil

    -- 提示框
    self.TooltipFrame = RoundFrame.new({
        Name = "Tooltip",
        Radius = 6,
        Type = "SquircleH",
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        ImageColor3 = Theme.Dialog,
        ImageTransparency = 0.05,
        Visible = false,
        ZIndex = 100,
        Parent = screenGui,
    })

    local tooltipStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.3,
        Thickness = 1,
        Parent = self.TooltipFrame.Instance,
    })

    local tooltipPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = self.TooltipFrame.Instance,
    })

    self.TooltipText = Create("TextLabel", {
        Name = "TooltipText",
        Size = UDim2.new(0, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        Parent = self.TooltipFrame.Instance,
    })

    return self
end

function TooltipManager:Show(text, targetInstance)
    if not text or text == "" then return end

    self.TooltipText.Text = text
    self.TooltipFrame.Instance.Visible = true

    -- 计算位置
    task.spawn(function()
        local mousePos = UserInputService:GetMouseLocation()
        local viewportSize = Workspace.CurrentCamera.ViewportSize

        local tipSize = self.TooltipFrame.Instance.AbsoluteSize
        local x = mousePos.X + 12
        local y = mousePos.Y + 12

        -- 边界检测
        if x + tipSize.X > viewportSize.X then
            x = mousePos.X - tipSize.X - 12
        end
        if y + tipSize.Y > viewportSize.Y then
            y = mousePos.Y - tipSize.Y - 12
        end

        self.TooltipFrame.Instance.Position = UDim2.new(0, x, 0, y)
    end)
end

function TooltipManager:Hide()
    self.TooltipFrame.Instance.Visible = false
end

function TooltipManager:Register(instance, text)
    instance.MouseEnter:Connect(function()
        self:Show(text, instance)
    end)
    instance.MouseLeave:Connect(function()
        self:Hide()
    end)
end

-- ============================================================
-- 控件创建函数
-- ============================================================
local Controls = {}

-- 按钮控件
function Controls.CreateButton(parent, label, onClick, tooltip)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local btn = RoundFrame.new({
        Name = "Button",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        Parent = container,
    })

    local btnLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label or "按钮",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Parent = btn.Instance,
    })

    -- 交互效果
    btn.Instance.MouseEnter:Connect(function()
        Tween(btn.Instance, { ImageTransparency = 0.15 }, 0.15):Play()
    end)
    btn.Instance.MouseLeave:Connect(function()
        Tween(btn.Instance, { ImageTransparency = 0 }, 0.15):Play()
    end)
    btn.Instance.MouseButton1Down:Connect(function()
        Tween(btn.Instance, { ImageTransparency = 0.25 }, 0.1):Play()
    end)
    btn.Instance.MouseButton1Up:Connect(function()
        Tween(btn.Instance, { ImageTransparency = 0.15 }, 0.1):Play()
    end)
    btn.Instance.MouseButton1Click:Connect(function()
        if onClick then onClick() end
    end)

    return {
        Container = container,
        Button = btn,
        SetLabel = function(_, text)
            btnLabel.Text = text
        end,
        SetEnabled = function(_, enabled)
            btn.Instance.Active = enabled
            btn.Instance.ImageTransparency = enabled and 0 or 0.6
        end,
    }
end

-- 开关控件
function Controls.CreateToggle(parent, label, defaultValue, onChange, tooltip)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local labelText = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = label or "开关",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Parent = container,
    })

    -- 开关背景
    local toggleBg = RoundFrame.new({
        Name = "ToggleBg",
        Radius = 12,
        Type = "Circle",
        Size = UDim2.new(0, 40, 0, 24),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        ImageColor3 = defaultValue and Theme.Accent or Theme.ToggleOff,
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        Parent = container,
    })

    -- 开关滑块
    local toggleKnob = RoundFrame.new({
        Name = "ToggleKnob",
        Radius = 8,
        Type = "Circle",
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = defaultValue and UDim2.new(0, 19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        ImageColor3 = Color3.new(1, 1, 1),
        ImageTransparency = 0,
        Parent = toggleBg.Instance,
    })

    local isOn = defaultValue or false

    local function toggle()
        isOn = not isOn
        local targetColor = isOn and Theme.Accent or Theme.ToggleOff
        local targetPos = isOn and UDim2.new(0, 19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)

        Tween(toggleBg.Instance, { ImageColor3 = targetColor }, 0.2):Play()
        Tween(toggleKnob.Instance, { Position = targetPos }, 0.2):Play()

        if onChange then onChange(isOn) end
    end

    toggleBg.Instance.MouseButton1Click:Connect(toggle)

    return {
        Container = container,
        ToggleBg = toggleBg,
        ToggleKnob = toggleKnob,
        GetValue = function() return isOn end,
        SetValue = function(_, value, skipCallback)
            isOn = value
            local targetColor = isOn and Theme.Accent or Theme.ToggleOff
            local targetPos = isOn and UDim2.new(0, 19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            toggleBg.Instance.ImageColor3 = targetColor
            toggleKnob.Instance.Position = targetPos
            if not skipCallback and onChange then onChange(isOn) end
        end,
    }
end

-- 滑块控件
function Controls.CreateSlider(parent, label, minValue, maxValue, defaultValue, onChange, tooltip)
    minValue = minValue or 0
    maxValue = maxValue or 100
    defaultValue = defaultValue or 50

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    -- 顶部标签和值
    local topRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Parent = container,
    })

    local labelText = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = label or "滑块",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topRow,
    })

    local valueText = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = tostring(defaultValue),
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Parent = topRow,
    })

    -- 滑块轨道
    local sliderBg = RoundFrame.new({
        Name = "SliderBg",
        Radius = 4,
        Type = "Circle",
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        ImageColor3 = Theme.SliderBackground,
        ImageTransparency = 0,
        Parent = container,
    })

    -- 滑块填充
    local sliderFill = RoundFrame.new({
        Name = "SliderFill",
        Radius = 4,
        Type = "Circle",
        Size = UDim2.new(0, 0, 1, 0),
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0,
        ClipsDescendants = true,
        Parent = sliderBg.Instance,
    })

    -- 滑块手柄
    local sliderKnob = RoundFrame.new({
        Name = "SliderKnob",
        Radius = 8,
        Type = "Circle",
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        ImageColor3 = Color3.new(1, 1, 1),
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        Parent = sliderBg.Instance,
    })

    local isDragging = false
    local currentValue = defaultValue

    local function updateSlider(percent)
        percent = math.clamp(percent, 0, 1)
        currentValue = math.floor(minValue + (maxValue - minValue) * percent + 0.5)

        sliderFill.Instance.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Instance.Position = UDim2.new(percent, 0, 0.5, 0)
        valueText.Text = tostring(currentValue)

        if onChange then onChange(currentValue) end
    end

    -- 初始化
    local initPercent = (defaultValue - minValue) / (maxValue - minValue)
    updateSlider(initPercent)

    -- 拖动
    sliderKnob.Instance.MouseButton1Down:Connect(function()
        isDragging = true
    end)

    sliderBg.Instance.MouseButton1Down:Connect(function()
        isDragging = true
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = sliderBg.Instance.AbsolutePosition
        local sliderSize = sliderBg.Instance.AbsoluteSize
        local percent = (mousePos.X - sliderPos.X) / sliderSize.X
        updateSlider(percent)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.Instance.AbsolutePosition
            local sliderSize = sliderBg.Instance.AbsoluteSize
            local percent = (mousePos.X - sliderPos.X) / sliderSize.X
            updateSlider(percent)
        end
    end)

    return {
        Container = container,
        SliderBg = sliderBg,
        SliderFill = sliderFill,
        SliderKnob = sliderKnob,
        GetValue = function() return currentValue end,
        SetValue = function(_, value, skipCallback)
            local percent = (value - minValue) / (maxValue - minValue)
            currentValue = value
            sliderFill.Instance.Size = UDim2.new(percent, 0, 1, 0)
            sliderKnob.Instance.Position = UDim2.new(percent, 0, 0.5, 0)
            valueText.Text = tostring(value)
            if not skipCallback and onChange then onChange(value) end
        end,
    }
end

-- 输入框控件
function Controls.CreateInput(parent, label, placeholder, defaultValue, onChange, tooltip)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local labelText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = label or "输入框",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local inputBg = RoundFrame.new({
        Name = "InputBg",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        ImageColor3 = Theme.InputBackground,
        ImageTransparency = 0,
        Parent = container,
    })

    local inputStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.5,
        Thickness = 1,
        Parent = inputBg.Instance,
    })

    local inputPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = inputBg.Instance,
    })

    local inputBox = Create("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = defaultValue or "",
        PlaceholderText = placeholder or "请输入...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputBg.Instance,
    })

    local currentText = defaultValue or ""

    inputBox.Focused:Connect(function()
        Tween(inputStroke, { Color = Theme.Accent, Transparency = 0 }, 0.15):Play()
    end)

    inputBox.FocusLost:Connect(function()
        Tween(inputStroke, { Color = Theme.Border, Transparency = 0.5 }, 0.15):Play()
        currentText = inputBox.Text
        if onChange then onChange(currentText) end
    end)

    return {
        Container = container,
        InputBox = inputBox,
        InputBg = inputBg,
        GetValue = function() return currentText end,
        SetValue = function(_, value, skipCallback)
            currentText = value
            inputBox.Text = value
            if not skipCallback and onChange then onChange(value) end
        end,
    }
end

-- 下拉菜单控件
function Controls.CreateDropdown(parent, label, options, defaultValue, onChange, tooltip)
    options = options or { "选项1", "选项2", "选项3" }

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex = 10,
        Parent = parent,
    })

    local labelText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = label or "下拉菜单",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local dropdownBg = RoundFrame.new({
        Name = "DropdownBg",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        ImageColor3 = Theme.InputBackground,
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        ClipsDescendants = false,
        ZIndex = 10,
        Parent = container,
    })

    local dropdownStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.5,
        Thickness = 1,
        Parent = dropdownBg.Instance,
    })

    local dropdownPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = dropdownBg.Instance,
    })

    local selectedText = Create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = defaultValue or options[1],
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true,
        Parent = dropdownBg.Instance,
    })

    local chevronIcon = CreateIcon("chevronDown", UDim2.new(0, 14, 0, 14), Theme.Icon, dropdownBg.Instance)
    chevronIcon.AnchorPoint = Vector2.new(1, 0.5)
    chevronIcon.Position = UDim2.new(1, 0, 0.5, 0)

    -- 下拉列表
    local dropdownList = RoundFrame.new({
        Name = "DropdownList",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        ImageColor3 = Theme.Dialog,
        ImageTransparency = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 20,
        Parent = dropdownBg.Instance,
    })

    local listStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.3,
        Thickness = 1,
        Parent = dropdownList.Instance,
    })

    local listLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdownList.Instance,
    })

    local listPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = dropdownList.Instance,
    })

    local isOpen = false
    local currentValue = defaultValue or options[1]
    local optionButtons = {}

    local function closeDropdown()
        isOpen = false
        dropdownList.Instance.Visible = false
        Tween(chevronIcon, { Rotation = 0 }, 0.2):Play()
    end

    local function openDropdown()
        isOpen = true
        -- 计算列表高度
        local listHeight = #options * 28 + 8
        dropdownList.Instance.Size = UDim2.new(1, 0, 0, math.min(listHeight, 200))
        dropdownList.Instance.Visible = true
        Tween(chevronIcon, { Rotation = 180 }, 0.2):Play()
    end

    -- 创建选项
    for i, option in ipairs(options) do
        local optBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = option == currentValue and Theme.Accent or Theme.Text,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i,
            AutoButtonColor = false,
            Parent = dropdownList.Instance,
        })

        local optPadding = Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = optBtn,
        })

        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundTransparency = 0.85
            optBtn.BackgroundColor3 = Theme.Hover
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundTransparency = 1
        end)
        optBtn.MouseButton1Click:Connect(function()
            currentValue = option
            selectedText.Text = option
            -- 更新所有选项颜色
            for _, btn in ipairs(optionButtons) do
                btn.TextColor3 = btn.Text == currentValue and Theme.Accent or Theme.Text
            end
            closeDropdown()
            if onChange then onChange(currentValue) end
        end)

        table.insert(optionButtons, optBtn)
    end

    dropdownBg.Instance.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
        else
            openDropdown()
        end
    end)

    -- 点击外部关闭
    UserInputService.InputBegan:Connect(function(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local listPos = dropdownList.Instance.AbsolutePosition
            local listSize = dropdownList.Instance.AbsoluteSize
            local bgPos = dropdownBg.Instance.AbsolutePosition
            local bgSize = dropdownBg.Instance.AbsoluteSize

            local inList = mousePos.X >= listPos.X and mousePos.X <= listPos.X + listSize.X
                and mousePos.Y >= listPos.Y and mousePos.Y <= listPos.Y + listSize.Y
            local inBg = mousePos.X >= bgPos.X and mousePos.X <= bgPos.X + bgSize.X
                and mousePos.Y >= bgPos.Y and mousePos.Y <= bgPos.Y + bgSize.Y

            if not inList and not inBg then
                closeDropdown()
            end
        end
    end)

    return {
        Container = container,
        DropdownBg = dropdownBg,
        DropdownList = dropdownList,
        GetValue = function() return currentValue end,
        SetValue = function(_, value, skipCallback)
            currentValue = value
            selectedText.Text = value
            for _, btn in ipairs(optionButtons) do
                btn.TextColor3 = btn.Text == currentValue and Theme.Accent or Theme.Text
            end
            if not skipCallback and onChange then onChange(value) end
        end,
    }
end

-- 颜色选择器控件
function Controls.CreateColorPicker(parent, label, defaultColor, onChange, tooltip)
    defaultColor = defaultColor or "#4a7dff"

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local labelText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = label or "颜色选择器",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local rowFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundTransparency = 1,
        Parent = container,
    })

    -- 颜色预览
    local colorPreview = RoundFrame.new({
        Name = "ColorPreview",
        Radius = 6,
        Type = "Circle",
        Size = UDim2.new(0, 30, 0, 30),
        ImageColor3 = HexToColor3(defaultColor),
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        Parent = rowFrame,
    })

    local previewStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.5,
        Thickness = 1,
        Parent = colorPreview.Instance,
    })

    -- Hex输入框
    local hexInputBg = RoundFrame.new({
        Name = "HexInputBg",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        ImageColor3 = Theme.InputBackground,
        ImageTransparency = 0,
        Parent = rowFrame,
    })

    local hexStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.5,
        Thickness = 1,
        Parent = hexInputBg.Instance,
    })

    local hexPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = hexInputBg.Instance,
    })

    local hexLabel = Create("TextLabel", {
        Size = UDim2.new(0, 30, 1, 0),
        BackgroundTransparency = 1,
        Text = "HEX",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = hexInputBg.Instance,
    })

    local hexInput = Create("TextBox", {
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text = defaultColor,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = hexInputBg.Instance,
    })

    local currentColor = defaultColor

    local function updateColor(hex)
        hex = hex:upper()
        if hex:sub(1, 1) ~= "#" then
            hex = "#" .. hex
        end
        -- 验证hex格式
        if hex:match("^#%x%x%x%x%x%x$") then
            currentColor = hex
            colorPreview.Instance.ImageColor3 = HexToColor3(hex)
            if onChange then onChange(hex) end
        end
    end

    hexInput.FocusLost:Connect(function()
        updateColor(hexInput.Text)
        hexInput.Text = currentColor
    end)

    -- 点击预览打开颜色对话框（简化版：直接输入hex）
    colorPreview.Instance.MouseButton1Click:Connect(function()
        hexInput:CaptureFocus()
    end)

    return {
        Container = container,
        ColorPreview = colorPreview,
        HexInput = hexInput,
        GetValue = function() return currentColor end,
        SetValue = function(_, hex, skipCallback)
            currentColor = hex
            colorPreview.Instance.ImageColor3 = HexToColor3(hex)
            hexInput.Text = hex
            if not skipCallback and onChange then onChange(hex) end
        end,
    }
end

-- 按键绑定控件
function Controls.CreateKeybind(parent, label, defaultKey, onChange, tooltip)
    defaultKey = defaultKey or Enum.KeyCode.F

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local labelText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = label or "按键绑定",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local keyBg = RoundFrame.new({
        Name = "KeybindBg",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        ImageColor3 = Theme.InputBackground,
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        Parent = container,
    })

    local keyStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.5,
        Thickness = 1,
        Parent = keyBg.Instance,
    })

    local keyText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = defaultKey.Name,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Parent = keyBg.Instance,
    })

    local isListening = false
    local currentKey = defaultKey

    local function startListening()
        isListening = true
        keyText.Text = "按下任意键..."
        keyText.TextColor3 = Theme.Accent
        Tween(keyStroke, { Color = Theme.Accent, Transparency = 0 }, 0.15):Play()
    end

    local function stopListening()
        isListening = false
        keyText.Text = currentKey.Name
        keyText.TextColor3 = Theme.Text
        Tween(keyStroke, { Color = Theme.Border, Transparency = 0.5 }, 0.15):Play()
    end

    keyBg.Instance.MouseButton1Click:Connect(function()
        if not isListening then
            startListening()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not isListening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape then
                stopListening()
                return
            end
            currentKey = input.KeyCode
            keyText.Text = currentKey.Name
            stopListening()
            if onChange then onChange(currentKey) end
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- 点击外部取消
            task.delay(0.1, function()
                if isListening then
                    stopListening()
                end
            end)
        end
    end)

    return {
        Container = container,
        KeyBg = keyBg,
        GetValue = function() return currentKey end,
        SetValue = function(_, keyCode, skipCallback)
            currentKey = keyCode
            keyText.Text = keyCode.Name
            if not skipCallback and onChange then onChange(keyCode) end
        end,
    }
end

-- 代码块控件
function Controls.CreateCodeBlock(parent, codeText, tooltip)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = container,
    })

    local headerLabel = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "示例代码",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    local copyBtn = Create("TextButton", {
        Size = UDim2.new(0, 60, 1, 0),
        BackgroundTransparency = 1,
        Text = "复制",
        TextColor3 = Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AutoButtonColor = false,
        Parent = header,
    })

    copyBtn.MouseEnter:Connect(function()
        copyBtn.TextColor3 = Theme.AccentDim
    end)
    copyBtn.MouseLeave:Connect(function()
        copyBtn.TextColor3 = Theme.Accent
    end)

    local codeBg = RoundFrame.new({
        Name = "CodeBg",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 1, -28),
        Position = UDim2.new(0, 0, 0, 28),
        ImageColor3 = Theme.CodeBackground,
        ImageTransparency = 0,
        ClipsDescendants = true,
        Parent = container,
    })

    local codePadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = codeBg.Instance,
    })

    local codeLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = codeText or "-- 示例代码\nprint(\"Hello, WindUI!\")",
        TextColor3 = Color3.fromHex("#e6e6e6"),
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = codeBg.Instance,
    })

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(codeText or "")
            copyBtn.Text = "已复制!"
            task.delay(1.5, function()
                copyBtn.Text = "复制"
            end)
        end
    end)

    return {
        Container = container,
        CodeLabel = codeLabel,
        CopyBtn = copyBtn,
        SetCode = function(_, text)
            codeLabel.Text = text
            codeText = text
        end,
    }
end

-- 分组容器控件
function Controls.CreateGroup(parent, title)
    local groupFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title or "分组",
        TextColor = Theme.TextDim,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = groupFrame,
    })

    local contentFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = groupFrame,
    })

    local contentLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = contentFrame,
    })

    return {
        Container = groupFrame,
        Content = contentFrame,
        Layout = contentLayout,
    }
end

-- 进度条控件
function Controls.CreateProgressBar(parent, label, progress, tooltip)
    progress = progress or 0

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local topRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Parent = container,
    })

    local labelText = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = label or "进度条",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topRow,
    })

    local percentText = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = tostring(math.floor(progress * 100)) .. "%",
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Parent = topRow,
    })

    local barBg = RoundFrame.new({
        Name = "ProgressBg",
        Radius = 4,
        Type = "Circle",
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        ImageColor3 = Theme.SliderBackground,
        ImageTransparency = 0,
        Parent = container,
    })

    local barFill = RoundFrame.new({
        Name = "ProgressFill",
        Radius = 4,
        Type = "Circle",
        Size = UDim2.new(progress, 0, 1, 0),
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0,
        Parent = barBg.Instance,
    })

    return {
        Container = container,
        BarBg = barBg,
        BarFill = barFill,
        SetProgress = function(_, value)
            progress = math.clamp(value, 0, 1)
            barFill.Instance.Size = UDim2.new(progress, 0, 1, 0)
            percentText.Text = tostring(math.floor(progress * 100)) .. "%"
        end,
        GetProgress = function() return progress end,
    }
end

-- 图片/图标显示控件
function Controls.CreateImage(parent, iconName, size, tooltip)
    local container = Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local icon = CreateIcon(iconName, size or UDim2.new(0, 48, 0, 48), Theme.Icon, container)

    return {
        Container = container,
        Icon = icon,
        SetIcon = function(_, name)
            icon.Image = Icons[name] or Icons.info
        end,
        SetColor = function(_, color)
            icon.ImageColor3 = color
        end,
    }
end

-- ============================================================
-- 3D视口
-- ============================================================
local Viewport3D = {}
Viewport3D.__index = Viewport3D

function Viewport3D.new(parent)
    local self = setmetatable({}, Viewport3D)
    self.Parent = parent

    -- 视口容器
    self.Container = RoundFrame.new({
        Name = "Viewport3D",
        Radius = 8,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.Dialog,
        ImageTransparency = 0.1,
        ClipsDescendants = true,
        Parent = parent,
    })

    -- ViewportFrame
    self.Viewport = Create("ViewportFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Ambient = Color3.new(0.8, 0.8, 0.8),
        LightColor = Color3.new(1, 1, 1),
        LightDirection = Vector3.new(1, 1, 1),
        Parent = self.Container.Instance,
    })

    -- 相机
    self.Camera = Create("Camera", {
        FieldOfView = 50,
        CFrame = CFrame.new(Vector3.new(0, 2, 5), Vector3.new(0, 1.5, 0)),
        Parent = self.Viewport,
    })
    self.Viewport.CurrentCamera = self.Camera

    -- 世界模型
    self.WorldModel = Create("WorldModel", {
        Parent = self.Viewport,
    })

    -- 地面
    local ground = Create("Part", {
        Size = Vector3.new(10, 0.2, 10),
        Position = Vector3.new(0, 0, 0),
        Color = Color3.fromHex("#252530"),
        Material = Enum.Material.SmoothPlastic,
        Anchored = true,
        CanCollide = false,
        Parent = self.WorldModel,
    })
    local groundMesh = Create("SpecialMesh", {
        MeshType = Enum.MeshType.Brick,
        Parent = ground,
    })

    self.CharacterModel = nil
    self:LoadCharacter()

    return self
end

function Viewport3D:LoadCharacter()
    task.spawn(function()
        -- 等待角色加载（最多等10秒）
        local timeout = 10
        local startTime = os.clock()
        while not LocalPlayer.Character and os.clock() - startTime < timeout do
            task.wait(0.1)
        end

        local character = LocalPlayer.Character
        if not character then return end

        -- 等待角色的 Humanoid 和 HumanoidRootPart 加载
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not hrp or not humanoid then return end

        -- 清除旧模型
        if self.CharacterModel then
            self.CharacterModel:Destroy()
        end

        -- 克隆角色
        local success, clonedChar = pcall(function()
            return character:Clone()
        end)
        if not success or not clonedChar then return end

        clonedChar.Name = "ViewportCharacter"
        clonedChar:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, math.rad(25), 0))
        clonedChar.Parent = self.WorldModel

        -- 清理脚本和不必要的对象，保留Humanoid用于渲染
        for _, child in ipairs(clonedChar:GetDescendants()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                child:Destroy()
            elseif child:IsA("Humanoid") then
                child.DisplayName = ""
                child.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
                child:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                child.AutoRotate = false
            end
        end

        -- 让角色面向前方（静态，不旋转）
        self.CharacterModel = clonedChar

        -- 相机对准角色
        local vpHRP = clonedChar:FindFirstChild("HumanoidRootPart")
        if vpHRP then
            self.Camera.CFrame = CFrame.new(
                vpHRP.Position + Vector3.new(0, 1.5, 4.5),
                vpHRP.Position + Vector3.new(0, 1.5, 0)
            )
        end

        -- 角色重生时重新加载
        LocalPlayer.CharacterAdded:Connect(function()
            task.delay(2, function()
                self:LoadCharacter()
            end)
        end)
    end)
end

function Viewport3D:Refresh()
    self:LoadCharacter()
end

-- ============================================================
-- 主 WindUI 类
-- ============================================================
local WindUI = {}
WindUI.__index = WindUI

function WindUI.new()
    local self = setmetatable({}, WindUI)

    -- 初始化管理器
    self.Config = ConfigManager.new()
    self.Scale = self.Config:Get("Scale") or 1
    self.IsOpen = false
    self.IsMaximized = false
    self.CurrentTab = 1

    -- 回调
    self.OnOpenCallback = nil
    self.OnCloseCallback = nil
    self.OnDestroyCallback = nil

    -- 顶部栏按钮可见性
    self.TopbarButtonsEnabled = {
        Minimize = true,
        Maximize = true,
        Close = true,
    }

    -- 创建ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "WindUI_MainPanel",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })

    -- UIScale
    self.UIScale = Create("UIScale", {
        Scale = self.Scale,
        Parent = self.ScreenGui,
    })

    -- 初始化管理器
    self.Notifications = NotificationManager.new(self.ScreenGui)
    self.Tooltips = TooltipManager.new(self.ScreenGui)

    -- 构建窗口
    self:BuildWindow()

    -- 构建3个Tab
    self:BuildTabs()

    -- 构建3D视口
    self:BuildViewport()

    -- 构建关闭确认对话框
    self:BuildCloseDialog()

    -- 注册快捷键
    self:RegisterKeybinds()

    -- 加载配置值到控件
    self:LoadConfigToControls()

    -- 初始化显示状态（默认打开）
    self:打开()

    return self
end

-- 构建主窗口
function WindUI:BuildWindow()
    local configSize = self.Config:Get("WindowSize")
    local windowSize = Vector2.new(configSize.X or 580, configSize.Y or 440)

    -- 主窗口容器
    self.WindowContainer = Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Visible = false,
        Parent = self.ScreenGui,
    })

    -- 窗口主体
    self.WindowFrame = RoundFrame.new({
        Name = "WindowBody",
        Radius = 12,
        Type = "Squircle",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.Background,
        ImageTransparency = Theme.BackgroundTransparency,
        Parent = self.WindowContainer,
    })

    -- 窗口边框
    local windowStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.4,
        Thickness = 1,
        Parent = self.WindowFrame.Instance,
    })

    -- 顶部栏
    self.Topbar = Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.WindowFrame.Instance,
    })

    local topbarBg = RoundFrame.new({
        Name = "TopbarBg",
        Radius = 12,
        Type = "Squircle-TL-TR",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.Topbar,
        ImageTransparency = Theme.TopbarTransparency,
        Parent = self.Topbar,
    })

    -- 顶部栏底部分割线
    local topbarDivider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.5,
        Parent = self.Topbar,
    })

    -- 左侧：图标 + 标题 + 副标题
    local leftContainer = Create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.Topbar,
    })

    local leftLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = leftContainer,
    })

    local leftPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        Parent = leftContainer,
    })

    -- 窗口图标
    self.WindowIcon = CreateIcon("home", UDim2.new(0, 20, 0, 20), Theme.Accent, leftContainer)
    self.WindowIcon.LayoutOrder = 1

    -- 标题文字容器
    local titleContainer = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = leftContainer,
    })

    local titleLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = titleContainer,
    })

    self.TitleLabel = Create("TextLabel", {
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "主面板",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = titleContainer,
    })

    self.AuthorLabel = Create("TextLabel", {
        Size = UDim2.new(0, 0, 0, 12),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = titleContainer,
    })

    -- 右侧：搜索框 + 系统按钮
    local rightContainer = Create("Frame", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.Topbar,
    })

    local rightLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = rightContainer,
    })

    local rightPadding = Create("UIPadding", {
        PaddingRight = UDim.new(0, 10),
        Parent = rightContainer,
    })

    -- 搜索框
    self.SearchContainer = Create("Frame", {
        Size = UDim2.new(0, 140, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = rightContainer,
    })

    local searchBg = RoundFrame.new({
        Name = "SearchBg",
        Radius = 6,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.InputBackground,
        ImageTransparency = 0,
        Parent = self.SearchContainer,
    })

    local searchPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = searchBg.Instance,
    })

    local searchInnerLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = searchBg.Instance,
    })

    local searchIcon = CreateIcon("search", UDim2.new(0, 14, 0, 14), Theme.TextDim, searchBg.Instance)
    searchIcon.LayoutOrder = 1

    self.SearchInput = Create("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "搜索...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        LayoutOrder = 2,
        Parent = searchBg.Instance,
    })

    -- 最小化按钮
    self.MinimizeBtn = self:CreateTopbarButton("minimize", 2, "最小化")
    self.MinimizeBtn.Parent = rightContainer

    -- 最大化按钮
    self.MaximizeBtn = self:CreateTopbarButton("maximize", 3, "最大化")
    self.MaximizeBtn.Parent = rightContainer

    -- 关闭按钮
    self.CloseBtn = self:CreateTopbarButton("x", 4, "关闭")
    self.CloseBtn.ImageLabel.ImageColor3 = Theme.Error
    self.CloseBtn.Parent = rightContainer

    -- 最小化按钮点击
    self.MinimizeBtn.Button.MouseButton1Click:Connect(function()
        self:关闭()
    end)

    -- 最大化按钮点击
    self.MaximizeBtn.Button.MouseButton1Click:Connect(function()
        self:ToggleMaximize()
    end)

    -- 关闭按钮点击
    self.CloseBtn.Button.MouseButton1Click:Connect(function()
        self:ShowCloseDialog()
    end)

    -- 主体区域（侧边栏 + 内容区）
    self.BodyContainer = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.WindowFrame.Instance,
    })

    -- 侧边栏
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.BodyContainer,
    })

    local sidebarBg = RoundFrame.new({
        Name = "SidebarBg",
        Radius = 0,
        Type = "Square",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.Sidebar,
        ImageTransparency = Theme.SidebarTransparency,
        Parent = self.Sidebar,
    })

    -- 侧边栏右侧分割线
    local sidebarDivider = Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.5,
        Parent = self.Sidebar,
    })

    local sidebarPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = self.Sidebar,
    })

    self.SidebarLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = self.Sidebar,
    })

    -- 内容区
    self.ContentContainer = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 140, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.BodyContainer,
    })

    local contentPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        Parent = self.ContentContainer,
    })

    -- Tab页面容器
    self.TabPages = {}
    self.TabButtons = {}

    -- 底部拖动条
    self.DragBar = Create("Frame", {
        Name = "DragBar",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundTransparency = 1,
        Parent = self.WindowFrame.Instance,
        ZIndex = 10,
    })

    -- 右下角缩放手柄
    self.ResizeHandle = Create("TextButton", {
        Name = "ResizeHandle",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = self.WindowFrame.Instance,
        ZIndex = 11,
    })

    local resizeIcon = CreateIcon("maximize2", UDim2.new(0, 12, 0, 12), Theme.TextDim, self.ResizeHandle)
    resizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    resizeIcon.Position = UDim2.new(0.5, 2, 0.5, 2)
    resizeIcon.Rotation = 45

    -- 注册拖动
    self:RegisterDrag()
    self:RegisterResize()

    -- 搜索功能
    self.SearchInput.FocusLost:Connect(function(enterPressed)
        self:FilterTabs(self.SearchInput.Text)
    end)
    self.SearchInput.Changed:Connect(function(prop)
        if prop == "Text" then
            self:FilterTabs(self.SearchInput.Text)
        end
    end)
end

-- 创建顶部栏按钮
function WindUI:CreateTopbarButton(iconName, order, tooltip)
    local btnFrame = Create("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    })

    local btnBg = RoundFrame.new({
        Name = "ButtonBg",
        Radius = 6,
        Type = "Circle",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.Hover,
        ImageTransparency = 1,
        IsButton = true,
        AutoButtonColor = false,
        Parent = btnFrame,
    })

    local icon = CreateIcon(iconName, UDim2.new(0, 16, 0, 16), Theme.Icon, btnBg.Instance)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)

    btnBg.Instance.MouseEnter:Connect(function()
        Tween(btnBg.Instance, { ImageTransparency = 0 }, 0.15):Play()
    end)
    btnBg.Instance.MouseLeave:Connect(function()
        Tween(btnBg.Instance, { ImageTransparency = 1 }, 0.15):Play()
    end)

    if tooltip then
        self.Tooltips:Register(btnBg.Instance, tooltip)
    end

    return {
        Frame = btnFrame,
        Button = btnBg.Instance,
        ImageLabel = icon,
        SetVisible = function(_, visible)
            btnFrame.Visible = visible
        end,
    }
end

-- 注册窗口拖动
function WindUI:RegisterDrag()
    local isDragging = false
    local dragStart = nil
    local windowStartPos = nil

    self.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            windowStartPos = self.WindowContainer.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local viewportSize = Workspace.CurrentCamera.ViewportSize

            local newX = windowStartPos.X.Offset + delta.X
            local newY = windowStartPos.Y.Offset + delta.Y

            -- 限制在屏幕内
            local windowSize = self.WindowContainer.AbsoluteSize
            newX = math.clamp(newX, windowSize.X / 2, viewportSize.X - windowSize.X / 2)
            newY = math.clamp(newY, windowSize.Y / 2, viewportSize.Y - windowSize.Y / 2)

            self.WindowContainer.Position = UDim2.new(
                windowStartPos.X.Scale,
                newX,
                windowStartPos.Y.Scale,
                newY
            )

            -- 保存位置
            self.Config:Set("WindowPosition", {
                X = self.WindowContainer.Position.X.Offset,
                Y = self.WindowContainer.Position.Y.Offset,
            })
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
end

-- 注册窗口缩放
function WindUI:RegisterResize()
    local isResizing = false
    local resizeStart = nil
    local windowStartSize = nil
    local windowStartPos = nil
    local minSize = Vector2.new(400, 300)
    local maxSize = Vector2.new(1200, 800)

    self.ResizeHandle.MouseButton1Down:Connect(function()
        isResizing = true
        resizeStart = UserInputService:GetMouseLocation()
        windowStartSize = self.WindowContainer.AbsoluteSize
        windowStartPos = self.WindowContainer.AbsolutePosition
        self.WindowContainer.AnchorPoint = Vector2.new(0, 0)
        self.WindowContainer.Position = UDim2.new(
            0, windowStartPos.X,
            0, windowStartPos.Y
        )
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = mousePos - resizeStart

            local newWidth = math.clamp(windowStartSize.X + delta.X, minSize.X, maxSize.X)
            local newHeight = math.clamp(windowStartSize.Y + delta.Y, minSize.Y, maxSize.Y)

            self.WindowContainer.Size = UDim2.new(0, newWidth, 0, newHeight)

            -- 保存大小
            self.Config:Set("WindowSize", {
                X = newWidth,
                Y = newHeight,
            })
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isResizing then
            isResizing = false
        end
    end)
end

-- 构建侧边栏Tab和内容Tab
function WindUI:BuildTabs()
    local tabDefs = {
        { Name = "基础控件", Icon = "layoutList", Title = "📋 基础控件" },
        { Name = "高级控件", Icon = "wrench", Title = "🔧 高级控件" },
        { Name = "其他", Icon = "package", Title = "📦 布局 & 其他" },
    }

    for i, tabDef in ipairs(tabDefs) do
        -- 侧边栏Tab按钮
        local tabBtn = self:CreateSidebarTab(tabDef.Icon, tabDef.Name, i)
        table.insert(self.TabButtons, tabBtn)

        -- 内容页面
        local tabPage = Create("ScrollingFrame", {
            Name = "Tab_" .. i,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Scrollbar,
            ScrollBarImageTransparency = 0.5,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = i == 1,
            Parent = self.ContentContainer,
        })

        local tabLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = tabPage,
        })

        local tabPadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabPage,
        })

        -- Tab标题
        local tabTitle = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = tabDef.Title,
            TextColor3 = Theme.Text,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            Parent = tabPage,
        })

        local tabSubtitle = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            Parent = tabPage,
        })

        local tabContent = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 3,
            Parent = tabPage,
        })

        local contentLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            Parent = tabContent,
        })

        table.insert(self.TabPages, {
            Page = tabPage,
            Content = tabContent,
            Layout = contentLayout,
            Title = tabTitle,
            Def = tabDef,
        })
    end

    -- 构建每个Tab的控件
    self:BuildTab1Controls()
    self:BuildTab2Controls()
    self:BuildTab3Controls()
end

-- 创建侧边栏Tab按钮
function WindUI:CreateSidebarTab(iconName, label, index)
    local btnFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = index,
        Parent = self.Sidebar,
    })

    local btnBg = RoundFrame.new({
        Name = "TabBg",
        Radius = 7,
        Type = "SquircleH",
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Theme.Accent,
        ImageTransparency = index == 1 and 0.85 or 1,
        IsButton = true,
        AutoButtonColor = false,
        Parent = btnFrame,
    })

    local innerPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = btnBg.Instance,
    })

    local innerLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = btnBg.Instance,
    })

    local icon = CreateIcon(iconName, UDim2.new(0, 16, 0, 16), Theme.Icon, btnBg.Instance)
    icon.LayoutOrder = 1

    local labelText = Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = index == 1 and Theme.Text or Theme.TextDim,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        LayoutOrder = 2,
        Parent = btnBg.Instance,
    })

    btnBg.Instance.MouseEnter:Connect(function()
        if self.CurrentTab ~= index then
            Tween(btnBg.Instance, { ImageTransparency = 0.85 }, 0.15):Play()
        end
    end)
    btnBg.Instance.MouseLeave:Connect(function()
        if self.CurrentTab ~= index then
            Tween(btnBg.Instance, { ImageTransparency = 1 }, 0.15):Play()
        end
    end)
    btnBg.Instance.MouseButton1Click:Connect(function()
        self:SelectTab(index)
    end)

    return {
        Frame = btnFrame,
        Bg = btnBg,
        Icon = icon,
        Label = labelText,
        Index = index,
    }
end

-- 选择Tab
function WindUI:SelectTab(index)
    if index < 1 or index > #self.TabPages then return end
    if self.CurrentTab == index then return end

    self.CurrentTab = index

    -- 更新侧边栏按钮状态
    for i, tabBtn in ipairs(self.TabButtons) do
        local isActive = i == index
        Tween(tabBtn.Bg.Instance, { ImageTransparency = isActive and 0.85 or 1 }, 0.2):Play()
        tabBtn.Label.TextColor3 = isActive and Theme.Text or Theme.TextDim
    end

    -- 切换内容页面
    for i, tabPage in ipairs(self.TabPages) do
        tabPage.Page.Visible = i == index
    end
end

-- 搜索过滤Tab
function WindUI:FilterTabs(searchText)
    searchText = searchText:lower()
    if searchText == "" then
        for _, tabBtn in ipairs(self.TabButtons) do
            tabBtn.Frame.Visible = true
        end
        return
    end

    for i, tabBtn in ipairs(self.TabButtons) do
        local tabName = self.TabPages[i].Def.Name:lower()
        tabBtn.Frame.Visible = string.find(tabName, searchText, 1, true) ~= nil
    end
end

-- Tab 1：基础控件
function WindUI:BuildTab1Controls()
    local content = self.TabPages[1].Content

    -- 按钮
    self.Button1 = Controls.CreateButton(content, "点击我", function()
        self.Notifications:Notify("按钮点击", "你点击了按钮！", "success", 3)
    end, "点击弹出通知")

    -- 开关
    self.Toggle1 = Controls.CreateToggle(content, "启用功能", false, function(value)
        self.Config:Set("Tabs.1.Controls.toggleEnabled", value)
        self.Notifications:Notify("开关", value and "功能已启用" or "功能已禁用", value and "success" or "info", 2)
    end, "点击切换状态")

    -- 滑块
    self.Slider1 = Controls.CreateSlider(content, "音量", 0, 100, 50, function(value)
        self.Config:Set("Tabs.1.Controls.sliderVolume", value)
    end, "拖拽调整音量")

    -- 输入框
    self.Input1 = Controls.CreateInput(content, "用户名", "请输入用户名", "", function(value)
        self.Config:Set("Tabs.1.Controls.inputUsername", value)
    end, "输入文本自动保存")

    -- 下拉菜单
    self.Dropdown1 = Controls.CreateDropdown(content, "主题", { "深色", "浅色", "自动" }, "深色", function(value)
        self.Config:Set("Tabs.1.Controls.dropdownTheme", value)
    end, "选择主题")
end

-- Tab 2：高级控件
function WindUI:BuildTab2Controls()
    local content = self.TabPages[2].Content

    -- 颜色选择器
    self.ColorPicker1 = Controls.CreateColorPicker(content, "颜色选择器", "#4a7dff", function(hex)
        self.Config:Set("Tabs.2.Controls.colorPicker", hex)
    end, "点击选择颜色")

    -- 按键绑定
    self.Keybind1 = Controls.CreateKeybind(content, "按键绑定", Enum.KeyCode.F, function(keyCode)
        self.Config:Set("Tabs.2.Controls.keybind", keyCode.Name)
        self.Notifications:Notify("按键绑定", "已绑定按键: " .. keyCode.Name, "info", 2)
    end, "点击后按键盘录制按键")

    -- 代码块
    self.CodeBlock1 = Controls.CreateCodeBlock(content, [[-- WindUI 示例代码
local WindUI = loadstring(game:HttpGet("..."))()
local Window = WindUI:CreateWindow({
    Title = "主面板",
})

Window:Button("按钮", function()
    print("按钮被点击!")
end)]], "示例代码块")
end

-- Tab 3：其他
function WindUI:BuildTab3Controls()
    local content = self.TabPages[3].Content

    -- 分组容器
    local group = Controls.CreateGroup(content, "分组容器")

    -- 横向排列3个小按钮
    local btnRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = group.Content,
    })

    local btnRowLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = btnRow,
    })

    for i = 1, 3 do
        local smallBtn = RoundFrame.new({
            Radius = 6,
            Type = "SquircleH",
            Size = UDim2.new(0, 60, 0, 30),
            ImageColor3 = Theme.InputBackground,
            ImageTransparency = 0,
            IsButton = true,
            AutoButtonColor = false,
            LayoutOrder = i,
            Parent = btnRow,
        })

        local btnStroke = Create("UIStroke", {
            Color = Theme.Border,
            Transparency = 0.5,
            Thickness = 1,
            Parent = smallBtn.Instance,
        })

        local btnLabel = Create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "按钮" .. i,
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Parent = smallBtn.Instance,
        })

        smallBtn.Instance.MouseEnter:Connect(function()
            Tween(smallBtn.Instance, { ImageColor3 = Theme.Hover }, 0.15):Play()
        end)
        smallBtn.Instance.MouseLeave:Connect(function()
            Tween(smallBtn.Instance, { ImageColor3 = Theme.InputBackground }, 0.15):Play()
        end)
        smallBtn.Instance.MouseButton1Click:Connect(function()
            self.Notifications:Notify("按钮" .. i, "按钮" .. i .. "被点击", "info", 2)
        end)
    end

    -- 图片显示
    local imageGroup = Controls.CreateGroup(content, "图片")
    local imageCtrl = Controls.CreateImage(imageGroup.Content, "gem", UDim2.new(0, 48, 0, 48), "固定图标")
    imageCtrl:SetColor(Theme.Accent)

    -- 进度条
    self.Progress1 = Controls.CreateProgressBar(content, "加载进度", 0.7, "显示进度")
end

-- 构建3D视口
function WindUI:BuildViewport()
    -- 左下角3D视口
    self.ViewportContainer = Create("Frame", {
        Name = "ViewportContainer",
        Size = UDim2.new(0, 120, 0, 140),
        Position = UDim2.new(0, 10, 1, -150),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 5,
        Parent = self.WindowFrame.Instance,
    })

    self.Viewport = Viewport3D.new(self.ViewportContainer)
end

-- 构建关闭确认对话框
function WindUI:BuildCloseDialog()
    -- 遮罩
    self.DialogOverlay = Create("Frame", {
        Name = "DialogOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.6,
        Visible = false,
        ZIndex = 50,
        Parent = self.WindowContainer,
    })

    -- 对话框
    self.DialogFrame = RoundFrame.new({
        Name = "CloseDialog",
        Radius = 10,
        Type = "SquircleH",
        Size = UDim2.new(0, 300, 0, 140),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ImageColor3 = Theme.Dialog,
        ImageTransparency = 0,
        Visible = false,
        ZIndex = 51,
        Parent = self.DialogOverlay,
    })

    local dialogStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.3,
        Thickness = 1,
        Parent = self.DialogFrame.Instance,
    })

    local dialogPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        Parent = self.DialogFrame.Instance,
    })

    local dialogLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = self.DialogFrame.Instance,
    })

    -- 图标
    local dialogIcon = CreateIcon("alertCircle", UDim2.new(0, 32, 0, 32), Theme.Warning, self.DialogFrame.Instance)
    dialogIcon.LayoutOrder = 1

    -- 标题
    local dialogTitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "确定要关闭窗口吗？",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        LayoutOrder = 2,
        Parent = self.DialogFrame.Instance,
    })

    -- 按钮容器
    local btnContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        Parent = self.DialogFrame.Instance,
    })

    local btnLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = btnContainer,
    })

    -- 取消按钮
    local cancelBtn = RoundFrame.new({
        Radius = 6,
        Type = "SquircleH",
        Size = UDim2.new(0, 100, 1, 0),
        ImageColor3 = Theme.InputBackground,
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        LayoutOrder = 1,
        Parent = btnContainer,
    })

    local cancelStroke = Create("UIStroke", {
        Color = Theme.Border,
        Transparency = 0.5,
        Thickness = 1,
        Parent = cancelBtn.Instance,
    })

    local cancelLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "取消",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        Parent = cancelBtn.Instance,
    })

    cancelBtn.Instance.MouseEnter:Connect(function()
        Tween(cancelBtn.Instance, { ImageColor3 = Theme.Hover }, 0.15):Play()
    end)
    cancelBtn.Instance.MouseLeave:Connect(function()
        Tween(cancelBtn.Instance, { ImageColor3 = Theme.InputBackground }, 0.15):Play()
    end)
    cancelBtn.Instance.MouseButton1Click:Connect(function()
        self:HideCloseDialog()
    end)

    -- 关闭按钮
    local closeDialogBtn = RoundFrame.new({
        Radius = 6,
        Type = "SquircleH",
        Size = UDim2.new(0, 100, 1, 0),
        ImageColor3 = Theme.Error,
        ImageTransparency = 0,
        IsButton = true,
        AutoButtonColor = false,
        LayoutOrder = 2,
        Parent = btnContainer,
    })

    local closeDialogLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "关闭",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Parent = closeDialogBtn.Instance,
    })

    closeDialogBtn.Instance.MouseEnter:Connect(function()
        Tween(closeDialogBtn.Instance, { ImageTransparency = 0.15 }, 0.15):Play()
    end)
    closeDialogBtn.Instance.MouseLeave:Connect(function()
        Tween(closeDialogBtn.Instance, { ImageTransparency = 0 }, 0.15):Play()
    end)
    closeDialogBtn.Instance.MouseButton1Click:Connect(function()
        self:HideCloseDialog()
        self:关闭()
    end)
end

function WindUI:ShowCloseDialog()
    self.DialogOverlay.Visible = true
    self.DialogFrame.Instance.Visible = true
    -- 进入动画
    self.DialogFrame.Instance.Size = UDim2.new(0, 280, 0, 130)
    self.DialogFrame.Instance.ImageTransparency = 0.3
    Tween(self.DialogFrame.Instance, { Size = UDim2.new(0, 300, 0, 140), ImageTransparency = 0 }, 0.2, Enum.EasingStyle.Back):Play()
    Tween(self.DialogOverlay, { BackgroundTransparency = 0.6 }, 0.2):Play()
end

function WindUI:HideCloseDialog()
    Tween(self.DialogFrame.Instance, { Size = UDim2.new(0, 280, 0, 130), ImageTransparency = 0.3 }, 0.15):Play()
    Tween(self.DialogOverlay, { BackgroundTransparency = 1 }, 0.15):Play()
    task.delay(0.15, function()
        self.DialogOverlay.Visible = false
        self.DialogFrame.Instance.Visible = false
    end)
end

-- 注册快捷键
function WindUI:RegisterKeybinds()
    -- F12 切换窗口
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F12 then
            self:切换()
        end
    end)
end

-- 加载配置到控件
function WindUI:LoadConfigToControls()
    -- Tab 1
    local toggleVal = self.Config:Get("Tabs.1.Controls.toggleEnabled")
    if toggleVal ~= nil then
        self.Toggle1:SetValue(toggleVal, true)
    end

    local sliderVal = self.Config:Get("Tabs.1.Controls.sliderVolume")
    if sliderVal ~= nil then
        self.Slider1:SetValue(sliderVal, true)
    end

    local inputVal = self.Config:Get("Tabs.1.Controls.inputUsername")
    if inputVal ~= nil then
        self.Input1:SetValue(inputVal, true)
    end

    local dropdownVal = self.Config:Get("Tabs.1.Controls.dropdownTheme")
    if dropdownVal ~= nil then
        self.Dropdown1:SetValue(dropdownVal, true)
    end

    -- Tab 2
    local colorVal = self.Config:Get("Tabs.2.Controls.colorPicker")
    if colorVal ~= nil then
        self.ColorPicker1:SetValue(colorVal, true)
    end

    local keybindVal = self.Config:Get("Tabs.2.Controls.keybind")
    if keybindVal ~= nil and type(keybindVal) == "string" then
        local keyCode = Enum.KeyCode[keybindVal]
        if keyCode then
            self.Keybind1:SetValue(keyCode, true)
        end
    end

    -- 窗口位置
    local pos = self.Config:Get("WindowPosition")
    if pos and pos.X and pos.Y then
        self.WindowContainer.AnchorPoint = Vector2.new(0, 0)
        self.WindowContainer.Position = UDim2.new(0, pos.X, 0, pos.Y)
    end
end

-- ============================================================
-- 公开 API（15个函数）
-- ============================================================

-- 1. 打开窗口
function WindUI:打开()
    if self.IsOpen then return end
    self.IsOpen = true

    self.WindowContainer.Visible = true
    self.WindowContainer.AnchorPoint = self.WindowContainer.AnchorPoint

    -- 缩放进入动画
    self.UIScale.Scale = self.Scale * 0.9
    local scaleTween = Tween(self.UIScale, { Scale = self.Scale }, 0.25, Enum.EasingStyle.Back)
    scaleTween:Play()

    -- 透明度过渡
    self.WindowFrame.Instance.ImageTransparency = 1
    local fadeTween = Tween(self.WindowFrame.Instance, { ImageTransparency = Theme.BackgroundTransparency }, 0.2)
    fadeTween:Play()

    if self.OnOpenCallback then
        self.OnOpenCallback()
    end
end

-- 2. 关闭窗口
function WindUI:关闭()
    if not self.IsOpen then return end
    self.IsOpen = false

    local closeTween = Tween(self.WindowFrame.Instance, { ImageTransparency = 1 }, 0.2)
    closeTween:Play()

    task.delay(0.2, function()
        self.WindowContainer.Visible = false
    end)

    if self.OnCloseCallback then
        self.OnCloseCallback()
    end
end

-- 3. 销毁窗口
function WindUI:销毁()
    if self.OnDestroyCallback then
        self.OnDestroyCallback()
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    self = nil
end

-- 4. 切换窗口
function WindUI:切换()
    if self.IsOpen then
        self:关闭()
    else
        self:打开()
    end
end

-- 5. 设置大小
function WindUI:设置大小(size)
    if typeof(size) == "Vector2" then
        self.WindowContainer.Size = UDim2.new(0, size.X, 0, size.Y)
        self.Config:Set("WindowSize", { X = size.X, Y = size.Y })
    elseif type(size) == "table" and size.X and size.Y then
        self.WindowContainer.Size = UDim2.new(0, size.X, 0, size.Y)
        self.Config:Set("WindowSize", { X = size.X, Y = size.Y })
    end
end

-- 6. 设置标题
function WindUI:设置标题(text)
    self.TitleLabel.Text = text or "主面板"
end

-- 7. 设置作者（副标题）
function WindUI:设置作者(text)
    self.AuthorLabel.Text = text or ""
end

-- 8. 移动屏幕中央
function WindUI:移动屏幕中央()
    self.WindowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    self.WindowContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Config:Set("WindowPosition", nil)
end

-- 9. 获取缩放比例
function WindUI:获取缩放比例()
    return self.Scale
end

-- 10. 设置缩放比例
function WindUI:设置缩放比例(scale)
    scale = tonumber(scale) or 1
    scale = math.clamp(scale, 0.5, 2)
    self.Scale = scale
    self.UIScale.Scale = scale
    self.Config:Set("Scale", scale)
end

-- 11. 选择标签页
function WindUI:选择标签页(index)
    self:SelectTab(tonumber(index) or 1)
end

-- 12. 禁用顶部栏按钮
function WindUI:禁用顶部栏按钮(buttonList)
    if type(buttonList) ~= "table" then return end

    for _, btnName in ipairs(buttonList) do
        if btnName == "Minimize" or btnName == "最小化" then
            self.MinimizeBtn:SetVisible(false)
            self.TopbarButtonsEnabled.Minimize = false
        elseif btnName == "Maximize" or btnName == "最大化" then
            self.MaximizeBtn:SetVisible(false)
            self.TopbarButtonsEnabled.Maximize = false
        elseif btnName == "Close" or btnName == "关闭" then
            self.CloseBtn:SetVisible(false)
            self.TopbarButtonsEnabled.Close = false
        end
    end
end

-- 13. 窗口打开时触发
function WindUI:窗口打开时触发(callback)
    if type(callback) == "function" then
        self.OnOpenCallback = callback
    end
end

-- 14. 窗口关闭时触发
function WindUI:窗口关闭时触发(callback)
    if type(callback) == "function" then
        self.OnCloseCallback = callback
    end
end

-- 15. 窗口销毁时触发
function WindUI:窗口销毁时触发(callback)
    if type(callback) == "function" then
        self.OnDestroyCallback = callback
    end
end

-- 内部：最大化切换
function WindUI:ToggleMaximize()
    if self.IsMaximized then
        -- 还原
        self.IsMaximized = false
        local configSize = self.Config:Get("WindowSize")
        Tween(self.WindowContainer, {
            Size = UDim2.new(0, configSize.X, 0, configSize.Y),
        }, 0.25):Play()
        if self._prevPos then
            Tween(self.WindowContainer, { Position = self._prevPos }, 0.25):Play()
            self.WindowContainer.AnchorPoint = self._prevAnchor
        end
    else
        -- 最大化
        self.IsMaximized = true
        self._prevPos = self.WindowContainer.Position
        self._prevAnchor = self.WindowContainer.AnchorPoint

        local viewportSize = Workspace.CurrentCamera.ViewportSize
        self.WindowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        Tween(self.WindowContainer, {
            Size = UDim2.new(0, viewportSize.X - 40, 0, viewportSize.Y - 40),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }, 0.25):Play()
    end
end

-- ============================================================
-- 标签页() - 返回已有Tab供外部调用（简化版，不可新建）
-- ============================================================
function WindUI:标签页()
    return self.TabPages
end

-- ============================================================
-- 初始化并返回 API
-- ============================================================
local MainPanel = WindUI.new()

-- 公开的 API 表
local API = {
    打开 = function() MainPanel:打开() end,
    关闭 = function() MainPanel:关闭() end,
    销毁 = function() MainPanel:销毁() end,
    切换 = function() MainPanel:切换() end,
    设置大小 = function(size) MainPanel:设置大小(size) end,
    设置标题 = function(text) MainPanel:设置标题(text) end,
    设置作者 = function(text) MainPanel:设置作者(text) end,
    移动屏幕中央 = function() MainPanel:移动屏幕中央() end,
    获取缩放比例 = function() return MainPanel:获取缩放比例() end,
    设置缩放比例 = function(scale) MainPanel:设置缩放比例(scale) end,
    选择标签页 = function(index) MainPanel:选择标签页(index) end,
    禁用顶部栏按钮 = function(list) MainPanel:禁用顶部栏按钮(list) end,
    窗口打开时触发 = function(callback) MainPanel:窗口打开时触发(callback) end,
    窗口关闭时触发 = function(callback) MainPanel:窗口关闭时触发(callback) end,
    窗口销毁时触发 = function(callback) MainPanel:窗口销毁时触发(callback) end,

    -- 通知（额外提供，方便外部调用）
    通知 = function(title, text, notifType, duration)
        MainPanel.Notifications:Notify(title, text, notifType, duration)
    end,

    -- 标签页（简化版：返回已有Tab）
    标签页 = function()
        return MainPanel:标签页()
    end,
}

return API
