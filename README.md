-- ================================================================
-- WindUI 独立版 v4.0（基于差异清单补全）
-- 补全内容：
-- 1. 图标库扩展至 60+ 个常用图标 ID
-- 2. 形状系统：SquircleH、SquircleV、Glass、Outline
-- 3. 新增 ColorPicker、Keybind、ProgressBar 控件
-- 4. 窗口新增 SubTitle、透明模式、热键最小化
-- 5. 新增 Dialog 对话框
-- 6. 模拟 Acrylic 毛玻璃效果
-- 7. 完善事件管理
-- ================================================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- ================================================================
-- 工具函数
-- ================================================================
local function New(className, props, children)
    local obj = Instance.new(className)
    local defaults = {
        Frame = { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1,1,1) },
        TextLabel = { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Text = "", RichText = true, TextColor3 = Color3.new(1,1,1), TextSize = 14 },
        TextButton = { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Text = "", AutoButtonColor = false, TextColor3 = Color3.new(1,1,1), TextSize = 14 },
        TextBox = { BackgroundColor3 = Color3.new(1,1,1), BorderColor3 = Color3.new(0,0,0), ClearTextOnFocus = false, Text = "", TextColor3 = Color3.new(0,0,0), TextSize = 14 },
        ImageLabel = { BackgroundTransparency = 1, BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 },
        ImageButton = { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, AutoButtonColor = false },
        UIListLayout = { SortOrder = "LayoutOrder" },
        ScrollingFrame = { ScrollBarImageTransparency = 1, BorderSizePixel = 0 },
        UICorner = { CornerRadius = UDim.new(0,0) },
        UIPadding = { PaddingTop = UDim.new(0,0), PaddingBottom = UDim.new(0,0), PaddingLeft = UDim.new(0,0), PaddingRight = UDim.new(0,0) },
        UIScale = { Scale = 1 },
        UIStroke = { Thickness = 1, Color = Color3.new(1,1,1), Transparency = 0 },
        UIGradient = { Rotation = 0 },
    }
    local def = defaults[className] or {}
    for k,v in pairs(def) do obj[k] = v end
    if props then
        for k,v in pairs(props) do
            if k ~= "Children" and k ~= "ThemeTag" then
                obj[k] = v
            end
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

local function Tween(obj, duration, props, easing, dir)
    return TweenService:Create(obj, TweenInfo.new(duration, easing or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function GenerateGUID()
    return HttpService:GenerateGUID(false)
end

local function SafeCallback(fn, ...)
    if fn then pcall(fn, ...) end
end

-- 信号管理（自动断开）
local Signals = {}
local function AddSignal(obj, cb)
    local conn = obj:Connect(cb)
    table.insert(Signals, conn)
    return conn
end

local function DisconnectAll()
    for _, conn in ipairs(Signals) do
        pcall(conn.Disconnect, conn)
    end
    Signals = {}
end

local CurrentInput = nil
local function Drag(frame, dragObjs, cb, guid)
    guid = guid or GenerateGUID()
    local dragging = false
    local startPos, startInput
    local can = true
    local objs = dragObjs or { frame }
    for _, obj in ipairs(objs) do
        obj.InputBegan:Connect(function(input)
            if dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if CurrentInput and CurrentInput ~= guid then return end
            CurrentInput = guid
            dragging = true
            startInput = input.Position
            startPos = frame.Position
            if cb then cb(true) end
        end)
    end
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not can then return end
        if CurrentInput and CurrentInput ~= guid then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - startInput
            Tween(frame, 0.02, {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            CurrentInput = nil
            dragging = false
            if cb then cb(false) end
        end
    end)
    return { Set = function(_, v) can = v end }
end

-- ================================================================
-- 主题系统（完整版）
-- ================================================================
local Themes = {
    Dark = {
        Name = "Dark",
        WindowBackground = Color3.fromHex("#18181b"),
        SubTitle = Color3.fromHex("#888888"),
        Text = Color3.fromHex("#ffffff"),
        Placeholder = Color3.fromHex("#a1a1a1"),
        Button = Color3.fromHex("#52525b"),
        ElementBackground = Color3.fromHex("#2A2A2C"),
        ElementBackgroundTransparency = 0,
        PanelBackground = Color3.fromHex("#ffffff"),
        PanelBackgroundTransparency = 0.95,
        Toggle = Color3.fromHex("#33C759"),
        Slider = Color3.fromHex("#0091FF"),
        Primary = Color3.fromHex("#0091FF"),
        TabBackground = Color3.fromHex("#2A2A2C"),
        TabBackgroundHover = Color3.fromHex("#3A3A3C"),
        TabBackgroundActive = Color3.fromHex("#3A3A3C"),
        TabText = Color3.fromHex("#ffffff"),
        TabTextTransparency = 0.4,
        TabTextActiveTransparency = 0,
        Shadow = Color3.fromHex("#000000"),
        ShadowTransparency = 0.55,
        Dialog = Color3.fromHex("#1a1a1a"),
        Icon = Color3.fromHex("#a1a1aa"),
        AcrylicMain = Color3.fromHex("#18181b"),
        AcrylicMainTransparency = 0.85,
        AcrylicNoise = 0.9,
    },
    Light = {
        Name = "Light",
        WindowBackground = Color3.fromHex("#f0f0f0"),
        SubTitle = Color3.fromHex("#666666"),
        Text = Color3.fromHex("#000000"),
        Placeholder = Color3.fromHex("#555555"),
        Button = Color3.fromHex("#18181b"),
        ElementBackground = Color3.fromHex("#ffffff"),
        ElementBackgroundTransparency = 0,
        PanelBackground = Color3.fromHex("#efefef"),
        PanelBackgroundTransparency = 0,
        Toggle = Color3.fromHex("#33C759"),
        Slider = Color3.fromHex("#0091FF"),
        Primary = Color3.fromHex("#0091FF"),
        TabBackground = Color3.fromHex("#ffffff"),
        TabBackgroundHover = Color3.fromHex("#f3f3f3"),
        TabBackgroundActive = Color3.fromHex("#efefef"),
        TabText = Color3.fromHex("#000000"),
        TabTextTransparency = 0.3,
        TabTextActiveTransparency = 0,
        Shadow = Color3.fromHex("#000000"),
        ShadowTransparency = 0.25,
        Dialog = Color3.fromHex("#f4f4f5"),
        Icon = Color3.fromHex("#52525b"),
        AcrylicMain = Color3.fromHex("#f0f0f0"),
        AcrylicMainTransparency = 0.8,
        AcrylicNoise = 0.85,
    },
}

local CurrentThemeName = "Dark"
local Theme = Themes.Dark
local ThemeObjects = {}

function GetThemeProperty(prop)
    return Theme[prop]
end

function SetTheme(name)
    if Themes[name] then
        CurrentThemeName = name
        Theme = Themes[name]
        for obj, tag in pairs(ThemeObjects) do
            ApplyThemeTag(obj, tag)
        end
    end
end

function AddThemeObject(obj, tag)
    ThemeObjects[obj] = tag
    ApplyThemeTag(obj, tag)
end

function ApplyThemeTag(obj, tag)
    for prop, key in pairs(tag) do
        local val = GetThemeProperty(key)
        if val ~= nil then
            if typeof(val) == "Color3" then
                obj[prop] = val
            elseif typeof(val) == "number" then
                obj[prop] = val
            elseif typeof(val) == "table" and val.Color and val.Transparency then
                local grad = obj:FindFirstChild("_theme_grad")
                if not grad then
                    grad = New("UIGradient", { Name = "_theme_grad", Parent = obj })
                end
                grad.Color = val.Color
                grad.Transparency = val.Transparency
            end
        end
    end
end

-- ================================================================
-- 图标系统（扩展至 60+ 个）
-- ================================================================
local IconData = {}

function AddIcon(name, image, rectSize, rectPos)
    IconData[name] = { Image = image, RectSize = rectSize or Vector2.new(0,0), RectPos = rectPos or Vector2.new(0,0) }
end

function GetIcon(name)
    return IconData[name]
end

function CreateIcon(name, size, parent, props)
    local data = GetIcon(name)
    if not data then return nil end
    local img = New("ImageLabel", {
        Image = data.Image,
        Size = size or UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        ImageRectSize = data.RectSize,
        ImageRectOffset = data.RectPos,
        Parent = parent,
    })
    if props then
        for k,v in pairs(props) do
            img[k] = v
        end
    end
    return img
end

-- ===== 60+ 个常用图标 ID =====
local function LoadIcons()
    -- 窗口控制
    AddIcon("close", "rbxassetid://110786993356448")
    AddIcon("minimize", "rbxassetid://123467780715624")
    AddIcon("maximize", "rbxassetid://137492887754537")
    AddIcon("expand", "rbxassetid://137492887754537")
    AddIcon("chevron_down", "rbxassetid://134243273101015")
    AddIcon("chevron_up", "rbxassetid://122444883127455")
    AddIcon("chevron_left", "rbxassetid://73780377692148")
    AddIcon("chevron_right", "rbxassetid://92473583511724")
    AddIcon("window_icon", "rbxassetid://122180020814574")

    -- 导航
    AddIcon("home", "rbxassetid://98755624629571")
    AddIcon("settings", "rbxassetid://80758916183665")
    AddIcon("user", "rbxassetid://81589895647169")
    AddIcon("users", "rbxassetid://115398113982385")
    AddIcon("folder", "rbxassetid://121178377882882")
    AddIcon("search", "rbxassetid://121018724060431")
    AddIcon("bell", "rbxassetid://97392696311902")
    AddIcon("heart", "rbxassetid://116559368303288")
    AddIcon("star", "rbxassetid://136141469398409")
    AddIcon("bookmark", "rbxassetid://121093149326239")

    -- 安全
    AddIcon("lock", "rbxassetid://134724289526879")
    AddIcon("lock_open", "rbxassetid://93597915325122")
    AddIcon("key", "rbxassetid://96510194465420")
    AddIcon("shield", "rbxassetid://110987169760162")
    AddIcon("shield_check", "rbxassetid://87354736164608")

    -- 媒体
    AddIcon("book", "rbxassetid://125383279695672")
    AddIcon("film", "rbxassetid://120978945609706")
    AddIcon("music", "rbxassetid://113343203848535")
    AddIcon("gamepad", "rbxassetid://121607283959010")
    AddIcon("headphones", "rbxassetid://118833729589183")
    AddIcon("camera", "rbxassetid://79950339943067")
    AddIcon("image", "rbxassetid://112751259236831")
    AddIcon("video", "rbxassetid://107587444636945")

    -- 开发
    AddIcon("code", "rbxassetid://107380207681249")
    AddIcon("terminal", "rbxassetid://106783148545356")
    AddIcon("database", "rbxassetid://126791525623846")
    AddIcon("server", "rbxassetid://92188766517878")
    AddIcon("cpu", "rbxassetid://77549309870247")
    AddIcon("layers", "rbxassetid://81973586053257")
    AddIcon("grid", "rbxassetid://81344910161871")
    AddIcon("layout", "rbxassetid://112556185960101")

    -- 网络
    AddIcon("cloud", "rbxassetid://121226497050352")
    AddIcon("wifi", "rbxassetid://104669375183960")
    AddIcon("globe", "rbxassetid://114238209622913")
    AddIcon("flag", "rbxassetid://78183383236196")
    AddIcon("link", "rbxassetid://131607023382430")
    AddIcon("external", "rbxassetid://129331830773832")

    -- 工具
    AddIcon("check", "rbxassetid://93898873302694")
    AddIcon("x", "rbxassetid://110786993356448")
    AddIcon("plus", "rbxassetid://111774323017047")
    AddIcon("minus", "rbxassetid://118026365011536")
    AddIcon("trash", "rbxassetid://106723740584310")
    AddIcon("edit", "rbxassetid://72037878096321")
    AddIcon("copy", "rbxassetid://78979572434545")
    AddIcon("paste", "rbxassetid://74382068849983")
    AddIcon("download", "rbxassetid://134814648082393")
    AddIcon("upload", "rbxassetid://138212042425501")

    -- 杂项
    AddIcon("calendar", "rbxassetid://114792700814035")
    AddIcon("clock", "rbxassetid://121808839832144")
    AddIcon("mail", "rbxassetid://103945161245599")
    AddIcon("message", "rbxassetid://127255077587058")
    AddIcon("notification", "rbxassetid://136219289862706")
    AddIcon("tag", "rbxassetid://129104970103940")
    AddIcon("gift", "rbxassetid://109855212076373")
    AddIcon("trophy", "rbxassetid://131545003268773")
    AddIcon("medal", "rbxassetid://79016002264450")
    AddIcon("fire", "rbxassetid://98218034436456")

    -- 方向
    AddIcon("arrow_up", "rbxassetid://89282378235317")
    AddIcon("arrow_down", "rbxassetid://98764963621439")
    AddIcon("arrow_left", "rbxassetid://102531941843733")
    AddIcon("arrow_right", "rbxassetid://113692007244654")
    AddIcon("arrow_up_right", "rbxassetid://129280608535523")
    AddIcon("arrow_down_left", "rbxassetid://102899325237364")

    -- 文件
    AddIcon("file", "rbxassetid://74748492079329")
    AddIcon("folder_open", "rbxassetid://76018996254888")
    AddIcon("archive", "rbxassetid://122180020814574")
end
LoadIcons()

-- ================================================================
-- 形状系统（多种圆角变体）
-- ================================================================
local ShapeImages = {
    Squircle = "rbxassetid://89641024074289",
    SquircleH = "rbxassetid://125083578015333",
    SquircleV = "rbxassetid://124965260437653",
    SquircleGlass = "rbxassetid://131126436897551",
    SquircleOutline = "rbxassetid://74029063732681",
    Circle = "rbxassetid://111665032676235",
    CircleOutline = "rbxassetid://108556680453287",
    CircleGlass = "rbxassetid://95600044758841",
}

local ShapeSlices = {
    Squircle = Rect.new(460,460,460,460),
    SquircleH = Rect.new(512,325,512,325),
    SquircleV = Rect.new(325,512,325,512),
    SquircleGlass = Rect.new(512,512,512,512),
    SquircleOutline = Rect.new(512,512,512,512),
    Circle = Rect.new(512,512,512,512),
    CircleOutline = Rect.new(512,512,512,512),
    CircleGlass = Rect.new(512,512,512,512),
}

function NewRoundFrame(radius, shape, props, children)
    shape = shape or "Squircle"
    local img = ShapeImages[shape] or ShapeImages.Squircle
    local slice = ShapeSlices[shape] or ShapeSlices.Squircle
    local frame = New("ImageLabel", {
        Image = img,
        ScaleType = "Slice",
        SliceCenter = slice,
        SliceScale = math.max(radius / 512, 0.01),
        BackgroundTransparency = 1,
    })
    for k,v in pairs(props or {}) do
        if k ~= "Children" then frame[k] = v end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = frame
        end
    end
    return frame
end

-- ================================================================
-- Acrylic 毛玻璃效果（模拟）
-- ================================================================
local AcrylicActive = false
local AcrylicObjects = {}

function EnableAcrylic(window)
    if AcrylicActive then return end
    AcrylicActive = true
    -- 创建一个 DepthOfFieldEffect 来模拟毛玻璃
    local dof = Instance.new("DepthOfFieldEffect")
    dof.FarIntensity = 0
    dof.InFocusRadius = 0.1
    dof.NearIntensity = 1
    dof.Parent = Lighting
    table.insert(AcrylicObjects, dof)
    -- 窗口背景变半透明
    if window and window.MainFrame then
        window.MainFrame.BackgroundTransparency = 0.15
    end
end

function DisableAcrylic()
    AcrylicActive = false
    for _, obj in ipairs(AcrylicObjects) do
        obj:Destroy()
    end
    AcrylicObjects = {}
end

-- ================================================================
-- 窗口主类
-- ================================================================
local Window = {}
Window.__index = Window

function Window.New(config)
    config = config or {}
    local self = setmetatable({}, Window)
    self.Title = config.Title or "Window"
    self.SubTitle = config.SubTitle
    self.Author = config.Author
    self.Icon = config.Icon or "window_icon"
    self.Size = config.Size or UDim2.new(0, 660, 0, 480)
    self.MinSize = config.MinSize or Vector2.new(400, 300)
    self.MaxSize = config.MaxSize or Vector2.new(900, 700)
    self.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.Resizable = config.Resizable ~= false
    self.Transparent = config.Transparent or false
    self.Acrylic = config.Acrylic or false
    self.MinimizeKey = config.MinimizeKey
    self.Parent = config.Parent or CoreGui
    self.UIScale = config.UIScale or 1
    self.Closed = false
    self.Destroyed = false
    self.IsFullscreen = false
    self.CanResize = true
    self.Tabs = {}
    self.TabCount = 0
    self.Dropdowns = {}
    self.Notifications = {}
    self.UICorner = 16
    self.UIPadding = 14
    self.WindowVisible = true

    -- GUI
    self.ScreenGui = New("ScreenGui", {
        Name = "WindUI_Window",
        Parent = self.Parent,
        ResetOnSpawn = false,
        ZIndexBehavior = "Sibling",
        IgnoreGuiInset = true,
        ScreenInsets = "None",
        DisplayOrder = -999,
    })
    self.UIScaleObj = New("UIScale", { Scale = self.UIScale, Parent = self.ScreenGui })

    -- 窗口底板
    self.MainFrame = New("Frame", {
        Size = self.Size,
        Position = self.Position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = self.Transparent and 0.15 or 0,
        BackgroundColor3 = Theme.WindowBackground,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    })
    AddThemeObject(self.MainFrame, { BackgroundColor3 = "WindowBackground" })
    if self.Transparent then
        AddThemeObject(self.MainFrame, { BackgroundTransparency = 0.15 })
    end
    New("UICorner", { CornerRadius = UDim.new(0, self.UICorner) }, { Parent = self.MainFrame })

    -- 阴影
    local shadow = New("ImageLabel", {
        Image = "rbxassetid://8992230677",
        ScaleType = "Slice",
        SliceCenter = Rect.new(99,99,99,99),
        Size = UDim2.new(1, 100, 1, 100),
        Position = UDim2.new(0, -50, 0, -50),
        BackgroundTransparency = 1,
        ImageTransparency = Theme.ShadowTransparency,
        ZIndex = -1,
        Parent = self.MainFrame,
    })
    AddThemeObject(shadow, { ImageTransparency = "ShadowTransparency" })

    -- Acrylic 玻璃效果
    if self.Acrylic then
        EnableAcrylic(self)
    end

    -- 顶部栏
    self.Topbar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        Parent = self.MainFrame,
    })

    -- 左侧
    self.TitleLeft = New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = "X",
        BackgroundTransparency = 1,
        Parent = self.Topbar,
    })
    New("UIListLayout", {
        FillDirection = "Horizontal",
        VerticalAlignment = "Center",
        Padding = UDim.new(0, 8),
    }, { Parent = self.TitleLeft })
    New("UIPadding", { PaddingLeft = UDim.new(0, 12) }, { Parent = self.TitleLeft })

    self.WinIcon = CreateIcon(self.Icon, UDim2.new(0, 20, 0, 20), self.TitleLeft)
    self.TitleLabel = New("TextLabel", {
        Text = self.Title,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        TextColor3 = Theme.Text,
        TextSize = 16,
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
        Parent = self.TitleLeft,
    })
    AddThemeObject(self.TitleLabel, { TextColor3 = "Text" })

    if self.SubTitle then
        self.SubTitleLabel = New("TextLabel", {
            Text = self.SubTitle,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
            TextColor3 = Theme.SubTitle,
            TextSize = 12,
            TextTransparency = 0.3,
            BackgroundTransparency = 1,
            AutomaticSize = "XY",
            Parent = self.TitleLeft,
        })
        AddThemeObject(self.SubTitleLabel, { TextColor3 = "SubTitle" })
    end

    if self.Author then
        self.AuthorLabel = New("TextLabel", {
            Text = self.Author,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextTransparency = 0.35,
            BackgroundTransparency = 1,
            AutomaticSize = "XY",
            Parent = self.TitleLeft,
        })
        AddThemeObject(self.AuthorLabel, { TextColor3 = "Text" })
    end

    -- 右侧 Mac 按钮
    self.TitleRight = New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = "X",
        BackgroundTransparency = 1,
        Parent = self.Topbar,
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
    })
    New("UIListLayout", {
        FillDirection = "Horizontal",
        VerticalAlignment = "Center",
        Padding = UDim.new(0, 8),
    }, { Parent = self.TitleRight })
    New("UIPadding", { PaddingRight = UDim.new(0, 12) }, { Parent = self.TitleRight })

    self:AddMacButton("close", Color3.fromHex("#ff5f56"), function() self:Destroy() end, 3)
    self:AddMacButton("minimize", Color3.fromHex("#ffbd2e"), function() self:Close() end, 2)
    self:AddMacButton("maximize", Color3.fromHex("#27c93f"), function() self:ToggleFullscreen() end, 1)

    -- 主体
    self.MainBody = New("Frame", {
        Size = UDim2.new(1, 0, 1, -52),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Parent = self.MainFrame,
    })

    -- 侧边栏
    self.Sidebar = New("ScrollingFrame", {
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Theme.Button,
        ScrollBarImageTransparency = 0.5,
        ClipsDescendants = true,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        Parent = self.MainBody,
    })
    AddThemeObject(self.Sidebar, { ScrollBarImageColor3 = "Button" })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, self.UIPadding/2),
        PaddingRight = UDim.new(0, self.UIPadding/2),
        PaddingTop = UDim.new(0, self.UIPadding/2),
        PaddingBottom = UDim.new(0, self.UIPadding/2),
    }, { Parent = self.Sidebar })
    self.SidebarList = New("UIListLayout", {
        SortOrder = "LayoutOrder",
        Padding = UDim.new(0, 6),
    }, { Parent = self.Sidebar })

    -- 内容面板
    self.ContentArea = New("Frame", {
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.MainBody,
    })
    self.ContentBg = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.PanelBackground,
        BackgroundTransparency = Theme.PanelBackgroundTransparency,
        Parent = self.ContentArea,
    })
    AddThemeObject(self.ContentBg, { BackgroundColor3 = "PanelBackground", BackgroundTransparency = "PanelBackgroundTransparency" })
    New("UICorner", { CornerRadius = UDim.new(0, self.UICorner - self.UIPadding/2) }, { Parent = self.ContentBg })

    -- 内容滚动
    self.ContentScroller = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Theme.Button,
        ScrollBarImageTransparency = 0.5,
        ClipsDescendants = true,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = "Y",
        ScrollingDirection = "Y",
        Parent = self.ContentArea,
    })
    AddThemeObject(self.ContentScroller, { ScrollBarImageColor3 = "Button" })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 20),
        PaddingBottom = UDim.new(0, 20),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
    }, { Parent = self.ContentScroller })
    self.ContentList = New("UIListLayout", {
        SortOrder = "LayoutOrder",
        Padding = UDim.new(0, 6),
        HorizontalAlignment = "Center",
    }, { Parent = self.ContentScroller })

    -- 拖拽
    self.DragHandler = Drag(self.MainFrame, { self.Topbar })

    -- 调整大小
    if self.Resizable then
        self.ResizeHandle = New("Frame", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = self.MainFrame,
            ZIndex = 99,
        })
        local resizeIcon = CreateIcon("expand", UDim2.new(0, 20, 0, 20), self.ResizeHandle)
        resizeIcon.ImageTransparency = 0.8
        local isResizing = false
        local initialSize, initialInput
        local resizeGuid = GenerateGUID()
        self.ResizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if CurrentInput and CurrentInput ~= resizeGuid then return end
            CurrentInput = resizeGuid
            isResizing = true
            initialSize = self.MainFrame.Size
            initialInput = input.Position
            Tween(resizeIcon, 0.1, { ImageTransparency = 0.35 }):Play()
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not isResizing then return end
            if CurrentInput and CurrentInput ~= resizeGuid then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - initialInput
                local newSize = UDim2.new(0, 
                    math.clamp(initialSize.X.Offset + delta.X * 2, self.MinSize.X, self.MaxSize.X),
                    0,
                    math.clamp(initialSize.Y.Offset + delta.Y * 2, self.MinSize.Y, self.MaxSize.Y)
                )
                Tween(self.MainFrame, 0.08, { Size = newSize }):Play()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if not isResizing then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                CurrentInput = nil
                isResizing = false
                Tween(resizeIcon, 0.17, { ImageTransparency = 0.8 }):Play()
            end
        end)
    end

    -- 自动缩放
    self:SetupAutoScale()

    -- 热键最小化
    if self.MinimizeKey then
        AddSignal(UserInputService.InputBegan, function(input, processed)
            if processed then return end
            if input.KeyCode == self.MinimizeKey then
                self:ToggleMinimize()
            end
        end)
    end

    self:Open()
    return self
end

function Window:AddMacButton(name, color, callback, order)
    local btn = New("ImageButton", {
        Image = GetIcon(name).Image,
        Size = UDim2.new(0, 13, 0, 13),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.15,
        ImageTransparency = 0.6,
        LayoutOrder = order or 999,
        Parent = self.TitleRight,
        AutoButtonColor = false,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = btn })
    New("UIStroke", { Color = Color3.new(0,0,0), Transparency = 0.8, Thickness = 0.5 }, { Parent = btn })
    AddSignal(btn.MouseEnter, function()
        Tween(btn, 0.1, { BackgroundTransparency = 0.05, ImageTransparency = 0.2 }):Play()
    end)
    AddSignal(btn.MouseLeave, function()
        Tween(btn, 0.1, { BackgroundTransparency = 0.15, ImageTransparency = 0.6 }):Play()
    end)
    AddSignal(btn.MouseButton1Down, function()
        Tween(btn, 0.1, { Size = UDim2.new(0, 11, 0, 11) }):Play()
    end)
    AddSignal(btn.MouseButton1Up, function()
        Tween(btn, 0.1, { Size = UDim2.new(0, 13, 0, 13) }):Play()
    end)
    AddSignal(btn.MouseButton1Click, function()
        if callback then SafeCallback(callback) end
    end)
    return btn
end

function Window:Open()
    if self.Destroyed then return end
    self.Closed = false
    self.WindowVisible = true
    self.MainFrame.Visible = true
    self.ScreenGui.Enabled = true
    Tween(self.MainFrame, 0.5, { Size = self.Size }):Play()
end

function Window:Close()
    if self.Destroyed then return end
    self.Closed = true
    self.WindowVisible = false
    Tween(self.MainFrame, 0.4, { Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 0) }):Play()
    task.wait(0.4)
    self.MainFrame.Visible = false
    self.ScreenGui.Enabled = false
end

function Window:ToggleMinimize()
    if self.WindowVisible then
        self:Close()
    else
        self:Open()
    end
end

function Window:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self:Close()
    DisconnectAll()
    DisableAcrylic()
    self.ScreenGui:Destroy()
end

function Window:ToggleFullscreen()
    self.IsFullscreen = not self.IsFullscreen
    self.DragHandler:Set(not self.IsFullscreen)
    if self.IsFullscreen then
        self.CanResize = false
        local size = UDim2.new(0, self.ScreenGui.AbsoluteSize.X - 20, 0, self.ScreenGui.AbsoluteSize.Y - 20 - 52)
        Tween(self.MainFrame, 0.45, { Size = size, Position = UDim2.new(0.5, 0, 0.5, 26) }):Play()
    else
        self.CanResize = self.Resizable
        Tween(self.MainFrame, 0.45, { Size = self.Size, Position = self.Position }):Play()
    end
end

function Window:SetTitle(title)
    self.Title = title
    self.TitleLabel.Text = title
end

function Window:SetSubTitle(subtitle)
    self.SubTitle = subtitle
    if not self.SubTitleLabel then
        self.SubTitleLabel = New("TextLabel", {
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
            TextColor3 = Theme.SubTitle,
            TextSize = 12,
            TextTransparency = 0.3,
            BackgroundTransparency = 1,
            AutomaticSize = "XY",
            Parent = self.TitleLeft,
        })
        AddThemeObject(self.SubTitleLabel, { TextColor3 = "SubTitle" })
    end
    self.SubTitleLabel.Text = subtitle
end

function Window:SetUIScale(scale)
    self.UIScale = math.clamp(scale, 0.5, 1.5)
    Tween(self.UIScaleObj, 0.3, { Scale = self.UIScale }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
end

function Window:SetupAutoScale()
    local function updateScale()
        local viewport = self.ScreenGui.AbsoluteSize
        if viewport.X == 0 or viewport.Y == 0 then return end
        local baseWidth = 660
        local baseHeight = 480
        local padding = 40
        local maxWidth = viewport.X - padding
        local maxHeight = viewport.Y - padding
        local scaleX = maxWidth / baseWidth
        local scaleY = maxHeight / baseHeight
        local newScale = math.min(scaleX, scaleY, 1.2)
        newScale = math.max(newScale, 0.6)
        if self.UIScale ~= newScale then
            self.UIScale = newScale
            Tween(self.UIScaleObj, 0.3, { Scale = newScale }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
        end
    end
    AddSignal(self.MainFrame:GetPropertyChangedSignal("AbsoluteSize"), updateScale)
    local lastViewport = self.ScreenGui.AbsoluteSize
    AddSignal(RunService.Heartbeat, function()
        local current = self.ScreenGui.AbsoluteSize
        if current.X ~= lastViewport.X or current.Y ~= lastViewport.Y then
            lastViewport = current
            updateScale()
        end
    end)
    task.wait(0.1)
    updateScale()
end

-- ================================================================
-- Tab 系统
-- ================================================================
function Window:AddTab(config)
    config = config or {}
    local tab = {}
    tab.Title = config.Title or "Tab"
    tab.Icon = config.Icon or "folder"
    tab.Index = self.TabCount + 1
    self.TabCount = tab.Index
    tab.Elements = {}
    tab.Selected = false

    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = tab.Title,
        TextColor3 = Theme.TabText,
        TextSize = 15,
        TextXAlignment = "Left",
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        TextTransparency = Theme.TabTextTransparency,
        Parent = self.Sidebar,
        LayoutOrder = tab.Index,
    })
    AddThemeObject(btn, { TextColor3 = "TabText", TextTransparency = "TabTextTransparency" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = btn })
    New("UIPadding", { PaddingLeft = UDim.new(0, 36) }, { Parent = btn })

    local icon = CreateIcon(tab.Icon, UDim2.new(0, 18, 0, 18), btn)
    if icon then
        icon.Position = UDim2.new(0, 10, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.ImageTransparency = Theme.TabTextTransparency
        AddThemeObject(icon, { ImageTransparency = "TabTextTransparency" })
    end

    AddSignal(btn.MouseEnter, function()
        if not tab.Selected then
            Tween(btn, 0.1, { BackgroundTransparency = 0.93 }):Play()
        end
    end)
    AddSignal(btn.MouseLeave, function()
        if not tab.Selected then
            Tween(btn, 0.1, { BackgroundTransparency = 1 }):Play()
        end
    end)
    AddSignal(btn.MouseButton1Click, function()
        self:SelectTab(tab.Index)
    end)

    local container = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.ContentScroller,
    })
    container.AnchorPoint = Vector2.new(0, 0.05)
    local containerList = New("UIListLayout", {
        SortOrder = "LayoutOrder",
        Padding = UDim.new(0, 6),
        HorizontalAlignment = "Center",
    }, { Parent = container })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
    }, { Parent = container })

    tab.Button = btn
    tab.Icon = icon
    tab.Container = container

    self.Tabs[tab.Index] = tab

    if self.TabCount == 1 then
        self:SelectTab(1)
    end

    return tab
end

function Window:SelectTab(index)
    local tab = self.Tabs[index]
    if not tab or tab.Selected then return end

    for _, t in pairs(self.Tabs) do
        t.Selected = false
        t.Button.TextTransparency = Theme.TabTextTransparency
        if t.Icon then t.Icon.ImageTransparency = Theme.TabTextTransparency end
        t.Button.BackgroundTransparency = 1
        if t.Container.Visible then
            Tween(t.Container, 0.15, { AnchorPoint = Vector2.new(0, 0.05) }):Play()
            task.wait(0.15)
            t.Container.Visible = false
        end
    end

    tab.Selected = true
    tab.Button.TextTransparency = Theme.TabTextActiveTransparency
    if tab.Icon then tab.Icon.ImageTransparency = Theme.TabTextActiveTransparency end
    tab.Button.BackgroundTransparency = 0.93
    tab.Container.Visible = true
    Tween(tab.Container, 0.15, { AnchorPoint = Vector2.new(0, 0) }):Play()
    self.ContentScroller.CanvasPosition = Vector2.new(0,0)
end

function Window:AddElement(tabIndex, element)
    local tab = self.Tabs[tabIndex]
    if not tab then return end
    table.insert(tab.Elements, element)
    if element.Gui then
        element.Gui.Parent = tab.Container
        element.Gui.LayoutOrder = #tab.Elements
    end
end

-- ================================================================
-- 控件
-- ================================================================
function Window:Button(config)
    config = config or {}
    local btn = New("TextButton", {
        Text = config.Text or "Button",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.15,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        AutoButtonColor = false,
        Parent = nil,
    })
    AddThemeObject(btn, { BackgroundColor3 = "Button", TextColor3 = "Text" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = btn })
    AddSignal(btn.MouseEnter, function()
        Tween(btn, 0.1, { BackgroundTransparency = 0.05 }):Play()
    end)
    AddSignal(btn.MouseLeave, function()
        Tween(btn, 0.1, { BackgroundTransparency = 0.15 }):Play()
    end)
    if config.Callback then
        AddSignal(btn.MouseButton1Click, function() SafeCallback(config.Callback) end)
    end
    return { Gui = btn, Type = "Button" }
end

function Window:Label(config)
    config = config or {}
    local label = New("TextLabel", {
        Text = config.Text or "",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Left",
        TextWrapped = true,
        Parent = nil,
    })
    AddThemeObject(label, { TextColor3 = "Text" })
    return { Gui = label, Type = "Label" }
end

function Window:Input(config)
    config = config or {}
    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = nil,
    })
    local box = New("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = Theme.ElementBackgroundTransparency or 0,
        Text = "",
        PlaceholderText = config.Placeholder or "Input...",
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Placeholder,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Left",
        ClearTextOnFocus = config.ClearTextOnFocus or false,
        Parent = frame,
    })
    AddThemeObject(box, { BackgroundColor3 = "ElementBackground", TextColor3 = "Text", PlaceholderColor3 = "Placeholder" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = box })
    AddSignal(box.MouseEnter, function()
        Tween(box, 0.1, { BackgroundTransparency = 0.75 }):Play()
    end)
    AddSignal(box.MouseLeave, function()
        Tween(box, 0.1, { BackgroundTransparency = Theme.ElementBackgroundTransparency or 0 }):Play()
    end)
    if config.Callback then
        AddSignal(box:GetPropertyChangedSignal("Text"), function()
            SafeCallback(config.Callback, box.Text)
        end)
    end
    if config.MultiLine then
        box.MultiLine = true
        box.TextWrapped = true
        box.Size = UDim2.new(1, 0, 0, 100)
        frame.Size = UDim2.new(1, 0, 0, 100)
    end
    if config.Password then
        box.Password = true
    end
    if config.NumberOnly then
        box.Text = ""
        AddSignal(box:GetPropertyChangedSignal("Text"), function()
            local val = tonumber(box.Text)
            if val == nil and box.Text ~= "" then
                box.Text = box.Text:sub(1, -2)
            end
        end)
    end
    return { Gui = frame, TextBox = box, Type = "Input" }
end

function Window:Toggle(config)
    config = config or {}
    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = nil,
    })
    local label = New("TextLabel", {
        Text = config.Text or "Toggle",
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        TextXAlignment = "Left",
        Parent = frame,
    })
    AddThemeObject(label, { TextColor3 = "Text" })

    local toggleBtn = New("TextButton", {
        Size = UDim2.new(0, 40, 0, 24),
        Position = UDim2.new(1, -5, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.5,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    AddThemeObject(toggleBtn, { BackgroundColor3 = "Button" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = toggleBtn })
    local thumb = New("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        Parent = toggleBtn,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = thumb })

    local state = config.Default or false
    local function updateState(newState, animate)
        state = newState
        if state then
            toggleBtn.BackgroundColor3 = Theme.Toggle
            thumb.Position = UDim2.new(1, -3, 0.5, 0)
            thumb.AnchorPoint = Vector2.new(1, 0.5)
        else
            toggleBtn.BackgroundColor3 = Theme.Button
            thumb.Position = UDim2.new(0, 3, 0.5, 0)
            thumb.AnchorPoint = Vector2.new(0, 0.5)
        end
        if animate ~= false then
            Tween(toggleBtn, 0.35, { BackgroundColor3 = toggleBtn.BackgroundColor3 }):Play()
            Tween(thumb, 0.35, { Position = thumb.Position }):Play()
        end
        if config.Callback then SafeCallback(config.Callback, state) end
    end
    updateState(state, false)

    AddSignal(toggleBtn.MouseButton1Click, function()
        updateState(not state, true)
    end)
    AddSignal(toggleBtn.MouseEnter, function()
        Tween(toggleBtn, 0.1, { BackgroundTransparency = 0.3 }):Play()
    end)
    AddSignal(toggleBtn.MouseLeave, function()
        Tween(toggleBtn, 0.1, { BackgroundTransparency = 0.5 }):Play()
    end)

    return { Gui = frame, Toggle = toggleBtn, State = state, Set = updateState, Type = "Toggle" }
end

function Window:Slider(config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local step = config.Step or 1
    local default = math.clamp(config.Default or min, min, max)
    if step ~= 1 then default = math.floor(default / step + 0.5) * step end
    local text = config.Text or "Slider"
    local callback = config.Callback

    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        Parent = nil,
    })
    local label = New("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 15,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        TextXAlignment = "Left",
        Parent = frame,
    })
    AddThemeObject(label, { TextColor3 = "Text" })
    local valueLabel = New("TextLabel", {
        Text = tostring(default),
        Size = UDim2.new(0, 40, 0, 24),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Right",
        Parent = frame,
    })
    AddThemeObject(valueLabel, { TextColor3 = "Text" })

    local track = New("Frame", {
        Size = UDim2.new(1, -50, 0, 4),
        Position = UDim2.new(0, 0, 1, -4),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.5,
        Parent = frame,
    })
    AddThemeObject(track, { BackgroundColor3 = "Button" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = track })
    local fill = New("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Slider,
        Parent = track,
    })
    AddThemeObject(fill, { BackgroundColor3 = "Slider" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = fill })
    local thumb = New("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.1,
        Text = "",
        AutoButtonColor = false,
        Parent = track,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = thumb })
    local glow = New("Frame", {
        Size = UDim2.new(1, 8, 1, 8),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Slider,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Parent = thumb,
    })
    AddThemeObject(glow, { BackgroundColor3 = "Slider" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = glow })

    local currentValue = default
    local isDragging = false
    local guid = GenerateGUID()

    local function updateValue(val, animate)
        val = math.clamp(val, min, max)
        if step ~= 1 then val = math.floor(val / step + 0.5) * step end
        if val == currentValue then return end
        currentValue = val
        local percent = (val - min) / (max - min)
        if animate ~= false then
            Tween(fill, 0.1, { Size = UDim2.new(percent, 0, 1, 0) }):Play()
            Tween(thumb, 0.1, { Position = UDim2.new(percent, 0, 0.5, 0) }):Play()
        else
            fill.Size = UDim2.new(percent, 0, 1, 0)
            thumb.Position = UDim2.new(percent, 0, 0.5, 0)
        end
        valueLabel.Text = tostring(val)
        if callback then SafeCallback(callback, val) end
    end

    local function startDrag(input)
        if isDragging then return end
        if CurrentInput and CurrentInput ~= guid then return end
        CurrentInput = guid
        isDragging = true
        local pos = input.Position.X - track.AbsolutePosition.X
        local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
        updateValue(min + percent * (max - min), false)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if CurrentInput and CurrentInput ~= guid then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - track.AbsolutePosition.X
            local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
            updateValue(min + percent * (max - min), false)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            CurrentInput = nil
            isDragging = false
        end
    end)

    AddSignal(thumb.MouseEnter, function()
        Tween(glow, 0.15, { BackgroundTransparency = 0.4 }):Play()
        Tween(thumb, 0.15, { Size = UDim2.new(0, 22, 0, 22) }):Play()
    end)
    AddSignal(thumb.MouseLeave, function()
        Tween(glow, 0.15, { BackgroundTransparency = 0.8 }):Play()
        Tween(thumb, 0.15, { Size = UDim2.new(0, 16, 0, 16) }):Play()
    end)

    return { Gui = frame, Type = "Slider", Value = currentValue, Set = updateValue, Get = function() return currentValue end }
end

function Window:Dropdown(config)
    config = config or {}
    local text = config.Text or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or (options[1] or "")
    local callback = config.Callback
    local searchable = config.Searchable or false
    local multi = config.Multi or false

    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Parent = nil,
        ClipsDescendants = false,
    })
    local label = New("TextLabel", {
        Text = text,
        Size = UDim2.new(0.4, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 15,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        TextXAlignment = "Left",
        Parent = frame,
    })
    AddThemeObject(label, { TextColor3 = "Text" })

    local box = New("TextButton", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = 0.85,
        Text = default,
        TextColor3 = Theme.Text,
        TextSize = 15,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Left",
        AutoButtonColor = false,
        Parent = frame,
    })
    AddThemeObject(box, { BackgroundColor3 = "ElementBackground", TextColor3 = "Text" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = box })
    local arrow = CreateIcon("chevron_down", UDim2.new(0, 16, 0, 16), box)
    if arrow then
        arrow.Position = UDim2.new(1, -5, 0.5, 0)
        arrow.AnchorPoint = Vector2.new(1, 0.5)
    end

    local list = New("ScrollingFrame", {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.4, 0, 1, 4),
        BackgroundColor3 = Theme.Dialog,
        BackgroundTransparency = 0.1,
        Visible = false,
        ClipsDescendants = true,
        ScrollBarThickness = 4,
        ZIndex = 100,
        Parent = frame,
    })
    AddThemeObject(list, { BackgroundColor3 = "Dialog" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = list })
    New("UIStroke", { Color = Theme.Text, Transparency = 0.8, Thickness = 1 }, { Parent = list })
    AddThemeObject(list:FindFirstChild("UIStroke"), { Color = "Text" })
    local listLayout = New("UIListLayout", {
        SortOrder = "LayoutOrder",
        Padding = UDim.new(0, 2),
    }, { Parent = list })

    local searchBox = nil
    if searchable then
        searchBox = New("TextBox", {
            Size = UDim2.new(1, 0, 0, 32),
            PlaceholderText = "搜索...",
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.Placeholder,
            BackgroundColor3 = Theme.ElementBackground,
            BackgroundTransparency = 0.5,
            TextSize = 14,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
            Parent = list,
        })
        AddThemeObject(searchBox, { TextColor3 = "Text", PlaceholderColor3 = "Placeholder", BackgroundColor3 = "ElementBackground" })
        New("UICorner", { CornerRadius = UDim.new(0, 4) }, { Parent = searchBox })
        New("UIPadding", { PaddingLeft = UDim.new(0, 8) }, { Parent = searchBox })
    end

    local selectedOption = default
    local selectedOptions = multi and {} or nil
    if multi and type(default) == "table" then
        selectedOptions = default
    elseif multi then
        selectedOptions = { default }
    end

    local isOpen = false

    local function rebuildOptions(filter)
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") and child ~= searchBox then child:Destroy() end
        end
        local filtered = options
        if filter and filter ~= "" then
            filtered = {}
            for _, opt in ipairs(options) do
                if string.find(string.lower(opt), string.lower(filter), 1, true) then
                    table.insert(filtered, opt)
                end
            end
        end
        for i, opt in ipairs(filtered) do
            local optBtn = New("TextButton", {
                Text = opt,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                TextColor3 = Theme.Text,
                TextSize = 14,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
                TextXAlignment = "Left",
                TextTruncate = "AtEnd",
                LayoutOrder = i,
                Parent = list,
            })
            AddThemeObject(optBtn, { TextColor3 = "Text" })
            New("UIPadding", { PaddingLeft = UDim.new(0, 8) }, { Parent = optBtn })
            if (multi and table.find(selectedOptions, opt)) or (not multi and opt == selectedOption) then
                optBtn.TextColor3 = Theme.Primary
                AddThemeObject(optBtn, { TextColor3 = "Primary" })
            end
            AddSignal(optBtn.MouseEnter, function()
                Tween(optBtn, 0.1, { BackgroundTransparency = 0.9 }):Play()
            end)
            AddSignal(optBtn.MouseLeave, function()
                Tween(optBtn, 0.1, { BackgroundTransparency = 1 }):Play()
            end)
            AddSignal(optBtn.MouseButton1Click, function()
                if multi then
                    local idx = table.find(selectedOptions, opt)
                    if idx then
                        table.remove(selectedOptions, idx)
                        optBtn.TextColor3 = Theme.Text
                        AddThemeObject(optBtn, { TextColor3 = "Text" })
                    else
                        table.insert(selectedOptions, opt)
                        optBtn.TextColor3 = Theme.Primary
                        AddThemeObject(optBtn, { TextColor3 = "Primary" })
                    end
                    local display = table.concat(selectedOptions, ", ")
                    box.Text = display ~= "" and display or "--"
                    if callback then SafeCallback(callback, selectedOptions) end
                else
                    selectedOption = opt
                    box.Text = opt
                    if callback then SafeCallback(callback, opt) end
                    self:CloseDropdown(list)
                end
            end)
        end
        local count = #filtered
        local maxHeight = 200
        local itemHeight = 34
        local height = math.min(count * itemHeight + 8, maxHeight)
        if searchBox then height = height + 32 end
        list.Size = UDim2.new(0, box.AbsoluteSize.X, 0, height)
        list.CanvasSize = UDim2.new(0, 0, 0, count * itemHeight + 8)
    end

    local function toggleDropdown()
        if isOpen then
            self:CloseDropdown(list)
        else
            self:CloseAllDropdowns()
            isOpen = true
            list.Visible = true
            rebuildOptions()
            local pos = box.AbsolutePosition
            local size = box.AbsoluteSize
            local listSize = list.AbsoluteSize
            local viewport = self.ScreenGui.AbsoluteSize
            local newY = size.Y + 4
            if pos.Y + size.Y + listSize.Y > viewport.Y then
                newY = -listSize.Y - 4
            end
            list.Position = UDim2.new(0.4, 0, 1, newY)
            list.Size = UDim2.new(0, box.AbsoluteSize.X, 0, 0)
            Tween(list, 0.2, { Size = UDim2.new(0, box.AbsoluteSize.X, 0, list.CanvasSize.Y.Offset + 8) }):Play()
            if arrow then arrow.Rotation = 180 end
            table.insert(self.Dropdowns, { Close = function() self:CloseDropdown(list) end })
            if searchBox then searchBox:CaptureFocus() end
        end
    end

    AddSignal(box.MouseButton1Click, toggleDropdown)
    if searchBox then
        AddSignal(searchBox:GetPropertyChangedSignal("Text"), function()
            rebuildOptions(searchBox.Text)
        end)
    end

    return {
        Gui = frame,
        Type = "Dropdown",
        Value = selectedOption,
        Set = function(_, opt)
            if multi then
                if type(opt) ~= "table" then opt = {opt} end
                selectedOptions = opt
                local display = table.concat(opt, ", ")
                box.Text = display ~= "" and display or "--"
                if callback then SafeCallback(callback, opt) end
            else
                selectedOption = opt
                box.Text = opt
                if callback then SafeCallback(callback, opt) end
            end
        end,
        Get = function() return multi and selectedOptions or selectedOption end,
        Open = toggleDropdown,
        Close = function() self:CloseDropdown(list) end,
    }
end

function Window:CloseDropdown(list)
    if not list then return end
    list.Visible = false
    local parent = list.Parent
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ImageLabel") and child.Image and child.Image:find("chevron_down") then
                child.Rotation = 0
                break
            end
        end
    end
    list.Size = UDim2.new(0, 0, 0, 0)
    for i, dd in ipairs(self.Dropdowns) do
        if dd.Close == function() self:CloseDropdown(list) end then
            table.remove(self.Dropdowns, i)
            break
        end
    end
end

function Window:CloseAllDropdowns()
    for _, dd in ipairs(self.Dropdowns) do
        if dd.Close then dd:Close() end
    end
    self.Dropdowns = {}
end

-- ================================================================
-- 新增控件: ProgressBar
-- ================================================================
function Window:ProgressBar(config)
    config = config or {}
    local value = math.clamp(config.Value or 0, 0, 100)
    local text = config.Text or "Progress"
    local callback = config.Callback

    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Parent = nil,
    })
    local label = New("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 15,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        TextXAlignment = "Left",
        Parent = frame,
    })
    AddThemeObject(label, { TextColor3 = "Text" })

    local track = New("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.5,
        Parent = frame,
    })
    AddThemeObject(track, { BackgroundColor3 = "Button" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = track })

    local fill = New("Frame", {
        Size = UDim2.new(value / 100, 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        Parent = track,
    })
    AddThemeObject(fill, { BackgroundColor3 = "Primary" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = fill })

    local valueLabel = New("TextLabel", {
        Text = tostring(math.floor(value)) .. "%",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Right",
        Parent = frame,
    })
    AddThemeObject(valueLabel, { TextColor3 = "Text" })

    return {
        Gui = frame,
        Type = "ProgressBar",
        Value = value,
        Set = function(_, val)
            val = math.clamp(val, 0, 100)
            value = val
            fill.Size = UDim2.new(val / 100, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(val)) .. "%"
            if callback then SafeCallback(callback, val) end
        end,
        Get = function() return value end,
    }
end

-- ================================================================
-- 新增控件: Keybind
-- ================================================================
function Window:Keybind(config)
    config = config or {}
    local text = config.Text or "Keybind"
    local default = config.Default or "F"
    local callback = config.Callback

    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = nil,
    })
    local label = New("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        TextXAlignment = "Left",
        Parent = frame,
    })
    AddThemeObject(label, { TextColor3 = "Text" })

    local keyBtn = New("TextButton", {
        Text = default,
        Size = UDim2.new(0, 70, 0, 30),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = 0.85,
        TextColor3 = Theme.Text,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        AutoButtonColor = false,
        Parent = frame,
    })
    AddThemeObject(keyBtn, { BackgroundColor3 = "ElementBackground", TextColor3 = "Text" })
    New("UICorner", { CornerRadius = UDim.new(0, 6) }, { Parent = keyBtn })

    local currentKey = default
    local listening = false
    local guid = GenerateGUID()

    local function startListening()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode.Name
                keyBtn.Text = currentKey
                listening = false
                conn:Disconnect()
                if callback then SafeCallback(callback, currentKey) end
            end
        end)
    end

    AddSignal(keyBtn.MouseButton1Click, startListening)

    AddSignal(keyBtn.MouseEnter, function()
        Tween(keyBtn, 0.1, { BackgroundTransparency = 0.75 }):Play()
    end)
    AddSignal(keyBtn.MouseLeave, function()
        Tween(keyBtn, 0.1, { BackgroundTransparency = 0.85 }):Play()
    end)

    -- 监听按键（不处于录制状态时）
    AddSignal(UserInputService.InputBegan, function(input, processed)
        if processed then return end
        if listening then return end
        if input.KeyCode.Name == currentKey then
            if callback then SafeCallback(callback, currentKey) end
        end
    end)

    return {
        Gui = frame,
        Type = "Keybind",
        Value = currentKey,
        Set = function(_, key) currentKey = key keyBtn.Text = key end,
        Get = function() return currentKey end,
    }
end

-- ================================================================
-- 新增控件: ColorPicker (简化版)
-- ================================================================
function Window:ColorPicker(config)
    config = config or {}
    local default = config.Default or Color3.fromHex("#0091FF")
    local text = config.Text or "Color"
    local callback = config.Callback

    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = nil,
    })
    local label = New("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        TextXAlignment = "Left",
        Parent = frame,
    })
    AddThemeObject(label, { TextColor3 = "Text" })

    local colorPreview = New("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Parent = frame,
    })
    New("UICorner", { CornerRadius = UDim.new(0, 6) }, { Parent = colorPreview })
    New("UIStroke", { Color = Theme.Text, Transparency = 0.5, Thickness = 1 }, { Parent = colorPreview })
    AddThemeObject(colorPreview:FindFirstChild("UIStroke"), { Color = "Text" })

    -- 点击打开简易取色器
    local colorPickerOpen = false
    local pickerFrame = New("Frame", {
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Dialog,
        BackgroundTransparency = 0.05,
        Visible = false,
        ZIndex = 100,
        Parent = self.ScreenGui,
    })
    AddThemeObject(pickerFrame, { BackgroundColor3 = "Dialog" })
    New("UICorner", { CornerRadius = UDim.new(0, 12) }, { Parent = pickerFrame })
    New("UIStroke", { Color = Theme.Text, Transparency = 0.8, Thickness = 1 }, { Parent = pickerFrame })
    AddThemeObject(pickerFrame:FindFirstChild("UIStroke"), { Color = "Text" })

    -- 颜色选择滑块 (简化版 - 色相)
    local hueSlider = New("Frame", {
        Size = UDim2.new(0, 160, 0, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1,0,0),
        Parent = pickerFrame,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = hueSlider })
    local hueGrad = New("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
            ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)),
            ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)),
            ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
            ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)),
            ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,0,0)),
        }),
    }, { Parent = hueSlider })

    local hueThumb = New("Frame", {
        Size = UDim2.new(0, 12, 1, 4),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        Parent = hueSlider,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = hueThumb })

    -- 关闭按钮
    local closePicker = New("TextButton", {
        Text = "✕",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -5, 0, 5),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold),
        Parent = pickerFrame,
    })
    AddThemeObject(closePicker, { TextColor3 = "Text" })
    AddSignal(closePicker.MouseButton1Click, function()
        pickerFrame.Visible = false
        colorPickerOpen = false
    end)

    local function openPicker()
        if colorPickerOpen then
            pickerFrame.Visible = false
            colorPickerOpen = false
            return
        end
        pickerFrame.Visible = true
        colorPickerOpen = true
        -- 定位在屏幕中央
        pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
        -- 初始化色相位置
        local h,s,v = Color3.toHSV(default)
        hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
    end

    AddSignal(colorPreview.MouseButton1Click, openPicker)

    -- 色相拖动
    local isDraggingHue = false
    local hueGuid = GenerateGUID()
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if CurrentInput and CurrentInput ~= hueGuid then return end
            CurrentInput = hueGuid
            isDraggingHue = true
            local pos = (input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X
            local h = math.clamp(pos, 0, 1)
            hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
            local color = Color3.fromHSV(h, 0.8, 0.8)
            colorPreview.BackgroundColor3 = color
            if callback then SafeCallback(callback, color) end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not isDraggingHue then return end
        if CurrentInput and CurrentInput ~= hueGuid then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local pos = (input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X
            local h = math.clamp(pos, 0, 1)
            hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
            local color = Color3.fromHSV(h, 0.8, 0.8)
            colorPreview.BackgroundColor3 = color
            if callback then SafeCallback(callback, color) end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if isDraggingHue and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            CurrentInput = nil
            isDraggingHue = false
        end
    end)

    return {
        Gui = frame,
        Type = "ColorPicker",
        Color = default,
        Set = function(_, color)
            default = color
            colorPreview.BackgroundColor3 = color
            local h,s,v = Color3.toHSV(color)
            hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
        end,
        Get = function() return default end,
    }
end

-- ================================================================
-- Dialog 对话框
-- ================================================================
function Window:Dialog(config)
    config = config or {}
    local title = config.Title or "Dialog"
    local content = config.Content or ""
    local buttons = config.Buttons or {{ Text = "OK", Callback = function() end }}

    local overlay = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.6,
        ZIndex = 999,
        Parent = self.ScreenGui,
    })

    local dialog = New("Frame", {
        Size = UDim2.new(0, 320, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Dialog,
        BackgroundTransparency = 0.05,
        AutomaticSize = "Y",
        ClipsDescendants = true,
        ZIndex = 1000,
        Parent = overlay,
    })
    AddThemeObject(dialog, { BackgroundColor3 = "Dialog" })
    New("UICorner", { CornerRadius = UDim.new(0, 12) }, { Parent = dialog })
    New("UIStroke", { Color = Theme.Text, Transparency = 0.8, Thickness = 1 }, { Parent = dialog })
    AddThemeObject(dialog:FindFirstChild("UIStroke"), { Color = "Text" })

    New("UIPadding", { PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, { Parent = dialog })

    local titleLabel = New("TextLabel", {
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 18,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        Parent = dialog,
    })
    AddThemeObject(titleLabel, { TextColor3 = "Text" })

    local contentLabel = New("TextLabel", {
        Text = content,
        TextColor3 = Theme.Text,
        TextSize = 15,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        TextTransparency = 0.3,
        Parent = dialog,
    })
    AddThemeObject(contentLabel, { TextColor3 = "Text" })

    local btnFrame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Parent = dialog,
    })
    New("UIListLayout", {
        FillDirection = "Horizontal",
        HorizontalAlignment = "Right",
        Padding = UDim.new(0, 8),
    }, { Parent = btnFrame })

    for _, btn in ipairs(buttons) do
        local b = New("TextButton", {
            Text = btn.Text,
            Size = UDim2.new(0, 60, 0, 32),
            BackgroundColor3 = Theme.Button,
            BackgroundTransparency = 0.85,
            TextColor3 = Theme.Text,
            TextSize = 14,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
            AutoButtonColor = false,
            Parent = btnFrame,
        })
        AddThemeObject(b, { BackgroundColor3 = "Button", TextColor3 = "Text" })
        New("UICorner", { CornerRadius = UDim.new(0, 6) }, { Parent = b })
        AddSignal(b.MouseEnter, function()
            Tween(b, 0.1, { BackgroundTransparency = 0.75 }):Play()
        end)
        AddSignal(b.MouseLeave, function()
            Tween(b, 0.1, { BackgroundTransparency = 0.85 }):Play()
        end)
        AddSignal(b.MouseButton1Click, function()
            if btn.Callback then SafeCallback(btn.Callback) end
            overlay:Destroy()
        end)
    end

    -- 点击外部关闭
    AddSignal(overlay.MouseButton1Click, function()
        overlay:Destroy()
    end)
    -- 阻止点击穿透到 overlay
    AddSignal(dialog.MouseButton1Click, function() end)

    return overlay
end

-- ================================================================
-- 段落、分隔线
-- ================================================================
function Window:Paragraph(config)
    config = config or {}
    local label = New("TextLabel", {
        Text = config.Text or "",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Left",
        TextWrapped = true,
        Parent = nil,
    })
    AddThemeObject(label, { TextColor3 = "Text" })
    return { Gui = label, Type = "Paragraph" }
end

function Window:Divider()
    local div = New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Text,
        BackgroundTransparency = 0.9,
        Parent = nil,
    })
    AddThemeObject(div, { BackgroundColor3 = "Text" })
    return { Gui = div, Type = "Divider" }
end

function Window:Section(config)
    config = config or {}
    local title = config.Title or "Section"
    local collapsed = config.Collapsed or false
    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Parent = nil,
    })
    local header = New("TextButton", {
        Text = (collapsed and "▶ " or "▼ ") .. title,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        TextXAlignment = "Left",
        AutoButtonColor = false,
        Parent = frame,
    })
    AddThemeObject(header, { TextColor3 = "Text" })
    local content = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Visible = not collapsed,
        Parent = frame,
    })
    New("UIPadding", { PaddingLeft = UDim.new(0, 16) }, { Parent = content })
    local contentList = New("UIListLayout", {
        SortOrder = "LayoutOrder",
        Padding = UDim.new(0, 4),
    }, { Parent = content })

    local section = {
        Gui = frame,
        Type = "Section",
        Header = header,
        Content = content,
        Collapsed = collapsed,
        AddElement = function(self, element)
            if element.Gui then
                element.Gui.Parent = content
                element.Gui.LayoutOrder = #content:GetChildren()
            end
        end,
    }

    AddSignal(header.MouseButton1Click, function()
        section.Collapsed = not section.Collapsed
        header.Text = (section.Collapsed and "▶ " or "▼ ") .. title
        content.Visible = not section.Collapsed
    end)
    return section
}

-- ================================================================
-- 通知系统
-- ================================================================
function Window:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 4
    local icon = config.Icon

    local notif = New("Frame", {
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, -20, 1, -20 - #self.Notifications * 70),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Theme.Dialog,
        BackgroundTransparency = 0.05,
        Parent = self.ScreenGui,
        ClipsDescendants = true,
        ZIndex = 100,
    })
    AddThemeObject(notif, { BackgroundColor3 = "Dialog" })
    New("UICorner", { CornerRadius = UDim.new(0, 12) }, { Parent = notif })
    New("UIStroke", { Color = Theme.Text, Transparency = 0.8, Thickness = 1 }, { Parent = notif })
    AddThemeObject(notif:FindFirstChild("UIStroke"), { Color = "Text" })
    New("UIListLayout", {
        FillDirection = "Horizontal",
        VerticalAlignment = "Center",
        Padding = UDim.new(0, 12),
    }, { Parent = notif })
    New("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, { Parent = notif })

    if icon then
        local img = CreateIcon(icon, UDim2.new(0, 24, 0, 24), notif)
        if img then img.ImageTransparency = 0.2 end
    end
    local textFrame = New("Frame", {
        Size = UDim2.new(1, -48, 0, 0),
        AutomaticSize = "Y",
        BackgroundTransparency = 1,
        Parent = notif,
    })
    New("UIListLayout", { FillDirection = "Vertical", Padding = UDim.new(0, 2) }, { Parent = textFrame })
    local titleLabel = New("TextLabel", {
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        AutomaticSize = "XY",
        Parent = textFrame,
    })
    AddThemeObject(titleLabel, { TextColor3 = "Text" })
    local contentLabel = New("TextLabel", {
        Text = content,
        TextColor3 = Theme.Text,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        AutomaticSize = "XY",
        TextTransparency = 0.4,
        Parent = textFrame,
    })
    AddThemeObject(contentLabel, { TextColor3 = "Text" })

    local closeBtn = CreateIcon("close", UDim2.new(0, 16, 0, 16), notif)
    if closeBtn then
        closeBtn.ImageTransparency = 0.4
        local closeHit = New("TextButton", {
            Size = UDim2.new(1, 8, 1, 8),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = closeBtn,
        })
        AddSignal(closeHit.MouseButton1Click, function()
            self:CloseNotification(notif)
        end)
    end

    task.wait()
    local height = notif.AbsoluteSize.Y
    notif.Size = UDim2.new(0, 300, 0, 0)
    Tween(notif, 0.3, { Size = UDim2.new(0, 300, 0, height) }):Play()
    table.insert(self.Notifications, notif)

    if duration > 0 then
        task.delay(duration, function()
            self:CloseNotification(notif)
        end)
    end
    return notif
end

function Window:CloseNotification(notif)
    if not notif.Parent then return end
    Tween(notif, 0.3, { Size = UDim2.new(0, 300, 0, 0) }):Play()
    task.wait(0.35)
    notif:Destroy()
    for i, n in ipairs(self.Notifications) do
        if n == notif then table.remove(self.Notifications, i) break end
    end
    for i, n in ipairs(self.Notifications) do
        Tween(n, 0.3, { Position = UDim2.new(1, -20, 1, -20 - (i-1) * 70) }):Play()
    end
end

-- ================================================================
-- 自动创建窗口并演示所有功能
-- ================================================================
local function AutoCreate()
    local win = Window.New({
        Title = "WindUI v4.0 完整版",
        SubTitle = "基于差异清单补全",
        Author = "独立实现",
        Size = UDim2.new(0, 820, 0, 580),
        Resizable = true,
        Transparent = false,
        Acrylic = false,
        MinimizeKey = Enum.KeyCode.H,
    })

    -- Tab 1: 基础控件
    local tab1 = win:AddTab({ Title = "基础", Icon = "home" })
    win:AddElement(tab1.Index, win:Paragraph({ Text = "v4.0 完整版 - 60+ 图标，完整形状系统，所有控件齐全" }))
    win:AddElement(tab1.Index, win:Divider())
    win:AddElement(tab1.Index, win:Button({ Text = "点击测试", Callback = function() print("点击") win:Notify({ Title = "提示", Content = "按钮被点击", Icon = "check", Duration = 2 }) end }))
    win:AddElement(tab1.Index, win:Input({ Placeholder = "输入框", ClearTextOnFocus = true, Callback = function(t) print("输入:", t) end }))
    win:AddElement(tab1.Index, win:Toggle({ Text = "开关", Default = true, Callback = function(s) print("开关:", s) end }))

    -- Tab 2: 高级控件
    local tab2 = win:AddTab({ Title = "高级", Icon = "settings" })
    win:AddElement(tab2.Index, win:Slider({ Text = "滑块", Min = 0, Max = 100, Default = 50, Step = 5, Callback = function(v) print("滑块:", v) end }))
    win:AddElement(tab2.Index, win:Dropdown({ Text = "下拉框", Options = {"选项A", "选项B", "选项C", "选项D"}, Default = "选项A", Searchable = true, Callback = function(v) print("下拉:", v) end }))
    win:AddElement(tab2.Index, win:ProgressBar({ Text = "进度条", Value = 75, Callback = function(v) print("进度:", v) end }))
    win:AddElement(tab2.Index, win:Keybind({ Text = "按键绑定", Default = "F", Callback = function(k) print("按键:", k) end }))

    -- Tab 3: 颜色 + 演示
    local tab3 = win:AddTab({ Title = "颜色", Icon = "palette" })
    win:AddElement(tab3.Index, win:ColorPicker({ Text = "颜色选择器", Default = Color3.fromHex("#0091FF"), Callback = function(c) print("颜色:", c) end }))
    win:AddElement(tab3.Index, win:Divider())
    win:AddElement(tab3.Index, win:Paragraph({ Text = "按 H 键最小化窗口" }))
    win:AddElement(tab3.Index, win:Button({ Text = "打开对话框", Callback = function()
        win:Dialog({
            Title = "提示",
            Content = "这是一个对话框示例",
            Buttons = {
                { Text = "取消", Callback = function() print("取消") end },
                { Text = "确定", Callback = function() print("确定") end },
            }
        })
    end }))

    -- Tab 4: 分组
    local tab4 = win:AddTab({ Title = "分组", Icon = "folder" })
    local sec = win:Section({ Title = "可折叠分组" })
    sec:AddElement(win:Button({ Text = "组内按钮1" }))
    sec:AddElement(win:Button({ Text = "组内按钮2" }))
    sec:AddElement(win:Input({ Placeholder = "组内输入" }))
    win:AddElement(tab4.Index, sec)

    local sec2 = win:Section({ Title = "另一个分组", Collapsed = true })
    sec2:AddElement(win:Label({ Text = "这个分组默认折叠" }))
    win:AddElement(tab4.Index, sec2)

    -- 启动通知
    task.delay(0.5, function()
        win:Notify({ Title = "WindUI v4.0", Content = "所有功能已加载完成", Icon = "check", Duration = 3 })
        task.delay(1, function()
            win:Notify({ Title = "提示", Content = "按 H 键最小化窗口", Icon = "bell", Duration = 3 })
        end)
    end)

    return win
end

return AutoCreate()
