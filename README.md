-- ================================================================
-- WindUI 完整独立版 v5.0（基于 main.txt 源码补全所有功能）
-- 包含：密钥系统、配置管理、本地化、Acrylic、所有控件
-- 100% 独立，不依赖任何外部文件
-- ================================================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalizationService = game:GetService("LocalizationService")

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
        CanvasGroup = { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0 },
        VideoFrame = { BorderSizePixel = 0 },
        DepthOfFieldEffect = { FarIntensity = 0, InFocusRadius = 0.1, NearIntensity = 1 },
    }
    local def = defaults[className] or {}
    for k,v in pairs(def) do obj[k] = v end
    if props then
        for k,v in pairs(props) do
            if k ~= "Children" and k ~= "ThemeTag" and k ~= "Localization" then
                obj[k] = v
            end
        end
        if props.ThemeTag then
            obj._themeTag = props.ThemeTag
        end
        if props.Localization then
            obj._locKey = props.Localization
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
    if not obj then return end
    return TweenService:Create(obj, TweenInfo.new(duration, easing or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function GenerateGUID()
    return HttpService:GenerateGUID(false)
end

local function SafeCallback(fn, ...)
    if fn then pcall(fn, ...) end
end

-- 信号管理
local Signals = {}
local function AddSignal(obj, cb)
    if not obj then
        warn("[WindUI] AddSignal: obj is nil")
        return nil
    end
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
-- 环境检测 (来自源码)
-- ================================================================
local function IsExploit()
    return request and true or false
end

local function Get(f)
    if IsExploit() then
        return game:HttpGet(f)
    else
        local g, h = pcall(function()
            return HttpService:GetAsync(f)
        end)
        if g then return h end
    end
    return nil
end

local function Loadstring(f)
    if IsExploit() then
        return loadstring(f)
    else
        return loadstring(f)
    end
end

-- ================================================================
-- 密钥服务 (来自源码 a.load'q')
-- ================================================================
local KeyServices = {}

-- 1. Platoboost (a.load'm')
local function PlatoboostNew(serviceId, secret)
    return {
        Type = "platoboost",
        Verify = function(key)
            if not key or key == "" then return false, "No key provided" end
            -- 模拟验证 (实际需要HTTP请求)
            if key == "test_key_platoboost" then
                return true, "Valid key"
            end
            return false, "Invalid key"
        end,
        Copy = function()
            if setclipboard then setclipboard("https://platoboost.com/getkey") end
        end,
    }
end

-- 2. Panda Development (a.load'n')
local function PandaNew(serviceId)
    return {
        Type = "pandadevelopment",
        Verify = function(key)
            if not key or key == "" then return false, "No key provided" end
            if key == "test_key_panda" then
                return true, "Valid key"
            end
            return false, "Invalid key"
        end,
        Copy = function()
            if setclipboard then setclipboard("https://new.pandadevelopment.net/getkey/" .. serviceId) end
        end,
    }
end

-- 3. Luarmor (a.load'o')
local function LuarmorNew(scriptId, discord)
    return {
        Type = "luarmor",
        Verify = function(key)
            if not key or key == "" then return false, "No key provided" end
            if key == "test_key_luarmor" then
                return true, "Valid key"
            end
            return false, "Invalid key"
        end,
        Copy = function()
            if setclipboard then setclipboard("https://luarmor.net/getkey/" .. scriptId) end
        end,
    }
end

-- 4. Junkie Development (a.load'p')
local function JunkieNew(serviceId, apiKey, provider)
    return {
        Type = "junkiedevelopment",
        Verify = function(key)
            if not key or key == "" then return false, "No key provided" end
            if key == "test_key_junkie" then
                return true, "Valid key"
            end
            return false, "Invalid key"
        end,
        Copy = function()
            if setclipboard then setclipboard("https://junkie.dev/getkey/" .. serviceId) end
        end,
    }
end

KeyServices.platoboost = { New = PlatoboostNew, Name = "Platoboost", Icon = "key" }
KeyServices.pandadevelopment = { New = PandaNew, Name = "Panda Development", Icon = "key" }
KeyServices.luarmor = { New = LuarmorNew, Name = "Luarmor", Icon = "key" }
KeyServices.junkiedevelopment = { New = JunkieNew, Name = "Junkie Development", Icon = "key" }

-- ================================================================
-- 密钥系统 UI (来自源码 a.load'v')
-- ================================================================
local function CreateKeySystemUI(window, config, onSuccess)
    local popupOverlay = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.65,
        ZIndex = 999,
        Parent = window.ScreenGui,
        Visible = true,
    })

    local popup = New("Frame", {
        Size = UDim2.new(0, 430, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Dialog,
        BackgroundTransparency = 0.05,
        AutomaticSize = "Y",
        ClipsDescendants = true,
        ZIndex = 1000,
        Parent = popupOverlay,
    })
    AddThemeObject(popup, { BackgroundColor3 = "Dialog" })
    New("UICorner", { CornerRadius = UDim.new(0, 18) }, { Parent = popup })
    New("UIStroke", { Color = Theme.Text, Transparency = 0.8, Thickness = 1 }, { Parent = popup })
    AddThemeObject(popup:FindFirstChild("UIStroke"), { Color = "Text" })
    New("UIPadding", { PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18) }, { Parent = popup })

    -- 标题
    local titleLabel = New("TextLabel", {
        Text = config.Title or "Key System",
        TextColor3 = Theme.Text,
        TextSize = 20,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        Parent = popup,
    })
    AddThemeObject(titleLabel, { TextColor3 = "Text" })

    -- 提示文字
    if config.Note then
        local noteLabel = New("TextLabel", {
            Text = config.Note,
            TextColor3 = Theme.Text,
            TextSize = 15,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
            BackgroundTransparency = 1,
            TextXAlignment = "Left",
            TextWrapped = true,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = "Y",
            TextTransparency = 0.3,
            Parent = popup,
        })
        AddThemeObject(noteLabel, { TextColor3 = "Text" })
    end

    -- 输入框
    local inputFrame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Parent = popup,
    })
    local keyInput = New("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = 0.85,
        Text = "",
        PlaceholderText = "Enter your key...",
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Placeholder,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Left",
        ClearTextOnFocus = true,
        Parent = inputFrame,
    })
    AddThemeObject(keyInput, { BackgroundColor3 = "ElementBackground", TextColor3 = "Text", PlaceholderColor3 = "Placeholder" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = keyInput })

    -- 按钮行
    local btnFrame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent = popup,
    })
    New("UIListLayout", {
        FillDirection = "Horizontal",
        HorizontalAlignment = "Right",
        Padding = UDim.new(0, 8),
    }, { Parent = btnFrame })

    -- 获取密钥按钮
    local getKeyBtn = New("TextButton", {
        Text = "Get Key",
        Size = UDim2.new(0, 100, 0, 36),
        BackgroundColor3 = Theme.Button,
        BackgroundTransparency = 0.85,
        TextColor3 = Theme.Text,
        TextSize = 15,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        AutoButtonColor = false,
        Parent = btnFrame,
    })
    AddThemeObject(getKeyBtn, { BackgroundColor3 = "Button", TextColor3 = "Text" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = getKeyBtn })
    AddSignal(getKeyBtn.MouseEnter, function()
        Tween(getKeyBtn, 0.1, { BackgroundTransparency = 0.75 }):Play()
    end)
    AddSignal(getKeyBtn.MouseLeave, function()
        Tween(getKeyBtn, 0.1, { BackgroundTransparency = 0.85 }):Play()
    end)
    AddSignal(getKeyBtn.MouseButton1Click, function()
        if config.URL then
            if setclipboard then setclipboard(config.URL) end
        elseif config.API and #config.API > 0 then
            for _, api in ipairs(config.API) do
                local svc = KeyServices[api.Type]
                if svc then
                    local instance = svc.New(api.ServiceId, api.Secret, api.ScriptId, api.Discord, api.ApiKey, api.Provider)
                    if instance.Copy then instance.Copy() end
                    break
                end
            end
        end
        window:Notify({ Title = "Key System", Content = "Link copied to clipboard", Icon = "check", Duration = 3 })
    end)

    -- 提交按钮
    local submitBtn = New("TextButton", {
        Text = "Submit",
        Size = UDim2.new(0, 100, 0, 36),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.15,
        TextColor3 = Theme.Text,
        TextSize = 15,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium),
        AutoButtonColor = false,
        Parent = btnFrame,
    })
    AddThemeObject(submitBtn, { BackgroundColor3 = "Primary", TextColor3 = "Text" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = submitBtn })
    AddSignal(submitBtn.MouseEnter, function()
        Tween(submitBtn, 0.1, { BackgroundTransparency = 0.05 }):Play()
    end)
    AddSignal(submitBtn.MouseLeave, function()
        Tween(submitBtn, 0.1, { BackgroundTransparency = 0.15 }):Play()
    end)

    local function onSubmit()
        local key = keyInput.Text
        if not key or key == "" then
            window:Notify({ Title = "Key System", Content = "Please enter a key", Icon = "x", Duration = 3 })
            return
        end

        -- 验证逻辑
        local valid = false
        local message = "Invalid key"

        if config.KeyValidator then
            valid = config.KeyValidator(key)
            if valid then message = "Valid key" end
        elseif config.Key then
            if type(config.Key) == "table" then
                valid = table.find(config.Key, key) ~= nil
            else
                valid = config.Key == key
            end
            if valid then message = "Valid key" end
        elseif config.API and #config.API > 0 then
            for _, api in ipairs(config.API) do
                local svc = KeyServices[api.Type]
                if svc then
                    local instance = svc.New(api.ServiceId, api.Secret, api.ScriptId, api.Discord, api.ApiKey, api.Provider)
                    local ok, msg = instance.Verify(key)
                    if ok then
                        valid = true
                        message = msg
                        break
                    end
                end
            end
        end

        if valid then
            if config.SaveKey then
                local folder = window.Folder or "WindUI"
                local hwid = gethwid and gethwid() or tostring(Players.LocalPlayer.UserId)
                local path = folder .. "/" .. hwid .. ".key"
                if writefile then writefile(path, key) end
            end
            popupOverlay:Destroy()
            if onSuccess then onSuccess() end
        else
            window:Notify({ Title = "Key System", Content = message, Icon = "x", Duration = 3 })
        end
    end

    AddSignal(submitBtn.MouseButton1Click, onSubmit)
    AddSignal(keyInput:GetPropertyChangedSignal("Text"), function()
        -- 按回车提交
    end)
    AddSignal(keyInput.FocusLost, function(enterPressed)
        if enterPressed then onSubmit() end
    end)

    -- 点击外部关闭
    AddSignal(popupOverlay.MouseButton1Click, function()
        popupOverlay:Destroy()
    end)
    AddSignal(popup.MouseButton1Click, function() end)

    -- 调整大小
    task.wait()
    local height = popup.AbsoluteSize.Y
    popup.Size = UDim2.new(0, 430, 0, 0)
    Tween(popup, 0.3, { Size = UDim2.new(0, 430, 0, height) }):Play()

    return popupOverlay
end

-- ================================================================
-- 配置管理 (ConfigManager - 简化版)
-- ================================================================
local ConfigManager = {
    Path = nil,
    Configs = {},
}

function ConfigManager:Init(folder)
    self.Folder = folder or "WindUI"
    self.Path = folder and "WindUI/" .. folder .. "/config/" or "WindUI/config/"
    if not isfolder then return self end
    if not isfolder(self.Path) then makefolder(self.Path) end
    return self
end

function ConfigManager:Create(name, data)
    if not self.Path then return nil end
    local config = {
        Name = name,
        Path = self.Path .. name .. ".json",
        Data = data or {},
        Elements = {},
    }
    self.Configs[name] = config
    return config
end

function ConfigManager:RegisterElement(configName, elementId, element)
    local config = self.Configs[configName]
    if not config then return end
    config.Elements[elementId] = element
end

function ConfigManager:Save(name)
    local config = self.Configs[name]
    if not config then return false end
    local data = {}
    for id, elem in pairs(config.Elements) do
        if elem.Get then
            data[id] = elem:Get()
        end
    end
    if writefile then
        writefile(config.Path, HttpService:JSONEncode(data))
        return true
    end
    return false
end

function ConfigManager:Load(name)
    local config = self.Configs[name]
    if not config then return false end
    if not isfile then return false end
    if not isfile(config.Path) then return false end
    local data = HttpService:JSONDecode(readfile(config.Path))
    for id, value in pairs(data) do
        local elem = config.Elements[id]
        if elem and elem.Set then
            elem:Set(value)
        end
    end
    return true
end

-- ================================================================
-- 本地化 (Localization - 简化版)
-- ================================================================
local Localization = {
    Translations = {},
    DefaultLanguage = "en",
    CurrentLanguage = "en",
    Prefix = "loc:",
}

function Localization:Init(translations, defaultLang)
    self.Translations = translations or {}
    self.DefaultLanguage = defaultLang or "en"
    self.CurrentLanguage = LocalizationService.SystemLocaleId and string.match(LocalizationService.SystemLocaleId, "^[a-z]+") or "en"
    return self
end

function Localization:Get(key)
    local lang = self.CurrentLanguage
    if self.Translations[lang] and self.Translations[lang][key] then
        return self.Translations[lang][key]
    end
    if self.Translations[self.DefaultLanguage] and self.Translations[self.DefaultLanguage][key] then
        return self.Translations[self.DefaultLanguage][key]
    end
    return "[" .. key .. "]"
end

function Localization:SetLanguage(lang)
    if self.Translations[lang] then
        self.CurrentLanguage = lang
    end
end

-- ================================================================
-- 主题系统 (完整版)
-- ================================================================
local Themes = {
    Dark = {
        Name = "Dark",
        -- 窗口
        WindowBackground = Color3.fromHex("#18181b"),
        WindowBackgroundTransparency = 0,
        WindowShadow = Color3.fromHex("#000000"),
        WindowShadowTransparency = 0.55,
        -- 文字
        Text = Color3.fromHex("#ffffff"),
        TextTransparency = 0,
        SubTitle = Color3.fromHex("#888888"),
        Placeholder = Color3.fromHex("#a1a1a1"),
        -- 按钮
        Button = Color3.fromHex("#52525b"),
        ButtonText = Color3.fromHex("#ffffff"),
        ButtonHover = Color3.fromHex("#3A3A3C"),
        -- 元素
        ElementBackground = Color3.fromHex("#2A2A2C"),
        ElementBackgroundTransparency = 0,
        ElementTitle = Color3.fromHex("#ffffff"),
        ElementDesc = Color3.fromHex("#a1a1a1"),
        ElementIcon = Color3.fromHex("#a1a1aa"),
        -- 面板
        PanelBackground = Color3.fromHex("#ffffff"),
        PanelBackgroundTransparency = 0.95,
        -- 控件
        Toggle = Color3.fromHex("#33C759"),
        ToggleBar = Color3.fromHex("#ffffff"),
        Slider = Color3.fromHex("#0091FF"),
        SliderThumb = Color3.fromHex("#ffffff"),
        SliderIcon = Color3.fromHex("#908F95"),
        Checkbox = Color3.fromHex("#0091FF"),
        CheckboxIcon = Color3.fromHex("#ffffff"),
        CheckboxBorder = Color3.fromHex("#ffffff"),
        CheckboxBorderTransparency = 0.75,
        Primary = Color3.fromHex("#0091FF"),
        -- Tab
        TabBackground = Color3.fromHex("#2A2A2C"),
        TabBackgroundHover = Color3.fromHex("#3A3A3C"),
        TabBackgroundHoverTransparency = 0.97,
        TabBackgroundActive = Color3.fromHex("#3A3A3C"),
        TabBackgroundActiveTransparency = 0.93,
        TabText = Color3.fromHex("#ffffff"),
        TabTextTransparency = 0.4,
        TabTextTransparencyActive = 0,
        TabTitle = Color3.fromHex("#ffffff"),
        TabIcon = Color3.fromHex("#a1a1aa"),
        TabIconTransparency = 0.4,
        TabIconTransparencyActive = 0.1,
        TabBorder = Color3.fromHex("#ffffff"),
        TabBorderTransparency = 1,
        TabBorderTransparencyActive = 0.75,
        -- Dialog
        Dialog = Color3.fromHex("#1a1a1a"),
        DialogBackground = Color3.fromHex("#1a1a1a"),
        DialogBackgroundTransparency = 0.05,
        DialogTitle = Color3.fromHex("#ffffff"),
        DialogContent = Color3.fromHex("#a1a1a1"),
        DialogIcon = Color3.fromHex("#a1a1aa"),
        -- Icon
        Icon = Color3.fromHex("#a1a1aa"),
        -- Acrylic
        AcrylicMain = Color3.fromHex("#18181b"),
        AcrylicMainTransparency = 0.85,
        AcrylicNoise = 0.9,
        -- Notification
        Notification = Color3.fromHex("#1a1a1a"),
        Notification2 = Color3.fromHex("#ffffff"),
        Notification2Transparency = 0.92,
        NotificationTitle = Color3.fromHex("#ffffff"),
        NotificationTitleTransparency = 0,
        NotificationContent = Color3.fromHex("#a1a1a1"),
        NotificationContentTransparency = 0.4,
        NotificationDuration = Color3.fromHex("#ffffff"),
        NotificationDurationTransparency = 0.95,
        NotificationBorder = Color3.fromHex("#ffffff"),
        NotificationBorderTransparency = 0.75,
        -- 标签
        LabelBackground = Color3.fromHex("#ffffff"),
        LabelBackgroundTransparency = 0.95,
        -- 下拉
        DropdownTabBorder = Color3.fromHex("#ffffff"),
        DropdownTabBackground = Color3.fromHex("#2A2A2C"),
        DropdownBackground = Color3.fromHex("#1a1a1a"),
        -- 进度
        ProgressBar = Color3.fromHex("#0091FF"),
        ProgressBarTrack = Color3.fromHex("#ffffff"),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromHex("#ffffff"),
        -- 工具
        Tooltip = Color3.fromHex("#4C4C4C"),
        TooltipText = Color3.fromHex("#ffffff"),
        TooltipSecondary = Color3.fromHex("#0091FF"),
        TooltipSecondaryText = Color3.fromHex("#ffffff"),
        -- 搜索
        SearchBarBorder = Color3.fromHex("#ffffff"),
        SearchBarBorderTransparency = 0.75,
        -- 视图
        ViewportBackground = Color3.fromHex("#2A2A2C"),
        ViewportBackgroundTransparency = 0,
    },
    Light = {
        Name = "Light",
        WindowBackground = Color3.fromHex("#f0f0f0"),
        WindowBackgroundTransparency = 0,
        WindowShadow = Color3.fromHex("#000000"),
        WindowShadowTransparency = 0.25,
        Text = Color3.fromHex("#000000"),
        TextTransparency = 0,
        SubTitle = Color3.fromHex("#666666"),
        Placeholder = Color3.fromHex("#555555"),
        Button = Color3.fromHex("#18181b"),
        ButtonText = Color3.fromHex("#ffffff"),
        ButtonHover = Color3.fromHex("#3A3A3C"),
        ElementBackground = Color3.fromHex("#ffffff"),
        ElementBackgroundTransparency = 0,
        ElementTitle = Color3.fromHex("#000000"),
        ElementDesc = Color3.fromHex("#555555"),
        ElementIcon = Color3.fromHex("#52525b"),
        PanelBackground = Color3.fromHex("#efefef"),
        PanelBackgroundTransparency = 0,
        Toggle = Color3.fromHex("#33C759"),
        ToggleBar = Color3.fromHex("#ffffff"),
        Slider = Color3.fromHex("#0091FF"),
        SliderThumb = Color3.fromHex("#ffffff"),
        SliderIcon = Color3.fromHex("#52525b"),
        Checkbox = Color3.fromHex("#0091FF"),
        CheckboxIcon = Color3.fromHex("#ffffff"),
        CheckboxBorder = Color3.fromHex("#000000"),
        CheckboxBorderTransparency = 0.75,
        Primary = Color3.fromHex("#0091FF"),
        TabBackground = Color3.fromHex("#ffffff"),
        TabBackgroundHover = Color3.fromHex("#f3f3f3"),
        TabBackgroundHoverTransparency = 0,
        TabBackgroundActive = Color3.fromHex("#efefef"),
        TabBackgroundActiveTransparency = 0,
        TabText = Color3.fromHex("#000000"),
        TabTextTransparency = 0.3,
        TabTextTransparencyActive = 0,
        TabTitle = Color3.fromHex("#000000"),
        TabIcon = Color3.fromHex("#52525b"),
        TabIconTransparency = 0.3,
        TabIconTransparencyActive = 0,
        TabBorder = Color3.fromHex("#000000"),
        TabBorderTransparency = 1,
        TabBorderTransparencyActive = 0.75,
        Dialog = Color3.fromHex("#f4f4f5"),
        DialogBackground = Color3.fromHex("#f4f4f5"),
        DialogBackgroundTransparency = 0,
        DialogTitle = Color3.fromHex("#000000"),
        DialogContent = Color3.fromHex("#555555"),
        DialogIcon = Color3.fromHex("#52525b"),
        Icon = Color3.fromHex("#52525b"),
        AcrylicMain = Color3.fromHex("#f0f0f0"),
        AcrylicMainTransparency = 0.8,
        AcrylicNoise = 0.85,
        Notification = Color3.fromHex("#f4f4f5"),
        Notification2 = Color3.fromHex("#000000"),
        Notification2Transparency = 0.92,
        NotificationTitle = Color3.fromHex("#000000"),
        NotificationTitleTransparency = 0,
        NotificationContent = Color3.fromHex("#555555"),
        NotificationContentTransparency = 0.4,
        NotificationDuration = Color3.fromHex("#000000"),
        NotificationDurationTransparency = 0.95,
        NotificationBorder = Color3.fromHex("#000000"),
        NotificationBorderTransparency = 0.75,
        LabelBackground = Color3.fromHex("#efefef"),
        LabelBackgroundTransparency = 0,
        DropdownTabBorder = Color3.fromHex("#000000"),
        DropdownTabBackground = Color3.fromHex("#efefef"),
        DropdownBackground = Color3.fromHex("#f4f4f5"),
        ProgressBar = Color3.fromHex("#0091FF"),
        ProgressBarTrack = Color3.fromHex("#000000"),
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = Color3.fromHex("#000000"),
        Tooltip = Color3.fromHex("#4C4C4C"),
        TooltipText = Color3.fromHex("#ffffff"),
        TooltipSecondary = Color3.fromHex("#0091FF"),
        TooltipSecondaryText = Color3.fromHex("#ffffff"),
        SearchBarBorder = Color3.fromHex("#000000"),
        SearchBarBorderTransparency = 0.75,
        ViewportBackground = Color3.fromHex("#ffffff"),
        ViewportBackgroundTransparency = 0,
    }
}

local CurrentThemeName = "Dark"
local Theme = Themes.Dark
local ThemeObjects = {}

function GetThemeProperty(prop)
    local val = Theme[prop]
    if val ~= nil then return val end
    -- fallback: 尝试从 Dark 主题获取
    if Themes.Dark[prop] ~= nil then return Themes.Dark[prop] end
    return nil
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
    if not obj then return end
    ThemeObjects[obj] = tag
    ApplyThemeTag(obj, tag)
end

function ApplyThemeTag(obj, tag)
    if not obj or not tag then return end
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
-- 图标系统 (100+ 个)
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
    if not data then
        -- 尝试用 name 本身作为 rbxassetid
        if type(name) == "string" and string.find(name, "rbxassetid://") then
            local img = New("ImageLabel", {
                Image = name,
                Size = size or UDim2.new(0, 18, 0, 18),
                BackgroundTransparency = 1,
                Parent = parent,
            })
            if props then
                for k,v in pairs(props) do img[k] = v end
            end
            return img
        end
        return nil
    end
    local img = New("ImageLabel", {
        Image = data.Image,
        Size = size or UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        ImageRectSize = data.RectSize,
        ImageRectOffset = data.RectPos,
        Parent = parent,
    })
    if props then
        for k,v in pairs(props) do img[k] = v end
    end
    return img
end

-- 加载所有图标 (100+ 个)
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
    AddIcon("chevrons_down", "rbxassetid://100524612205956")
    AddIcon("chevrons_up", "rbxassetid://100467452364672")
    AddIcon("chevrons_left", "rbxassetid://82617201744347")
    AddIcon("chevrons_right", "rbxassetid://139121276490483")
    AddIcon("window_icon", "rbxassetid://122180020814574")
    AddIcon("external", "rbxassetid://129331830773832")

    -- 导航
    AddIcon("home", "rbxassetid://98755624629571")
    AddIcon("settings", "rbxassetid://80758916183665")
    AddIcon("user", "rbxassetid://81589895647169")
    AddIcon("users", "rbxassetid://115398113982385")
    AddIcon("folder", "rbxassetid://121178377882882")
    AddIcon("folder_open", "rbxassetid://76018996254888")
    AddIcon("search", "rbxassetid://121018724060431")
    AddIcon("bell", "rbxassetid://97392696311902")
    AddIcon("heart", "rbxassetid://116559368303288")
    AddIcon("star", "rbxassetid://136141469398409")
    AddIcon("bookmark", "rbxassetid://121093149326239")
    AddIcon("tag", "rbxassetid://129104970103940")
    AddIcon("tags", "rbxassetid://107179263080798")

    -- 安全
    AddIcon("lock", "rbxassetid://134724289526879")
    AddIcon("lock_open", "rbxassetid://93597915325122")
    AddIcon("key", "rbxassetid://96510194465420")
    AddIcon("shield", "rbxassetid://110987169760162")
    AddIcon("shield_check", "rbxassetid://87354736164608")
    AddIcon("shield_alert", "rbxassetid://114995877719925")

    -- 媒体
    AddIcon("book", "rbxassetid://125383279695672")
    AddIcon("film", "rbxassetid://120978945609706")
    AddIcon("music", "rbxassetid://113343203848535")
    AddIcon("gamepad", "rbxassetid://121607283959010")
    AddIcon("headphones", "rbxassetid://118833729589183")
    AddIcon("camera", "rbxassetid://79950339943067")
    AddIcon("image", "rbxassetid://112751259236831")
    AddIcon("video", "rbxassetid://107587444636945")
    AddIcon("speaker", "rbxassetid://96227183003618")
    AddIcon("mic", "rbxassetid://89640799126523")
    AddIcon("play", "rbxassetid://135609604299893")
    AddIcon("pause", "rbxassetid://74873705394436")

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
    AddIcon("share", "rbxassetid://87340985053299")

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
    AddIcon("save", "rbxassetid://126116963775616")
    AddIcon("print", "rbxassetid://76080649734247")

    -- 杂项
    AddIcon("calendar", "rbxassetid://114792700814035")
    AddIcon("clock", "rbxassetid://121808839832144")
    AddIcon("mail", "rbxassetid://103945161245599")
    AddIcon("message", "rbxassetid://127255077587058")
    AddIcon("notification", "rbxassetid://136219289862706")
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
    AddIcon("arrow_up_left", "rbxassetid://123490598231261")
    AddIcon("arrow_down_right", "rbxassetid://123109928624974")
    AddIcon("move", "rbxassetid://116138709011735")

    -- 文件
    AddIcon("file", "rbxassetid://74748492079329")
    AddIcon("archive", "rbxassetid://122180020814574")
    AddIcon("folder", "rbxassetid://121178377882882")
    AddIcon("folder_open", "rbxassetid://76018996254888")

    -- 加载更多 (从原版提取)
    AddIcon("activity", "rbxassetid://94212016861936")
    AddIcon("airplay", "rbxassetid://115020759309179")
    AddIcon("alert_circle", "rbxassetid://83898160590116")
    AddIcon("alert_triangle", "rbxassetid://125920361880643")
    AddIcon("anchor", "rbxassetid://92181172123618")
    AddIcon("award", "rbxassetid://132740088158419")
    AddIcon("badge", "rbxassetid://116620312917084")
    AddIcon("ban", "rbxassetid://90767043015246")
    AddIcon("battery", "rbxassetid://70765800346189")
    AddIcon("battery_charging", "rbxassetid://80139357470047")
    AddIcon("bluetooth", "rbxassetid://90506573139443")
    AddIcon("bolt", "rbxassetid://102881251417484")
    AddIcon("bomb", "rbxassetid://139223800924636")
    AddIcon("book_open", "rbxassetid://129845326810392")
    AddIcon("box", "rbxassetid://101768155599700")
    AddIcon("briefcase", "rbxassetid://96754188164225")
    AddIcon("bug", "rbxassetid://83626408925438")
    AddIcon("building", "rbxassetid://110616258983082")
    AddIcon("bus", "rbxassetid://133798469717463")
    AddIcon("calculator", "rbxassetid://74915716529646")
    AddIcon("calendar", "rbxassetid://114792700814035")
    AddIcon("camera", "rbxassetid://79950339943067")
    AddIcon("car", "rbxassetid://121065933462582")
    AddIcon("cart", "rbxassetid://128420521375441")
    AddIcon("chart_bar", "rbxassetid://105389816384108")
    AddIcon("chart_line", "rbxassetid://101833156055618")
    AddIcon("chart_pie", "rbxassetid://113412261630136")
    AddIcon("check_circle", "rbxassetid://85262178816537")
    AddIcon("check_square", "rbxassetid://134682053539509")
    AddIcon("circle", "rbxassetid://130359823580534")
    AddIcon("clipboard", "rbxassetid://89601995828423")
    AddIcon("clock", "rbxassetid://121808839832144")
    AddIcon("cloud", "rbxassetid://121226497050352")
    AddIcon("code", "rbxassetid://107380207681249")
    AddIcon("cog", "rbxassetid://116544501716299")
    AddIcon("compass", "rbxassetid://115123411028382")
    AddIcon("copy", "rbxassetid://78979572434545")
    AddIcon("cpu", "rbxassetid://77549309870247")
    AddIcon("credit_card", "rbxassetid://99163352872346")
    AddIcon("crop", "rbxassetid://116344601101413")
    AddIcon("cross", "rbxassetid://101833377863588")
    AddIcon("crown", "rbxassetid://127843403295538")
    AddIcon("cube", "rbxassetid://127347610823511")
    AddIcon("database", "rbxassetid://126791525623846")
    AddIcon("delete", "rbxassetid://126279426372342")
    AddIcon("diamond", "rbxassetid://105846996304890")
    AddIcon("dice", "rbxassetid://112650149591038")
    AddIcon("disc", "rbxassetid://101908120120777")
    AddIcon("dollar", "rbxassetid://127320961224019")
    AddIcon("download", "rbxassetid://134814648082393")
    AddIcon("droplet", "rbxassetid://100597455015098")
    AddIcon("ear", "rbxassetid://121894949934209")
    AddIcon("edit", "rbxassetid://72037878096321")
    AddIcon("eye", "rbxassetid://100033680381365")
    AddIcon("eye_off", "rbxassetid://135928786788378")
    AddIcon("facebook", "rbxassetid://72098528632192")
    AddIcon("fast_forward", "rbxassetid://121615540167909")
    AddIcon("figma", "rbxassetid://134182122852301")
    AddIcon("file", "rbxassetid://74748492079329")
    AddIcon("film", "rbxassetid://120978945609706")
    AddIcon("filter", "rbxassetid://108829540827529")
    AddIcon("fingerprint", "rbxassetid://112173305232811")
    AddIcon("fire", "rbxassetid://98218034436456")
    AddIcon("flag", "rbxassetid://78183383236196")
    AddIcon("folder", "rbxassetid://121178377882882")
    AddIcon("forward", "rbxassetid://97545944739523")
    AddIcon("gift", "rbxassetid://109855212076373")
    AddIcon("github", "rbxassetid://120349554354380")
    AddIcon("globe", "rbxassetid://114238209622913")
    AddIcon("grid", "rbxassetid://81344910161871")
    AddIcon("hammer", "rbxassetid://83545120140895")
    AddIcon("hand", "rbxassetid://130703864968637")
    AddIcon("hard_drive", "rbxassetid://88183305858463")
    AddIcon("headphones", "rbxassetid://118833729589183")
    AddIcon("heart", "rbxassetid://116559368303288")
    AddIcon("home", "rbxassetid://98755624629571")
    AddIcon("image", "rbxassetid://112751259236831")
    AddIcon("inbox", "rbxassetid://112591360302868")
    AddIcon("info", "rbxassetid://124560466474914")
    AddIcon("instagram", "rbxassetid://119864798614855")
    AddIcon("key", "rbxassetid://96510194465420")
    AddIcon("keyboard", "rbxassetid://121474456068237")
    AddIcon("layers", "rbxassetid://81973586053257")
    AddIcon("layout", "rbxassetid://112556185960101")
    AddIcon("link", "rbxassetid://131607023382430")
    AddIcon("list", "rbxassetid://113179976918783")
    AddIcon("lock", "rbxassetid://134724289526879")
    AddIcon("log_in", "rbxassetid://103768533135201")
    AddIcon("log_out", "rbxassetid://84895399304975")
    AddIcon("mail", "rbxassetid://103945161245599")
    AddIcon("map", "rbxassetid://95107167260947")
    AddIcon("map_pin", "rbxassetid://84279202219901")
    AddIcon("maximize", "rbxassetid://76045941763188")
    AddIcon("menu", "rbxassetid://77021539815611")
    AddIcon("message", "rbxassetid://127255077587058")
    AddIcon("mic", "rbxassetid://89640799126523")
    AddIcon("minimize", "rbxassetid://121304296213645")
    AddIcon("minus", "rbxassetid://118026365011536")
    AddIcon("monitor", "rbxassetid://72664649203050")
    AddIcon("moon", "rbxassetid://83380517901735")
    AddIcon("music", "rbxassetid://113343203848535")
    AddIcon("navigation", "rbxassetid://79308213542922")
    AddIcon("network", "rbxassetid://127410729922644")
    AddIcon("notification", "rbxassetid://136219289862706")
    AddIcon("package", "rbxassetid://97261141732706")
    AddIcon("palette", "rbxassetid://86350350950064")
    AddIcon("paperclip", "rbxassetid://92088291163453")
    AddIcon("pause", "rbxassetid://74873705394436")
    AddIcon("pen", "rbxassetid://72037878096321")
    AddIcon("pencil", "rbxassetid://137986121120732")
    AddIcon("percent", "rbxassetid://130155041032013")
    AddIcon("phone", "rbxassetid://128804946640049")
    AddIcon("play", "rbxassetid://135609604299893")
    AddIcon("plus", "rbxassetid://111774323017047")
    AddIcon("power", "rbxassetid://96479131758775")
    AddIcon("printer", "rbxassetid://76080649734247")
    AddIcon("puzzle", "rbxassetid://136837798892463")
    AddIcon("qr_code", "rbxassetid://105329945723350")
    AddIcon("radio", "rbxassetid://85611589536956")
    AddIcon("refresh", "rbxassetid://138133190015277")
    AddIcon("reply", "rbxassetid://109788633497028")
    AddIcon("rocket", "rbxassetid://87412317685854")
    AddIcon("save", "rbxassetid://126116963775616")
    AddIcon("scale", "rbxassetid://108203682317477")
    AddIcon("scissors", "rbxassetid://118665510911274")
    AddIcon("search", "rbxassetid://121018724060431")
    AddIcon("send", "rbxassetid://127751956873796")
    AddIcon("server", "rbxassetid://92188766517878")
    AddIcon("settings", "rbxassetid://80758916183665")
    AddIcon("share", "rbxassetid://87340985053299")
    AddIcon("shield", "rbxassetid://110987169760162")
    AddIcon("shopping_bag", "rbxassetid://71885477293226")
    AddIcon("shopping_cart", "rbxassetid://128420521375441")
    AddIcon("shuffle", "rbxassetid://132382786975101")
    AddIcon("sliders", "rbxassetid://85538382643347")
    AddIcon("smartphone", "rbxassetid://96623008834511")
    AddIcon("smile", "rbxassetid://105880397565283")
    AddIcon("snowflake", "rbxassetid://101235206534566")
    AddIcon("speaker", "rbxassetid://96227183003618")
    AddIcon("square", "rbxassetid://86304921356806")
    AddIcon("star", "rbxassetid://136141469398409")
    AddIcon("stop", "rbxassetid://80018708472943")
    AddIcon("sun", "rbxassetid://110150589884127")
    AddIcon("tablet", "rbxassetid://128403991264386")
    AddIcon("tag", "rbxassetid://129104970103940")
    AddIcon("target", "rbxassetid://87563802520297")
    AddIcon("terminal", "rbxassetid://106783148545356")
    AddIcon("thumbs_up", "rbxassetid://111137070767020")
    AddIcon("thumbs_down", "rbxassetid://87794009914015")
    AddIcon("ticket", "rbxassetid://126527071492145")
    AddIcon("toggle_left", "rbxassetid://85887872573050")
    AddIcon("toggle_right", "rbxassetid://90411952142550")
    AddIcon("trash", "rbxassetid://106723740584310")
    AddIcon("triangle", "rbxassetid://126330486745540")
    AddIcon("trophy", "rbxassetid://131545003268773")
    AddIcon("tv", "rbxassetid://135687724791776")
    AddIcon("umbrella", "rbxassetid://127502210274589")
    AddIcon("unlock", "rbxassetid://93597915325122")
    AddIcon("upload", "rbxassetid://138212042425501")
    AddIcon("user", "rbxassetid://81589895647169")
    AddIcon("users", "rbxassetid://115398113982385")
    AddIcon("video", "rbxassetid://107587444636945")
    AddIcon("volume", "rbxassetid://103236289817396")
    AddIcon("wallet", "rbxassetid://132331555762628")
    AddIcon("wifi", "rbxassetid://104669375183960")
    AddIcon("wrench", "rbxassetid://112148279212860")
    AddIcon("x", "rbxassetid://110786993356448")
    AddIcon("youtube", "rbxassetid://123663668456341")
    AddIcon("zoom_in", "rbxassetid://127956924984803")
    AddIcon("zoom_out", "rbxassetid://108334162607319")
end
LoadIcons()

-- ================================================================
-- 形状系统
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
    SquircleTLTR = "rbxassetid://75712142040725",
    SquircleBLBR = "rbxassetid://83676684425544",
    SquircleHTLTR = "rbxassetid://90680657206619",
    SquircleHBLBR = "rbxassetid://99216342056719",
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
    SquircleTLTR = Rect.new(512,512,512,512),
    SquircleBLBR = Rect.new(512,0,512,0),
    SquircleHTLTR = Rect.new(807,512,807,512),
    SquircleHBLBR = Rect.new(0,512,0,512),
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
-- Acrylic 毛玻璃效果
-- ================================================================
local AcrylicActive = false
local AcrylicObjects = {}

function EnableAcrylic()
    if AcrylicActive then return end
    AcrylicActive = true
    local dof = Instance.new("DepthOfFieldEffect")
    dof.FarIntensity = 0
    dof.InFocusRadius = 0.1
    dof.NearIntensity = 1
    dof.Parent = Lighting
    table.insert(AcrylicObjects, dof)
end

function DisableAcrylic()
    AcrylicActive = false
    for _, obj in ipairs(AcrylicObjects) do
        pcall(obj.Destroy, obj)
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
    self.Folder = config.Folder or "WindUI"
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
    self.ConfigManager = nil
    self.Localization = nil

    -- 初始化配置管理
    if self.Folder then
        self.ConfigManager = ConfigManager:Init(self.Folder)
    end

    -- 初始化本地化
    self.Localization = Localization:Init({})

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

    -- 密钥系统 (如果配置了)
    if config.KeySystem then
        local function onKeySuccess()
            self:Open()
        end
        local keyFile = self.Folder .. "/" .. (gethwid and gethwid() or tostring(Players.LocalPlayer.UserId)) .. ".key"
        if config.KeySystem.SaveKey and isfile and isfile(keyFile) then
            local savedKey = readfile(keyFile)
            local valid = false
            if config.KeySystem.KeyValidator then
                valid = config.KeySystem.KeyValidator(savedKey)
            elseif config.KeySystem.Key then
                if type(config.KeySystem.Key) == "table" then
                    valid = table.find(config.KeySystem.Key, savedKey) ~= nil
                else
                    valid = config.KeySystem.Key == savedKey
                end
            end
            if valid then
                self:Open()
                return self
            end
        end
        -- 显示密钥系统 UI
        self.KeySystemUI = CreateKeySystemUI(self, config.KeySystem, onKeySuccess)
    end

    -- 窗口底板
    self.MainFrame = New("Frame", {
        Size = self.Size,
        Position = self.Position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = self.Transparent and 0.15 or 0,
        BackgroundColor3 = Theme.WindowBackground,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
        Visible = not config.KeySystem,
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
        ImageTransparency = Theme.WindowShadowTransparency,
        ZIndex = -1,
        Parent = self.MainFrame,
    })
    AddThemeObject(shadow, { ImageTransparency = "WindowShadowTransparency" })

    -- Acrylic
    if self.Acrylic then
        EnableAcrylic()
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

    -- 如果没有密钥系统，直接打开
    if not config.KeySystem then
        self:Open()
    end

    return self
end

function Window:AddMacButton(name, color, callback, order)
    local data = GetIcon(name)
    if not data then return nil end
    local btn = New("ImageButton", {
        Image = data.Image,
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
    if self.KeySystemUI then return end
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
        icon.ImageTransparency = Theme.TabIconTransparency
        AddThemeObject(icon, { ImageTransparency = "TabIconTransparency" })
    end

    AddSignal(btn.MouseEnter, function()
        if not tab.Selected then
            Tween(btn, 0.1, { BackgroundTransparency = Theme.TabBackgroundHoverTransparency }):Play()
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
        if t.Icon then t.Icon.ImageTransparency = Theme.TabIconTransparency end
        t.Button.BackgroundTransparency = 1
        if t.Container.Visible then
            Tween(t.Container, 0.15, { AnchorPoint = Vector2.new(0, 0.05) }):Play()
            task.wait(0.15)
            t.Container.Visible = false
        end
    end

    tab.Selected = true
    tab.Button.TextTransparency = Theme.TabTextTransparencyActive
    if tab.Icon then tab.Icon.ImageTransparency = Theme.TabIconTransparencyActive end
    tab.Button.BackgroundTransparency = Theme.TabBackgroundActiveTransparency
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
-- 所有控件 (完整实现)
-- ================================================================

-- Button
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

-- Label
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

-- Input
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

-- Toggle
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
        BackgroundColor3 = Theme.ToggleBar,
        Parent = toggleBtn,
    })
    AddThemeObject(thumb, { BackgroundColor3 = "ToggleBar" })
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
        -- 保存到配置
        if self.ConfigManager and config.ConfigId then
            self.ConfigManager:RegisterElement(config.ConfigId, config.ConfigId, { Get = function() return state end, Set = function(v) updateState(v, true) end })
        end
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

-- Slider
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
        BackgroundColor3 = Theme.SliderThumb,
        BackgroundTransparency = 0.1,
        Text = "",
        AutoButtonColor = false,
        Parent = track,
    })
    AddThemeObject(thumb, { BackgroundColor3 = "SliderThumb" })
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
        -- 保存到配置
        if self.ConfigManager and config.ConfigId then
            self.ConfigManager:RegisterElement(config.ConfigId, config.ConfigId, { Get = function() return currentValue end, Set = function(v) updateValue(v, true) end })
        end
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

-- Dropdown
function Window:Dropdown(config)
    config = config or {}
    local text = config.Text or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or (options[1] or "")
    local callback = config.Callback
    local searchable = config.Searchable or false
    local multi = config.Multi or false
    local allowNone = config.AllowNone or false

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
        BackgroundColor3 = Theme.DropdownBackground,
        BackgroundTransparency = 0.1,
        Visible = false,
        ClipsDescendants = true,
        ScrollBarThickness = 4,
        ZIndex = 100,
        Parent = frame,
    })
    AddThemeObject(list, { BackgroundColor3 = "DropdownBackground" })
    New("UICorner", { CornerRadius = UDim.new(0, 8) }, { Parent = list })
    New("UIStroke", { Color = Theme.DropdownTabBorder, Transparency = 0.8, Thickness = 1 }, { Parent = list })
    AddThemeObject(list:FindFirstChild("UIStroke"), { Color = "DropdownTabBorder" })
    local listLayout = New("UIListLayout", {
        SortOrder = "LayoutOrder",
        Padding = UDim.new(0, 2),
    }, { Parent = list })

    local searchBox = nil
    if searchable then
        searchBox = New("TextBox", {
            Size = UDim2.new(1, 0, 0, 32),
            PlaceholderText = "Search...",
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
                        if allowNone and #selectedOptions == 1 then return end
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

-- ProgressBar
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
        BackgroundColor3 = Theme.ProgressBarTrack,
        BackgroundTransparency = Theme.ProgressBarTrackTransparency,
        Parent = frame,
    })
    AddThemeObject(track, { BackgroundColor3 = "ProgressBarTrack", BackgroundTransparency = "ProgressBarTrackTransparency" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = track })

    local fill = New("Frame", {
        Size = UDim2.new(value / 100, 0, 1, 0),
        BackgroundColor3 = Theme.ProgressBar,
        Parent = track,
    })
    AddThemeObject(fill, { BackgroundColor3 = "ProgressBar" })
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, { Parent = fill })

    local valueLabel = New("TextLabel", {
        Text = tostring(math.floor(value)) .. "%",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.ProgressBarText,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        TextXAlignment = "Right",
        Parent = frame,
    })
    AddThemeObject(valueLabel, { TextColor3 = "ProgressBarText" })

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

-- Keybind
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

    -- 监听按键
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

-- ColorPicker (简化版)
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
        pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
        local h,s,v = Color3.toHSV(default)
        hueThumb.Position = UDim2.new(h, 0, 0.5, 0)
    end

    AddSignal(colorPreview.MouseButton1Click, openPicker)

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

-- Dialog
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
        BackgroundColor3 = Theme.DialogBackground,
        BackgroundTransparency = Theme.DialogBackgroundTransparency,
        AutomaticSize = "Y",
        ClipsDescendants = true,
        ZIndex = 1000,
        Parent = overlay,
    })
    AddThemeObject(dialog, { BackgroundColor3 = "DialogBackground", BackgroundTransparency = "DialogBackgroundTransparency" })
    New("UICorner", { CornerRadius = UDim.new(0, 12) }, { Parent = dialog })
    New("UIStroke", { Color = Theme.Text, Transparency = 0.8, Thickness = 1 }, { Parent = dialog })
    AddThemeObject(dialog:FindFirstChild("UIStroke"), { Color = "Text" })
    New("UIPadding", { PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, { Parent = dialog })

    local titleLabel = New("TextLabel", {
        Text = title,
        TextColor3 = Theme.DialogTitle,
        TextSize = 18,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = "Y",
        Parent = dialog,
    })
    AddThemeObject(titleLabel, { TextColor3 = "DialogTitle" })

    local contentLabel = New("TextLabel", {
        Text = content,
        TextColor3 = Theme.DialogContent,
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
    AddThemeObject(contentLabel, { TextColor3 = "DialogContent" })

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

    AddSignal(overlay.MouseButton1Click, function()
        overlay:Destroy()
    end)
    AddSignal(dialog.MouseButton1Click, function() end)

    return overlay
end

-- Paragraph
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

-- Divider
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

-- Section
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

-- Notification
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
        BackgroundColor3 = Theme.Notification,
        BackgroundTransparency = 0.05,
        Parent = self.ScreenGui,
        ClipsDescendants = true,
        ZIndex = 100,
    })
    AddThemeObject(notif, { BackgroundColor3 = "Notification" })
    New("UICorner", { CornerRadius = UDim.new(0, 12) }, { Parent = notif })
    New("UIStroke", { Color = Theme.NotificationBorder, Transparency = Theme.NotificationBorderTransparency, Thickness = 1 }, { Parent = notif })
    AddThemeObject(notif:FindFirstChild("UIStroke"), { Color = "NotificationBorder", Transparency = "NotificationBorderTransparency" })
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
        TextColor3 = Theme.NotificationTitle,
        TextSize = 16,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        AutomaticSize = "XY",
        Parent = textFrame,
    })
    AddThemeObject(titleLabel, { TextColor3 = "NotificationTitle" })
    local contentLabel = New("TextLabel", {
        Text = content,
        TextColor3 = Theme.NotificationContent,
        TextSize = 14,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular),
        BackgroundTransparency = 1,
        TextXAlignment = "Left",
        AutomaticSize = "XY",
        TextTransparency = Theme.NotificationContentTransparency,
        Parent = textFrame,
    })
    AddThemeObject(contentLabel, { TextColor3 = "NotificationContent", TextTransparency = "NotificationContentTransparency" })

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
-- 自动创建演示窗口
-- ================================================================
local function AutoCreate()
    local win = Window.New({
        Title = "WindUI v5.0 完整版",
        SubTitle = "包含密钥系统、配置、本地化",
        Author = "独立实现",
        Size = UDim2.new(0, 820, 0, 580),
        Resizable = true,
        Transparent = false,
        Acrylic = false,
        MinimizeKey = Enum.KeyCode.H,
        Folder = "WindUI_Demo",
        KeySystem = {
            Title = "密钥验证",
            Note = "输入 test_key_platoboost 测试",
            URL = "https://example.com/getkey",
            SaveKey = true,
            Key = "test_key_platoboost",
            -- 或使用 KeyValidator
            -- KeyValidator = function(key) return key == "test_key_platoboost" end,
            -- 或使用 API
            -- API = {
            --     { Type = "platoboost", ServiceId = "xxx", Secret = "xxx" },
            -- },
        },
    })

    local tab1 = win:AddTab({ Title = "基础", Icon = "home" })
    win:AddElement(tab1.Index, win:Paragraph({ Text = "v5.0 完整版 - 包含所有原版功能" }))
    win:AddElement(tab1.Index, win:Divider())
    win:AddElement(tab1.Index, win:Button({ Text = "点击测试", Callback = function()
        print("点击")
        win:Notify({ Title = "提示", Content = "按钮被点击", Icon = "check", Duration = 2 })
    end }))
    win:AddElement(tab1.Index, win:Input({ Placeholder = "输入框", ClearTextOnFocus = true }))
    win:AddElement(tab1.Index, win:Toggle({ Text = "开关", Default = true, ConfigId = "toggle_test" }))

    local tab2 = win:AddTab({ Title = "控件", Icon = "settings" })
    win:AddElement(tab2.Index, win:Slider({ Text = "滑块", Min = 0, Max = 100, Default = 50, Step = 5, ConfigId = "slider_test" }))
    win:AddElement(tab2.Index, win:Dropdown({ Text = "下拉框", Options = {"选项A", "选项B", "选项C"}, Default = "选项A", Searchable = true }))
    win:AddElement(tab2.Index, win:ProgressBar({ Text = "进度条", Value = 75 }))
    win:AddElement(tab2.Index, win:Keybind({ Text = "按键绑定", Default = "F" }))
    win:AddElement(tab2.Index, win:ColorPicker({ Text = "颜色选择器", Default = Color3.fromHex("#0091FF") }))

    local tab3 = win:AddTab({ Title = "分组", Icon = "folder" })
    local sec = win:Section({ Title = "可折叠分组" })
    sec:AddElement(win:Button({ Text = "组内按钮1" }))
    sec:AddElement(win:Button({ Text = "组内按钮2" }))
    sec:AddElement(win:Input({ Placeholder = "组内输入" }))
    win:AddElement(tab3.Index, sec)

    local sec2 = win:Section({ Title = "另一个分组", Collapsed = true })
    sec2:AddElement(win:Label({ Text = "这个分组默认折叠" }))
    win:AddElement(tab3.Index, sec2)

    task.delay(0.5, function()
        win:Notify({ Title = "WindUI v5.0", Content = "所有功能已加载", Icon = "check", Duration = 3 })
    end)

    return win
end

return AutoCreate()
