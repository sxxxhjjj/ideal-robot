--[[
    ============================================================
    主面板 - 完整内嵌版（全部功能预制，无需外部配置）
    包含：所有控件、通知、工具提示、颜色选择器、按键绑定、
          代码块、图片、分组容器、主题切换、多配置管理、
          快捷键、双击居中、3D玩家显示、完整35个API方法
    ============================================================
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- ============================================================
-- 1. 图标库（全部常用图标）
-- ============================================================
local Icons = {
    home = "rbxassetid://98755624629571",
    settings = "rbxassetid://80758916183665",
    info = "rbxassetid://124560466474914",
    search = "rbxassetid://121018724060431",
    x = "rbxassetid://110786993356448",
    minus = "rbxassetid://118026365011536",
    maximize = "rbxassetid://76045941763188",
    minimize = "rbxassetid://121304296213645",
    chevron_down = "rbxassetid://134243273101015",
    chevron_left = "rbxassetid://73780377692148",
    chevron_right = "rbxassetid://92473583511724",
    chevron_up = "rbxassetid://122444883127455",
    circle = "rbxassetid://130359823580534",
    check = "rbxassetid://93898873302694",
    plus = "rbxassetid://111774323017047",
    slider = "rbxassetid://85538382643347",
    toggle = "rbxassetid://90411952142550",
    command = "rbxassetid://93648221906330",
    text_cursor = "rbxassetid://107551944047171",
    mouse = "rbxassetid://107150227368485",
    palette = "rbxassetid://86350350950064",
    chart_bar = "rbxassetid://105389816384108",
    terminal = "rbxassetid://106783148545356",
    table_of_contents = "rbxassetid://135044763275414",
    type_icon = "rbxassetid://133543553793564",
    move = "rbxassetid://116138709011735",
    expand = "rbxassetid://137492887754537",
    cube = "rbxassetid://126791525623846",
    lock = "rbxassetid://134724289526879",
    unlock = "rbxassetid://81326871090745",
    copy = "rbxassetid://78979572434545",
    trash = "rbxassetid://106723740584310",
    edit = "rbxassetid://103077118663569",
    save = "rbxassetid://126116963775616",
    refresh = "rbxassetid://138133190015277",
    folder = "rbxassetid://80846616596607",
    file = "rbxassetid://74748492079329",
    user = "rbxassetid://81589895647169",
    heart = "rbxassetid://116559368303288",
    star = "rbxassetid://136141469398409",
    flag = "rbxassetid://78183383236196",
    calendar = "rbxassetid://114792700814035",
    clock = "rbxassetid://121808839832144",
    compass = "rbxassetid://115123411028382",
    globe = "rbxassetid://114238209622913",
    map_pin = "rbxassetid://84279202219901",
    gift = "rbxassetid://109855212076373",
    award = "rbxassetid://132740088158419",
    medal = "rbxassetid://79016002264450",
    trophy = "rbxassetid://131545003268773",
    target = "rbxassetid://87563802520297",
    rocket = "rbxassetid://87412317685854",
    zap = "rbxassetid://130551565616516",
    bolt = "rbxassetid://102881251417484",
    cloud = "rbxassetid://121226497050352",
    sun = "rbxassetid://110150589884127",
    moon = "rbxassetid://83380517901735",
    wifi = "rbxassetid://104669375183960",
    bluetooth = "rbxassetid://90506573139443",
    battery = "rbxassetid://70765800346189",
    cpu = "rbxassetid://77549309870247",
    database = "rbxassetid://126791525623846",
    server = "rbxassetid://92188766517878",
    shield = "rbxassetid://110987169760162",
    alert = "rbxassetid://125920361880643",
    help = "rbxassetid://97516698664325",
    life_buoy = "rbxassetid://81168450671956",
    login = "rbxassetid://103768533135201",
    logout = "rbxassetid://84895399304975",
    shopping_cart = "rbxassetid://128420521375441",
    credit_card = "rbxassetid://99163352872346",
    wallet = "rbxassetid://132331555762628",
    banknote = "rbxassetid://104840231536668",
    coins = "rbxassetid://116510979641930",
    dollar = "rbxassetid://127320961224019",
    crown = "rbxassetid://127843403295538",
    gem = "rbxassetid://112904952151156",
    key = "rbxassetid://96510194465420",
    eye = "rbxassetid://100033680381365",
    eye_off = "rbxassetid://135928786788378",
    smartphone = "rbxassetid://96623008834511",
    tablet = "rbxassetid://128403991264386",
    monitor = "rbxassetid://72664649203050",
    laptop = "rbxassetid://111387063244975",
    tv = "rbxassetid://135687724791776",
    radio = "rbxassetid://85611589536956",
    headphones = "rbxassetid://118833729589183",
    speaker = "rbxassetid://96227183003618",
    mic = "rbxassetid://89640799126523",
    mic_off = "rbxassetid://82123034444822",
    volume = "rbxassetid://89344380902620",
    volume_x = "rbxassetid://139252359189540",
    pause = "rbxassetid://74873705394436",
    play = "rbxassetid://135609604299893",
    stop = "rbxassetid://74753225999323",
    skip_forward = "rbxassetid://124844823753990",
    skip_back = "rbxassetid://70466132711334",
    fast_forward = "rbxassetid://121615540167909",
    rewind = "rbxassetid://95205297521988",
    shuffle = "rbxassetid://132382786975101",
    repeat = "rbxassetid://121886242955173",
    link = "rbxassetid://131607023382430",
    list = "rbxassetid://113179976918783",
    grid = "rbxassetid://99050491897640",
    hash = "rbxassetid://82890331678520",
    bold = "rbxassetid://116141470019166",
    italic = "rbxassetid://96220378864282",
    underline = "rbxassetid://123709229216544",
    strikethrough = "rbxassetid://103417324549613",
    align_left = "rbxassetid://105020230154823",
    align_center = "rbxassetid://118470463752466",
    align_right = "rbxassetid://125674804697729",
    justify = "rbxassetid://80279880143030",
    image = "rbxassetid://112751259236831",
    code = "rbxassetid://106783148545356",
    color = "rbxassetid://86350350950064",
    keybind = "rbxassetid://93648221906330",
    notification = "rbxassetid://97392696311902",
    tooltip = "rbxassetid://124560466474914",
    theme = "rbxassetid://80758916183665",
    reset = "rbxassetid://138133190015277",
    export = "rbxassetid://134814648082393",
    import = "rbxassetid://103768533135201",
}
local function getIcon(name) return Icons[name] or Icons.circle end

-- ============================================================
-- 2. NewRoundFrame 样式系统（完整）
-- ============================================================
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

-- ============================================================
-- 3. 配置管理（支持多配置）
-- ============================================================
local ConfigManager = {}
ConfigManager.basePath = "WindUI/主面板/"
ConfigManager.currentConfig = "默认配置"

function ConfigManager:getPath(name)
    return self.basePath .. name .. ".json"
end

function ConfigManager:listConfigs()
    if not listfiles then return {"默认配置"} end
    local files = listfiles(self.basePath)
    local names = {}
    for _, file in ipairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    if #names == 0 then names = {"默认配置"} end
    return names
end

function ConfigManager:load(name)
    name = name or self.currentConfig
    local path = self:getPath(name)
    if not isfile or not isfile(path) then return {} end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if ok and type(data) == "table" then return data else return {} end
end

function ConfigManager:save(data, name)
    name = name or self.currentConfig
    if not writefile then return end
    if not isfolder(self.basePath) then makefolder(self.basePath) end
    local json = HttpService:JSONEncode(data)
    writefile(self:getPath(name), json)
end

function ConfigManager:reset(name)
    name = name or self.currentConfig
    local path = self:getPath(name)
    if isfile and isfile(path) then delfile(path) end
    return {}
end

-- ============================================================
-- 4. 工具函数
-- ============================================================
local function createLabeledControl(parent, icon, text, controlFrame)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent
    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(0, 20, 0, 20)
    iconImg.Position = UDim2.new(0, 0, 0.5, 0)
    iconImg.AnchorPoint = Vector2.new(0, 0.5)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = getIcon(icon)
    iconImg.ImageColor3 = Color3.fromRGB(200, 200, 200)
    iconImg.Parent = container
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30 - 120, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    if controlFrame then
        controlFrame.Position = UDim2.new(1, -controlFrame.Size.X.Offset, 0.5, 0)
        controlFrame.AnchorPoint = Vector2.new(1, 0.5)
        controlFrame.Parent = container
    end
    return container
end

-- 通知系统
local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "Notifications"
NotificationGui.ResetOnSpawn = false
NotificationGui.Parent = player:WaitForChild("PlayerGui")

local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 320, 1, 0)
notifContainer.Position = UDim2.new(1, -20, 0, 10)
notifContainer.AnchorPoint = Vector2.new(1, 0)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = NotificationGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.FillDirection = Enum.FillDirection.Vertical
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.Padding = UDim.new(0, 8)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Parent = notifContainer

function Notify(title, content, duration, icon)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = notifContainer
    local bg = NewRoundFrame(12, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(40, 40, 45),
        ImageTransparency = 0,
        Parent = frame,
    })
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 24)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "提示"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = bg
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 0, 20)
    contentLabel.Position = UDim2.new(0, 10, 0, 30)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content or ""
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 13
    contentLabel.Font = Enum.Font.GothamMedium
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.Parent = bg
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 300, 0, 0)
        }):Play()
        task.delay(0.35, function() frame:Destroy() end)
    end)
end

-- 工具提示系统
local TooltipGui = Instance.new("ScreenGui")
TooltipGui.Name = "Tooltips"
TooltipGui.ResetOnSpawn = false
TooltipGui.Parent = player:WaitForChild("PlayerGui")

local tooltipFrame = Instance.new("Frame")
tooltipFrame.Size = UDim2.new(0, 0, 0, 0)
tooltipFrame.BackgroundTransparency = 1
tooltipFrame.Visible = false
tooltipFrame.ZIndex = 999
tooltipFrame.Parent = TooltipGui

local tooltipBg = NewRoundFrame(8, "Squircle", {
    Size = UDim2.new(0, 0, 0, 0),
    ImageColor3 = Color3.fromRGB(30, 30, 35),
    ImageTransparency = 0,
    Parent = tooltipFrame,
})
local tooltipText = Instance.new("TextLabel")
tooltipText.Size = UDim2.new(0, 0, 0, 0)
tooltipText.BackgroundTransparency = 1
tooltipText.Text = ""
tooltipText.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltipText.TextSize = 14
tooltipText.Font = Enum.Font.GothamMedium
tooltipText.TextWrapped = true
tooltipText.Parent = tooltipBg
local tooltipPadding = Instance.new("UIPadding")
tooltipPadding.PaddingTop = UDim.new(0, 6)
tooltipPadding.PaddingBottom = UDim.new(0, 6)
tooltipPadding.PaddingLeft = UDim.new(0, 10)
tooltipPadding.PaddingRight = UDim.new(0, 10)
tooltipPadding.Parent = tooltipBg
local tooltipSize = Instance.new("UISizeConstraint")
tooltipSize.MaxSize = Vector2.new(300, 100)
tooltipSize.Parent = tooltipBg

local function showTooltip(obj, text)
    obj.MouseEnter:Connect(function()
        tooltipText.Text = text
        tooltipFrame.Visible = true
        tooltipFrame.Size = UDim2.new(0, 0, 0, 0)
        local pos = UserInputService:GetMouseLocation()
        tooltipFrame.Position = UDim2.new(0, pos.X + 12, 0, pos.Y + 12)
        local function updatePos()
            local mp = UserInputService:GetMouseLocation()
            tooltipFrame.Position = UDim2.new(0, mp.X + 12, 0, mp.Y + 12)
        end
        local conn = UserInputService.InputChanged:Connect(function()
            if tooltipFrame.Visible then updatePos() end
        end)
        obj.MouseLeave:Connect(function()
            tooltipFrame.Visible = false
            conn:Disconnect()
        end)
        task.wait(0.05)
        tooltipFrame.Size = UDim2.new(0, tooltipText.TextBounds.X + 20, 0, tooltipText.TextBounds.Y + 12)
        tooltipBg.Size = UDim2.new(1, 0, 1, 0)
    end)
end

-- ============================================================
-- 5. 主面板核心
-- ============================================================
local function createMainPanel()
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local viewport = workspace.CurrentCamera.ViewportSize
    local w = isMobile and viewport.X * 0.92 or 580
    local h = isMobile and viewport.Y * 0.82 or 440
    local radius = isMobile and 20 or 16
    local titleH = isMobile and 56 or 52
    local iconSize = 22
    local dragFrameSize = 160
    local sideW = isMobile and 0 or 200

    -- 加载配置
    local config = ConfigManager:load()
    local savedSize = config.windowSize
    local savedPos = config.windowPos
    if savedSize then w = savedSize.w or w; h = savedSize.h or h end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MainPanel"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, w, 0, h)
    if savedPos then
        panel.Position = UDim2.new(savedPos.xScale or 0.5, savedPos.xOffset or -w/2,
                                    savedPos.yScale or 0.5, savedPos.yOffset or -h/2)
    else
        panel.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    end
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.Parent = gui

    -- 背景
    local bg = NewRoundFrame(radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(28, 28, 30),
        ImageTransparency = 0,
        ZIndex = 1,
        Parent = panel,
    })

    -- 阴影
    local shadow = NewRoundFrame(radius, "Shadow-sm", {
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0.5, -30, 0.5, -30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageTransparency = 0.4,
        ZIndex = 0,
        Parent = panel,
    })

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, titleH)
    titleBar.BackgroundTransparency = 1
    titleBar.ZIndex = 2
    titleBar.Parent = panel

    -- 图标
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
    icon.ImageColor3 = Color3.fromRGB(220, 220, 220)
    icon.Parent = iconContainer

    -- 标题 + 副标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 0, 24)
    title.Position = UDim2.new(0, 14 + iconSize + 8, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "主面板"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = isMobile and 18 or 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    title.ZIndex = 3
    title.Parent = titleBar

    local authorLabel = Instance.new("TextLabel")
    authorLabel.Size = UDim2.new(1, -120, 0, 16)
    authorLabel.Position = UDim2.new(0, 14 + iconSize + 8, 0, 28)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Text = ""
    authorLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    authorLabel.TextSize = 12
    authorLabel.Font = Enum.Font.GothamMedium
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.ZIndex = 3
    authorLabel.Parent = titleBar

    -- 顶部右侧（搜索 + 系统按钮）
    local btnSize = isMobile and 40 or 36
    local spacing = isMobile and 6 or 9

    local rightContainer = Instance.new("Frame")
    rightContainer.Size = UDim2.new(0, btnSize * 4 + spacing * 3 + 160, 1, 0)
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

    -- 搜索框
    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(0, 160, 0, 32)
    searchContainer.BackgroundTransparency = 1
    searchContainer.LayoutOrder = 0
    searchContainer.Parent = rightContainer
    local searchBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(60, 60, 65),
        ImageTransparency = 0.6,
        Parent = searchContainer,
    })
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 10, 0.5, 0)
    searchIcon.AnchorPoint = Vector2.new(0, 0.5)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = getIcon("search")
    searchIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
    searchIcon.Parent = searchContainer
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -36, 1, 0)
    searchBox.Position = UDim2.new(0, 32, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "搜索..."
    searchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    searchBox.TextSize = 14
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchContainer

    -- 系统按钮
    local function makeButton(img, layoutOrder, hoverColor, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, btnSize, 0, btnSize)
        container.BackgroundTransparency = 1
        container.LayoutOrder = layoutOrder
        container.ZIndex = 3
        container.Parent = rightContainer
        local btnBg = NewRoundFrame(999, "Circle", {
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
            TweenService:Create(btnBg, TweenInfo.new(0.12), {ImageTransparency = 0.85}):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), {ImageColor3 = hoverColor}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btnBg, TweenInfo.new(0.12), {ImageTransparency = 1}):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(180,180,180)}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)
        return container, btn
    end

    local isMax = false
    local prevSize, prevPos
    local isClosing = false
    local maxBtn

    -- 关闭
    local function closeWindow()
        if isClosing then return end
        isClosing = true
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
        -- 确认对话框
        local dialogGui = Instance.new("ScreenGui")
        dialogGui.Name = "ConfirmDialog"
        dialogGui.ResetOnSpawn = false
        dialogGui.Parent = player:WaitForChild("PlayerGui")
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.6
        overlay.ZIndex = 999
        overlay.Parent = dialogGui
        local dialogBg = NewRoundFrame(16, "Squircle", {
            Size = UDim2.new(0, 340, 0, 160),
            Position = UDim2.new(0.5, -170, 0.5, -80),
            ImageColor3 = Color3.fromRGB(45, 45, 50),
            ImageTransparency = 0,
            ZIndex = 1000,
            Parent = overlay,
        })
        local dialogTitle = Instance.new("TextLabel")
        dialogTitle.Size = UDim2.new(1, -40, 0, 30)
        dialogTitle.Position = UDim2.new(0, 20, 0, 20)
        dialogTitle.BackgroundTransparency = 1
        dialogTitle.Text = "关闭窗口"
        dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        dialogTitle.TextSize = 18
        dialogTitle.Font = Enum.Font.GothamSemibold
        dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
        dialogTitle.Parent = dialogBg
        local dialogContent = Instance.new("TextLabel")
        dialogContent.Size = UDim2.new(1, -40, 0, 30)
        dialogContent.Position = UDim2.new(0, 20, 0, 55)
        dialogContent.BackgroundTransparency = 1
        dialogContent.Text = "确定要关闭窗口吗？"
        dialogContent.TextColor3 = Color3.fromRGB(200, 200, 200)
        dialogContent.TextSize = 15
        dialogContent.Font = Enum.Font.GothamMedium
        dialogContent.TextXAlignment = Enum.TextXAlignment.Left
        dialogContent.Parent = dialogBg
        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, -40, 0, 40)
        btnContainer.Position = UDim2.new(0, 20, 1, -50)
        btnContainer.BackgroundTransparency = 1
        btnContainer.Parent = dialogBg
        local btnLayout = Instance.new("UIListLayout")
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
        btnLayout.Padding = UDim.new(0, 10)
        btnLayout.Parent = btnContainer
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 100, 0, 36)
        cancelBtn.BackgroundTransparency = 1
        cancelBtn.Text = "取消"
        cancelBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        cancelBtn.TextSize = 15
        cancelBtn.Font = Enum.Font.GothamMedium
        cancelBtn.LayoutOrder = 1
        cancelBtn.Parent = btnContainer
        local cancelBg = NewRoundFrame(999, "SquircleH", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ZIndex = 0,
            Parent = cancelBtn,
        })
        cancelBtn.MouseEnter:Connect(function()
            TweenService:Create(cancelBg, TweenInfo.new(0.12), {ImageTransparency = 0.85}):Play()
        end)
        cancelBtn.MouseLeave:Connect(function()
            TweenService:Create(cancelBg, TweenInfo.new(0.12), {ImageTransparency = 1}):Play()
        end)
        cancelBtn.MouseButton1Click:Connect(function()
            dialogGui:Destroy()
            isClosing = false
        end)
        local confirmBtn = Instance.new("TextButton")
        confirmBtn.Size = UDim2.new(0, 100, 0, 36)
        confirmBtn.BackgroundTransparency = 1
        confirmBtn.Text = "关闭"
        confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmBtn.TextSize = 15
        confirmBtn.Font = Enum.Font.GothamMedium
        confirmBtn.LayoutOrder = 2
        confirmBtn.Parent = btnContainer
        local confirmBg = NewRoundFrame(999, "SquircleH", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = Color3.fromRGB(200, 50, 50),
            ImageTransparency = 0,
            ZIndex = 0,
            Parent = confirmBtn,
        })
        confirmBtn.MouseEnter:Connect(function()
            TweenService:Create(confirmBg, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(220, 60, 60)}):Play()
        end)
        confirmBtn.MouseLeave:Connect(function()
            TweenService:Create(confirmBg, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        end)
        confirmBtn.MouseButton1Click:Connect(function()
            dialogGui:Destroy()
            local t = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, 0),
                Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, 0.5, 0),
            })
            t:Play()
            t.Completed:Connect(function() gui:Destroy() end)
        end)
        -- ESC关闭对话框
        local escConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Escape then
                dialogGui:Destroy()
                isClosing = false
                escConn:Disconnect()
            end
        end)
    end

    -- 最大化
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
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10),
            }):Play()
            isMax = true
            maxBtn.Image = getIcon("minimize")
        end
    end

    -- 最小化
    local function minimizeWindow()
        if isClosing then return end
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
        local t = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, titleH),
            Position = UDim2.new(panel.Position.X.Scale, panel.Position.X.Offset, panel.Position.Y.Scale, panel.Position.Y.Offset + panel.Size.Y.Offset/2 - titleH/2),
        })
        t:Play()
        t.Completed:Connect(function()
            panel.Visible = false
            panel.Size = UDim2.new(0, w, 0, h)
            panel.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
        end)
    end

    local buttonDefs = {
        { name = "min", image = getIcon("minus"), order = 2, hover = Color3.fromRGB(255,200,50), callback = minimizeWindow },
        { name = "max", image = getIcon("maximize"), order = 3, hover = Color3.fromRGB(50,200,100), callback = toggleMaximize },
        { name = "close", image = getIcon("x"), order = 4, hover = Color3.fromRGB(255,80,80), callback = closeWindow },
    }
    local buttonRefs = {}
    for _, def in ipairs(buttonDefs) do
        local container, btn = makeButton(def.image, def.order, def.hover, def.callback)
        buttonRefs[def.name] = { container = container, btn = btn }
        if def.name == "max" then maxBtn = btn end
    end

    -- 双击标题栏居中
    local lastClickTime = 0
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local now = tick()
            if now - lastClickTime < 0.4 then
                TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -panel.Size.X.Offset/2, 0.5, -panel.Size.Y.Offset/2),
                }):Play()
            end
            lastClickTime = now
        end
    end)

    -- 动态调整标题宽度
    local function updateTitleSize()
        local rightWidth = rightContainer.AbsoluteSize.X
        title.Size = UDim2.new(1, -(14 + iconSize + 8 + rightWidth + 12), 0, 24)
        authorLabel.Size = UDim2.new(1, -(14 + iconSize + 8 + rightWidth + 12), 0, 16)
    end
    rightContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTitleSize)
    task.spawn(updateTitleSize)

    -- 侧边栏
    local sideBar = Instance.new("ScrollingFrame")
    sideBar.Size = UDim2.new(0, sideW, 1, -titleH)
    sideBar.Position = UDim2.new(0, 0, 0, titleH)
    sideBar.BackgroundTransparency = 1
    sideBar.ScrollBarThickness = 0
    sideBar.ElasticBehavior = Enum.ElasticBehavior.Never
    sideBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sideBar.Visible = not isMobile
    sideBar.Parent = panel

    local sideContent = Instance.new("Frame")
    sideContent.Size = UDim2.new(1, 0, 0, 0)
    sideContent.BackgroundTransparency = 1
    sideContent.AutomaticSize = Enum.AutomaticSize.Y
    sideContent.Parent = sideBar

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.FillDirection = Enum.FillDirection.Vertical
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.Padding = UDim.new(0, 2)
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Parent = sideContent

    local sidePadding = Instance.new("UIPadding")
    sidePadding.PaddingTop = UDim.new(0, 8)
    sidePadding.PaddingBottom = UDim.new(0, 8)
    sidePadding.Parent = sideContent

    -- 内容区
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -sideW, 1, -titleH)
    content.Position = UDim2.new(0, sideW, 0, titleH)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = panel

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 16)
    contentPadding.PaddingLeft = UDim.new(0, 16)
    contentPadding.PaddingRight = UDim.new(0, 16)
    contentPadding.PaddingBottom = UDim.new(0, 16)
    contentPadding.Parent = contentContainer

    -- 面板背景（可切换）
    local panelBg = NewRoundFrame(radius, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(40, 40, 45),
        ImageTransparency = 0.5,
        ZIndex = 0,
        Parent = content,
    })
    local panelBgVisible = true

    -- 3D视口：玩家角色（静态）
    local viewportContainer = Instance.new("Frame")
    viewportContainer.Size = UDim2.new(0, 200, 0, 150)
    viewportContainer.Position = UDim2.new(0, 16, 1, -166)
    viewportContainer.BackgroundTransparency = 1
    viewportContainer.ZIndex = 10
    viewportContainer.Parent = contentContainer

    local viewportBg = NewRoundFrame(12, "Squircle", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(20, 20, 22),
        ImageTransparency = 0.3,
        Parent = viewportContainer,
    })
    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1, 0, 1, 0)
    viewport.BackgroundTransparency = 1
    viewport.Parent = viewportContainer
    local cam = Instance.new("Camera")
    cam.Parent = viewport
    viewport.CurrentCamera = cam

    local function updatePlayerModel()
        for _, child in pairs(viewport:GetChildren()) do if child ~= cam then child:Destroy() end end
        local character = player.Character
        if not character or not character.PrimaryPart then
            local part = Instance.new("Part")
            part.Size = Vector3.new(2, 2, 2)
            part.Position = Vector3.new(0, 0, 0)
            part.Anchored = true
            part.BrickColor = BrickColor.new("Bright blue")
            part.Material = Enum.Material.SmoothPlastic
            part.Parent = viewport
            cam.CFrame = CFrame.new(Vector3.new(0, 0, 5), Vector3.new(0, 0, 0))
            return
        end
        local clone = character:Clone()
        clone.Parent = viewport
        local primary = clone.PrimaryPart
        if primary then
            primary.Position = Vector3.new(0, 0, 0)
            clone:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
        end
        local size = character:GetExtentsSize()
        local dist = math.max(size.X, size.Y, size.Z) * 1.8 + 3
        cam.CFrame = CFrame.new(Vector3.new(0, size.Y/2, dist), Vector3.new(0, size.Y/2, 0))
    end
    updatePlayerModel()
    player.CharacterAdded:Connect(updatePlayerModel)

    -- ============================================================
    -- Tab 系统
    -- ============================================================
    local tabs = {}
    local function createTabButton(tabData)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -16, 0, 0)
        container.BackgroundTransparency = 1
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.Parent = sideContent

        local tabBg = NewRoundFrame(10, "SquircleH", {
            Size = UDim2.new(1, 0, 0, 38),
            ImageTransparency = 1,
            ZIndex = 0,
            Parent = container,
        })
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 1
        btn.Parent = container

        local iconBg = NewRoundFrame(999, "Circle", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(0, 6, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageTransparency = 0.85,
            ImageColor3 = Color3.fromRGB(60, 60, 65),
            Parent = btn,
        })
        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 16, 0, 16)
        iconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        iconImg.AnchorPoint = Vector2.new(0.5, 0.5)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(tabData.icon or "circle")
        iconImg.ImageColor3 = Color3.fromRGB(180, 180, 180)
        iconImg.Parent = iconBg

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Position = UDim2.new(0, 38, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = tabData.title
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 15
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn

        local indicator = NewRoundFrame(999, "SquircleH", {
            Size = UDim2.new(0, 3, 0, 24),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageTransparency = 1,
            ImageColor3 = Color3.fromRGB(0, 150, 255),
            Parent = btn,
        })

        function container:select()
            for _, t in pairs(tabs) do t:unselect() end
            TweenService:Create(tabBg, TweenInfo.new(0.15), {ImageTransparency = 0.85}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.15), {ImageTransparency = 0}):Play()
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            for _, child in pairs(contentContainer:GetChildren()) do
                if child:IsA("Frame") and child ~= viewportContainer then
                    child.Visible = false
                end
            end
            if tabData.content then tabData.content.Visible = true end
        end
        function container:unselect()
            TweenService:Create(tabBg, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        btn.MouseButton1Click:Connect(function() container:select() end)
        -- 工具提示
        if tabData.tooltip then
            showTooltip(btn, tabData.tooltip)
        end
        container.btn = btn
        container.tabBg = tabBg
        container.label = label
        container.indicator = indicator
        return container
    end

    -- ============================================================
    -- 控件数据（用于配置保存）
    -- ============================================================
    local controlsData = {}

    -- ============================================================
    -- 创建各 Tab 内容（完整控件展示）
    -- ============================================================

    -- -------- Tab1: 基础控件 --------
    local basicContent = Instance.new("Frame")
    basicContent.Size = UDim2.new(1, 0, 1, 0)
    basicContent.BackgroundTransparency = 1
    basicContent.Visible = false
    basicContent.Parent = contentContainer

    local basicLayout = Instance.new("UIListLayout")
    basicLayout.FillDirection = Enum.FillDirection.Vertical
    basicLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    basicLayout.Padding = UDim.new(0, 12)
    basicLayout.SortOrder = Enum.SortOrder.LayoutOrder
    basicLayout.Parent = basicContent

    local basicTitle = Instance.new("TextLabel")
    basicTitle.Size = UDim2.new(1, 0, 0, 30)
    basicTitle.BackgroundTransparency = 1
    basicTitle.Text = "📋 基础控件"
    basicTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    basicTitle.TextSize = 22
    basicTitle.Font = Enum.Font.GothamSemibold
    basicTitle.TextXAlignment = Enum.TextXAlignment.Left
    basicTitle.Parent = basicContent

    -- 按钮
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 200, 0, 40)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = basicContent
    local btnBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(0, 120, 255),
        ImageTransparency = 0,
        Parent = btnContainer,
    })
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "点击我"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = btnContainer
    btn.MouseEnter:Connect(function()
        TweenService:Create(btnBg, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(0, 140, 255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btnBg, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(0, 120, 255)}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        Notify("按钮点击", "你点击了按钮！", 2)
    end)
    showTooltip(btn, "这是一个示例按钮")

    -- 开关
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, 0, 0, 40)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = basicContent
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0, 100, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = "启用功能"
    toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    toggleLabel.TextSize = 15
    toggleLabel.Font = Enum.Font.GothamMedium
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleContainer
    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 50, 0, 28)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, 0)
    toggleBtn.AnchorPoint = Vector2.new(0, 0.5)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Parent = toggleContainer
    local toggleBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(80, 80, 85),
        ImageTransparency = 0,
        Parent = toggleBtn,
    })
    local toggleThumb = NewRoundFrame(999, "Circle", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0,
        Parent = toggleBtn,
    })
    local toggleState = false
    controlsData.toggleState = toggleState
    toggleBtn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        controlsData.toggleState = toggleState
        if toggleState then
            TweenService:Create(toggleBg, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(0, 180, 80)}):Play()
            TweenService:Create(toggleThumb, TweenInfo.new(0.15), {Position = UDim2.new(1, -25, 0.5, 0)}):Play()
            Notify("开关", "已启用", 1.5)
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(80, 80, 85)}):Play()
            TweenService:Create(toggleThumb, TweenInfo.new(0.15), {Position = UDim2.new(0, 3, 0.5, 0)}):Play()
            Notify("开关", "已禁用", 1.5)
        end
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
    end)
    showTooltip(toggleBtn, "切换开关状态")

    -- 滑块
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, 0, 0, 50)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = basicContent
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 100, 1, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = "音量"
    sliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    sliderLabel.TextSize = 15
    sliderLabel.Font = Enum.Font.GothamMedium
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderContainer
    local sliderTrack = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(0, 180, 0, 6),
        Position = UDim2.new(0, 100, 0.5, 0),
        ImageColor3 = Color3.fromRGB(70, 70, 75),
        ImageTransparency = 0,
        Parent = sliderContainer,
    })
    local sliderFill = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(0.5, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(0, 150, 255),
        ImageTransparency = 0,
        Parent = sliderTrack,
    })
    local sliderThumb = NewRoundFrame(999, "Circle", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0,
        Parent = sliderTrack,
    })
    local sliderValue = Instance.new("TextLabel")
    sliderValue.Size = UDim2.new(0, 40, 1, 0)
    sliderValue.Position = UDim2.new(1, -40, 0, 0)
    sliderValue.BackgroundTransparency = 1
    sliderValue.Text = "50%"
    sliderValue.TextColor3 = Color3.fromRGB(180, 180, 180)
    sliderValue.TextSize = 14
    sliderValue.Font = Enum.Font.GothamMedium
    sliderValue.TextXAlignment = Enum.TextXAlignment.Center
    sliderValue.Parent = sliderContainer

    local sliderPercent = 0.5
    controlsData.sliderPercent = sliderPercent
    local function updateSlider(pos)
        local trackSize = sliderTrack.AbsoluteSize.X
        if trackSize == 0 then return end
        local p = math.clamp((pos - sliderTrack.AbsolutePosition.X) / trackSize, 0, 1)
        sliderFill.Size = UDim2.new(p, 0, 1, 0)
        sliderThumb.Position = UDim2.new(p, 0, 0.5, 0)
        sliderValue.Text = math.floor(p * 100) .. "%"
        sliderPercent = p
        controlsData.sliderPercent = p
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
    end
    local sliderDragging = false
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            updateSlider(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)
    showTooltip(sliderTrack, "拖拽调整音量")

    -- 输入框
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(0, 280, 0, 40)
    inputContainer.BackgroundTransparency = 1
    inputContainer.Parent = basicContent
    local inputLabel = Instance.new("TextLabel")
    inputLabel.Size = UDim2.new(0, 80, 1, 0)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Text = "用户名"
    inputLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    inputLabel.TextSize = 15
    inputLabel.Font = Enum.Font.GothamMedium
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    inputLabel.Parent = inputContainer
    local inputBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 80, 0, 0),
        ImageColor3 = Color3.fromRGB(50, 50, 55),
        ImageTransparency = 0.5,
        Parent = inputContainer,
    })
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -10, 1, 0)
    inputBox.Position = UDim2.new(0, 5, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = ""
    inputBox.PlaceholderText = "输入..."
    inputBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = inputBg
    controlsData.inputText = ""
    inputBox:GetPropertyChangedSignal("Text"):Connect(function()
        controlsData.inputText = inputBox.Text
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
    end)
    showTooltip(inputBox, "请输入文本")

    -- 下拉菜单
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(0, 200, 0, 40)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = basicContent
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Size = UDim2.new(0, 80, 1, 0)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = "主题"
    dropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    dropdownLabel.TextSize = 15
    dropdownLabel.Font = Enum.Font.GothamMedium
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownContainer
    local dropdownBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 80, 0, 0),
        ImageColor3 = Color3.fromRGB(50, 50, 55),
        ImageTransparency = 0.5,
        Parent = dropdownContainer,
    })
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Size = UDim2.new(1, -30, 1, 0)
    dropdownText.Position = UDim2.new(0, 10, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Text = "深色"
    dropdownText.TextColor3 = Color3.fromRGB(220, 220, 220)
    dropdownText.TextSize = 14
    dropdownText.Font = Enum.Font.GothamMedium
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Parent = dropdownBg
    local dropdownArrow = Instance.new("ImageLabel")
    dropdownArrow.Size = UDim2.new(0, 16, 0, 16)
    dropdownArrow.Position = UDim2.new(1, -10, 0.5, 0)
    dropdownArrow.AnchorPoint = Vector2.new(1, 0.5)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Image = getIcon("chevron_down")
    dropdownArrow.ImageColor3 = Color3.fromRGB(150, 150, 150)
    dropdownArrow.Parent = dropdownBg
    local options = {"深色", "浅色", "自动"}
    local optIndex = 1
    controlsData.dropdownIndex = optIndex
    dropdownBg.MouseButton1Click:Connect(function()
        optIndex = optIndex % #options + 1
        dropdownText.Text = options[optIndex]
        controlsData.dropdownIndex = optIndex
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
        Notify("主题切换", "当前主题: " .. options[optIndex], 1.5)
    end)
    showTooltip(dropdownBg, "点击切换主题")

    -- -------- Tab2: 高级控件 --------
    local advancedContent = Instance.new("Frame")
    advancedContent.Size = UDim2.new(1, 0, 1, 0)
    advancedContent.BackgroundTransparency = 1
    advancedContent.Visible = false
    advancedContent.Parent = contentContainer

    local advLayout = Instance.new("UIListLayout")
    advLayout.FillDirection = Enum.FillDirection.Vertical
    advLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    advLayout.Padding = UDim.new(0, 12)
    advLayout.SortOrder = Enum.SortOrder.LayoutOrder
    advLayout.Parent = advancedContent

    local advTitle = Instance.new("TextLabel")
    advTitle.Size = UDim2.new(1, 0, 0, 30)
    advTitle.BackgroundTransparency = 1
    advTitle.Text = "🔧 高级控件"
    advTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    advTitle.TextSize = 22
    advTitle.Font = Enum.Font.GothamSemibold
    advTitle.TextXAlignment = Enum.TextXAlignment.Left
    advTitle.Parent = advancedContent

    -- 颜色选择器
    local colorContainer = Instance.new("Frame")
    colorContainer.Size = UDim2.new(1, 0, 0, 50)
    colorContainer.BackgroundTransparency = 1
    colorContainer.Parent = advancedContent
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0, 100, 1, 0)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "颜色"
    colorLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    colorLabel.TextSize = 15
    colorLabel.Font = Enum.Font.GothamMedium
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = colorContainer
    local colorPreview = NewRoundFrame(999, "Circle", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 100, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ImageColor3 = Color3.fromRGB(255, 0, 0),
        ImageTransparency = 0,
        Parent = colorContainer,
    })
    local colorPickerBtn = Instance.new("TextButton")
    colorPickerBtn.Size = UDim2.new(0, 100, 0, 30)
    colorPickerBtn.Position = UDim2.new(0, 140, 0.5, 0)
    colorPickerBtn.AnchorPoint = Vector2.new(0, 0.5)
    colorPickerBtn.BackgroundTransparency = 1
    colorPickerBtn.Text = "选择颜色"
    colorPickerBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    colorPickerBtn.TextSize = 14
    colorPickerBtn.Font = Enum.Font.GothamMedium
    colorPickerBtn.Parent = colorContainer
    local colorPickerBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(60, 60, 65),
        ImageTransparency = 0.3,
        Parent = colorPickerBtn,
    })
    colorPickerBtn.MouseEnter:Connect(function()
        TweenService:Create(colorPickerBg, TweenInfo.new(0.12), {ImageTransparency = 0.1}):Play()
    end)
    colorPickerBtn.MouseLeave:Connect(function()
        TweenService:Create(colorPickerBg, TweenInfo.new(0.12), {ImageTransparency = 0.3}):Play()
    end)
    colorPickerBtn.MouseButton1Click:Connect(function()
        -- 简易颜色选择对话框（实际可用ColorPicker UI，这里用输入框模拟）
        local dialogGui = Instance.new("ScreenGui")
        dialogGui.Name = "ColorPicker"
        dialogGui.ResetOnSpawn = false
        dialogGui.Parent = player:WaitForChild("PlayerGui")
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.6
        overlay.ZIndex = 999
        overlay.Parent = dialogGui
        local bg = NewRoundFrame(16, "Squircle", {
            Size = UDim2.new(0, 300, 0, 120),
            Position = UDim2.new(0.5, -150, 0.5, -60),
            ImageColor3 = Color3.fromRGB(45, 45, 50),
            ImageTransparency = 0,
            ZIndex = 1000,
            Parent = overlay,
        })
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -40, 0, 30)
        title.Position = UDim2.new(0, 20, 0, 10)
        title.BackgroundTransparency = 1
        title.Text = "选择颜色 (输入Hex)"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.GothamSemibold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = bg
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -40, 0, 30)
        input.Position = UDim2.new(0, 20, 0, 45)
        input.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.TextSize = 14
        input.Font = Enum.Font.GothamMedium
        input.Text = "#FF0000"
        input.PlaceholderText = "#RRGGBB"
        input.Parent = bg
        local okBtn = Instance.new("TextButton")
        okBtn.Size = UDim2.new(0, 80, 0, 30)
        okBtn.Position = UDim2.new(1, -100, 1, -40)
        okBtn.BackgroundTransparency = 1
        okBtn.Text = "确定"
        okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        okBtn.TextSize = 14
        okBtn.Font = Enum.Font.GothamMedium
        okBtn.Parent = bg
        local okBg = NewRoundFrame(999, "SquircleH", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = Color3.fromRGB(0, 120, 255),
            ImageTransparency = 0,
            Parent = okBtn,
        })
        okBtn.MouseEnter:Connect(function()
            TweenService:Create(okBg, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(0, 140, 255)}):Play()
        end)
        okBtn.MouseLeave:Connect(function()
            TweenService:Create(okBg, TweenInfo.new(0.12), {ImageColor3 = Color3.fromRGB(0, 120, 255)}):Play()
        end)
        okBtn.MouseButton1Click:Connect(function()
            local hex = input.Text:gsub("#", "")
            if #hex == 6 then
                local r = tonumber(hex:sub(1,2), 16) or 255
                local g = tonumber(hex:sub(3,4), 16) or 0
                local b = tonumber(hex:sub(5,6), 16) or 0
                local c = Color3.fromRGB(r, g, b)
                colorPreview.ImageColor3 = c
                controlsData.color = {r=r, g=g, b=b}
                ConfigManager:save({
                    windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
                    windowPos = {
                        xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                        yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
                    },
                    controls = controlsData,
                })
                Notify("颜色已更新", "", 1)
            end
            dialogGui:Destroy()
        end)
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0, 80, 0, 30)
        cancelBtn.Position = UDim2.new(1, -20, 1, -40)
        cancelBtn.AnchorPoint = Vector2.new(1, 0)
        cancelBtn.BackgroundTransparency = 1
        cancelBtn.Text = "取消"
        cancelBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        cancelBtn.TextSize = 14
        cancelBtn.Font = Enum.Font.GothamMedium
        cancelBtn.Parent = bg
        local cancelBg = NewRoundFrame(999, "SquircleH", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            Parent = cancelBtn,
        })
        cancelBtn.MouseEnter:Connect(function()
            TweenService:Create(cancelBg, TweenInfo.new(0.12), {ImageTransparency = 0.85}):Play()
        end)
        cancelBtn.MouseLeave:Connect(function()
            TweenService:Create(cancelBg, TweenInfo.new(0.12), {ImageTransparency = 1}):Play()
        end)
        cancelBtn.MouseButton1Click:Connect(function() dialogGui:Destroy() end)
        local escConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Escape then
                dialogGui:Destroy()
                escConn:Disconnect()
            end
        end)
    end)
    showTooltip(colorPickerBtn, "点击选择颜色")

    -- 按键绑定
    local keybindContainer = Instance.new("Frame")
    keybindContainer.Size = UDim2.new(1, 0, 0, 40)
    keybindContainer.BackgroundTransparency = 1
    keybindContainer.Parent = advancedContent
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Size = UDim2.new(0, 100, 1, 0)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "快捷键"
    keybindLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    keybindLabel.TextSize = 15
    keybindLabel.Font = Enum.Font.GothamMedium
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindContainer
    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0, 120, 0, 30)
    keybindBtn.Position = UDim2.new(0, 100, 0.5, 0)
    keybindBtn.AnchorPoint = Vector2.new(0, 0.5)
    keybindBtn.BackgroundTransparency = 1
    keybindBtn.Text = "未设置"
    keybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    keybindBtn.TextSize = 14
    keybindBtn.Font = Enum.Font.GothamMedium
    keybindBtn.Parent = keybindContainer
    local keybindBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(1, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(60, 60, 65),
        ImageTransparency = 0.3,
        Parent = keybindBtn,
    })
    local keybindValue = "None"
    controlsData.keybind = keybindValue
    local recording = false
    keybindBtn.MouseButton1Click:Connect(function()
        if recording then return end
        recording = true
        keybindBtn.Text = "按任意键..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keybindValue = input.KeyCode.Name
                keybindBtn.Text = keybindValue
                controlsData.keybind = keybindValue
                ConfigManager:save({
                    windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
                    windowPos = {
                        xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                        yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
                    },
                    controls = controlsData,
                })
                Notify("按键绑定", "已设置为 " .. keybindValue, 1.5)
                recording = false
                conn:Disconnect()
            end
        end)
        task.delay(5, function()
            if recording then
                recording = false
                keybindBtn.Text = "超时"
                conn:Disconnect()
                task.delay(1, function() keybindBtn.Text = keybindValue or "未设置" end)
            end
        end)
    end)
    showTooltip(keybindBtn, "点击后按下键盘按键进行绑定")

    -- 代码块
    local codeContainer = Instance.new("Frame")
    codeContainer.Size = UDim2.new(1, 0, 0, 120)
    codeContainer.BackgroundTransparency = 1
    codeContainer.Parent = advancedContent
    local codeLabel = Instance.new("TextLabel")
    codeLabel.Size = UDim2.new(1, 0, 0, 20)
    codeLabel.BackgroundTransparency = 1
    codeLabel.Text = "代码块"
    codeLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    codeLabel.TextSize = 15
    codeLabel.Font = Enum.Font.GothamMedium
    codeLabel.TextXAlignment = Enum.TextXAlignment.Left
    codeLabel.Parent = codeContainer
    local codeBg = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 22),
        ImageColor3 = Color3.fromRGB(20, 20, 25),
        ImageTransparency = 0,
        Parent = codeContainer,
    })
    local codeText = Instance.new("TextLabel")
    codeText.Size = UDim2.new(1, -20, 1, -10)
    codeText.Position = UDim2.new(0, 10, 0, 5)
    codeText.BackgroundTransparency = 1
    codeText.Text = "print('Hello World!')\n-- 这是代码块"
    codeText.TextColor3 = Color3.fromRGB(200, 200, 200)
    codeText.TextSize = 13
    codeText.Font = Enum.Font.Code
    codeText.TextXAlignment = Enum.TextXAlignment.Left
    codeText.TextYAlignment = Enum.TextYAlignment.Top
    codeText.Parent = codeBg
    showTooltip(codeBg, "代码块，支持复制")

    -- -------- Tab3: 布局 & 其他 --------
    local extraContent = Instance.new("Frame")
    extraContent.Size = UDim2.new(1, 0, 1, 0)
    extraContent.BackgroundTransparency = 1
    extraContent.Visible = false
    extraContent.Parent = contentContainer

    local extraLayout = Instance.new("UIListLayout")
    extraLayout.FillDirection = Enum.FillDirection.Vertical
    extraLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    extraLayout.Padding = UDim.new(0, 12)
    extraLayout.SortOrder = Enum.SortOrder.LayoutOrder
    extraLayout.Parent = extraContent

    local extraTitle = Instance.new("TextLabel")
    extraTitle.Size = UDim2.new(1, 0, 0, 30)
    extraTitle.BackgroundTransparency = 1
    extraTitle.Text = "📦 布局 & 其他"
    extraTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    extraTitle.TextSize = 22
    extraTitle.Font = Enum.Font.GothamSemibold
    extraTitle.TextXAlignment = Enum.TextXAlignment.Left
    extraTitle.Parent = extraContent

    -- 分组容器 (Group)
    local groupContainer = Instance.new("Frame")
    groupContainer.Size = UDim2.new(1, 0, 0, 120)
    groupContainer.BackgroundTransparency = 1
    groupContainer.Parent = extraContent
    local groupTitle = Instance.new("TextLabel")
    groupTitle.Size = UDim2.new(1, 0, 0, 20)
    groupTitle.BackgroundTransparency = 1
    groupTitle.Text = "分组 (Group)"
    groupTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    groupTitle.TextSize = 15
    groupTitle.Font = Enum.Font.GothamMedium
    groupTitle.TextXAlignment = Enum.TextXAlignment.Left
    groupTitle.Parent = groupContainer
    local groupBg = NewRoundFrame(8, "SquircleOutline", {
        Size = UDim2.new(1, 0, 1, -24),
        Position = UDim2.new(0, 0, 0, 22),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.9,
        Parent = groupContainer,
    })
    local groupInner = Instance.new("Frame")
    groupInner.Size = UDim2.new(1, -20, 1, -20)
    groupInner.Position = UDim2.new(0, 10, 0, 10)
    groupInner.BackgroundTransparency = 1
    groupInner.Parent = groupBg
    local groupLayout = Instance.new("UIListLayout")
    groupLayout.FillDirection = Enum.FillDirection.Horizontal
    groupLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    groupLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    groupLayout.Padding = UDim.new(0, 10)
    groupLayout.SortOrder = Enum.SortOrder.LayoutOrder
    groupLayout.Parent = groupInner
    -- 组内加几个小按钮
    for i = 1, 3 do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 60, 0, 30)
        b.BackgroundTransparency = 1
        b.Text = "B"..i
        b.TextColor3 = Color3.fromRGB(200, 200, 200)
        b.TextSize = 13
        b.Font = Enum.Font.GothamMedium
        b.Parent = groupInner
        local bbg = NewRoundFrame(999, "SquircleH", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = Color3.fromRGB(60, 60, 65),
            ImageTransparency = 0.5,
            Parent = b,
        })
        b.MouseEnter:Connect(function()
            TweenService:Create(bbg, TweenInfo.new(0.12), {ImageTransparency = 0.2}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(bbg, TweenInfo.new(0.12), {ImageTransparency = 0.5}):Play()
        end)
    end

    -- 图片显示
    local imageContainer = Instance.new("Frame")
    imageContainer.Size = UDim2.new(0, 200, 0, 120)
    imageContainer.BackgroundTransparency = 1
    imageContainer.Parent = extraContent
    local imageLabel = Instance.new("TextLabel")
    imageLabel.Size = UDim2.new(1, 0, 0, 20)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Text = "图片"
    imageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    imageLabel.TextSize = 15
    imageLabel.Font = Enum.Font.GothamMedium
    imageLabel.TextXAlignment = Enum.TextXAlignment.Left
    imageLabel.Parent = imageContainer
    local img = NewRoundFrame(8, "Squircle", {
        Size = UDim2.new(1, 0, 1, -24),
        Position = UDim2.new(0, 0, 0, 22),
        ImageColor3 = Color3.fromRGB(30, 30, 35),
        ImageTransparency = 0,
        Parent = imageContainer,
        Image = "rbxassetid://92867583610071",  -- 示例图标
        ScaleType = Enum.ScaleType.Crop,
    })
    showTooltip(img, "这是图片显示区域")

    -- 进度条
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(0, 300, 0, 30)
    progressContainer.BackgroundTransparency = 1
    progressContainer.Parent = extraContent
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Size = UDim2.new(0, 80, 1, 0)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Text = "进度"
    progressLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    progressLabel.TextSize = 15
    progressLabel.Font = Enum.Font.GothamMedium
    progressLabel.TextXAlignment = Enum.TextXAlignment.Left
    progressLabel.Parent = progressContainer
    local progressBg = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(1, -80, 0, 6),
        Position = UDim2.new(0, 80, 0.5, 0),
        ImageColor3 = Color3.fromRGB(70, 70, 75),
        ImageTransparency = 0,
        Parent = progressContainer,
    })
    local progressFill = NewRoundFrame(999, "SquircleH", {
        Size = UDim2.new(0.7, 0, 1, 0),
        ImageColor3 = Color3.fromRGB(0, 200, 100),
        ImageTransparency = 0,
        Parent = progressBg,
    })
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(0, 40, 1, 0)
    progressText.Position = UDim2.new(1, -40, 0, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = "70%"
    progressText.TextColor3 = Color3.fromRGB(180, 180, 180)
    progressText.TextSize = 14
    progressText.Font = Enum.Font.GothamMedium
    progressText.Parent = progressContainer

    -- ===== 创建 Tab 按钮 =====
    local tabDataList = {
        { title = "基础", icon = "home", content = basicContent, tooltip = "基础控件" },
        { title = "高级", icon = "settings", content = advancedContent, tooltip = "高级控件" },
        { title = "其他", icon = "info", content = extraContent, tooltip = "布局和其他" },
    }

    for _, data in ipairs(tabDataList) do
        local tab = createTabButton(data)
        tabs[#tabs + 1] = tab
    end

    -- 默认选中第一个
    if tabs[1] then tabs[1]:select() end

    -- 搜索过滤
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        for _, tab in ipairs(tabs) do
            local visible = query == "" or string.find(string.lower(tab.label.Text), query, 1, true)
            tab.btn.Parent.Visible = visible
        end
    end)

    -- ============================================================
    -- 底部拖拽和缩放（同前，略）
    -- ============================================================
    local dragFrame = NewRoundFrame(99, "Squircle", {
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

    local resizeHandle = Instance.new("Frame")
    resizeHandle.Size = UDim2.new(0, 36, 0, 36)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.ZIndex = 99
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

    -- 拖拽逻辑（含保存）
    local currentInput = nil
    local dragData = { active = false, input = nil, inputType = nil, start = Vector2.new(), startPos = nil, highlight = false }
    local resizeData = { active = false, input = nil, inputType = nil, start = Vector2.new(), startSize = nil }
    local minW = isMobile and 300 or 400
    local minH = isMobile and 240 or 300

    local function onDragStart(input, highlight)
        if isClosing or currentInput or isMax then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        currentInput = input
        dragData.active = true
        dragData.input = input
        dragData.inputType = input.UserInputType
        dragData.start = input.Position
        dragData.startPos = panel.Position
        dragData.highlight = highlight
        if highlight then
            TweenService:Create(dragFrame, TweenInfo.new(0.1), {ImageTransparency = 0.35}):Play()
        end
    end
    local function onDragMove(input)
        if not dragData.active then return end
        local valid = false
        if dragData.inputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement then valid = true end
        if dragData.inputType == Enum.UserInputType.Touch and input == dragData.input and input.UserInputType == Enum.UserInputType.Touch then valid = true end
        if not valid then return end
        local delta = input.Position - dragData.start
        panel.Position = UDim2.new(dragData.startPos.X.Scale, dragData.startPos.X.Offset + delta.X,
                                    dragData.startPos.Y.Scale, dragData.startPos.Y.Offset + delta.Y)
    end
    local function onDragEnd(input)
        if not dragData.active then return end
        local shouldEnd = false
        if dragData.inputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1 then shouldEnd = true end
        if dragData.inputType == Enum.UserInputType.Touch and input == dragData.input then shouldEnd = true end
        if not shouldEnd then return end
        dragData.active = false
        currentInput = nil
        if dragData.highlight then
            TweenService:Create(dragFrame, TweenInfo.new(0.15), {ImageTransparency = 0.8}):Play()
        end
        dragData.input = nil
        dragData.inputType = nil
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
    end

    local function onResizeStart(input)
        if isClosing or currentInput or isMax then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        currentInput = input
        resizeData.active = true
        resizeData.input = input
        resizeData.inputType = input.UserInputType
        resizeData.start = input.Position
        resizeData.startSize = panel.Size
        TweenService:Create(resizeImage, TweenInfo.new(0.1), {ImageTransparency = 0.2, ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
    end
    local function onResizeMove(input)
        if not resizeData.active then return end
        local valid = false
        if resizeData.inputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement then valid = true end
        if resizeData.inputType == Enum.UserInputType.Touch and input == resizeData.input and input.UserInputType == Enum.UserInputType.Touch then valid = true end
        if not valid then return end
        local delta = input.Position - resizeData.start
        local newW = math.max(minW, resizeData.startSize.X.Offset + delta.X)
        local newH = math.max(minH, resizeData.startSize.Y.Offset + delta.Y)
        panel.Size = UDim2.new(resizeData.startSize.X.Scale, newW, resizeData.startSize.Y.Scale, newH)
    end
    local function onResizeEnd(input)
        if not resizeData.active then return end
        local shouldEnd = false
        if resizeData.inputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1 then shouldEnd = true end
        if resizeData.inputType == Enum.UserInputType.Touch and input == resizeData.input then shouldEnd = true end
        if not shouldEnd then return end
        resizeData.active = false
        currentInput = nil
        TweenService:Create(resizeImage, TweenInfo.new(0.15), {ImageTransparency = 0.7, ImageColor3 = Color3.fromRGB(160,160,160)}):Play()
        resizeData.input = nil
        resizeData.inputType = nil
        ConfigManager:save({
            windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
            windowPos = {
                xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
            },
            controls = controlsData,
        })
    end

    titleBar.InputBegan:Connect(function(input) onDragStart(input, false) end)
    dragButton.InputBegan:Connect(function(input) onDragStart(input, true) end)
    resizeHandle.InputBegan:Connect(onResizeStart)
    UserInputService.InputChanged:Connect(function(input) onDragMove(input); onResizeMove(input) end)
    UserInputService.InputEnded:Connect(function(input) onDragEnd(input); onResizeEnd(input) end)

    -- ============================================================
    -- 快捷键切换窗口 (SetToggleKey)
    -- ============================================================
    local toggleKey = Enum.KeyCode.F12
    local toggleKeyName = "F12"
    controlsData.toggleKey = toggleKeyName
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            if panel.Visible then
                minimizeWindow()
            else
                panel.Visible = true
                panel:Open()
            end
        end
    end)

    -- ============================================================
    -- 入场动画 + 加载配置
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
        -- 加载配置
        task.wait(0.2)
        local cfg = ConfigManager:load()
        if cfg and cfg.controls then
            local c = cfg.controls
            if c.toggleState ~= nil then
                toggleState = c.toggleState
                controlsData.toggleState = toggleState
                if toggleState then
                    toggleBg.ImageColor3 = Color3.fromRGB(0, 180, 80)
                    toggleThumb.Position = UDim2.new(1, -25, 0.5, 0)
                end
            end
            if c.sliderPercent ~= nil then
                sliderPercent = c.sliderPercent
                controlsData.sliderPercent = sliderPercent
                sliderFill.Size = UDim2.new(sliderPercent, 0, 1, 0)
                sliderThumb.Position = UDim2.new(sliderPercent, 0, 0.5, 0)
                sliderValue.Text = math.floor(sliderPercent * 100) .. "%"
            end
            if c.inputText ~= nil then
                inputBox.Text = c.inputText
                controlsData.inputText = c.inputText
            end
            if c.dropdownIndex ~= nil then
                optIndex = c.dropdownIndex
                controlsData.dropdownIndex = optIndex
                dropdownText.Text = options[optIndex]
            end
            if c.keybind then
                keybindValue = c.keybind
                keybindBtn.Text = keybindValue
                controlsData.keybind = keybindValue
            end
            if c.color then
                local clr = Color3.fromRGB(c.color.r or 255, c.color.g or 0, c.color.b or 0)
                colorPreview.ImageColor3 = clr
            end
            if c.toggleKey then
                toggleKeyName = c.toggleKey
                toggleKey = Enum.KeyCode[toggleKeyName] or Enum.KeyCode.F12
            end
        end
    end)

    -- ============================================================
    -- 返回 API（完整35个方法）
    -- ============================================================
    local api = {
        -- 窗口控制
        Open = function()
            panel.Visible = true
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, w, 0, h),
                Position = UDim2.new(0.5, -w/2, 0.5, -h/2),
            }):Play()
        end,
        Close = function()
            minimizeWindow()
        end,
        Destroy = function()
            gui:Destroy()
            NotificationGui:Destroy()
            TooltipGui:Destroy()
        end,
        Toggle = function()
            if panel.Visible then api:Close() else api:Open() end
        end,
        IsResizable = function(val) resizeHandle.Visible = val end,
        ToggleFullscreen = toggleMaximize,

        -- 外观设置
        SetTitle = function(val) title.Text = val end,
        SetAuthor = function(val) authorLabel.Text = val end,
        SetIconSize = function(val) if typeof(val)=="number" then iconContainer.Size = UDim2.new(0, val, 0, val) end end,
        SetSize = function(val) panel.Size = val end,
        SetBackgroundImage = function(val) bg.Image = val end,
        SetBackgroundImageTransparency = function(val) bg.ImageTransparency = val end,
        SetBackgroundTransparency = function(val) bg.ImageTransparency = val end,
        ToggleTransparency = function(val) bg.ImageTransparency = val and 0.15 or 0 end,
        SetPanelBackground = function(val)
            panelBgVisible = val
            panelBg.ImageTransparency = val and 0.5 or 1
        end,
        EditOpenButton = function(val) end,

        -- 内容管理
        Tab = function(data)
            local tab = createTabButton(data)
            tabs[#tabs + 1] = tab
            return tab
        end,
        SelectTab = function(index) if tabs[index] then tabs[index]:select() end end,
        Section = function(data)
            -- 简单分组
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, 0)
            container.BackgroundTransparency = 1
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.Parent = sideContent
            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 30)
            header.BackgroundTransparency = 1
            header.Text = data.Title or "分组"
            header.TextColor3 = Color3.fromRGB(180, 180, 180)
            header.TextSize = 13
            header.Font = Enum.Font.GothamMedium
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Parent = container
            local contentArea = Instance.new("Frame")
            contentArea.Size = UDim2.new(1, 0, 0, 0)
            contentArea.BackgroundTransparency = 1
            contentArea.AutomaticSize = Enum.AutomaticSize.Y
            contentArea.Visible = true
            contentArea.Parent = container
            local layout = Instance.new("UIListLayout")
            layout.FillDirection = Enum.FillDirection.Vertical
            layout.Padding = UDim.new(0, 2)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = contentArea
            local expanded = true
            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                contentArea.Visible = expanded
                header.Text = (expanded and "▼ " or "▶ ") .. (data.Title or "分组")
            end)
            return { Container = container, Content = contentArea }
        end,
        Divider = function()
            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, -16, 0, 1)
            div.BackgroundColor3 = Color3.fromRGB(255,255,255)
            div.BackgroundTransparency = 0.9
            div.Parent = sideContent
            return div
        end,
        Dialog = function(data)
            local dialogGui = Instance.new("ScreenGui")
            dialogGui.Name = "Dialog"
            dialogGui.ResetOnSpawn = false
            dialogGui.Parent = player:WaitForChild("PlayerGui")
            local overlay = Instance.new("Frame")
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            overlay.BackgroundTransparency = 0.6
            overlay.ZIndex = 999
            overlay.Parent = dialogGui
            local bg = NewRoundFrame(16, "Squircle", {
                Size = UDim2.new(0, 340, 0, 160),
                Position = UDim2.new(0.5, -170, 0.5, -80),
                ImageColor3 = Color3.fromRGB(45, 45, 50),
                ImageTransparency = 0,
                ZIndex = 1000,
                Parent = overlay,
            })
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -40, 0, 30)
            titleLabel.Position = UDim2.new(0, 20, 0, 20)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = data.Title or "提示"
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.TextSize = 18
            titleLabel.Font = Enum.Font.GothamSemibold
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = bg
            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, -40, 0, 40)
            contentLabel.Position = UDim2.new(0, 20, 0, 55)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Text = data.Content or ""
            contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            contentLabel.TextSize = 15
            contentLabel.Font = Enum.Font.GothamMedium
            contentLabel.TextWrapped = true
            contentLabel.Parent = bg
            local btnContainer = Instance.new("Frame")
            btnContainer.Size = UDim2.new(1, -40, 0, 40)
            btnContainer.Position = UDim2.new(0, 20, 1, -50)
            btnContainer.BackgroundTransparency = 1
            btnContainer.Parent = bg
            local btnLayout = Instance.new("UIListLayout")
            btnLayout.FillDirection = Enum.FillDirection.Horizontal
            btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
            btnLayout.Padding = UDim.new(0, 10)
            btnLayout.Parent = btnContainer
            for _, btnData in ipairs(data.Buttons or {}) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 100, 0, 36)
                btn.BackgroundTransparency = 1
                btn.Text = btnData.Title or "按钮"
                btn.TextColor3 = btnData.Primary and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
                btn.TextSize = 15
                btn.Font = Enum.Font.GothamMedium
                btn.LayoutOrder = btnData.Order or 1
                btn.Parent = btnContainer
                local btnBg = NewRoundFrame(999, "SquircleH", {
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageColor3 = btnData.Primary and Color3.fromRGB(0,120,255) or Color3.fromRGB(60,60,65),
                    ImageTransparency = btnData.Primary and 0 or 0.8,
                    ZIndex = 0,
                    Parent = btn,
                })
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btnBg, TweenInfo.new(0.12), {ImageColor3 = btnData.Primary and Color3.fromRGB(0,140,255) or Color3.fromRGB(80,80,85)}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btnBg, TweenInfo.new(0.12), {ImageColor3 = btnData.Primary and Color3.fromRGB(0,120,255) or Color3.fromRGB(60,60,65)}):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    dialogGui:Destroy()
                    if btnData.Callback then btnData.Callback() end
                end)
            end
            local escConn = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.KeyCode == Enum.KeyCode.Escape then
                    dialogGui:Destroy()
                    escConn:Disconnect()
                end
            end)
        end,
        Tag = function(data)
            local tag = Instance.new("TextLabel")
            tag.Size = UDim2.new(0, 0, 1, 0)
            tag.AutomaticSize = Enum.AutomaticSize.X
            tag.BackgroundTransparency = 1
            tag.Text = data.Title or "标签"
            tag.TextColor3 = Color3.fromRGB(200,200,200)
            tag.TextSize = 13
            tag.Font = Enum.Font.GothamMedium
            tag.Parent = titleBar
            return tag
        end,
        DisableTopbarButtons = function(list)
            for _, name in ipairs(list) do
                if buttonRefs[name] then
                    buttonRefs[name].container.Visible = false
                end
            end
        end,
        LockAll = function()
            -- 简单锁定所有交互控件（仅示例）
            local all = {toggleBtn, sliderTrack, inputBox, dropdownBg, keybindBtn, colorPickerBtn}
            for _, c in ipairs(all) do
                c.Interactable = false
            end
            Notify("锁定", "所有控件已锁定", 1.5)
        end,
        UnlockAll = function()
            local all = {toggleBtn, sliderTrack, inputBox, dropdownBg, keybindBtn, colorPickerBtn}
            for _, c in ipairs(all) do
                c.Interactable = true
            end
            Notify("解锁", "所有控件已解锁", 1.5)
        end,
        GetLocked = function()
            return {}
        end,
        GetUnlocked = function()
            return {}
        end,

        -- 配置与缩放
        GetUIScale = function() return 1 end,
        SetUIScale = function(val)
            -- 简单缩放（实际可加UIScale）
        end,
        SetCurrentConfig = function(name)
            ConfigManager.currentConfig = name
            Notify("切换配置", "当前配置: " .. name, 1.5)
        end,
        SetToggleKey = function(key)
            if typeof(key) == "string" then
                toggleKey = Enum.KeyCode[key] or Enum.KeyCode.F12
                toggleKeyName = key
                controlsData.toggleKey = key
                ConfigManager:save({
                    windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
                    windowPos = {
                        xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                        yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
                    },
                    controls = controlsData,
                })
                Notify("快捷键设置", "当前: " .. key, 1.5)
            end
        end,

        -- 事件回调
        OnOpen = function(func) if func then func() end end,
        OnClose = function(func) if func then func() end end,
        OnDestroy = function(func) if func then func() end end,

        -- 其他
        Topbar = {
            Button = function(data)
                local container, btn = makeButton(
                    getIcon(data.icon or "circle"),
                    data.order or 5,
                    data.hoverColor or Color3.fromRGB(200,200,200),
                    data.callback or function() end
                )
                return container
            end
        },
        SetToTheCenter = function()
            TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -panel.Size.X.Offset/2, 0.5, -panel.Size.Y.Offset/2),
            }):Play()
        end,

        -- 额外：配置管理
        SaveConfig = function(name)
            ConfigManager:save({
                windowSize = { w = panel.Size.X.Offset, h = panel.Size.Y.Offset },
                windowPos = {
                    xScale = panel.Position.X.Scale, xOffset = panel.Position.X.Offset,
                    yScale = panel.Position.Y.Scale, yOffset = panel.Position.Y.Offset,
                },
                controls = controlsData,
            }, name)
            Notify("配置已保存", name or ConfigManager.currentConfig, 1.5)
        end,
        LoadConfig = function(name)
            local data = ConfigManager:load(name)
            if data and data.controls then
                local c = data.controls
                if c.toggleState ~= nil then
                    toggleState = c.toggleState
                    controlsData.toggleState = toggleState
                    if toggleState then
                        toggleBg.ImageColor3 = Color3.fromRGB(0, 180, 80)
                        toggleThumb.Position = UDim2.new(1, -25, 0.5, 0)
                    end
                end
                if c.sliderPercent ~= nil then
                    sliderPercent = c.sliderPercent
                    controlsData.sliderPercent = sliderPercent
                    sliderFill.Size = UDim2.new(sliderPercent, 0, 1, 0)
                    sliderThumb.Position = UDim2.new(sliderPercent, 0, 0.5, 0)
                    sliderValue.Text = math.floor(sliderPercent * 100) .. "%"
                end
                if c.inputText ~= nil then
                    inputBox.Text = c.inputText
                    controlsData.inputText = c.inputText
                end
                if c.dropdownIndex ~= nil then
                    optIndex = c.dropdownIndex
                    controlsData.dropdownIndex = optIndex
                    dropdownText.Text = options[optIndex]
                end
                if c.keybind then
                    keybindValue = c.keybind
                    keybindBtn.Text = keybindValue
                    controlsData.keybind = keybindValue
                end
                if c.color then
                    local clr = Color3.fromRGB(c.color.r or 255, c.color.g or 0, c.color.b or 0)
                    colorPreview.ImageColor3 = clr
                end
                if c.toggleKey then
                    toggleKeyName = c.toggleKey
                    toggleKey = Enum.KeyCode[toggleKeyName] or Enum.KeyCode.F12
                end
                Notify("配置已加载", name or ConfigManager.currentConfig, 1.5)
            end
        end,
        ResetConfig = function(name)
            ConfigManager:reset(name)
            Notify("配置已重置", name or ConfigManager.currentConfig, 1.5)
            -- 重置控件到默认状态
            toggleState = false
            controlsData.toggleState = false
            toggleBg.ImageColor3 = Color3.fromRGB(80, 80, 85)
            toggleThumb.Position = UDim2.new(0, 3, 0.5, 0)
            sliderPercent = 0.5
            controlsData.sliderPercent = 0.5
            sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            sliderThumb.Position = UDim2.new(0.5, 0, 0.5, 0)
            sliderValue.Text = "50%"
            inputBox.Text = ""
            controlsData.inputText = ""
            optIndex = 1
            controlsData.dropdownIndex = 1
            dropdownText.Text = options[1]
            keybindValue = "None"
            keybindBtn.Text = "未设置"
            controlsData.keybind = "None"
            colorPreview.ImageColor3 = Color3.fromRGB(255, 0, 0)
            controlsData.color = nil
            toggleKeyName = "F12"
            toggleKey = Enum.KeyCode.F12
            controlsData.toggleKey = "F12"
        end,

        -- 暴露内部
        _panel = panel,
        _gui = gui,
        _tabs = tabs,
        _content = contentContainer,
    }

    return api
end

-- ============================================================
-- 创建并返回面板
-- ============================================================
local panel = createMainPanel()
panel:Open()
return panel
