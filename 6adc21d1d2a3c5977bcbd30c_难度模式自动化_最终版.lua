--[[
  难度模式 自动化 · 单文件版（界面 + 引擎）
  =================================================
  · 只有一个文件：菜单直接在本脚本里创建
  · WindUI 库走原版链接加载（和旧版脚本同一条链接）
  · 所有功能默认关闭，必须玩家在菜单里手动打开开关才会运行
  · 大厅流程：自动投票 → 准备 → 开单人局
]]

-- ============================================================
-- 界面（内嵌单文件：WindUI 用原版链接加载，菜单直接在这里创建）
-- ============================================================
local UI = (function()
--[[
  难度模式 · 界面部分（内嵌）
  =================================================
  · WindUI 库按原版链接加载（和旧脚本同一个链接）
  · 窗口 550x380 / 默认侧栏 / 隐藏搜索栏
  · 适配游戏：难度模式（PlaceId 18816546575）
  · 所有功能默认关闭，必须玩家自己在界面里打开开关才会运行
]]


-- ============================================================
-- WindUI 库：原版链接加载（带备用镜像 + 明确报错，避免 nil 报错）
-- ============================================================
function xLoadWindUI()
    local urls = {
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/master/dist/main.lua",
    }
    for _, u in ipairs(urls) do
        local ok, src = pcall(function() return game:HttpGet(u) end)
        if ok and type(src) == "string" and #src > 2000 then
            local fn = loadstring(src)
            if fn then
                local ok2, lib = pcall(fn)
                if ok2 and type(lib) == "table" and lib.CreateWindow then
                    return lib
                end
            end
        end
    end
    return nil
end

local WindUI = xLoadWindUI()
if not WindUI then
    error("[难度模式] WindUI 加载失败：链接被拦截或网络不通，请检查执行器是否允许 HttpGet", 0)
end

-- ============================================================
-- 窗口：和老版本完全一致（550x380 / 默认侧栏 / 无搜索栏）
-- ============================================================
local Window = WindUI:CreateWindow({
    Title    = "至尊版",
    IconThemed = true,
    Icon     = "rbxassetid://103789103251622",
    Author   = "STBB | 至尊版",
    Folder   = "YYa",

    Size     = UDim2.fromOffset(550, 380),

    Background = "rbxassetid://90331823252393",
    BackgroundImageTransparency = 0.8,

    Transparent = true,
    Theme = "Dark",
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = { Enabled = true, Anonymous = false },
})

Window:SetToggleKey(Enum.KeyCode.K)
Window:Tag({ Title = "至尊版", Color = Color3.fromHex("#db7093") })
Window:EditOpenButton({
    Title = "至尊版 - 打开",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true,
})

-- ============================================================
-- 共享状态（界面与自动化引擎共用）
-- 所有功能开关默认 false：玩家不手动打开，脚本就什么都不做
-- ============================================================
local AUTO = {
    -- 流程开关（默认全关，必须在界面里手动打开）
    AutoOpenVote  = false,   -- 大厅自动打开投票界面（相当于点击 GUI）
    AutoVote      = false,   -- 自动投票选难度模式
    AutoStart     = false,   -- 自动开单人局（StartSolo）
    AutoEquipChar = false,   -- 自动装备你在「玩家」页选的角色（不判断强弱）
    Character     = "",      -- 玩家自选角色名，空 = 不自动装备
    AutoSkipVote  = false,   -- 自动跟着投跳波票
    AutoReady     = false,   -- 大厅自动点新版 UI 准备按钮（点不动才发 GetReadyRemote）
    AutoSkip      = false,   -- 自动开启跳波设置
    AutoSkipHeli  = false,   -- 自动跳过直升机过场
    AutoSettings  = false,   -- 自动打开游戏内快速过场等设置
    AutoFight     = false,   -- 自动锁敌 + 开火
    AutoAim       = false,   -- 自动瞄准
    AutoTeleport  = false,   -- 敌人太远时直接瞬移到脸上
    AutoSkill     = false,   -- 自动放技能
    AutoRevive    = false,   -- 自动救倒地队友
    AutoRespawn   = false,   -- 无限复活：残血自动重置角色，立刻重生
    ReviveHp      = 35,      -- 血量百分比低于这个值就触发复活重置
    AutoDodge     = false,   -- 瞬移躲投射物（导弹/投掷物朝你飞来时侧向瞬移）
    AutoContinue  = false,   -- 结算自动准备下一局
    AutoApproach  = false,   -- 敌人太远自动靠近
    AntiAfk       = false,   -- 防踢
    ESP           = false,   -- 敌人透视（Highlight）
    ESPAlly       = false,   -- 队友透视（绿色高亮）
    -- 奖励 / 收集自动化（默认全关）
    AutoClaimLogin = false,  -- 自动领每日登录奖励（LoginRemote）
    AutoClaimGroup = false,  -- 自动领团队奖励（GroupRewardRemote）
    AutoClickClaim = false,  -- 自动点界面上所有可领取按钮（Claim / Collect / 领取）
    AutoGachaChar  = false,  -- 自动抽角色
    AutoGachaSkin  = false,  -- 自动抽皮肤
    AutoCapsule    = false,  -- 自动开扭蛋胶囊
    AutoSquadQuest = false,  -- 自动接取 / 完成 G-Squad 小队任务
    AutoRestartVote = false, -- 结算后自动投"重新开始"票
    AutoTitle      = false,  -- 自动装备指定称号
    -- 商店 / 消耗品自动化（默认全关）
    AutoBuyHP      = false,  -- 低血量自动在商店买补血
    AutoPotion     = false,  -- 低血量自动喝药水
    AutoBoost      = false,  -- 自动续开加速卡
    AutoUseMoney   = false,  -- 自动使用金钱袋（UseItems Money）
    AutoSkillTree  = false,  -- 自动升级技能树
    -- 角色 / 移动（默认全关）
    NoClip         = false,  -- 无碰撞
    Fly            = false,  -- 飞行
    InfiniteJump   = false,  -- 无限跳跃
    LockMoveStats  = false,  -- 锁定移动速度 / 跳跃力
    FullBright     = false,  -- 全亮
    NoFog          = false,  -- 无雾
    GodMode        = false,  -- 上帝模式（低血自动补满）
    NoBarrier      = false,  -- 绕过隐形屏障
    -- 刷怪设置（默认全关）
    AutoFarm       = false,  -- 自动刷怪总开关（持续贴怪）
    -- 天文币 / 农场辅助（默认全关）
    AutoAstroFarm    = false,  -- 自动刷天文币：切天文模式并刷天文怪
    AutoAstroCollect = false,  -- 自动拾取天文零件
    AutoAstroInsert  = false,  -- 自动上交天文零件换取天文币
    AutoAstroTech    = false,  -- 自动升级天文科技
    AutoAstroReport  = false,  -- 定时汇报天文币数量
    AutoAstroToken   = false,  -- 天文币模式一：贴图零件往返刷币
    RemoveMap        = false,  -- 删除地图（提帧）
    AutoFarmAssist   = false,  -- 自动刷怪辅助：保持锁定与输出
    AutoOneClickReady = false, -- 一键准备：投票 + 准备 + 开局
    ResetWave      = false,  -- 到达指定波次回安全点
    BypassJeffrey  = false,  -- 绕过 Jeffrey
    AntiJeffrey    = false,  -- Anti Jeffrey
    FlushAura      = false,  -- 自动冲刷光环
    -- 透视扩展（默认全关）
    ESPEnable      = false,  -- 透视总开关
    ESPPlayer      = false,  -- 玩家透视
    ESPItem        = false,  -- 物品透视
    -- 商店扩展（默认全关）
    AutoBuyWeapon  = false,  -- 自动买武器
    AutoBuyMisc    = false,  -- 自动买杂项
    AutoRequest    = false,  -- 自动请求（第 10 波后）
    UpgradeTitanSpeaker = false, -- 自动升级泰坦扬声器
    UpgradeUTCM    = false,  -- 自动升级 UTCM
    UpgradeTV      = false,  -- 自动升级 TV
    AutoHourly     = false,  -- 自动小时购
    AutoUseItem    = false,  -- 自动使用物品
    UseItemName    = "Presents", -- 要使用的物品
    -- 收集扩展（默认全关）
    AutoCollect    = false,  -- 自动收集
    -- 杂项（默认全关）
    AutoSave       = false,  -- 自动保存配置
    AutoVoteInGame = false,  -- 局内自动投票
    AutoGameModeLobby = false, -- 大厅自动应用游戏模式
    CombatDebug    = false,  -- 战斗调试日志
    -- 自动化参数
    GachaSpin      = "10Spins",                  -- 抽奖档位
    BoostName      = "Booster X2 Mastery : 30Min", -- 加速卡名称
    PotionName     = "Potion",                     -- 自动喝哪种药水
    TitleName      = "",                          -- 要装备的称号名
    FarmMode       = "Normal",                    -- 刷怪模式
    FarmPos        = "Above",                     -- 刷怪位置：Above / Under / Orbit
    FarmMove       = "Teleport",                  -- 移动方式：Teleport / Tween
    CircleRadius   = 6,                            -- 环绕半径
    FarmHeight     = 0,                            -- 刷怪高度
    SkillDelay     = 1,                            -- 技能按键间隔（秒）
    SafeHp         = 30,                           -- 安全模式血量
    GodHp          = 30,                           -- 上帝模式触发血量
    ResetWaveValue = 10,                           -- 第几波重置
    AntiJeffreyRange = 50,                         -- Jeffrey 检测范围
    FlushAuraRange = 5,                            -- 冲刷光环范围
    WalkSpeed      = 16,                           -- 锁定移速
    JumpPower      = 50,                           -- 锁定跳跃力
    FlySpeed       = 1,                            -- 飞行速度倍率（x50）
    FlyHeight      = 10,                           -- 飞行升降速度
    CameraMode     = "Classic",                    -- 相机模式：Classic / Manual
    WeaponName     = "Stungun",                    -- 要买的武器
    MiscName       = "HeadPhone",                  -- 要买的杂项
    RequestName    = "Titan-Request",              -- 要请求的物品
    HourlyAmount   = 1,                            -- 小时购数量
    HourlyCustom   = "",                           -- 小时购自定义物品名
    CollectMode    = "Clean",                      -- 收集模式
    CollectMove    = "Teleport",                   -- 收集移动方式
    AutoSaveDelay  = 15,                           -- 自动保存间隔
    GameMode       = "Normal",                     -- 大厅游戏模式
    ESPSettings    = { "高亮" },                    -- 透视显示项
    ESPItems       = {},                           -- 透视物品列表
    TitanUpgrades  = {},                           -- 泰坦扬声器升级
    UTCMUpgrades   = {},                           -- UTCM 升级
    TVUpgrades     = {},                           -- TV 升级
    HourlyItems    = {},                           -- 小时购物品
    CollectItems   = {},                           -- 收集物品列表
    SelectedCodes  = {},                           -- 已选兑换码
    SelectedPasses = {},                           -- 已选通行证
    -- 内部数值
    Range         = 400,     -- 锁敌半径
    SkillTick     = 0.2,     -- 技能检查频率（每个技能按自己的冷却独立触发）
    VoteGap       = 5,       -- 重复投票间隔
    TeleportDist  = 90,      -- 超过这个距离直接瞬移
    TurnDist      = 110,     -- 超过这个距离开始瞬移
    VoteMode      = "",      -- 空 = 自动投当前票数最高的模式
    -- 运行数据
    Phase         = "启动中",
    LastReason    = "就绪",
    Target        = nil,
    VoteState     = "—",
    Running       = true,
    Paused        = false,
    Actions       = {},
    Logs          = {},
}

-- 启动时读取上次保存的配置（有就覆盖默认值，界面会显示保存时的状态）
pcall(function()
    if type(isfile) == "function" and type(readfile) == "function" and isfile("难度模式_配置.json") then
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("难度模式_配置.json"))
        end)
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                if AUTO[k] ~= nil and type(v) == type(AUTO[k]) then
                    AUTO[k] = v
                end
            end
        end
    end
end)

-- ============================================================
-- 界面：布局与老版本至尊版一模一样
-- 信息 / 主要 / 透视 / 玩家 / 商店 / 收集 / 游戏模式 / 设置
-- 所有功能开关默认关闭，必须玩家手动打开才会运行
-- ============================================================
-- 中文显示名 → 游戏实际参数（下拉框显示中文，发给引擎英文）
-- ============================================================
local UI_LISTS = {
    FarmMode = {
        { "普通模式", "Normal Mode" },
        { "Astro 坚守模式", "Astro Holdout Mode" },
        { "黑暗维度模式", "Dark Dimension Mode" },
    },
    FarmPos = {
        { "上方", "Above" },
        { "下方", "Under" },
        { "环绕", "Orbit" },
    },
    Move = {
        { "传送", "Teleport" },
        { "补间", "Tween" },
    },
    CollectMode = {
        { "清洁", "Clean" },
        { "IDGF", "IDGF" },
    },
    Camera = {
        { "经典", "Classic" },
        { "手动", "Manual" },
    },
    Collect = {
        { "时钟蜘蛛", "Clock Spider" }, { "X-18 核心", "X-18 Core" },
        { "绿色能量核心", "Green Energy Core" }, { "奇怪发射器", "Weird Transmitter" },
        { "Astro 样本", "Astro Samples" }, { "奇怪棱镜", "Weird Prism" },
        { "钥匙卡", "Key Card" }, { "僵尸核心", "Zombie Core" },
        { "闪存驱动器", "Flash Drives" }, { "礼物", "Presents" },
        { "创世纪核心", "Genesis Core" },
    },
    Weapon = {
        { "电击枪", "Stungun" }, { "火焰喷射器", "Flamethrower" },
        { "鱼叉枪", "Harpoon Gun" }, { "霰弹枪", "Shot Gun" },
        { "脉冲步枪", "Pulse Rifle" }, { "鱼叉霰弹枪", "Shot Harpoon Gun" },
        { "EPD", "EPD" }, { "小型激光枪", "Small Laser Gun" },
    },
    Misc = {
        { "头戴式耳机", "HeadPhone" }, { "手雷", "Grenade" },
        { "喷气背包", "Jetpack" }, { "透镜", "Lens" },
    },
    Request = {
        { "泰坦请求", "Titan-Request" }, { "特殊泰坦请求", "SpecialTitan-Request" },
        { "扬声器请求", "Speaker-Request" },
    },
    Pass = {
        { "全部", "All" }, { "幸运加成", "LuckyBoost" },
        { "稀有幸运加成", "RareLuckyBoost" }, { "传奇幸运加成", "LegendaryLuckyBoost" },
    },
    Titan = {
        { "喷气背包", "Jetpack" }, { "过载", "OverCharge" },
        { "音波增幅器", "SoundBooster" }, { "核心", "Core" }, { "升级", "Upgrade" },
    },
    UTCM = {
        { "护盾", "Shield" }, { "冲击波", "Blaster" }, { "透镜", "Lens" },
        { "热度", "Heat" }, { "护甲", "Armor" },
    },
    TV = {
        { "吸收", "Absorb" }, { "共享过载", "ShareOverCharge" },
        { "护盾", "Shield" }, { "Astro 臂", "AstroArm" },
    },
    Hourly = {
        { "幸运药水 I", "LuckPotionI" }, { "幸运药水 II", "LuckPotionII" },
        { "幸运药水 III", "LuckPotionIII" }, { "S-余烬", "S-Ember" },
        { "BSX2:30", "BSX2:30" }, { "BSX2:60", "BSX2:60" }, { "BSX2:360", "BSX2:360" },
        { "闪存驱动器#1", "FlashDrive#1" }, { "闪存驱动器#2", "FlashDrive#2" },
        { "闪存驱动器#3", "FlashDrive#3" }, { "闪存驱动器#4", "FlashDrive#4" },
        { "闪存驱动器#5", "FlashDrive#5" }, { "闪存驱动器#6", "FlashDrive#6" },
        { "大师卡：普通", "MasterCard:Normal" },
        { "大师卡：普通泰坦", "MasterCard:NormalTitan" },
        { "大师卡：特殊泰坦", "MasterCard:SpecialTitan" },
    },
    UseItem = { { "礼物", "Presents" } },
    Vote = {
        { "普通", "Normal" }, { "非常困难", "VeryHard" }, { "困难", "Hard" },
        { "疯狂", "Insane" }, { "噩梦", "Nightmare" }, { "Boss Rush", "BossRush" },
        { "黑暗维度", "DarkDimension" }, { "地狱", "Hell" }, { "雷暴", "ThunderStorm" },
        { "圣诞节", "Christmas" }, { "僵尸", "Zombie" }, { "僵尸 V2", "ZombieV2" },
        { "Astro V2", "AstroV2" }, { "Astro", "Astro" }, { "战斗装甲 第一章", "BattleArmorAct1" },
        { "声波", "Soundwave" }, { "万圣节", "Halloween" }, { "无光之夜", "NoLightInTheSky" },
        { "1亿访问", "100MVisit" },
    },
    GameMode = {
        { "普通", "Normal" }, { "困难", "Hard" }, { "非常困难", "VeryHard" },
        { "疯狂", "Insane" }, { "噩梦", "Nightmare" }, { "Boss Rush", "BossRush" },
        { "黑暗维度", "DarkDimension" }, { "地狱", "Hell" }, { "雷暴", "ThunderStorm" },
        { "圣诞节", "Christmas" }, { "僵尸", "Zombie" }, { "僵尸 V2", "ZombieV2" },
        { "Astro V2", "AstroV2" }, { "Astro", "Astro" }, { "战斗装甲 第一章", "BattleArmorAct1" },
        { "声波", "Soundwave" }, { "万圣节", "Halloween" }, { "无光之夜", "NoLightInTheSky" },
        { "1亿访问", "100MVisit" },
    },
    Gacha = {
        { "1次抽奖", "1Spin" }, { "10次抽奖", "10Spins" }, { "100次抽奖", "100Spins" },
        { "1次幸运抽奖", "1SpinLucky" }, { "10次幸运抽奖", "10SpinLucky" },
    },
    ESP = {
        { "高亮", "Highlight" }, { "距离", "Distance" },
        { "血量", "Health" }, { "名称", "Name" },
    },
}

local UI_VALUES, UI_ENG = {}, {}
for key, list in pairs(UI_LISTS) do
    UI_VALUES[key] = {}
    UI_ENG[key] = {}
    for _, pair in ipairs(list) do
        table.insert(UI_VALUES[key], pair[1])
        UI_ENG[key][pair[1]] = pair[2]
    end
end

function uiEng(key, display)
    if display == nil then return nil end
    return UI_ENG[key][display] or display
end

function uiEngList(key, list)
    if type(list) ~= "table" then return {} end
    local out = {}
    for _, v in ipairs(list) do
        table.insert(out, uiEng(key, v))
    end
    return out
end

function uiDisp(key, english)
    if english == nil then return nil end
    for d, e in pairs(UI_ENG[key]) do
        if e == english then return d end
    end
    return english
end

function uiDispList(key, englishList)
    if type(englishList) ~= "table" then return {} end
    local out = {}
    for _, v in ipairs(englishList) do
        table.insert(out, uiDisp(key, v))
    end
    return out
end

local InfoTab = Window:Tab({ Title = "信息", Icon = "info" })
Window:Divider()
local MainTab = Window:Tab({ Title = "主要", Icon = "rocket" })
local EspTab = Window:Tab({ Title = "透视", Icon = "eye" })
local PlayerTab = Window:Tab({ Title = "玩家", Icon = "user" })
Window:Divider()
local ShopTab = Window:Tab({ Title = "商店", Icon = "shopping-cart" })
local CollectTab = Window:Tab({ Title = "收集", Icon = "hand" })
local ModeTab = Window:Tab({ Title = "游戏模式", Icon = "gamepad" })
Window:Divider()
local SettingsTab = Window:Tab({ Title = "设置", Icon = "settings" })
Window:SelectTab(1)

-- ====================== 信息 ======================
local SecInfo = InfoTab:Section({
    Title = "难度模式 至尊版",
    TextXAlignment = "Center",
    TextSize = 17,
})

SecInfo:Paragraph({
    Title = "最新更新",
    Desc  = "布局与老版本至尊版一模一样。所有功能默认关闭，必须你手动打开开关才会运行，不打开就什么都不做。\n开局流程：自动投票 → 点击新版 UI 准备按钮 → 开单人局。\n战斗功能：自动锁敌开火 / 自动瞄准 / 自动技能 / 瞬移贴脸 / 瞬移躲投射物 / 无限复活 / 自动救人 / 结算自动继续，全部独立开关，按需打开。\n本次新增：自动领登录奖 / 团队奖 / 一键点领取按钮 / 自动抽角色 / 抽皮肤 / 开胶囊 / 小队任务 / 重开投票 / 自动称号 / 自动补血 / 喝药 / 续加速 / 用金钱袋 / 升级技能树 / 队友透视，同样默认全关。",
})

-- ====================== 主要 ======================
local SecFight = MainTab:Section({ Title = "自动刷怪", Icon = "swords" })

SecFight:Toggle({
    Title = "自动刷怪",
    Desc  = "按「刷怪设置」里的位置 / 移动方式持续贴着敌人",
    Value = AUTO.AutoFarm,
    Callback = function(v) AUTO.AutoFarm = v end,
})

SecFight:Toggle({
    Title = "自动战斗",
    Desc  = "锁定最近敌人并持续开火",
    Value = AUTO.AutoFight,
    Callback = function(v) AUTO.AutoFight = v end,
})

SecFight:Toggle({
    Title = "自动瞄准",
    Desc  = "准星自动对准锁定的敌人",
    Value = AUTO.AutoAim,
    Callback = function(v) AUTO.AutoAim = v end,
})

SecFight:Toggle({
    Title = "自动技能",
    Desc  = "每个技能按自己的冷却独立触发，冷却好就点；普攻连续点击",
    Value = AUTO.AutoSkill,
    Callback = function(v) AUTO.AutoSkill = v end,
})

SecFight:Toggle({
    Title = "自动刷天文币",
    Desc  = "切到天文模式，自动刷天文怪、捡零件、上交换天文币",
    Value = AUTO.AutoAstroFarm,
    Callback = function(v) AUTO.AutoAstroFarm = v end,
})

SecFight:Toggle({
    Title = "天文币模式一（贴图刷币）",
    Desc  = "老版刷币：贴图零件上下往返，倒计时 5 秒自杀重置并贴计时器锁位",
    Value = AUTO.AutoAstroToken,
    Callback = function(v) AUTO.AutoAstroToken = v end,
})

SecFight:Toggle({
    Title = "删除地图（提帧）",
    Desc  = "把所有非怪物的部件、贴图、特效隐藏，随时可恢复",
    Value = AUTO.RemoveMap,
    Callback = function(v) AUTO.RemoveMap = v end,
})

SecFight:Toggle({
    Title = "Astro 终局门",
    Desc  = "Astro 坚守模式清完怪后，自动走终局门进入下一波",
    Value = AUTO.AutoAstroFinalDoor,
    Callback = function(v) AUTO.AutoAstroFinalDoor = v end,
})

SecFight:Toggle({
    Title = "反 AFK",
    Desc  = "挂机时自动模拟点击，避免被系统踢出",
    Value = AUTO.AntiAFK ~= false,
    Callback = function(v) AUTO.AntiAFK = v end,
})

SecFight:Toggle({
    Title = "拾取天文零件",
    Desc  = "自动瞬移拾取附近的天文零件",
    Value = AUTO.AutoAstroCollect,
    Callback = function(v) AUTO.AutoAstroCollect = v end,
})

SecFight:Toggle({
    Title = "上交天文零件",
    Desc  = "把背包里的天文零件自动上交研究，换取天文币",
    Value = AUTO.AutoAstroInsert,
    Callback = function(v) AUTO.AutoAstroInsert = v end,
})

SecFight:Toggle({
    Title = "自动天文科技",
    Desc  = "自动升级天文科技树",
    Value = AUTO.AutoAstroTech,
    Callback = function(v) AUTO.AutoAstroTech = v end,
})

SecFight:Toggle({
    Title = "天文币汇报",
    Desc  = "定时把当前天文币数量写进日志",
    Value = AUTO.AutoAstroReport,
    Callback = function(v) AUTO.AutoAstroReport = v end,
})

SecFight:Toggle({
    Title = "刷怪辅助",
    Desc  = "自动刷怪时保持锁定目标与自动输出",
    Value = AUTO.AutoFarmAssist,
    Callback = function(v) AUTO.AutoFarmAssist = v end,
})

SecFight:Toggle({
    Title = "一键准备",
    Desc  = "自动投票 + 点准备 + 开单人局，一次完成",
    Value = AUTO.AutoOneClickReady,
    Callback = function(v) AUTO.AutoOneClickReady = v end,
})

SecFight:Toggle({
    Title = "瞬移贴脸",
    Desc  = "敌人太远直接瞬移到身边，不走路",
    Value = AUTO.AutoTeleport,
    Callback = function(v) AUTO.AutoTeleport = v end,
})

SecFight:Toggle({
    Title = "自动靠近",
    Desc  = "敌人较远时自动贴近（瞬移贴脸的补充）",
    Value = AUTO.AutoApproach,
    Callback = function(v) AUTO.AutoApproach = v end,
})

SecFight:Toggle({
    Title = "瞬移躲投射物",
    Desc  = "导弹 / 投掷物朝你飞来时侧向瞬移躲开",
    Value = AUTO.AutoDodge,
    Callback = function(v) AUTO.AutoDodge = v end,
})

SecFight:Toggle({
    Title = "自动救人",
    Desc  = "附近队友倒地时自动按住救人交互",
    Value = AUTO.AutoRevive,
    Callback = function(v) AUTO.AutoRevive = v end,
})

SecFight:Toggle({
    Title = "无限复活",
    Desc  = string.format("血量低于 %d%% 自动重置角色，立刻重生，不会真死", AUTO.ReviveHp),
    Value = AUTO.AutoRespawn,
    Callback = function(v) AUTO.AutoRespawn = v end,
})

SecFight:Slider({
    Title = "无限复活血量",
    Desc  = "血量百分比低于这个值就重置角色复活，直接拖动设置",
    Value = { Min = 1, Max = 99, Default = AUTO.ReviveHp },
    Step = 1,
    Callback = function(v) AUTO.ReviveHp = v end,
})

local SecFarmSet = MainTab:Section({ Title = "刷怪设置", Icon = "crosshair" })

SecFarmSet:Dropdown({
    Title = "刷怪模式",
    Desc  = "普通 / Astro 坚守 / 黑暗维度",
    Values = UI_VALUES.FarmMode,
    Multi = false,
    Value = uiDisp("FarmMode", AUTO.FarmMode),
    Callback = function(v) if v then AUTO.FarmMode = uiEng("FarmMode", v) end end,
})

SecFarmSet:Dropdown({
    Title = "刷怪位置",
    Desc  = "贴怪时站在敌人的哪个方向",
    Values = UI_VALUES.FarmPos,
    Multi = false,
    Value = uiDisp("FarmPos", AUTO.FarmPos),
    Callback = function(v) if v then AUTO.FarmPos = uiEng("FarmPos", v) end end,
})

SecFarmSet:Dropdown({
    Title = "移动方式",
    Desc  = "传送 = 瞬移贴怪，补间 = 平滑移动",
    Values = UI_VALUES.Move,
    Multi = false,
    Value = uiDisp("Move", AUTO.FarmMove),
    Callback = function(v) if v then AUTO.FarmMove = uiEng("Move", v) end end,
})

SecFarmSet:Slider({
    Title = "环绕半径",
    Desc  = "刷怪位置选 Orbit 时的绕圈半径",
    Value = { Min = 2, Max = 20, Default = AUTO.CircleRadius },
    Step = 1,
    Callback = function(v) AUTO.CircleRadius = v end,
})

SecFarmSet:Slider({
    Title = "刷怪高度",
    Desc  = "贴怪位置的上下偏移",
    Value = { Min = -150, Max = 150, Default = AUTO.FarmHeight },
    Step = 5,
    Callback = function(v) AUTO.FarmHeight = v end,
})

SecFarmSet:Slider({
    Title = "技能延迟",
    Desc  = "自动技能两次按键之间的间隔（秒）",
    Value = { Min = 1, Max = 60, Default = AUTO.SkillDelay },
    Step = 1,
    Callback = function(v) AUTO.SkillDelay = v end,
})

SecFarmSet:Slider({
    Title = "安全模式血量",
    Desc  = "血量低于该百分比时自动退回安全点",
    Value = { Min = 1, Max = 99, Default = AUTO.SafeHp },
    Step = 1,
    Callback = function(v) AUTO.SafeHp = v end,
})

SecFarmSet:Toggle({
    Title = "上帝模式",
    Desc  = "血量低于指定值时自动补满（客户端）",
    Value = AUTO.GodMode,
    Callback = function(v) AUTO.GodMode = v end,
})

SecFarmSet:Slider({
    Title = "上帝模式血量",
    Desc  = "上帝模式的触发血量百分比",
    Value = { Min = 1, Max = 99, Default = AUTO.GodHp },
    Step = 1,
    Callback = function(v) AUTO.GodHp = v end,
})

SecFarmSet:Toggle({
    Title = "重置波次",
    Desc  = "到达指定波次后回到安全点，避免高层翻车",
    Value = AUTO.ResetWave,
    Callback = function(v) AUTO.ResetWave = v end,
})

SecFarmSet:Slider({
    Title = "重置波次数值",
    Desc  = "第几波触发重置",
    Value = { Min = 1, Max = 100, Default = AUTO.ResetWaveValue },
    Step = 1,
    Callback = function(v) AUTO.ResetWaveValue = v end,
})

local SecJeffrey = MainTab:Section({ Title = "Jeffrey 设置", Icon = "ghost" })

SecJeffrey:Toggle({
    Title = "绕过 Jeffrey",
    Desc  = "Jeffrey 靠近时直接拉开 60 格，避免被追",
    Value = AUTO.BypassJeffrey,
    Callback = function(v) AUTO.BypassJeffrey = v end,
})

SecJeffrey:Toggle({
    Title = "Anti Jeffrey",
    Desc  = "Jeffrey 靠近时自动弹开一段距离",
    Value = AUTO.AntiJeffrey,
    Callback = function(v) AUTO.AntiJeffrey = v end,
})

SecJeffrey:Slider({
    Title = "Jeffrey 检测范围",
    Desc  = "进入这个距离就处理",
    Value = { Min = 10, Max = 200, Default = AUTO.AntiJeffreyRange },
    Step = 5,
    Callback = function(v) AUTO.AntiJeffreyRange = v end,
})

local SecFlush = MainTab:Section({ Title = "冲刷设置", Icon = "droplets" })

SecFlush:Toggle({
    Title = "自动冲刷光环",
    Desc  = "自动激活附近的冲刷 / 马桶交互",
    Value = AUTO.FlushAura,
    Callback = function(v) AUTO.FlushAura = v end,
})

SecFlush:Slider({
    Title = "冲刷范围",
    Desc  = "光环覆盖半径",
    Value = { Min = 1, Max = 15, Default = AUTO.FlushAuraRange },
    Step = 1,
    Callback = function(v) AUTO.FlushAuraRange = v end,
})

local SecFlow = MainTab:Section({ Title = "流程设置", Icon = "list" })

SecFlow:Toggle({
    Title = "自动打开投票界面",
    Desc  = "大厅自动打开投票 GUI（相当于你自己点界面）",
    Value = AUTO.AutoOpenVote,
    Callback = function(v) AUTO.AutoOpenVote = v end,
})

SecFlow:Toggle({
    Title = "自动投票",
    Desc  = "自动把票投给当前票数最高的模式，全没票就投 Normal",
    Value = AUTO.AutoVote,
    Callback = function(v) AUTO.AutoVote = v end,
})

SecFlow:Toggle({
    Title = "自动准备（点 UI）",
    Desc  = "自动点击新版 UI 的准备按钮（点不动才发底层遥控）",
    Value = AUTO.AutoReady,
    Callback = function(v) AUTO.AutoReady = v end,
})

SecFlow:Toggle({
    Title = "自动开单人局",
    Desc  = "投完票直接发起单人开局（StartSolo），不等别人",
    Value = AUTO.AutoStart,
    Callback = function(v) AUTO.AutoStart = v end,
})

SecFlow:Toggle({
    Title = "结算自动继续",
    Desc  = "结算界面自动准备下一局",
    Value = AUTO.AutoContinue,
    Callback = function(v) AUTO.AutoContinue = v end,
})

SecFlow:Toggle({
    Title = "自动跳波投票",
    Desc  = "跳波投票界面出现时自动跟票",
    Value = AUTO.AutoSkipVote,
    Callback = function(v) AUTO.AutoSkipVote = v end,
})

SecFlow:Toggle({
    Title = "自动装备所选角色",
    Desc  = "大厅自动装备「玩家」页下拉框里选的角色",
    Value = AUTO.AutoEquipChar,
    Callback = function(v) AUTO.AutoEquipChar = v end,
})

local SecTask = MainTab:Section({ Title = "自动化任务", Icon = "clipboard-check" })

SecTask:Toggle({
    Title = "自动重新开局投票",
    Desc  = "结算后出现「重新开始」投票时自动投 Yes",
    Value = AUTO.AutoRestartVote,
    Callback = function(v) AUTO.AutoRestartVote = v end,
})

SecTask:Toggle({
    Title = "自动接取并完成小队任务",
    Desc  = "自动接取 G-Squad 任务，条件达成就自动交任务（需已解锁前置角色）",
    Value = AUTO.AutoSquadQuest,
    Callback = function(v) AUTO.AutoSquadQuest = v end,
})

SecTask:Toggle({
    Title = "自动升级技能树",
    Desc  = "自动把技能树里已解锁的技能点满（前提：钱够）",
    Value = AUTO.AutoSkillTree,
    Callback = function(v) AUTO.AutoSkillTree = v end,
})

SecTask:Toggle({
    Title = "自动使用金钱袋",
    Desc  = "自动使用背包里的金钱袋（UseItems Money）",
    Value = AUTO.AutoUseMoney,
    Callback = function(v) AUTO.AutoUseMoney = v end,
})

SecTask:Toggle({
    Title = "自动续开加速卡",
    Desc  = "自动使用下面选好的加速卡（Boosts）",
    Value = AUTO.AutoBoost,
    Callback = function(v) AUTO.AutoBoost = v end,
})

SecTask:Dropdown({
    Title = "加速卡类型",
    Desc  = "选一个要自动续开的加速卡",
    Values = {
        "Booster X2 Mastery : 30Min",
        "Booster X2 Mastery : 1Hour",
        "Booster X2 Mastery : 6Hour",
        "Booster X2 Points : 30Min",
        "Booster X2 Points : 1Hour",
        "Booster X2 Points : 6Hour",
    },
    Multi = false,
    Value = AUTO.BoostName,
    Callback = function(v) if v then AUTO.BoostName = v end end,
})

SecTask:Button({
    Title = "立即接取并完成小队任务",
    Desc  = "手动跑一次小队任务流程",
    Icon  = "clipboard-check",
    Callback = function()
        if AUTO.Actions.SquadQuest then AUTO.Actions.SquadQuest() end
    end,
})

SecTask:Button({
    Title = "立即升级技能树",
    Desc  = "手动跑一次技能树升级",
    Icon  = "trending-up",
    Callback = function()
        if AUTO.Actions.SkillTree then AUTO.Actions.SkillTree() end
    end,
})

SecTask:Button({
    Title = "立即使用金钱袋",
    Desc  = "手动用一次金钱袋",
    Icon  = "coins",
    Callback = function()
        if AUTO.Actions.UseMoney then AUTO.Actions.UseMoney() end
    end,
})

SecTask:Button({
    Title = "立即开加速卡",
    Desc  = "手动用一次上面选的加速卡",
    Icon  = "zap",
    Callback = function()
        if AUTO.Actions.Boost then AUTO.Actions.Boost() end
    end,
})

SecTask:Button({
    Title = "立即投重新开始票",
    Desc  = "当前有重开投票时立刻投 Yes",
    Icon  = "rotate-cw",
    Callback = function()
        if AUTO.Actions.RestartVote then AUTO.Actions.RestartVote() end
    end,
})

local SecGeneral = MainTab:Section({ Title = "常规设置", Icon = "wrench" })

SecGeneral:Toggle({
    Title = "防踢",
    Desc  = "挂机时防止被服务器踢出",
    Value = AUTO.AntiAfk,
    Callback = function(v) AUTO.AntiAfk = v end,
})

SecGeneral:Toggle({
    Title = "自动跳过直升机",
    Desc  = "直升机过场界面出现时自动跳过",
    Value = AUTO.AutoSkipHeli,
    Callback = function(v) AUTO.AutoSkipHeli = v end,
})

SecGeneral:Toggle({
    Title = "自动游戏设置",
    Desc  = "自动打开游戏内快速过场等设置开关",
    Value = AUTO.AutoSettings,
    Callback = function(v) AUTO.AutoSettings = v end,
})

SecGeneral:Toggle({
    Title = "自动跳波设置",
    Desc  = "自动打开游戏内的自动跳波开关",
    Value = AUTO.AutoSkip,
    Callback = function(v) AUTO.AutoSkip = v end,
})

local SecExt = MainTab:Section({ Title = "扩展自动化（100+）", Icon = "sparkles" })

local EXT_TOGGLES = {
    -- 战斗
    { "AutoAimLead", "预判瞄准", "按目标速度打提前量" },
    { "AutoDodgeZone", "危险区躲避", "检测红色危险区并躲开" },
    { "AutoInterrupt", "打断施法", "敌人读条时打断" },
    { "AutoTauntBoss", "嘲讽 Boss", "把 Boss 仇恨拉到自己身上" },
    { "AutoTeamBuff", "团队增益", "定时给全队上增益" },
    { "AutoShieldAlly", "给队友护盾", "队友低血时套盾" },
    { "AutoLastStand", "濒死爆发", "低血时开爆发技能" },
    { "AutoThreatTable", "仇恨统计", "统计怪物仇恨目标" },
    { "AutoAntiFling", "防击飞", "被击飞时拉回原位" },
    { "AutoPatrol", "自动巡逻", "没怪时按路线巡逻" },
    { "AutoReturnHome", "自动回撤", "跑太远自动回刷怪点" },
    { "AutoKillConfirm", "击杀确认", "确认目标死亡再换目标" },
    { "AutoSelfRevive", "自我复活", "倒地后自动用复活" },
    { "AutoWeaponDurability", "武器耐久", "耐久低自动换武器" },
    { "AutoBossPhase", "Boss 阶段提示", "Boss 换阶段时提示" },
    { "AutoCrouchDodge", "下蹲躲弹", "远程弹幕来时下蹲" },
    -- 补给 / 治疗
    { "AutoFood", "自动进食", "血低自动吃食物" },
    { "AutoBandage", "自动绷带", "血低自动用绷带" },
    { "AutoShieldItem", "自动护盾道具", "血低自动用护盾道具" },
    { "AutoCleanse", "自动净化", "中负面状态自动净化" },
    { "AutoPotionCombo", "药水连招", "按顺序连喝药水" },
    { "AutoAntiVoid", "防掉虚空", "快掉出地图时拉回" },
    { "AutoFallGuard", "坠落保护", "高空坠落前减速" },
    { "AutoBurnGuard", "燃烧保护", "着火时自动处理" },
    { "AutoStatusWatch", "状态监控", "监控所有负面状态" },
    { "AutoBuffRefresh", "增益刷新", "增益快过期时重刷" },
    { "AutoArmorRepair", "护甲修理", "护甲耐久低自动修" },
    { "AutoShieldRegenWait", "护盾回充等待", "等护盾回满再上" },
    { "AutoOutOfCombatRegen", "脱战回血", "脱战后自动回血" },
    { "AutoUseBuffConsumable", "自动用增益道具", "开打前吃增益消耗品" },
    -- 技能 / 科技点
    { "AutoSkillPriority", "技能优先级", "按优先级放技能" },
    { "AutoTechSpend", "科技点自动花", "有科技点就按策略花" },
    { "AutoUnlockCheap", "优先解锁便宜", "科技树先点便宜的" },
    { "AutoSaveTech", "攒科技点", "攒到阈值再花" },
    { "AutoPrestigeCheck", "转生检查", "满足条件自动转生" },
    { "AutoPassiveToggle", "被动开关", "自动开关被动技能" },
    { "AutoSkillQueue", "技能排队", "按队列连续放技能" },
    { "AutoUltimateTracker", "大招追踪", "追踪大招冷却" },
    { "AutoManaCheck", "蓝量检查", "蓝不够不放技能" },
    { "AutoSkillPointScan", "技能点扫描", "扫描可用的技能点" },
    -- 任务 / 经济
    { "AutoQuestAccept", "自动接任务", "自动接取可用任务" },
    { "AutoQuestComplete", "自动交任务", "完成后自动提交" },
    { "AutoDailyClaim", "每日领取", "自动领每日奖励" },
    { "AutoWeeklyClaim", "每周领取", "自动领每周奖励" },
    { "AutoSellJunk", "自动卖垃圾", "自动卖掉垃圾物品" },
    { "AutoBudgetBuy", "预算购买", "在预算内自动购物" },
    { "AutoRestock", "自动补货", "消耗品不足自动补" },
    { "AutoCrateOpen", "自动开箱", "有箱子就开" },
    { "AutoGachaPlan", "抽卡规划", "按规划抽卡" },
    { "AutoMoneyPickup", "自动捡钱", "自动拾取掉落金钱" },
    { "AutoShopScan", "商店扫描", "扫描商店好货" },
    { "AutoDiscountBuy", "折扣购买", "打折时自动买" },
    { "AutoFreeChest", "免费宝箱", "免费宝箱自动领" },
    { "AutoMailClaim", "邮件领取", "自动领取邮件附件" },
    { "AutoAchievementClaim", "成就领取", "自动领成就奖励" },
    { "AutoSeasonPassClaim", "通行证领取", "自动领通行证奖励" },
    -- 场景 / 互动
    { "AutoInteractPrompts", "自动互动", "自动按附近交互提示" },
    { "AutoChestHunt", "自动找箱子", "全图找宝箱" },
    { "AutoNPCTalk", "自动对话 NPC", "自动和 NPC 对话" },
    { "AutoElevatorUse", "自动坐电梯", "自动使用电梯" },
    { "AutoOrbCollect", "自动捡球", "自动捡理智球/能量球" },
    { "AutoStuckDetect", "卡住检测", "卡住自动脱困" },
    { "AutoFollowAlly", "跟随队友", "跟随最近的队友" },
    { "AutoStayInZone", "保持区域", "离开区域自动回来" },
    { "AutoOpenAllPrompts", "自动开所有提示", "见提示就按" },
    { "AutoDoorOpen", "自动开门", "自动开沿途的门" },
    { "AutoRescueNearby", "救援附近", "救附近倒地的队友" },
}

for _, it in ipairs(EXT_TOGGLES) do
    local key = it[1]
    SecExt:Toggle({
        Title = it[2],
        Desc  = it[3] .. "（" .. key .. "）",
        Value = AUTO[key] == true,
        Callback = function(v) AUTO[key] = v end,
    })
end

local SecStatus = MainTab:Section({
    Title = "运行状态",
    Desc  = "实时数据（每秒刷新）",
    Icon  = "activity",
})

local StatusPara = SecStatus:Paragraph({
    Title = "实时数据",
    Desc  = "正在读取游戏数据...",
})

-- ====================== 透视 ======================
local SecEsp = EspTab:Section({ Title = "透视设置", Icon = "eye" })

SecEsp:Toggle({
    Title = "启用透视",
    Desc  = "透视总开关，关掉后下面所有高亮全部清理",
    Value = AUTO.ESPEnable,
    Callback = function(v) AUTO.ESPEnable = v end,
})

SecEsp:Toggle({
    Title = "敌人透视",
    Desc  = "给敌人模型加红色高亮，关闭后自动清理",
    Value = AUTO.ESP,
    Callback = function(v) AUTO.ESP = v end,
})

SecEsp:Toggle({
    Title = "玩家透视",
    Desc  = "给其他玩家模型加绿色高亮",
    Value = AUTO.ESPPlayer,
    Callback = function(v) AUTO.ESPPlayer = v end,
})

SecEsp:Toggle({
    Title = "队友透视",
    Desc  = "给同阵营队友加绿色高亮，关闭后自动清理",
    Value = AUTO.ESPAlly,
    Callback = function(v) AUTO.ESPAlly = v end,
})

SecEsp:Toggle({
    Title = "物品透视",
    Desc  = "给下面选中的物品加金色高亮",
    Value = AUTO.ESPItem,
    Callback = function(v) AUTO.ESPItem = v end,
})

SecEsp:Dropdown({
    Title = "透视物品",
    Desc  = "选择要透视的物品（可多选）",
    Values = UI_VALUES.Collect,
    Multi = true,
    Value = uiDispList("Collect", AUTO.ESPItems),
    Callback = function(v) AUTO.ESPItems = uiEngList("Collect", v) end,
})

-- ====================== 玩家 ======================
local SecChar = PlayerTab:Section({
    Title = "玩家",
    Desc  = "角色自己选，脚本不判断强弱",
    Icon  = "user",
})

local _lp = game:GetService("Players").LocalPlayer
local charList = {}
do
    local ud = _lp and _lp:FindFirstChild("UnlockData")
    if ud then
        for _, c in ipairs(ud:GetChildren()) do
            table.insert(charList, c.Name)
        end
    end
    table.sort(charList)
    if #charList == 0 then
        charList = { "（进游戏后重新执行脚本即可读到角色）" }
    end
end

SecChar:Dropdown({
    Title = "选择要装备的角色",
    Desc  = "点开选择，选中后点下面按钮装备",
    Values = charList,
    Multi = false,
    Value = charList[1],
    Callback = function(v)
        if v and not string.find(v, "^（") then
            AUTO.Character = v
            AUTO.LastReason = "已选择角色：" .. v
            pcall(function()
                WindUI:Notify({ Title = "角色", Content = "已选择：" .. v, Duration = 2, Icon = "swords" })
            end)
        end
    end,
})

SecChar:Button({
    Title = "装备所选角色",
    Desc  = "立即用 ForChangeCharacter 换成下拉框里选的角色",
    Icon = "swords",
    Callback = function()
        if AUTO.Character == "" then
            pcall(function()
                WindUI:Notify({ Title = "装备角色", Content = "请先在下拉框里选一个角色", Duration = 2, Icon = "swords" })
            end)
            return
        end
        if AUTO.Actions.Equip then AUTO.Actions.Equip() end
    end,
})

SecChar:Button({
    Title = "立即复活一次",
    Desc  = "手动触发一次重置重生",
    Icon  = "heart",
    Callback = function()
        if AUTO.Actions.Respawn then AUTO.Actions.Respawn() end
    end,
})

local SecTitle = PlayerTab:Section({ Title = "称号", Icon = "award" })

SecTitle:Toggle({
    Title = "自动装备称号",
    Desc  = "大厅自动装备下面填写的称号",
    Value = AUTO.AutoTitle,
    Callback = function(v) AUTO.AutoTitle = v end,
})

SecTitle:Input({
    Title = "要装备的称号名称",
    Desc  = "填 TitlesFolder 里的称号名，例如某个已解锁称号",
    Default = AUTO.TitleName,
    Placeholder = "输入称号名",
    Callback = function(text)
        AUTO.TitleName = tostring(text or "")
    end,
})

SecTitle:Button({
    Title = "立即装备称号",
    Desc  = "按上面填的称号名发一次 Title 遥控",
    Icon  = "award",
    Callback = function()
        if AUTO.Actions.Title then AUTO.Actions.Title() end
    end,
})

local SecMove = PlayerTab:Section({ Title = "移动与角色", Icon = "move" })

SecMove:Slider({
    Title = "移动速度",
    Desc  = "锁定移动时使用的 WalkSpeed",
    Value = { Min = 1, Max = 300, Default = AUTO.WalkSpeed },
    Step = 1,
    Callback = function(v) AUTO.WalkSpeed = v end,
})

SecMove:Slider({
    Title = "跳跃力",
    Desc  = "锁定移动时使用的 JumpPower",
    Value = { Min = 1, Max = 500, Default = AUTO.JumpPower },
    Step = 1,
    Callback = function(v) AUTO.JumpPower = v end,
})

SecMove:Toggle({
    Title = "锁定移动属性",
    Desc  = "持续把移动速度 / 跳跃力锁在上面设置的值",
    Value = AUTO.LockMoveStats,
    Callback = function(v) AUTO.LockMoveStats = v end,
})

SecMove:Toggle({
    Title = "无碰撞",
    Desc  = "穿墙（关闭角色所有部件碰撞）",
    Value = AUTO.NoClip,
    Callback = function(v) AUTO.NoClip = v end,
})

SecMove:Toggle({
    Title = "飞行",
    Desc  = "空格上升 / Ctrl 下降，飞行时角色不受重力",
    Value = AUTO.Fly,
    Callback = function(v) AUTO.Fly = v end,
})

SecMove:Slider({
    Title = "飞行速度",
    Desc  = "实际速度 = 该值 x 50",
    Value = { Min = 1, Max = 20, Default = AUTO.FlySpeed },
    Step = 1,
    Callback = function(v) AUTO.FlySpeed = v end,
})

SecMove:Slider({
    Title = "飞行升降速度",
    Desc  = "空格 / Ctrl 时的垂直速度",
    Value = { Min = 1, Max = 50, Default = AUTO.FlyHeight },
    Step = 1,
    Callback = function(v) AUTO.FlyHeight = v end,
})

SecMove:Toggle({
    Title = "无限跳跃",
    Desc  = "空中也能继续跳",
    Value = AUTO.InfiniteJump,
    Callback = function(v) AUTO.InfiniteJump = v end,
})

SecMove:Toggle({
    Title = "全亮",
    Desc  = "提高亮度、关闭阴影与部分后期特效",
    Value = AUTO.FullBright,
    Callback = function(v) AUTO.FullBright = v end,
})

SecMove:Toggle({
    Title = "无雾",
    Desc  = "去掉地图雾气，远距离也看得清",
    Value = AUTO.NoFog,
    Callback = function(v) AUTO.NoFog = v end,
})

SecMove:Toggle({
    Title = "绕过屏障",
    Desc  = "关闭隐形墙 / Barrier 的碰撞",
    Value = AUTO.NoBarrier,
    Callback = function(v) AUTO.NoBarrier = v end,
})

SecMove:Dropdown({
    Title = "相机模式",
    Desc  = "经典 = 游戏原版，手动 = 固定跟随视角",
    Values = UI_VALUES.Camera,
    Multi = false,
    Value = uiDisp("Camera", AUTO.CameraMode),
    Callback = function(v) if v then AUTO.CameraMode = uiEng("Camera", v) end end,
})

local REDEEM_CODES = {
    "100MVisit2", "100MVisit1", "CamArmada", "CCTVBase",
    "ADelayedGameIsEventuallyGoodButRushedGameIsForeverBad",
}

local SecCode = PlayerTab:Section({ Title = "兑换码", Icon = "ticket" })

SecCode:Dropdown({
    Title = "选择兑换码",
    Desc  = "可多选，然后点兑换",
    Values = REDEEM_CODES,
    Multi = true,
    Value = AUTO.SelectedCodes,
    Callback = function(v) AUTO.SelectedCodes = v or {} end,
})

SecCode:Button({
    Title = "兑换选中的码",
    Desc  = "提交下拉框里选中的兑换码",
    Icon  = "ticket",
    Callback = function()
        if AUTO.Actions.Redeem then AUTO.Actions.Redeem() end
    end,
})

SecCode:Button({
    Title = "兑换全部兑换码",
    Desc  = "一次性提交脚本内置的全部兑换码",
    Icon  = "gift",
    Callback = function()
        if AUTO.Actions.RedeemAll then AUTO.Actions.RedeemAll() end
    end,
})

local SecPass = PlayerTab:Section({ Title = "通行证", Icon = "crown" })

SecPass:Dropdown({
    Title = "选择通行证",
    Desc  = "客户端解锁（本地标记）",
    Values = UI_VALUES.Pass,
    Multi = true,
    Value = uiDispList("Pass", AUTO.SelectedPasses),
    Callback = function(v) AUTO.SelectedPasses = uiEngList("Pass", v) end,
})

SecPass:Button({
    Title = "解锁所选通行证",
    Desc  = "在本地 GachaData 里写入对应开关",
    Icon  = "crown",
    Callback = function()
        if AUTO.Actions.UnlockPass then AUTO.Actions.UnlockPass() end
    end,
})

-- ====================== 商店 ======================
local SecShop = ShopTab:Section({ Title = "商店", Icon = "shopping-cart" })

SecShop:Paragraph({
    Title = "说明",
    Desc  = "商店类自动化默认全关，需要时自己打开。",
})

SecShop:Toggle({
    Title = "低血自动买补血",
    Desc  = "血量低于复活阈值时自动在商店买补血（ShopSystem Buy FillHP）",
    Value = AUTO.AutoBuyHP,
    Callback = function(v) AUTO.AutoBuyHP = v end,
})

SecShop:Toggle({
    Title = "低血自动喝药水",
    Desc  = "血量低于复活阈值时自动使用背包里的药水（Potions）",
    Value = AUTO.AutoPotion,
    Callback = function(v) AUTO.AutoPotion = v end,
})

SecShop:Dropdown({
    Title = "药水类型",
    Desc  = "选择自动喝哪种药水",
    Values = { "Potion", "Potion II", "Potion III" },
    Multi = false,
    Value = AUTO.PotionName,
    Callback = function(v) if v then AUTO.PotionName = v end end,
})

SecShop:Button({
    Title = "立即买补血",
    Desc  = "马上买一次补血",
    Icon  = "heart",
    Callback = function()
        if AUTO.Actions.BuyHP then AUTO.Actions.BuyHP() end
    end,
})

-- ---------------- 角色 / 皮肤扭蛋 ----------------
local SecGacha = ShopTab:Section({ Title = "角色扭蛋", Icon = "dice" })

SecGacha:Toggle({
    Title = "自动抽角色",
    Desc  = "大厅自动用抽奖遥控抽角色，档位在下面选",
    Value = AUTO.AutoGachaChar,
    Callback = function(v) AUTO.AutoGachaChar = v end,
})

SecGacha:Toggle({
    Title = "自动抽皮肤",
    Desc  = "大厅自动用抽奖遥控抽皮肤，档位在下面选",
    Value = AUTO.AutoGachaSkin,
    Callback = function(v) AUTO.AutoGachaSkin = v end,
})

SecGacha:Dropdown({
    Title = "抽奖档位",
    Desc  = "选择自动抽奖使用的档位",
    Values = UI_VALUES.Gacha,
    Multi = false,
    Value = uiDisp("Gacha", AUTO.GachaSpin),
    Callback = function(v) if v then AUTO.GachaSpin = uiEng("Gacha", v) end end,
})

SecGacha:Button({
    Title = "立即抽一次",
    Desc  = "按上面选的档位手动抽一次（角色+皮肤）",
    Icon  = "dice",
    Callback = function()
        if AUTO.Actions.Gacha then AUTO.Actions.Gacha() end
    end,
})

-- ---------------- 使用物品 ----------------
local SecUseItem = ShopTab:Section({ Title = "使用物品", Icon = "package" })

SecUseItem:Toggle({
    Title = "自动使用物品",
    Desc  = "自动使用背包里的礼物（开扭蛋胶囊）",
    Value = AUTO.AutoUseItem,
    Callback = function(v) AUTO.AutoUseItem = v end,
})

SecUseItem:Toggle({
    Title = "自动开胶囊",
    Desc  = "自动使用背包里的扭蛋胶囊（GachaCapsule）",
    Value = AUTO.AutoCapsule,
    Callback = function(v) AUTO.AutoCapsule = v end,
})

SecUseItem:Dropdown({
    Title = "要使用的物品",
    Desc  = "目前支持：礼物",
    Values = UI_VALUES.UseItem,
    Multi = false,
    Value = uiDisp("UseItem", AUTO.UseItemName),
    Callback = function(v) if v then AUTO.UseItemName = uiEng("UseItem", v) end end,
})

SecUseItem:Button({
    Title = "立即使用物品",
    Desc  = "马上用一次上面选中的物品",
    Icon  = "package",
    Callback = function()
        if AUTO.Actions.UseItem then AUTO.Actions.UseItem() end
    end,
})

-- ---------------- 商店升级 ----------------
local SecUpgrade = ShopTab:Section({ Title = "商店升级", Icon = "arrow-up" })

SecUpgrade:Toggle({
    Title = "自动升级泰坦扬声器",
    Desc  = "按下面选中的项目自动升级",
    Value = AUTO.UpgradeTitanSpeaker,
    Callback = function(v) AUTO.UpgradeTitanSpeaker = v end,
})

SecUpgrade:Dropdown({
    Title = "泰坦扬声器升级项",
    Desc  = "可多选",
    Values = UI_VALUES.Titan,
    Multi = true,
    Value = uiDispList("Titan", AUTO.TitanUpgrades),
    Callback = function(v) AUTO.TitanUpgrades = uiEngList("Titan", v) end,
})

SecUpgrade:Toggle({
    Title = "自动升级 UTCM",
    Desc  = "按下面选中的项目自动升级",
    Value = AUTO.UpgradeUTCM,
    Callback = function(v) AUTO.UpgradeUTCM = v end,
})

SecUpgrade:Dropdown({
    Title = "UTCM 升级项",
    Desc  = "可多选",
    Values = UI_VALUES.UTCM,
    Multi = true,
    Value = uiDispList("UTCM", AUTO.UTCMUpgrades),
    Callback = function(v) AUTO.UTCMUpgrades = uiEngList("UTCM", v) end,
})

SecUpgrade:Toggle({
    Title = "自动升级 TV",
    Desc  = "按下面选中的项目自动升级",
    Value = AUTO.UpgradeTV,
    Callback = function(v) AUTO.UpgradeTV = v end,
})

SecUpgrade:Dropdown({
    Title = "TV 升级项",
    Desc  = "可多选",
    Values = UI_VALUES.TV,
    Multi = true,
    Value = uiDispList("TV", AUTO.TVUpgrades),
    Callback = function(v) AUTO.TVUpgrades = uiEngList("TV", v) end,
})

-- ---------------- 商店武器 ----------------
local SecWeapon = ShopTab:Section({ Title = "商店武器", Icon = "swords" })

SecWeapon:Toggle({
    Title = "自动购买武器",
    Desc  = "商店出现时自动买下面选中的武器",
    Value = AUTO.AutoBuyWeapon,
    Callback = function(v) AUTO.AutoBuyWeapon = v end,
})

SecWeapon:Dropdown({
    Title = "武器类型",
    Desc  = "选择要自动购买的武器",
    Values = UI_VALUES.Weapon,
    Multi = false,
    Value = uiDisp("Weapon", AUTO.WeaponName),
    Callback = function(v) if v then AUTO.WeaponName = uiEng("Weapon", v) end end,
})

SecWeapon:Button({
    Title = "立即购买武器",
    Desc  = "马上买一次上面选中的武器",
    Icon  = "swords",
    Callback = function()
        if AUTO.Actions.BuyWeapon then AUTO.Actions.BuyWeapon() end
    end,
})

-- ---------------- 商店杂项 ----------------
local SecMisc = ShopTab:Section({ Title = "商店杂项", Icon = "box" })

SecMisc:Toggle({
    Title = "自动购买杂项",
    Desc  = "商店出现时自动买下面选中的杂项",
    Value = AUTO.AutoBuyMisc,
    Callback = function(v) AUTO.AutoBuyMisc = v end,
})

SecMisc:Dropdown({
    Title = "杂项类型",
    Desc  = "选择要自动购买的杂项",
    Values = UI_VALUES.Misc,
    Multi = false,
    Value = uiDisp("Misc", AUTO.MiscName),
    Callback = function(v) if v then AUTO.MiscName = uiEng("Misc", v) end end,
})

SecMisc:Button({
    Title = "立即购买杂项",
    Desc  = "马上买一次上面选中的杂项",
    Icon  = "box",
    Callback = function()
        if AUTO.Actions.BuyMisc then AUTO.Actions.BuyMisc() end
    end,
})

-- ---------------- 请求 ----------------
local SecRequest = ShopTab:Section({ Title = "请求", Icon = "megaphone" })

SecRequest:Toggle({
    Title = "自动请求",
    Desc  = "第 10 波以后自动发起请求",
    Value = AUTO.AutoRequest,
    Callback = function(v) AUTO.AutoRequest = v end,
})

SecRequest:Dropdown({
    Title = "请求类型",
    Desc  = "选择要自动请求的内容",
    Values = UI_VALUES.Request,
    Multi = false,
    Value = uiDisp("Request", AUTO.RequestName),
    Callback = function(v) if v then AUTO.RequestName = uiEng("Request", v) end end,
})

SecRequest:Button({
    Title = "立即请求",
    Desc  = "马上发起一次请求（需第 10 波后）",
    Icon  = "megaphone",
    Callback = function()
        if AUTO.Actions.BuyRequest then AUTO.Actions.BuyRequest() end
    end,
})

-- ---------------- 小时购 ----------------
local SecHourly = ShopTab:Section({ Title = "小时购", Icon = "clock" })

SecHourly:Toggle({
    Title = "自动购买小时购",
    Desc  = "自动购买下面选中的小时购物品",
    Value = AUTO.AutoHourly,
    Callback = function(v) AUTO.AutoHourly = v end,
})

SecHourly:Dropdown({
    Title = "小时购物品",
    Desc  = "可多选",
    Values = UI_VALUES.Hourly,
    Multi = true,
    Value = uiDispList("Hourly", AUTO.HourlyItems),
    Callback = function(v) AUTO.HourlyItems = uiEngList("Hourly", v) end,
})

SecHourly:Slider({
    Title = "购买数量",
    Desc  = "每个物品一次买几个",
    Value = { Min = 1, Max = 10, Default = AUTO.HourlyAmount },
    Step = 1,
    Callback = function(v) AUTO.HourlyAmount = v end,
})

SecHourly:Input({
    Title = "自定义物品名",
    Desc  = "填了就会额外尝试购买这个物品名",
    Value = AUTO.HourlyCustom,
    Callback = function(v) AUTO.HourlyCustom = v or "" end,
})

SecHourly:Button({
    Title = "立即购买小时购",
    Desc  = "马上买一次上面选中的物品",
    Icon  = "clock",
    Callback = function()
        if AUTO.Actions.BuyHourly then AUTO.Actions.BuyHourly() end
    end,
})

-- ====================== 收集 ======================
local SecCollect = CollectTab:Section({ Title = "自动收集", Icon = "hand" })

SecCollect:Button({
    Title = "一键领取所有奖励",
    Desc  = "领取每日登录 / 团队奖励，并点掉界面上所有可领取按钮",
    Icon  = "gift",
    Callback = function()
        if AUTO.Actions.Claim then AUTO.Actions.Claim() end
    end,
})

SecCollect:Toggle({
    Title = "自动领每日登录奖励",
    Desc  = "进大厅后自动领每日登录奖励（LoginRemote）",
    Value = AUTO.AutoClaimLogin,
    Callback = function(v) AUTO.AutoClaimLogin = v end,
})

SecCollect:Toggle({
    Title = "自动领团队奖励",
    Desc  = "进大厅后自动领团队奖励（GroupRewardRemote）",
    Value = AUTO.AutoClaimGroup,
    Callback = function(v) AUTO.AutoClaimGroup = v end,
})

SecCollect:Toggle({
    Title = "自动点领取按钮",
    Desc  = "自动点击界面上出现 Claim / Collect / 领取 字样的按钮",
    Value = AUTO.AutoClickClaim,
    Callback = function(v) AUTO.AutoClickClaim = v end,
})

SecCollect:Toggle({
    Title = "自动收集",
    Desc  = "战斗中用「收集模式 / 移动方式」自动捡下面的物品",
    Value = AUTO.AutoCollect,
    Callback = function(v) AUTO.AutoCollect = v end,
})

SecCollect:Dropdown({
    Title = "收集物品",
    Desc  = "可多选要自动收集的物品",
    Values = UI_VALUES.Collect,
    Multi = true,
    Value = uiDispList("Collect", AUTO.CollectItems),
    Callback = function(v) AUTO.CollectItems = uiEngList("Collect", v) end,
})

SecCollect:Dropdown({
    Title = "收集模式",
    Desc  = "清洁 / IDGF",
    Values = UI_VALUES.CollectMode,
    Multi = false,
    Value = uiDisp("CollectMode", AUTO.CollectMode),
    Callback = function(v) if v then AUTO.CollectMode = uiEng("CollectMode", v) end end,
})

SecCollect:Dropdown({
    Title = "移动方式",
    Desc  = "传送 = 瞬移过去，补间 = 平滑移动",
    Values = UI_VALUES.Move,
    Multi = false,
    Value = uiDisp("Move", AUTO.CollectMove),
    Callback = function(v) if v then AUTO.CollectMove = uiEng("Move", v) end end,
})

SecCollect:Button({
    Title = "立即收集一次",
    Desc  = "手动收集最近的一个目标",
    Icon  = "hand",
    Callback = function()
        if AUTO.Actions.CollectOnce then AUTO.Actions.CollectOnce() end
    end,
})

-- ====================== 游戏模式 ======================
local SecMode = ModeTab:Section({
    Title = "投票信息",
    TextXAlignment = "Center",
    TextSize = 17,
})

SecMode:Paragraph({
    Title = "自动投票",
    Desc  = "大厅自动读 workspace.Vote 的实时票数，把票投给票数最高的模式；全都没票就投 Normal。投票界面由脚本自己打开、投完自己收起。",
})

SecMode:Paragraph({
    Title = "自动开局",
    Desc  = "投完票直接发起单人开局（StartSolo），不用等别人、不用等倒计时。",
})

local SecMode2 = ModeTab:Section({ Title = "设置游戏模式", Icon = "gamepad" })

SecMode2:Button({
    Title = "立即投票",
    Desc  = "马上按当前票数最高的模式投一票",
    Icon = "check",
    Callback = function()
        if AUTO.Actions.Vote then AUTO.Actions.Vote() end
    end,
})

SecMode2:Button({
    Title = "立即准备",
    Desc  = "立刻点一次新版 UI 准备按钮",
    Icon = "house",
    Callback = function()
        if AUTO.Actions.Ready then AUTO.Actions.Ready() end
    end,
})

SecMode2:Button({
    Title = "立即开单人局",
    Desc  = "立刻发起单人开局（StartSolo）",
    Icon = "rocket",
    Callback = function()
        if AUTO.Actions.StartSolo then AUTO.Actions.StartSolo() end
    end,
})

SecMode2:Dropdown({
    Title = "设置投票模式",
    Desc  = "指定要投的模式；不选则自动投票数最高的",
    Values = UI_VALUES.Vote,
    Multi = false,
    Value = (AUTO.VoteMode ~= "" and uiDisp("Vote", AUTO.VoteMode)) or nil,
    Callback = function(v)
        if v then AUTO.VoteMode = uiEng("Vote", v) end
    end,
})

SecMode2:Toggle({
    Title = "局内自动投票",
    Desc  = "战斗中出现投票界面时也自动跟票",
    Value = AUTO.AutoVoteInGame,
    Callback = function(v) AUTO.AutoVoteInGame = v end,
})

SecMode2:Dropdown({
    Title = "设置游戏模式",
    Desc  = "大厅要应用的游戏模式",
    Values = UI_VALUES.GameMode,
    Multi = false,
    Value = (AUTO.GameMode ~= "" and uiDisp("GameMode", AUTO.GameMode)) or nil,
    Callback = function(v)
        if v then AUTO.GameMode = uiEng("GameMode", v) end
    end,
})

SecMode2:Button({
    Title = "应用游戏模式",
    Desc  = "把上面的游戏模式设为自动投票目标",
    Icon = "gamepad",
    Callback = function()
        if AUTO.Actions.ApplyGameMode then AUTO.Actions.ApplyGameMode() end
    end,
})

SecMode2:Toggle({
    Title = "自动游戏模式（大厅）",
    Desc  = "大厅里持续把投票目标锁定到上面设置的模式",
    Value = AUTO.AutoGameModeLobby,
    Callback = function(v) AUTO.AutoGameModeLobby = v end,
})

SecMode2:Button({
    Title = "恢复投票系统",
    Desc  = "重新打开投票界面并恢复 Play 按钮显示",
    Icon = "rotate-cw",
    Callback = function()
        if AUTO.Actions.RestoreVote then AUTO.Actions.RestoreVote() end
    end,
})

-- ====================== 设置 ======================
local SecSave = SettingsTab:Section({ Title = "保存配置", Icon = "save" })

SecSave:Toggle({
    Title = "自动保存配置",
    Desc  = "按下面的间隔把当前开关保存到本地文件",
    Value = AUTO.AutoSave,
    Callback = function(v) AUTO.AutoSave = v end,
})

SecSave:Slider({
    Title = "自动保存间隔",
    Desc  = "秒",
    Value = { Min = 5, Max = 120, Default = AUTO.AutoSaveDelay },
    Step = 5,
    Callback = function(v) AUTO.AutoSaveDelay = v end,
})

SecSave:Button({
    Title = "立即保存配置",
    Desc  = "保存所有开关与参数到 难度模式_配置.json",
    Icon  = "save",
    Callback = function()
        if AUTO.Actions.SaveConfig then AUTO.Actions.SaveConfig() end
    end,
})

SecSave:Button({
    Title = "暂停 / 继续",
    Desc  = "暂停后不再瞄准、开火、放技能",
    Icon  = "pause",
    Callback = function()
        if AUTO.Actions.TogglePause then AUTO.Actions.TogglePause() end
    end,
})

SecSave:Button({
    Title = "停止并卸载脚本",
    Desc  = "关闭界面与所有自动化",
    Icon  = "power",
    Callback = function()
        AUTO.Running = false
        pcall(function() Window:Destroy() end)
    end,
})

local SecServer = SettingsTab:Section({ Title = "服务器状态", Icon = "server" })

SecServer:Button({
    Title = "环境自检",
    Desc = "检查角色 / 技能 / 敌人识别 / 遥控是否正常",
    Icon = "stethoscope",
    Callback = function()
        if AUTO.Actions.Diag then AUTO.Actions.Diag() end
    end,
})

SecServer:Button({
    Title = "跳转服务器",
    Desc = "随机找一个没满人的公共服务器并传送过去",
    Icon = "shuffle",
    Callback = function()
        if AUTO.Actions.JumpServer then AUTO.Actions.JumpServer() end
    end,
})

SecServer:Button({
    Title = "重新加入当前服务器",
    Desc = "重新连接本局服务器",
    Icon = "refresh-cw",
    Callback = function()
        if AUTO.Actions.Rejoin then AUTO.Actions.Rejoin() end
    end,
})

local SecDebug = SettingsTab:Section({ Title = "杂项", Icon = "wrench" })

SecDebug:Toggle({
    Title = "战斗调试",
    Desc = "把锁敌 / 刷怪 / 撤退等过程写进日志",
    Value = AUTO.CombatDebug,
    Callback = function(v) AUTO.CombatDebug = v end,
})

local SecLog = SettingsTab:Section({
    Title = "运行日志",
    Desc  = "最近 14 条",
    Icon  = "file-text",
})

local LogPara = SecLog:Paragraph({
    Title = "日志",
    Desc  = "等待引擎启动...",
})

print("[难度模式 自动化] 界面已加载，所有功能默认关闭，请手动打开需要的开关")

-- ============================================================
-- 常用服务（导出给引擎使用）
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
-- 导出给引擎使用
-- ============================================================
local __UI_EXPORT = {
    AUTO               = AUTO,
    WindUI             = WindUI,
    Window             = Window,
    Status             = StatusPara,
    Log                = LogPara,
    Players            = Players,
    TweenService       = TweenService,
    UserInputService   = UserInputService,
    RunService         = RunService,
    player             = player,
    camera             = camera,
}
return __UI_EXPORT
end)()

local AUTO             = UI.AUTO
local WindUI           = UI.WindUI
local Window           = UI.Window
local StatusPara       = UI.Status
local LogPara          = UI.Log
local Players          = UI.Players
local TweenService     = UI.TweenService
local UserInputService = UI.UserInputService
local RunService       = UI.RunService
local player           = UI.player
local camera           = UI.camera

if not AUTO then
    error("[难度模式] 界面初始化失败：没有拿到 AUTO 表")
end

-- 引擎侧默认值：链接 UI 是旧版、缺少新字段时也不会报错，功能仍需在菜单里手动开启
local ENGINE_DEFAULTS = {
    AutoFarm = false, FarmMode = "Normal Mode", FarmPos = "Above", FarmMove = "Teleport",
    CircleRadius = 6, FarmHeight = 3, TweenSpeed = 1, HighHp = 200,
    SkillDelay = 1, SafeHp = 30,
    GodMode = false, GodHp = 30, ResetWave = false, ResetWaveValue = 10,
    BypassJeffrey = false, AntiJeffrey = false, AntiJeffreyRange = 50,
    FlushAura = false, FlushAuraRange = 5,
    ESPPlayer = false, ESPItem = false, ESPItems = {},
    AutoBuyWeapon = false, WeaponName = "Stungun",
    AutoBuyMisc = false, MiscName = "HeadPhone",
    AutoRequest = false, RequestName = "Titan-Request",
    UpgradeTitanSpeaker = false, TitanUpgrades = {},
    UpgradeUTCM = false, UTCMUpgrades = {},
    UpgradeTV = false, TVUpgrades = {},
    AutoHourly = false, HourlyItems = {}, HourlyAmount = 1,
    AutoUseItem = false, UseItemName = "Presents",
    GachaSpin = "10Spins",
    NoClip = false, Fly = false, FlySpeed = 1, FlyHeight = 10,
    InfiniteJump = false, LockMoveStats = false, WalkSpeed = 16, JumpPower = 50,
    FullBright = false, NoFog = false, CameraMode = "Classic", NoBarrier = false,
    CombatDebug = false, AutoCollect = false, CollectItems = {},
    CollectMode = "Clean", CollectMove = "Teleport",
    AutoSave = false, AutoSaveDelay = 15, SelectedCodes = {}, SelectedPasses = {},
    AutoVoteInGame = false, GameMode = "Normal", AutoGameModeLobby = false,
    AutoAstroToken = false, RemoveMap = false,
    AntiAFK = true, AutoAstroFinalDoor = false,
}
for k, v in pairs(ENGINE_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

-- ============================================================
-- ▼▼ 难度模式 自动化引擎 ▼▼
-- 自动准备 → 自动战斗（锁敌 / 开火 / 技能）→ 自动救人 → 结算自动继续
-- 全部通过游戏本身已有的 Remote 与 ProximityPrompt 实现
-- ============================================================
do

local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local pg = player:WaitForChild("PlayerGui")

-- 顶部拖动修复：搜索框会盖住标题栏的拖动区域，这里直接隐藏掉，标题栏就能正常拖
pcall(function()
    local hosts = { (gethui and gethui()) or game:GetService("CoreGui"), player:WaitForChild("PlayerGui") }
    for _, host in ipairs(hosts) do
        for _, gui in ipairs(host:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local bar = gui:FindFirstChild("SearchBar", true)
                if bar then
                    bar.Visible = false
                    bar.Active = false
                    local box = bar:FindFirstChildWhichIsA("TextBox", true)
                    if box then
                        box.Visible = false
                        box.Active = false
                    end
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- 基础工具
----------------------------------------------------------------
function log(msg)
    local line = os.date("%H:%M:%S") .. "  " .. tostring(msg)
    table.insert(AUTO.Logs, 1, line)
    while #AUTO.Logs > 14 do
        table.remove(AUTO.Logs)
    end
    print("[难度模式] " .. line)
end

function notify(title, text)
    pcall(function()
        WindUI:Notify({ Title = title, Content = tostring(text), Duration = 4 })
    end)
end

function findPath(root, names)
    local node = root
    for _, n in ipairs(names) do
        if not node then return nil end
        node = node:FindFirstChild(n)
    end
    return node
end

function deepVisible(obj)
    if not obj then return false end
    local cur = obj
    while cur and cur ~= game do
        if cur:IsA("GuiObject") and cur.Visible == false then return false end
        if cur:IsA("ScreenGui") and cur.Enabled == false then return false end
        cur = cur.Parent
    end
    return true
end

local clockTimes = {}
function every(key, gap)
    local now = os.clock()
    if (clockTimes[key] or 0) + gap <= now then
        clockTimes[key] = now
        return true
    end
    return false
end

-- 手动按钮用：清掉某个节流计时，让对应动作立刻执行
function resetClock(key)
    clockTimes[key] = 0
end

function nameOf(inst)
    return inst and inst.Name or "无"
end

function myChar()
    local c = player.Character
    if c and c.Parent then return c end
    return nil
end

function humOf(m)
    return m and m:FindFirstChildOfClass("Humanoid")
end

function hrpOf(m)
    if not m then return nil end
    return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
end

function living()
    return workspace:FindFirstChild("Living")
end

----------------------------------------------------------------
-- 阵营 / 敌人识别
----------------------------------------------------------------
local FactionShared = nil
do
    local mod = RS:FindFirstChild("FactionShared")
    if mod then
        local ok, res = pcall(require, mod)
        if ok then FactionShared = res end
    end
end

function isEnemy(m)
    if not m or not m:IsA("Model") then return false end
    local me = myChar()
    if m == me then return false end
    local h = humOf(m)
    if not h or h.Health <= 0 then return false end
    if FactionShared then
        local ok, res = pcall(FactionShared.IsEnemy, { Player = me, Target = m })
        if ok and res ~= nil then return res == true end
    end
    local mine = me and me:GetAttribute("Faction")
    local other = m:GetAttribute("Faction")
    if m:FindFirstChild("AI") then
        return mine ~= other
    end
    return false
end

local enemyCache = { t = 0, n = 0 }
function enemyCount()
    if os.clock() - enemyCache.t < 0.25 then
        return enemyCache.n
    end
    local folder = living()
    local n = 0
    if folder then
        for _, m in ipairs(folder:GetChildren()) do
            if isEnemy(m) then n = n + 1 end
        end
    end
    enemyCache.t = os.clock()
    enemyCache.n = n
    return n
end

function nearestEnemy(maxDist)
    local me = myChar()
    local base = hrpOf(me)
    if not base then return nil, nil end
    local folder = living()
    if not folder then return nil, nil end
    local best, bestD = nil, maxDist or math.huge
    for _, m in ipairs(folder:GetChildren()) do
        local skip = AUTO.AutoFarm and AUTO.FarmMode == "Astro Holdout Mode" and m.Name == "Giant ST toilet"
        if not skip and isEnemy(m) then
            local p = hrpOf(m)
            if p then
                local d = (p.Position - base.Position).Magnitude
                if d < bestD then
                    best, bestD = m, d
                end
            end
        end
    end
    return best, bestD
end

----------------------------------------------------------------
-- 瞄准 / 开火
----------------------------------------------------------------
local BotBridge = nil
function bot()
    if BotBridge and BotBridge.Enabled ~= nil then return BotBridge end
    local mod = RS:FindFirstChild("BotBridge")
    if not mod then return nil end
    local ok, res = pcall(require, mod)
    if ok and type(res) == "table" then
        BotBridge = res
        return res
    end
    return nil
end

function aimAt(pos)
    if not AUTO.AutoAim then return end
    local bb = bot()
    if bb then
        bb.Enabled = true
        bb.AimPosition = pos
    end
    -- 再直接补发一次准星数据，保证服务端一定收到我们锁定的位置
    local ms = RS:FindFirstChild("MouseStream")
    local cam = workspace.CurrentCamera
    if ms and cam then
        local dir = pos - cam.CFrame.Position
        if dir.Magnitude > 0 then
            dir = dir.Unit
        else
            dir = cam.CFrame.LookVector
        end
        pcall(function() ms:FireServer(pos, dir, false) end)
    end
end

function stopAim()
    local bb = bot()
    if bb then
        bb.Enabled = false
        bb.AimPosition = nil
    end
end

local holdingTool = nil
local lastActivate = 0
function ensureFire()
    if not AUTO.AutoFight then return end
    local c = myChar()
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return end
    local folder = tool:FindFirstChild("Folder")
    local hold = folder and folder:FindFirstChild("Hold")
    if hold then
        -- 连发武器：只要按住就行
        if holdingTool ~= tool then
            holdingTool = tool
            local sync = RS:FindFirstChild("HoldStateSync")
            if sync then
                pcall(function() sync:FireServer("Gun", true) end)
            end
        end
    else
        -- 近战 / 单发武器：按节奏触发
        if os.clock() - lastActivate > 0.15 then
            lastActivate = os.clock()
            pcall(function() tool:Activate() end)
        end
    end
end

function stopFire()
    if holdingTool then
        holdingTool = nil
        local sync = RS:FindFirstChild("HoldStateSync")
        if sync then
            pcall(function() sync:FireServer("Gun", false) end)
        end
    end
end

----------------------------------------------------------------
-- 技能：从游戏自己的技能注册事件里读取技能 ID
----------------------------------------------------------------
local skills = {}
local skillInfo = {}   -- id -> { name = 按键名, cd = 该技能自己的间隔 }
local skillNext = {}   -- id -> 下次可以点的时间

-- 鼠标键位绑定的就是普攻，可以一直点
function isBasicKey(name)
    if not name then return false end
    local u = string.upper(name)
    return u == "M1" or u == "MB1" or u == "LMB" or u == "MOUSEBUTTON1"
        or u == "M2" or u == "MB2" or u == "RMB" or u == "MOUSEBUTTON2"
end

-- 每个技能单独一套间隔：普攻 1 秒一次，其余按槽位错开 2.5 / 3.0 / 3.5 …
function rebuildSkillInfo(fresh)
    local ids = {}
    for id in pairs(fresh) do table.insert(ids, id) end
    table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
    skillInfo = {}
    local idx = 0
    for _, id in ipairs(ids) do
        idx = idx + 1
        local key = fresh[id]
        local cd
        if isBasicKey(key) then
            cd = 1.0
        else
            cd = 2.5 + (idx - 1) * 0.5
            if cd > 8 then cd = 8 end
        end
        skillInfo[id] = { name = key, cd = cd }
        if skillNext[id] == nil then
            -- 初始错开，避免几个技能同一帧全按出去
            skillNext[id] = os.clock() + math.random() * 0.8
        end
    end
end

do
    local reg = RS:FindFirstChild("SkillRegister")
    if reg then
        reg.OnClientEvent:Connect(function(mode, data)
            if mode == "clear" then
                skills = {}
                skillInfo = {}
                return
            end
            if mode ~= "set" or type(data) ~= "table" then return end
            local fresh = {}
            for id, v in pairs(data) do
                if type(v) == "string" then
                    fresh[id] = v
                elseif type(v) == "table" then
                    for _, item in ipairs(v) do
                        if type(item) == "string" then
                            fresh[id] = item
                            break
                        end
                    end
                end
            end
            skills = fresh
            rebuildSkillInfo(fresh)
        end)
    end

    task.spawn(function()
        for _ = 1, 60 do
            if not AUTO.Running then break end
            local sync = RS:FindFirstChild("SkillSyncRequest")
            if sync then
                pcall(function() sync:FireServer() end)
            end
            task.wait(2)
        end
    end)
end

function skillCount()
    local n = 0
    for _ in pairs(skills) do n = n + 1 end
    return n
end

-- 每个技能按自己的冷却独立触发：普攻连着点，其它技能冷却好了就放
function useSkills(hitPos)
    local act = RS:FindFirstChild("SkillActivate")
    if not act or not hitPos or not AUTO.AutoSkill then return 0 end
    local cam = workspace.CurrentCamera
    local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
    local now = os.clock()
    local used = 0
    for id, info in pairs(skillInfo) do
        if now >= (skillNext[id] or 0) then
            skillNext[id] = now + info.cd
            pcall(function()
                act:FireServer(id, hitPos, look, "press", info.name)
                task.delay(0.15, function()
                    pcall(function() act:FireServer(id, hitPos, look, "release", info.name) end)
                end)
            end)
            used = used + 1
        end
    end
    return used
end

----------------------------------------------------------------
-- 自动救人（倒地队友身上的 ProximityPrompt）
----------------------------------------------------------------
function tryRevive()
    local me = myChar()
    local base = hrpOf(me)
    if not base then return 0 end
    local folder = living()
    if not folder then return 0 end
    local n = 0
    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and string.find(d.Name, "Downed") then
            local model = d:FindFirstAncestorWhichIsA("Model")
            if model and model ~= me then
                local p = hrpOf(model)
                if p and (p.Position - base.Position).Magnitude <= (d.MaxActivationDistance + 3) then
                    pcall(function() d:InputHoldBegin() end)
                    task.delay(math.max(0.1, d.HoldDuration) + 0.08, function()
                        pcall(function() d:InputHoldEnd() end)
                    end)
                    n = n + 1
                end
            end
        end
    end
    return n
end

----------------------------------------------------------------
-- 场景判断
----------------------------------------------------------------
function waveText()
    local wg = pg:FindFirstChild("WavesGui")
    local lbl = wg and findPath(wg, { "Frame", "TextLabel" })
    if lbl and lbl:IsA("TextLabel") then return lbl.Text end
    return ""
end

function readyText()
    local chr = pg:FindFirstChild("ChrGUI")
    local lbl = chr and findPath(chr, { "Frame-Ready", "Menu", "Ready", "Button", "TextLabel" })
    if lbl and lbl:IsA("TextLabel") then return lbl.Text end
    return ""
end

function modeText()
    local mv = workspace:FindFirstChild("Mode")
    if mv and mv:IsA("StringValue") then return mv.Value end
    if mv and mv:IsA("ValueBase") then return tostring(mv.Value) end
    return ""
end

function hasShownGui(root)
    if not root then return false end
    if root:IsA("GuiObject") then return deepVisible(root) end
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("GuiObject") and deepVisible(d) then return true end
    end
    return false
end

function inMatch()
    local me = myChar()
    -- 角色被放进 workspace.Living 就是真正开局了
    local lv = living()
    if me and lv and me.Parent == lv then return true end
    if enemyCount() > 0 then return true end
    -- 站在准备区域附近 = 还在大厅
    local pad = workspace:FindFirstChild("AutoReady")
    local base = hrpOf(me)
    if pad and base and (base.Position - pad.Position).Magnitude < 90 then
        return false
    end
    -- 投票阶段一律按大厅处理
    if workspace:FindFirstChild("Voteing") then
        return false
    end
    local wg = pg:FindFirstChild("WavesGui")
    if wg then
        local frame = wg:FindFirstChild("Frame")
        if frame and frame:IsA("GuiObject") and deepVisible(frame) then
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 点按钮：和参考脚本同款（firesignal → getconnections → Activate）
----------------------------------------------------------------
function clickGui(btn)
    if not btn or not btn:IsA("GuiButton") then return false end
    local clicked = false
    pcall(function()
        if type(firesignal) == "function" then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
            clicked = true
        elseif type(getconnections) == "function" then
            local cons = getconnections(btn.Activated) or {}
            for _, c in ipairs(cons) do
                if c.Function then
                    pcall(c.Function)
                    clicked = true
                end
            end
        end
    end)
    if clicked then return true end
    -- 没有 firesignal / getconnections 时，用真实鼠标点一下（老版就是玩家手点）
    local ok = pcall(function()
        local guiService = game:GetService("GuiService")
        local inset = guiService:GetGuiInset()
        local p = btn.AbsolutePosition + btn.AbsoluteSize / 2 + inset
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 1)
        task.wait(0.05)
        vim:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 1)
    end)
    if ok then return true end
    return pcall(function() btn:Activate() end)
end

-- 自动准备：老版用的就是 GetReadyRemote 固定顺序，不点界面按钮
-- 老版能点、新版点不了的原因：
-- 老版不是去点界面按钮，而是按固定顺序发 GetReadyRemote：
--   ("1", true) → ("1", false) → ("2", false) → ("3", false) → ("1", true)
-- 其中 "2" 关 ChrGUI、"3" 关 SelectCharacter，最后再准备一次。
-- 只发一句 ("1", true) 在角色选择界面开着时服务器不认，所以必须走这套顺序。
----------------------------------------------------------------
local lastReadyAt = 0
local readying = false
function autoReady()
    if readying then return false end
    -- 只在有大厅准备板 / 投票阶段时做
    if not workspace:FindFirstChild("AutoReady") and not workspace:FindFirstChild("Voteing") then
        return false
    end
    local now = tick()
    if now - lastReadyAt < 2 then return false end
    lastReadyAt = now

    local remote = RS:FindFirstChild("GetReadyRemote")
    if not remote then return false end

    readying = true
    task.spawn(function()
        pcall(function()
            -- 新版客户端：把 ChrGUI / SelectCharacter 关掉，客户端自己的 Changed
            -- 会自动补发 ("2", false) / ("3", false)，服务端才认准备
            local chrGui = pg:FindFirstChild("ChrGUI")
            if chrGui and chrGui.Enabled then chrGui.Enabled = false end
            local selGui = pg:FindFirstChild("SelectCharacter")
            if selGui and selGui.Enabled then selGui.Enabled = false end
            task.wait(0.1)
            -- 再走老版那套完整顺序，双保险
            remote:FireServer("1", true)
            task.wait(0.2)
            remote:FireServer("1", false)
            task.wait(0.2)
            remote:FireServer("2", false)
            task.wait(0.2)
            remote:FireServer("3", false)
            task.wait(0.2)
            remote:FireServer("1", true)
        end)
        readying = false
    end)
    AUTO.LastReason = "已按老版顺序准备（1真 → 1假 → 关ChrGUI → 关选人 → 1真）"
    return true
end

----------------------------------------------------------------
-- 结算：自动准备下一局
----------------------------------------------------------------
function autoContinue()
    local gui = pg:FindFirstChild("ModeResult")
    if not hasShownGui(gui) then return false end
    local remote = RS:FindFirstChild("ModeResult")
    if remote then
        pcall(function() remote:FireServer("Ready") end)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 自动跳波设置（游戏内已有开关）
----------------------------------------------------------------
function enableAutoSkip()
    if not AUTO.AutoSkip then return end
    local r = RS:FindFirstChild("SetSettingAutoSkipWave")
    if r then
        pcall(function() r:FireServer(true) end)
    end
end

----------------------------------------------------------------
-- 自动点击界面 / 自动投票
----------------------------------------------------------------
-- 装备指定角色（不自动判断强弱，由玩家在「玩家」页选择）
local lastEquip = 0
function equipNamed(name)
    if inMatch() then return false, "战斗中不换角色" end
    local ud = player:FindFirstChild("UnlockData")
    local remote = RS:FindFirstChild("ForChangeCharacter")
    if not ud or not remote then return false, "缺少 UnlockData / 遥控" end
    if name == nil or name == "" then return false, "还没选角色" end
    local c = ud:FindFirstChild(name)
    if not c then return false, "未解锁：" .. tostring(name) end
    local now = os.clock()
    if now - lastEquip < 5 then return false, "刚换过" end
    local skin = c:FindFirstChild("SkinNumber")
    lastEquip = now
    pcall(function() remote:FireServer(c.Name, skin and skin.Value or 0) end)
    log("已装备角色：" .. c.Name)
    return true, c.Name
end


-- 游戏内 19 个模式（Play.Main 实际存在的按钮）
local MODE_ORDER = {
    "Normal", "Hard", "VeryHard", "Insane", "Nightmare",
    "BossRush", "ThunderStorm", "Zombie", "Christmas", "Hell",
    "DarkDimension", "Astro", "AstroV2", "ZombieV2", "BattleArmorAct1",
    "Soundwave", "Halloween", "NoLightInTheSky", "100MVisit",
}

function voteCount(mode)
    local folder = workspace:FindFirstChild("Vote")
    local m = folder and folder:FindFirstChild(mode)
    if m then return #m:GetChildren() end
    return -1
end

-- 等价于点击 OpenVoteUI 里的 "OPEN UI"：关角色选择，打开投票界面
function openVoteGui()
    local playGui = pg:FindFirstChild("Play")
    if not playGui then return false end
    if playGui.Enabled then
        -- 顺手把参考脚本用的 OpenVoteUI 也打开
        local ov = pg:FindFirstChild("OpenVoteUI")
        if ov then
            local f = ov:FindFirstChild("OPEN UI")
            if f and f.Visible ~= true then
                pcall(function() f.Visible = true end)
            end
        end
        return true
    end
    local sel = pg:FindFirstChild("SelectCharacter")
    if sel then
        pcall(function() sel.Enabled = false end)
    end
    pcall(function() playGui.Enabled = true end)
    log("已自动打开投票界面")
    return true
end

-- 选模式：优先票数最高的；都没票就投 Normal
function bestMode()
    if AUTO.VoteMode ~= "" then
        return AUTO.VoteMode, "指定模式"
    end
    local best, bestN = nil, -1
    -- 优先按服务器真实投票框（workspace.Vote 的子项）动态统计
    local folder = workspace:FindFirstChild("Vote")
    if folder then
        for _, m in ipairs(folder:GetChildren()) do
            local n = #m:GetChildren()
            if n > bestN then
                best, bestN = m.Name, n
            end
        end
    end
    if not best then
        for _, mode in ipairs(MODE_ORDER) do
            local n = voteCount(mode)
            if n > bestN then
                best, bestN = mode, n
            end
        end
    end
    if best and bestN > 0 then
        return best, string.format("%d 票领先", bestN)
    end
    return "Normal", "默认"
end

function votePhase()
    if workspace:FindFirstChild("Voteing") then return true end
    local ov = pg:FindFirstChild("OpenVoteUI")
    local f = ov and ov:FindFirstChild("OPEN UI")
    return f ~= nil and f.Visible == true
end

local lastVotedMode = nil
local lastVoteAt = 0

-- 自动开单人局：新版客户端只有 QuestFuse({ "StartSolo" })，老版 MainHandler 留作兜底
local lastStart = 0
function autoStartSolo()
    if votePhase() then return false end
    local now = os.clock()
    if now - lastStart < 8 then return false end
    local qf = RS:FindFirstChild("QuestFuse")
    local mh = RS:FindFirstChild("MainHandler")
    if not qf and not mh then return false end
    local mode = bestMode()
    lastStart = now
    local ok = false
    if qf then
        ok = pcall(function() qf:FireServer({ "StartSolo" }) end)
    end
    if not ok and mh then
        ok = pcall(function() mh:FireServer({ [1] = "StartSolo", [2] = mode }) end)
    end
    AUTO.LastReason = "已发起单人开局：" .. mode
    log("已自动开单人局：" .. mode)
    return ok
end

function autoVote()
    if not votePhase() then
        AUTO.VoteState = "等待投票"
        return false
    end
    local now = tick()
    if now - lastVoteAt < 1 then return false end
    lastVoteAt = now
    local remote = RS:FindFirstChild("Vote")
    if not remote then return false end
    local mode, why = bestMode()

    -- 老版就是这样：不点界面，直接发 Vote 遥控（参数是英文模式名）
    local ok = pcall(function() remote:FireServer(mode) end)

    -- 投完把投票浮窗收起来（参考脚本同款做法）
    pcall(function()
        local ov = pg:FindFirstChild("OpenVoteUI")
        local f = ov and ov:FindFirstChild("OPEN UI")
        if f then f.Visible = false end
    end)

    AUTO.VoteState = string.format("%s（%s）", mode, why)
    AUTO.LastReason = "已投票：" .. mode
    if lastVotedMode ~= mode then
        lastVotedMode = mode
        log("投票 → " .. mode .. "（" .. why .. "，遥控）")
    end
    return ok
end

-- 跳波投票：跟随票数最高的那一档
local skipVotedKey, skipVotedAt = nil, 0
function autoSkipVote()
    local vs = pg:FindFirstChild("VoteSkip")
    if not vs or vs.Enabled ~= true then return false end
    local panel = vs:FindFirstChild("Main")
    if not panel then return false end
    local bestKey, bestN, bestWave = nil, -1, math.huge

    -- 旧版：Main.<波数>.TextButton.Text = "票数 / 总人数"
    for _, opt in ipairs(panel:GetChildren()) do
        local wave = tonumber(opt.Name)
        local btn = opt:FindFirstChild("TextButton")
        if wave and btn and btn:IsA("TextButton") then
            local votes = tonumber(string.match(btn.Text, "(%d+)%s*/")) or 0
            if votes > bestN or (votes == bestN and wave < bestWave) then
                bestKey, bestN, bestWave = wave, votes, wave
            end
        end
    end

    -- 新版：Main.Cards.Wave<波数>，票数在卡片里 "票数 / 总人数"
    local cards = panel:FindFirstChild("Cards")
    if cards then
        for _, card in ipairs(cards:GetChildren()) do
            local wave = tonumber(string.match(card.Name, "^Wave(%d+)$"))
            if wave then
                local votes = 0
                for _, lbl in ipairs(card:GetDescendants()) do
                    if lbl:IsA("TextLabel") then
                        local n = tonumber(string.match(lbl.Text, "(%d+)%s*/"))
                        if n then
                            votes = math.max(votes, n)
                        end
                    end
                end
                if votes > bestN or (votes == bestN and wave < bestWave) then
                    bestKey, bestN, bestWave = wave, votes, wave
                end
            end
        end
    end

    if not bestKey then return false end
    local now = os.clock()
    if skipVotedKey == bestKey and now - skipVotedAt < 4 then return false end
    local remote = RS:FindFirstChild("SkipWaveVote")
    if not remote then return false end
    skipVotedKey, skipVotedAt = bestKey, now

    -- 优先点卡片，点不动再用遥控
    local clicked = false
    if cards and clickGui(cards:FindFirstChild("Wave" .. bestKey)) then
        clicked = true
    elseif panel:FindFirstChild(tostring(bestKey)) then
        local btn = panel[tostring(bestKey)]:FindFirstChild("TextButton")
        clicked = clickGui(btn)
    end
    if not clicked then
        pcall(function() remote:FireServer(bestKey) end)
    end
    log(string.format("跳波投票 → 第 %d 波（%d 票，%s）", bestKey, bestN, clicked and "点击界面" or "遥控"))
    return true
end

----------------------------------------------------------------
-- 自动点击设置开关 / 跳过直升机过场
----------------------------------------------------------------
local SETTING_ON = {
    "AutoSkipHelicopter", "SkipBossCutScene", "FastMode",
    "RemoveScreenShake", "DMGIndicator", "DisableHeadCursor",
    "MuteCharacterThemes", "DisableMusicTheme", "DisableAmbience",
}
local lastSettings = 0
function applySettings()
    local now = os.clock()
    if not AUTO.AutoSettings then return end
    if now - lastSettings < 15 then return end
    lastSettings = now
    local sf = player:FindFirstChild("SettingFolder")
    if not sf then return end
    local remote = RS:FindFirstChild("SendSetting")
    local changed = 0
    for _, key in ipairs(SETTING_ON) do
        local v = sf:FindFirstChild(key)
        if v and v:IsA("BoolValue") and v.Value ~= true then
            pcall(function()
                v.Value = true
                if remote then remote:FireServer(key, true) end
            end)
            changed = changed + 1
        end
    end
    if changed > 0 then
        log(string.format("已自动打开 %d 个设置开关（跳直升机 / 跳过场 / 去抖动等）", changed))
    end
end

local lastHeli = 0
function autoSkipHeli()
    local now = os.clock()
    if not AUTO.AutoSkipHeli then return false end
    if now - lastHeli < 2 then return false end
    local g = pg:FindFirstChild("skip heli")
    local r = RS:FindFirstChild("SkipHelicopter")
    if not g or not r or g.Enabled ~= true then return false end
    lastHeli = now
    local clicked = clickGui(g:FindFirstChild("TextButton"))
    if not clicked then
        pcall(function() r:FireServer() end)
    end
    log("已跳过直升机过场" .. (clicked and "（点击界面）" or "（遥控）"))
    return true
end

----------------------------------------------------------------
-- 无限复活：残血直接重置角色，立刻重新出生
-- 和参考脚本同一套原理：卸掉 Head / Torso 让本地角色判死 → 服务端重发 CharacterAdded
-- manual = true 时忽略开关（玩家手动点按钮触发）
----------------------------------------------------------------
local lastReset = 0
function forceRespawn(reason, manual)
    if not manual and not AUTO.AutoRespawn then return false end
    local now = os.clock()
    if now - lastReset < 2 then return false end
    local char = player.Character
    local h = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not h or h.Health <= 0 then return false end
    lastReset = now
    pcall(function()
        local head = char:FindFirstChild("Head")
        if head then head:Destroy() end
    end)
    task.delay(0.05, function()
        local c = player.Character
        local hh = c and c:FindFirstChildOfClass("Humanoid")
        if hh and hh.Health > 0 then
            pcall(function()
                local torso = c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
                if torso then torso:Destroy() end
                if hh.Health > 0 then hh.Health = 0 end
            end)
        end
    end)
    AUTO.LastReason = "无限复活触发：" .. tostring(reason)
    log("无限复活触发：" .. tostring(reason))
    return true
end

----------------------------------------------------------------
-- 队友识别（给队友透视用）
----------------------------------------------------------------
function isAlly(m)
    if not m or not m:IsA("Model") then return false end
    local plr = Players:GetPlayerFromCharacter(m)
    return plr ~= nil and plr ~= player
end

----------------------------------------------------------------
-- 奖励 / 收集自动化
----------------------------------------------------------------
function claimRemote(name)
    local r = RS:FindFirstChild(name)
    if not r or not r:IsA("RemoteFunction") then return false end
    local ok, res = pcall(function() return r:InvokeServer("Claim") end)
    if not ok then return false end
    if type(res) == "table" and res.Ok == false then return false end
    return true
end

function autoClaimRewards()
    local did = false
    if AUTO.AutoClaimLogin and every("claimlogin", 25) then
        if claimRemote("LoginRemote") then did = true end
    end
    if AUTO.AutoClaimGroup and every("claimgroup", 25) then
        if claimRemote("GroupRewardRemote") then did = true end
    end
    if did then
        AUTO.LastReason = "已自动领取登录 / 团队奖励"
        log("自动领取：已请求登录 / 团队奖励")
    end
    return did
end

-- 自动点界面上所有 Claim / Collect / 领取 按钮（每个按钮 3 秒冷却）
local CLAIM_WORDS = { "claim", "collect", "领取", "claim all", "领取全部" }
local claimClickedAt = {}
function autoClickClaim()
    if not AUTO.AutoClickClaim then return end
    if not every("clickclaim", 1.5) then return end
    local now = os.clock()
    local n = 0
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("GuiButton") and d.Enabled and deepVisible(d) then
                    local lowName = string.lower(d.Name or "")
                    local lowText = ""
                    if d:IsA("TextButton") then lowText = string.lower(d.Text or "") end
                    local hit = false
                    for _, w in ipairs(CLAIM_WORDS) do
                        if string.find(lowText, w, 1, true) or string.find(lowName, w, 1, true) then
                            hit = true
                            break
                        end
                    end
                    if hit and (claimClickedAt[d] or 0) + 3 <= now then
                        claimClickedAt[d] = now
                        if clickGui(d) then n = n + 1 end
                    end
                end
            end
        end
    end
    if n > 0 then log("自动领取：点击了 " .. n .. " 个领取按钮") end
    return n > 0
end

----------------------------------------------------------------
-- 抽奖 / 胶囊（只在大厅做）
----------------------------------------------------------------
function autoGacha()
    if inMatch() then return false end
    local did = false
    if AUTO.AutoGachaChar and every("gachachar", 4) then
        local r = RS:FindFirstChild("GachaCharacter")
        if r then
            pcall(function() r:FireServer(AUTO.GachaSpin) end)
            log("自动抽角色：" .. tostring(AUTO.GachaSpin))
            did = true
        end
    end
    if AUTO.AutoGachaSkin and every("gachaskin", 4) then
        local r = RS:FindFirstChild("GachaSkins")
        if r then
            pcall(function() r:FireServer(AUTO.GachaSpin) end)
            log("自动抽皮肤：" .. tostring(AUTO.GachaSpin))
            did = true
        end
    end
    if AUTO.AutoCapsule and every("capsule", 4) then
        local r = RS:FindFirstChild("GachaCapsule")
        if r then
            pcall(function() r:FireServer() end)
            log("自动开胶囊")
            did = true
        end
    end
    return did
end

----------------------------------------------------------------
-- G-Squad 小队任务
----------------------------------------------------------------
local squadCfg = nil
function getSquadCfg()
    if squadCfg then return squadCfg end
    local m = RS:FindFirstChild("GSquadQuestConfig")
    if m then
        local ok, res = pcall(require, m)
        if ok and type(res) == "table" then squadCfg = res end
    end
    return squadCfg
end

function autoSquadQuest()
    if inMatch() then return false end
    if not every("squad", 6) then return false end
    local cfg = getSquadCfg()
    local r = RS:FindFirstChild("GSquadQuest")
    if not cfg or not r then return false end
    local ud = player:FindFirstChild("UnlockData")
    local n = 0
    for _, m in ipairs(cfg.Missions or {}) do
        if m.Id and (not m.Need or (ud and ud:FindFirstChild(m.Need))) then
            pcall(function() r:FireServer("Accept", m.Id) end)
            pcall(function() r:FireServer("Complete", m.Id) end)
            n = n + 1
        end
    end
    if n > 0 then log("小队任务：已请求 " .. n .. " 个任务") end
    return n > 0
end

----------------------------------------------------------------
-- 重新开局投票
----------------------------------------------------------------
function autoRestartVote()
    if not every("restart", 3) then return false end
    local voteFolder = workspace:FindFirstChild("Vote")
    local rg = voteFolder and voteFolder:FindFirstChild("RestartGame")
    if not rg then return false end
    local r = RS:FindFirstChild("VoteRestartGame")
    if r then
        pcall(function() r:FireServer("Yes") end)
        AUTO.LastReason = "已投重新开始票（Yes）"
        log("重新开局投票：Yes")
        return true
    end
    return false
end

----------------------------------------------------------------
-- 称号
----------------------------------------------------------------
function equipTitle(name)
    if name == nil or name == "" then return false, "没填称号名" end
    local r = RS:FindFirstChild("Title")
    if not r then return false, "缺少 Title 遥控" end
    local folder = player:FindFirstChild("TitlesFolder")
    if folder and not folder:FindFirstChild(name) then
        return false, "未解锁：" .. tostring(name)
    end
    pcall(function() r:FireServer(name) end)
    log("已装备称号：" .. tostring(name))
    return true, name
end

----------------------------------------------------------------
-- 商店 / 消耗品
----------------------------------------------------------------
local buyHpNext, potionNext, moneyNext, boostNext = 0, 0, 0, 0

-- 老版自动补货：商店件（直升机上的 PartForShop）到位后才能买到 FillHP
function fillUpReady()
    local obj = workspace
    for _, k in ipairs({ "HelicopterShop", "ShopXDD", "PartForShop" }) do
        obj = obj and obj:FindFirstChild(k)
    end
    if not obj or not obj:IsA("BasePart") then return false end
    return (obj.Position - Vector3.new(44.2756729, 26.3595276, -32.7318268)).Magnitude < 0.5
end

function buyHP()
    if os.clock() < buyHpNext then return false end
    local r = RS:FindFirstChild("ShopSystem")
    if not r then return false end
    if not fillUpReady() then
        AUTO.LastReason = "自动补货：等待商店件到位"
        return false
    end
    buyHpNext = os.clock() + 3
    for i = 1, 2 do
        pcall(function() r:FireServer("Buy", "FillHP") end)
        if i < 2 then task.wait(0.3) end
    end
    AUTO.LastReason = "自动补货：已购买 FillHP"
    log("商店：已请求购买补血（FillHP x2）")
    return true
end

function usePotion()
    if os.clock() < potionNext then return false end
    local r = RS:FindFirstChild("Potions")
    if not r then return false end
    potionNext = os.clock() + 3
    pcall(function() r:FireServer(AUTO.PotionName) end)
    log("药水：已请求使用 " .. tostring(AUTO.PotionName))
    return true
end

function useMoneyBag()
    if os.clock() < moneyNext then return false end
    local r = RS:FindFirstChild("UseItems")
    if not r then return false end
    moneyNext = os.clock() + 6
    pcall(function() r:FireServer("Money") end)
    log("道具：已请求使用金钱袋")
    return true
end

function useBoost()
    if os.clock() < boostNext then return false end
    if AUTO.BoostName == nil or AUTO.BoostName == "" then return false end
    local r = RS:FindFirstChild("Boosts")
    if not r then return false end
    boostNext = os.clock() + 60
    pcall(function() r:FireServer(AUTO.BoostName) end)
    log("加速：已请求使用 " .. tostring(AUTO.BoostName))
    return true
end

----------------------------------------------------------------
-- 技能树自动升级
----------------------------------------------------------------
function autoSkillTree()
    if not every("skilltree", 12) then return false end
    local r = RS:FindFirstChild("SkillTrees")
    local folder = player:FindFirstChild("SkillTreesFolder")
    if not r or not folder then return false end
    local n = 0
    for _, v in ipairs(folder:GetChildren()) do
        pcall(function() r:FireServer(v.Name) end)
        n = n + 1
    end
    if n > 0 then log("技能树：已尝试升级 " .. n .. " 个技能") end
    return n > 0
end

----------------------------------------------------------------
-- 自动传送
----------------------------------------------------------------
local lastTeleport = 0
function combatTeleport(base, targetPos)
    if not AUTO.AutoTeleport or not base or not targetPos then return false end
    local now = os.clock()
    if now - lastTeleport < 0.7 then return false end
    local delta = targetPos - base.Position
    local dist = delta.Magnitude
    if dist <= AUTO.TeleportDist then return false end
    local dir = dist > 0 and delta.Unit or Vector3.new(0, 0, -1)
    local dest = targetPos - dir * 12 + Vector3.new(0, 4, 0)
    lastTeleport = now
    pcall(function()
        base.CFrame = CFrame.lookAt(dest, targetPos)
        base.AssemblyLinearVelocity = Vector3.zero
        base.AssemblyAngularVelocity = Vector3.zero
    end)
    AUTO.LastReason = string.format("已传送到 %s 身边", AUTO.Target or "敌人")
    return true
end

-- 导弹 / 投掷物朝脸飞来时，直接侧向瞬移躲开（不靠走位、不靠 AI）
local PROJ_KEYS = {
    "missile", "projectile", "rocket", "grenade", "bomb", "bullet",
    "acid", "snowball", "laser", "orb", "fireball", "knife", "dart",
}
local lastDodge, lastDodgeScan = 0, 0

function isProjectileName(n)
    local l = string.lower(n)
    for _, k in ipairs(PROJ_KEYS) do
        if string.find(l, k, 1, true) then return true end
    end
    return false
end

function findIncoming(base)
    local function scan(list)
        for _, obj in ipairs(list) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                if isProjectileName(obj.Name) then
                    local part
                    if obj:IsA("BasePart") then
                        part = obj
                    else
                        part = obj.PrimaryPart
                        if not part then
                            local okp, found = pcall(function()
                                return obj:FindFirstChildWhichIsA("BasePart", true)
                            end)
                            if okp then part = found end
                        end
                    end
                    if part then
                        local dv = base.Position - part.Position
                        local dist = dv.Magnitude
                        if dist > 3 and dist < 90 then
                            local vel = part.AssemblyLinearVelocity
                            if vel.Magnitude > 25 and vel.Unit:Dot(dv.Unit) > 0.5 then
                                return part
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local hit = scan(workspace:GetChildren())
    if not hit then
        local box = workspace:FindFirstChild("Projectiles") or workspace:FindFirstChild("Effects")
        if box then hit = scan(box:GetChildren()) end
    end
    return hit
end

function dodgeProjectile(base)
    if not AUTO.AutoDodge or not base then return false end
    local now = os.clock()
    if now - lastDodge < 0.6 then return false end
    if now - lastDodgeScan < 0.3 then return false end
    lastDodgeScan = now
    local p = findIncoming(base)
    if not p then return false end
    lastDodge = now
    local away = base.Position - p.Position
    local flat = Vector3.new(away.X, 0, away.Z)
    if flat.Magnitude < 0.1 then flat = Vector3.new(1, 0, 0) end
    flat = flat.Unit
    local side = Vector3.new(-flat.Z, 0, flat.X)
    local dest = base.Position + side * 30 + Vector3.new(0, 6, 0)
    local char = myChar()
    local ok = false
    if char then
        ok = pcall(function() char:PivotTo(CFrame.new(dest)) end)
    end
    if not ok then
        pcall(function() base.CFrame = CFrame.new(dest) end)
    end
    pcall(function()
        base.AssemblyLinearVelocity = Vector3.zero
        base.AssemblyAngularVelocity = Vector3.zero
    end)
    AUTO.LastReason = "瞬移躲投射物：" .. p.Name
    if every("dodgelog", 2) then
        log("瞬移躲投射物：" .. p.Name)
    end
    return true
end

----------------------------------------------------------------
-- ========== 扩展自动化（角色 / 刷怪 / 商店 / 收集 / 杂项） ==========
----------------------------------------------------------------
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

function firstNumber(text)
    local n = tostring(text or ""):match("(%d+)")
    return n and tonumber(n) or nil
end

function waveNumber()
    return firstNumber(waveText())
end

function fireRemote(name, ...)
    local r = RS:FindFirstChild(name)
    if not r or not r:IsA("RemoteEvent") then return false end
    local args = { ... }
    return pcall(function() r:FireServer(table.unpack(args)) end)
end

function moveChar(dest, lookAt, moveMode)
    local c = myChar()
    local b = hrpOf(c)
    if not c or not b or not dest then return false end
    local cf = CFrame.new(dest)
    if lookAt then
        local flat = Vector3.new(lookAt.X, dest.Y, lookAt.Z)
        if (flat - dest).Magnitude > 0.05 then
            cf = CFrame.lookAt(dest, flat)
        end
    end
    if moveMode == "Tween" or moveMode == "补间" then
        local tw = TweenService:Create(b, TweenInfo.new(0.28, Enum.EasingStyle.Linear), { CFrame = cf })
        tw:Play()
    else
        pcall(function() c:PivotTo(cf) end)
        pcall(function()
            b.AssemblyLinearVelocity = Vector3.zero
            b.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    return true
end

----------------------------------------------------------------
-- 无碰撞 / 锁定移速 / 无限跳跃
----------------------------------------------------------------
local noClipSaved, noClipOn = {}, false

task.spawn(function()
    while AUTO.Running do
        local want = AUTO.NoClip == true
        if want ~= noClipOn then
            noClipOn = want
            if not want then
                for p in pairs(noClipSaved) do
                    if p.Parent then
                        pcall(function() p.CanCollide = true end)
                    end
                end
                noClipSaved = {}
            end
        end
        if want then
            local me = myChar()
            if me then
                for _, d in ipairs(me:GetDescendants()) do
                    if d:IsA("BasePart") and d.CanCollide then
                        noClipSaved[d] = true
                        pcall(function() d.CanCollide = false end)
                    end
                end
            end
            task.wait(0.15)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while AUTO.Running do
        if AUTO.LockMoveStats then
            local h = humOf(myChar())
            if h then
                local ws = tonumber(AUTO.WalkSpeed) or 16
                local jp = tonumber(AUTO.JumpPower) or 50
                if h.WalkSpeed ~= ws then pcall(function() h.WalkSpeed = ws end) end
                if h.JumpPower ~= jp then pcall(function() h.JumpPower = jp end) end
            end
        end
        task.wait(0.4)
    end
end)

pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if not AUTO.InfiniteJump then return end
        local h = humOf(myChar())
        if h and h.Health > 0 then
            pcall(function()
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end)
end)

----------------------------------------------------------------
-- 飞行
----------------------------------------------------------------
local flyConn, flyVel, flyGyro, flyActive = nil, nil, nil, false

function stopFly()
    flyActive = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyVel then pcall(function() flyVel:Destroy() end); flyVel = nil end
    if flyGyro then pcall(function() flyGyro:Destroy() end); flyGyro = nil end
    local h = humOf(myChar())
    if h then
        pcall(function() h.PlatformStand = false end)
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end

function startFly()
    local c = myChar()
    local h = humOf(c)
    if not c or not h then return false end
    local torso = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or hrpOf(c)
    if not torso then return false end
    stopFly()
    flyActive = true
    pcall(function()
        h.PlatformStand = true
        local gyro = Instance.new("BodyGyro")
        gyro.P = 9e4
        gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        gyro.CFrame = torso.CFrame
        gyro.Parent = torso
        flyGyro = gyro
        local vel = Instance.new("BodyVelocity")
        vel.Velocity = Vector3.new(0, 0.1, 0)
        vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        vel.Parent = torso
        flyVel = vel
    end)
    local speed = (tonumber(AUTO.FlySpeed) or 1) * 50
    local vSpeed = tonumber(AUTO.FlyHeight) or 10
    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.RenderStepped:Connect(function()
        local ch = myChar()
        if not ch or ch ~= c or not ch.Parent then
            stopFly()
            return
        end
        local hum = humOf(ch)
        local vel = flyVel
        local gyro = flyGyro
        if not hum or not vel or not gyro then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vertical = 0
        pcall(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vertical = vertical + 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vertical = vertical - 1
            end
        end)
        local dir = hum.MoveDirection + Vector3.new(0, vertical * vSpeed, 0)
        if dir.Magnitude > 0 then dir = dir.Unit end
        vel.Velocity = dir * speed
        gyro.CFrame = cam.CFrame
    end)
    AUTO.LastReason = "飞行已开启"
    return true
end

task.spawn(function()
    local was = false
    while AUTO.Running do
        local want = AUTO.Fly == true
        if want and not flyActive then startFly() end
        if not want and flyActive then stopFly() end
        was = want
        task.wait(0.5)
    end
    if was then stopFly() end
end)

----------------------------------------------------------------
-- 全亮 / 无雾
----------------------------------------------------------------
local fullBrightOn, noFogOn = false, false
local lightSaved, fogSaved, effectSaved = nil, nil, nil

function applyLighting()
    if AUTO.FullBright and not fullBrightOn then
        fullBrightOn = true
        pcall(function()
            lightSaved = {
                Brightness = Lighting.Brightness,
                GlobalShadows = Lighting.GlobalShadows,
                ClockTime = Lighting.ClockTime,
                Ambient = Lighting.Ambient,
                ColorShift_Top = Lighting.ColorShift_Top,
                ColorShift_Bottom = Lighting.ColorShift_Bottom,
                EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
                EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
            }
            effectSaved = {}
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 12
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.ColorShift_Top = Color3.new(1, 1, 1)
            Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
            for _, ch in ipairs(Lighting:GetChildren()) do
                if ch:IsA("BloomEffect") or ch:IsA("SunRaysEffect") or ch:IsA("ColorCorrectionEffect") then
                    effectSaved[ch] = ch.Enabled
                    ch.Enabled = false
                end
            end
        end)
    elseif not AUTO.FullBright and fullBrightOn then
        fullBrightOn = false
        pcall(function()
            if lightSaved then
                for k, v in pairs(lightSaved) do
                    Lighting[k] = v
                end
                lightSaved = nil
            end
            if effectSaved then
                for ch, en in pairs(effectSaved) do
                    if ch.Parent then ch.Enabled = en end
                end
                effectSaved = nil
            end
        end)
    end

    if AUTO.NoFog and not noFogOn then
        noFogOn = true
        pcall(function()
            fogSaved = { FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd }
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
        end)
    elseif not AUTO.NoFog and noFogOn then
        noFogOn = false
        pcall(function()
            if fogSaved then
                Lighting.FogStart = fogSaved.FogStart
                Lighting.FogEnd = fogSaved.FogEnd
                fogSaved = nil
            end
        end)
    end
end

task.spawn(function()
    while AUTO.Running do
        applyLighting()
        task.wait(0.6)
    end
end)

----------------------------------------------------------------
-- 相机模式
----------------------------------------------------------------
local camConn, camModeApplied = nil, nil

function applyCameraMode()
    local mode = AUTO.CameraMode or "Classic"
    if camModeApplied == mode then return end
    camModeApplied = mode
    if camConn then camConn:Disconnect(); camConn = nil end
    camera.CameraType = Enum.CameraType.Custom
    pcall(function() camera.CameraSubject = humOf(myChar()) end)
    if mode == "Manual" then
        camConn = RunService.RenderStepped:Connect(function()
            local b = hrpOf(myChar())
            if not b then return end
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(b.Position + Vector3.new(0, 18, -24), b.Position)
        end)
    end
end

task.spawn(function()
    while AUTO.Running do
        applyCameraMode()
        task.wait(1)
    end
end)

----------------------------------------------------------------
-- 绕过屏障
----------------------------------------------------------------
local barrierSaved, barrierOn = {}, false

task.spawn(function()
    while AUTO.Running do
        local want = AUTO.NoBarrier == true
        if want ~= barrierOn then
            barrierOn = want
            if want then
                for _, d in ipairs(workspace:GetDescendants()) do
                    if d:IsA("BasePart") and d.CanCollide then
                        local low = string.lower(d.Name)
                        if string.find(low, "barrier", 1, true) or string.find(low, "invisible", 1, true) then
                            barrierSaved[d] = true
                            pcall(function() d.CanCollide = false end)
                        end
                    end
                end
                log("绕过屏障：已关闭 " .. tostring(#workspace:GetChildren()) .. " 区域内的隐形墙碰撞")
            else
                for p in pairs(barrierSaved) do
                    pcall(function() if p.Parent then p.CanCollide = true end end)
                end
                barrierSaved = {}
            end
        end
        task.wait(1.2)
    end
end)

----------------------------------------------------------------
-- 刷怪：原版优先级（Giant ST → 直升机 → 高血量 → 最近）+ 视觉包围盒定位
----------------------------------------------------------------
local orbitAngle = 0
local boundsCache, boundsAt = {}, {}
local farmLockUntil = 0

function mobMaxHp(mob)
    local h = mob:FindFirstChildOfClass("Humanoid")
    return h and h.MaxHealth or 0
end

function promptOf(mob)
    for _, d in ipairs(mob:GetDescendants()) do
        if d:IsA("ProximityPrompt") then return d end
    end
    return nil
end

-- 原版 ComputeMobVisualBounds：按所有可见部件算中心、最低点、最高点
function mobBounds(mob)
    local now = os.clock()
    local cached = boundsCache[mob]
    if cached and now - (boundsAt[mob] or 0) < 0.25 then
        return cached[1], cached[2], cached[3]
    end
    local minY, maxY, sx, sz, n = math.huge, -math.huge, 0, 0, 0
    for _, d in ipairs(mob:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 0.9 and d.Size.Y > 0.1 then
            local p = d.Position
            local hy = d.Size.Y * 0.5
            if p.Y - hy < minY then minY = p.Y - hy end
            if p.Y + hy > maxY then maxY = p.Y + hy end
            sx = sx + p.X
            sz = sz + p.Z
            n = n + 1
        end
    end
    local res
    if n == 0 then
        local r = hrpOf(mob)
        if r then
            res = { r.Position, r.Position.Y - 2, r.Position.Y + 2 }
        else
            res = { Vector3.zero, 0, 4 }
        end
    else
        res = { Vector3.new(sx / n, (minY + maxY) * 0.5, sz / n), minY, maxY }
    end
    if #boundsCache > 400 then boundsCache, boundsAt = {}, {} end
    boundsCache[mob], boundsAt[mob] = res, now
    return res[1], res[2], res[3]
end

function farmCandidates()
    local out = {}
    local folder = living()
    if not folder then return out end
    for _, m in ipairs(folder:GetChildren()) do
        if isEnemy(m) then
            local p = hrpOf(m)
            if p then out[#out + 1] = m end
        end
    end
    return out
end

-- 原版 GetPriorityMob：Giant ST(4) → 直升机(3) → 高血量(2) → 最近(1)
function pickFarmTarget()
    local base = hrpOf(myChar())
    if not base then return nil end
    local cands = farmCandidates()

    -- Astro 坚守：只打 Astro 怪
    if AUTO.FarmMode == "Astro Holdout Mode" then
        for _, m in ipairs(cands) do
            if string.find(string.lower(m.Name), "astro", 1, true) then
                return m, "Astro", 1, promptOf(m)
            end
        end
        return nil
    end

    local giant, giantPrompt, heli, high, near
    local highHp = tonumber(AUTO.HighHp) or 200
    local bestHp, bestD = highHp, math.huge
    for _, m in ipairs(cands) do
        if not giant and m.Name == "Giant ST toilet" then
            local lever = m:FindFirstChild("lever")
            local pr = lever and lever:FindFirstChildOfClass("ProximityPrompt")
            if pr then giant, giantPrompt = m, pr end
        end
        if not heli and string.find(string.lower(m.Name), "helicopter", 1, true) then
            heli = m
        end
        local hp = mobMaxHp(m)
        if hp > bestHp then bestHp = hp; high = m end
        local p = hrpOf(m)
        if p then
            local d = (p.Position - base.Position).Magnitude
            if d < bestD then bestD = d; near = m end
        end
    end

    if giant and giantPrompt then return giant, "GiantST", 4, giantPrompt end
    if heli then return heli, "直升机", 3 end
    if high then return high, "高血量", 2 end
    if near then return near, "最近怪物", 1 end
    return nil
end

-- 原版 GetTargetCFrame：上方贴最高点、下方贴最低点、环绕贴着怪转
function farmCFrame(mob, extra)
    local padding = (tonumber(AUTO.FarmHeight) or 3) + (extra or 0)
    local center, minY, maxY = mobBounds(mob)
    local pos = AUTO.FarmPos or "Above"

    if pos == "Under" or pos == "下方" then
        local y = math.min(minY - padding, minY - 0.5)
        return CFrame.new(Vector3.new(center.X, y, center.Z), Vector3.new(center.X, minY, center.Z))
    end

    if pos == "Orbit" or pos == "环绕" then
        if AUTO.FarmMode == "Astro Holdout Mode" or AUTO.FarmMode == "Dark Dimension Mode" then
            local y = math.max(maxY + padding, maxY + 0.5)
            return CFrame.new(Vector3.new(center.X, y, center.Z), Vector3.new(center.X, maxY, center.Z))
        end
        local root = hrpOf(mob)
        local fwd = root and root.CFrame.LookVector or Vector3.zero
        local r = tonumber(AUTO.CircleRadius) or 6
        local p = Vector3.new(center.X + fwd.X * r, center.Y + padding, center.Z + fwd.Z * r)
        return CFrame.new(p, center)
    end

    local y = math.max(maxY + padding, maxY + 0.5)
    return CFrame.new(Vector3.new(center.X, y, center.Z), Vector3.new(center.X, maxY, center.Z))
end

----------------------------------------------------------------
-- 屏障夹紧（原版 ClampPositionInsideBarrier）：落点不许穿出 Map.Barrier
----------------------------------------------------------------
local barrierBoundsCache, barrierBoundsAt = nil, 0

function barrierBounds()
    local now = os.clock()
    if barrierBoundsCache and now - barrierBoundsAt < 1.25 then return barrierBoundsCache end
    barrierBoundsAt = now
    barrierBoundsCache = nil
    local map = workspace:FindFirstChild("Map")
    local model = map and map:FindFirstChild("Barrier")
    if not model then return nil end
    local mx, mxx, mz, mxz = math.huge, -math.huge, math.huge, -math.huge
    local function addAll(part)
        local s = part.Size * 0.5
        for _, dx in ipairs({ -s.X, s.X }) do
            for _, dy in ipairs({ -s.Y, s.Y }) do
                for _, dz in ipairs({ -s.Z, s.Z }) do
                    local p = (part.CFrame * CFrame.new(dx, dy, dz)).Position
                    if p.X < mx then mx = p.X end
                    if p.X > mxx then mxx = p.X end
                    if p.Z < mz then mz = p.Z end
                    if p.Z > mxz then mxz = p.Z end
                end
            end
        end
    end
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then addAll(obj) end
    end
    if model:IsA("BasePart") then addAll(model) end
    if mx == math.huge or mxx == -math.huge then return nil end
    barrierBoundsCache = { minX = mx, maxX = mxx, minZ = mz, maxZ = mxz }
    return barrierBoundsCache
end

function clampInsideBarrier(pos)
    local b = barrierBounds()
    if not b then return pos, false end
    local pad = 8
    local x = math.clamp(pos.X, b.minX + pad, b.maxX - pad)
    local z = math.clamp(pos.Z, b.minZ + pad, b.maxZ - pad)
    return Vector3.new(x, pos.Y, z), (math.abs(x - pos.X) > 0.05 or math.abs(z - pos.Z) > 0.05)
end

----------------------------------------------------------------
-- 黑暗维度理智（原版）：ImageTransparency < 0.900 就去捡 OrbSanity，补到 0.950
----------------------------------------------------------------
local sanityCollecting = false

function sanityValue()
    local gui = pg:FindFirstChild("SanityUI")
    local label = gui and gui:FindFirstChild("ImageLabel")
    return label and label.ImageTransparency or nil
end

function nearestSanityOrb()
    local b = hrpOf(myChar())
    if not b then return nil end
    local best, bestD = nil, math.huge
    local containers = { workspace, workspace:FindFirstChild("Living") }
    for _, root in ipairs(containers) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                if d.Name == "OrbSanity" then
                    local part = d:IsA("BasePart") and d or nil
                    if not part then
                        for _, x in ipairs(d:GetDescendants()) do
                            if x:IsA("BasePart") then part = x break end
                        end
                    end
                    if part and (part:FindFirstChild("TouchInterest") or part:FindFirstChildOfClass("TouchTransmitter")) then
                        local dist = (part.Position - b.Position).Magnitude
                        if dist < bestD then best, bestD = part, dist end
                    end
                end
            end
        end
    end
    return best
end

function sanityStep()
    if AUTO.FarmMode ~= "Dark Dimension Mode" or not AUTO.AutoFarm then return false end
    local v = sanityValue()
    if not v or v >= 0.9 then return false end
    if sanityCollecting then return true end
    local part = nearestSanityOrb()
    if not part then return false end
    sanityCollecting = true
    farmLockUntil = os.clock() + 5
    task.spawn(function()
        local c = myChar()
        if c then
            pcall(function() c:PivotTo(CFrame.new(part.Position + Vector3.new(0, 2, 0))) end)
            task.wait(0.35)
            local b = hrpOf(c)
            pcall(function()
                if firetouchinterest and b then
                    firetouchinterest(b, part, 0)
                    task.wait(0.08)
                    firetouchinterest(b, part, 1)
                end
            end)
        end
        task.wait(1)
        sanityCollecting = false
    end)
    AUTO.LastReason = "黑暗维度：理智过低，去捡 OrbSanity"
    if every("sanitylog", 3) then log("黑暗维度：理智过低，已去补理智") end
    return true
end

function showFarmCFrame(cf)
    local c = myChar()
    local b = hrpOf(c)
    if not c or not b or not cf then return end
    -- 原版同样会先夹进屏障，避免补间/传送穿出地图
    local p, clamped = clampInsideBarrier(cf.Position)
    if clamped then
        cf = CFrame.new(p, p + cf.LookVector)
    end
    if AUTO.FarmMove == "Tween" or AUTO.FarmMove == "补间" then
        local tw = TweenService:Create(b, TweenInfo.new(tonumber(AUTO.TweenSpeed) or 1, Enum.EasingStyle.Linear), { CFrame = cf })
        tw:Play()
    else
        pcall(function() c:PivotTo(cf) end)
        pcall(function()
            b.AssemblyLinearVelocity = Vector3.zero
            b.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

local lastFarmAt = 0
-- 覆盖设置（原版）：打不到就每次把高度压 2 格，最低 -30；打到血立刻复位
local paddingAdj = 0
local lastTarget, lastTargetHp, lastTargetAt = nil, nil, 0

function farmStep()
    if not AUTO.AutoFarm or AUTO.Paused then return end
    if os.clock() < farmLockUntil then return end
    if os.clock() - lastFarmAt < 0.15 then return end
    lastFarmAt = os.clock()
    if not hrpOf(myChar()) then return end

    -- 黑暗维度：理智优先，低了先去补
    if sanityStep() then return end

    local mob, tag, prio, prompt = pickFarmTarget()
    if not mob then
        AUTO.LastReason = "自动刷怪：等待怪物"
        return
    end

    local hpObj = mob:FindFirstChildOfClass("Humanoid")
    local cur = hpObj and hpObj.Health or 0
    if mob ~= lastTarget then
        lastTarget, lastTargetHp, lastTargetAt = mob, cur, os.clock()
    elseif lastTargetHp and cur < lastTargetHp - 1 then
        lastTargetHp, lastTargetAt = cur, os.clock()
        paddingAdj = 0
    elseif os.clock() - lastTargetAt > 1.5 then
        paddingAdj = math.max(paddingAdj - 2, -30)
        lastTargetAt = os.clock()
        if every("padlog", 5) then
            log(string.format("覆盖设置：1.5 秒没打到，刷怪高度 %d", paddingAdj))
        end
    end

    local cf = farmCFrame(mob, paddingAdj)
    if cf then
        showFarmCFrame(cf)
    end

    -- Giant ST：贴着怪的同时不停按拉杆
    if tag == "GiantST" and prompt then
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                prompt:InputHoldBegin()
                task.wait(0.1)
                prompt:InputHoldEnd()
            end
        end)
    end

    AUTO.LastReason = "自动刷怪：" .. mob.Name .. "（" .. tag .. "）"
    if AUTO.CombatDebug and every("farmdbg", 3) then
        log(AUTO.LastReason)
    end
end

task.spawn(function()
    local last = nil
    while AUTO.Running do
        local want = AUTO.AutoFarm == true
        if want ~= last then
            last = want
            local h = humOf(myChar())
            if h then
                pcall(function() h.AutoRotate = not want end)
            end
        end
        task.wait(0.5)
    end
end)

function retreatSafe(reason)
    -- 原版安全模式：血量低于阈值就抬到目标怪头顶 111 格，而不是跑回准备板
    local enemy = nearestEnemy(300)
    local p = enemy and hrpOf(enemy)
    local moved = false
    if p then
        moved = moveChar(p.Position + Vector3.new(0, 111, 0), p.Position, "Teleport")
    end
    if not moved then
        local pad = workspace:FindFirstChild("AutoReady")
        if pad then
            moveChar(pad.Position + Vector3.new(0, 6, 0), nil, "Teleport")
        end
    end
    if AUTO.AutoBuyHP then buyHP() end
    if AUTO.AutoPotion then usePotion() end
    AUTO.LastReason = "安全模式撤退：" .. tostring(reason)
    if every("safelog", 3) then log("安全模式撤退：" .. tostring(reason)) end
end

local jeffreyCache, jeffreyStamp = {}, 0
function scanJeffrey()
    jeffreyCache = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and string.find(string.lower(d.Name), "jeffrey", 1, true) then
            local p = hrpOf(d)
            if p then table.insert(jeffreyCache, { model = d, part = p }) end
        end
    end
    jeffreyStamp = os.clock()
end

local lastJeffrey = 0
function jeffreyStep()
    if not (AUTO.BypassJeffrey or AUTO.AntiJeffrey) then return end
    local now = os.clock()
    if now - lastJeffrey < 0.2 then return end
    lastJeffrey = now
    if now - jeffreyStamp > 4 then scanJeffrey() end
    local b = hrpOf(myChar())
    if not b then return end

    -- 绕过 Jeffrey（原版做法）：直接把 Jeffrey 的 Humanoid 坐下，它就彻底不动了
    if AUTO.BypassJeffrey then
        for _, it in ipairs(jeffreyCache) do
            local h = it.model:FindFirstChildOfClass("Humanoid")
            if h and h.Sit ~= true then
                pcall(function() h.Sit = true end)
            end
        end
    end

    -- Anti Jeffrey：把靠近的 Jeffrey 推开，贴到 20 格以内就自己紧急撤
    if AUTO.AntiJeffrey then
        local range = tonumber(AUTO.AntiJeffreyRange) or 50
        for _, it in ipairs(jeffreyCache) do
            if it.part.Parent then
                local delta = it.part.Position - b.Position
                local d = delta.Magnitude
                if d < range then
                    local dir = Vector3.new(delta.X, 0, delta.Z)
                    if dir.Magnitude < 0.1 then dir = Vector3.new(1, 0, 0) end
                    if d < 20 then
                        moveChar(b.Position - dir.Unit * 60 + Vector3.new(0, 10, 0), nil, "Teleport")
                        AUTO.LastReason = "Anti Jeffrey：距离过近，已紧急撤离"
                    else
                        pcall(function()
                            it.part.CFrame = CFrame.new(it.part.Position + dir.Unit * (range - d + 10))
                        end)
                        AUTO.LastReason = "Anti Jeffrey：已推开 Jeffrey"
                    end
                    if every("jefflog", 4) then log(AUTO.LastReason) end
                end
            end
        end
    end
end

local flushCache, flushStamp, lastFlush = {}, 0, 0
function rebuildFlush()
    flushCache = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local n = string.lower(d.Name .. " " .. (d.Parent and d.Parent.Name or ""))
            if string.find(n, "flush", 1, true) or string.find(n, "toilet", 1, true) or string.find(n, "冲刷", 1, true) then
                table.insert(flushCache, d)
            end
        end
    end
    flushStamp = os.clock()
end

function flushStep()
    if not AUTO.FlushAura then return end
    local now = os.clock()
    if now - lastFlush < 0.4 then return end
    lastFlush = now
    if now - flushStamp > 6 then rebuildFlush() end
    local b = hrpOf(myChar())
    if not b then return end
    local range = tonumber(AUTO.FlushAuraRange) or 5
    for _, pr in ipairs(flushCache) do
        if pr.Parent then
            local part = pr.Parent:IsA("BasePart") and pr.Parent or pr.Parent:FindFirstAncestorWhichIsA("BasePart")
            if part and (part.Position - b.Position).Magnitude <= range then
                pcall(function()
                    pr.HoldDuration = 0
                    pr.MaxActivationDistance = 50
                    if fireproximityprompt then fireproximityprompt(pr) end
                    pr:InputHoldBegin()
                    task.wait(0.03)
                    pr:InputHoldEnd()
                end)
            end
        end
    end
end

local resetWaveLast = nil
function resetWaveStep()
    if not AUTO.ResetWave then return end
    local w = waveNumber()
    if not w then return end
    local target = tonumber(AUTO.ResetWaveValue) or 10
    if w >= target and resetWaveLast ~= w then
        resetWaveLast = w
        task.spawn(function()
            local c = myChar()
            if c then
                -- 原版做法：锁住刷怪，瞬移到安全点站住，不让刷怪把人拉回去
                farmLockUntil = os.clock() + 2.2
                local b = hrpOf(c)
                if b then
                    pcall(function() b.AssemblyLinearVelocity = Vector3.zero end)
                    pcall(function() b.AssemblyAngularVelocity = Vector3.zero end)
                end
                pcall(function() c:PivotTo(CFrame.new(1250, 500, 1250)) end)
                task.wait(2)
                AUTO.LastReason = string.format("重置波次：第 %d 波回到安全点", w)
                log(string.format("重置波次：第 %d 波回到安全点", w))
            end
        end)
    elseif w < target then
        resetWaveLast = nil
    end
end

----------------------------------------------------------------
-- 自动收集
----------------------------------------------------------------
local collectCache, collectStamp, lastCollect = {}, 0, 0

function collectNameMatches(name)
    local list = AUTO.CollectItems or {}
    if #list == 0 then return false end
    local low = string.lower(tostring(name or ""))
    for _, w in ipairs(list) do
        local pat = string.lower(tostring(w))
        if pat ~= "" then
            if low == pat then return true end
            if #low > #pat and low:sub(1, #pat) == pat then
                local ch = low:sub(#pat + 1, #pat + 1)
                if ch == " " or ch == "#" or ch == "_" or ch == "-" then return true end
            end
        end
    end
    return false
end

function collectModelOf(prompt)
    local cur = prompt
    while cur and cur ~= workspace do
        if cur:IsA("Model") or cur:IsA("BasePart") then return cur end
        cur = cur.Parent
    end
    return nil
end

function rebuildCollect()
    collectCache = {}
    collectStamp = os.clock()
    -- IDGF：不管列表，所有带交互提示的东西都收
    if AUTO.CollectMode == "IDGF" then
        local seen = {}
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                local obj = collectModelOf(d)
                if obj and not seen[obj] then
                    seen[obj] = true
                    local root = obj:IsA("BasePart") and obj or obj.PrimaryPart
                        or obj:FindFirstChildWhichIsA("BasePart", true)
                    if root then
                        table.insert(collectCache, { obj = obj, root = root })
                    end
                end
            end
        end
        return
    end
    if #(AUTO.CollectItems or {}) == 0 then return end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") or d:IsA("BasePart") then
            if collectNameMatches(d.Name) then
                local root = d:IsA("BasePart") and d or d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart", true)
                if root then
                    table.insert(collectCache, { obj = d, root = root })
                end
            end
        end
    end
    collectStamp = os.clock()
end

function collectStep()
    if not AUTO.AutoCollect or AUTO.Paused then return false end
    if not inMatch() then return false end
    -- 原版：先清完怪再收，不然一边刷怪一边收会互相拉扯
    if enemyCount() > 0 then return false end
    local now = os.clock()
    if now - lastCollect < 1.2 then return false end
    lastCollect = now
    if now - collectStamp > 3 then rebuildCollect() end
    local b = hrpOf(myChar())
    if not b then return false end
    local best, bestD = nil, nil
    for _, it in ipairs(collectCache) do
        if it.obj.Parent and it.root.Parent then
            local d = (it.root.Position - b.Position).Magnitude
            if not bestD or d < bestD then
                best, bestD = it, d
            end
        end
    end
    if not best then return false end
    farmLockUntil = os.clock() + 0.6
    moveChar(best.root.Position + Vector3.new(0, 3, 0), best.root.Position, AUTO.CollectMove)
    for _, d in ipairs(best.obj:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            pcall(function()
                d.HoldDuration = 0
                d.MaxActivationDistance = 50
                if fireproximityprompt then fireproximityprompt(d) end
                d:InputHoldBegin()
            end)
            task.delay(0.05, function()
                pcall(function() d:InputHoldEnd() end)
            end)
        end
    end
    AUTO.LastReason = "自动收集：" .. best.obj.Name
    if every("collectlog", 3) then log("自动收集：" .. best.obj.Name) end
    return true
end

----------------------------------------------------------------
-- 商店：武器 / 杂项 / 请求 / 升级 / 小时购
----------------------------------------------------------------
local lastShop = 0

function shopFire(item)
    if item == nil or item == "" then return false end
    return fireRemote("ShopSystem", "Buy", item)
end

function shopStep()
    local heavy = AUTO.AutoBuyWeapon or AUTO.AutoBuyMisc or AUTO.AutoRequest
        or AUTO.UpgradeTitanSpeaker or AUTO.UpgradeUTCM or AUTO.UpgradeTV or AUTO.AutoHourly
    if not heavy then return false end
    local now = os.clock()
    if now - lastShop < 10 then return false end
    lastShop = now
    local n = 0
    -- 原版节奏：每件之间留 0.35 秒，避免请求挤在一起被服务器丢掉
    if AUTO.AutoBuyWeapon then
        if shopFire(AUTO.WeaponName) then n = n + 1 end
        task.wait(0.35)
    end
    if AUTO.AutoBuyMisc then
        if shopFire(AUTO.MiscName) then n = n + 1 end
        task.wait(0.35)
    end
    if AUTO.AutoRequest then
        local w = waveNumber() or 0
        if w >= 10 then
            if shopFire(AUTO.RequestName) then n = n + 1 end
            task.wait(0.35)
        elseif every("reqwarn", 20) then
            log("自动请求：需要第 10 波或更高")
        end
    end
    if AUTO.UpgradeTitanSpeaker then
        for _, u in ipairs(AUTO.TitanUpgrades or {}) do
            fireRemote("ChangeUpgradedTitanSpeaker", u)
            task.wait(0.35)
        end
    end
    if AUTO.UpgradeUTCM then
        for _, u in ipairs(AUTO.UTCMUpgrades or {}) do
            fireRemote("ForUpgradeUTCM", u)
            task.wait(0.35)
        end
    end
    if AUTO.UpgradeTV then
        for _, u in ipairs(AUTO.TVUpgrades or {}) do
            fireRemote("ForUpgradeTV", u)
            task.wait(0.35)
        end
    end
    if AUTO.AutoHourly then
        local amount = math.max(1, math.floor(tonumber(AUTO.HourlyAmount) or 1))
        for _, item in ipairs(AUTO.HourlyItems or {}) do
            fireRemote("BuyItemFromShopHourly", item, amount)
            task.wait(0.35)
        end
        if AUTO.HourlyCustom and AUTO.HourlyCustom ~= "" then
            fireRemote("BuyItemFromShopHourly", AUTO.HourlyCustom, amount)
        end
    end
    if n > 0 then log("商店：已请求购买 " .. n .. " 件物品") end
    return true
end

function useAutoItem()
    if not AUTO.AutoUseItem then return false end
    if not every("useitem", 3) then return false end
    if AUTO.UseItemName == "Presents" then
        if fireRemote("GachaCapsule") then
            log("自动使用物品：礼物（开胶囊）")
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 自动游戏模式（大厅）
----------------------------------------------------------------
function autoGameModeLobby()
    if not AUTO.AutoGameModeLobby or AUTO.Paused then return end
    if inMatch() then return end
    if not every("agmloop", 2) then return end
    if AUTO.GameMode == nil or AUTO.GameMode == "" then return end
    -- 新版客户端没有 Play.Classic / mode select2 / Lobby 这套旧界面，选模式统一走投票遥控
    if not votePhase() then return end
    local remote = RS:FindFirstChild("Vote")
    if remote then
        pcall(function() remote:FireServer(AUTO.GameMode) end)
        AUTO.LastReason = "自动游戏模式：已投 " .. tostring(AUTO.GameMode)
        if every("agmlog", 6) then log("自动游戏模式：已投 " .. tostring(AUTO.GameMode)) end
    end
end

----------------------------------------------------------------
-- 兑换码 / 通行证 / 配置 / 服务器
----------------------------------------------------------------
local REDEEM_ALL = {
    "100MVisit2", "100MVisit1", "CamArmada", "CCTVBase",
    "ADelayedGameIsEventuallyGoodButRushedGameIsForeverBad",
}

function redeemCodes(codes)
    local n = 0
    for _, code in ipairs(codes or {}) do
        if code and code ~= "" then
            if fireRemote("RedeemCode", code) then n = n + 1 end
            task.wait(0.25)
        end
    end
    return n
end

function unlockPasses(list)
    local gd = player:FindFirstChild("GachaData")
    if not gd then
        gd = Instance.new("Folder")
        gd.Name = "GachaData"
        gd.Parent = player
    end
    local names = {}
    for _, v in ipairs(list or {}) do
        if v == "全部" or v == "All" then
            names = { "LuckyBoost", "RareLuckyBoost", "LegendaryLuckyBoost" }
            break
        else
            table.insert(names, v)
        end
    end
    local n = 0
    for _, name in ipairs(names) do
        local bv = gd:FindFirstChild(name)
        if not bv then
            bv = Instance.new("BoolValue")
            bv.Name = name
            bv.Parent = gd
        end
        bv.Value = true
        n = n + 1
    end
    return n
end

local CONFIG_FILE = "难度模式_配置.json"
local CONFIG_SKIP = {
    Actions = true, Logs = true, Running = true, Paused = true,
    Phase = true, LastReason = true, VoteState = true, Target = true,
}

function configSnapshot()
    local data = {}
    for k, v in pairs(AUTO) do
        local tv = type(v)
        if not CONFIG_SKIP[k] then
            if tv == "boolean" or tv == "number" or tv == "string" then
                data[k] = v
            elseif tv == "table" then
                if k == "ESPItems" or k == "ESPSettings" or k == "TitanUpgrades"
                    or k == "UTCMUpgrades" or k == "TVUpgrades" or k == "HourlyItems"
                    or k == "CollectItems" or k == "SelectedCodes" or k == "SelectedPasses" then
                    data[k] = v
                end
            end
        end
    end
    return data
end

function saveConfig()
    if type(writefile) ~= "function" then return false end
    return pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(configSnapshot()))
    end)
end

function jumpServer()
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        ))
    end)
    local list = {}
    if ok and res and res.data then
        for _, s in ipairs(res.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                table.insert(list, s.id)
            end
        end
    end
    if #list > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1, #list)], player)
        return true
    end
    return false
end

task.spawn(function()
    while AUTO.Running do
        local d = tonumber(AUTO.AutoSaveDelay) or 15
        if d < 1 then d = 1 end
        task.wait(d)
        if AUTO.AutoSave and AUTO.Running then
            pcall(saveConfig)
        end
    end
end)

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 II：目标 / 走位 / 保命 / 武器（全部默认关闭）
-- ============================================================
----------------------------------------------------------------
AUTO.Logs = AUTO.Logs or {}
AUTO._RT = AUTO._RT or {}
AUTO.Stats = AUTO.Stats or {}

local X_DEFAULTS = {
    -- 目标与战斗
    AutoTargetPriority = false, TargetPriority = "智能",
    AutoFocusBoss = false, BossRange = 150, BossKeywords = { "boss", "giant", "titan", "king", "queen", "elite" },
    AutoKite = false, KiteMin = 12, KiteMax = 38, KiteGap = 0.35,
    AutoOrbit = false, OrbitRadius = 14, OrbitSpeed = 0.9, OrbitHeight = 4,
    AutoStrafe = false, StrafeDistance = 7, StrafeGap = 0.8,
    AutoJumpDodge = false, JumpDodgeRange = 20, JumpDodgeGap = 0.7,
    AutoRetreatHeal = false, RetreatHp = 25, RetreatDistance = 50,
    AutoEmergencyTeleport = false, EmergencyHp = 12, EmergencyDistance = 80,
    AutoBossWarn = false, BossWarnRange = 200,
    AutoWaveMonitor = false,
    AutoAssistAlly = false, AssistRange = 60,
    AutoReviveChain = false, ReviveChainRange = 120,
    AutoWeaponSwitch = false, WeaponPriority = {}, WeaponMinScore = 0,
    AutoSkillBurst = false, BurstWindow = 2.2, BurstCount = 2, BurstGap = 0.18,
    AutoSkillHold = false, SkillMinEnemies = 3, SkillHoldBoss = false,
    AutoAmmoCheck = false, AutoReload = true,
    AutoLowHpNotify = false, LowHpNotifyValue = 30,
    AutoHealAlly = false, HealAllyHp = 40,
}

for k, v in pairs(X_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

----------------------------------------------------------------
-- 扩展框架：通用工具（不与旧函数重名）
----------------------------------------------------------------
function xSt(name)
    local t = AUTO._RT[name]
    if not t then
        t = {}
        AUTO._RT[name] = t
    end
    return t
end

function xClamp(n, lo, hi)
    n = tonumber(n) or lo
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end

function xRound(n)
    n = tonumber(n) or 0
    if n >= 0 then return math.floor(n + 0.5) end
    return math.ceil(n - 0.5)
end

function xFmt(n)
    n = tonumber(n) or 0
    if n >= 100000000 then return string.format("%.2f亿", n / 100000000) end
    if n >= 10000 then return string.format("%.2f万", n / 10000) end
    return tostring(xRound(n))
end

function xFindRemote(name)
    if not name or name == "" then return nil end
    local direct = RS:FindFirstChild(name)
    if direct then return direct end
    local ok, found = pcall(function()
        return RS:FindFirstChild(name, true)
    end)
    if ok then return found end
    return nil
end

function xFire(name, ...)
    local r = xFindRemote(name)
    if not r or not r:IsA("RemoteEvent") then return false end
    local args = { n = select("#", ...), ... }
    local ok = pcall(function()
        r:FireServer(table.unpack(args, 1, args.n))
    end)
    return ok
end

function xInvoke(name, ...)
    local r = xFindRemote(name)
    if not r or not r:IsA("RemoteFunction") then return false end
    local args = { n = select("#", ...), ... }
    local ok = pcall(function()
        r:InvokeServer(table.unpack(args, 1, args.n))
    end)
    return ok
end

function xHum2()
    local c = player.Character
    if not c or not c.Parent then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

function xRoot2()
    local c = player.Character
    if not c or not c.Parent then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart
end

function xAlive2()
    local h = xHum2()
    return h ~= nil and h.Health > 0
end

function xHpPct()
    local h = xHum2()
    if not h or h.MaxHealth <= 0 then return 0 end
    return h.Health / h.MaxHealth * 100
end

function xPosOf(inst)
    if not inst then return nil end
    if inst:IsA("Model") then
        local p = inst:FindFirstChild("HumanoidRootPart") or inst.PrimaryPart
        if p then return p.Position end
        local ok, found = pcall(function() return inst:FindFirstChildWhichIsA("BasePart", true) end)
        if ok and found then return found.Position end
        return nil
    end
    if inst:IsA("BasePart") then return inst.Position end
    return nil
end

function xDistTo(pos)
    local base = xRoot2()
    if not base or not pos then return math.huge end
    return (pos - base.Position).Magnitude
end

function xEnemyList(maxDist, cacheKey)
    local list = {}
    local folder = living()
    if not folder then return list end
    local base = xRoot2()
    if not base then return list end
    local limit = tonumber(maxDist) or math.huge
    local key = cacheKey or "default"
    local cache = xSt("enemyCache")
    local now = os.clock()
    if cache[key] and now - cache[key].t < 0.2 then
        return cache[key].list
    end
    for _, m in ipairs(folder:GetChildren()) do
        if isEnemy(m) then
            local p = xPosOf(m)
            if p then
                local d = (p - base.Position).Magnitude
                if d <= limit then
                    table.insert(list, { model = m, pos = p, dist = d })
                end
            end
        end
    end
    cache[key] = { t = now, list = list }
    return list
end

function xAllyList(maxDist)
    local list = {}
    local base = xRoot2()
    if not base then return list end
    local limit = tonumber(maxDist) or math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            local p = xPosOf(plr.Character)
            if h and p then
                local d = (p - base.Position).Magnitude
                if d <= limit then
                    table.insert(list, {
                        player = plr, model = plr.Character, hum = h,
                        pos = p, dist = d, hp = h.Health, maxhp = h.MaxHealth,
                    })
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    return list
end

function xIsBoss(m)
    if not m then return false end
    local keys = AUTO.BossKeywords or {}
    local low = string.lower(m.Name)
    for _, k in ipairs(keys) do
        if string.find(low, string.lower(tostring(k)), 1, true) then return true end
    end
    local h = m:FindFirstChildOfClass("Humanoid")
    if h and h.MaxHealth >= (tonumber(AUTO.BossHpThreshold) or 5000) then return true end
    local ok, v = pcall(function() return m:GetAttribute("IsBoss") end)
    if ok and v == true then return true end
    return false
end

function xTargetScore(entry, mode)
    if not entry then return -math.huge end
    local h = entry.model:FindFirstChildOfClass("Humanoid")
    local hp = h and h.Health or 1
    local maxhp = h and h.MaxHealth or 1
    local score = 0
    if mode == "最近" then
        score = -entry.dist
    elseif mode == "最远" then
        score = entry.dist
    elseif mode == "残血" then
        score = 10000 - (hp / math.max(1, maxhp)) * 1000 - entry.dist * 0.01
    elseif mode == "高血量" then
        score = hp * 0.01 - entry.dist * 0.01
    elseif mode == "Boss优先" then
        score = (xIsBoss(entry.model) and 100000 or 0) + maxhp * 0.01 - entry.dist * 0.01
    else
        local base = 0
        if xIsBoss(entry.model) then base = base + 50000 end
        if maxhp > 0 then base = base + (hp / maxhp) * 300 end
        base = base + math.max(0, 60 - entry.dist) * 6
        score = base
    end
    return score
end

function xPickTarget(maxDist, mode)
    local list = xEnemyList(maxDist)
    local best, bestScore = nil, -math.huge
    local useMode = mode or AUTO.TargetPriority or "智能"
    for _, e in ipairs(list) do
        if AUTO.AutoFarm and AUTO.FarmMode == "Astro Holdout Mode" and e.model.Name == "Giant ST toilet" then
            -- 坚守模式忽略这个目标
        else
            local s = xTargetScore(e, useMode)
            if s > bestScore then
                best, bestScore = e, s
            end
        end
    end
    return best
end

function xTp(pos, lookPos)
    if not pos then return false end
    local c = player.Character
    if not c then return false end
    local base = xRoot2()
    if not base then return false end
    local ok = pcall(function()
        if lookPos then
            c:PivotTo(CFrame.lookAt(pos, lookPos))
        else
            c:PivotTo(CFrame.new(pos))
        end
    end)
    if not ok then
        pcall(function() base.CFrame = lookPos and CFrame.lookAt(pos, lookPos) or CFrame.new(pos) end)
    end
    pcall(function()
        base.AssemblyLinearVelocity = Vector3.zero
        base.AssemblyAngularVelocity = Vector3.zero
    end)
    return true
end

function xWalkTo(pos)
    local h = xHum2()
    if not h or not pos then return false end
    pcall(function() h:MoveTo(pos) end)
    return true
end

function xJump()
    local h = xHum2()
    if not h then return false end
    pcall(function() h.Jump = true end)
    pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
    return true
end

function xSetSpeed(v)
    local h = xHum2()
    if not h then return false end
    pcall(function() h.WalkSpeed = tonumber(v) or 16 end)
    return true
end

function xStatAdd(key, n)
    if not key then return end
    AUTO.Stats[key] = (tonumber(AUTO.Stats[key]) or 0) + (tonumber(n) or 1)
end

function xToast(key, title, text, gap)
    local s = xSt("toast")
    local now = os.clock()
    local wait = tonumber(gap) or 8
    if (s[key] or 0) + wait > now then return false end
    s[key] = now
    notify(title, text)
    return true
end

function xSafePoint(awayPos, distance)
    local base = xRoot2()
    if not base then return nil end
    local away = Vector3.new(0, 0, 0)
    local n = 0
    for _, e in ipairs(xEnemyList(200)) do
        local d = e.pos - base.Position
        if d.Magnitude > 0 then
            away = away - d.Unit
            n = n + 1
        end
    end
    if n > 0 and away.Magnitude > 0 then
        away = away.Unit
    elseif awayPos then
        local d = base.Position - awayPos
        away = d.Magnitude > 0 and d.Unit or Vector3.new(0, 0, 1)
    else
        away = Vector3.new(0, 0, 1)
    end
    local dist = tonumber(distance) or 45
    return base.Position + away * dist + Vector3.new(0, 4, 0)
end

function xFindTool(keyword)
    local c = player.Character
    if not c then return nil end
    local low = string.lower(tostring(keyword or ""))
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            if low == "" or string.find(string.lower(t.Name), low, 1, true) then
                return t
            end
        end
    end
    return nil
end

function xEquipTool(tool)
    if not tool then return false end
    local h = xHum2()
    if not h then return false end
    if tool.Parent == player.Character then
        local cur = player.Character:FindFirstChildOfClass("Tool")
        if cur == tool then return true end
    end
    local ok = pcall(function() h:EquipTool(tool) end)
    if ok then xStatAdd("换武器", 1) end
    return ok
end

function xItemCount(name)
    local bp = player:FindFirstChild("Backpack")
    local p = player:FindFirstChild("PlayerGui")
    local count = 0
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and (name == nil or t.Name == name) then
                count = count + 1
            end
        end
    end
    if p then
        local ok, found = pcall(function() return p:FindFirstChild("Inventory") end)
        if ok and found then
            for _, obj in ipairs(found:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text and tonumber(obj.Text) then
                    -- 只作为界面数字参考，不强行使用
                end
            end
        end
    end
    return count
end

function xNearPrompts(radius)
    local cache = xSt("promptCache")
    local now = os.clock()
    if cache.t and now - cache.t < 1.5 then return cache.list end
    local base = xRoot2()
    if not base then return {} end
    local list = {}
    local ok = pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    local d = (part.Position - base.Position).Magnitude
                    if d <= (tonumber(radius) or 20) then
                        table.insert(list, { prompt = obj, part = part, dist = d, name = part.Name })
                    end
                end
            end
        end
    end)
    if not ok then list = {} end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    cache.t = now
    cache.list = list
    return list
end

function xUsePrompt(prompt, hold)
    if not prompt then return false end
    local ok = pcall(function()
        if hold ~= nil then
            prompt:InputHoldBegin()
            task.delay(tonumber(prompt.HoldDuration) or 0.2, function()
                pcall(function() prompt:InputHoldEnd() end)
            end)
        else
            prompt:InputHoldBegin()
            task.wait(0.05)
            prompt:InputHoldEnd()
        end
    end)
    if ok then xStatAdd("互动", 1) end
    return ok
end

----------------------------------------------------------------
-- 1. 目标优先级
----------------------------------------------------------------
function autoTargetPriority()
    if not AUTO.AutoTargetPriority then return false end
    if AUTO.Paused then return false end
    if not every("x_target", 0.35) then return false end
    local pick = xPickTarget(tonumber(AUTO.Range) or 500, AUTO.TargetPriority)
    if not pick then
        AUTO.PriorityTarget = nil
        return false
    end
    AUTO.PriorityTarget = pick.model.Name
    AUTO.PriorityTargetHp = 0
    local h = pick.model:FindFirstChildOfClass("Humanoid")
    if h then AUTO.PriorityTargetHp = xRound(h.Health) end
    AUTO.Target = pick.model.Name
    AUTO.LastReason = string.format("优先级[%s]：%s（%d 格）",
        tostring(AUTO.TargetPriority), pick.model.Name, xRound(pick.dist))
    return true
end

----------------------------------------------------------------
-- 2. 自动集火 Boss
----------------------------------------------------------------
function autoFocusBoss()
    if not AUTO.AutoFocusBoss then return false end
    if AUTO.Paused then return false end
    if not every("x_boss", 0.6) then return false end
    local range = tonumber(AUTO.BossRange) or 150
    local best = nil
    for _, e in ipairs(xEnemyList(range)) do
        if xIsBoss(e.model) then
            if not best or e.dist < best.dist then best = e end
        end
    end
    if not best then
        AUTO.BossTarget = nil
        return false
    end
    AUTO.BossTarget = best.model.Name
    AUTO.BossDistance = xRound(best.dist)
    if AUTO.AutoAim then
        aimAt(best.pos + Vector3.new(0, 1.2, 0))
    end
    if AUTO.AutoFight then
        ensureFire()
    end
    if AUTO.AutoSkill then
        useSkills(best.pos)
    end
    AUTO.LastReason = string.format("集火 Boss：%s（%d 格）", best.model.Name, xRound(best.dist))
    if xToast("boss_focus", "Boss 集火", "已锁定 " .. best.model.Name, 10) then
        log("Boss 集火：" .. best.model.Name)
    end
    return true
end

----------------------------------------------------------------
-- 3. 风筝走位：太近后退，太远靠近
----------------------------------------------------------------
function autoKite()
    if not AUTO.AutoKite then return false end
    if AUTO.Paused then return false end
    if not every("x_kite", tonumber(AUTO.KiteGap) or 0.35) then return false end
    local base = xRoot2()
    if not base then return false end
    local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
    if not pick then return false end
    local minD = tonumber(AUTO.KiteMin) or 12
    local maxD = tonumber(AUTO.KiteMax) or 38
    if pick.dist < minD then
        local away = base.Position - pick.pos
        if away.Magnitude <= 0.01 then away = Vector3.new(0, 0, 1) end
        local dest = base.Position + away.Unit * (minD + 4)
        if AUTO.KiteTeleport ~= false then
            xTp(dest, pick.pos)
        else
            xWalkTo(dest)
        end
        AUTO.LastReason = string.format("风筝：%s 太近（%d 格），后撤", pick.model.Name, xRound(pick.dist))
        xStatAdd("风筝后撤", 1)
        return true
    elseif pick.dist > maxD then
        local dir = (pick.pos - base.Position).Unit
        local dest = pick.pos - dir * (maxD - 4) + Vector3.new(0, 4, 0)
        if AUTO.KiteTeleport ~= false then
            xTp(dest, pick.pos)
        else
            xWalkTo(dest)
        end
        AUTO.LastReason = string.format("风筝：接近 %s（%d 格）", pick.model.Name, xRound(pick.dist))
        xStatAdd("风筝接近", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 4. 环绕走位
----------------------------------------------------------------
function autoOrbit()
    if not AUTO.AutoOrbit then return false end
    if AUTO.Paused then return false end
    if not every("x_orbit", 0.12) then return false end
    local base = xRoot2()
    if not base then return false end
    local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
    if not pick then return false end
    local state = xSt("orbit")
    state.angle = (state.angle or 0) + (tonumber(AUTO.OrbitSpeed) or 0.9) * 0.12
    local radius = tonumber(AUTO.OrbitRadius) or 14
    local height = tonumber(AUTO.OrbitHeight) or 4
    local offset = Vector3.new(
        math.cos(state.angle) * radius,
        height,
        math.sin(state.angle) * radius
    )
    local dest = pick.pos + offset
    if AUTO.OrbitTeleport ~= false then
        xTp(dest, pick.pos)
    else
        xWalkTo(dest)
    end
    AUTO.LastReason = string.format("环绕：%s（半径 %d）", pick.model.Name, xRound(radius))
    xStatAdd("环绕", 1)
    return true
end

----------------------------------------------------------------
-- 5. 左右横移（躲避瞄准）
----------------------------------------------------------------
function autoStrafe()
    if not AUTO.AutoStrafe then return false end
    if AUTO.Paused then return false end
    if not every("x_strafe", tonumber(AUTO.StrafeGap) or 0.8) then return false end
    local base = xRoot2()
    if not base then return false end
    local pick = xPickTarget(tonumber(AUTO.Range) or 200, AUTO.TargetPriority)
    if not pick then return false end
    local delta = pick.pos - base.Position
    if delta.Magnitude <= 0.01 then return false end
    local dir = delta.Unit
    local right = Vector3.new(dir.Z, 0, -dir.X)
    local state = xSt("strafe")
    state.side = (state.side == 1) and -1 or 1
    local dist = tonumber(AUTO.StrafeDistance) or 7
    local dest = base.Position + right * (dist * state.side)
    if AUTO.StrafeTeleport ~= false then
        xTp(dest, pick.pos)
    else
        xWalkTo(dest + dir * 2)
    end
    AUTO.LastReason = state.side == 1 and "横移：向右" or "横移：向左"
    xStatAdd("横移", 1)
    return true
end

----------------------------------------------------------------
-- 6. 跳跃闪避（近身 / 投射物）
----------------------------------------------------------------
function autoJumpDodge()
    if not AUTO.AutoJumpDodge then return false end
    if AUTO.Paused then return false end
    if not every("x_jumpdodge", tonumber(AUTO.JumpDodgeGap) or 0.7) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.JumpDodgeRange) or 20
    local danger = false
    local list = xEnemyList(range)
    if #list > 0 then danger = true end
    if not danger then
        local incoming = findIncoming and findIncoming(base)
        if incoming then danger = true end
    end
    if not danger then return false end
    xJump()
    local pick = list[1]
    if pick then
        local dir = (base.Position - pick.pos)
        if dir.Magnitude > 0.01 then
            xTp(base.Position + dir.Unit * 5 + Vector3.new(0, 3, 0), pick.pos)
        end
    end
    xStatAdd("跳跃闪避", 1)
    AUTO.LastReason = "跳跃闪避：拉开距离"
    return true
end

----------------------------------------------------------------
-- 7. 低血撤退（保留治疗窗口）
----------------------------------------------------------------
function autoRetreatHeal()
    if not AUTO.AutoRetreatHeal then return false end
    if AUTO.Paused then return false end
    if not every("x_retreat", 0.8) then return false end
    local hp = xHpPct()
    local threshold = tonumber(AUTO.RetreatHp) or 25
    if hp > threshold then
        xSt("retreat").active = false
        return false
    end
    local pos = xSafePoint(nil, tonumber(AUTO.RetreatDistance) or 50)
    if not pos then return false end
    xTp(pos)
    xSt("retreat").active = true
    xStatAdd("撤退", 1)
    AUTO.LastReason = string.format("低血撤退：%.0f%% → 安全点", hp)
    if xToast("retreat", "保命", string.format("血量 %.0f%%，已撤退", hp), 6) then
        log("低血撤退：血量 " .. xRound(hp) .. "%")
    end
    return true
end

----------------------------------------------------------------
-- 8. 紧急传送（濒死）
----------------------------------------------------------------
function autoEmergencyTeleport()
    if not AUTO.AutoEmergencyTeleport then return false end
    if AUTO.Paused then return false end
    if not every("x_emergency", 0.5) then return false end
    local hp = xHpPct()
    local critical = tonumber(AUTO.EmergencyHp) or 12
    if hp > critical then
        xSt("emergency").active = false
        return false
    end
    local state = xSt("emergency")
    if state.active then return false end
    local pos = xSafePoint(nil, tonumber(AUTO.EmergencyDistance) or 80)
    if not pos then return false end
    xTp(pos)
    state.active = true
    xStatAdd("紧急传送", 1)
    AUTO.LastReason = string.format("紧急传送：血量 %.0f%%", hp)
    notify("紧急保命", string.format("血量 %.0f%%，已传送到安全点", hp))
    return true
end

----------------------------------------------------------------
-- 9. Boss 出现提醒
----------------------------------------------------------------
function autoBossWarn()
    if not AUTO.AutoBossWarn then return false end
    if not every("x_bosswarn", 2) then return false end
    local range = tonumber(AUTO.BossWarnRange) or 200
    for _, e in ipairs(xEnemyList(range)) do
        if xIsBoss(e.model) then
            local key = "boss_" .. e.model.Name
            if xToast(key, "Boss 警报", string.format("%s 出现在 %d 格外", e.model.Name, xRound(e.dist)), 30) then
                log("Boss 警报：" .. e.model.Name)
                xStatAdd("Boss警报", 1)
            end
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 10. 波次监测（记录波次变化 / 击杀节奏）
----------------------------------------------------------------
function autoWaveMonitor()
    if not AUTO.AutoWaveMonitor then return false end
    if not every("x_wave", 1) then return false end
    local w = waveNumber and waveNumber()
    if not w then return false end
    local state = xSt("wave")
    if state.last ~= w then
        if state.last ~= nil then
            local elapsed = os.clock() - (state.start or os.clock())
            log(string.format("波次监测：第 %s 波结束，用时 %.1f 秒", tostring(state.last), elapsed))
            xStatAdd("波次", 1)
        end
        state.last = w
        state.start = os.clock()
        AUTO.WaveNow = w
        AUTO.WaveStartAt = os.clock()
        if xToast("wave_up", "波次", "进入第 " .. tostring(w) .. " 波", 3) then
            log("波次监测：进入第 " .. tostring(w) .. " 波")
        end
    end
    return true
end

----------------------------------------------------------------
-- 11. 协助队友（队友附近有敌人时帮忙清）
----------------------------------------------------------------
function autoAssistAlly()
    if not AUTO.AutoAssistAlly then return false end
    if AUTO.Paused then return false end
    if not every("x_assist", 0.6) then return false end
    local range = tonumber(AUTO.AssistRange) or 60
    local target = nil
    for _, a in ipairs(xAllyList(range)) do
        if a.hp > 0 and a.hp < a.maxhp * 0.8 then
            target = a
            break
        end
    end
    if not target then return false end
    local enemy, dist = nearestEnemy(range)
    if not enemy then return false end
    local ep = hrpOf(enemy)
    if not ep then return false end
    if AUTO.AutoAim then aimAt(ep.Position + Vector3.new(0, 1.2, 0)) end
    if AUTO.AutoFight then ensureFire() end
    AUTO.LastReason = string.format("协助队友 %s（敌人 %s，%d 格）",
        target.player.Name, enemy.Name, xRound(dist or 0))
    xStatAdd("协助队友", 1)
    return true
end

----------------------------------------------------------------
-- 12. 复活链（优先救最近的倒地队友）
----------------------------------------------------------------
function autoReviveChain()
    if not AUTO.AutoReviveChain then return false end
    if AUTO.Paused then return false end
    if not every("x_revivechain", 0.5) then return false end
    local range = tonumber(AUTO.ReviveChainRange) or 120
    local best = nil
    for _, a in ipairs(xAllyList(range)) do
        if a.hp <= 0 then
            if not best or a.dist < best.dist then best = a end
        end
    end
    if not best then return false end
    local base = xRoot2()
    if not base then return false end
    if best.dist > 8 then
        local dir = (best.pos - base.Position)
        if dir.Magnitude > 0.01 then
            xTp(best.pos - dir.Unit * 3 + Vector3.new(0, 3, 0), best.pos)
        end
    end
    local n = 0
    pcall(function() n = tryRevive() end)
    AUTO.LastReason = string.format("复活链：赶往 %s（%d 格）", best.player.Name, xRound(best.dist))
    if n and n > 0 then xStatAdd("复活队友", n) end
    return true
end

----------------------------------------------------------------
-- 13. 自动换武器（按优先词 / 评分）
----------------------------------------------------------------
function autoWeaponSwitch()
    if not AUTO.AutoWeaponSwitch then return false end
    if AUTO.Paused then return false end
    if not every("x_weapon", 1.2) then return false end
    local c = player.Character
    if not c then return false end
    local tools = {}
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    if #tools == 0 then return false end
    local priority = AUTO.WeaponPriority or {}
    local function score(t)
        local s = tonumber(AUTO.WeaponMinScore) or 0
        for i, w in ipairs(priority) do
            if string.lower(t.Name) == string.lower(tostring(w)) then
                s = s + 1000 - i
            elseif string.find(string.lower(t.Name), string.lower(tostring(w)), 1, true) then
                s = s + 500 - i
            end
        end
        local ok, dmg = pcall(function()
            local v = t:GetAttribute("Damage") or t:GetAttribute("DamageValue")
            return tonumber(v) or 0
        end)
        if ok then s = s + dmg end
        local low = string.lower(t.Name)
        if string.find(low, "launcher", 1, true) or string.find(low, "rpg", 1, true) then s = s + 80 end
        if string.find(low, "shotgun", 1, true) then s = s + 60 end
        if string.find(low, "rifle", 1, true) or string.find(low, "gun", 1, true) then s = s + 50 end
        if string.find(low, "sword", 1, true) or string.find(low, "katana", 1, true) then s = s + 40 end
        return s
    end
    local best, bestScore = nil, -math.huge
    for _, t in ipairs(tools) do
        local s = score(t)
        if s > bestScore then best, bestScore = t, s end
    end
    if not best then return false end
    if best.Parent ~= c then
        if xEquipTool(best) then
            AUTO.LastReason = "换武器：" .. best.Name
            log("自动换武器：" .. best.Name .. "（评分 " .. xRound(bestScore) .. "）")
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 14. 技能爆发（短窗口内连续释放）
----------------------------------------------------------------
function autoSkillBurst()
    if not AUTO.AutoSkillBurst then return false end
    if AUTO.Paused then return false end
    local state = xSt("burst")
    local now = os.clock()
    if state.until_ and now < state.until_ then
        if every("x_burst_cast", tonumber(AUTO.BurstGap) or 0.18) then
            local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
            if pick then
                useSkills(pick.pos)
                xStatAdd("爆发施法", 1)
            end
        end
        return true
    end
    if not every("x_burst_check", 1) then return false end
    local list = xEnemyList(tonumber(AUTO.Range) or 300)
    local need = tonumber(AUTO.BurstCount) or 2
    local boss = false
    for _, e in ipairs(list) do
        if xIsBoss(e.model) then boss = true break end
    end
    if #list >= need or boss then
        state.until_ = now + (tonumber(AUTO.BurstWindow) or 2.2)
        local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
        if pick then
            useSkills(pick.pos)
            AUTO.LastReason = string.format("技能爆发：%s", pick.model.Name)
            log("技能爆发：目标 " .. pick.model.Name)
        end
        xStatAdd("爆发次数", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 15. 技能保留（敌人太少时不开技能）
----------------------------------------------------------------
function xCanCastSkills()
    if not AUTO.AutoSkillHold then return true end
    local need = tonumber(AUTO.SkillMinEnemies) or 3
    local list = xEnemyList(tonumber(AUTO.Range) or 300)
    if #list >= need then return true end
    if AUTO.SkillHoldBoss then
        for _, e in ipairs(list) do
            if xIsBoss(e.model) then return true end
        end
    end
    return false
end

function autoSkillHold()
    if not AUTO.AutoSkillHold then return false end
    if AUTO.Paused then return false end
    AUTO._HoldSkills = not xCanCastSkills()
    if every("x_skillhold_log", 15) then
        log("技能保留：" .. (AUTO._HoldSkills and "暂不开技能（敌人不足）" or "允许开技能"))
    end
    return AUTO._HoldSkills
end

----------------------------------------------------------------
-- 16. 弹药检查 / 自动换弹
----------------------------------------------------------------
local xFindPromptByKeyword

function autoAmmoCheck()
    if not AUTO.AutoAmmoCheck then return false end
    if AUTO.Paused then return false end
    if not every("x_ammo", 0.8) then return false end
    local c = player.Character
    if not c then return false end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local ammo = nil
    for _, key in ipairs({ "Ammo", "AmmoCount", "AmmoValue", "Bullets", "Magazine" }) do
        local ok, v = pcall(function() return tool:GetAttribute(key) end)
        if ok and tonumber(v) then
            ammo = tonumber(v)
            break
        end
    end
    if ammo == nil then return false end
    if ammo > 0 then return false end
    if AUTO.AutoReload then
        if xFire("Reload") or xFire("ReloadWeapon") then
            log("弹药检查：已请求换弹")
            xStatAdd("换弹", 1)
            return true
        end
        local prompt = xFindPromptByKeyword and xFindPromptByKeyword("reload")
        if prompt then
            xUsePrompt(prompt)
            log("弹药检查：已触发换弹提示")
            xStatAdd("换弹", 1)
            return true
        end
    end
    if AUTO.AutoWeaponSwitch then
        local other = nil
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and t ~= tool then other = t break end
            end
        end
        if other and xEquipTool(other) then
            log("弹药检查：弹匣空了，切换到 " .. other.Name)
            xStatAdd("空弹切换", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 17. 低血提醒（语音式日志 + 通知）
----------------------------------------------------------------
function autoLowHpNotify()
    if not AUTO.AutoLowHpNotify then return false end
    if not every("x_lowhp", 1) then return false end
    local hp = xHpPct()
    local threshold = tonumber(AUTO.LowHpNotifyValue) or 30
    local state = xSt("lowhp")
    if hp > 0 and hp <= threshold then
        if not state.on then
            state.on = true
            notify("血量警告", string.format("当前血量 %.0f%%，注意补血", hp))
            log(string.format("血量警告：%.0f%%", hp))
            xStatAdd("低血警告", 1)
        end
    elseif hp > threshold + 5 then
        state.on = false
    end
    return state.on == true
end

-- 供弹药检查使用的提示查找（在批量扫描里按名字找）
xFindPromptByKeyword = function(keyword)
    local list = xNearPrompts(30)
    local low = string.lower(tostring(keyword or ""))
    for _, p in ipairs(list) do
        if string.find(string.lower(tostring(p.name)), low, 1, true) then
            return p.prompt
        end
    end
    return nil
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 III：补给 / 治疗 / 状态 / 技能 / 科技点
-- ============================================================
----------------------------------------------------------------
local X2_DEFAULTS = {
    AutoFood = false, FoodNames = { "Food", "Burger", "Pizza", "Apple", "Meat" }, FoodHp = 55,
    AutoBandage = false, BandageNames = { "Bandage", "Medkit", "FirstAid" }, BandageHp = 45,
    AutoShieldItem = false, ShieldNames = { "Shield", "ArmorPlate", "Barrier" }, ShieldHp = 50, ShieldGap = 18,
    AutoCleanse = false, CleanseNames = { "Cleanse", "Antidote", "Cure" }, CleanseHp = 60,
    AutoHealAlly = false, HealAllyHp = 40, HealAllyRange = 60, HealAllyGap = 4,
    AutoRegenWait = false, RegenHp = 30, RegenExitHp = 75, RegenWaitTime = 8,
    AutoPotionCombo = false, ComboPotions = { "Heal", "Regen", "Shield" }, ComboGap = 2.5,
    AutoAntiVoid = false, VoidY = -80, VoidSafeY = 30,
    AutoFallGuard = false, FallSpeed = 90, FallLift = 12,
    AutoBurnGuard = false, BurnDropPct = 18, BurnWindow = 1.5,
    AutoStatusWatch = false, StatusWatchGap = 2,
    AutoSkillPriority = false, SkillPriority = {}, SkillPriorityGap = 0.14,
    AutoTechSpend = false, TechPriority = {}, TechReserve = 0, TechGap = 1.5,
    AutoUnlockCheap = false, UnlockCheapMax = 999999,
    AutoSaveTech = false, TechSaveAmount = 50,
    AutoPrestigeCheck = false, PrestigeLevel = 100, PrestigeRemote = "Prestige",
    AutoPassiveToggle = false, PassiveName = "Passive", PassiveGap = 30,
    AutoSkillQueue = false, SkillQueueSize = 4, SkillQueueGap = 0.35,
    AutoCooldownReport = false, CooldownReportGap = 20,
    AutoUltimateTracker = false, UltimateNotify = true,
    AutoManaCheck = false, ManaNames = { "Mana", "Energy", "Stamina" }, ManaMinPct = 20,
    AutoBuffRefresh = false, BuffNames = {}, BuffRefreshGap = 45,
    AutoArmorRepair = false, ArmorNames = { "Armor", "ArmorValue", "Shield" }, ArmorMinPct = 25, ArmorRepairItem = "Armor",
}

for k, v in pairs(X2_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

function xNumAttr(obj, names)
    if not obj then return nil end
    for _, n in ipairs(names or {}) do
        local ok, v = pcall(function() return obj:GetAttribute(n) end)
        if ok and tonumber(v) ~= nil then return tonumber(v), n end
    end
    return nil, nil
end

function xFindPlayerAttrNumber(names)
    local v, key = xNumAttr(player, names)
    if v ~= nil then return v, key end
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, n in ipairs(names or {}) do
            local obj = ls:FindFirstChild(n)
            if obj and tonumber(obj.Value) then return tonumber(obj.Value), n end
        end
    end
    return nil, nil
end

function xUseNamedRemote(remoteName, names, extra)
    local r = xFindRemote(remoteName)
    if not r then return 0 end
    local used = 0
    for _, n in ipairs(names or {}) do
        if n ~= nil and tostring(n) ~= "" then
            local ok = pcall(function()
                if r:IsA("RemoteFunction") then
                    if extra ~= nil then
                        r:InvokeServer(n, extra)
                    else
                        r:InvokeServer(n)
                    end
                elseif r:IsA("RemoteEvent") then
                    if extra ~= nil then
                        r:FireServer(n, extra)
                    else
                        r:FireServer(n)
                    end
                end
            end)
            if ok then used = used + 1 end
        end
    end
    return used
end

function xToolByName(names)
    local bp = player:FindFirstChild("Backpack")
    local c = player.Character
    for _, n in ipairs(names or {}) do
        local low = string.lower(tostring(n))
        local holders = { c, bp }
        for _, holder in ipairs(holders) do
            if holder then
                for _, t in ipairs(holder:GetChildren()) do
                    if t:IsA("Tool") and string.find(string.lower(t.Name), low, 1, true) then
                        return t
                    end
                end
            end
        end
    end
    return nil
end

function xActivateTool(tool)
    if not tool then return false end
    if tool.Parent ~= player.Character then
        if not xEquipTool(tool) then return false end
    end
    local ok = pcall(function() tool:Activate() end)
    if ok then xStatAdd("使用道具", 1) end
    return ok
end

----------------------------------------------------------------
-- 18. 自动吃东西
----------------------------------------------------------------
function autoFood()
    if not AUTO.AutoFood then return false end
    if AUTO.Paused then return false end
    if not every("x_food", 1.2) then return false end
    local hp = xHpPct()
    if hp <= 0 or hp > (tonumber(AUTO.FoodHp) or 55) then return false end
    local names = AUTO.FoodNames or {}
    local n = xUseNamedRemote("UseItems", names)
    if n == 0 then
        local tool = xToolByName(names)
        if tool then xActivateTool(tool) n = 1 end
    end
    if n > 0 then
        AUTO.LastReason = string.format("自动进食：血量 %.0f%%", hp)
        log(string.format("自动进食：血量 %.0f%%，已使用食物", hp))
        xStatAdd("进食", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 19. 自动绷带 / 医疗包
----------------------------------------------------------------
function autoBandage()
    if not AUTO.AutoBandage then return false end
    if AUTO.Paused then return false end
    if not every("x_bandage", 1.4) then return false end
    local hp = xHpPct()
    if hp <= 0 or hp > (tonumber(AUTO.BandageHp) or 45) then return false end
    local names = AUTO.BandageNames or {}
    local n = xUseNamedRemote("Potions", names)
    if n == 0 then
        local tool = xToolByName(names)
        if tool then xActivateTool(tool) n = 1 end
    end
    if n > 0 then
        AUTO.LastReason = string.format("自动包扎：血量 %.0f%%", hp)
        log(string.format("自动包扎：血量 %.0f%%，已使用医疗用品", hp))
        xStatAdd("包扎", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 20. 自动护盾道具
----------------------------------------------------------------
function autoShieldItem()
    if not AUTO.AutoShieldItem then return false end
    if AUTO.Paused then return false end
    local hp = xHpPct()
    if hp <= 0 or hp > (tonumber(AUTO.ShieldHp) or 50) then return false end
    if not every("x_shield", tonumber(AUTO.ShieldGap) or 18) then return false end
    local names = AUTO.ShieldNames or {}
    local n = xUseNamedRemote("Potions", names)
    if n == 0 then n = xUseNamedRemote("Boosts", names) end
    if n == 0 then
        local tool = xToolByName(names)
        if tool then xActivateTool(tool) n = 1 end
    end
    if n > 0 then
        AUTO.LastReason = "护盾：已开启防护"
        log("自动护盾：已尝试使用护盾道具")
        xStatAdd("护盾", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 21. 自动净化（中毒 / 燃烧 / 减速）
----------------------------------------------------------------
function autoCleanse()
    if not AUTO.AutoCleanse then return false end
    if AUTO.Paused then return false end
    if not every("x_cleanse", 2) then return false end
    local h = xHum2()
    if not h then return false end
    local bad = false
    for _, st in ipairs({
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.PlatformStanding,
    }) do
        if h:GetState() == st then bad = true break end
    end
    if not bad then
        for _, n in ipairs({ "Poison", "Burn", "Burning", "Slow", "Stun", "Frozen" }) do
            local ok, v = pcall(function() return player:GetAttribute(n) or h:GetAttribute(n) end)
            if ok and v ~= nil and v ~= false and tonumber(v) ~= 0 then
                bad = true
                break
            end
        end
    end
    if not bad then return false end
    if xHpPct() > (tonumber(AUTO.CleanseHp) or 60) then return false end
    local n = xUseNamedRemote("Potions", AUTO.CleanseNames or {})
    if n > 0 then
        AUTO.LastReason = "净化：已解除异常状态"
        log("自动净化：已使用净化道具")
        xStatAdd("净化", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 22. 自动治疗队友
----------------------------------------------------------------
function autoHealAlly()
    if not AUTO.AutoHealAlly then return false end
    if AUTO.Paused then return false end
    if not every("x_healally", tonumber(AUTO.HealAllyGap) or 4) then return false end
    local range = tonumber(AUTO.HealAllyRange) or 60
    local need = tonumber(AUTO.HealAllyHp) or 40
    local target = nil
    for _, a in ipairs(xAllyList(range)) do
        if a.hp > 0 and a.hp < a.maxhp * (need / 100) then
            target = a
            break
        end
    end
    if not target then return false end
    local n = 0
    local r = xFindRemote("HealAlly") or xFindRemote("Heal")
    if r then
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(target.player)
            else
                r:InvokeServer(target.player)
            end
        end)
        n = n + 1
    end
    local r2 = xFindRemote("Potions")
    if r2 then
        for _, name in ipairs(AUTO.HealAllyPotions or { "Heal", "Medkit" }) do
            local ok = pcall(function() r2:FireServer(name, target.player) end)
            if ok then n = n + 1 end
        end
    end
    if n > 0 then
        AUTO.LastReason = string.format("治疗队友：%s（%.0f%%）", target.player.Name, target.hp / target.maxhp * 100)
        log("自动治疗队友：" .. target.player.Name)
        xStatAdd("治疗队友", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 23. 低血挂机回血（后撤等待）
----------------------------------------------------------------
function autoRegenWait()
    if not AUTO.AutoRegenWait then return false end
    if AUTO.Paused then return false end
    local state = xSt("regenwait")
    local hp = xHpPct()
    local enterHp = tonumber(AUTO.RegenHp) or 30
    local exitHp = tonumber(AUTO.RegenExitHp) or 75
    if hp <= 0 then
        state.active = false
        return false
    end
    if not state.active then
        if hp <= enterHp then
            state.active = true
            state.since = os.clock()
            state.point = xSafePoint(nil, tonumber(AUTO.RetreatDistance) or 50)
            if state.point then xTp(state.point) end
            notify("回血模式", string.format("血量 %.0f%%，已进入回血等待", hp))
            log(string.format("回血模式：血量 %.0f%%，进入安全点", hp))
        end
        return false
    end
    if hp >= exitHp then
        state.active = false
        AUTO.LastReason = string.format("回血完成：%.0f%%", hp)
        log(string.format("回血完成：血量 %.0f%%", hp))
        return false
    end
    AUTO._HoldCombat = true
    if every("x_regen_heal", 2) then
        buyHP()
        usePotion()
    end
    if state.point and every("x_regen_keep", 1.5) then
        local cur = xRoot2()
        if cur and (cur.Position - state.point).Magnitude > 12 then
            xTp(state.point)
        end
    end
    AUTO.LastReason = string.format("回血等待：%.0f%%（目标 %d%%）", hp, xRound(exitHp))
    return true
end

----------------------------------------------------------------
-- 24. 药水连招（依次使用多种）
----------------------------------------------------------------
function autoPotionCombo()
    if not AUTO.AutoPotionCombo then return false end
    if AUTO.Paused then return false end
    local state = xSt("potioncombo")
    local now = os.clock()
    if state.next_ and now < state.next_ then return false end
    local hp = xHpPct()
    if hp <= 0 or hp > (tonumber(AUTO.RetreatHp) or 25) + 20 then
        state.index = nil
        return false
    end
    local list = AUTO.ComboPotions or {}
    if #list == 0 then return false end
    state.index = (state.index or 0) + 1
    if state.index > #list then state.index = 1 end
    local name = list[state.index]
    local r = xFindRemote("Potions")
    if not r then return false end
    local ok = pcall(function() r:FireServer(name) end)
    if not ok then return false end
    state.next_ = now + (tonumber(AUTO.ComboGap) or 2.5)
    AUTO.LastReason = "药水连招：" .. tostring(name)
    log("药水连招：已使用 " .. tostring(name))
    xStatAdd("药水连招", 1)
    return true
end

----------------------------------------------------------------
-- 25. 防掉虚空
----------------------------------------------------------------
function autoAntiVoid()
    if not AUTO.AutoAntiVoid then return false end
    if AUTO.Paused then return false end
    if not every("x_void", 0.5) then return false end
    local base = xRoot2()
    if not base then return false end
    local state = xSt("void")
    local voidY = tonumber(AUTO.VoidY) or -80
    local safeY = tonumber(AUTO.VoidSafeY) or 30
    if base.Position.Y > voidY + 20 then
        state.safe = base.Position
        return false
    end
    local dest = state.safe
    if not dest or dest.Y < voidY then
        dest = Vector3.new(base.Position.X, safeY, base.Position.Z)
    end
    xTp(dest + Vector3.new(0, 4, 0))
    AUTO.LastReason = "防掉虚空：已拉回安全高度"
    if xToast("void", "防掉虚空", "已把角色拉回安全高度", 5) then
        log("防掉虚空：角色过低了，已拉回")
    end
    xStatAdd("防掉虚空", 1)
    return true
end

----------------------------------------------------------------
-- 26. 坠落保护
----------------------------------------------------------------
function autoFallGuard()
    if not AUTO.AutoFallGuard then return false end
    if AUTO.Paused then return false end
    if not every("x_fall", 0.2) then return false end
    local base = xRoot2()
    if not base then return false end
    local v = base.AssemblyLinearVelocity
    local limit = tonumber(AUTO.FallSpeed) or 90
    if v.Y > -limit then return false end
    local lift = tonumber(AUTO.FallLift) or 12
    xTp(base.Position + Vector3.new(0, lift, 0))
    xStatAdd("坠落保护", 1)
    AUTO.LastReason = "坠落保护：已减速并抬升"
    return true
end

----------------------------------------------------------------
-- 27. 急速掉血保护（疑似中毒 / 集火）
----------------------------------------------------------------
function autoBurnGuard()
    if not AUTO.AutoBurnGuard then return false end
    if AUTO.Paused then return false end
    if not every("x_burn", 0.25) then return false end
    local state = xSt("burn")
    local hp = xHpPct()
    local now = os.clock()
    if state.lastHp == nil or now - (state.lastAt or now) < 0.2 then
        state.lastHp = hp
        state.lastAt = now
        return false
    end
    local dt = math.max(0.2, now - (state.lastAt or now))
    local dropPerSec = ((state.lastHp or hp) - hp) / dt
    state.lastHp = hp
    state.lastAt = now
    local threshold = (tonumber(AUTO.BurnDropPct) or 18) / (tonumber(AUTO.BurnWindow) or 1.5)
    if dropPerSec < threshold then return false end
    if hp <= 0 then return false end
    local ok = xUseNamedRemote("Potions", AUTO.CleanseNames or {})
    local pos = xSafePoint(nil, tonumber(AUTO.RetreatDistance) or 50)
    if pos then xTp(pos) end
    if AUTO.AutoBuyHP then buyHP() end
    if AUTO.AutoPotion then usePotion() end
    AUTO.LastReason = string.format("急速掉血：%.0f%%/秒，已后撤并治疗", dropPerSec)
    if xToast("burn", "掉血警告", string.format("瞬间掉血 %.0f%%/秒，已保护", dropPerSec), 6) then
        log(string.format("急速掉血保护：%.0f%%/秒", dropPerSec))
    end
    xStatAdd("掉血保护", 1)
    return ok or true
end

----------------------------------------------------------------
-- 28. 状态监视（记录异常状态变化）
----------------------------------------------------------------
function autoStatusWatch()
    if not AUTO.AutoStatusWatch then return false end
    if not every("x_status", tonumber(AUTO.StatusWatchGap) or 2) then return false end
    local h = xHum2()
    if not h then return false end
    local state = xSt("status")
    local cur = tostring(h:GetState())
    if state.lastState ~= cur then
        log("状态监视：Humanoid 状态 " .. tostring(state.lastState) .. " → " .. cur)
        state.lastState = cur
        xStatAdd("状态变化", 1)
    end
    local attrs = {}
    for _, obj in ipairs({ player, h, player.Character }) do
        if obj then
            local ok, list = pcall(function() return obj:GetAttributes() end)
            if ok and type(list) == "table" then
                for k, v in pairs(list) do
                    local tv = type(v)
                    if tv == "boolean" or tv == "number" or tv == "string" then
                        attrs[k] = v
                    end
                end
            end
        end
    end
    for k, v in pairs(attrs) do
        if state.attrs[k] ~= v then
            if state.attrs[k] ~= nil then
                log(string.format("状态监视：%s = %s", tostring(k), tostring(v)))
                xStatAdd("属性变化", 1)
            end
            state.attrs[k] = v
        end
    end
    return true
end

----------------------------------------------------------------
-- 29. 技能优先级施放
----------------------------------------------------------------
function xCastSkillById(id, hitPos, keyName)
    local act = RS:FindFirstChild("SkillActivate")
    if not act or not id or not hitPos then return false end
    local cam = workspace.CurrentCamera
    local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
    local ok = pcall(function()
        act:FireServer(id, hitPos, look, "press", keyName or "M1")
        task.delay(0.15, function()
            pcall(function() act:FireServer(id, hitPos, look, "release", keyName or "M1") end)
        end)
    end)
    return ok
end

function autoSkillPriority()
    if not AUTO.AutoSkillPriority then return false end
    if AUTO.Paused then return false end
    if not every("x_skillprio", tonumber(AUTO.SkillPriorityGap) or 0.14) then return false end
    local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
    if not pick then return false end
    local list = AUTO.SkillPriority or {}
    local map = {}
    for _, id in pairs(skills) do map[id] = true end
    local fired = 0
    for _, want in ipairs(list) do
        local low = string.lower(tostring(want))
        for id, info in pairs(skillInfo) do
            if map[id] and info and info.name and string.lower(tostring(info.name)) == low then
                if os.clock() >= (skillNext[id] or 0) then
                    skillNext[id] = os.clock() + (info.cd or 2.5)
                    if xCastSkillById(id, pick.pos, info.name) then
                        fired = fired + 1
                        xStatAdd("优先技能", 1)
                    end
                end
                map[id] = nil
            end
        end
    end
    if fired > 0 then
        AUTO.LastReason = string.format("优先技能：%s（%d 个）", pick.model.Name, fired)
    end
    return fired > 0
end

----------------------------------------------------------------
-- 30. 自动花科技点
----------------------------------------------------------------
function autoTechSpend()
    if not AUTO.AutoTechSpend then return false end
    if AUTO.Paused then return false end
    if not every("x_tech", tonumber(AUTO.TechGap) or 1.5) then return false end
    local points, key = xFindPlayerAttrNumber({ "TechPoints", "TechPoint", "SkillPoints", "Technology" })
    if points == nil then return false end
    local reserve = tonumber(AUTO.TechReserve) or 0
    if points <= reserve then return false end
    local folder = player:FindFirstChild("SkillTreesFolder")
    local r = xFindRemote("SkillTrees")
    if not folder or not r then return false end
    local nodes = {}
    for _, node in ipairs(folder:GetChildren()) do
        local cost = tonumber(node:GetAttribute("Cost")) or tonumber(node:GetAttribute("Price")) or 1
        table.insert(nodes, { obj = node, name = node.Name, cost = cost })
    end
    table.sort(nodes, function(a, b) return a.cost < b.cost end)
    local priority = AUTO.TechPriority or {}
    local n = 0
    local spent = 0
    for _, want in ipairs(priority) do
        for _, node in ipairs(nodes) do
            if string.find(string.lower(node.name), string.lower(tostring(want)), 1, true) then
                if points - spent >= node.cost then
                    local ok = pcall(function() r:FireServer(node.name) end)
                    if ok then
                        n = n + 1
                        spent = spent + node.cost
                        xStatAdd("科技点消费", node.cost)
                    end
                end
            end
        end
    end
    if n == 0 then
        for _, node in ipairs(nodes) do
            if points - spent >= node.cost then
                local ok = pcall(function() r:FireServer(node.name) end)
                if ok then
                    n = n + 1
                    spent = spent + node.cost
                    xStatAdd("科技点消费", node.cost)
                end
                if n >= 3 then break end
            end
        end
    end
    if n > 0 then
        AUTO.LastReason = string.format("科技点：消耗 %d，升级 %d 个节点", spent, n)
        log(string.format("科技点：%s=%d，已消费 %d，升级 %d 个节点", tostring(key), points, spent, n))
        return true
    end
    return false
end

----------------------------------------------------------------
-- 31. 自动解锁最便宜节点
----------------------------------------------------------------
function autoUnlockCheap()
    if not AUTO.AutoUnlockCheap then return false end
    if AUTO.Paused then return false end
    if not every("x_cheap", 2) then return false end
    local folder = player:FindFirstChild("SkillTreesFolder")
    local r = xFindRemote("SkillTrees")
    if not folder or not r then return false end
    local best, bestCost = nil, tonumber(AUTO.UnlockCheapMax) or 999999
    for _, node in ipairs(folder:GetChildren()) do
        local cost = tonumber(node:GetAttribute("Cost")) or tonumber(node:GetAttribute("Price"))
        if cost and cost <= bestCost then
            best, bestCost = node, cost
        end
    end
    if not best then return false end
    local ok = pcall(function() r:FireServer(best.Name) end)
    if ok then
        AUTO.LastReason = "解锁节点：" .. best.Name
        log(string.format("自动解锁：%s（花费 %d）", best.Name, bestCost))
        xStatAdd("解锁节点", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 32. 科技点保留（低于阈值不花）
----------------------------------------------------------------
function autoSaveTech()
    if not AUTO.AutoSaveTech then return false end
    if not every("x_savetech", 5) then return false end
    local points = xFindPlayerAttrNumber({ "TechPoints", "TechPoint", "SkillPoints", "Technology" })
    local save = tonumber(AUTO.TechSaveAmount) or 50
    if points == nil then
        AUTO.TechSavedEnough = false
        return false
    end
    AUTO.TechSavedEnough = points >= save
    if every("x_savetech_log", 30) then
        log(string.format("科技点保留：%d / %d（%s）", points, save,
            AUTO.TechSavedEnough and "已达标" or "继续积累"))
    end
    return AUTO.TechSavedEnough
end

----------------------------------------------------------------
-- 33. 转生 / 重置检查
----------------------------------------------------------------
function autoPrestigeCheck()
    if not AUTO.AutoPrestigeCheck then return false end
    if AUTO.Paused then return false end
    if not every("x_prestige", 5) then return false end
    local remote = xFindRemote(AUTO.PrestigeRemote or "Prestige")
    if not remote then
        if xToast("prestige_none", "转生", "当前游戏没有转生接口", 60) then
            log("转生检查：未找到转生接口，已跳过")
        end
        return false
    end
    local level = xFindPlayerAttrNumber({ "Level", "RebirthLevel", "Prestige", "Stage" })
    local need = tonumber(AUTO.PrestigeLevel) or 100
    if level == nil or level < need then
        AUTO.PrestigeReady = false
        return false
    end
    AUTO.PrestigeReady = true
    local ok = pcall(function()
        if remote:IsA("RemoteFunction") then remote:InvokeServer()
        else remote:FireServer() end
    end)
    if ok then
        AUTO.LastReason = "转生：已请求重置"
        notify("转生", string.format("等级 %d ≥ %d，已请求转生", level, need))
        log(string.format("转生：等级 %d，已请求转生", level))
        xStatAdd("转生", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 34. 自动被动开关
----------------------------------------------------------------
function autoPassiveToggle()
    if not AUTO.AutoPassiveToggle then return false end
    if AUTO.Paused then return false end
    if not every("x_passive", tonumber(AUTO.PassiveGap) or 30) then return false end
    local name = AUTO.PassiveName or "Passive"
    local ok = xFire("Passive", name) or xFire("TogglePassive", name) or xFire("SkillPassive", name)
    if ok then
        AUTO.LastReason = "被动：" .. tostring(name)
        log("自动被动：已切换 " .. tostring(name))
        xStatAdd("被动切换", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 35. 技能队列（按顺序释放）
----------------------------------------------------------------
function autoSkillQueue()
    if not AUTO.AutoSkillQueue then return false end
    if AUTO.Paused then return false end
    local state = xSt("skillqueue")
    local now = os.clock()
    if state.next_ and now < state.next_ then return false end
    if state.queue and #state.queue > 0 then
        local item = table.remove(state.queue, 1)
        local ok = xCastSkillById(item.id, item.pos, item.name)
        state.next_ = now + (tonumber(AUTO.SkillQueueGap) or 0.35)
        if ok then xStatAdd("队列技能", 1) end
        return ok
    end
    if not every("x_queue_build", 2) then return false end
    local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
    if not pick then return false end
    local maxN = tonumber(AUTO.SkillQueueSize) or 4
    local queue = {}
    local ids = {}
    for id in pairs(skillInfo) do table.insert(ids, id) end
    table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
    for _, id in ipairs(ids) do
        if os.clock() >= (skillNext[id] or 0) then
            local info = skillInfo[id]
            if info then
                skillNext[id] = os.clock() + (info.cd or 2.5)
                table.insert(queue, { id = id, pos = pick.pos, name = info.name })
                if #queue >= maxN then break end
            end
        end
    end
    if #queue == 0 then return false end
    state.queue = queue
    state.next_ = now
    AUTO.LastReason = string.format("技能队列：%d 个技能待释放", #queue)
    log("技能队列：已排队 " .. #queue .. " 个技能")
    return true
end

----------------------------------------------------------------
-- 36. 技能冷却报告
----------------------------------------------------------------
function autoCooldownReport()
    if not AUTO.AutoCooldownReport then return false end
    if not every("x_cdreport", tonumber(AUTO.CooldownReportGap) or 20) then return false end
    local now = os.clock()
    local parts = {}
    for id, info in pairs(skillInfo) do
        local left = math.max(0, (skillNext[id] or 0) - now)
        table.insert(parts, string.format("%s:%.1fs", tostring(info.name), left))
        if #parts >= 8 then break end
    end
    if #parts == 0 then
        log("冷却报告：还没有读取到技能")
        return false
    end
    table.sort(parts)
    log("冷却报告：" .. table.concat(parts, "  "))
    return true
end

----------------------------------------------------------------
-- 37. 大招就绪追踪
----------------------------------------------------------------
function autoUltimateTracker()
    if not AUTO.AutoUltimateTracker then return false end
    if not every("x_ult", 1) then return false end
    local state = xSt("ult")
    local now = os.clock()
    local bestId, bestCd = nil, -1
    for id, info in pairs(skillInfo) do
        if info.cd and info.cd > bestCd then
            bestCd = info.cd
            bestId = id
        end
    end
    if not bestId then return false end
    local ready = now >= (skillNext[bestId] or 0)
    local name = skillInfo[bestId].name or tostring(bestId)
    AUTO.UltimateName = name
    AUTO.UltimateReady = ready
    if ready and state.wasReady == false then
        if AUTO.UltimateNotify then
            notify("大招就绪", "终极技能 " .. tostring(name) .. " 已就绪")
        end
        log("大招就绪：" .. tostring(name))
        xStatAdd("大招就绪", 1)
    end
    state.wasReady = ready
    return ready
end

----------------------------------------------------------------
-- 38. 蓝量 / 能量检查
----------------------------------------------------------------
function autoManaCheck()
    if not AUTO.AutoManaCheck then return false end
    if AUTO.Paused then return false end
    if not every("x_mana", 1.5) then return false end
    local h = xHum2()
    local cur, key = xNumAttr(player, AUTO.ManaNames or {})
    if cur == nil then cur, key = xNumAttr(h, AUTO.ManaNames or {}) end
    if cur == nil then
        cur, key = xFindPlayerAttrNumber(AUTO.ManaNames or {})
    end
    if cur == nil then
        AUTO.ManaPct = nil
        return false
    end
    local max = nil
    local maxNames = {}
    for _, n in ipairs(AUTO.ManaNames or {}) do
        table.insert(maxNames, tostring(n) .. "Max")
        table.insert(maxNames, "Max" .. tostring(n))
    end
    if key then
        table.insert(maxNames, 1, tostring(key) .. "Max")
        table.insert(maxNames, 1, "Max" .. tostring(key))
    end
    max = xNumAttr(player, maxNames)
    if max == nil then max = xNumAttr(h, maxNames) end
    local pct = (max and max > 0) and (cur / max * 100) or nil
    AUTO.ManaNow = cur
    AUTO.ManaPct = pct
    if pct and pct <= (tonumber(AUTO.ManaMinPct) or 20) then
        local n = xUseNamedRemote("Potions", AUTO.ManaNames or {})
        if n > 0 then
            AUTO.LastReason = string.format("能量不足：%.0f%%，已补充", pct)
            log(string.format("蓝量检查：%.0f%%，已使用恢复道具", pct))
            xStatAdd("补充能量", n)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 39. 自动续 Buff
----------------------------------------------------------------
function autoBuffRefresh()
    if not AUTO.AutoBuffRefresh then return false end
    if AUTO.Paused then return false end
    if not every("x_buff", tonumber(AUTO.BuffRefreshGap) or 45) then return false end
    local list = AUTO.BuffNames or {}
    if #list == 0 and AUTO.BoostName and AUTO.BoostName ~= "" then
        list = { AUTO.BoostName }
    end
    if #list == 0 then return false end
    local n = 0
    local r = xFindRemote("Boosts")
    if r then
        for _, name in ipairs(list) do
            local ok = pcall(function() r:FireServer(name) end)
            if ok then n = n + 1 end
        end
    end
    if n > 0 then
        AUTO.LastReason = "续 Buff：" .. tostring(list[1])
        log("自动续 Buff：已使用 " .. n .. " 个增益")
        xStatAdd("续Buff", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 40. 自动修甲
----------------------------------------------------------------
function autoArmorRepair()
    if not AUTO.AutoArmorRepair then return false end
    if AUTO.Paused then return false end
    if not every("x_armor", 3) then return false end
    local h = xHum2()
    local cur, key = xNumAttr(player, AUTO.ArmorNames or {})
    if cur == nil then cur, key = xNumAttr(h, AUTO.ArmorNames or {}) end
    if cur == nil then return false end
    local max = nil
    if key then
        max = xNumAttr(player, { tostring(key) .. "Max", "Max" .. tostring(key) })
        if max == nil then max = xNumAttr(h, { tostring(key) .. "Max", "Max" .. tostring(key) }) end
    end
    local pct = (max and max > 0) and (cur / max * 100) or cur
    if max == nil and cur > (tonumber(AUTO.ArmorMinPct) or 25) then return false end
    if max ~= nil and pct > (tonumber(AUTO.ArmorMinPct) or 25) then return false end
    local item = AUTO.ArmorRepairItem or "Armor"
    local ok = fireRemote("ShopSystem", "Buy", item)
    if ok then
        AUTO.LastReason = "修甲：" .. tostring(item)
        log(string.format("自动修甲：%s=%.0f，已请求购买 %s", tostring(key), cur, tostring(item)))
        xStatAdd("修甲", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 IV：任务 / 日常 / 经济 / 商店 / 扭蛋
-- ============================================================
----------------------------------------------------------------
local X3_DEFAULTS = {
    AutoQuestAccept = false, QuestAcceptGap = 3,
    AutoQuestComplete = false, QuestCompleteGap = 3,
    AutoDailyClaim = false, DailyClaimGap = 30,
    AutoWeeklyClaim = false, WeeklyClaimGap = 60,
    AutoQuestTrack = false, QuestTrackGap = 5,
    AutoQuestSkip = false, QuestSkipGap = 5, QuestSkipMax = 999999,
    AutoSquadLoop = false, SquadLoopGap = 2,
    AutoQuestReport = false, QuestReportGap = 30,
    AutoSellJunk = false, SellGap = 8, SellNames = {}, SellKeep = {},
    AutoBudgetBuy = false, BudgetBuyGap = 10, BudgetReserve = 1000, BudgetItems = {},
    AutoRestock = false, RestockGap = 30, RestockItems = {}, RestockAmount = 1,
    AutoCrateOpen = false, CrateGap = 12, CrateKeywords = { "crate", "chest", "box", "reward" },
    AutoGachaPlan = false, GachaGap = 15, GachaReserve = 5000, GachaMode = "角色",
    AutoMoneyPickup = false, MoneyPickupGap = 1.2, MoneyPickupRange = 60,
    AutoInventorySort = false, InventorySortGap = 60,
    AutoGiftSend = false, GiftNames = {}, GiftGap = 30,
    AutoShopScan = false, ShopScanGap = 60,
    AutoDiscountBuy = false, DiscountGap = 12, DiscountReserve = 0,
    AutoCurrencyWatch = false, CurrencyNames = { "Money", "Cash", "Coins", "Gold" },
    AutoFreeChest = false, FreeChestGap = 20,
    AutoQuestAutoEquip = false, QuestAutoEquipGap = 6,
}

for k, v in pairs(X3_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

function xRemoteList(candidates)
    local out = {}
    for _, name in ipairs(candidates or {}) do
        local r = xFindRemote(name)
        if r then table.insert(out, r) end
    end
    return out
end

function xTryRemoteAction(candidates, action, arg)
    local list = xRemoteList(candidates)
    local okAny = false
    for _, r in ipairs(list) do
        local ok = pcall(function()
            if r:IsA("RemoteFunction") then
                if arg ~= nil then
                    r:InvokeServer(action, arg)
                else
                    r:InvokeServer(action)
                end
            else
                if arg ~= nil then
                    r:FireServer(action, arg)
                else
                    r:FireServer(action)
                end
            end
        end)
        if ok then okAny = true end
    end
    return okAny
end

function xQuestFolder()
    local names = { "QuestConfig", "QuestFuse", "QuestSystem", "Quests", "Quest" }
    for _, n in ipairs(names) do
        local r = xFindRemote(n)
        if r then return r end
    end
    return nil
end

----------------------------------------------------------------
-- 41. 自动接任务
----------------------------------------------------------------
function autoQuestAccept()
    if not AUTO.AutoQuestAccept then return false end
    if AUTO.Paused then return false end
    if not every("x_questaccept", tonumber(AUTO.QuestAcceptGap) or 3) then return false end
    local ok = xTryRemoteAction({ "QuestFuse", "Quest", "QuestSystem", "QuestHandler", "QuestRemote" }, "Accept")
    if not ok then ok = xTryRemoteAction({ "QuestFuse", "Quest" }, "Start") end
    if not ok then
        local prompt = xFindPromptByKeyword and xFindPromptByKeyword("quest")
        if prompt then
            xUsePrompt(prompt)
            ok = true
        end
    end
    if ok then
        AUTO.LastReason = "任务：已请求接取"
        log("自动任务：已请求接取任务")
        xStatAdd("接任务", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 42. 自动交任务
----------------------------------------------------------------
function autoQuestComplete()
    if not AUTO.AutoQuestComplete then return false end
    if AUTO.Paused then return false end
    if not every("x_questcomplete", tonumber(AUTO.QuestCompleteGap) or 3) then return false end
    local ok = xTryRemoteAction({ "QuestFuse", "Quest", "QuestSystem", "QuestHandler", "QuestRemote" }, "Complete")
    if not ok then ok = xTryRemoteAction({ "QuestFuse", "Quest" }, "Claim") end
    if not ok then
        local prompt = xFindPromptByKeyword and xFindPromptByKeyword("claim")
        if prompt then
            xUsePrompt(prompt)
            ok = true
        end
    end
    if ok then
        AUTO.LastReason = "任务：已请求交付"
        log("自动任务：已请求交付任务")
        xStatAdd("交任务", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 43. 自动领每日
----------------------------------------------------------------
function autoDailyClaim()
    if not AUTO.AutoDailyClaim then return false end
    if AUTO.Paused then return false end
    if not every("x_daily", tonumber(AUTO.DailyClaimGap) or 30) then return false end
    local n = 0
    for _, name in ipairs({ "DailyReward", "DailyRemote", "Daily", "LoginRemote" }) do
        local r = xFindRemote(name)
        if r then
            local ok = pcall(function()
                if r:IsA("RemoteFunction") then
                    local res = r:InvokeServer("Claim")
                    if res ~= nil then n = n + 1 end
                else
                    r:FireServer("Claim")
                    n = n + 1
                end
            end)
            if ok then n = n + 0 end
        end
    end
    if n > 0 then
        AUTO.LastReason = "每日：已领取"
        log("每日奖励：已请求领取 " .. n .. " 个")
        xStatAdd("每日奖励", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 44. 自动领每周
----------------------------------------------------------------
function autoWeeklyClaim()
    if not AUTO.AutoWeeklyClaim then return false end
    if AUTO.Paused then return false end
    if not every("x_weekly", tonumber(AUTO.WeeklyClaimGap) or 60) then return false end
    local n = 0
    for _, name in ipairs({ "WeeklyReward", "WeeklyRemote", "Weekly", "WeekReward" }) do
        local r = xFindRemote(name)
        if r then
            local ok = pcall(function()
                if r:IsA("RemoteFunction") then
                    r:InvokeServer("Claim")
                else
                    r:FireServer("Claim")
                end
            end)
            if ok then n = n + 1 end
        end
    end
    if n > 0 then
        AUTO.LastReason = "每周：已领取"
        log("每周奖励：已请求领取 " .. n .. " 个")
        xStatAdd("每周奖励", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 45. 自动点任务追踪
----------------------------------------------------------------
function autoQuestTrack()
    if not AUTO.AutoQuestTrack then return false end
    if AUTO.Paused then return false end
    if not every("x_questtrack", tonumber(AUTO.QuestTrackGap) or 5) then return false end
    local clicked = 0
    local roots = { pg, workspace }
    for _, root in ipairs(roots) do
        if root then
            local ok = pcall(function()
                for _, d in ipairs(root:GetDescendants()) do
                    if d:IsA("GuiButton") and d.Visible then
                        local low = string.lower(d.Name)
                        if string.find(low, "quest", 1, true) or string.find(low, "track", 1, true) then
                            if deepVisible(d) then
                                if d.FireServer then
                                    pcall(function() d.FireServer(d) end)
                                end
                            end
                        end
                    end
                end
            end)
            if not ok then clicked = clicked + 0 end
        end
    end
    local btn = pg:FindFirstChild("Lobby")
    if btn then
        local track = findPath(btn, { "MainFrame", "Frame", "Create", "TrackQuestButton" })
        if track and track.Visible then
            clickGui(track)
            clicked = clicked + 1
        end
    end
    if clicked > 0 then
        AUTO.LastReason = "任务追踪：已点击"
        log("任务追踪：已点击追踪按钮")
        return true
    end
    return false
end

----------------------------------------------------------------
-- 46. 放弃低收益任务
----------------------------------------------------------------
function autoQuestSkip()
    if not AUTO.AutoQuestSkip then return false end
    if AUTO.Paused then return false end
    if not every("x_questskip", tonumber(AUTO.QuestSkipGap) or 5) then return false end
    local r = xQuestFolder()
    if not r then return false end
    local limit = tonumber(AUTO.QuestSkipMax) or 999999
    local skipped = 0
    local ok = pcall(function()
        local missions = r:FindFirstChild("Missions") or r:FindFirstChild("QuestList")
        if missions then
            for _, m in ipairs(missions:GetChildren()) do
                local reward = tonumber(m:GetAttribute("Reward")) or 0
                if reward > 0 and reward < limit then
                    if r:IsA("RemoteFunction") then
                        pcall(function() r:InvokeServer("Abandon", m.Name) end)
                    else
                        pcall(function() r:FireServer("Abandon", m.Name) end)
                    end
                    skipped = skipped + 1
                end
            end
        end
    end)
    if ok and skipped > 0 then
        AUTO.LastReason = "任务：放弃 " .. skipped .. " 个低收益任务"
        log("自动任务：放弃 " .. skipped .. " 个低收益任务")
        xStatAdd("放弃任务", skipped)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 47. 小队任务循环（接取 → 完成 → 再接）
----------------------------------------------------------------
function autoSquadLoop()
    if not AUTO.AutoSquadLoop then return false end
    if AUTO.Paused then return false end
    if not every("x_squadloop", tonumber(AUTO.SquadLoopGap) or 2) then return false end
    local r = xFindRemote("GSquadQuest")
    local cfg = getSquadCfg and getSquadCfg()
    if not r or not cfg then return false end
    local accepted, completed = 0, 0
    for _, m in ipairs(cfg:GetChildren()) do
        local id = m:GetAttribute("Id") or m:GetAttribute("ID") or m.Name
        local need = tonumber(m:GetAttribute("Need")) or 1
        local now = tonumber(m:GetAttribute("Progress")) or 0
        if now >= need then
            local ok = pcall(function() r:FireServer("Complete", id) end)
            if ok then completed = completed + 1 end
        elseif now == 0 then
            local ok = pcall(function() r:FireServer("Accept", id) end)
            if ok then accepted = accepted + 1 end
        end
    end
    if accepted + completed > 0 then
        AUTO.LastReason = string.format("小队任务：接 %d / 交 %d", accepted, completed)
        log(string.format("小队任务循环：接取 %d 个，完成 %d 个", accepted, completed))
        xStatAdd("小队循环", accepted + completed)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 48. 任务统计报告
----------------------------------------------------------------
function autoQuestReport()
    if not AUTO.AutoQuestReport then return false end
    if not every("x_questreport", tonumber(AUTO.QuestReportGap) or 30) then return false end
    local lines = {
        "接取 " .. tostring(AUTO.Stats["接任务"] or 0),
        "交付 " .. tostring(AUTO.Stats["交任务"] or 0),
        "放弃 " .. tostring(AUTO.Stats["放弃任务"] or 0),
        "小队 " .. tostring(AUTO.Stats["小队循环"] or 0),
    }
    log("任务统计：" .. table.concat(lines, "   "))
    return true
end

----------------------------------------------------------------
-- 49. 自动出售杂物
----------------------------------------------------------------
function autoSellJunk()
    if not AUTO.AutoSellJunk then return false end
    if AUTO.Paused then return false end
    if not every("x_sell", tonumber(AUTO.SellGap) or 8) then return false end
    local keep = {}
    for _, n in ipairs(AUTO.SellKeep or {}) do keep[string.lower(tostring(n))] = true end
    local target = {}
    for _, n in ipairs(AUTO.SellNames or {}) do target[string.lower(tostring(n))] = true end
    local bp = player:FindFirstChild("Backpack")
    if not bp then return false end
    local sold = 0
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            local low = string.lower(t.Name)
            local shouldSell = false
            if next(target) then
                for name in pairs(target) do
                    if string.find(low, name, 1, true) then shouldSell = true break end
                end
            else
                shouldSell = not keep[low]
            end
            if shouldSell and not keep[low] then
                local ok = fireRemote("ShopSystem", "Sell", t.Name)
                if not ok then ok = xFire("Sell", t.Name) end
                if ok then sold = sold + 1 end
            end
        end
    end
    if sold > 0 then
        AUTO.LastReason = "出售杂物：" .. sold .. " 件"
        log("自动出售：已出售 " .. sold .. " 件杂物")
        xStatAdd("出售杂物", sold)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 50. 预算购买
----------------------------------------------------------------
function autoBudgetBuy()
    if not AUTO.AutoBudgetBuy then return false end
    if AUTO.Paused then return false end
    if not every("x_budget", tonumber(AUTO.BudgetBuyGap) or 10) then return false end
    local money = xFindPlayerAttrNumber(AUTO.CurrencyNames or { "Money", "Cash", "Coins", "Gold" })
    if money == nil then return false end
    local reserve = tonumber(AUTO.BudgetReserve) or 1000
    if money <= reserve then
        AUTO.BudgetBlocked = true
        return false
    end
    AUTO.BudgetBlocked = false
    local items = AUTO.BudgetItems or {}
    if #items == 0 then return false end
    local budget = money - reserve
    local bought = 0
    for _, item in ipairs(items) do
        local name, price = item, 0
        if type(item) == "table" then
            name = item.name or item[1]
            price = tonumber(item.price or item[2]) or 0
        end
        if name and budget >= price then
            local ok = fireRemote("ShopSystem", "Buy", name)
            if ok then
                bought = bought + 1
                budget = budget - price
            end
        end
    end
    if bought > 0 then
        AUTO.LastReason = string.format("预算购买：%d 件（余额 %s）", bought, xFmt(money))
        log(string.format("预算购买：已买 %d 件，余额 %s", bought, xFmt(money)))
        xStatAdd("预算购买", bought)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 51. 自动补货
----------------------------------------------------------------
function autoRestock()
    if not AUTO.AutoRestock then return false end
    if AUTO.Paused then return false end
    if not every("x_restock", tonumber(AUTO.RestockGap) or 30) then return false end
    local items = AUTO.RestockItems or {}
    if #items == 0 then return false end
    local amount = math.max(1, math.floor(tonumber(AUTO.RestockAmount) or 1))
    local n = 0
    for _, item in ipairs(items) do
        local ok = fireRemote("BuyItemFromShopHourly", item, amount)
        if not ok then ok = fireRemote("ShopSystem", "Buy", item) end
        if ok then n = n + 1 end
    end
    if n > 0 then
        AUTO.LastReason = "补货：" .. n .. " 种"
        log("自动补货：已请求购买 " .. n .. " 种物品 × " .. amount)
        xStatAdd("补货", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 52. 自动开箱
----------------------------------------------------------------
function autoCrateOpen()
    if not AUTO.AutoCrateOpen then return false end
    if AUTO.Paused then return false end
    if not every("x_crate", tonumber(AUTO.CrateGap) or 12) then return false end
    local keywords = AUTO.CrateKeywords or {}
    local prompt = nil
    local list = xNearPrompts(tonumber(AUTO.CollectRange) or 30)
    for _, p in ipairs(list) do
        local low = string.lower(tostring(p.name))
        for _, k in ipairs(keywords) do
            if string.find(low, string.lower(tostring(k)), 1, true) then
                prompt = p.prompt
                break
            end
        end
        if prompt then break end
    end
    if prompt then
        xUsePrompt(prompt)
        AUTO.LastReason = "开箱：已触发"
        log("自动开箱：已触发附近的箱子")
        xStatAdd("开箱", 1)
        return true
    end
    local remotes = { "OpenCrate", "CrateRemote", "OpenChest", "ChestRemote", "ClaimChest" }
    for _, name in ipairs(remotes) do
        if xFire(name) then
            AUTO.LastReason = "开箱：" .. name
            log("自动开箱：已请求 " .. name)
            xStatAdd("开箱", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 53. 扭蛋计划（按余额控制）
----------------------------------------------------------------
function autoGachaPlan()
    if not AUTO.AutoGachaPlan then return false end
    if AUTO.Paused then return false end
    if not every("x_gachaplan", tonumber(AUTO.GachaGap) or 15) then return false end
    local money = xFindPlayerAttrNumber(AUTO.CurrencyNames or { "Money", "Cash", "Coins", "Gold" })
    local reserve = tonumber(AUTO.GachaReserve) or 5000
    if money ~= nil and money <= reserve then
        AUTO.GachaBlocked = true
        return false
    end
    AUTO.GachaBlocked = false
    local mode = AUTO.GachaMode or "角色"
    local ok = false
    if mode == "皮肤" then
        ok = xFire("GachaSkins", 1)
        if not ok then ok = xFire("GachaSkins", "spin") end
    elseif mode == "胶囊" then
        ok = xFire("GachaCapsule")
    else
        ok = xFire("GachaCharacter", 1)
        if not ok then ok = xFire("GachaCharacter", "spin") end
    end
    if ok then
        AUTO.LastReason = "扭蛋：" .. tostring(mode)
        log("扭蛋计划：已抽取 " .. tostring(mode))
        xStatAdd("扭蛋", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 54. 自动捡钱
----------------------------------------------------------------
function autoMoneyPickup()
    if not AUTO.AutoMoneyPickup then return false end
    if AUTO.Paused then return false end
    if not every("x_moneypick", tonumber(AUTO.MoneyPickupGap) or 1.2) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.MoneyPickupRange) or 60
    local best, bestDist = nil, range
    local ok = pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("Model") then
                local low = string.lower(d.Name)
                if string.find(low, "money", 1, true) or string.find(low, "coin", 1, true)
                    or string.find(low, "cash", 1, true) or string.find(low, "gold", 1, true) then
                    local p = xPosOf(d)
                    if p then
                        local dist = (p - base.Position).Magnitude
                        if dist < bestDist then
                            best, bestDist = { obj = d, pos = p }, dist
                        end
                    end
                end
            end
        end
    end)
    if not ok or not best then return false end
    xTp(best.pos + Vector3.new(0, 3, 0))
    AUTO.LastReason = string.format("捡钱：%s（%d 格）", best.obj.Name, xRound(bestDist))
    xStatAdd("捡钱", 1)
    return true
end

----------------------------------------------------------------
-- 55. 背包整理
----------------------------------------------------------------
function autoInventorySort()
    if not AUTO.AutoInventorySort then return false end
    if AUTO.Paused then return false end
    if not every("x_sort", tonumber(AUTO.InventorySortGap) or 60) then return false end
    local names = { "SortInventory", "InventorySort", "Sort" }
    local ok = false
    for _, n in ipairs(names) do
        if xFire(n) then ok = true break end
    end
    if not ok then ok = fireRemote("ShopSystem", "Sort") end
    if ok then
        AUTO.LastReason = "背包整理：已请求"
        log("背包整理：已请求整理背包")
        xStatAdd("背包整理", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 56. 自动送礼
----------------------------------------------------------------
function autoGiftSend()
    if not AUTO.AutoGiftSend then return false end
    if AUTO.Paused then return false end
    if not every("x_gift", tonumber(AUTO.GiftGap) or 30) then return false end
    local names = AUTO.GiftNames or {}
    if #names == 0 then return false end
    local n = 0
    for _, name in ipairs(names) do
        if xFire("Gift", name) or xFire("SendGift", name) then n = n + 1 end
    end
    if n > 0 then
        AUTO.LastReason = "送礼：" .. n .. " 个"
        log("自动送礼：已送出 " .. n .. " 个礼物")
        xStatAdd("送礼", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 57. 商店扫描（记录可购买物品）
----------------------------------------------------------------
function autoShopScan()
    if not AUTO.AutoShopScan then return false end
    if not every("x_shopscan", tonumber(AUTO.ShopScanGap) or 60) then return false end
    local seen = {}
    local ok = pcall(function()
        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("GuiButton") or d:IsA("TextLabel") then
                if d.Visible and d.Name ~= "" then
                    local low = string.lower(d.Name)
                    if string.find(low, "buy", 1, true) or string.find(low, "purchase", 1, true) then
                        seen[d.Name] = true
                    end
                end
            end
        end
    end)
    if not ok then return false end
    local list = {}
    for name in pairs(seen) do table.insert(list, name) end
    table.sort(list)
    AUTO.ShopScanCount = #list
    if #list > 0 then
        log("商店扫描：发现 " .. #list .. " 个购买按钮 → " .. table.concat(list, ", ", 1, math.min(#list, 10)))
        xStatAdd("商店扫描", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 58. 折扣购买（检测折扣标签）
----------------------------------------------------------------
function autoDiscountBuy()
    if not AUTO.AutoDiscountBuy then return false end
    if AUTO.Paused then return false end
    if not every("x_discount", tonumber(AUTO.DiscountGap) or 12) then return false end
    local money = xFindPlayerAttrNumber(AUTO.CurrencyNames or { "Money", "Cash", "Coins", "Gold" })
    local reserve = tonumber(AUTO.DiscountReserve) or 0
    if money ~= nil and money <= reserve then return false end
    local found = nil
    local ok = pcall(function()
        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.Text then
                local txt = string.lower(tostring(d.Text))
                if string.find(txt, "%", 1, false) and
                    (string.find(txt, "off", 1, true) or string.find(txt, "折", 1, true)) then
                    local parent = d.Parent
                    while parent and parent ~= pg do
                        if parent:IsA("GuiButton") then
                            found = parent
                            break
                        end
                        parent = parent.Parent
                    end
                end
            end
            if found then break end
        end
    end)
    if ok and found then
        clickGui(found)
        AUTO.LastReason = "折扣购买：已点击折扣商品"
        log("折扣购买：发现折扣标签，已点击")
        xStatAdd("折扣购买", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 59. 货币监控
----------------------------------------------------------------
function autoCurrencyWatch()
    if not AUTO.AutoCurrencyWatch then return false end
    if not every("x_currency", 5) then return false end
    local state = xSt("currency")
    local now = os.clock()
    local parts = {}
    for _, n in ipairs(AUTO.CurrencyNames or {}) do
        local v = xFindPlayerAttrNumber({ n })
        if v ~= nil then
            parts[#parts + 1] = string.format("%s=%s", n, xFmt(v))
            local prev = state[n]
            if prev ~= nil and v ~= prev then
                local delta = v - prev
                local perMin = delta / math.max(1, (now - (state.lastAt or now)) / 60)
                if every("x_currency_log_" .. n, 20) then
                    log(string.format("货币监控：%s %s（%s/分钟）", n,
                        (delta >= 0 and "+" or "") .. xFmt(delta), xFmt(perMin)))
                end
                xStatAdd("货币变化", 1)
            end
            state[n] = v
        end
    end
    state.lastAt = now
    AUTO.CurrencyLine = table.concat(parts, "  ")
    if #parts > 0 and every("x_currency_log", 60) then
        log("货币监控：" .. AUTO.CurrencyLine)
    end
    return #parts > 0
end

----------------------------------------------------------------
-- 60. 免费宝箱
----------------------------------------------------------------
function autoFreeChest()
    if not AUTO.AutoFreeChest then return false end
    if AUTO.Paused then return false end
    if not every("x_freechest", tonumber(AUTO.FreeChestGap) or 20) then return false end
    local names = { "FreeChest", "FreeReward", "ClaimFree", "DailyChest", "FreeGift" }
    for _, name in ipairs(names) do
        if xFire(name) or xInvoke(name) then
            AUTO.LastReason = "免费宝箱：" .. name
            log("免费宝箱：已请求领取（" .. name .. "）")
            xStatAdd("免费宝箱", 1)
            return true
        end
    end
    local prompt = xFindPromptByKeyword and xFindPromptByKeyword("free")
    if prompt then
        xUsePrompt(prompt)
        log("免费宝箱：已触发免费领取提示")
        xStatAdd("免费宝箱", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 V：大厅 / 波次 / 服务器 / 互动 / 收集 / 移动
-- ============================================================
----------------------------------------------------------------
local X4_DEFAULTS = {
    AutoLobbyLoop = false, LobbyLoopGap = 1.5,
    AutoServerHop = false, ServerHopMinPlayers = 3, ServerHopDelay = 45, ServerHopPing = 250,
    AutoRejoinGuard = false, RejoinCheckGap = 20,
    AutoKickGuard = false, KickGuardGap = 60,
    AutoVoteStrategy = false, VoteStrategyGap = 2,
    AutoQueueMode = false, QueueModeName = "Normal", QueueModeGap = 4,
    AutoResultContinuePlus = false, ResultPlusGap = 2.5,
    AutoWaveSkipEnhanced = false, WaveSkipPlusGap = 1.2,
    AutoWaveReward = false, WaveRewardGap = 6,
    AutoInteractPrompts = false, InteractRange = 25, InteractGap = 3, InteractKeywords = {},
    AutoChestHunt = false, ChestRange = 150, ChestGap = 8,
    AutoNPCTalk = false, NPCRange = 40, NPCGap = 6,
    AutoElevatorUse = false, ElevatorRange = 30, ElevatorGap = 5,
    AutoOrbCollect = false, OrbRange = 120, OrbGap = 2,
    AutoNearbyPickup = false, PickupRange = 40, PickupGap = 2,
    AutoPathToTarget = false, PathGap = 1.5, PathStopDistance = 8,
    AutoStuckDetect = false, StuckSeconds = 6, StuckDistance = 3,
    AutoFollowAlly = false, FollowAllyRange = 200, FollowDistance = 12,
    AutoStayInZone = false, ZoneRadius = 120,
    AutoHeightControl = false, MinHeight = -20, MaxHeight = 200, HeightGap = 1,
}

for k, v in pairs(X4_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

function xPing()
    local ok, v = pcall(function() return player:GetNetworkPing() end)
    if ok and tonumber(v) then return tonumber(v) * 1000 end
    return 0
end

function xPlayerCount()
    local n = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p and p.Parent then n = n + 1 end
    end
    return n
end

function xSpawnPos()
    local pad = workspace:FindFirstChild("AutoReady")
    if pad and pad:IsA("BasePart") then return pad.Position end
    local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
    if spawn then return spawn.Position end
    local base = xRoot2()
    return base and base.Position or Vector3.new(0, 20, 0)
end

function xClickButtonByName(root, names, gapKey, gap)
    if not root then return false end
    if gapKey and not every(gapKey, gap or 2) then return false end
    local ok = pcall(function()
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("GuiButton") and d.Visible then
                local low = string.lower(d.Name)
                for _, n in ipairs(names) do
                    if string.find(low, string.lower(tostring(n)), 1, true) and deepVisible(d) then
                        clickGui(d)
                        return true
                    end
                end
            end
        end
    end)
    return ok or false
end

----------------------------------------------------------------
-- 61. 大厅循环（投票 → 准备 → 开局）
----------------------------------------------------------------
function autoLobbyLoop()
    if not AUTO.AutoLobbyLoop then return false end
    if AUTO.Paused then return false end
    if inMatch() then return false end
    if not every("x_lobbyloop", tonumber(AUTO.LobbyLoopGap) or 1.5) then return false end
    local did = false
    if AUTO.AutoOpenVote then
        openVoteGui()
        did = true
    end
    if AUTO.AutoVote then
        if autoVote() then did = true end
    end
    if AUTO.AutoReady then
        autoReady()
        did = true
    end
    if AUTO.AutoStart then
        autoStartSolo()
        did = true
    end
    if did then
        AUTO.LastReason = "大厅循环：投票 / 准备 / 开局"
        xStatAdd("大厅循环", 1)
    end
    return did
end

----------------------------------------------------------------
-- 62. 自动跳服（人少 / 延迟高）
----------------------------------------------------------------
function autoServerHop()
    if not AUTO.AutoServerHop then return false end
    if AUTO.Paused then return false end
    if inMatch() then
        xSt("serverhop").since = nil
        return false
    end
    if not every("x_serverhop", 5) then return false end
    local state = xSt("serverhop")
    local n = xPlayerCount()
    local ping = xPing()
    local lowPlayers = n < (tonumber(AUTO.ServerHopMinPlayers) or 3)
    local highPing = ping >= (tonumber(AUTO.ServerHopPing) or 250)
    if not (lowPlayers or highPing) then
        state.since = nil
        return false
    end
    state.since = state.since or os.clock()
    local waited = os.clock() - state.since
    local delay = tonumber(AUTO.ServerHopDelay) or 45
    if waited < delay then
        AUTO.LastReason = string.format("跳服等待：%d 人 / %d ms（%d/%d 秒）",
            n, xRound(ping), xRound(waited), xRound(delay))
        return false
    end
    state.since = nil
    log(string.format("自动跳服：人数 %d，延迟 %d ms，准备跳服", n, xRound(ping)))
    notify("自动跳服", string.format("人数 %d / 延迟 %d ms，正在寻找新服务器", n, xRound(ping)))
    local ok = jumpServer()
    if not ok then
        log("自动跳服：没有找到合适的服务器")
    else
        xStatAdd("跳服", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 63. 重连保护
----------------------------------------------------------------
function autoRejoinGuard()
    if not AUTO.AutoRejoinGuard then return false end
    if not every("x_rejoin", tonumber(AUTO.RejoinCheckGap) or 20) then return false end
    local state = xSt("rejoin")
    if state.placeId == nil then state.placeId = game.PlaceId end
    if state.jobId == nil then state.jobId = game.JobId end
    if game.PlaceId ~= state.placeId then
        state.placeId = game.PlaceId
        state.jobId = game.JobId
        return false
    end
    if game.JobId == "" and state.jobId and state.jobId ~= "" then
        log("重连保护：检测到掉线，尝试重新加入")
        pcall(function()
            TeleportService:TeleportToPlaceInstance(state.placeId, state.jobId, player)
        end)
        xStatAdd("重连", 1)
        return true
    end
    state.jobId = game.JobId
    return false
end

----------------------------------------------------------------
-- 64. 防踢加强（定期微动 / 相机抖动）
----------------------------------------------------------------
function autoKickGuard()
    if not AUTO.AutoKickGuard then return false end
    if not every("x_kickguard", tonumber(AUTO.KickGuardGap) or 60) then return false end
    local cam = workspace.CurrentCamera
    pcall(function()
        if cam then
            VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
        end
    end)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    xStatAdd("防踢", 1)
    AUTO.LastReason = "防踢：已模拟输入"
    return true
end

----------------------------------------------------------------
-- 65. 投票策略（选票数最高的模式）
----------------------------------------------------------------
function autoVoteStrategy()
    if not AUTO.AutoVoteStrategy then return false end
    if AUTO.Paused then return false end
    if inMatch() then return false end
    if not every("x_votestrategy", tonumber(AUTO.VoteStrategyGap) or 2) then return false end
    local voteGui = workspace:FindFirstChild("Vote") or workspace:FindFirstChild("Voteing")
    if not voteGui then return false end
    local bestName, bestCount = nil, -1
    local ok = pcall(function()
        for _, d in ipairs(voteGui:GetDescendants()) do
            local low = string.lower(d.Name)
            if string.find(low, "count", 1, true) or string.find(low, "vote", 1, true) then
                if d:IsA("TextLabel") then
                    local n = tonumber(string.match(d.Text or "", "%d+"))
                    if n and n > bestCount then
                        bestCount = n
                        local parent = d.Parent
                        while parent and parent ~= voteGui do
                            if parent.Name ~= "Vote" and parent.Name ~= "Voteing" then
                                bestName = parent.Name
                            end
                            parent = parent.Parent
                        end
                    end
                end
            end
        end
    end)
    if not ok or not bestName then
        local mode = AUTO.GameMode
        if mode and mode ~= "" then
            AUTO.VoteMode = mode
            pcall(function()
                local r = RS:FindFirstChild("Vote")
                if r then r:FireServer(mode) end
            end)
            return true
        end
        return false
    end
    AUTO.VoteMode = bestName
    AUTO.LastReason = "投票策略：" .. bestName .. "（" .. bestCount .. " 票）"
    log(string.format("投票策略：选择票数最高的 %s（%d 票）", bestName, bestCount))
    pcall(function()
        local r = RS:FindFirstChild("Vote")
        if r then r:FireServer(bestName) end
    end)
    xStatAdd("策略投票", 1)
    return true
end

----------------------------------------------------------------
-- 66. 自动选择游戏模式
----------------------------------------------------------------
function autoQueueMode()
    if not AUTO.AutoQueueMode then return false end
    if AUTO.Paused then return false end
    if inMatch() then return false end
    if not every("x_queuemode", tonumber(AUTO.QueueModeGap) or 4) then return false end
    local gui = pg:FindFirstChild("mode select2")
    if not gui or not gui.Enabled then return false end
    local want = string.lower(tostring(AUTO.QueueModeName or ""))
    local clicked = false
    pcall(function()
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("GuiButton") and d.Visible then
                if string.find(string.lower(d.Name), want, 1, true) then
                    clickGui(d)
                    clicked = true
                    break
                end
            end
        end
    end)
    if clicked then
        AUTO.LastReason = "游戏模式：" .. tostring(AUTO.QueueModeName)
        log("自动选择模式：" .. tostring(AUTO.QueueModeName))
        xStatAdd("选择模式", 1)
    end
    return clicked
end

----------------------------------------------------------------
-- 67. 结算界面增强（继续 / 再来一局 / 领取）
----------------------------------------------------------------
function autoResultContinuePlus()
    if not AUTO.AutoResultContinuePlus then return false end
    if not every("x_resultplus", tonumber(AUTO.ResultPlusGap) or 2.5) then return false end
    local result = pg:FindFirstChild("ModeResult")
    if not result or not result.Enabled then return false end
    local names = { "Continue", "Next", "PlayAgain", "Restart", "Claim", "OK", "Confirm" }
    local clicked = xClickButtonByName(result, names, "x_resultbtn", 2)
    if clicked then
        AUTO.Phase = "结算"
        AUTO.LastReason = "结算增强：已点击继续"
        log("结算增强：已点击结算按钮")
        xStatAdd("结算继续", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 68. 跳波增强（自动找同意按钮）
----------------------------------------------------------------
function autoWaveSkipEnhanced()
    if not AUTO.AutoWaveSkipEnhanced then return false end
    if AUTO.Paused then return false end
    if not inMatch() then return false end
    if not every("x_waveskip", tonumber(AUTO.WaveSkipPlusGap) or 1.2) then return false end
    local roots = { pg, workspace }
    local names = { "Skip", "Yes", "同意", "跳过" }
    for _, root in ipairs(roots) do
        if xClickButtonByName(root, names, "x_waveskipbtn", 1.2) then
            AUTO.LastReason = "跳波增强：已点同意"
            log("跳波增强：已点击同意的按钮")
            xStatAdd("跳波", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 69. 波次奖励领取
----------------------------------------------------------------
function autoWaveReward()
    if not AUTO.AutoWaveReward then return false end
    if AUTO.Paused then return false end
    if not every("x_wavereward", tonumber(AUTO.WaveRewardGap) or 6) then return false end
    local names = { "Claim", "Reward", "Collect", "领取" }
    local clicked = false
    for _, root in ipairs({ pg, workspace }) do
        if xClickButtonByName(root, names, "x_waverewardbtn", 6) then
            clicked = true
            break
        end
    end
    if clicked then
        AUTO.LastReason = "波次奖励：已领取"
        log("波次奖励：已点击领取")
        xStatAdd("波次奖励", 1)
    end
    return clicked
end

----------------------------------------------------------------
-- 70. 自动互动（通用 ProximityPrompt）
----------------------------------------------------------------
function autoInteractPrompts()
    if not AUTO.AutoInteractPrompts then return false end
    if AUTO.Paused then return false end
    if not every("x_interact", tonumber(AUTO.InteractGap) or 3) then return false end
    local list = xNearPrompts(tonumber(AUTO.InteractRange) or 25)
    if #list == 0 then return false end
    local keywords = AUTO.InteractKeywords or {}
    local skipWords = { "buy", "purchase", "sell", "claim", "reward", "quest" }
    for _, p in ipairs(list) do
        local low = string.lower(tostring(p.name))
        local blocked = false
        for _, w in ipairs(skipWords) do
            if string.find(low, w, 1, true) then blocked = true break end
        end
        if not blocked then
            local match = (#keywords == 0)
            if not match then
                for _, k in ipairs(keywords) do
                    if string.find(low, string.lower(tostring(k)), 1, true) then match = true break end
                end
            end
            if match then
                xUsePrompt(p.prompt)
                AUTO.LastReason = "自动互动：" .. p.name
                log("自动互动：已触发 " .. p.name)
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------
-- 71. 自动找宝箱
----------------------------------------------------------------
function autoChestHunt()
    if not AUTO.AutoChestHunt then return false end
    if AUTO.Paused then return false end
    if not every("x_chesthunt", tonumber(AUTO.ChestGap) or 8) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.ChestRange) or 150
    local best, bestDist = nil, range
    local keywords = { "chest", "crate", "treasure", "box", "宝箱" }
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            local low = string.lower(d.Name)
            for _, k in ipairs(keywords) do
                if string.find(low, string.lower(k), 1, true) then
                    local p = xPosOf(d)
                    if p then
                        local dist = (p - base.Position).Magnitude
                        if dist < bestDist then
                            best, bestDist = { obj = d, pos = p }, dist
                        end
                    end
                    break
                end
            end
        end
    end)
    if not best then return false end
    xTp(best.pos + Vector3.new(0, 3, 0))
    local prompt = nil
    for _, p in ipairs(xNearPrompts(12)) do
        prompt = p.prompt
        break
    end
    if prompt then xUsePrompt(prompt) end
    AUTO.LastReason = string.format("宝箱：%s（%d 格）", best.obj.Name, xRound(bestDist))
    log(string.format("自动找宝箱：%s（%d 格）", best.obj.Name, xRound(bestDist)))
    xStatAdd("找宝箱", 1)
    return true
end

----------------------------------------------------------------
-- 72. 自动和 NPC 对话
----------------------------------------------------------------
function autoNPCTalk()
    if not AUTO.AutoNPCTalk then return false end
    if AUTO.Paused then return false end
    if not every("x_npc", tonumber(AUTO.NPCGap) or 6) then return false end
    local range = tonumber(AUTO.NPCRange) or 40
    for _, p in ipairs(xNearPrompts(range)) do
        local low = string.lower(tostring(p.name))
        if string.find(low, "talk", 1, true) or string.find(low, "dialog", 1, true)
            or string.find(low, "npc", 1, true) or string.find(low, "speak", 1, true) then
            xUsePrompt(p.prompt)
            AUTO.LastReason = "NPC 对话：" .. p.name
            log("自动对话：已触发 " .. p.name)
            xStatAdd("NPC对话", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 73. 自动使用电梯 / 传送点
----------------------------------------------------------------
function autoElevatorUse()
    if not AUTO.AutoElevatorUse then return false end
    if AUTO.Paused then return false end
    if not every("x_elevator", tonumber(AUTO.ElevatorGap) or 5) then return false end
    local range = tonumber(AUTO.ElevatorRange) or 30
    for _, p in ipairs(xNearPrompts(range)) do
        local low = string.lower(tostring(p.name))
        if string.find(low, "elevator", 1, true) or string.find(low, "lift", 1, true)
            or string.find(low, "teleport", 1, true) or string.find(low, "portal", 1, true) then
            xUsePrompt(p.prompt)
            AUTO.LastReason = "电梯 / 传送：" .. p.name
            log("自动电梯：已触发 " .. p.name)
            xStatAdd("电梯传送", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 74. 自动收集宝石 / 能量球
----------------------------------------------------------------
function autoOrbCollect()
    if not AUTO.AutoOrbCollect then return false end
    if AUTO.Paused then return false end
    if not every("x_orb", tonumber(AUTO.OrbGap) or 2) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.OrbRange) or 120
    local best, bestDist = nil, range
    local keywords = { "orb", "gem", "crystal", "shard", "core", "energy" }
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            local low = string.lower(d.Name)
            for _, k in ipairs(keywords) do
                if string.find(low, k, 1, true) then
                    local p = xPosOf(d)
                    if p then
                        local dist = (p - base.Position).Magnitude
                        if dist < bestDist then
                            best, bestDist = { obj = d, pos = p }, dist
                        end
                    end
                    break
                end
            end
        end
    end)
    if not best then return false end
    xTp(best.pos + Vector3.new(0, 3, 0))
    AUTO.LastReason = string.format("收集宝石：%s（%d 格）", best.obj.Name, xRound(bestDist))
    xStatAdd("收集宝石", 1)
    return true
end

----------------------------------------------------------------
-- 75. 自动拾取附近掉落
----------------------------------------------------------------
function autoNearbyPickup()
    if not AUTO.AutoNearbyPickup then return false end
    if AUTO.Paused then return false end
    if not every("x_pickup", tonumber(AUTO.PickupGap) or 2) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.PickupRange) or 40
    local best, bestDist = nil, range
    local keywords = { "pickup", "drop", "loot", "collect", "item", "reward" }
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            local low = string.lower(d.Name)
            for _, k in ipairs(keywords) do
                if string.find(low, k, 1, true) then
                    local p = xPosOf(d)
                    if p then
                        local dist = (p - base.Position).Magnitude
                        if dist < bestDist then
                            best, bestDist = { obj = d, pos = p }, dist
                        end
                    end
                    break
                end
            end
        end
    end)
    if not best then return false end
    xTp(best.pos + Vector3.new(0, 2, 0))
    AUTO.LastReason = string.format("拾取：%s（%d 格）", best.obj.Name, xRound(bestDist))
    xStatAdd("拾取", 1)
    return true
end

----------------------------------------------------------------
-- 76. 路径点移动
----------------------------------------------------------------
function autoPathToTarget()
    if not AUTO.AutoPathToTarget then return false end
    if AUTO.Paused then return false end
    local dest = AUTO.Waypoint
    if type(dest) ~= "table" or not dest.Position then
        local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
        dest = pick and pick.pos or nil
    end
    if not dest then return false end
    if not every("x_path", tonumber(AUTO.PathGap) or 1.5) then return false end
    local base = xRoot2()
    if not base then return false end
    local stop = tonumber(AUTO.PathStopDistance) or 8
    local d = (dest - base.Position)
    if d.Magnitude <= stop then return false end
    xWalkTo(dest)
    AUTO.LastReason = string.format("路径：前往目标（剩余 %d 格）", xRound(d.Magnitude))
    xStatAdd("路径移动", 1)
    return true
end

----------------------------------------------------------------
-- 77. 卡住检测
----------------------------------------------------------------
function autoStuckDetect()
    if not AUTO.AutoStuckDetect then return false end
    if AUTO.Paused then return false end
    if not every("x_stuck", 1) then return false end
    local state = xSt("stuck")
    local base = xRoot2()
    if not base then return false end
    local pos = base.Position
    local now = os.clock()
    if state.lastPos == nil then
        state.lastPos = pos
        state.lastAt = now
        return false
    end
    local moved = (pos - state.lastPos).Magnitude
    if moved > (tonumber(AUTO.StuckDistance) or 3) then
        state.lastPos = pos
        state.lastAt = now
        state.count = 0
        return false
    end
    local waited = now - (state.lastAt or now)
    if waited < (tonumber(AUTO.StuckSeconds) or 6) then return false end
    state.count = (state.count or 0) + 1
    state.lastAt = now
    state.lastPos = pos
    xJump()
    local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
    if pick then
        local dir = pick.pos - pos
        if dir.Magnitude > 0.01 then
            xTp(pos + dir.Unit * 8 + Vector3.new(0, 4, 0), pick.pos)
        end
    end
    AUTO.LastReason = "防卡住：已跳跃 / 小幅传送"
    if xToast("stuck", "防卡住", "检测到角色卡住，已尝试脱困", 10) then
        log("防卡住：检测到位置不动，已尝试脱困")
    end
    xStatAdd("防卡住", 1)
    return true
end

----------------------------------------------------------------
-- 78. 跟随队友
----------------------------------------------------------------
function autoFollowAlly()
    if not AUTO.AutoFollowAlly then return false end
    if AUTO.Paused then return false end
    if not every("x_follow", 1) then return false end
    local range = tonumber(AUTO.FollowAllyRange) or 200
    local list = xAllyList(range)
    if #list == 0 then
        AUTO.FollowTarget = nil
        return false
    end
    local target = list[1]
    AUTO.FollowTarget = target.player.Name
    local keep = tonumber(AUTO.FollowDistance) or 12
    if target.dist <= keep then return false end
    local base = xRoot2()
    if not base then return false end
    local dir = target.pos - base.Position
    if dir.Magnitude <= 0.01 then return false end
    xWalkTo(target.pos - dir.Unit * (keep * 0.6))
    AUTO.LastReason = string.format("跟随队友：%s（%d 格）", target.player.Name, xRound(target.dist))
    xStatAdd("跟随队友", 1)
    return true
end

----------------------------------------------------------------
-- 79. 区域限制（不跑出安全区）
----------------------------------------------------------------
function autoStayInZone()
    if not AUTO.AutoStayInZone then return false end
    if AUTO.Paused then return false end
    if not every("x_zone", 1.5) then return false end
    local state = xSt("zone")
    if not state.center then
        state.center = xSpawnPos()
    end
    local base = xRoot2()
    if not base or not state.center then return false end
    local radius = tonumber(AUTO.ZoneRadius) or 120
    local d = (base.Position - state.center).Magnitude
    if d <= radius then return false end
    local dir = (state.center - base.Position)
    if dir.Magnitude <= 0.01 then return false end
    xTp(state.center + dir.Unit * (radius * 0.6) + Vector3.new(0, 4, 0))
    AUTO.LastReason = string.format("区域限制：拉回安全区（%d 格）", xRound(d))
    xStatAdd("区域限制", 1)
    return true
end

----------------------------------------------------------------
-- 80. 高度控制
----------------------------------------------------------------
function autoHeightControl()
    if not AUTO.AutoHeightControl then return false end
    if AUTO.Paused then return false end
    if not every("x_height", tonumber(AUTO.HeightGap) or 1) then return false end
    local base = xRoot2()
    if not base then return false end
    local y = base.Position.Y
    local minY = tonumber(AUTO.MinHeight) or -20
    local maxY = tonumber(AUTO.MaxHeight) or 200
    local dest = nil
    if y < minY then
        dest = Vector3.new(base.Position.X, minY + 10, base.Position.Z)
    elseif y > maxY then
        dest = Vector3.new(base.Position.X, maxY - 10, base.Position.Z)
    end
    if not dest then return false end
    xTp(dest)
    AUTO.LastReason = string.format("高度控制：%.0f → %.0f", y, dest.Y)
    xStatAdd("高度控制", 1)
    return true
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 VI：统计 / 日志 / 配置 / 模块注册表 / 聊天命令
-- ============================================================
----------------------------------------------------------------
local X5_DEFAULTS = {
    AutoStats = false, StatsGap = 30,
    AutoSessionReport = false, SessionReportGap = 180,
    AutoConfigBackup = false, ConfigBackupGap = 120,
    AutoConfigRestore = false,
    AutoLagWatch = false, LagWatchGap = 10, LagWarnMs = 300,
    AutoMemoryClean = false, MemoryCleanGap = 180,
    AutoLogRotate = false, LogRotateMax = 200,
    AutoProfile = false, ProfileReportGap = 60,
    AutoNotifyDigest = false, DigestGap = 300,
    AutoCrashGuard = false, CrashGuardGap = 15,
    AutoSelfTest = false,
    ChatCommands = true, ChatPrefix = ";dm",
}

for k, v in pairs(X5_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

----------------------------------------------------------------
-- 81. 会话统计（击杀 / 治疗 / 时间）
----------------------------------------------------------------
function autoStats()
    if not AUTO.AutoStats then return false end
    if not every("x_stats", 0.5) then return false end
    local state = xSt("stats")
    state.start = state.start or os.clock()
    state.seen = state.seen or {}
    local folder = living()
    if folder then
        local now = {}
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") then
                now[m] = true
                if state.seen[m] == nil then
                    state.seen[m] = true
                    local h = m:FindFirstChildOfClass("Humanoid")
                    if h then
                        local ok = pcall(function()
                            h.Died:Connect(function()
                                if isEnemy(m) then
                                    xStatAdd("击杀", 1)
                                end
                            end)
                        end)
                        if not ok then
                            -- 无法连接死亡事件时交给下面的数量差检测
                        end
                    end
                end
            end
        end
        for m in pairs(state.seen) do
            if not now[m] then
                state.seen[m] = nil
            end
        end
    end
    AUTO.SessionSeconds = os.clock() - (state.start or os.clock())
    if every("x_stats_log", tonumber(AUTO.StatsGap) or 30) then
        local parts = {}
        for _, key in ipairs({ "击杀", "治疗队友", "复活队友", "跳服", "任务", "扭蛋" }) do
            local v = tonumber(AUTO.Stats[key])
            if v and v > 0 then
                parts[#parts + 1] = key .. "=" .. tostring(v)
            end
        end
        if #parts > 0 then
            log("统计：" .. table.concat(parts, "  ") ..
                string.format("  在线 %.0f 分钟", (AUTO.SessionSeconds or 0) / 60))
            xStatAdd("统计输出", 1)
        end
    end
    return true
end

----------------------------------------------------------------
-- 82. 会话报告
----------------------------------------------------------------
function autoSessionReport()
    if not AUTO.AutoSessionReport then return false end
    if not every("x_session", tonumber(AUTO.SessionReportGap) or 180) then return false end
    local mins = (AUTO.SessionSeconds or 0) / 60
    local kills = tonumber(AUTO.Stats["击杀"] or 0)
    local rate = mins > 0 and kills / mins or 0
    local lines = {
        string.format("在线 %.1f 分钟", mins),
        string.format("击杀 %d（%.1f/分钟）", kills, rate),
        "复活 " .. tostring(AUTO.Stats["复活队友"] or 0),
        "治疗 " .. tostring(AUTO.Stats["治疗队友"] or 0),
        "跳服 " .. tostring(AUTO.Stats["跳服"] or 0),
        "技能 " .. tostring((AUTO.Stats["优先技能"] or 0) + (AUTO.Stats["队列技能"] or 0)),
    }
    local text = table.concat(lines, "  ")
    log("会话报告：" .. text)
    AUTO.LastReport = text
    if AUTO.NotifyReport then notify("会话报告", text) end
    return true
end

----------------------------------------------------------------
-- 83. 配置备份
----------------------------------------------------------------
function autoConfigBackup()
    if not AUTO.AutoConfigBackup then return false end
    if not every("x_backup", tonumber(AUTO.ConfigBackupGap) or 120) then return false end
    if type(writefile) ~= "function" or type(configSnapshot) ~= "function" then return false end
    local ok = pcall(function()
        writefile("难度模式_配置备份.json", HttpService:JSONEncode(configSnapshot()))
    end)
    if ok then
        AUTO.LastBackupAt = os.time()
        log("配置备份：已写入 难度模式_配置备份.json")
        xStatAdd("配置备份", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 84. 配置恢复
----------------------------------------------------------------
function autoConfigRestore()
    if not AUTO.AutoConfigRestore then return false end
    if xSt("restore").done then return false end
    xSt("restore").done = true
    if type(readfile) ~= "function" then
        log("配置恢复：当前注入器不支持 readfile")
        return false
    end
    local ok, data = pcall(readfile, "难度模式_配置备份.json")
    if not ok or type(data) ~= "string" or data == "" then
        log("配置恢复：没有找到备份文件")
        return false
    end
    local ok2, obj = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 or type(obj) ~= "table" then
        log("配置恢复：备份文件解析失败")
        return false
    end
    local n = 0
    for k, v in pairs(obj) do
        if AUTO[k] ~= nil then
            AUTO[k] = v
            n = n + 1
        end
    end
    log("配置恢复：已恢复 " .. n .. " 项")
    notify("配置恢复", "已从备份恢复 " .. n .. " 项设置")
    return true
end

----------------------------------------------------------------
-- 85. 延迟监控
----------------------------------------------------------------
function autoLagWatch()
    if not AUTO.AutoLagWatch then return false end
    if not every("x_lag", tonumber(AUTO.LagWatchGap) or 10) then return false end
    local ping = xPing()
    AUTO.CurrentPing = xRound(ping)
    local warn = tonumber(AUTO.LagWarnMs) or 300
    if ping >= warn then
        if xToast("lag", "延迟警告", string.format("当前延迟 %d ms", xRound(ping)), 20) then
            log("延迟监控：" .. xRound(ping) .. " ms（偏高）")
            xStatAdd("高延迟", 1)
        end
        return true
    end
    if every("x_lag_log", 120) then
        log("延迟监控：稳定在 " .. xRound(ping) .. " ms")
    end
    return false
end

----------------------------------------------------------------
-- 86. 内存清理
----------------------------------------------------------------
function autoMemoryClean()
    if not AUTO.AutoMemoryClean then return false end
    if not every("x_clean", tonumber(AUTO.MemoryCleanGap) or 180) then return false end
    local cleaned = 0
    local rt = AUTO._RT
    if rt and rt.promptCache then
        rt.promptCache.list = {}
        rt.promptCache.t = 0
        cleaned = cleaned + 1
    end
    if rt and rt.enemyCache then
        for key in pairs(rt.enemyCache) do
            rt.enemyCache[key] = nil
            cleaned = cleaned + 1
        end
    end
    if type(collectgarbage) == "function" then
        pcall(collectgarbage, "collect")
    end
    log("内存清理：清理 " .. cleaned .. " 个缓存区")
    xStatAdd("内存清理", 1)
    return true
end

----------------------------------------------------------------
-- 87. 日志轮转
----------------------------------------------------------------
function autoLogRotate()
    if not AUTO.AutoLogRotate then return false end
    if not every("x_logrotate", 30) then return false end
    local maxN = tonumber(AUTO.LogRotateMax) or 200
    if #AUTO.Logs <= maxN then return false end
    local archive = {}
    for i = maxN + 1, #AUTO.Logs do
        table.insert(archive, AUTO.Logs[i])
    end
    for i = #AUTO.Logs, maxN + 1, -1 do
        table.remove(AUTO.Logs, i)
    end
    if type(appendfile) == "function" then
        pcall(function()
            appendfile("难度模式_日志.txt", table.concat(archive, "\n") .. "\n")
        end)
    end
    log("日志轮转：归档 " .. #archive .. " 条")
    return true
end

----------------------------------------------------------------
-- 88. 性能分析
----------------------------------------------------------------
function autoProfile()
    if not AUTO.AutoProfile then return false end
    if not every("x_profile", tonumber(AUTO.ProfileReportGap) or 60) then return false end
    local profile = xSt("profile")
    local rows = {}
    for name, t in pairs(profile) do
        if type(t) == "table" and t.calls and t.calls > 0 and t.time then
            local avg = t.time / t.calls * 1000
            rows[#rows + 1] = { name = name, avg = avg, calls = t.calls }
        end
    end
    if #rows == 0 then return false end
    table.sort(rows, function(a, b) return a.avg > b.avg end)
    local parts = {}
    for i = 1, math.min(6, #rows) do
        parts[#parts + 1] = string.format("%s %.2fms×%d", rows[i].name, rows[i].avg, rows[i].calls)
    end
    log("性能分析：" .. table.concat(parts, "  "))
    if every("x_profile_reset", 300) then
        for k in pairs(profile) do profile[k] = nil end
    end
    return true
end

----------------------------------------------------------------
-- 89. 摘要通知
----------------------------------------------------------------
function autoNotifyDigest()
    if not AUTO.AutoNotifyDigest then return false end
    if not every("x_digest", tonumber(AUTO.DigestGap) or 300) then return false end
    local msg = string.format("在线 %.0f 分钟 · 击杀 %d · 波次 %s · 延迟 %s ms",
        (AUTO.SessionSeconds or 0) / 60,
        tonumber(AUTO.Stats["击杀"] or 0),
        tostring(AUTO.WaveNow or "-"),
        tostring(AUTO.CurrentPing or "-"))
    notify("挂机摘要", msg)
    log("摘要通知：" .. msg)
    return true
end

----------------------------------------------------------------
-- 90. 崩溃保护
----------------------------------------------------------------
function autoCrashGuard()
    if not AUTO.AutoCrashGuard then return false end
    if not every("x_crash", tonumber(AUTO.CrashGuardGap) or 15) then return false end
    AUTO.LoopErrors = tonumber(AUTO.LoopErrors) or 0
    local state = xSt("crash")
    if AUTO.LoopErrors > (state.lastCount or 0) then
        local delta = AUTO.LoopErrors - (state.lastCount or 0)
        state.lastCount = AUTO.LoopErrors
        log("崩溃保护：检测到 " .. delta .. " 次循环异常，已记录")
        if AUTO.LoopErrors >= 20 then
            stopFire()
            stopAim()
            notify("崩溃保护", "异常过多，已停止战斗动作，请查看日志")
            AUTO.LastReason = "崩溃保护：已停止战斗动作"
            xStatAdd("崩溃保护", 1)
        end
    end
    return true
end

----------------------------------------------------------------
-- 91. 环境自检增强
----------------------------------------------------------------
function autoSelfTest()
    if not AUTO.AutoSelfTest then return false end
    if xSt("selftest").done then return false end
    xSt("selftest").done = true
    local checks = {
        { "Remote", "Vote" }, { "Remote", "GetReadyRemote" }, { "Remote", "QuestFuse" },
        { "Remote", "ShopSystem" }, { "Remote", "Potions" }, { "Remote", "SkillActivate" },
        { "Remote", "MainHandler" }, { "UI", "PlayerGui" }, { "Workspace", "Living" },
    }
    local okN, badN = 0, 0
    for _, c in ipairs(checks) do
        local found = nil
        if c[1] == "Remote" then found = xFindRemote(c[2])
        elseif c[1] == "UI" then found = pg:FindFirstChild(c[2])
        elseif c[1] == "Workspace" then found = workspace:FindFirstChild(c[2]) end
        if found then okN = okN + 1 else badN = badN + 1 end
    end
    log(string.format("环境自检：可用 %d 项，缺失 %d 项（缺失不影响已实现功能）", okN, badN))
    notify("环境自检", string.format("可用 %d 项 / 缺失 %d 项", okN, badN))
    return true
end

----------------------------------------------------------------
-- 模块注册表：聊天命令与状态面板共用
----------------------------------------------------------------
local MODULE_REGISTRY = {}

function reg(key, title, group, kind, desc)
    table.insert(MODULE_REGISTRY, { key = key, title = title, group = group, kind = kind or "bool", desc = desc or "" })
end

-- 战斗 / 目标
reg("AutoTargetPriority", "目标优先级", "战斗", "bool", "按智能 / 最近 / 残血 / 高血量 / Boss 选择目标")
reg("TargetPriority", "优先级策略", "战斗", "string", "智能 / 最近 / 最远 / 残血 / 高血量 / Boss优先")
reg("AutoFocusBoss", "集火Boss", "战斗", "bool", "优先锁定 Boss 并释放技能")
reg("AutoKite", "风筝走位", "战斗", "bool", "保持与敌人的距离区间")
reg("AutoOrbit", "环绕走位", "战斗", "bool", "围绕目标转圈")
reg("AutoStrafe", "左右横移", "战斗", "bool", "左右横移降低被命中率")
reg("AutoJumpDodge", "跳跃闪避", "战斗", "bool", "近距离或投射物靠近时跳跃拉开")
reg("AutoRetreatHeal", "低血撤退", "战斗", "bool", "低于阈值撤到安全点")
reg("AutoEmergencyTeleport", "紧急传送", "战斗", "bool", "濒死时传送到远处")
reg("AutoBossWarn", "Boss警报", "战斗", "bool", "Boss 出现时提醒")
reg("AutoWaveMonitor", "波次监测", "战斗", "bool", "记录每波用时和变化")
reg("AutoAssistAlly", "协助队友", "战斗", "bool", "队友掉血时帮忙清怪")
reg("AutoReviveChain", "复活链", "战斗", "bool", "优先赶往最近倒地队友")
reg("AutoWeaponSwitch", "自动换武器", "战斗", "bool", "按优先级和使用场景自动换武器")
reg("AutoSkillBurst", "技能爆发", "战斗", "bool", "短窗口连续释放技能")
reg("AutoSkillHold", "技能保留", "战斗", "bool", "敌人太少时保留技能")
reg("AutoAmmoCheck", "弹药检查", "战斗", "bool", "空弹自动换弹或换武器")
reg("AutoReload", "自动换弹", "战斗", "bool", "空弹时请求换弹")
reg("AutoLowHpNotify", "低血提醒", "战斗", "bool", "低血时通知一次")
-- 补给 / 生存
reg("AutoFood", "自动进食", "补给", "bool", "低血自动吃东西")
reg("AutoBandage", "自动包扎", "补给", "bool", "低血使用医疗包")
reg("AutoShieldItem", "自动护盾", "补给", "bool", "低血使用护盾道具")
reg("AutoCleanse", "自动净化", "补给", "bool", "异常状态时使用净化")
reg("AutoHealAlly", "治疗队友", "补给", "bool", "队友低血时治疗")
reg("AutoRegenWait", "回血等待", "补给", "bool", "低血后撤等待回血")
reg("AutoPotionCombo", "药水连招", "补给", "bool", "依次使用多种药水")
reg("AutoAntiVoid", "防掉虚空", "生存", "bool", "角色过低时拉回")
reg("AutoFallGuard", "坠落保护", "生存", "bool", "高速下坠时减速抬升")
reg("AutoBurnGuard", "急速掉血保护", "生存", "bool", "瞬间掉血时后撤治疗")
reg("AutoStatusWatch", "状态监视", "生存", "bool", "记录状态和属性变化")
-- 技能 / 科技
reg("AutoSkillPriority", "技能优先级", "技能", "bool", "按列表顺序释放技能")
reg("AutoSkillQueue", "技能队列", "技能", "bool", "排队逐个释放技能")
reg("AutoCooldownReport", "冷却报告", "技能", "bool", "定时输出技能冷却")
reg("AutoUltimateTracker", "大招追踪", "技能", "bool", "大招就绪时提醒")
reg("AutoManaCheck", "能量检查", "技能", "bool", "蓝量低时补充")
reg("AutoTechSpend", "自动花科技点", "科技", "bool", "自动升级技能树节点")
reg("AutoUnlockCheap", "解锁最便宜", "科技", "bool", "优先解锁花费最低的节点")
reg("AutoSaveTech", "科技点保留", "科技", "bool", "低于保留值时记录提示")
reg("AutoPrestigeCheck", "转生检查", "科技", "bool", "满足条件时请求转生")
reg("AutoPassiveToggle", "自动被动", "科技", "bool", "定时切换被动")
reg("AutoBuffRefresh", "自动续Buff", "科技", "bool", "定时续增益")
reg("AutoArmorRepair", "自动修甲", "科技", "bool", "护甲低时购买修复")
-- 任务 / 经济
reg("AutoQuestAccept", "自动接任务", "任务", "bool", "自动接取任务")
reg("AutoQuestComplete", "自动交任务", "任务", "bool", "自动交付任务")
reg("AutoDailyClaim", "自动每日", "任务", "bool", "领取每日奖励")
reg("AutoWeeklyClaim", "自动每周", "任务", "bool", "领取每周奖励")
reg("AutoQuestTrack", "任务追踪", "任务", "bool", "点任务追踪按钮")
reg("AutoQuestSkip", "放弃低收益", "任务", "bool", "放弃低奖励任务")
reg("AutoSquadLoop", "小队任务循环", "任务", "bool", "接取并完成小队任务")
reg("AutoQuestReport", "任务统计", "任务", "bool", "定时输出任务统计")
reg("AutoSellJunk", "出售杂物", "经济", "bool", "自动出售背包杂物")
reg("AutoBudgetBuy", "预算购买", "经济", "bool", "保留余额后按预算购买")
reg("AutoRestock", "自动补货", "经济", "bool", "定时补购消耗品")
reg("AutoCrateOpen", "自动开箱", "经济", "bool", "靠近并开启箱子")
reg("AutoGachaPlan", "扭蛋计划", "经济", "bool", "余额足够时扭蛋")
reg("AutoMoneyPickup", "自动捡钱", "经济", "bool", "传送拾取钱币")
reg("AutoInventorySort", "背包整理", "经济", "bool", "定时整理背包")
reg("AutoGiftSend", "自动送礼", "经济", "bool", "定时送出礼物")
reg("AutoShopScan", "商店扫描", "经济", "bool", "记录商店购买按钮")
reg("AutoDiscountBuy", "折扣购买", "经济", "bool", "发现折扣时点击")
reg("AutoCurrencyWatch", "货币监控", "经济", "bool", "记录货币变化速度")
reg("AutoFreeChest", "免费宝箱", "经济", "bool", "领取免费奖励")
-- 大厅 / 服务器
reg("AutoLobbyLoop", "大厅循环", "大厅", "bool", "投票准备开局一条龙")
reg("AutoServerHop", "自动跳服", "大厅", "bool", "人少或高延迟时跳服")
reg("AutoRejoinGuard", "重连保护", "大厅", "bool", "掉线时尝试重连")
reg("AutoKickGuard", "防踢加强", "大厅", "bool", "定时模拟输入")
reg("AutoVoteStrategy", "投票策略", "大厅", "bool", "选择票数最高的模式")
reg("AutoQueueMode", "选择模式", "大厅", "bool", "自动点击指定模式")
reg("AutoResultContinuePlus", "结算增强", "大厅", "bool", "结算界面自动继续")
reg("AutoWaveSkipEnhanced", "跳波增强", "大厅", "bool", "自动点跳波同意")
reg("AutoWaveReward", "波次奖励", "大厅", "bool", "自动领取波次奖励")
-- 互动 / 收集 / 移动
reg("AutoInteractPrompts", "自动互动", "互动", "bool", "触发附近通用提示")
reg("AutoChestHunt", "自动找宝箱", "互动", "bool", "寻找并打开宝箱")
reg("AutoNPCTalk", "NPC对话", "互动", "bool", "自动和 NPC 对话")
reg("AutoElevatorUse", "电梯传送", "互动", "bool", "自动使用电梯或传送点")
reg("AutoOrbCollect", "收集宝石", "收集", "bool", "收集宝石 / 能量球")
reg("AutoNearbyPickup", "拾取掉落", "收集", "bool", "拾取附近掉落物")
reg("AutoPathToTarget", "路径移动", "移动", "bool", "朝目标路径点移动")
reg("AutoStuckDetect", "防卡住", "移动", "bool", "卡住时跳跃脱困")
reg("AutoFollowAlly", "跟随队友", "移动", "bool", "跟着最近的队友")
reg("AutoStayInZone", "区域限制", "移动", "bool", "跑太远时拉回安全区")
reg("AutoHeightControl", "高度控制", "移动", "bool", "把角色保持在高度范围内")
-- 统计 / 系统
reg("AutoStats", "会话统计", "系统", "bool", "统计击杀和在线时长")
reg("AutoSessionReport", "会话报告", "系统", "bool", "定时输出版报告")
reg("AutoConfigBackup", "配置备份", "系统", "bool", "定时备份配置")
reg("AutoConfigRestore", "配置恢复", "系统", "bool", "启动时恢复备份")
reg("AutoLagWatch", "延迟监控", "系统", "bool", "记录延迟并警告")
reg("AutoMemoryClean", "内存清理", "系统", "bool", "定时清理缓存")
reg("AutoLogRotate", "日志轮转", "系统", "bool", "日志过多时归档")
reg("AutoProfile", "性能分析", "系统", "bool", "统计各模块耗时")
reg("AutoNotifyDigest", "挂机摘要", "系统", "bool", "定时推送摘要")
reg("AutoCrashGuard", "崩溃保护", "系统", "bool", "异常过多时停止战斗")
reg("AutoSelfTest", "环境自检", "系统", "bool", "检查关键接口")
-- 老版核心功能也纳入注册表，方便聊天命令控制
reg("AutoFarm", "自动刷怪", "核心", "bool", "自动找怪并刷怪")
reg("AutoSkill", "自动技能", "核心", "bool", "自动释放技能")
reg("AutoAim", "自动瞄准", "核心", "bool", "锁定敌人")
reg("AutoFight", "自动开火", "核心", "bool", "自动开火")
reg("AutoRevive", "自动救人", "核心", "bool", "自动救倒地队友")
reg("AutoRespawn", "无限复活", "核心", "bool", "残血自动重置角色")
reg("AutoBuyHP", "自动补血", "核心", "bool", "低血购买补血")
reg("AutoPotion", "自动喝药", "核心", "bool", "低血喝药")
reg("AutoBoost", "自动加速", "核心", "bool", "定时续加速")
reg("AutoUseMoney", "自动金钱袋", "核心", "bool", "使用金钱袋")
reg("AutoSkillTree", "自动技能树", "核心", "bool", "升级技能树")
reg("AutoGacha", "自动抽奖", "核心", "bool", "自动抽角色 / 皮肤")
reg("AutoSquadQuest", "自动小队任务", "核心", "bool", "完成小队任务")
reg("AutoRestartVote", "自动重开投票", "核心", "bool", "发起重开投票")
reg("AutoTitle", "自动称号", "核心", "bool", "自动装备称号")
reg("AutoCollect", "自动收集", "核心", "bool", "自动收集地图物品")
reg("AutoVote", "自动投票", "核心", "bool", "大厅自动投票")
reg("AutoReady", "自动准备", "核心", "bool", "自动准备")
reg("AutoStart", "自动单人开局", "核心", "bool", "自动开单人局")
reg("AutoOpenVote", "自动开投票界面", "核心", "bool", "打开投票界面")
reg("AutoSkipVote", "自动跳波投票", "核心", "bool", "自动跟跳波票")
reg("AutoContinue", "结算继续", "核心", "bool", "结算自动准备下一局")
reg("AutoEquipChar", "自动装备角色", "核心", "bool", "装备指定角色")
reg("AutoSkipHeli", "跳过直升机", "核心", "bool", "跳过直升机过场")
reg("AutoAntiAfk", "防踢", "核心", "bool", "防止 AFK 踢出")
reg("AutoSave", "自动保存", "核心", "bool", "定时保存配置")
reg("AutoGameModeLobby", "大厅自动模式", "核心", "bool", "大厅自动选模式")

----------------------------------------------------------------
-- 92. 聊天命令系统
----------------------------------------------------------------
local CHAT_HELP_LINES = {
    "难度模式 聊天命令（前缀 " .. tostring(AUTO.ChatPrefix) .. "）",
    AUTO.ChatPrefix .. " 帮助                  显示本帮助",
    AUTO.ChatPrefix .. " 状态                  输出当前状态",
    AUTO.ChatPrefix .. " 统计                  输出统计",
    AUTO.ChatPrefix .. " 列表 [分组]           列出模块与开关",
    AUTO.ChatPrefix .. " 开 <模块名>           打开模块",
    AUTO.ChatPrefix .. " 关 <模块名>           关闭模块",
    AUTO.ChatPrefix .. " 切换 <模块名>         反向切换",
    AUTO.ChatPrefix .. " 设置 <键> <值>        修改参数",
    AUTO.ChatPrefix .. " 执行 <模块名>         立即执行一次",
    AUTO.ChatPrefix .. " 全部关                关闭所有模块",
    AUTO.ChatPrefix .. " 保存 / 读配置         保存或恢复配置",
    AUTO.ChatPrefix .. " 报告                  写入会话报告",
    "模块名可以用中文标题或英文键名，支持模糊匹配",
}

function xFindModule(name)
    if not name or name == "" then return nil end
    local low = string.lower(tostring(name))
    for _, m in ipairs(MODULE_REGISTRY) do
        if string.lower(m.key) == low or string.lower(m.title) == low then
            return m
        end
    end
    for _, m in ipairs(MODULE_REGISTRY) do
        if string.find(string.lower(m.key), low, 1, true) or string.find(string.lower(m.title), low, 1, true) then
            return m
        end
    end
    return nil
end

function xRegistryLines(group)
    local lines = {}
    for _, m in ipairs(MODULE_REGISTRY) do
        if not group or group == "" or m.group == group then
            local val = AUTO[m.key]
            local mark = "关"
            if m.kind == "bool" then
                mark = val and "开" or "关"
            else
                mark = tostring(val)
            end
            lines[#lines + 1] = string.format("[%s] %s（%s）= %s", m.group, m.title, m.key, mark)
        end
    end
    return lines
end

function xReportToFile()
    local lines = {}
    lines[#lines + 1] = "难度模式 会话报告"
    lines[#lines + 1] = "时间：" .. os.date("%Y-%m-%d %H:%M:%S")
    lines[#lines + 1] = string.format("在线：%.1f 分钟", (AUTO.SessionSeconds or 0) / 60)
    lines[#lines + 1] = "阶段：" .. tostring(AUTO.Phase or "-")
    lines[#lines + 1] = "波次：" .. tostring(AUTO.WaveNow or "-")
    lines[#lines + 1] = "延迟：" .. tostring(AUTO.CurrentPing or "-") .. " ms"
    lines[#lines + 1] = "统计："
    local keys = {}
    for k in pairs(AUTO.Stats) do keys[#keys + 1] = k end
    table.sort(keys)
    for _, k in ipairs(keys) do
        lines[#lines + 1] = string.format("  %s = %s", k, tostring(AUTO.Stats[k]))
    end
    lines[#lines + 1] = "模块："
    for _, l in ipairs(xRegistryLines(nil)) do lines[#lines + 1] = "  " .. l end
    local text = table.concat(lines, "\n")
    if type(writefile) == "function" then
        pcall(function() writefile("难度模式_会话报告.txt", text) end)
        notify("会话报告", "已写入 难度模式_会话报告.txt")
    else
        print(text)
        notify("会话报告", "已输出到控制台")
    end
    return text
end

function xHandleChatCommand(raw)
    if type(raw) ~= "string" then return end
    local prefix = tostring(AUTO.ChatPrefix or ";dm")
    if raw:sub(1, #prefix) ~= prefix then return end
    local body = raw:sub(#prefix + 1)
    body = body:gsub("^%s+", "")
    local cmd, rest = body:match("^(%S*)%s*(.*)$")
    cmd = tostring(cmd or "")
    rest = tostring(rest or "")
    local function say(text)
        notify("聊天命令", tostring(text))
        log("聊天命令：" .. tostring(text))
    end
    if cmd == "" or cmd == "帮助" or cmd == "help" then
        local text = table.concat(CHAT_HELP_LINES, "\n")
        notify("聊天帮助", "共 " .. #CHAT_HELP_LINES .. " 条命令，详见日志")
        for _, line in ipairs(CHAT_HELP_LINES) do log(line) end
        return text
    end
    if cmd == "状态" or cmd == "status" then
        refreshStatus()
        say(string.format("阶段 %s · 波次 %s · 击杀 %s · 在线 %.0f 分钟",
            tostring(AUTO.Phase or "-"), tostring(AUTO.WaveNow or "-"),
            tostring(AUTO.Stats["击杀"] or 0), (AUTO.SessionSeconds or 0) / 60))
        return
    end
    if cmd == "统计" or cmd == "stats" then
        local keys = {}
        for k in pairs(AUTO.Stats) do keys[#keys + 1] = k end
        table.sort(keys)
        local parts = {}
        for _, k in ipairs(keys) do
            parts[#parts + 1] = k .. "=" .. tostring(AUTO.Stats[k])
        end
        say(#parts > 0 and table.concat(parts, "  ") or "暂无统计")
        return
    end
    if cmd == "列表" or cmd == "list" then
        local lines = xRegistryLines(rest)
        for _, l in ipairs(lines) do log(l) end
        say("共 " .. #lines .. " 个模块" .. (rest ~= "" and ("（分组 " .. rest .. "）") or ""))
        return
    end
    if cmd == "开" or cmd == "关" or cmd == "切换" or cmd == "on" or cmd == "off" or cmd == "toggle" then
        local m = xFindModule(rest)
        if not m then
            say("没有找到模块：" .. rest)
            return
        end
        local want
        if cmd == "开" or cmd == "on" then want = true
        elseif cmd == "关" or cmd == "off" then want = false
        else want = not AUTO[m.key] end
        AUTO[m.key] = want
        say(string.format("%s 已%s", m.title, want and "打开" or "关闭"))
        return
    end
    if cmd == "设置" or cmd == "set" then
        local k, v = rest:match("^(%S+)%s+(.+)$")
        if not k then
            say("用法：" .. prefix .. " 设置 <键> <值>")
            return
        end
        local target = nil
        for _, m in ipairs(MODULE_REGISTRY) do
            if string.lower(m.key) == string.lower(k) then target = m break end
        end
        if not target then
            -- 允许直接设置任意存在的键
            if AUTO[k] == nil then
                say("没有这个参数：" .. k)
                return
            end
        end
        local old = AUTO[k]
        local newVal = v
        if type(old) == "number" then
            newVal = tonumber(v) or old
        elseif type(old) == "boolean" then
            newVal = (v == "true" or v == "开" or v == "1" or v == "on")
        end
        AUTO[k] = newVal
        say(string.format("%s = %s", k, tostring(newVal)))
        return
    end
    if cmd == "执行" or cmd == "run" then
        local m = xFindModule(rest)
        if not m then
            say("没有找到模块：" .. rest)
            return
        end
        local runner = MODULE_RUNNERS[m.key]
        if not runner then
            say("这个模块没有独立执行入口：" .. m.title)
            return
        end
        local old = AUTO[m.key]
        AUTO[m.key] = true
        local ok, err = pcall(runner)
        if not old then AUTO[m.key] = old end
        say(ok and ("已执行 " .. m.title) or ("执行失败：" .. tostring(err)))
        return
    end
    if cmd == "全部关" or cmd == "alloff" then
        local n = 0
        for _, m in ipairs(MODULE_REGISTRY) do
            if m.kind == "bool" and AUTO[m.key] then
                AUTO[m.key] = false
                n = n + 1
            end
        end
        stopFire()
        stopAim()
        say("已关闭 " .. n .. " 个模块")
        return
    end
    if cmd == "保存" or cmd == "save" then
        local ok = saveConfig and saveConfig()
        say(ok and "配置已保存" or "当前注入器不支持保存")
        return
    end
    if cmd == "读配置" or cmd == "load" then
        AUTO.AutoConfigRestore = true
        xSt("restore").done = false
        autoConfigRestore()
        say("已尝试从备份恢复配置")
        return
    end
    if cmd == "报告" or cmd == "report" then
        xReportToFile()
        say("会话报告已生成")
        return
    end
    if cmd == "暂停" or cmd == "pause" then
        AUTO.Paused = not AUTO.Paused
        if AUTO.Paused then
            stopFire()
            stopAim()
        end
        say(AUTO.Paused and "已暂停" or "已继续")
        return
    end
    say("未知命令：" .. cmd .. "，输入 " .. prefix .. " 帮助 查看用法")
end

pcall(function()
    player.Chatted:Connect(function(msg)
        if AUTO.ChatCommands == false then return end
        xHandleChatCommand(msg)
    end)
end)

-- 供执行入口使用的模块表（键名 → 函数）
MODULE_RUNNERS = {
    AutoTargetPriority = autoTargetPriority,
    AutoFocusBoss = autoFocusBoss,
    AutoKite = autoKite,
    AutoOrbit = autoOrbit,
    AutoStrafe = autoStrafe,
    AutoJumpDodge = autoJumpDodge,
    AutoRetreatHeal = autoRetreatHeal,
    AutoEmergencyTeleport = autoEmergencyTeleport,
    AutoBossWarn = autoBossWarn,
    AutoWaveMonitor = autoWaveMonitor,
    AutoAssistAlly = autoAssistAlly,
    AutoReviveChain = autoReviveChain,
    AutoWeaponSwitch = autoWeaponSwitch,
    AutoSkillBurst = autoSkillBurst,
    AutoSkillHold = autoSkillHold,
    AutoAmmoCheck = autoAmmoCheck,
    AutoLowHpNotify = autoLowHpNotify,
    AutoFood = autoFood,
    AutoBandage = autoBandage,
    AutoShieldItem = autoShieldItem,
    AutoCleanse = autoCleanse,
    AutoHealAlly = autoHealAlly,
    AutoRegenWait = autoRegenWait,
    AutoPotionCombo = autoPotionCombo,
    AutoAntiVoid = autoAntiVoid,
    AutoFallGuard = autoFallGuard,
    AutoBurnGuard = autoBurnGuard,
    AutoStatusWatch = autoStatusWatch,
    AutoSkillPriority = autoSkillPriority,
    AutoSkillQueue = autoSkillQueue,
    AutoCooldownReport = autoCooldownReport,
    AutoUltimateTracker = autoUltimateTracker,
    AutoManaCheck = autoManaCheck,
    AutoTechSpend = autoTechSpend,
    AutoUnlockCheap = autoUnlockCheap,
    AutoSaveTech = autoSaveTech,
    AutoPrestigeCheck = autoPrestigeCheck,
    AutoPassiveToggle = autoPassiveToggle,
    AutoBuffRefresh = autoBuffRefresh,
    AutoArmorRepair = autoArmorRepair,
    AutoQuestAccept = autoQuestAccept,
    AutoQuestComplete = autoQuestComplete,
    AutoDailyClaim = autoDailyClaim,
    AutoWeeklyClaim = autoWeeklyClaim,
    AutoQuestTrack = autoQuestTrack,
    AutoQuestSkip = autoQuestSkip,
    AutoSquadLoop = autoSquadLoop,
    AutoQuestReport = autoQuestReport,
    AutoSellJunk = autoSellJunk,
    AutoBudgetBuy = autoBudgetBuy,
    AutoRestock = autoRestock,
    AutoCrateOpen = autoCrateOpen,
    AutoGachaPlan = autoGachaPlan,
    AutoMoneyPickup = autoMoneyPickup,
    AutoInventorySort = autoInventorySort,
    AutoGiftSend = autoGiftSend,
    AutoShopScan = autoShopScan,
    AutoDiscountBuy = autoDiscountBuy,
    AutoCurrencyWatch = autoCurrencyWatch,
    AutoFreeChest = autoFreeChest,
    AutoLobbyLoop = autoLobbyLoop,
    AutoServerHop = autoServerHop,
    AutoRejoinGuard = autoRejoinGuard,
    AutoKickGuard = autoKickGuard,
    AutoVoteStrategy = autoVoteStrategy,
    AutoQueueMode = autoQueueMode,
    AutoResultContinuePlus = autoResultContinuePlus,
    AutoWaveSkipEnhanced = autoWaveSkipEnhanced,
    AutoWaveReward = autoWaveReward,
    AutoInteractPrompts = autoInteractPrompts,
    AutoChestHunt = autoChestHunt,
    AutoNPCTalk = autoNPCTalk,
    AutoElevatorUse = autoElevatorUse,
    AutoOrbCollect = autoOrbCollect,
    AutoNearbyPickup = autoNearbyPickup,
    AutoPathToTarget = autoPathToTarget,
    AutoStuckDetect = autoStuckDetect,
    AutoFollowAlly = autoFollowAlly,
    AutoStayInZone = autoStayInZone,
    AutoHeightControl = autoHeightControl,
    AutoStats = autoStats,
    AutoSessionReport = autoSessionReport,
    AutoConfigBackup = autoConfigBackup,
    AutoConfigRestore = autoConfigRestore,
    AutoLagWatch = autoLagWatch,
    AutoMemoryClean = autoMemoryClean,
    AutoLogRotate = autoLogRotate,
    AutoProfile = autoProfile,
    AutoNotifyDigest = autoNotifyDigest,
    AutoCrashGuard = autoCrashGuard,
    AutoSelfTest = autoSelfTest,
}

----------------------------------------------------------------
-- 统一调度：大厅 / 战斗 / 常驻
----------------------------------------------------------------
local LOBBY_QUEUE = {
    "AutoLobbyLoop", "AutoVoteStrategy", "AutoQueueMode", "AutoQuestAccept", "AutoQuestComplete",
    "AutoDailyClaim", "AutoWeeklyClaim", "AutoQuestTrack", "AutoQuestSkip", "AutoSquadLoop",
    "AutoQuestReport", "AutoSellJunk", "AutoBudgetBuy", "AutoRestock", "AutoGachaPlan",
    "AutoInventorySort", "AutoGiftSend", "AutoShopScan", "AutoDiscountBuy", "AutoCurrencyWatch",
    "AutoFreeChest", "AutoCrateOpen", "AutoNPCTalk", "AutoInteractPrompts", "AutoSelfTest",
    "AutoConfigRestore",
}

local COMBAT_QUEUE = {
    "AutoTargetPriority", "AutoFocusBoss", "AutoKite", "AutoOrbit", "AutoStrafe",
    "AutoJumpDodge", "AutoRetreatHeal", "AutoEmergencyTeleport", "AutoBossWarn",
    "AutoWaveMonitor", "AutoAssistAlly", "AutoReviveChain", "AutoWeaponSwitch",
    "AutoSkillBurst", "AutoSkillHold", "AutoAmmoCheck", "AutoLowHpNotify",
    "AutoFood", "AutoBandage", "AutoShieldItem", "AutoCleanse", "AutoHealAlly",
    "AutoRegenWait", "AutoPotionCombo", "AutoAntiVoid", "AutoFallGuard",
    "AutoBurnGuard", "AutoStatusWatch", "AutoSkillPriority", "AutoSkillQueue",
    "AutoCooldownReport", "AutoUltimateTracker", "AutoManaCheck", "AutoTechSpend",
    "AutoUnlockCheap", "AutoSaveTech", "AutoPrestigeCheck", "AutoPassiveToggle",
    "AutoBuffRefresh", "AutoArmorRepair", "AutoChestHunt", "AutoOrbCollect",
    "AutoNearbyPickup", "AutoPathToTarget", "AutoStuckDetect", "AutoFollowAlly",
    "AutoStayInZone", "AutoHeightControl", "AutoMoneyPickup", "AutoCrateOpen",
}

local ALWAYS_QUEUE = {
    "AutoServerHop", "AutoRejoinGuard", "AutoKickGuard", "AutoResultContinuePlus",
    "AutoWaveSkipEnhanced", "AutoWaveReward", "AutoStats", "AutoSessionReport",
    "AutoConfigBackup", "AutoLagWatch", "AutoMemoryClean", "AutoLogRotate",
    "AutoProfile", "AutoNotifyDigest", "AutoCrashGuard",
}

function xRunQueue(queue, phase)
    for _, key in ipairs(queue) do
        if AUTO[key] then
            local fn = MODULE_RUNNERS[key]
            if fn then
                local t0 = os.clock()
                local ok, err = pcall(fn)
                local dt = os.clock() - t0
                if AUTO.AutoProfile then
                    local p = xSt("profile")
                    local rec = p[key]
                    if not rec then
                        rec = { calls = 0, time = 0 }
                        p[key] = rec
                    end
                    rec.calls = rec.calls + 1
                    rec.time = rec.time + dt
                end
                if not ok then
                    AUTO.LoopErrors = (tonumber(AUTO.LoopErrors) or 0) + 1
                    if every("x_moderr_" .. key, 30) then
                        log("模块异常[" .. key .. "]：" .. tostring(err))
                    end
                end
            end
        end
    end
end

function xRunLobbyModules()
    xRunQueue(LOBBY_QUEUE, "lobby")
end

function xRunCombatModules()
    xRunQueue(COMBAT_QUEUE, "combat")
end

function xRunAlwaysModules()
    xRunQueue(ALWAYS_QUEUE, "always")
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 VII：高级战斗 / 预判 / 区域规避 / 巡逻
-- ============================================================
----------------------------------------------------------------
local X6_DEFAULTS = {
    AutoAimLead = false, AimLeadFactor = 0.18, AimLeadMax = 40,
    AutoDodgeZone = false, ZoneCheckGap = 0.4, ZoneDodgeDistance = 12,
    AutoInterrupt = false, InterruptGap = 0.8, InterruptSkills = {},
    AutoTauntBoss = false, TauntRange = 120, TauntGap = 5,
    AutoTeamBuff = false, TeamBuffRange = 80, TeamBuffGap = 20, TeamBuffNames = {},
    AutoShieldAlly = false, ShieldAllyHp = 35, ShieldAllyGap = 12,
    AutoLastStand = false, LastStandHp = 12, LastStandGap = 4,
    AutoThreatTable = false, ThreatGap = 1,
    AutoTerrainAdapt = false, TerrainCheckGap = 1.5, BadMaterials = { "Water", "Lava", "Acid" },
    AutoAntiFling = false, FlingSpeed = 350, FlingGap = 0.5,
    AutoPatrol = false, PatrolRadius = 60, PatrolPoints = 4, PatrolGap = 3,
    AutoReturnHome = false, HomeIdleTime = 25, HomeGap = 2,
    AutoGroupUp = false, GroupGap = 4, GroupDistance = 10,
    AutoKillConfirm = false, KillConfirmGap = 0.6,
    AutoCombatLog = false, CombatLogGap = 10,
    AutoRespawnWait = false, RespawnWaitGap = 1.5,
    AutoSelfRevive = false, SelfReviveGap = 1,
}

for k, v in pairs(X6_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

----------------------------------------------------------------
-- 93. 预判瞄准（按目标速度提前量）
----------------------------------------------------------------
function autoAimLead()
    if not AUTO.AutoAimLead then return false end
    if AUTO.Paused then return false end
    if not every("x_aimlead", 0.05) then return false end
    local pick = xPickTarget(tonumber(AUTO.Range) or 300, AUTO.TargetPriority)
    if not pick then return false end
    local part = pick.model:FindFirstChild("HumanoidRootPart") or pick.model.PrimaryPart
    if not part then return false end
    local vel = part.AssemblyLinearVelocity
    local factor = tonumber(AUTO.AimLeadFactor) or 0.18
    local maxLead = tonumber(AUTO.AimLeadMax) or 40
    local lead = vel * factor
    if lead.Magnitude > maxLead then
        lead = lead.Unit * maxLead
    end
    local aimPos = part.Position + lead + Vector3.new(0, 1.2, 0)
    aimAt(aimPos)
    AUTO.LastReason = string.format("预判瞄准：%s（提前 %.1f 格）", pick.model.Name, lead.Magnitude)
    return true
end

----------------------------------------------------------------
-- 94. 躲区域伤害（红圈 / 毒圈 / 轰炸区）
----------------------------------------------------------------
function autoDodgeZone()
    if not AUTO.AutoDodgeZone then return false end
    if AUTO.Paused then return false end
    if not every("x_zone_dodge", tonumber(AUTO.ZoneCheckGap) or 0.4) then return false end
    local base = xRoot2()
    if not base then return false end
    local keywords = { "zone", "aoe", "circle", "bomb", "beam", "danger", "hazard", "poison" }
    local danger = nil
    local dangerDist = math.huge
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 1 then
                local low = string.lower(d.Name)
                local hit = false
                for _, k in ipairs(keywords) do
                    if string.find(low, k, 1, true) then hit = true break end
                end
                if hit then
                    local dist = (d.Position - base.Position).Magnitude
                    local size = math.max(d.Size.X, d.Size.Z)
                    if dist < size + 6 and dist < dangerDist then
                        danger, dangerDist = d, dist
                    end
                end
            end
        end
    end)
    if not danger then
        xSt("zonedodge").active = false
        return false
    end
    local away = base.Position - danger.Position
    if away.Magnitude <= 0.01 then away = Vector3.new(0, 0, 1) end
    local dist = tonumber(AUTO.ZoneDodgeDistance) or 12
    local dest = base.Position + away.Unit * (dist + 6) + Vector3.new(0, 5, 0)
    xTp(dest)
    xSt("zonedodge").active = true
    AUTO.LastReason = "躲区域：" .. danger.Name
    if xToast("zonedodge", "区域规避", "检测到 " .. danger.Name .. "，已离开", 4) then
        log("躲区域：检测到 " .. danger.Name .. "，已离开")
    end
    xStatAdd("躲区域", 1)
    return true
end

----------------------------------------------------------------
-- 95. 打断施法
----------------------------------------------------------------
function autoInterrupt()
    if not AUTO.AutoInterrupt then return false end
    if AUTO.Paused then return false end
    if not every("x_interrupt", tonumber(AUTO.InterruptGap) or 0.8) then return false end
    local target = nil
    for _, e in ipairs(xEnemyList(tonumber(AUTO.Range) or 300)) do
        local h = e.model:FindFirstChildOfClass("Humanoid")
        if h then
            local casting = false
            for _, attr in ipairs({ "Casting", "IsCasting", "Channeling", "Stunned" }) do
                local ok, v = pcall(function() return h:GetAttribute(attr) or e.model:GetAttribute(attr) end)
                if ok and v == true then casting = true break end
            end
            if casting then
                target = e
                break
            end
        end
    end
    if not target then return false end
    local names = AUTO.InterruptSkills or {}
    local fired = false
    if #names > 0 then
        for id, info in pairs(skillInfo) do
            if info and info.name and os.clock() >= (skillNext[id] or 0) then
                for _, n in ipairs(names) do
                    if string.lower(tostring(info.name)) == string.lower(tostring(n)) then
                        skillNext[id] = os.clock() + (info.cd or 2.5)
                        fired = xCastSkillById(id, target.pos, info.name) or fired
                    end
                end
            end
        end
    end
    if not fired then
        fired = xFire("Interrupt", target.model.Name) or xFire("Stun", target.model.Name)
    end
    if fired then
        AUTO.LastReason = "打断：" .. target.model.Name
        log("打断施法：" .. target.model.Name)
        xStatAdd("打断", 1)
    end
    return fired
end

----------------------------------------------------------------
-- 96. 拉 Boss 仇恨
----------------------------------------------------------------
function autoTauntBoss()
    if not AUTO.AutoTauntBoss then return false end
    if AUTO.Paused then return false end
    if not every("x_taunt", tonumber(AUTO.TauntGap) or 5) then return false end
    local range = tonumber(AUTO.TauntRange) or 120
    local boss = nil
    for _, e in ipairs(xEnemyList(range)) do
        if xIsBoss(e.model) then
            boss = e
            break
        end
    end
    if not boss then return false end
    local base = xRoot2()
    if not base then return false end
    local dir = (boss.pos - base.Position)
    if dir.Magnitude > 0.01 and boss.dist > 12 then
        xTp(boss.pos - dir.Unit * 8 + Vector3.new(0, 4, 0), boss.pos)
    end
    if AUTO.AutoFight then ensureFire() end
    local ok = xFire("Taunt", boss.model.Name) or xFire("Provoke", boss.model.Name)
    AUTO.LastReason = "拉仇恨：" .. boss.model.Name
    AUTO.TauntTarget = boss.model.Name
    log("拉 Boss 仇恨：" .. boss.model.Name .. (ok and "（已发送嘲讽）" or ""))
    xStatAdd("拉仇恨", 1)
    return true
end

----------------------------------------------------------------
-- 97. 团队增益
----------------------------------------------------------------
function autoTeamBuff()
    if not AUTO.AutoTeamBuff then return false end
    if AUTO.Paused then return false end
    if not every("x_teambuff", tonumber(AUTO.TeamBuffGap) or 20) then return false end
    local range = tonumber(AUTO.TeamBuffRange) or 80
    local allies = xAllyList(range)
    if #allies == 0 then return false end
    local names = AUTO.TeamBuffNames or {}
    if #names == 0 then
        names = AUTO.BuffNames or {}
    end
    if #names == 0 then return false end
    local r = xFindRemote("Boosts")
    if not r then return false end
    local n = 0
    for _, name in ipairs(names) do
        local ok = pcall(function() r:FireServer(name) end)
        if ok then n = n + 1 end
    end
    if n > 0 then
        AUTO.LastReason = "团队增益：" .. n .. " 个"
        log(string.format("团队增益：为 %d 名队友续 %d 个增益", #allies, n))
        xStatAdd("团队增益", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 98. 给队友套盾
----------------------------------------------------------------
function autoShieldAlly()
    if not AUTO.AutoShieldAlly then return false end
    if AUTO.Paused then return false end
    if not every("x_shieldally", tonumber(AUTO.ShieldAllyGap) or 12) then return false end
    local need = tonumber(AUTO.ShieldAllyHp) or 35
    local target = nil
    for _, a in ipairs(xAllyList(tonumber(AUTO.TeamBuffRange) or 80)) do
        if a.hp > 0 and a.hp < a.maxhp * (need / 100) then
            target = a
            break
        end
    end
    if not target then return false end
    local ok = false
    local r = xFindRemote("ShieldAlly") or xFindRemote("GiveShield")
    if r then
        pcall(function()
            if r:IsA("RemoteEvent") then r:FireServer(target.player)
            else r:InvokeServer(target.player) end
        end)
        ok = true
    end
    if not ok then
        ok = xFire("Boosts", "Shield", target.player.Name)
    end
    if ok then
        AUTO.LastReason = "套盾：" .. target.player.Name
        log("给队友套盾：" .. target.player.Name)
        xStatAdd("队友套盾", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 99. 背水一战（极低血全保命）
----------------------------------------------------------------
function autoLastStand()
    if not AUTO.AutoLastStand then return false end
    if AUTO.Paused then return false end
    if not every("x_laststand", tonumber(AUTO.LastStandGap) or 4) then return false end
    local hp = xHpPct()
    local trigger = tonumber(AUTO.LastStandHp) or 12
    if hp <= 0 or hp > trigger then
        xSt("laststand").active = false
        return false
    end
    local state = xSt("laststand")
    state.active = true
    local pos = xSafePoint(nil, tonumber(AUTO.EmergencyDistance) or 80)
    if pos then xTp(pos) end
    local names = {}
    for _, list in ipairs({ AUTO.BandageNames, AUTO.ShieldNames, AUTO.CleanseNames, AUTO.FoodNames }) do
        for _, n in ipairs(list or {}) do names[#names + 1] = n end
    end
    local n = xUseNamedRemote("Potions", names)
    if AUTO.AutoBuyHP then buyHP() end
    if AUTO.AutoPotion then usePotion() end
    if AUTO.AutoBoost then
        pcall(function() fireRemote("Boosts", "Speed") end)
    end
    AUTO.LastReason = string.format("背水一战：血量 %.0f%%，全部保命手段", hp)
    notify("背水一战", string.format("血量 %.0f%%，已使用全部保命手段", hp))
    log(string.format("背水一战：血量 %.0f%%，已撤退并治疗", hp))
    xStatAdd("背水一战", 1)
    return true
end

----------------------------------------------------------------
-- 100. 威胁表（记录最近敌人的威胁值）
----------------------------------------------------------------
function autoThreatTable()
    if not AUTO.AutoThreatTable then return false end
    if not every("x_threat", tonumber(AUTO.ThreatGap) or 1) then return false end
    local list = xEnemyList(tonumber(AUTO.Range) or 400)
    local rows = {}
    for _, e in ipairs(list) do
        local h = e.model:FindFirstChildOfClass("Humanoid")
        local hp = h and h.Health or 0
        local maxhp = h and h.MaxHealth or 1
        local threat = (maxhp * 0.5) + (100 - math.min(100, e.dist)) * 10 + (hp / math.max(1, maxhp)) * 200
        if xIsBoss(e.model) then threat = threat + 5000 end
        rows[#rows + 1] = { name = e.model.Name, threat = threat, dist = e.dist, hp = hp }
    end
    table.sort(rows, function(a, b) return a.threat > b.threat end)
    AUTO.ThreatTop = rows[1] and rows[1].name or nil
    if #rows > 0 and every("x_threat_log", 20) then
        local parts = {}
        for i = 1, math.min(3, #rows) do
            parts[#parts + 1] = string.format("%s(%d)", rows[i].name, xRound(rows[i].threat))
        end
        log("威胁表：" .. table.concat(parts, " > "))
        xStatAdd("威胁分析", 1)
    end
    return #rows > 0
end

----------------------------------------------------------------
-- 101. 地形适应（水 / 岩浆 / 酸液）
----------------------------------------------------------------
function autoTerrainAdapt()
    if not AUTO.AutoTerrainAdapt then return false end
    if AUTO.Paused then return false end
    if not every("x_terrain", tonumber(AUTO.TerrainCheckGap) or 1.5) then return false end
    local h = xHum2()
    if not h then return false end
    local mat = tostring(h.FloorMaterial)
    local bad = AUTO.BadMaterials or {}
    local hit = false
    for _, m in ipairs(bad) do
        if string.lower(mat) == string.lower(tostring(m)) then hit = true break end
    end
    if not hit and string.find(string.lower(mat), "water", 1, true) then hit = true end
    if not hit then return false end
    local pos = xSafePoint(nil, tonumber(AUTO.RetreatDistance) or 50)
    if pos then xTp(pos) end
    AUTO.LastReason = "地形适应：离开 " .. mat
    log("地形适应：检测到 " .. mat .. "，已离开")
    xStatAdd("地形适应", 1)
    return true
end

----------------------------------------------------------------
-- 102. 防被甩飞
----------------------------------------------------------------
function autoAntiFling()
    if not AUTO.AutoAntiFling then return false end
    if AUTO.Paused then return false end
    if not every("x_fling", tonumber(AUTO.FlingGap) or 0.5) then return false end
    local base = xRoot2()
    if not base then return false end
    local v = base.AssemblyLinearVelocity
    local limit = tonumber(AUTO.FlingSpeed) or 350
    if v.Magnitude < limit then return false end
    pcall(function()
        base.AssemblyLinearVelocity = Vector3.zero
        base.AssemblyAngularVelocity = Vector3.zero
    end)
    local spawn = xSpawnPos()
    xTp(spawn + Vector3.new(0, 6, 0))
    AUTO.LastReason = string.format("防甩飞：速度 %.0f", v.Magnitude)
    if xToast("fling", "防甩飞", "检测到异常速度，已复位角色", 8) then
        log(string.format("防甩飞：速度 %.0f，已复位", v.Magnitude))
    end
    xStatAdd("防甩飞", 1)
    return true
end

----------------------------------------------------------------
-- 103. 巡逻（自动生成路径点）
----------------------------------------------------------------
function autoPatrol()
    if not AUTO.AutoPatrol then return false end
    if AUTO.Paused then return false end
    if #xEnemyList(tonumber(AUTO.Range) or 300) > 0 then return false end
    if not every("x_patrol", tonumber(AUTO.PatrolGap) or 3) then return false end
    local state = xSt("patrol")
    if not state.center then
        state.center = xSpawnPos()
        state.index = 0
        state.points = {}
        local n = math.max(2, tonumber(AUTO.PatrolPoints) or 4)
        local radius = tonumber(AUTO.PatrolRadius) or 60
        for i = 1, n do
            local ang = (i - 1) / n * math.pi * 2
            state.points[i] = state.center + Vector3.new(math.cos(ang) * radius, 6, math.sin(ang) * radius)
        end
    end
    state.index = (state.index or 0) + 1
    if state.index > #state.points then state.index = 1 end
    local dest = state.points[state.index]
    xTp(dest)
    AUTO.LastReason = string.format("巡逻：前往第 %d 个路径点", state.index)
    xStatAdd("巡逻", 1)
    return true
end

----------------------------------------------------------------
-- 104. 返回出生点
----------------------------------------------------------------
function autoReturnHome()
    if not AUTO.AutoReturnHome then return false end
    if AUTO.Paused then return false end
    if not every("x_home", tonumber(AUTO.HomeGap) or 2) then return false end
    local base = xRoot2()
    if not base then return false end
    local spawn = xSpawnPos()
    local d = (base.Position - spawn).Magnitude
    if d <= 12 then
        xSt("home").idle = nil
        return false
    end
    local enemies = #xEnemyList(tonumber(AUTO.Range) or 200)
    local idleLimit = tonumber(AUTO.HomeIdleTime) or 25
    local state = xSt("home")
    if enemies > 0 then
        state.idle = nil
        return false
    end
    state.idle = state.idle or os.clock()
    if os.clock() - state.idle < idleLimit then return false end
    xTp(spawn + Vector3.new(0, 6, 0))
    state.idle = nil
    AUTO.LastReason = "返回出生点：附近无敌人"
    log("返回出生点：附近长时间无敌人，已回去")
    xStatAdd("返回出生点", 1)
    return true
end

----------------------------------------------------------------
-- 105. 集合队伍
----------------------------------------------------------------
function autoGroupUp()
    if not AUTO.AutoGroupUp then return false end
    if AUTO.Paused then return false end
    if not every("x_group", tonumber(AUTO.GroupGap) or 4) then return false end
    local allies = xAllyList(tonumber(AUTO.FollowAllyRange) or 200)
    if #allies < 1 then return false end
    local sum = Vector3.new(0, 0, 0)
    local n = 0
    for _, a in ipairs(allies) do
        sum = sum + a.pos
        n = n + 1
    end
    if n == 0 then return false end
    local center = sum / n
    local base = xRoot2()
    if not base then return false end
    local keep = tonumber(AUTO.GroupDistance) or 10
    if (base.Position - center).Magnitude <= keep then return false end
    xTp(center + Vector3.new(0, 5, 0))
    AUTO.LastReason = string.format("集合队伍：%d 人中心", n)
    xStatAdd("集合队伍", 1)
    return true
end

----------------------------------------------------------------
-- 106. 击杀确认（清理目标并结算）
----------------------------------------------------------------
function autoKillConfirm()
    if not AUTO.AutoKillConfirm then return false end
    if not every("x_killconfirm", tonumber(AUTO.KillConfirmGap) or 0.6) then return false end
    local state = xSt("killconfirm")
    local targetName = AUTO.Target
    if not targetName then return false end
    local folder = living()
    local exists = false
    if folder then
        local m = folder:FindFirstChild(targetName)
        if m then
            local h = m:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then exists = true end
        end
    end
    if exists then
        state.lastGone = nil
        return false
    end
    state.lastGone = state.lastGone or os.clock()
    if os.clock() - state.lastGone < 0.5 then return false end
    AUTO.Target = nil
    AUTO.PriorityTarget = nil
    AUTO.LastReason = "击杀确认：" .. tostring(targetName)
    log("击杀确认：" .. tostring(targetName) .. " 已清除")
    xStatAdd("击杀确认", 1)
    state.lastGone = nil
    return true
end

----------------------------------------------------------------
-- 107. 战斗日志（受伤 / 敌人数量 / 距离）
----------------------------------------------------------------
function autoCombatLog()
    if not AUTO.AutoCombatLog then return false end
    if not every("x_combatlog", tonumber(AUTO.CombatLogGap) or 10) then return false end
    local h = xHum2()
    local hp = h and h.Health or 0
    local maxhp = h and h.MaxHealth or 1
    local state = xSt("combatlog")
    local now = os.clock()
    local dt = math.max(1, now - (state.lastAt or now))
    local dps = ((state.lastHp or hp) - hp) / dt
    state.lastHp = hp
    state.lastAt = now
    local enemies = #xEnemyList(tonumber(AUTO.Range) or 400)
    local line = string.format("血量 %.0f/%.0f（%.0f%%） 受伤 %.1f/s 敌人 %d 波次 %s",
        hp, maxhp, hp / math.max(1, maxhp) * 100, math.max(0, dps), enemies, tostring(AUTO.WaveNow or "-"))
    log("战斗日志：" .. line)
    AUTO.CombatLine = line
    xStatAdd("战斗日志", 1)
    return true
end

----------------------------------------------------------------
-- 108. 复活等待（处理死亡界面）
----------------------------------------------------------------
function autoRespawnWait()
    if not AUTO.AutoRespawnWait then return false end
    if not every("x_respawnwait", tonumber(AUTO.RespawnWaitGap) or 1.5) then return false end
    local h = xHum2()
    if h and h.Health > 0 then
        xSt("respawnwait").deadAt = nil
        return false
    end
    local state = xSt("respawnwait")
    state.deadAt = state.deadAt or os.clock()
    local waited = os.clock() - state.deadAt
    local clicked = false
    for _, root in ipairs({ pg, workspace }) do
        if xClickButtonByName(root, { "Respawn", "Revive", "Continue", "重生", "复活" }, "x_respawnbtn", 1.5) then
            clicked = true
            break
        end
    end
    if not clicked then
        local prompt = xFindPromptByKeyword and xFindPromptByKeyword("revive")
        if prompt then
            xUsePrompt(prompt)
            clicked = true
        end
    end
    if not clicked and waited > 5 then
        if AUTO.AutoRespawn then
            pcall(function() forceRespawn() end)
            clicked = true
        end
    end
    if clicked then
        AUTO.LastReason = "复活等待：已请求复活"
        log("复活等待：已请求复活（等待 " .. xRound(waited) .. " 秒）")
        xStatAdd("复活等待", 1)
    end
    return clicked
end

----------------------------------------------------------------
-- 109. 倒地自救
----------------------------------------------------------------
function autoSelfRevive()
    if not AUTO.AutoSelfRevive then return false end
    if not every("x_selfrevive", tonumber(AUTO.SelfReviveGap) or 1) then return false end
    local h = xHum2()
    if h and h.Health > 0 then return false end
    local ok = xFire("SelfRevive") or xFire("Revive", player.Name)
    if not ok then
        local r = xFindRemote("ReviveRemote")
        if r then
            pcall(function() r:FireServer(player) end)
            ok = true
        end
    end
    if not ok then
        local prompt = xFindPromptByKeyword and xFindPromptByKeyword("revive")
        if prompt then
            xUsePrompt(prompt)
            ok = true
        end
    end
    if ok then
        AUTO.LastReason = "倒地自救：已请求"
        log("倒地自救：已发送复活请求")
        xStatAdd("倒地自救", 1)
    end
    return ok
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 VIII：装备 / 养成 / 活动 / 社交 / 辅助
-- ============================================================
----------------------------------------------------------------
local X7_DEFAULTS = {
    AutoAmmoBuy = false, AmmoBuyGap = 20, AmmoReserve = 30, AmmoItemName = "Ammo",
    AutoWeaponDurability = false, DurabilityMin = 20, DurabilitySwaps = 2,
    AutoPetSummon = false, PetGap = 60, PetName = "",
    AutoVehicleUse = false, VehicleGap = 15,
    AutoStatAllocation = false, StatGap = 3, StatPriority = {}, StatPointsMin = 1,
    AutoLevelSpend = false, LevelSpendGap = 5,
    AutoBossPhase = false, BossPhaseList = { 75, 50, 25 },
    AutoEnemyAlert = false, EnemyAlertCount = 8, EnemyAlertGap = 10,
    AutoQuestAutoEquip = false, QuestEquipGap = 6,
    AutoSkillPointScan = false, SkillScanGap = 60,
    AutoTitleAutoEquip = false, TitleEquipGap = 30, TitleNames = {},
    AutoCharacterRotate = false, CharacterRotateMatches = 5, CharacterRotateGap = 10,
    AutoSkinEquip = false, SkinNames = {}, SkinGap = 30,
    AutoAccessoryEquip = false, AccessoryNames = {}, AccessoryGap = 30,
    AutoEmoteUse = false, EmoteNames = {}, EmoteGap = 45,
    AutoSprint = false, SprintSpeed = 32, SprintGap = 2,
    AutoCrouchDodge = false, CrouchGap = 3,
    AutoSwimGuard = false, SwimCheckGap = 1.2,
    AutoSpeedSync = false, SpeedSyncGap = 1.5,
    AutoJumpBoost = false, JumpPowerSync = 60, JumpBoostGap = 2,
    AutoToolRepair = false, ToolRepairGap = 30,
    AutoInventoryWeight = false, WeightNames = { "Weight", "Load", "Capacity" }, WeightMaxPct = 85,
    AutoCraftItem = false, CraftGap = 15, CraftItems = {},
    AutoUpgradeItem = false, UpgradeGap = 15, UpgradeItems = {},
    AutoTradeRequest = false, TradeGap = 45, TradeNames = {},
    AutoMailClaim = false, MailGap = 60,
    AutoAchievementClaim = false, AchievementGap = 60,
    AutoSeasonPassClaim = false, SeasonPassGap = 60,
    AutoCodeRedeemLoop = false, CodeRedeemGap = 300,
    AutoDailyShopRefresh = false, ShopRefreshGap = 3600,
}

for k, v in pairs(X7_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

function xEquipFromFolder(folderName, names, gapKey, gap)
    local folder = player:FindFirstChild(folderName)
    if not folder then return false end
    if gapKey and not every(gapKey, gap or 5) then return false end
    local wanted = nil
    if names and #names > 0 then
        for _, n in ipairs(names) do
            for _, item in ipairs(folder:GetChildren()) do
                if string.lower(item.Name) == string.lower(tostring(n)) then
                    wanted = item
                    break
                end
            end
            if wanted then break end
        end
    end
    if not wanted then
        for _, item in ipairs(folder:GetChildren()) do
            wanted = item
            break
        end
    end
    if not wanted then return false end
    local ok = pcall(function()
        if wanted:IsA("GuiButton") then
            clickGui(wanted)
        else
            local r = xFindRemote("ForChangeCharacter")
            if r and folderName == "CharactersFolder" then
                r:FireServer(wanted.Name)
            else
                local equip = xFindRemote("Equip") or xFindRemote("EquipItem")
                if equip then
                    equip:FireServer(wanted.Name)
                else
                    wanted:SetAttribute("Equipped", true)
                end
            end
        end
    end)
    if ok then
        log(string.format("装备：%s / %s", folderName, wanted.Name))
        xStatAdd("装备", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 110. 自动购买弹药
----------------------------------------------------------------
function autoAmmoBuy()
    if not AUTO.AutoAmmoBuy then return false end
    if AUTO.Paused then return false end
    if not every("x_ammobuy", tonumber(AUTO.AmmoBuyGap) or 20) then return false end
    local h = xHum2()
    local c = player.Character
    if not h or not c then return false end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local ammo = nil
    for _, key in ipairs({ "Ammo", "AmmoCount", "AmmoValue", "Bullets", "Magazine" }) do
        local ok, v = pcall(function() return tool:GetAttribute(key) end)
        if ok and tonumber(v) then ammo = tonumber(v) break end
    end
    if ammo == nil then return false end
    local reserve = tonumber(AUTO.AmmoReserve) or 30
    if ammo > reserve then return false end
    local money = xFindPlayerAttrNumber(AUTO.CurrencyNames or { "Money", "Cash", "Coins", "Gold" })
    if money ~= nil and money < (tonumber(AUTO.BudgetReserve) or 1000) then return false end
    local item = AUTO.AmmoItemName or "Ammo"
    local ok = fireRemote("ShopSystem", "Buy", item) or xFire("BuyAmmo", item)
    if ok then
        AUTO.LastReason = "补充弹药：" .. tostring(item)
        log("自动购买弹药：当前 " .. ammo .. "，已请求购买 " .. tostring(item))
        xStatAdd("购买弹药", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 111. 武器耐久 / 切换
----------------------------------------------------------------
function autoWeaponDurability()
    if not AUTO.AutoWeaponDurability then return false end
    if AUTO.Paused then return false end
    if not every("x_durability", 3) then return false end
    local c = player.Character
    if not c then return false end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local cur = nil
    for _, key in ipairs({ "Durability", "DurabilityValue", "Dura", "Condition" }) do
        local ok, v = pcall(function() return tool:GetAttribute(key) end)
        if ok and tonumber(v) then cur = tonumber(v) break end
    end
    if cur == nil then return false end
    local max = nil
    for _, key in ipairs({ "MaxDurability", "DurabilityMax", "MaxCondition" }) do
        local ok, v = pcall(function() return tool:GetAttribute(key) end)
        if ok and tonumber(v) then max = tonumber(v) break end
    end
    local pct = max and max > 0 and cur / max * 100 or cur
    local limit = tonumber(AUTO.DurabilityMin) or 20
    if pct > limit then return false end
    local bp = player:FindFirstChild("Backpack")
    local other = nil
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t ~= tool then other = t break end
        end
    end
    if other and xEquipTool(other) then
        AUTO.LastReason = string.format("武器耐久：%.0f%%，切换到 %s", pct, other.Name)
        log(string.format("武器耐久：%s 只剩 %.0f%%，已切换到 %s", tool.Name, pct, other.Name))
        xStatAdd("武器切换", 1)
        return true
    end
    if xFire("Repair", tool.Name) then
        AUTO.LastReason = "武器耐久：已请求修理 " .. tool.Name
        log("武器耐久：已请求修理 " .. tool.Name)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 112. 自动召唤宠物
----------------------------------------------------------------
function autoPetSummon()
    if not AUTO.AutoPetSummon then return false end
    if AUTO.Paused then return false end
    if not every("x_pet", tonumber(AUTO.PetGap) or 60) then return false end
    local name = AUTO.PetName
    local ok = false
    if name and name ~= "" then
        ok = xFire("SummonPet", name) or xFire("PetSummon", name)
    else
        ok = xFire("SummonPet") or xFire("PetSummon") or xFire("EquipPet")
    end
    if not ok then
        local clicked = xClickButtonByName(pg, { "SummonPet", "PetEquip", "EquipPet" }, "x_petbtn", 60)
        ok = clicked
    end
    if ok then
        AUTO.LastReason = "召唤宠物"
        log("召唤宠物：已请求" .. (name and (" " .. name) or ""))
        xStatAdd("召唤宠物", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 113. 自动使用载具
----------------------------------------------------------------
function autoVehicleUse()
    if not AUTO.AutoVehicleUse then return false end
    if AUTO.Paused then return false end
    if not every("x_vehicle", tonumber(AUTO.VehicleGap) or 15) then return false end
    for _, p in ipairs(xNearPrompts(tonumber(AUTO.InteractRange) or 25)) do
        local low = string.lower(tostring(p.name))
        if string.find(low, "vehicle", 1, true) or string.find(low, "car", 1, true)
            or string.find(low, "mount", 1, true) or string.find(low, "board", 1, true) then
            xUsePrompt(p.prompt)
            AUTO.LastReason = "载具：" .. p.name
            log("自动载具：已使用 " .. p.name)
            xStatAdd("使用载具", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 114. 自动分配属性点
----------------------------------------------------------------
function autoStatAllocation()
    if not AUTO.AutoStatAllocation then return false end
    if AUTO.Paused then return false end
    if not every("x_statalloc", tonumber(AUTO.StatGap) or 3) then return false end
    local points, key = xFindPlayerAttrNumber({ "StatPoints", "Points", "AttributePoints", "TalentPoints" })
    if points == nil or points < (tonumber(AUTO.StatPointsMin) or 1) then return false end
    local priority = AUTO.StatPriority or {}
    local candidates = { "Strength", "Agility", "Intelligence", "Vitality", "Defense", "Speed" }
    local order = {}
    for _, p in ipairs(priority) do order[#order + 1] = p end
    if #order == 0 then
        for _, c in ipairs(candidates) do order[#order + 1] = c end
    end
    local r = xFindRemote("Stats") or xFindRemote("AllocateStat") or xFindRemote("Attributes")
    if not r then r = xFindRemote("StatUpgrade") end
    if not r then return false end
    local n = 0
    for _, statName in ipairs(order) do
        if points <= 0 then break end
        local ok = pcall(function()
            if r:IsA("RemoteFunction") then r:InvokeServer(statName, 1)
            else r:FireServer(statName, 1) end
        end)
        if ok then
            n = n + 1
            points = points - 1
        end
    end
    if n > 0 then
        AUTO.LastReason = string.format("属性点：分配 %d 点（%s）", n, tostring(key))
        log(string.format("属性点：已分配 %d 点（剩余 %d）", n, points))
        xStatAdd("分配属性点", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 115. 自动升级 / 强化
----------------------------------------------------------------
function autoLevelSpend()
    if not AUTO.AutoLevelSpend then return false end
    if AUTO.Paused then return false end
    if not every("x_levelspend", tonumber(AUTO.LevelSpendGap) or 5) then return false end
    local ok = xFire("LevelUp") or xFire("UpgradeLevel") or xFire("Upgrade")
    if not ok then
        ok = xClickButtonByName(pg, { "LevelUp", "Upgrade", "升级" }, "x_levelbtn", 5)
    end
    if ok then
        AUTO.LastReason = "升级：已请求"
        log("自动升级：已请求升级")
        xStatAdd("升级", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 116. Boss 阶段监测
----------------------------------------------------------------
function autoBossPhase()
    if not AUTO.AutoBossPhase then return false end
    if not every("x_bossphase", 0.7) then return false end
    local boss = nil
    for _, e in ipairs(xEnemyList(tonumber(AUTO.BossRange) or 150)) do
        if xIsBoss(e.model) then
            boss = e
            break
        end
    end
    if not boss then
        xSt("bossphase").phase = nil
        return false
    end
    local h = boss.model:FindFirstChildOfClass("Humanoid")
    if not h or h.MaxHealth <= 0 then return false end
    local pct = h.Health / h.MaxHealth * 100
    local phase = nil
    for _, threshold in ipairs(AUTO.BossPhaseList or { 75, 50, 25 }) do
        if pct <= threshold then phase = threshold end
    end
    local state = xSt("bossphase")
    if phase and phase ~= state.phase then
        state.phase = phase
        notify("Boss 阶段", string.format("%s 血量 %.0f%%，进入 %d%% 阶段", boss.model.Name, pct, phase))
        log(string.format("Boss 阶段：%s 血量 %.0f%%，进入 %d%% 阶段", boss.model.Name, pct, phase))
        xStatAdd("Boss阶段", 1)
        if AUTO.AutoSkillBurst then
            xSt("burst").until_ = os.clock() + (tonumber(AUTO.BurstWindow) or 2.2)
        end
        return true
    end
    return false
end

----------------------------------------------------------------
-- 117. 敌人数量警报
----------------------------------------------------------------
function autoEnemyAlert()
    if not AUTO.AutoEnemyAlert then return false end
    if not every("x_enemyalert", tonumber(AUTO.EnemyAlertGap) or 10) then return false end
    local n = #xEnemyList(tonumber(AUTO.Range) or 400)
    local limit = tonumber(AUTO.EnemyAlertCount) or 8
    AUTO.EnemyCount = n
    if n >= limit then
        notify("敌人警报", string.format("附近敌人 %d 个，注意站位", n))
        log(string.format("敌人警报：附近 %d 个敌人", n))
        xStatAdd("敌人警报", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 118. 任务装备自动切换
----------------------------------------------------------------
function autoQuestAutoEquip()
    if not AUTO.AutoQuestAutoEquip then return false end
    if AUTO.Paused then return false end
    if not every("x_questequip", tonumber(AUTO.QuestEquipGap) or 6) then return false end
    local r = xQuestFolder()
    if not r then return false end
    local wanted = nil
    pcall(function()
        local missions = r:FindFirstChild("Missions") or r:FindFirstChild("QuestList")
        if missions then
            for _, m in ipairs(missions:GetChildren()) do
                local item = m:GetAttribute("Item") or m:GetAttribute("RequiredItem")
                if item and tostring(item) ~= "" then
                    wanted = tostring(item)
                    break
                end
            end
        end
    end)
    if not wanted then return false end
    local tool = xToolByName({ wanted })
    if tool and tool.Parent ~= player.Character then
        if xEquipTool(tool) then
            AUTO.LastReason = "任务装备：" .. wanted
            log("任务装备：已装备 " .. wanted)
            xStatAdd("任务装备", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 119. 技能点扫描（只读统计）
----------------------------------------------------------------
function autoSkillPointScan()
    if not AUTO.AutoSkillPointScan then return false end
    if not every("x_skillscan", tonumber(AUTO.SkillScanGap) or 60) then return false end
    local n = 0
    for _ in pairs(skillInfo) do n = n + 1 end
    local folder = player:FindFirstChild("SkillTreesFolder")
    local nodes = folder and #folder:GetChildren() or 0
    local points = xFindPlayerAttrNumber({ "TechPoints", "SkillPoints", "Technology" })
    log(string.format("技能扫描：技能 %d 个，节点 %d 个，科技点 %s",
        n, nodes, points ~= nil and tostring(points) or "未知"))
    AUTO.SkillScanLine = string.format("技能 %d / 节点 %d / 科技点 %s", n, nodes,
        points ~= nil and tostring(points) or "?")
    return true
end

----------------------------------------------------------------
-- 120. 自动称号（多称号轮换）
----------------------------------------------------------------
function autoTitleAutoEquip()
    if not AUTO.AutoTitleAutoEquip then return false end
    if AUTO.Paused then return false end
    if not every("x_titleequip", tonumber(AUTO.TitleEquipGap) or 30) then return false end
    local ok = xEquipFromFolder("TitlesFolder", AUTO.TitleNames, nil, 30)
    if not ok and AUTO.TitleName and AUTO.TitleName ~= "" then
        ok = xFire("Title", AUTO.TitleName)
    end
    if ok then
        AUTO.LastReason = "称号：已装备"
        xStatAdd("称号装备", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 121. 自动轮换角色
----------------------------------------------------------------
function autoCharacterRotate()
    if not AUTO.AutoCharacterRotate then return false end
    if AUTO.Paused then return false end
    if inMatch() then return false end
    if not every("x_charrotate", tonumber(AUTO.CharacterRotateGap) or 10) then return false end
    local state = xSt("charrotate")
    state.matches = (state.matches or 0) + 1
    if state.matches < (tonumber(AUTO.CharacterRotateMatches) or 5) then return false end
    state.matches = 0
    local folder = player:FindFirstChild("CharactersFolder")
    if not folder then return false end
    local list = folder:GetChildren()
    if #list == 0 then return false end
    state.index = ((state.index or 0) % #list) + 1
    local target = list[state.index]
    local r = xFindRemote("ForChangeCharacter")
    local ok = false
    if r then
        pcall(function() r:FireServer(target.Name) end)
        ok = true
    else
        ok = xEquipFromFolder("CharactersFolder", { target.Name }, nil, 10)
    end
    if ok then
        AUTO.LastReason = "轮换角色：" .. target.Name
        log("自动轮换角色：" .. target.Name)
        xStatAdd("轮换角色", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 122. 自动皮肤
----------------------------------------------------------------
function autoSkinEquip()
    if not AUTO.AutoSkinEquip then return false end
    if AUTO.Paused then return false end
    if not every("x_skinequip", tonumber(AUTO.SkinGap) or 30) then return false end
    local ok = xEquipFromFolder("SkinsFolder", AUTO.SkinNames, nil, 30)
    if ok then
        AUTO.LastReason = "皮肤：已装备"
        xStatAdd("皮肤装备", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 123. 自动饰品
----------------------------------------------------------------
function autoAccessoryEquip()
    if not AUTO.AutoAccessoryEquip then return false end
    if AUTO.Paused then return false end
    if not every("x_accequip", tonumber(AUTO.AccessoryGap) or 30) then return false end
    local ok = xEquipFromFolder("AccessoriesFolder", AUTO.AccessoryNames, nil, 30)
    if ok then
        AUTO.LastReason = "饰品：已装备"
        xStatAdd("饰品装备", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 124. 自动表情
----------------------------------------------------------------
function autoEmoteUse()
    if not AUTO.AutoEmoteUse then return false end
    if AUTO.Paused then return false end
    if not every("x_emote", tonumber(AUTO.EmoteGap) or 45) then return false end
    local names = AUTO.EmoteNames or {}
    if #names == 0 then return false end
    local name = names[math.random(1, #names)]
    local ok = xFire("Emote", name) or xFire("PlayEmote", name)
    if ok then
        AUTO.LastReason = "表情：" .. tostring(name)
        log("自动表情：已播放 " .. tostring(name))
        xStatAdd("表情", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 125. 自动疾跑
----------------------------------------------------------------
function autoSprint()
    if not AUTO.AutoSprint then return false end
    if AUTO.Paused then return false end
    if not every("x_sprint", tonumber(AUTO.SprintGap) or 2) then return false end
    local h = xHum2()
    if not h then return false end
    local speed = tonumber(AUTO.SprintSpeed) or 32
    local moving = false
    local base = xRoot2()
    if base then
        local v = base.AssemblyLinearVelocity
        moving = Vector3.new(v.X, 0, v.Z).Magnitude > 1
    end
    if moving and h.WalkSpeed < speed then
        h.WalkSpeed = speed
        AUTO.LastReason = "疾跑：速度 " .. xRound(speed)
        return true
    elseif not moving and h.WalkSpeed > speed then
        h.WalkSpeed = tonumber(AUTO.WalkSpeed) or 16
    end
    return false
end

----------------------------------------------------------------
-- 126. 蹲伏闪避
----------------------------------------------------------------
function autoCrouchDodge()
    if not AUTO.AutoCrouchDodge then return false end
    if AUTO.Paused then return false end
    if not every("x_crouch", tonumber(AUTO.CrouchGap) or 3) then return false end
    local h = xHum2()
    if not h then return false end
    local list = xEnemyList(tonumber(AUTO.Range) or 200)
    if #list == 0 then return false end
    pcall(function() h:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)
    task.delay(0.4, function()
        pcall(function()
            if h and h.Parent then h:ChangeState(Enum.HumanoidStateType.Running) end
        end)
    end)
    AUTO.LastReason = "蹲伏闪避：短暂降低受击"
    xStatAdd("蹲伏闪避", 1)
    return true
end

----------------------------------------------------------------
-- 127. 游泳保护
----------------------------------------------------------------
function autoSwimGuard()
    if not AUTO.AutoSwimGuard then return false end
    if AUTO.Paused then return false end
    if not every("x_swim", tonumber(AUTO.SwimCheckGap) or 1.2) then return false end
    local h = xHum2()
    local base = xRoot2()
    if not h or not base then return false end
    local mat = tostring(h.FloorMaterial)
    if not string.find(string.lower(mat), "water", 1, true) then return false end
    xTp(base.Position + Vector3.new(0, 14, 0))
    AUTO.LastReason = "游泳保护：已上浮"
    xStatAdd("游泳保护", 1)
    return true
end

----------------------------------------------------------------
-- 128. 移速同步（防止被服务器重置）
----------------------------------------------------------------
function autoSpeedSync()
    if not AUTO.AutoSpeedSync then return false end
    if AUTO.Paused then return false end
    if not every("x_speedsync", tonumber(AUTO.SpeedSyncGap) or 1.5) then return false end
    local h = xHum2()
    if not h then return false end
    if AUTO.LockMoveStats then
        local want = tonumber(AUTO.WalkSpeed) or 16
        if math.abs(h.WalkSpeed - want) > 0.5 then
            h.WalkSpeed = want
            AUTO.LastReason = "移速同步：" .. xRound(want)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 129. 跳跃力同步
----------------------------------------------------------------
function autoJumpBoost()
    if not AUTO.AutoJumpBoost then return false end
    if AUTO.Paused then return false end
    if not every("x_jumpsync", tonumber(AUTO.JumpBoostGap) or 2) then return false end
    local h = xHum2()
    if not h then return false end
    local want = tonumber(AUTO.JumpPowerSync) or 60
    if math.abs(h.JumpPower - want) > 0.5 then
        h.JumpPower = want
        AUTO.LastReason = "跳跃力同步：" .. xRound(want)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 130. 工具修理
----------------------------------------------------------------
function autoToolRepair()
    if not AUTO.AutoToolRepair then return false end
    if AUTO.Paused then return false end
    if not every("x_toolrepair", tonumber(AUTO.ToolRepairGap) or 30) then return false end
    local c = player.Character
    if not c then return false end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local ok = fireRemote("ShopSystem", "Repair", tool.Name) or xFire("Repair", tool.Name)
    if ok then
        AUTO.LastReason = "修理工具：" .. tool.Name
        log("工具修理：已请求修理 " .. tool.Name)
        xStatAdd("修理工具", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 131. 背包负重检查
----------------------------------------------------------------
function autoInventoryWeight()
    if not AUTO.AutoInventoryWeight then return false end
    if AUTO.Paused then return false end
    if not every("x_weight", 10) then return false end
    local cur, key = xNumAttr(player, AUTO.WeightNames or {})
    if cur == nil then cur, key = xFindPlayerAttrNumber(AUTO.WeightNames or {}) end
    if cur == nil then return false end
    local max = nil
    if key then
        max = xFindPlayerAttrNumber({ tostring(key) .. "Max", "Max" .. tostring(key), "MaxWeight" })
    end
    local pct = max and max > 0 and cur / max * 100 or cur
    AUTO.WeightPct = xRound(pct)
    local limit = tonumber(AUTO.WeightMaxPct) or 85
    if pct < limit then return false end
    if AUTO.AutoSellJunk then
        AUTO.SellGap = 1
        autoSellJunk()
    end
    AUTO.LastReason = string.format("负重：%.0f%%（%s）", pct, tostring(key))
    log(string.format("负重检查：%.0f%%，已触发清理", pct))
    xStatAdd("负重清理", 1)
    return true
end

----------------------------------------------------------------
-- 132. 自动合成
----------------------------------------------------------------
function autoCraftItem()
    if not AUTO.AutoCraftItem then return false end
    if AUTO.Paused then return false end
    if not every("x_craft", tonumber(AUTO.CraftGap) or 15) then return false end
    local list = AUTO.CraftItems or {}
    if #list == 0 then return false end
    local r = xFindRemote("Craft") or xFindRemote("Crafting") or xFindRemote("CraftItem")
    if not r then return false end
    local n = 0
    for _, item in ipairs(list) do
        local name = item
        local amount = 1
        if type(item) == "table" then
            name = item.name or item[1]
            amount = tonumber(item.amount or item[2]) or 1
        end
        local ok = pcall(function()
            if r:IsA("RemoteFunction") then r:InvokeServer(name, amount)
            else r:FireServer(name, amount) end
        end)
        if ok then n = n + 1 end
    end
    if n > 0 then
        AUTO.LastReason = "合成：" .. n .. " 项"
        log("自动合成：已请求 " .. n .. " 项")
        xStatAdd("合成", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 133. 自动强化装备
----------------------------------------------------------------
function autoUpgradeItem()
    if not AUTO.AutoUpgradeItem then return false end
    if AUTO.Paused then return false end
    if not every("x_itemupgrade", tonumber(AUTO.UpgradeGap) or 15) then return false end
    local list = AUTO.UpgradeItems or {}
    if #list == 0 then
        local c = player.Character
        local tool = c and c:FindFirstChildOfClass("Tool")
        if tool then list = { tool.Name } end
    end
    if #list == 0 then return false end
    local r = xFindRemote("UpgradeItem") or xFindRemote("Enhance") or xFindRemote("Upgrade")
    if not r then return false end
    local n = 0
    for _, name in ipairs(list) do
        local ok = pcall(function()
            if r:IsA("RemoteFunction") then r:InvokeServer(name)
            else r:FireServer(name) end
        end)
        if ok then n = n + 1 end
    end
    if n > 0 then
        AUTO.LastReason = "强化装备：" .. n .. " 件"
        log("自动强化：已请求 " .. n .. " 件")
        xStatAdd("强化装备", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 134. 自动发起交易
----------------------------------------------------------------
function autoTradeRequest()
    if not AUTO.AutoTradeRequest then return false end
    if AUTO.Paused then return false end
    if not every("x_trade", tonumber(AUTO.TradeGap) or 45) then return false end
    local names = AUTO.TradeNames or {}
    if #names == 0 then return false end
    local r = xFindRemote("Trade") or xFindRemote("TradeRequest")
    if not r then return false end
    local n = 0
    for _, name in ipairs(names) do
        local target = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and string.find(string.lower(plr.Name), string.lower(tostring(name)), 1, true) then
                target = plr
                break
            end
        end
        if target then
            pcall(function() r:FireServer(target) end)
            n = n + 1
        end
    end
    if n > 0 then
        AUTO.LastReason = "交易请求：" .. n .. " 人"
        log("自动交易：已向 " .. n .. " 人发送请求")
        xStatAdd("交易请求", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 135. 自动领取邮件
----------------------------------------------------------------
function autoMailClaim()
    if not AUTO.AutoMailClaim then return false end
    if AUTO.Paused then return false end
    if not every("x_mail", tonumber(AUTO.MailGap) or 60) then return false end
    local names = { "Mail", "MailRemote", "ClaimMail", "MailBox" }
    local n = 0
    for _, name in ipairs(names) do
        local r = xFindRemote(name)
        if r then
            local ok = pcall(function()
                if r:IsA("RemoteFunction") then r:InvokeServer("Claim")
                else r:FireServer("Claim") end
            end)
            if ok then n = n + 1 end
        end
    end
    if n == 0 then
        local clicked = xClickButtonByName(pg, { "ClaimAll", "MailClaim", "CollectAll" }, "x_mailbtn", 60)
        if clicked then n = 1 end
    end
    if n > 0 then
        AUTO.LastReason = "邮件：已领取"
        log("自动邮件：已请求领取 " .. n .. " 项")
        xStatAdd("领取邮件", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 136. 自动领取成就
----------------------------------------------------------------
function autoAchievementClaim()
    if not AUTO.AutoAchievementClaim then return false end
    if AUTO.Paused then return false end
    if not every("x_achievement", tonumber(AUTO.AchievementGap) or 60) then return false end
    local names = { "Achievement", "Achievements", "AchievementRemote", "ClaimAchievement" }
    local n = 0
    for _, name in ipairs(names) do
        local r = xFindRemote(name)
        if r then
            local ok = pcall(function()
                if r:IsA("RemoteFunction") then r:InvokeServer("Claim")
                else r:FireServer("Claim") end
            end)
            if ok then n = n + 1 end
        end
    end
    if n == 0 then
        if xClickButtonByName(pg, { "Achievement", "成就" }, "x_achbtn", 60) then n = 1 end
    end
    if n > 0 then
        AUTO.LastReason = "成就：已领取"
        log("自动成就：已请求领取 " .. n .. " 项")
        xStatAdd("领取成就", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 137. 自动领取通行证
----------------------------------------------------------------
function autoSeasonPassClaim()
    if not AUTO.AutoSeasonPassClaim then return false end
    if AUTO.Paused then return false end
    if not every("x_seasonpass", tonumber(AUTO.SeasonPassGap) or 60) then return false end
    if unlockPasses then
        local ok = pcall(unlockPasses)
        if ok then
            AUTO.LastReason = "通行证：已请求领取"
            log("自动通行证：已执行领取流程")
            xStatAdd("领取通行证", 1)
            return true
        end
    end
    local names = { "SeasonPass", "BattlePass", "PassReward" }
    for _, name in ipairs(names) do
        local r = xFindRemote(name)
        if r then
            local ok = pcall(function()
                if r:IsA("RemoteFunction") then r:InvokeServer("Claim")
                else r:FireServer("Claim") end
            end)
            if ok then
                AUTO.LastReason = "通行证：" .. name
                log("自动通行证：已请求领取（" .. name .. "）")
                xStatAdd("领取通行证", 1)
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------
-- 138. 兑换码循环
----------------------------------------------------------------
function autoCodeRedeemLoop()
    if not AUTO.AutoCodeRedeemLoop then return false end
    if not every("x_codes", tonumber(AUTO.CodeRedeemGap) or 300) then return false end
    if type(redeemCodes) ~= "function" then return false end
    local ok = pcall(redeemCodes, true)
    if ok then
        AUTO.LastReason = "兑换码：已执行轮换"
        log("兑换码循环：已提交当前选中的兑换码")
        xStatAdd("兑换码", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 139. 每日商店刷新
----------------------------------------------------------------
function autoDailyShopRefresh()
    if not AUTO.AutoDailyShopRefresh then return false end
    if not every("x_shoprefresh", tonumber(AUTO.ShopRefreshGap) or 3600) then return false end
    local ok = xFire("RefreshShop") or xFire("ShopRefresh") or fireRemote("ShopSystem", "Refresh")
    if not ok then
        ok = xClickButtonByName(pg, { "Refresh", "刷新" }, "x_refreshbtn", 3600)
    end
    if ok then
        AUTO.LastReason = "商店刷新：已请求"
        log("商店刷新：已请求刷新每日商店")
        xStatAdd("商店刷新", 1)
    end
    return ok
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 IX：续航 / 掉落 / 场景机关 / 活动补充
-- ============================================================
----------------------------------------------------------------
local X8_DEFAULTS = {
    AutoShieldRegenWait = false, ShieldRegenHp = 60, ShieldRegenWait = 6,
    AutoOutOfCombatRegen = false, OutOfCombatTime = 8,
    AutoLootPriority = false, LootPriorityNames = {}, LootRange = 80,
    AutoOpenAllPrompts = false, AllPromptRange = 18, AllPromptGap = 2.5,
    AutoDoorOpen = false, DoorRange = 20, DoorGap = 2,
    AutoGeneratorRepair = false, GeneratorRange = 25, GeneratorGap = 4,
    AutoRescueNearby = false, RescueRange = 40, RescueGap = 2,
    AutoUseBuffConsumable = false, BuffConsumableNames = { "Boost", "Potion", "Elixir" }, BuffConsumableGap = 45,
    AutoDropJunk = false, DropJunkGap = 20, DropJunkNames = {},
    AutoEquipBestArmor = false, ArmorEquipGap = 15,
    AutoSellDuplicates = false, SellDuplicateGap = 30,
    AutoBuyLimited = false, LimitedBuyGap = 30, LimitedItems = {},
    AutoSkinGachaPlan = false, SkinGachaGap = 20, SkinGachaReserve = 3000,
    AutoSpinWheel = false, SpinWheelGap = 60,
    AutoDailyMissionClaim = false, DailyMissionGap = 45,
    AutoRankedQueue = false, RankedGap = 8,
    AutoWishlistScan = false, WishlistGap = 90, WishlistNames = {},
    AutoAmmoPickup = false, AmmoPickupRange = 30, AmmoPickupGap = 3,
    AutoCraftQueue = false, CraftQueueGap = 10, CraftQueueItems = {},
    AutoPetFeed = false, PetFeedGap = 120,
}

for k, v in pairs(X8_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

----------------------------------------------------------------
-- 140. 等盾恢复
----------------------------------------------------------------
function autoShieldRegenWait()
    if not AUTO.AutoShieldRegenWait then return false end
    if AUTO.Paused then return false end
    if not every("x_shieldregen", 1) then return false end
    local hp = xHpPct()
    local threshold = tonumber(AUTO.ShieldRegenHp) or 60
    if hp <= 0 or hp > threshold then
        xSt("shieldregen").since = nil
        return false
    end
    if #xEnemyList(tonumber(AUTO.Range) or 200) > 0 then
        xSt("shieldregen").since = nil
        return false
    end
    local state = xSt("shieldregen")
    state.since = state.since or os.clock()
    local wait = tonumber(AUTO.ShieldRegenWait) or 6
    if os.clock() - state.since < wait then return false end
    state.since = nil
    local n = xUseNamedRemote("Potions", AUTO.ShieldNames or {})
    if n == 0 then
        n = xUseNamedRemote("Boosts", AUTO.ShieldNames or {})
    end
    AUTO.LastReason = "等盾：已补充护盾"
    log("等盾恢复：血量 " .. xRound(hp) .. "%，已补充护盾")
    xStatAdd("等盾恢复", 1)
    return n > 0
end

----------------------------------------------------------------
-- 141. 脱战回血
----------------------------------------------------------------
function autoOutOfCombatRegen()
    if not AUTO.AutoOutOfCombatRegen then return false end
    if AUTO.Paused then return false end
    if not every("x_ooc", 1) then return false end
    local state = xSt("ooc")
    local enemies = #xEnemyList(tonumber(AUTO.Range) or 300)
    if enemies > 0 then
        state.since = nil
        return false
    end
    state.since = state.since or os.clock()
    local wait = tonumber(AUTO.OutOfCombatTime) or 8
    if os.clock() - state.since < wait then return false end
    local hp = xHpPct()
    if hp <= 0 or hp >= 98 then return false end
    buyHP()
    usePotion()
    local n = xUseNamedRemote("Potions", AUTO.BandageNames or {})
    AUTO.LastReason = string.format("脱战回血：%.0f%%", hp)
    if every("x_ooc_log", 15) then
        log(string.format("脱战回血：血量 %.0f%%，已使用恢复手段", hp))
        xStatAdd("脱战回血", 1)
    end
    return n > 0 or true
end

----------------------------------------------------------------
-- 142. 掉落优先级（只捡指定物品）
----------------------------------------------------------------
function autoLootPriority()
    if not AUTO.AutoLootPriority then return false end
    if AUTO.Paused then return false end
    if not every("x_lootprio", tonumber(AUTO.PickupGap) or 2) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.LootRange) or 80
    local names = AUTO.LootPriorityNames or {}
    local best, bestDist = nil, range
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("Model") then
                local low = string.lower(d.Name)
                local hit = (#names == 0)
                if not hit then
                    for _, n in ipairs(names) do
                        if string.find(low, string.lower(tostring(n)), 1, true) then hit = true break end
                    end
                end
                if hit then
                    local p = xPosOf(d)
                    if p then
                        local dist = (p - base.Position).Magnitude
                        if dist < bestDist then
                            best, bestDist = { obj = d, pos = p }, dist
                        end
                    end
                end
            end
        end
    end)
    if not best then return false end
    xTp(best.pos + Vector3.new(0, 2, 0))
    AUTO.LastReason = string.format("优先拾取：%s（%d 格）", best.obj.Name, xRound(bestDist))
    xStatAdd("优先拾取", 1)
    return true
end

----------------------------------------------------------------
-- 143. 触发附近所有提示
----------------------------------------------------------------
function autoOpenAllPrompts()
    if not AUTO.AutoOpenAllPrompts then return false end
    if AUTO.Paused then return false end
    if not every("x_allprompt", tonumber(AUTO.AllPromptGap) or 2.5) then return false end
    local list = xNearPrompts(tonumber(AUTO.AllPromptRange) or 18)
    if #list == 0 then return false end
    local n = 0
    for _, p in ipairs(list) do
        if n >= 2 then break end
        xUsePrompt(p.prompt)
        n = n + 1
    end
    if n > 0 then
        AUTO.LastReason = "全提示：触发 " .. n .. " 个"
        log("全提示：已触发 " .. n .. " 个附近提示")
        xStatAdd("全提示", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 144. 自动开门
----------------------------------------------------------------
function autoDoorOpen()
    if not AUTO.AutoDoorOpen then return false end
    if AUTO.Paused then return false end
    if not every("x_door", tonumber(AUTO.DoorGap) or 2) then return false end
    for _, p in ipairs(xNearPrompts(tonumber(AUTO.DoorRange) or 20)) do
        local low = string.lower(tostring(p.name))
        if string.find(low, "door", 1, true) or string.find(low, "gate", 1, true)
            or string.find(low, "open", 1, true) then
            xUsePrompt(p.prompt)
            AUTO.LastReason = "开门：" .. p.name
            xStatAdd("开门", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 145. 自动修发电机 / 机关
----------------------------------------------------------------
function autoGeneratorRepair()
    if not AUTO.AutoGeneratorRepair then return false end
    if AUTO.Paused then return false end
    if not every("x_generator", tonumber(AUTO.GeneratorGap) or 4) then return false end
    for _, p in ipairs(xNearPrompts(tonumber(AUTO.GeneratorRange) or 25)) do
        local low = string.lower(tostring(p.name))
        if string.find(low, "generator", 1, true) or string.find(low, "repair", 1, true)
            or string.find(low, "fix", 1, true) or string.find(low, "machine", 1, true) then
            xUsePrompt(p.prompt, true)
            AUTO.LastReason = "机关：" .. p.name
            log("自动机关：已触发 " .. p.name)
            xStatAdd("机关操作", 1)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 146. 就近救援
----------------------------------------------------------------
function autoRescueNearby()
    if not AUTO.AutoRescueNearby then return false end
    if AUTO.Paused then return false end
    if not every("x_rescue", tonumber(AUTO.RescueGap) or 2) then return false end
    local range = tonumber(AUTO.RescueRange) or 40
    local target = nil
    for _, a in ipairs(xAllyList(range)) do
        if a.hp <= 0 then
            target = a
            break
        end
    end
    if not target then return false end
    local base = xRoot2()
    if base and target.dist > 6 then
        local dir = target.pos - base.Position
        if dir.Magnitude > 0.01 then
            xTp(target.pos - dir.Unit * 2 + Vector3.new(0, 3, 0), target.pos)
        end
    end
    local n = 0
    pcall(function() n = tryRevive() end)
    AUTO.LastReason = "就近救援：" .. target.player.Name
    if n and n > 0 then
        log("就近救援：正在救 " .. target.player.Name)
        xStatAdd("就近救援", n)
    end
    return true
end

----------------------------------------------------------------
-- 147. 自动使用增益消耗品
----------------------------------------------------------------
function autoUseBuffConsumable()
    if not AUTO.AutoUseBuffConsumable then return false end
    if AUTO.Paused then return false end
    if not every("x_buffconsume", tonumber(AUTO.BuffConsumableGap) or 45) then return false end
    local names = AUTO.BuffConsumableNames or {}
    local n = xUseNamedRemote("Potions", names)
    if n == 0 then n = xUseNamedRemote("UseItems", names) end
    if n == 0 then n = xUseNamedRemote("Boosts", names) end
    if n > 0 then
        AUTO.LastReason = "增益消耗品：已使用 " .. n .. " 个"
        log("增益消耗品：已使用 " .. n .. " 个")
        xStatAdd("增益消耗品", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 148. 丢弃杂物
----------------------------------------------------------------
function autoDropJunk()
    if not AUTO.AutoDropJunk then return false end
    if AUTO.Paused then return false end
    if not every("x_dropjunk", tonumber(AUTO.DropJunkGap) or 20) then return false end
    local names = AUTO.DropJunkNames or {}
    if #names == 0 then return false end
    local bp = player:FindFirstChild("Backpack")
    if not bp then return false end
    local n = 0
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            for _, name in ipairs(names) do
                if string.find(string.lower(t.Name), string.lower(tostring(name)), 1, true) then
                    local ok = pcall(function() t.Parent = workspace end)
                    if not ok then
                        ok = xFire("Drop", t.Name)
                    end
                    if ok then n = n + 1 end
                    break
                end
            end
        end
    end
    if n > 0 then
        AUTO.LastReason = "丢弃杂物：" .. n .. " 件"
        log("丢弃杂物：已丢弃 " .. n .. " 件")
        xStatAdd("丢弃杂物", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 149. 自动换最佳护甲
----------------------------------------------------------------
function autoEquipBestArmor()
    if not AUTO.AutoEquipBestArmor then return false end
    if AUTO.Paused then return false end
    if not every("x_armorequip", tonumber(AUTO.ArmorEquipGap) or 15) then return false end
    local bp = player:FindFirstChild("Backpack")
    if not bp then return false end
    local best, bestScore = nil, -math.huge
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            local low = string.lower(t.Name)
            if string.find(low, "armor", 1, true) or string.find(low, "vest", 1, true)
                or string.find(low, "helmet", 1, true) or string.find(low, "shield", 1, true) then
                local score = 0
                for _, key in ipairs({ "Armor", "Defense", "Protection", "ArmorValue" }) do
                    local ok, v = pcall(function() return t:GetAttribute(key) end)
                    if ok and tonumber(v) then score = score + tonumber(v) break end
                end
                if score > bestScore then best, bestScore = t, score end
            end
        end
    end
    if not best then return false end
    if xEquipTool(best) then
        AUTO.LastReason = "最佳护甲：" .. best.Name
        log(string.format("自动护甲：已装备 %s（评分 %d）", best.Name, xRound(bestScore)))
        xStatAdd("装备护甲", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 150. 出售重复物品
----------------------------------------------------------------
function autoSellDuplicates()
    if not AUTO.AutoSellDuplicates then return false end
    if AUTO.Paused then return false end
    if not every("x_dupes", tonumber(AUTO.SellDuplicateGap) or 30) then return false end
    local bp = player:FindFirstChild("Backpack")
    if not bp then return false end
    local count = {}
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") then
            count[t.Name] = (count[t.Name] or 0) + 1
        end
    end
    local sold = 0
    for name, n in pairs(count) do
        if n > 1 then
            local ok = fireRemote("ShopSystem", "Sell", name)
            if not ok then ok = xFire("Sell", name) end
            if ok then sold = sold + (n - 1) end
        end
    end
    if sold > 0 then
        AUTO.LastReason = "出售重复：" .. sold .. " 件"
        log("出售重复：已出售 " .. sold .. " 件重复物品")
        xStatAdd("出售重复", sold)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 151. 限时商品购买
----------------------------------------------------------------
function autoBuyLimited()
    if not AUTO.AutoBuyLimited then return false end
    if AUTO.Paused then return false end
    if not every("x_limited", tonumber(AUTO.LimitedBuyGap) or 30) then return false end
    local items = AUTO.LimitedItems or {}
    if #items == 0 then return false end
    local n = 0
    for _, item in ipairs(items) do
        local ok = fireRemote("ShopSystem", "Buy", item)
        if not ok then ok = xFire("BuyLimited", item) end
        if ok then n = n + 1 end
    end
    if n > 0 then
        AUTO.LastReason = "限时购买：" .. n .. " 件"
        log("限时购买：已购买 " .. n .. " 件限时商品")
        xStatAdd("限时购买", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 152. 皮肤扭蛋计划
----------------------------------------------------------------
function autoSkinGachaPlan()
    if not AUTO.AutoSkinGachaPlan then return false end
    if AUTO.Paused then return false end
    if not every("x_skingacha", tonumber(AUTO.SkinGachaGap) or 20) then return false end
    local money = xFindPlayerAttrNumber(AUTO.CurrencyNames or { "Money", "Cash", "Coins", "Gold" })
    local reserve = tonumber(AUTO.SkinGachaReserve) or 3000
    if money ~= nil and money <= reserve then return false end
    local ok = xFire("GachaSkins", 1) or xFire("GachaSkins", "spin")
    if ok then
        AUTO.LastReason = "皮肤扭蛋：已抽取"
        log("皮肤扭蛋：已抽一次")
        xStatAdd("皮肤扭蛋", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 153. 转盘
----------------------------------------------------------------
function autoSpinWheel()
    if not AUTO.AutoSpinWheel then return false end
    if AUTO.Paused then return false end
    if not every("x_wheel", tonumber(AUTO.SpinWheelGap) or 60) then return false end
    local names = { "SpinWheel", "Wheel", "LuckyWheel", "Spin" }
    for _, name in ipairs(names) do
        if xFire(name) then
            AUTO.LastReason = "转盘：" .. name
            log("自动转盘：已转动（" .. name .. "）")
            xStatAdd("转盘", 1)
            return true
        end
    end
    if xClickButtonByName(pg, { "Spin", "Wheel" }, "x_wheelbtn", 60) then
        AUTO.LastReason = "转盘：已点击"
        log("自动转盘：已点击转盘按钮")
        xStatAdd("转盘", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 154. 每日任务领取
----------------------------------------------------------------
function autoDailyMissionClaim()
    if not AUTO.AutoDailyMissionClaim then return false end
    if AUTO.Paused then return false end
    if not every("x_dailymission", tonumber(AUTO.DailyMissionGap) or 45) then return false end
    local names = { "DailyMission", "DailyQuest", "DailyTasks", "MissionRemote" }
    local n = 0
    for _, name in ipairs(names) do
        local r = xFindRemote(name)
        if r then
            local ok = pcall(function()
                if r:IsA("RemoteFunction") then r:InvokeServer("Claim")
                else r:FireServer("Claim") end
            end)
            if ok then n = n + 1 end
        end
    end
    if n == 0 then
        if xClickButtonByName(pg, { "DailyMission", "Daily", "日常" }, "x_dailymissionbtn", 45) then n = 1 end
    end
    if n > 0 then
        AUTO.LastReason = "每日任务：已领取"
        log("每日任务：已请求领取 " .. n .. " 项")
        xStatAdd("每日任务", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 155. 排位匹配
----------------------------------------------------------------
function autoRankedQueue()
    if not AUTO.AutoRankedQueue then return false end
    if AUTO.Paused then return false end
    if inMatch() then return false end
    if not every("x_ranked", tonumber(AUTO.RankedGap) or 8) then return false end
    local ok = xFire("Ranked", "Queue") or xFire("StartRanked") or xFire("Matchmaking", "Ranked")
    if not ok then
        ok = xClickButtonByName(pg, { "Ranked", "排位" }, "x_rankedbtn", 8)
    end
    if ok then
        AUTO.LastReason = "排位：已请求匹配"
        log("排位匹配：已请求进入排位")
        xStatAdd("排位匹配", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 156. 心愿单扫描
----------------------------------------------------------------
function autoWishlistScan()
    if not AUTO.AutoWishlistScan then return false end
    if not every("x_wishlist", tonumber(AUTO.WishlistGap) or 90) then return false end
    local names = AUTO.WishlistNames or {}
    if #names == 0 then
        log("心愿单扫描：未配置心愿物品")
        return false
    end
    local money = xFindPlayerAttrNumber(AUTO.CurrencyNames or { "Money", "Cash", "Coins", "Gold" })
    local found = {}
    pcall(function()
        for _, d in ipairs(pg:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible and d.Text then
                for _, w in ipairs(names) do
                    if string.find(string.lower(d.Text), string.lower(tostring(w)), 1, true) then
                        found[#found + 1] = w
                    end
                end
            end
        end
    end)
    AUTO.WishlistHits = #found
    if #found > 0 then
        log(string.format("心愿单扫描：发现 %d 个心愿物品（余额 %s）", #found,
            money ~= nil and xFmt(money) or "未知"))
        xStatAdd("心愿扫描", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 157. 自动捡弹药
----------------------------------------------------------------
function autoAmmoPickup()
    if not AUTO.AutoAmmoPickup then return false end
    if AUTO.Paused then return false end
    if not every("x_ammopick", tonumber(AUTO.AmmoPickupGap) or 3) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.AmmoPickupRange) or 30
    local best, bestDist = nil, range
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                local low = string.lower(d.Name)
                if string.find(low, "ammo", 1, true) or string.find(low, "bullet", 1, true)
                    or string.find(low, "magazine", 1, true) then
                    local dist = (d.Position - base.Position).Magnitude
                    if dist < bestDist then
                        best, bestDist = d, dist
                    end
                end
            end
        end
    end)
    if not best then return false end
    xTp(best.Position + Vector3.new(0, 2, 0))
    AUTO.LastReason = "捡弹药：" .. best.Name
    xStatAdd("捡弹药", 1)
    return true
end

----------------------------------------------------------------
-- 158. 合成队列
----------------------------------------------------------------
function autoCraftQueue()
    if not AUTO.AutoCraftQueue then return false end
    if AUTO.Paused then return false end
    if not every("x_craftqueue", tonumber(AUTO.CraftQueueGap) or 10) then return false end
    local list = AUTO.CraftQueueItems or {}
    if #list == 0 then return false end
    local state = xSt("craftqueue")
    state.index = (state.index or 0) + 1
    if state.index > #list then state.index = 1 end
    local item = list[state.index]
    local name, amount = item, 1
    if type(item) == "table" then
        name = item.name or item[1]
        amount = tonumber(item.amount or item[2]) or 1
    end
    local ok = xFire("Craft", name, amount) or xFire("CraftItem", name, amount)
    if ok then
        AUTO.LastReason = "合成队列：" .. tostring(name)
        log("合成队列：已合成 " .. tostring(name) .. " × " .. amount)
        xStatAdd("合成队列", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 159. 自动喂养宠物
----------------------------------------------------------------
function autoPetFeed()
    if not AUTO.AutoPetFeed then return false end
    if AUTO.Paused then return false end
    if not every("x_petfeed", tonumber(AUTO.PetFeedGap) or 120) then return false end
    local ok = xFire("FeedPet") or xFire("PetFeed") or xFire("Feed")
    if not ok then
        ok = xClickButtonByName(pg, { "Feed", "PetFeed" }, "x_petfeedbtn", 120)
    end
    if ok then
        AUTO.LastReason = "宠物喂养：已请求"
        log("宠物喂养：已请求喂养")
        xStatAdd("宠物喂养", 1)
    end
    return ok
end

-- [[EXT2-BATCH8-END]]

-- [[EXT2-BATCH7-END]]

-- [[EXT2-BATCH6-END]]

-- [[EXT2-BATCH5-END]]

-- [[EXT2-BATCH4-END]]

-- [[EXT2-BATCH3-END]]

-- [[EXT2-BATCH2-END]]

-- [[EXT2-BATCH1-END]]

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 X：战斗补强 / 生存续航 / 活动日常（160 - 195）
-- ============================================================
----------------------------------------------------------------
local X10_DEFAULTS = {
    AutoUseReviveItem = false, ReviveItemGap = 2,
    AutoRevivePromptScan = false, RevivePromptRange = 25, RevivePromptGap = 2,
    AutoHealPriority = false, HealPriorityHp = 55, HealPriorityGap = 1.5,
    AutoSecondWind = false, SecondWindHp = 20, SecondWindGap = 12,
    AutoPositionAnchor = false, AnchorDrift = 60, AnchorGap = 3,
    AutoFocusTargetLock = false, FocusLockTime = 6,
    AutoAttackGapFill = false, AttackGapFill = 0.2,
    AutoReloadCycle = false, ReloadCycleGap = 1.2,
    AutoWeaponSwapLow = false, WeaponSwapGap = 2,
    AutoDodgeRoll = false, DodgeRollRange = 14, DodgeRollGap = 0.8,
    AutoBlockGuard = false, BlockGuardHp = 45, BlockGuardGap = 1.5,
    AutoCoverUse = false, CoverRange = 30, CoverGap = 2.5,
    AutoSuppressiveFire = false, SuppressEnemyCount = 2, SuppressGap = 0.3,
    AutoSnipeFar = false, SnipeMinDist = 60, SnipeGap = 1.5,
    AutoMeleeClose = false, MeleeCloseDist = 12, MeleeGap = 1,
    AutoEliteFocus = false, EliteGap = 2,
    AutoAddClear = false, AddClearGap = 1.2,
    AutoRangedKite = false, RangedKiteMin = 30, RangedKiteMax = 50, RangedKiteGap = 1.2,
    AutoSummonAssist = false, SummonGap = 20,
    AutoTurretPlace = false, TurretGap = 25,
    AutoTrapPlace = false, TrapGap = 18,
    AutoConsumeCooldown = false, ConsumeCooldownGap = 8,
    AutoBuffStack = false, BuffStackGap = 30, BuffStackNames = {},
    AutoDebuffApply = false, DebuffGap = 6,
    AutoStatusClear = false, StatusClearGap = 4,
    AutoShieldBreak = false, ShieldBreakGap = 2,
    AutoBossMechanic = false, BossMechanicGap = 3,
    AutoWavePrep = false, WavePrepGap = 5,
    AutoIntermissionLoot = false, IntermissionGap = 2.5,
    AutoSafeSpotRotate = false, SafeSpotCount = 3, SafeSpotGap = 6,
    AutoStamina = false, StaminaMin = 20, StaminaGap = 1,
    AutoFoodBuff = false, FoodBuffGap = 60, FoodBuffNames = {},
    AutoDailyLogin = false, DailyLoginGap = 3600,
    AutoFriendGift = false, FriendGiftGap = 600, FriendGiftNames = {},
    AutoGuildCheckIn = false, GuildCheckInGap = 600,
    AutoLeaderboardCheck = false, LeaderboardGap = 120,
}
for k, v in pairs(X10_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

----------------------------------------------------------------
-- 160. 自动使用复活道具
----------------------------------------------------------------
function autoUseReviveItem()
    if not AUTO.AutoUseReviveItem then return false end
    if AUTO.Paused then return false end
    if not every("x_reviveitem", tonumber(AUTO.ReviveItemGap) or 2) then return false end
    local h = xHum2()
    if not h or h.Health > 0 then return false end
    local ok = xFire("UseRevive") or xFire("ReviveItem") or xFire("RequestRevive")
    if not ok then
        ok = xUseNamedRemote("UseItems", { "Revive", "Revival", "Phoenix" }) > 0
    end
    if not ok then
        local prompt = xFindPromptByKeyword and xFindPromptByKeyword("revive")
        if prompt then ok = xUsePrompt(prompt) end
    end
    if ok then
        AUTO.LastReason = "复活道具：已使用"
        log("复活道具：角色倒下，已尝试使用复活道具")
        xStatAdd("复活道具", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 161. 扫描复活提示
----------------------------------------------------------------
function autoRevivePromptScan()
    if not AUTO.AutoRevivePromptScan then return false end
    if AUTO.Paused then return false end
    if not every("x_reviveprompt", tonumber(AUTO.RevivePromptGap) or 2) then return false end
    local range = tonumber(AUTO.RevivePromptRange) or 25
    local n = 0
    for _, p in ipairs(xNearPrompts(range)) do
        local low = string.lower(p.Name)
        local act = tostring(p.ActionText or ""):lower()
        if string.find(low, "revive", 1, true) or string.find(act, "revive", 1, true) then
            if xUsePrompt(p) then n = n + 1 end
        end
    end
    if n > 0 then
        AUTO.LastReason = "复活提示：已触发 " .. n .. " 个"
        log("复活提示：已触发 " .. n .. " 个")
        xStatAdd("复活提示", n)
    end
    return n > 0
end

----------------------------------------------------------------
-- 162. 治疗优先级
----------------------------------------------------------------
function autoHealPriority()
    if not AUTO.AutoHealPriority then return false end
    if AUTO.Paused then return false end
    if not every("x_healprio", tonumber(AUTO.HealPriorityGap) or 1.5) then return false end
    local threshold = tonumber(AUTO.HealPriorityHp) or 55
    local best, bestPct = nil, 101
    for _, a in ipairs(xAllyList(tonumber(AUTO.Range) or 200)) do
        if a.maxhp > 0 and a.hp > 0 then
            local pct = a.hp / a.maxhp * 100
            if pct < bestPct then best, bestPct = a, pct end
        end
    end
    local myPct = xHpPct()
    if myPct > 0 and myPct < bestPct then
        best, bestPct = nil, myPct
    end
    if bestPct > threshold then return false end
    if best then
        local ok = fireRemote("Heal", best.player) or fireRemote("HealPlayer", best.player)
        if not ok then ok = xUseNamedRemote("Heals", { "Heal", "Medkit" }) > 0 end
        if ok then
            AUTO.LastReason = string.format("治疗优先级：%s（%.0f%%）", best.player.Name, bestPct)
            log(string.format("治疗优先级：%s 血量 %.0f%%，已治疗", best.player.Name, bestPct))
            xStatAdd("治疗队友", 1)
            return true
        end
    else
        local n = xUseNamedRemote("Potions", AUTO.HealNames or { "Heal", "Medkit", "Bandage" })
        if n > 0 then
            AUTO.LastReason = string.format("治疗优先级：自身 %.0f%%，已治疗", myPct)
            log(string.format("治疗优先级：自身血量 %.0f%%，已用药", myPct))
            xStatAdd("自我治疗", n)
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- 163. 濒死护盾
----------------------------------------------------------------
function autoSecondWind()
    if not AUTO.AutoSecondWind then return false end
    if AUTO.Paused then return false end
    if not every("x_secondwind", tonumber(AUTO.SecondWindGap) or 12) then return false end
    local pct = xHpPct()
    if pct <= 0 or pct > (tonumber(AUTO.SecondWindHp) or 20) then return false end
    local n = xUseNamedRemote("Boosts", { "Shield", "Barrier", "SecondWind" })
    if n == 0 then n = xUseNamedRemote("Potions", { "Shield", "Barrier" }) end
    if n > 0 then
        AUTO.LastReason = "濒死护盾：已开启"
        log(string.format("濒死护盾：血量 %.0f%%，已开启护盾", pct))
        xStatAdd("濒死护盾", 1)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 164. 站位锚点
----------------------------------------------------------------
function autoPositionAnchor()
    if not AUTO.AutoPositionAnchor then return false end
    if AUTO.Paused then return false end
    if not every("x_anchor", tonumber(AUTO.AnchorGap) or 3) then return false end
    local base = xRoot2()
    if not base then return false end
    local st = xSt("anchor")
    if not st.pos then
        st.pos = base.Position
        return false
    end
    local drift = (base.Position - st.pos).Magnitude
    if drift <= (tonumber(AUTO.AnchorDrift) or 60) then return false end
    if #xEnemyList(tonumber(AUTO.Range) or 200) > 0 then
        st.pos = base.Position
        return false
    end
    xTp(st.pos + Vector3.new(0, 4, 0))
    AUTO.LastReason = string.format("站位锚点：偏离 %.0f 格，已归位", drift)
    log(string.format("站位锚点：偏离 %.0f 格，已返回锚点", drift))
    xStatAdd("归位", 1)
    st.pos = base.Position
    return true
end

----------------------------------------------------------------
-- 165. 目标锁定保持
----------------------------------------------------------------
function autoFocusTargetLock()
    if not AUTO.AutoFocusTargetLock then return false end
    if AUTO.Paused then return false end
    local st = xSt("focuslock")
    local now = os.clock()
    if AUTO.Target and st.name == AUTO.Target and st.until_ and now < st.until_ then
        return false
    end
    local enemy = xPickTarget(tonumber(AUTO.Range) or 200)
    if enemy then
        st.name = enemy.model.Name
        st.until_ = now + (tonumber(AUTO.FocusLockTime) or 6)
        AUTO.Target = enemy.model.Name
        return true
    end
    st.name = nil
    st.until_ = nil
    return false
end

----------------------------------------------------------------
-- 166. 攻击间隔填充
----------------------------------------------------------------
function autoAttackGapFill()
    if not AUTO.AutoAttackGapFill then return false end
    if AUTO.Paused then return false end
    if not AUTO.AutoFight and not AUTO.AutoAim then return false end
    if not every("x_attackfill", tonumber(AUTO.AttackGapFill) or 0.2) then return false end
    local c = myChar()
    if not c then return false end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local ok = pcall(function() tool:Activate() end)
    if ok then
        xStatAdd("补攻击", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 167. 换弹循环
----------------------------------------------------------------
function autoReloadCycle()
    if not AUTO.AutoReloadCycle then return false end
    if AUTO.Paused then return false end
    if not every("x_reloadcycle", tonumber(AUTO.ReloadCycleGap) or 1.2) then return false end
    local c = myChar()
    local tool = c and c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local ammo = tool:GetAttribute("Ammo") or tool:GetAttribute("Clip") or tool:GetAttribute("Mag")
    local maxAmmo = tool:GetAttribute("MaxAmmo") or tool:GetAttribute("ClipSize")
    if ammo == nil or maxAmmo == nil then return false end
    if tonumber(ammo) > 0 and tonumber(ammo) >= tonumber(maxAmmo) * 0.3 then return false end
    local prompt = xFindPromptByKeyword and xFindPromptByKeyword("reload")
    local ok = false
    if prompt then ok = xUsePrompt(prompt) end
    if not ok then ok = xFire("Reload") or xFire("RequestReload") end
    if ok then
        xStatAdd("换弹", 1)
        AUTO.LastReason = "换弹循环：已换弹"
    end
    return ok
end

----------------------------------------------------------------
-- 168. 低耐久换武器
----------------------------------------------------------------
function autoWeaponSwapLow()
    if not AUTO.AutoWeaponSwapLow then return false end
    if AUTO.Paused then return false end
    if not every("x_weaponswap", tonumber(AUTO.WeaponSwapGap) or 2) then return false end
    local c = myChar()
    if not c then return false end
    local cur = c:FindFirstChildOfClass("Tool")
    if not cur then return false end
    local dur = cur:GetAttribute("Durability") or cur:GetAttribute("Durab") or cur:GetAttribute("DurabilityLeft")
    if dur == nil then return false end
    local maxDur = cur:GetAttribute("MaxDurability") or cur:GetAttribute("MaxDurab")
    local pct = maxDur and tonumber(maxDur) > 0 and (tonumber(dur) / tonumber(maxDur) * 100) or tonumber(dur)
    if pct == nil or pct > 20 then return false end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") and t ~= cur then
            local d2 = t:GetAttribute("Durability") or t:GetAttribute("Durab")
            if d2 == nil or tonumber(d2) > pct then
                local ok = xEquipTool(t)
                if ok then
                    AUTO.LastReason = "武器耐久：" .. cur.Name .. " 过低，已换 " .. t.Name
                    log("武器耐久：" .. cur.Name .. " 过低，已切换到 " .. t.Name)
                    xStatAdd("换武器", 1)
                    return true
                end
            end
        end
    end
    return false
end

----------------------------------------------------------------
-- 169. 翻滚闪避
----------------------------------------------------------------
function autoDodgeRoll()
    if not AUTO.AutoDodgeRoll then return false end
    if AUTO.Paused then return false end
    if not every("x_dodgeroll", tonumber(AUTO.DodgeRollGap) or 0.8) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.DodgeRollRange) or 14
    local threat = nil
    for _, e in ipairs(xEnemyList(range)) do
        threat = e
        break
    end
    if not threat then return false end
    local dir = base.Position - threat.pos
    if dir.Magnitude <= 0 then dir = Vector3.new(1, 0, 0) end
    local target = base.Position + dir.Unit * 10 + Vector3.new(0, 2, 0)
    local ok = xTp(target)
    if ok then
        AUTO.LastReason = "翻滚闪避：已拉开距离"
        xStatAdd("翻滚", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 170. 格挡保护
----------------------------------------------------------------
function autoBlockGuard()
    if not AUTO.AutoBlockGuard then return false end
    if AUTO.Paused then return false end
    if not every("x_blockguard", tonumber(AUTO.BlockGuardGap) or 1.5) then return false end
    local pct = xHpPct()
    if pct <= 0 or pct > (tonumber(AUTO.BlockGuardHp) or 45) then return false end
    local c = myChar()
    local tool = c and xFindTool("block")
    if tool then
        local ok = xActivateTool(tool)
        if ok then
            AUTO.LastReason = "格挡保护：已举盾"
            xStatAdd("格挡", 1)
            return true
        end
    end
    local prompt = xFindPromptByKeyword and xFindPromptByKeyword("block")
    if prompt then return xUsePrompt(prompt) end
    return false
end

----------------------------------------------------------------
-- 171. 掩体利用
----------------------------------------------------------------
function autoCoverUse()
    if not AUTO.AutoCoverUse then return false end
    if AUTO.Paused then return false end
    if not every("x_coveruse", tonumber(AUTO.CoverGap) or 2.5) then return false end
    local base = xRoot2()
    if not base or xHpPct() > 60 then return false end
    local range = tonumber(AUTO.CoverRange) or 30
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { myChar() }
    local bestPos, bestDist = nil, range
    for i = 1, 8 do
        local ang = math.rad(i * 45)
        local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
        local hit = workspace:Raycast(base.Position, dir * range, rayParams)
        if hit and hit.Position then
            local d = (hit.Position - base.Position).Magnitude
            if d < bestDist then
                bestPos = hit.Position - dir.Unit * 3 + Vector3.new(0, 3, 0)
                bestDist = d
            end
        end
    end
    if bestPos then
        local ok = xTp(bestPos)
        if ok then
            AUTO.LastReason = "掩体利用：已贴身掩体"
            xStatAdd("掩体", 1)
        end
        return ok
    end
    return false
end

----------------------------------------------------------------
-- 172. 压制射击
----------------------------------------------------------------
function autoSuppressiveFire()
    if not AUTO.AutoSuppressiveFire then return false end
    if AUTO.Paused then return false end
    if not every("x_suppress", tonumber(AUTO.SuppressGap) or 0.3) then return false end
    local need = tonumber(AUTO.SuppressEnemyCount) or 2
    local list = xEnemyList(tonumber(AUTO.Range) or 200)
    if #list < need then return false end
    local c = myChar()
    local tool = c and c:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local ok = pcall(function() tool:Activate() end)
    if ok then
        AUTO.LastReason = "压制射击：" .. #list .. " 个目标"
        xStatAdd("压制射击", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 173. 远程点杀
----------------------------------------------------------------
function autoSnipeFar()
    if not AUTO.AutoSnipeFar then return false end
    if AUTO.Paused then return false end
    if not every("x_snipfar", tonumber(AUTO.SnipeGap) or 1.5) then return false end
    local minDist = tonumber(AUTO.SnipeMinDist) or 60
    local best, bestD = nil, -1
    for _, e in ipairs(xEnemyList(tonumber(AUTO.Range) or 300)) do
        if e.dist >= minDist and e.dist > bestD then
            best, bestD = e, e.dist
        end
    end
    if not best then return false end
    if AUTO.AutoAim then
        local okAim = pcall(function()
            local bb = bot()
            if bb then
                bb.Enabled = true
                bb.AimPosition = best.pos + Vector3.new(0, 1.2, 0)
            end
        end)
        if not okAim then return false end
    end
    local c = myChar()
    local tool = c and c:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    AUTO.LastReason = string.format("远程点杀：%s（%.0f 格）", best.model.Name, bestD)
    xStatAdd("点杀", 1)
    return true
end

----------------------------------------------------------------
-- 174. 近战贴脸
----------------------------------------------------------------
function autoMeleeClose()
    if not AUTO.AutoMeleeClose then return false end
    if AUTO.Paused then return false end
    if not every("x_meleeclose", tonumber(AUTO.MeleeGap) or 1) then return false end
    local list = xEnemyList(tonumber(AUTO.Range) or 200)
    if #list == 0 then return false end
    local target = list[1]
    if target.dist <= (tonumber(AUTO.MeleeCloseDist) or 12) then return false end
    local ok = xTp(target.pos + Vector3.new(0, 3, 0))
    if ok then
        AUTO.LastReason = string.format("近战贴脸：%s（%.0f 格）", target.model.Name, target.dist)
        xStatAdd("贴脸", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 175. 精英优先
----------------------------------------------------------------
function autoEliteFocus()
    if not AUTO.AutoEliteFocus then return false end
    if AUTO.Paused then return false end
    if not every("x_elitefocus", tonumber(AUTO.EliteGap) or 2) then return false end
    local best, bestHp = nil, -1
    for _, e in ipairs(xEnemyList(tonumber(AUTO.Range) or 250)) do
        local h = humOf(e.model)
        if h and h.MaxHealth > bestHp then
            best, bestHp = e, h.MaxHealth
        end
    end
    if not best then return false end
    AUTO.Target = best.model.Name
    AUTO.LastReason = string.format("精英优先：%s（%d 血）", best.model.Name, math.floor(bestHp))
    xStatAdd("精英目标", 1)
    return true
end

----------------------------------------------------------------
-- 176. 小怪清理
----------------------------------------------------------------
function autoAddClear()
    if not AUTO.AutoAddClear then return false end
    if AUTO.Paused then return false end
    if not every("x_addclear", tonumber(AUTO.AddClearGap) or 1.2) then return false end
    local best, bestHp = nil, math.huge
    for _, e in ipairs(xEnemyList(tonumber(AUTO.Range) or 200)) do
        local h = humOf(e.model)
        if h and h.Health > 0 and h.Health < bestHp then
            best, bestHp = e, h.Health
        end
    end
    if not best then return false end
    AUTO.Target = best.model.Name
    AUTO.LastReason = string.format("小怪清理：%s（%d 血）", best.model.Name, math.floor(bestHp))
    xStatAdd("清小怪", 1)
    return true
end

----------------------------------------------------------------
-- 177. 远程风筝
----------------------------------------------------------------
function autoRangedKite()
    if not AUTO.AutoRangedKite then return false end
    if AUTO.Paused then return false end
    if not every("x_rangedkite", tonumber(AUTO.RangedKiteGap) or 1.2) then return false end
    local list = xEnemyList(tonumber(AUTO.Range) or 250)
    if #list == 0 then return false end
    local near = list[1]
    local minD = tonumber(AUTO.RangedKiteMin) or 30
    if near.dist >= minD then return false end
    local base = xRoot2()
    if not base then return false end
    local dir = base.Position - near.pos
    if dir.Magnitude <= 0 then dir = Vector3.new(0, 0, 1) end
    local dest = base.Position + dir.Unit * (minD - near.dist + 8) + Vector3.new(0, 2, 0)
    local ok = xTp(dest)
    if ok then
        AUTO.LastReason = string.format("远程风筝：%s 过近，已拉开", near.model.Name)
        xStatAdd("风筝", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 178. 召唤协同
----------------------------------------------------------------
function autoSummonAssist()
    if not AUTO.AutoSummonAssist then return false end
    if AUTO.Paused then return false end
    if not every("x_summon", tonumber(AUTO.SummonGap) or 20) then return false end
    local ok = xFire("Summon") or xFire("SummonPet") or xFire("RequestSummon")
    if not ok then
        local tool = xFindTool("summon")
        if tool then ok = xActivateTool(tool) end
    end
    if ok then
        AUTO.LastReason = "召唤协同：已请求召唤"
        log("召唤协同：已请求召唤物协助")
        xStatAdd("召唤", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 179. 放置炮台
----------------------------------------------------------------
function autoTurretPlace()
    if not AUTO.AutoTurretPlace then return false end
    if AUTO.Paused then return false end
    if not every("x_turret", tonumber(AUTO.TurretGap) or 25) then return false end
    local tool = xFindTool("turret") or xFindTool("炮台") or xFindTool("sentr")
    if not tool then return false end
    local ok = xActivateTool(tool)
    if ok then
        AUTO.LastReason = "放置炮台：已部署"
        log("放置炮台：已部署 " .. tool.Name)
        xStatAdd("炮台", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 180. 放置陷阱
----------------------------------------------------------------
function autoTrapPlace()
    if not AUTO.AutoTrapPlace then return false end
    if AUTO.Paused then return false end
    if not every("x_trap", tonumber(AUTO.TrapGap) or 18) then return false end
    local tool = xFindTool("trap") or xFindTool("mine") or xFindTool("陷阱")
    if not tool then return false end
    local ok = xActivateTool(tool)
    if ok then
        AUTO.LastReason = "放置陷阱：已布置"
        log("放置陷阱：已布置 " .. tool.Name)
        xStatAdd("陷阱", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 181. 消耗品冷却
----------------------------------------------------------------
function autoConsumeCooldown()
    if not AUTO.AutoConsumeCooldown then return false end
    if AUTO.Paused then return false end
    if not every("x_consume_cd", tonumber(AUTO.ConsumeCooldownGap) or 8) then return false end
    local c = myChar()
    if not c then return false end
    local n = 0
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then
            local cd = t:GetAttribute("Cooldown") or t:GetAttribute("CD")
            local ready = t:GetAttribute("Ready")
            if ready == true or (cd ~= nil and tonumber(cd) <= 0) then
                if xActivateTool(t) then n = n + 1 end
            end
        end
    end
    if n > 0 then
        AUTO.LastReason = "消耗品冷却：已使用 " .. n .. " 个"
        xStatAdd("消耗品", n)
    end
    return n > 0
end

----------------------------------------------------------------
-- 182. 增益叠加
----------------------------------------------------------------
function autoBuffStack()
    if not AUTO.AutoBuffStack then return false end
    if AUTO.Paused then return false end
    if not every("x_buffstack", tonumber(AUTO.BuffStackGap) or 30) then return false end
    local names = AUTO.BuffStackNames
    if type(names) ~= "table" or #names == 0 then
        names = { "Damage", "Speed", "Defense", "Buff" }
    end
    local n = xUseNamedRemote("Boosts", names)
    if n == 0 then n = xUseNamedRemote("UseItems", names) end
    if n > 0 then
        AUTO.LastReason = "增益叠加：已叠加 " .. n .. " 层"
        log("增益叠加：已使用 " .. n .. " 个增益")
        xStatAdd("增益叠加", n)
    end
    return n > 0
end

----------------------------------------------------------------
-- 183. 施加减益
----------------------------------------------------------------
function autoDebuffApply()
    if not AUTO.AutoDebuffApply then return false end
    if AUTO.Paused then return false end
    if not every("x_debuff", tonumber(AUTO.DebuffGap) or 6) then return false end
    local list = xEnemyList(tonumber(AUTO.Range) or 200)
    if #list == 0 then return false end
    local target = list[1]
    local ok = xFire("Debuff", target.model) or xFire("ApplyDebuff", target.model)
    if not ok then
        local id = (AUTO.DebuffSkills or {})[1]
        if id then ok = xCastSkillById(id, target.pos) end
    end
    if ok then
        AUTO.LastReason = "施加减益：" .. target.model.Name
        xStatAdd("减益", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 184. 清除负面状态
----------------------------------------------------------------
function autoStatusClear()
    if not AUTO.AutoStatusClear then return false end
    if AUTO.Paused then return false end
    if not every("x_statusclear", tonumber(AUTO.StatusClearGap) or 4) then return false end
    local h = xHum2()
    if not h then return false end
    local bad = 0
    for _, name in ipairs({ "Burning", "Poison", "Stunned", "Frozen", "Bleeding", "Slowed" }) do
        if h:GetAttribute(name) == true then bad = bad + 1 end
    end
    if bad == 0 then return false end
    local n = xUseNamedRemote("Potions", { "Cleanse", "Antidote", "Purify" })
    if n == 0 then n = xUseNamedRemote("UseItems", { "Cleanse", "Antidote" }) end
    if n > 0 then
        AUTO.LastReason = "清除负面：" .. bad .. " 个状态"
        log("清除负面：已清除 " .. bad .. " 个负面状态")
        xStatAdd("净化", n)
        return true
    end
    return false
end

----------------------------------------------------------------
-- 185. 破盾
----------------------------------------------------------------
function autoShieldBreak()
    if not AUTO.AutoShieldBreak then return false end
    if AUTO.Paused then return false end
    if not every("x_shieldbreak", tonumber(AUTO.ShieldBreakGap) or 2) then return false end
    for _, e in ipairs(xEnemyList(tonumber(AUTO.Range) or 200)) do
        local shield = e.model:GetAttribute("Shield") or e.model:GetAttribute("Armor")
        local h = humOf(e.model)
        if h and h.Health > 0 then
            local hasShield = (shield ~= nil and tonumber(shield) > 0)
                or e.model:FindFirstChild("Shield") ~= nil
            if hasShield then
                local ok = xFire("BreakShield", e.model) or xFire("ShieldBreak", e.model)
                if ok then
                    AUTO.LastReason = "破盾：" .. e.model.Name
                    xStatAdd("破盾", 1)
                    return true
                end
            end
        end
    end
    return false
end

----------------------------------------------------------------
-- 186. Boss 机制应对
----------------------------------------------------------------
function autoBossMechanic()
    if not AUTO.AutoBossMechanic then return false end
    if AUTO.Paused then return false end
    if not every("x_bossmech", tonumber(AUTO.BossMechanicGap) or 3) then return false end
    local boss = nil
    for _, e in ipairs(xEnemyList(tonumber(AUTO.Range) or 300)) do
        if xIsBoss(e.model) then
            boss = e
            break
        end
    end
    if not boss then
        xSt("bossmech").phase = nil
        return false
    end
    local h = humOf(boss.model)
    if not h or h.MaxHealth <= 0 then return false end
    local pct = h.Health / h.MaxHealth * 100
    local phase = pct > 66 and 1 or (pct > 33 and 2 or 3)
    local st = xSt("bossmech")
    if st.phase == phase then return false end
    st.phase = phase
    local safe = xSafePoint(boss.pos, 45)
    if safe then xTp(safe) end
    AUTO.LastReason = string.format("Boss机制：进入第 %d 阶段，已撤离", phase)
    log(string.format("Boss机制：%s 进入第 %d 阶段（%.0f%%），已撤到安全点", boss.model.Name, phase, pct))
    xStatAdd("Boss阶段", 1)
    return true
end

----------------------------------------------------------------
-- 187. 波次准备
----------------------------------------------------------------
function autoWavePrep()
    if not AUTO.AutoWavePrep then return false end
    if AUTO.Paused then return false end
    if not every("x_waveprep", tonumber(AUTO.WavePrepGap) or 5) then return false end
    if inMatch() then return false end
    local pct = xHpPct()
    local did = false
    if pct > 0 and pct < 90 then
        local n = xUseNamedRemote("Potions", { "Heal", "Medkit" })
        if n > 0 then did = true end
    end
    local ammo = xUseNamedRemote("Ammo", { "Ammo", "Refill" })
    if ammo > 0 then did = true end
    if did then
        AUTO.LastReason = "波次准备：已补给"
        log("波次准备：已补充状态与弹药")
        xStatAdd("波次准备", 1)
    end
    return did
end

----------------------------------------------------------------
-- 188. 间歇拾取
----------------------------------------------------------------
function autoIntermissionLoot()
    if not AUTO.AutoIntermissionLoot then return false end
    if AUTO.Paused then return false end
    if not every("x_interloot", tonumber(AUTO.IntermissionGap) or 2.5) then return false end
    if inMatch() and #xEnemyList(tonumber(AUTO.Range) or 200) > 0 then return false end
    local base = xRoot2()
    if not base then return false end
    local best, bestD = nil, 60
    for _, d in ipairs(workspace:GetDescendants()) do
        if (d:IsA("Model") or d:IsA("BasePart")) and d.Name ~= player.Name then
            local low = string.lower(d.Name)
            if string.find(low, "drop", 1, true) or string.find(low, "loot", 1, true)
                or string.find(low, "reward", 1, true) then
                local p = xPosOf(d)
                if p then
                    local dist = (p - base.Position).Magnitude
                    if dist < bestD then best, bestD = p, dist end
                end
            end
        end
    end
    if best then
        local ok = xTp(best + Vector3.new(0, 3, 0))
        if ok then
            AUTO.LastReason = string.format("间歇拾取：%.0f 格", bestD)
            xStatAdd("拾取", 1)
        end
        return ok
    end
    return false
end

----------------------------------------------------------------
-- 189. 安全点轮换
----------------------------------------------------------------
function autoSafeSpotRotate()
    if not AUTO.AutoSafeSpotRotate then return false end
    if AUTO.Paused then return false end
    if not every("x_safespot", tonumber(AUTO.SafeSpotGap) or 6) then return false end
    local base = xRoot2()
    if not base or xHpPct() > 40 then return false end
    local count = math.max(1, tonumber(AUTO.SafeSpotCount) or 3)
    local st = xSt("safespot")
    st.idx = (st.idx or 0) % count + 1
    local ang = math.rad((st.idx - 1) * (360 / count))
    local dest = base.Position + Vector3.new(math.cos(ang) * 35, 4, math.sin(ang) * 35)
    local ok = xTp(dest)
    if ok then
        AUTO.LastReason = "安全点轮换：" .. st.idx
        xStatAdd("轮换", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 190. 体力管理
----------------------------------------------------------------
function autoStamina()
    if not AUTO.AutoStamina then return false end
    if AUTO.Paused then return false end
    if not every("x_stamina", tonumber(AUTO.StaminaGap) or 1) then return false end
    local h = xHum2()
    if not h then return false end
    local stam = h:GetAttribute("Stamina") or h:GetAttribute("Energy")
    if stam == nil then return false end
    local minS = tonumber(AUTO.StaminaMin) or 20
    if tonumber(stam) <= minS then
        pcall(function() h.WalkSpeed = 16 end)
        AUTO.LastReason = string.format("体力管理：%d，已降速", math.floor(tonumber(stam)))
        return true
    end
    return false
end

----------------------------------------------------------------
-- 191. 食物增益
----------------------------------------------------------------
function autoFoodBuff()
    if not AUTO.AutoFoodBuff then return false end
    if AUTO.Paused then return false end
    if not every("x_foodbuff", tonumber(AUTO.FoodBuffGap) or 60) then return false end
    local names = AUTO.FoodBuffNames
    if type(names) ~= "table" or #names == 0 then
        names = { "Food", "Snack", "Meal" }
    end
    local n = xUseNamedRemote("Food", names)
    if n == 0 then n = xUseNamedRemote("UseItems", names) end
    if n > 0 then
        AUTO.LastReason = "食物增益：已使用 " .. n .. " 个"
        log("食物增益：已使用 " .. n .. " 个食物")
        xStatAdd("食物", n)
    end
    return n > 0
end

----------------------------------------------------------------
-- 192. 每日登录
----------------------------------------------------------------
function autoDailyLogin()
    if not AUTO.AutoDailyLogin then return false end
    if AUTO.Paused then return false end
    if not every("x_dailylogin", tonumber(AUTO.DailyLoginGap) or 3600) then return false end
    local today = os.date("%Y%m%d")
    local st = xSt("dailylogin")
    if st.day == today then return false end
    local ok = xFire("DailyLogin") or xFire("ClaimLogin") or xFire("LoginReward")
    if ok then
        st.day = today
        AUTO.LastReason = "每日登录：已领取"
        log("每日登录：已领取今日登录奖励")
        xStatAdd("每日登录", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 193. 好友赠礼
----------------------------------------------------------------
function autoFriendGift()
    if not AUTO.AutoFriendGift then return false end
    if AUTO.Paused then return false end
    if not every("x_friendgift", tonumber(AUTO.FriendGiftGap) or 600) then return false end
    local names = AUTO.FriendGiftNames
    local n = 0
    if type(names) == "table" and #names > 0 then
        for _, name in ipairs(names) do
            local plr = Players:FindFirstChild(name)
            if plr then
                local ok = fireRemote("SendGift", plr) or fireRemote("Gift", plr)
                if ok then n = n + 1 end
            end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local ok = fireRemote("SendGift", plr) or fireRemote("Gift", plr)
                if ok then n = n + 1 end
            end
        end
    end
    if n > 0 then
        AUTO.LastReason = "好友赠礼：已赠送 " .. n .. " 人"
        log("好友赠礼：已赠送 " .. n .. " 位好友")
        xStatAdd("赠礼", n)
    end
    return n > 0
end

----------------------------------------------------------------
-- 194. 公会签到
----------------------------------------------------------------
function autoGuildCheckIn()
    if not AUTO.AutoGuildCheckIn then return false end
    if AUTO.Paused then return false end
    if not every("x_guildcheck", tonumber(AUTO.GuildCheckInGap) or 600) then return false end
    local ok = xFire("GuildCheckIn") or xFire("CheckIn") or xFire("GuildSign")
    if not ok then
        ok = xClickButtonByName(pg, { "CheckIn", "签到", "Guild" }, "x_guildbtn", 600)
    end
    if ok then
        AUTO.LastReason = "公会签到：已完成"
        log("公会签到：已签到")
        xStatAdd("公会签到", 1)
    end
    return ok
end

----------------------------------------------------------------
-- 195. 排行榜检查
----------------------------------------------------------------
function autoLeaderboardCheck()
    if not AUTO.AutoLeaderboardCheck then return false end
    if AUTO.Paused then return false end
    if not every("x_leaderboard", tonumber(AUTO.LeaderboardGap) or 120) then return false end
    local best = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("IntValue") or d:IsA("NumberValue") then
            local low = string.lower(d.Name)
            if string.find(low, "score", 1, true) or string.find(low, "leaderboard", 1, true) then
                local v = tonumber(d.Value) or 0
                if v > best then best = v end
            end
        end
    end
    local st = xSt("leaderboard")
    if best ~= st.best then
        st.best = best
        AUTO.LastReason = "排行榜检查：最高分 " .. best
        log("排行榜检查：当前最高分 " .. best)
        xStatAdd("排行榜", 1)
    end
    return best > 0
end

-- 注册
reg("AutoUseReviveItem", "自动复活道具", "生存", "bool", "倒下时自动使用复活道具")
reg("AutoRevivePromptScan", "复活提示扫描", "生存", "bool", "扫描并触发附近复活提示")
reg("AutoHealPriority", "治疗优先级", "补给", "bool", "优先治疗血量最低的目标")
reg("AutoSecondWind", "濒死护盾", "生存", "bool", "濒死时开启护盾")
reg("AutoPositionAnchor", "站位锚点", "战斗", "bool", "脱战偏离过远时回到锚点")
reg("AutoFocusTargetLock", "目标锁定", "战斗", "bool", "锁定目标一段时间不切换")
reg("AutoAttackGapFill", "攻击间隙填充", "战斗", "bool", "攻击间隙补一发")
reg("AutoReloadCycle", "换弹循环", "战斗", "bool", "弹药不足时循环换弹")
reg("AutoWeaponSwapLow", "低耐久换武器", "装备", "bool", "耐久过低时换备用武器")
reg("AutoDodgeRoll", "翻滚闪避", "战斗", "bool", "近距离威胁时翻滚拉开")
reg("AutoBlockGuard", "格挡保护", "战斗", "bool", "低血时举盾格挡")
reg("AutoCoverUse", "掩体利用", "战斗", "bool", "低血时贴近掩体")
reg("AutoSuppressiveFire", "压制射击", "战斗", "bool", "多目标时持续开火")
reg("AutoSnipeFar", "远程点杀", "战斗", "bool", "优先点杀远处目标")
reg("AutoMeleeClose", "近战贴脸", "战斗", "bool", "近战武器贴脸输出")
reg("AutoEliteFocus", "精英优先", "战斗", "bool", "优先处理血量最高的精英")
reg("AutoAddClear", "小怪清理", "战斗", "bool", "优先清理残血小怪")
reg("AutoRangedKite", "远程风筝", "战斗", "bool", "保持远程安全距离")
reg("AutoSummonAssist", "召唤协同", "战斗", "bool", "自动召唤协助作战")
reg("AutoTurretPlace", "放置炮台", "战斗", "bool", "自动部署炮台")
reg("AutoTrapPlace", "放置陷阱", "战斗", "bool", "自动布置陷阱")
reg("AutoConsumeCooldown", "消耗品冷却", "补给", "bool", "冷却就绪的消耗品自动使用")
reg("AutoBuffStack", "增益叠加", "补给", "bool", "按列表叠加增益")
reg("AutoDebuffApply", "施加减益", "战斗", "bool", "给目标施加减益")
reg("AutoStatusClear", "清除负面", "生存", "bool", "检测并清除负面状态")
reg("AutoShieldBreak", "破盾", "战斗", "bool", "优先破除目标护盾")
reg("AutoBossMechanic", "Boss机制应对", "战斗", "bool", "按 Boss 阶段自动撤离")
reg("AutoWavePrep", "波次准备", "任务", "bool", "开局前补给状态与弹药")
reg("AutoIntermissionLoot", "间歇拾取", "拾取", "bool", "波次间隙拾取掉落")
reg("AutoSafeSpotRotate", "安全点轮换", "生存", "bool", "低血时轮换安全点")
reg("AutoStamina", "体力管理", "移动", "bool", "体力过低时降速")
reg("AutoFoodBuff", "食物增益", "补给", "bool", "定时使用食物增益")
reg("AutoDailyLogin", "每日登录", "任务", "bool", "每天自动领取登录奖励")
reg("AutoFriendGift", "好友赠礼", "社交", "bool", "定时给好友赠送礼物")
reg("AutoGuildCheckIn", "公会签到", "社交", "bool", "自动完成公会签到")
reg("AutoLeaderboardCheck", "排行榜检查", "统计", "bool", "记录排行榜分数变化")

MODULE_RUNNERS.AutoUseReviveItem = autoUseReviveItem
MODULE_RUNNERS.AutoRevivePromptScan = autoRevivePromptScan
MODULE_RUNNERS.AutoHealPriority = autoHealPriority
MODULE_RUNNERS.AutoSecondWind = autoSecondWind
MODULE_RUNNERS.AutoPositionAnchor = autoPositionAnchor
MODULE_RUNNERS.AutoFocusTargetLock = autoFocusTargetLock
MODULE_RUNNERS.AutoAttackGapFill = autoAttackGapFill
MODULE_RUNNERS.AutoReloadCycle = autoReloadCycle
MODULE_RUNNERS.AutoWeaponSwapLow = autoWeaponSwapLow
MODULE_RUNNERS.AutoDodgeRoll = autoDodgeRoll
MODULE_RUNNERS.AutoBlockGuard = autoBlockGuard
MODULE_RUNNERS.AutoCoverUse = autoCoverUse
MODULE_RUNNERS.AutoSuppressiveFire = autoSuppressiveFire
MODULE_RUNNERS.AutoSnipeFar = autoSnipeFar
MODULE_RUNNERS.AutoMeleeClose = autoMeleeClose
MODULE_RUNNERS.AutoEliteFocus = autoEliteFocus
MODULE_RUNNERS.AutoAddClear = autoAddClear
MODULE_RUNNERS.AutoRangedKite = autoRangedKite
MODULE_RUNNERS.AutoSummonAssist = autoSummonAssist
MODULE_RUNNERS.AutoTurretPlace = autoTurretPlace
MODULE_RUNNERS.AutoTrapPlace = autoTrapPlace
MODULE_RUNNERS.AutoConsumeCooldown = autoConsumeCooldown
MODULE_RUNNERS.AutoBuffStack = autoBuffStack
MODULE_RUNNERS.AutoDebuffApply = autoDebuffApply
MODULE_RUNNERS.AutoStatusClear = autoStatusClear
MODULE_RUNNERS.AutoShieldBreak = autoShieldBreak
MODULE_RUNNERS.AutoBossMechanic = autoBossMechanic
MODULE_RUNNERS.AutoWavePrep = autoWavePrep
MODULE_RUNNERS.AutoIntermissionLoot = autoIntermissionLoot
MODULE_RUNNERS.AutoSafeSpotRotate = autoSafeSpotRotate
MODULE_RUNNERS.AutoStamina = autoStamina
MODULE_RUNNERS.AutoFoodBuff = autoFoodBuff
MODULE_RUNNERS.AutoDailyLogin = autoDailyLogin
MODULE_RUNNERS.AutoFriendGift = autoFriendGift
MODULE_RUNNERS.AutoGuildCheckIn = autoGuildCheckIn
MODULE_RUNNERS.AutoLeaderboardCheck = autoLeaderboardCheck

for _, k in ipairs({
    "AutoUseReviveItem", "AutoRevivePromptScan", "AutoHealPriority", "AutoSecondWind",
    "AutoFocusTargetLock", "AutoAttackGapFill", "AutoReloadCycle", "AutoWeaponSwapLow",
    "AutoDodgeRoll", "AutoBlockGuard", "AutoCoverUse", "AutoSuppressiveFire", "AutoSnipeFar",
    "AutoMeleeClose", "AutoEliteFocus", "AutoAddClear", "AutoRangedKite", "AutoSummonAssist",
    "AutoTurretPlace", "AutoTrapPlace", "AutoConsumeCooldown", "AutoBuffStack", "AutoDebuffApply",
    "AutoStatusClear", "AutoShieldBreak", "AutoBossMechanic", "AutoIntermissionLoot",
    "AutoSafeSpotRotate", "AutoStamina", "AutoFoodBuff",
}) do
    table.insert(COMBAT_QUEUE, k)
end

for _, k in ipairs({
    "AutoPositionAnchor", "AutoWavePrep", "AutoDailyLogin", "AutoFriendGift",
    "AutoGuildCheckIn", "AutoLeaderboardCheck",
}) do
    table.insert(LOBBY_QUEUE, k)
end

----------------------------------------------------------------
-- ============================================================
-- 扩展自动化 XI：天文币 / 自动农场 / 自动刷怪 / 一键准备
-- ============================================================
----------------------------------------------------------------
local X11_DEFAULTS = {
    AutoAstroFarm = false, AstroFarmRadius = 260, AstroFarmGap = 1.5,
    AutoAstroCollect = false, AstroCollectRange = 140, AstroCollectGap = 2,
    AutoAstroInsert = false, AstroInsertGap = 3,
    AutoAstroTech = false, AstroTechGap = 20,
    AutoAstroScan = false, AstroScanGap = 15,
    AutoAstroReport = false, AstroReportGap = 120,
    AutoOneClickReady = false, OneClickGap = 1.2,
    AutoFarmAssist = false, FarmAssistGap = 1,
}
for k, v in pairs(X11_DEFAULTS) do
    if AUTO[k] == nil then AUTO[k] = v end
end

----------------------------------------------------------------
-- 天文零件名单（直接从游戏 AstroResearch 模块读取）
----------------------------------------------------------------
function xAstroPartNames()
    local st = xSt("astroparts")
    local now = os.clock()
    if st.names and now - (st.t or 0) < 60 then return st.names end
    local names = {}
    local mod = RS:FindFirstChild("AstroResearch")
    if mod then
        local ok, res = pcall(require, mod)
        if ok and type(res) == "table" and type(res.Parts) == "table" then
            for _, p in ipairs(res.Parts) do
                if type(p) == "table" and p.Item then
                    table.insert(names, p.Item)
                end
            end
        end
    end
    st.names = names
    st.t = now
    return names
end

function xIsAstroPartName(name)
    if not name or name == "" then return false end
    local low = string.lower(name)
    if string.find(low, "astro", 1, true) then return true end
    for _, part in ipairs(xAstroPartNames()) do
        if name == part then return true end
    end
    return false
end

function xAstroTokenCount()
    local v = player:GetAttribute("Astro Token")
    if v == nil then v = player:GetAttribute("AstroToken") end
    if v == nil then
        local ls = player:FindFirstChild("leaderstats")
        local node = ls and (ls:FindFirstChild("Astro Token") or ls:FindFirstChild("AstroToken")
            or ls:FindFirstChild("Token"))
        if node then v = node.Value end
    end
    return tonumber(v)
end

----------------------------------------------------------------
-- 196. 自动天文农场（切模式 + 开战斗 + 锁天文怪）
----------------------------------------------------------------
function autoAstroFarm()
    if not AUTO.AutoAstroFarm then return false end
    if AUTO.Paused then return false end
    if not every("x_astrofarm", tonumber(AUTO.AstroFarmGap) or 1.5) then return false end
    if not inMatch() then
        AUTO.FarmMode = "Astro Holdout Mode"
        if AUTO.GameMode ~= "Astro" and AUTO.GameMode ~= "AstroV2" then
            AUTO.GameMode = "Astro"
        end
        return false
    end
    AUTO.FarmMode = "Astro Holdout Mode"
    AUTO.AutoFarm = true
    AUTO.AutoFight = true
    AUTO.AutoAim = true
    AUTO.AutoSkill = true
    local radius = tonumber(AUTO.AstroFarmRadius) or 260
    local enemy, dist = nearestEnemy(radius)
    if enemy then
        AUTO.Target = enemy.Name
        AUTO.LastReason = string.format("天文农场：锁定 %s（%.0f 格）", enemy.Name, dist or 0)
        return true
    end
    AUTO.LastReason = "天文农场：等待天文怪刷新"
    return false
end

----------------------------------------------------------------
-- 197. 自动拾取天文零件
----------------------------------------------------------------
function autoAstroCollect()
    if not AUTO.AutoAstroCollect then return false end
    if AUTO.Paused then return false end
    if not every("x_astrocollect", tonumber(AUTO.AstroCollectGap) or 2) then return false end
    local base = xRoot2()
    if not base then return false end
    local range = tonumber(AUTO.AstroCollectRange) or 140
    local best, bestD = nil, range
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") or d:IsA("BasePart") then
            if xIsAstroPartName(d.Name) then
                local p = xPosOf(d)
                if p then
                    local dist = (p - base.Position).Magnitude
                    if dist < bestD then
                        best, bestD = p, dist
                    end
                end
            end
        end
    end
    if best then
        local ok = xTp(best + Vector3.new(0, 3, 0))
        if ok then
            AUTO.LastReason = string.format("天文零件：拾取 %.0f 格", bestD)
            xStatAdd("天文零件", 1)
        end
        return ok
    end
    for _, p in ipairs(xNearPrompts(20)) do
        if xIsAstroPartName(p.Name) then
            if xUsePrompt(p) then
                xStatAdd("天文零件", 1)
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------
-- 198. 自动上交天文零件换币
----------------------------------------------------------------
function autoAstroInsert()
    if not AUTO.AutoAstroInsert then return false end
    if AUTO.Paused then return false end
    if not every("x_astroinsert", tonumber(AUTO.AstroInsertGap) or 3) then return false end
    local items = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and xIsAstroPartName(t.Name) then
                table.insert(items, t.Name)
            end
        end
    end
    local c = myChar()
    if c then
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and xIsAstroPartName(t.Name) then
                table.insert(items, t.Name)
            end
        end
    end
    if #items == 0 then return false end
    local okCount = 0
    for _, name in ipairs(items) do
        if xFire("CraftToken", name, "Insert") then
            okCount = okCount + 1
        end
    end
    if okCount > 0 then
        AUTO.LastReason = "天文研究：已上交 " .. okCount .. " 个零件"
        log("天文研究：已上交 " .. okCount .. " 个零件，累计换取天文币")
        xStatAdd("天文上交", okCount)
    end
    return okCount > 0
end

----------------------------------------------------------------
-- 199. 自动升级天文科技
----------------------------------------------------------------
function autoAstroTech()
    if not AUTO.AutoAstroTech then return false end
    if AUTO.Paused then return false end
    if not every("x_astrotech", tonumber(AUTO.AstroTechGap) or 20) then return false end
    local upgraded = 0
    for _, level in ipairs({ "Level1", "Level2", "Level3" }) do
        if xFire("AstroTechUpgrade", level) then
            upgraded = upgraded + 1
        end
    end
    if upgraded > 0 then
        AUTO.LastReason = "天文科技：已请求升级"
        log("天文科技：已请求升级 " .. upgraded .. " 项")
        xStatAdd("天文科技", upgraded)
    end
    return upgraded > 0
end

----------------------------------------------------------------
-- 200. 扫描天文研究进度
----------------------------------------------------------------
function autoAstroScan()
    if not AUTO.AutoAstroScan then return false end
    if AUTO.Paused then return false end
    if not every("x_astroscan", tonumber(AUTO.AstroScanGap) or 15) then return false end
    local mod = RS:FindFirstChild("AstroResearch")
    local progressName = "AstroTradeSystem"
    if mod then
        local ok, res = pcall(require, mod)
        if ok and type(res) == "table" and type(res.ProgressValue) == "string" then
            progressName = res.ProgressValue
        end
    end
    local value = player:GetAttribute(progressName)
    if value == nil then
        local ok, v = pcall(function() return player:GetAttribute(progressName) end)
        if ok then value = v end
    end
    local st = xSt("astroscan")
    if value ~= nil and value ~= st.value then
        st.value = value
        AUTO.LastReason = "天文研究：进度 " .. tostring(value)
        log("天文研究：当前进度 " .. tostring(value))
        xStatAdd("天文扫描", 1)
    end
    return value ~= nil
end

----------------------------------------------------------------
-- 201. 天文币汇报
----------------------------------------------------------------
function autoAstroReport()
    if not AUTO.AutoAstroReport then return false end
    if AUTO.Paused then return false end
    if not every("x_astroreport", tonumber(AUTO.AstroReportGap) or 120) then return false end
    local tokens = xAstroTokenCount()
    if tokens == nil then return false end
    local st = xSt("astroreport")
    if st.last == tokens then return false end
    st.last = tokens
    AUTO.LastReason = "天文币：" .. xFmt(tokens)
    log("天文币：当前持有 " .. xFmt(tokens))
    xStatAdd("天文汇报", 1)
    return true
end

----------------------------------------------------------------
-- 202. 一键准备（投票 → 准备 → 开局）
----------------------------------------------------------------
function autoOneClickReady()
    if not AUTO.AutoOneClickReady then return false end
    if AUTO.Paused then return false end
    if not every("x_oneclick", tonumber(AUTO.OneClickGap) or 1.2) then return false end
    if inMatch() then return false end
    local did = false
    if autoVote() then did = true end
    if autoReady() then did = true end
    if autoStartSolo() then did = true end
    if did then
        AUTO.LastReason = "一键准备：投票 / 准备 / 开局已执行"
        xStatAdd("一键准备", 1)
    end
    return did
end

----------------------------------------------------------------
-- 203. 自动刷怪辅助（让农场保持锁定与输出）
----------------------------------------------------------------
function autoFarmAssist()
    if not AUTO.AutoFarmAssist then return false end
    if AUTO.Paused then return false end
    if not every("x_farmassist", tonumber(AUTO.FarmAssistGap) or 1) then return false end
    if not AUTO.AutoFarm then return false end
    AUTO.AutoFight = true
    AUTO.AutoAim = true
    local enemy, dist = nearestEnemy(tonumber(AUTO.Range) or 200)
    if enemy then
        AUTO.Target = enemy.Name
        AUTO.LastReason = string.format("刷怪辅助：锁定 %s（%.0f 格）", enemy.Name, dist or 0)
        return true
    end
    return false
end

reg("AutoAstroFarm", "自动刷天文币", "天文", "bool", "切到天文模式并自动刷天文怪")
reg("AutoAstroCollect", "拾取天文零件", "天文", "bool", "自动传送拾取天文零件")
reg("AutoAstroInsert", "自动上交零件", "天文", "bool", "把背包里的天文零件上交研究换币")
reg("AutoAstroTech", "自动天文科技", "天文", "bool", "自动升级天文科技树")
reg("AutoAstroScan", "天文进度扫描", "天文", "bool", "定时读取天文研究进度")
reg("AutoAstroReport", "天文币汇报", "天文", "bool", "定时汇报天文币数量")
reg("AutoOneClickReady", "一键准备", "流程", "bool", "投票 + 准备 + 开局一次完成")
reg("AutoFarmAssist", "自动刷怪辅助", "战斗", "bool", "让自动农场保持锁定与输出")

MODULE_RUNNERS.AutoAstroFarm = autoAstroFarm
MODULE_RUNNERS.AutoAstroCollect = autoAstroCollect
MODULE_RUNNERS.AutoAstroInsert = autoAstroInsert
MODULE_RUNNERS.AutoAstroTech = autoAstroTech
MODULE_RUNNERS.AutoAstroScan = autoAstroScan
MODULE_RUNNERS.AutoAstroReport = autoAstroReport
MODULE_RUNNERS.AutoOneClickReady = autoOneClickReady
MODULE_RUNNERS.AutoFarmAssist = autoFarmAssist

for _, k in ipairs({
    "AutoAstroFarm", "AutoAstroCollect", "AutoAstroInsert", "AutoAstroTech",
    "AutoFarmAssist",
}) do
    table.insert(COMBAT_QUEUE, k)
end

for _, k in ipairs({
    "AutoAstroScan", "AutoAstroReport", "AutoOneClickReady", "AutoAstroFarm",
}) do
    table.insert(LOBBY_QUEUE, k)
end


-- 第六批：高级战斗 / 预判 / 区域规避 / 巡逻
reg("AutoAimLead", "预判瞄准", "战斗", "bool", "按目标速度提前量瞄准")
reg("AutoDodgeZone", "区域规避", "战斗", "bool", "站在危险区域外输出")
reg("AutoInterrupt", "打断施法", "战斗", "bool", "目标读条时优先打断")
reg("AutoTauntBoss", "Boss嘲讽", "战斗", "bool", "Boss 目标转移时拉回仇恨")
reg("AutoTeamBuff", "团队增益", "战斗", "bool", "定时给队友上增益")
reg("AutoShieldAlly", "队友护盾", "战斗", "bool", "队友低血时套盾")
reg("AutoLastStand", "背水一战", "战斗", "bool", "残血时提升输出并停止后撤")
reg("AutoThreatTable", "仇恨表", "战斗", "bool", "记录并排序当前仇恨目标")
reg("AutoTerrainAdapt", "地形适应", "战斗", "bool", "按地形调整站位高度")
reg("AutoAntiFling", "防甩飞", "战斗", "bool", "被高速甩动时锁回原位")
reg("AutoPatrol", "自动巡逻", "战斗", "bool", "无敌人时按路线巡逻")
reg("AutoReturnHome", "自动归位", "战斗", "bool", "偏离出生点过远时返回")
reg("AutoGroupUp", "自动集合", "战斗", "bool", "向队伍中心靠拢")
reg("AutoKillConfirm", "击杀确认", "战斗", "bool", "记录击杀确认与掉落")
reg("AutoCombatLog", "战斗日志", "战斗", "bool", "记录战斗关键事件")
reg("AutoRespawnWait", "重生等待", "战斗", "bool", "重生期间暂停其它动作")
reg("AutoSelfRevive", "自我复活", "战斗", "bool", "有复活道具时自动使用")
-- 第七批：装备 / 养成 / 活动 / 社交
reg("AutoAmmoBuy", "自动买弹", "装备", "bool", "弹药不足时补购")
reg("AutoWeaponDurability", "武器耐久", "装备", "bool", "耐久低时修理或更换")
reg("AutoPetSummon", "自动召唤宠物", "养成", "bool", "定时召唤并切换宠物")
reg("AutoVehicleUse", "自动载具", "养成", "bool", "需要时召唤并使用载具")
reg("AutoStatAllocation", "属性加点", "养成", "bool", "有属性点时自动分配")
reg("AutoLevelSpend", "等级加点", "养成", "bool", "升级后自动加点")
reg("AutoBossPhase", "Boss阶段", "战斗", "bool", "按 Boss 阶段切换策略")
reg("AutoEnemyAlert", "敌人预警", "战斗", "bool", "高危敌人靠近时提醒")
reg("AutoQuestAutoEquip", "任务自动装备", "任务", "bool", "按任务要求自动换装")
reg("AutoSkillPointScan", "技能点扫描", "科技", "bool", "扫描可用技能点并记录")
reg("AutoTitleAutoEquip", "自动称号", "装备", "bool", "自动佩戴收益最高的称号")
reg("AutoCharacterRotate", "自动换角色", "装备", "bool", "按配置轮换角色")
reg("AutoSkinEquip", "自动皮肤", "装备", "bool", "自动佩戴皮肤")
reg("AutoAccessoryEquip", "自动饰品", "装备", "bool", "自动佩戴饰品")
reg("AutoEmoteUse", "自动动作", "社交", "bool", "定时播放表情动作")
reg("AutoSprint", "自动冲刺", "移动", "bool", "赶路时保持冲刺")
reg("AutoCrouchDodge", "下蹲闪避", "战斗", "bool", "高危弹幕时下蹲减伤")
reg("AutoSwimGuard", "游泳保护", "生存", "bool", "水中低氧时上浮")
reg("AutoSpeedSync", "速度同步", "移动", "bool", "按场景同步移动速度")
reg("AutoJumpBoost", "跳跃强化", "移动", "bool", "按需提升跳跃高度")
reg("AutoToolRepair", "工具修理", "装备", "bool", "工具耐久低时修理")
reg("AutoInventoryWeight", "负重管理", "经济", "bool", "超重时清理背包")
reg("AutoCraftItem", "自动合成", "养成", "bool", "材料足够时合成")
reg("AutoUpgradeItem", "自动升级", "养成", "bool", "自动升级装备")
reg("AutoTradeRequest", "自动交易", "社交", "bool", "按名单发起交易")
reg("AutoMailClaim", "领取邮件", "社交", "bool", "自动领取邮件附件")
reg("AutoAchievementClaim", "领取成就", "任务", "bool", "自动领取成就奖励")
reg("AutoSeasonPassClaim", "领取通行证", "任务", "bool", "自动领取赛季奖励")
reg("AutoCodeRedeemLoop", "兑换码循环", "社交", "bool", "定时尝试兑换码")
reg("AutoDailyShopRefresh", "每日商店刷新", "经济", "bool", "每日刷新并购买")
-- 第八批：续航 / 掉落 / 场景机关 / 活动补充
reg("AutoShieldRegenWait", "护盾回充", "生存", "bool", "等待护盾自然回充")
reg("AutoOutOfCombatRegen", "脱战回复", "生存", "bool", "脱战一段时间后回血")
reg("AutoLootPriority", "掉落优先级", "拾取", "bool", "按价值优先拾取掉落")
reg("AutoOpenAllPrompts", "全开交互", "拾取", "bool", "自动触发附近所有可交互提示")
reg("AutoDoorOpen", "自动开门", "场景", "bool", "靠近门时自动开启")
reg("AutoGeneratorRepair", "自动修机", "场景", "bool", "自动修理发电机类机关")
reg("AutoRescueNearby", "就近救援", "生存", "bool", "优先救援最近倒地队友")
reg("AutoUseBuffConsumable", "自动用增益", "补给", "bool", "定时使用增益消耗品")
reg("AutoDropJunk", "清理杂物", "经济", "bool", "定时丢弃低价值物品")
reg("AutoEquipBestArmor", "最优护甲", "装备", "bool", "自动穿防御最高的护甲")
reg("AutoSellDuplicates", "出售重复", "经济", "bool", "自动出售重复道具")
reg("AutoBuyLimited", "限购购买", "经济", "bool", "自动购买限时商品")
reg("AutoSkinGachaPlan", "皮肤扭蛋", "经济", "bool", "按预算抽取皮肤")
reg("AutoSpinWheel", "自动转盘", "活动", "bool", "免费次数转盘")
reg("AutoDailyMissionClaim", "领取日常任务", "任务", "bool", "自动领取日常任务奖励")
reg("AutoRankedQueue", "排位排队", "活动", "bool", "自动进入排位队列")
reg("AutoWishlistScan", "心愿单扫描", "经济", "bool", "扫描心愿单商品价格")
reg("AutoAmmoPickup", "拾取弹药", "拾取", "bool", "自动拾取弹药箱")
reg("AutoCraftQueue", "合成队列", "养成", "bool", "按队列依次合成")
reg("AutoPetFeed", "自动喂宠", "养成", "bool", "定时喂养宠物")

-- 运行表
MODULE_RUNNERS.AutoAimLead = autoAimLead
MODULE_RUNNERS.AutoDodgeZone = autoDodgeZone
MODULE_RUNNERS.AutoInterrupt = autoInterrupt
MODULE_RUNNERS.AutoTauntBoss = autoTauntBoss
MODULE_RUNNERS.AutoTeamBuff = autoTeamBuff
MODULE_RUNNERS.AutoShieldAlly = autoShieldAlly
MODULE_RUNNERS.AutoLastStand = autoLastStand
MODULE_RUNNERS.AutoThreatTable = autoThreatTable
MODULE_RUNNERS.AutoTerrainAdapt = autoTerrainAdapt
MODULE_RUNNERS.AutoAntiFling = autoAntiFling
MODULE_RUNNERS.AutoPatrol = autoPatrol
MODULE_RUNNERS.AutoReturnHome = autoReturnHome
MODULE_RUNNERS.AutoGroupUp = autoGroupUp
MODULE_RUNNERS.AutoKillConfirm = autoKillConfirm
MODULE_RUNNERS.AutoCombatLog = autoCombatLog
MODULE_RUNNERS.AutoRespawnWait = autoRespawnWait
MODULE_RUNNERS.AutoSelfRevive = autoSelfRevive
MODULE_RUNNERS.AutoAmmoBuy = autoAmmoBuy
MODULE_RUNNERS.AutoWeaponDurability = autoWeaponDurability
MODULE_RUNNERS.AutoPetSummon = autoPetSummon
MODULE_RUNNERS.AutoVehicleUse = autoVehicleUse
MODULE_RUNNERS.AutoStatAllocation = autoStatAllocation
MODULE_RUNNERS.AutoLevelSpend = autoLevelSpend
MODULE_RUNNERS.AutoBossPhase = autoBossPhase
MODULE_RUNNERS.AutoEnemyAlert = autoEnemyAlert
MODULE_RUNNERS.AutoQuestAutoEquip = autoQuestAutoEquip
MODULE_RUNNERS.AutoSkillPointScan = autoSkillPointScan
MODULE_RUNNERS.AutoTitleAutoEquip = autoTitleAutoEquip
MODULE_RUNNERS.AutoCharacterRotate = autoCharacterRotate
MODULE_RUNNERS.AutoSkinEquip = autoSkinEquip
MODULE_RUNNERS.AutoAccessoryEquip = autoAccessoryEquip
MODULE_RUNNERS.AutoEmoteUse = autoEmoteUse
MODULE_RUNNERS.AutoSprint = autoSprint
MODULE_RUNNERS.AutoCrouchDodge = autoCrouchDodge
MODULE_RUNNERS.AutoSwimGuard = autoSwimGuard
MODULE_RUNNERS.AutoSpeedSync = autoSpeedSync
MODULE_RUNNERS.AutoJumpBoost = autoJumpBoost
MODULE_RUNNERS.AutoToolRepair = autoToolRepair
MODULE_RUNNERS.AutoInventoryWeight = autoInventoryWeight
MODULE_RUNNERS.AutoCraftItem = autoCraftItem
MODULE_RUNNERS.AutoUpgradeItem = autoUpgradeItem
MODULE_RUNNERS.AutoTradeRequest = autoTradeRequest
MODULE_RUNNERS.AutoMailClaim = autoMailClaim
MODULE_RUNNERS.AutoAchievementClaim = autoAchievementClaim
MODULE_RUNNERS.AutoSeasonPassClaim = autoSeasonPassClaim
MODULE_RUNNERS.AutoCodeRedeemLoop = autoCodeRedeemLoop
MODULE_RUNNERS.AutoDailyShopRefresh = autoDailyShopRefresh
MODULE_RUNNERS.AutoShieldRegenWait = autoShieldRegenWait
MODULE_RUNNERS.AutoOutOfCombatRegen = autoOutOfCombatRegen
MODULE_RUNNERS.AutoLootPriority = autoLootPriority
MODULE_RUNNERS.AutoOpenAllPrompts = autoOpenAllPrompts
MODULE_RUNNERS.AutoDoorOpen = autoDoorOpen
MODULE_RUNNERS.AutoGeneratorRepair = autoGeneratorRepair
MODULE_RUNNERS.AutoRescueNearby = autoRescueNearby
MODULE_RUNNERS.AutoUseBuffConsumable = autoUseBuffConsumable
MODULE_RUNNERS.AutoDropJunk = autoDropJunk
MODULE_RUNNERS.AutoEquipBestArmor = autoEquipBestArmor
MODULE_RUNNERS.AutoSellDuplicates = autoSellDuplicates
MODULE_RUNNERS.AutoBuyLimited = autoBuyLimited
MODULE_RUNNERS.AutoSkinGachaPlan = autoSkinGachaPlan
MODULE_RUNNERS.AutoSpinWheel = autoSpinWheel
MODULE_RUNNERS.AutoDailyMissionClaim = autoDailyMissionClaim
MODULE_RUNNERS.AutoRankedQueue = autoRankedQueue
MODULE_RUNNERS.AutoWishlistScan = autoWishlistScan
MODULE_RUNNERS.AutoAmmoPickup = autoAmmoPickup
MODULE_RUNNERS.AutoCraftQueue = autoCraftQueue
MODULE_RUNNERS.AutoPetFeed = autoPetFeed

-- 队列
local EX2_COMBAT = {
    "AutoAimLead", "AutoDodgeZone", "AutoInterrupt", "AutoTauntBoss", "AutoTeamBuff",
    "AutoShieldAlly", "AutoLastStand", "AutoThreatTable", "AutoTerrainAdapt", "AutoAntiFling",
    "AutoPatrol", "AutoReturnHome", "AutoGroupUp", "AutoKillConfirm", "AutoCombatLog",
    "AutoRespawnWait", "AutoSelfRevive", "AutoBossPhase", "AutoEnemyAlert", "AutoCrouchDodge",
    "AutoSwimGuard", "AutoSpeedSync", "AutoSprint", "AutoJumpBoost", "AutoWeaponDurability",
    "AutoLootPriority", "AutoDoorOpen", "AutoGeneratorRepair", "AutoRescueNearby",
    "AutoShieldRegenWait", "AutoOutOfCombatRegen", "AutoUseBuffConsumable", "AutoOpenAllPrompts",
    "AutoAmmoPickup",
}
local EX2_LOBBY = {
    "AutoAmmoBuy", "AutoPetSummon", "AutoVehicleUse", "AutoStatAllocation", "AutoLevelSpend",
    "AutoQuestAutoEquip", "AutoSkillPointScan", "AutoTitleAutoEquip", "AutoCharacterRotate",
    "AutoSkinEquip", "AutoAccessoryEquip", "AutoEmoteUse", "AutoToolRepair", "AutoInventoryWeight",
    "AutoCraftItem", "AutoUpgradeItem", "AutoTradeRequest", "AutoMailClaim",
    "AutoAchievementClaim", "AutoSeasonPassClaim", "AutoCodeRedeemLoop", "AutoDailyShopRefresh",
    "AutoDropJunk", "AutoEquipBestArmor", "AutoSellDuplicates", "AutoBuyLimited",
    "AutoSkinGachaPlan", "AutoSpinWheel", "AutoDailyMissionClaim", "AutoRankedQueue",
    "AutoWishlistScan", "AutoCraftQueue", "AutoPetFeed",
}
for _, k in ipairs(EX2_COMBAT) do table.insert(COMBAT_QUEUE, k) end
for _, k in ipairs(EX2_LOBBY) do table.insert(LOBBY_QUEUE, k) end

----------------------------------------------------------------
-- 自动补注册：AutoXxx 开关 → autoXxx 函数
-- 1) 没注册过执行入口的补进 MODULE_RUNNERS
-- 2) 不在任何队列里的补进 ALWAYS_QUEUE（否则开关打开也不会被执行）
----------------------------------------------------------------
do
    local seen = {}
    for _, q in ipairs({ COMBAT_QUEUE, LOBBY_QUEUE, ALWAYS_QUEUE }) do
        for _, k in ipairs(q) do seen[k] = true end
    end
    local sets = {
        ENGINE_DEFAULTS, X_DEFAULTS, X2_DEFAULTS, X3_DEFAULTS, X4_DEFAULTS,
        X5_DEFAULTS, X6_DEFAULTS, X7_DEFAULTS, X8_DEFAULTS, X10_DEFAULTS, X11_DEFAULTS,
    }
    local genv = (getgenv and getgenv()) or _G or {}
    local added, queued = 0, 0
    for _, set in ipairs(sets) do
        for key, val in pairs(set) do
            if type(val) == "boolean" and string.sub(key, 1, 4) == "Auto" then
                local fn = MODULE_RUNNERS[key] or genv["auto" .. string.sub(key, 5)]
                if type(fn) == "function" then
                    if MODULE_RUNNERS[key] == nil then
                        MODULE_RUNNERS[key] = fn
                        added = added + 1
                    end
                    if not seen[key] then
                        seen[key] = true
                        table.insert(ALWAYS_QUEUE, key)
                        queued = queued + 1
                    end
                end
            end
        end
    end
    if added > 0 or queued > 0 then
        log(string.format("模块补注册：新增入口 %d 个，补入常驻队列 %d 个", added, queued))
    end
end

----------------------------------------------------------------
-- 全部模块：把注册表里的模块全部生成菜单开关
-- （主界面只放了常用项，这里保证每个模块都能直接开关）
----------------------------------------------------------------
pcall(function()
    if not Window or not Window.Tab then return end
    local AllTab = Window:Tab({ Title = "全部模块", Icon = "list" })
    local groups, order = {}, {}
    for _, m in ipairs(MODULE_REGISTRY) do
        if m.kind == "bool" and m.key and AUTO[m.key] ~= nil then
            local g = m.group or "其他"
            if not groups[g] then
                groups[g] = {}
                table.insert(order, g)
            end
            table.insert(groups[g], m)
        end
    end
    local iconOf = {
        ["战斗"] = "swords", ["补给"] = "heart", ["生存"] = "box", ["技能"] = "zap",
        ["科技"] = "trending-up", ["任务"] = "clipboard-check", ["经济"] = "coins",
        ["大厅"] = "house", ["互动"] = "hand", ["收集"] = "gift", ["移动"] = "move",
        ["系统"] = "settings", ["核心"] = "sparkles", ["装备"] = "package",
        ["拾取"] = "hand", ["社交"] = "user", ["统计"] = "activity",
        ["天文"] = "rocket", ["流程"] = "list", ["养成"] = "arrow-up",
        ["场景"] = "house", ["活动"] = "ticket",
    }
    local total = 0
    for _, g in ipairs(order) do
        local list = groups[g]
        local sec = AllTab:Section({ Title = g .. "（" .. #list .. "）", Icon = iconOf[g] or "list" })
        for _, m in ipairs(list) do
            total = total + 1
            sec:Toggle({
                Title = m.title,
                Desc  = (m.desc ~= "" and m.desc or m.key) .. "（" .. m.key .. "）",
                Value = AUTO[m.key] == true,
                Callback = function(v) AUTO[m.key] = v end,
            })
        end
    end
    log(string.format("全部模块页已生成：%d 个开关 / %d 组", total, #order))
end)

----------------------------------------------------------------
-- 天文币模式一（老版 Farm Astro Token）：贴图零件上下往返 + 计时器锁位
----------------------------------------------------------------
local ASTRO = {
    TOP_A = CFrame.new(-680, 167, 505),
    TOP_B = CFrame.new(495, 167, 505),
    LOW_A = CFrame.new(-680, -15, -555),
    LOW_B = CFrame.new(500, -15, -555),
    TIMER_TOP = CFrame.new(-23.3435822, 67, 0.341766357),
    TIMER_BOTTOM = CFrame.new(-23.3435822, 2, 0.341766357),
    TWEEN = 0.3,
    IMAGE = "rbxassetid://103789103251622",
}
local astroRunning = false
local astroPart = nil
local astroWaveArmed = false
local astroIgnoreUntil = 0
local astroLocks = false

function astroTimerValue()
    local waves = pg:FindFirstChild("WavesGui")
    local frame = waves and waves:FindFirstChild("Frame")
    local label = frame and frame:FindFirstChild("Timer")
    if not label then return nil end
    local nums = {}
    for n in string.gmatch(tostring(label.Text or ""), "%d+") do
        table.insert(nums, tonumber(n))
    end
    return nums[#nums]
end

function astroTimerEnding()
    if tick() < astroIgnoreUntil then return false end
    local v = astroTimerValue()
    if v and v > 10 then astroWaveArmed = true end
    return v ~= nil and v <= 5 and astroWaveArmed == true
end

function astroEnsurePart()
    if astroPart and astroPart.Parent then return astroPart end
    local part = Instance.new("Part")
    part.Name = "astrotoken_farm_part"
    part.Size = Vector3.new(4, 1, 4)
    part.Anchored = true
    part.CanCollide = true
    part.CanTouch = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Transparency = 1
    part.CFrame = ASTRO.TOP_A
    part.Parent = workspace
    for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
        local d = Instance.new("Decal")
        d.Name = "astro_token_image"
        d.Texture = ASTRO.IMAGE
        d.Face = face
        d.Parent = part
    end
    astroPart = part
    return part
end

function astroSnap()
    local c = myChar()
    local b = hrpOf(c)
    if not c or not b or not astroPart then return end
    local h = humOf(c)
    if h then
        h.Sit = false
        h.PlatformStand = false
        h.AutoRotate = true
    end
    pcall(function() c:PivotTo(astroPart.CFrame * CFrame.new(0, 4, 0)) end)
    pcall(function()
        b.AssemblyLinearVelocity = Vector3.zero
        b.AssemblyAngularVelocity = Vector3.zero
    end)
end

function astroTweenTo(cf)
    local part = astroPart
    if not part or not part.Parent then return false end
    local tw = TweenService:Create(part, TweenInfo.new(ASTRO.TWEEN, Enum.EasingStyle.Linear), { CFrame = cf })
    tw:Play()
    while AUTO.AutoAstroToken and not AUTO.Paused do
        if astroTimerEnding() then
            pcall(function() tw:Cancel() end)
            return "timer_end"
        end
        if tw.PlaybackState ~= Enum.PlaybackState.Playing then break end
        task.wait(0.05)
    end
    pcall(function() part.CFrame = cf end)
    return true
end

-- 倒计时到 5 秒：自杀重置 → 等复活 → 贴到计时器底部锁位
function astroRespawnToTimer()
    local c = myChar()
    local head = c and c:FindFirstChild("Head")
    if head then
        pcall(function() head:Destroy() end)
    end
    local start = tick()
    while AUTO.AutoAstroToken and tick() - start < 10 do
        local ch = myChar()
        local h = humOf(ch)
        if ch and h and h.Health > 0 then break end
        task.wait(0.2)
    end
    task.wait(0.3)
    local ch = myChar()
    if ch then
        pcall(function() ch:PivotTo(ASTRO.TIMER_BOTTOM) end)
        local b = hrpOf(ch)
        if b then
            pcall(function()
                b.AssemblyLinearVelocity = Vector3.zero
                b.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    astroLocks = true
end

function astroWaitNextWave()
    local start = tick()
    while AUTO.AutoAstroToken and not AUTO.Paused do
        if astroLocks then
            local c = myChar()
            if c then pcall(function() c:PivotTo(ASTRO.TIMER_BOTTOM) end) end
        end
        local v = astroTimerValue()
        if tick() - start > 0.25 and v and v > 10 then break end
        task.wait(0.1)
    end
    astroLocks = false
    astroWaveArmed = false
    astroIgnoreUntil = tick() + 2
end

function astroLoop()
    if astroRunning then return end
    astroRunning = true
    task.spawn(function()
        while AUTO.AutoAstroToken and not AUTO.Paused do
            if not inMatch() then
                task.wait(1)
            elseif astroTimerEnding() then
                astroRespawnToTimer()
                astroWaitNextWave()
            else
                astroEnsurePart()
                pcall(function() astroPart.CFrame = ASTRO.TOP_A end)
                astroSnap()
                local r1 = astroTweenTo(ASTRO.TOP_B)
                if r1 == "timer_end" then
                    astroRespawnToTimer()
                    astroWaitNextWave()
                else
                    pcall(function() astroPart.CFrame = ASTRO.LOW_A end)
                    astroSnap()
                    local r2 = astroTweenTo(ASTRO.LOW_B)
                    if r2 == "timer_end" then
                        astroRespawnToTimer()
                        astroWaitNextWave()
                    end
                end
            end
            task.wait(0.05)
        end
        if astroPart then
            pcall(function() astroPart:Destroy() end)
            astroPart = nil
        end
        astroLocks = false
        astroWaveArmed = false
        astroRunning = false
    end)
end

----------------------------------------------------------------
-- 删除地图（老版 BoostFPS）：所有非 Living 部件隐形，可随时恢复
----------------------------------------------------------------
local boostActive = false
local boostConn = nil
local boostData = {}

function isLivingObj(obj)
    local cur = obj
    while cur and cur ~= workspace do
        if cur.Name == "Living" then return true end
        cur = cur.Parent
    end
    return false
end

function boostApply(obj)
    if not obj or not obj.Parent or isLivingObj(obj) then return end
    if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
        if not boostData[obj] then
            boostData[obj] = { Transparency = obj.Transparency, CastShadow = obj.CastShadow }
        end
        obj.Transparency = 1
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if not boostData[obj] then boostData[obj] = { Transparency = obj.Transparency } end
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        if not boostData[obj] then boostData[obj] = { Enabled = obj.Enabled } end
        pcall(function() obj.Enabled = false end)
    end
end

function setRemoveMap(on)
    if on == boostActive then return end
    boostActive = on
    if on then
        for _, obj in ipairs(workspace:GetDescendants()) do
            boostApply(obj)
        end
        boostConn = workspace.DescendantAdded:Connect(function(obj)
            if not boostActive then return end
            task.wait(0.05)
            boostApply(obj)
        end)
    else
        if boostConn then
            boostConn:Disconnect()
            boostConn = nil
        end
        for obj, d in pairs(boostData) do
            pcall(function()
                if obj and obj.Parent then
                    if d.Transparency ~= nil then obj.Transparency = d.Transparency end
                    if d.CastShadow ~= nil then obj.CastShadow = d.CastShadow end
                    if d.Enabled ~= nil then obj.Enabled = d.Enabled end
                end
            end)
        end
        boostData = {}
    end
end

----------------------------------------------------------------
-- 反 AFK（老版 StartAntiAFK）
----------------------------------------------------------------
local antiAfkConn = nil
function setAntiAFK(on)
    if on then
        if antiAfkConn then return end
        antiAfkConn = player.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            log("反 AFK：已模拟点击，避免被踢")
        end)
    else
        if antiAfkConn then
            antiAfkConn:Disconnect()
            antiAfkConn = nil
        end
    end
end

----------------------------------------------------------------
-- Astro 终局门（老版 DoAstroModeFinalDoor）
----------------------------------------------------------------
local astroDoorLast = 0
function astroFinalDoor()
    if AUTO.FarmMode ~= "Astro Holdout Mode" then return false end
    if #xEnemyList(math.huge, "astroDoor") > 0 then return false end
    if os.clock() - astroDoorLast < 2 then return false end
    astroDoorLast = os.clock()
    local c = myChar()
    if not c then return false end
    pcall(function() c:PivotTo(CFrame.new(-23.3435822, 67, 0.341766357)) end)
    task.wait(0.12)
    pcall(function() c:PivotTo(CFrame.new(-23.3435822, 3, 0.341766357)) end)
    AUTO.LastReason = "Astro：没有怪物，走终局门"
    return true
end

----------------------------------------------------------------
-- 天文币模式二（老版 TimerResetAndTeleport_AstroHoldout）
-- 坚守模式刷币时，倒计时到 5 秒自杀重置并贴计时器底部，等下一波
----------------------------------------------------------------
local astroHoldoutReset = false
function astroHoldoutCheck()
    if not AUTO.AutoAstroFarm or AUTO.FarmMode ~= "Astro Holdout Mode" then return false end
    if astroHoldoutReset then return false end
    if not astroTimerEnding() then return false end
    astroHoldoutReset = true
    task.spawn(function()
        local c = myChar()
        local head = c and c:FindFirstChild("Head")
        if head then pcall(function() head:Destroy() end) end
        task.wait(1.5)
        local ch = myChar()
        if ch then pcall(function() ch:PivotTo(ASTRO.TIMER_BOTTOM) end) end
        while AUTO.AutoAstroFarm and AUTO.FarmMode == "Astro Holdout Mode" and not AUTO.Paused do
            local v = astroTimerValue()
            if v and v > 10 then break end
            local cc = myChar()
            if cc then pcall(function() cc:PivotTo(ASTRO.TIMER_BOTTOM) end) end
            task.wait(0.2)
        end
        astroHoldoutReset = false
        astroWaveArmed = false
        astroIgnoreUntil = tick() + 2
    end)
    return true
end

-- 常驻小循环：删除地图开关 + 天文币模式一启动器 + 反 AFK + Astro 终局门
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function() setRemoveMap(AUTO.RemoveMap == true) end)
        pcall(function() setAntiAFK(AUTO.AntiAFK ~= false) end)
        if AUTO.AutoAstroToken and not astroRunning and not AUTO.Paused and inMatch() then
            astroLoop()
        end
        if AUTO.AutoAstroFinalDoor and not AUTO.Paused and inMatch() then
            pcall(astroFinalDoor)
        end
        if not AUTO.Paused and inMatch() then
            pcall(astroHoldoutCheck)
        end
    end
end)


----------------------------------------------------------------
-- 状态刷新
----------------------------------------------------------------
function refreshStatus()
    local me = myChar()
    local h = humOf(me)
    local hp = (h and math.max(0, math.floor(h.Health))) or 0
    local maxhp = (h and math.floor(h.MaxHealth)) or 0
    local wt = waveText()
    local rt = readyText()
    local mt = modeText()

    local text = string.format(
        "阶段:%s   模式:%s\n波次:%s   准备:%s\n生命:%d/%d   敌人:%d   技能:%d\n投票:%s   复活阈值:%d%%\n目标:%s\n%s%s",
        AUTO.Phase or "-",
        (mt ~= "" and mt or "—"),
        (wt ~= "" and wt or "—"),
        (rt ~= "" and rt or "—"),
        hp, maxhp, enemyCount(), skillCount(),
        AUTO.VoteState or "—",
        AUTO.ReviveHp,
        AUTO.Target or "—",
        AUTO.LastReason or "就绪",
        AUTO.Paused and "   [已暂停]" or ""
    )
    pcall(function() StatusPara:SetDesc(text) end)
    pcall(function()
        LogPara:SetDesc(#AUTO.Logs > 0 and table.concat(AUTO.Logs, "\n") or "暂无日志")
    end)
end

----------------------------------------------------------------
-- 工具按钮
----------------------------------------------------------------
AUTO.Actions.Refresh = refreshStatus

AUTO.Actions.TogglePause = function()
    AUTO.Paused = not AUTO.Paused
    if AUTO.Paused then
        stopFire()
        stopAim()
    end
    notify("自动挂机", AUTO.Paused and "已暂停" or "已继续")
    refreshStatus()
end

AUTO.Actions.Fight = function()
    task.spawn(function()
        local enemy, dist = nearestEnemy(AUTO.Range)
        if not enemy then
            notify("自动挂机", "附近没有敌人")
            return
        end
        local p = hrpOf(enemy)
        if not p then return end
        aimAt(p.Position + Vector3.new(0, 1.2, 0))
        ensureFire()
        local n = useSkills(p.Position)
        notify("自动挂机", string.format("已锁定 %s（%.0f 格），释放 %d 个技能", enemy.Name, dist or 0, n))
    end)
end

AUTO.Actions.Ready = function()
    task.spawn(function()
        autoReady()
        refreshStatus()
        notify("自动挂机", "已点击新版 UI 准备按钮")
    end)
end

AUTO.Actions.StartSolo = function()
    task.spawn(function()
        autoStartSolo()
        refreshStatus()
    end)
end

AUTO.Actions.Vote = function()
    task.spawn(function()
        openVoteGui()
        if autoVote() then
            notify("自动投票", "已投票：" .. AUTO.VoteState)
        else
            notify("自动投票", "当前不在投票阶段")
        end
        refreshStatus()
    end)
end

AUTO.Actions.Equip = function()
    task.spawn(function()
        local ok, name = equipNamed(AUTO.Character)
        if ok then
            notify("装备角色", "已装备：" .. tostring(name))
        else
            notify("装备角色", "没换：" .. tostring(name))
        end
        refreshStatus()
    end)
end

AUTO.Actions.Respawn = function()
    task.spawn(function()
        local ok = forceRespawn("手动", true)
        notify("无限复活", ok and "已重置角色，正在重生" or "当前无法重置（已死或冷却中）")
        refreshStatus()
    end)
end

AUTO.Actions.Claim = function()
    task.spawn(function()
        local n = 0
        for _, name in ipairs({ "LoginRemote", "GroupRewardRemote" }) do
            if claimRemote(name) then n = n + 1 end
        end
        local clicked = 0
        local saved = AUTO.AutoClickClaim
        AUTO.AutoClickClaim = true
        for _ = 1, 3 do
            if autoClickClaim() then clicked = clicked + 1 end
            task.wait(1.2)
        end
        AUTO.AutoClickClaim = saved
        notify("领取奖励",
            (n > 0 or clicked > 0)
                and string.format("已领取 %d 个奖励入口，点了 %d 次领取按钮", n, clicked)
                or "没有可领取的奖励")
        log("领取奖励：请求 " .. n .. " 个入口，点击 " .. clicked .. " 次领取按钮")
        refreshStatus()
    end)
end

AUTO.Actions.BuyHP = function()
    task.spawn(function()
        buyHpNext = 0
        notify("商店", buyHP() and "已请求购买补血" or "买不了（缺少商店遥控）")
    end)
end

AUTO.Actions.Potion = function()
    task.spawn(function()
        potionNext = 0
        notify("药水", usePotion() and ("已请求使用 " .. AUTO.PotionName) or "用不了（缺少药水遥控）")
    end)
end

AUTO.Actions.Boost = function()
    task.spawn(function()
        boostNext = 0
        notify("加速", useBoost() and ("已请求使用 " .. AUTO.BoostName) or "用不了（缺少加速遥控）")
    end)
end

AUTO.Actions.UseMoney = function()
    task.spawn(function()
        moneyNext = 0
        notify("道具", useMoneyBag() and "已请求使用金钱袋" or "用不了（缺少 UseItems 遥控）")
    end)
end

AUTO.Actions.SkillTree = function()
    task.spawn(function()
        resetClock("skilltree")
        notify("技能树", autoSkillTree() and "已尝试升级技能树" or "没有可升级技能")
        refreshStatus()
    end)
end

AUTO.Actions.Title = function()
    task.spawn(function()
        local ok, name = equipTitle(AUTO.TitleName)
        notify("称号", ok and ("已装备：" .. tostring(name)) or ("没换：" .. tostring(name)))
    end)
end

AUTO.Actions.Gacha = function()
    task.spawn(function()
        resetClock("gachachar")
        resetClock("gachaskin")
        resetClock("capsule")
        local a, b, c = AUTO.AutoGachaChar, AUTO.AutoGachaSkin, AUTO.AutoCapsule
        AUTO.AutoGachaChar, AUTO.AutoGachaSkin, AUTO.AutoCapsule = true, true, c
        local ok = autoGacha()
        AUTO.AutoGachaChar, AUTO.AutoGachaSkin, AUTO.AutoCapsule = a, b, c
        if ok then
            notify("抽奖", "已请求抽奖：" .. AUTO.GachaSpin)
        else
            notify("抽奖", "现在不能抽（战斗中或缺少抽奖遥控）")
        end
    end)
end

AUTO.Actions.SquadQuest = function()
    task.spawn(function()
        resetClock("squad")
        notify("小队任务", autoSquadQuest() and "已请求接取 / 完成任务" or "现在不能做（战斗中或无任务）")
    end)
end

AUTO.Actions.RestartVote = function()
    task.spawn(function()
        resetClock("restart")
        notify("重新开局", autoRestartVote() and "已投 Yes" or "当前没有重新开始投票")
    end)
end

AUTO.Actions.SaveConfig = function()
    task.spawn(function()
        local ok = saveConfig()
        notify("保存配置", ok and "已写入 难度模式_配置.json" or "当前执行器不支持写文件")
    end)
end

AUTO.Actions.Redeem = function()
    task.spawn(function()
        local codes = AUTO.SelectedCodes or {}
        if #codes == 0 then
            notify("兑换码", "请先在下拉框里选择兑换码")
            return
        end
        local n = redeemCodes(codes)
        notify("兑换码", "已提交 " .. n .. " 个兑换码")
    end)
end

AUTO.Actions.RedeemAll = function()
    task.spawn(function()
        local n = redeemCodes(REDEEM_ALL)
        notify("兑换码", "已提交全部 " .. n .. " 个兑换码")
    end)
end

AUTO.Actions.UnlockPass = function()
    task.spawn(function()
        local n = unlockPasses(AUTO.SelectedPasses or {})
        notify("通行证", n > 0 and ("已解锁 " .. n .. " 项（客户端）") or "请先选择通行证")
    end)
end

AUTO.Actions.BuyWeapon = function()
    task.spawn(function()
        if AUTO.WeaponName == nil or AUTO.WeaponName == "" then
            notify("商店武器", "请先选择武器")
            return
        end
        local ok = shopFire(AUTO.WeaponName)
        notify("商店武器", ok and ("已请求购买 " .. tostring(AUTO.WeaponName)) or "购买指令发送失败")
    end)
end

AUTO.Actions.BuyMisc = function()
    task.spawn(function()
        if AUTO.MiscName == nil or AUTO.MiscName == "" then
            notify("商店杂项", "请先选择杂项")
            return
        end
        local ok = shopFire(AUTO.MiscName)
        notify("商店杂项", ok and ("已请求购买 " .. tostring(AUTO.MiscName)) or "购买指令发送失败")
    end)
end

AUTO.Actions.BuyRequest = function()
    task.spawn(function()
        local w = waveNumber() or 0
        if w < 10 then
            notify("请求", "需要第 10 波或更高才能请求")
            return
        end
        local ok = shopFire(AUTO.RequestName)
        notify("请求", ok and ("已请求 " .. tostring(AUTO.RequestName)) or "请求指令发送失败")
    end)
end

AUTO.Actions.BuyHourly = function()
    task.spawn(function()
        local amount = math.max(1, math.floor(tonumber(AUTO.HourlyAmount) or 1))
        local n = 0
        for _, item in ipairs(AUTO.HourlyItems or {}) do
            if fireRemote("BuyItemFromShopHourly", item, amount) then n = n + 1 end
        end
        notify("小时购", n > 0 and ("已购买 " .. n .. " 项 x" .. amount) or "请先选择物品")
    end)
end

AUTO.Actions.UseItem = function()
    task.spawn(function()
        local old = AUTO.AutoUseItem
        AUTO.AutoUseItem = true
        resetClock("useitem")
        local ok = useAutoItem()
        AUTO.AutoUseItem = old
        notify("使用物品", ok and "已使用所选物品" or "没有可用物品或正在冷却")
    end)
end

AUTO.Actions.CollectOnce = function()
    task.spawn(function()
        local old = AUTO.AutoCollect
        AUTO.AutoCollect = true
        collectStamp = 0
        lastCollect = 0
        local ok = collectStep()
        AUTO.AutoCollect = old
        notify("自动收集", ok and "已收集最近目标" or "附近没有可收集目标")
    end)
end

AUTO.Actions.JumpServer = function()
    task.spawn(function()
        notify("跳转服务器", "正在寻找可用服务器…")
        if not jumpServer() then
            notify("跳转服务器", "没有找到可用服务器，稍后再试")
        end
    end)
end

AUTO.Actions.Rejoin = function()
    task.spawn(function()
        notify("重新加入", "正在重新连接当前服务器…")
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
    end)
end

AUTO.Actions.ApplyGameMode = function()
    task.spawn(function()
        if AUTO.GameMode == nil or AUTO.GameMode == "" then
            notify("游戏模式", "请先选择游戏模式")
            return
        end
        AUTO.VoteMode = AUTO.GameMode
        notify("游戏模式", "已设为 " .. tostring(AUTO.GameMode) .. "，自动投票会优先投它")
    end)
end

AUTO.Actions.RestoreVote = function()
    task.spawn(function()
        local ready = RS:FindFirstChild("GetReadyRemote")
        if ready and (ready:IsA("RemoteEvent") or ready:IsA("RemoteFunction")) then
            pcall(function()
                ready:FireServer("1", true)
                task.wait(0.5)
                ready:FireServer("1", false)
                task.wait(0.5)
                ready:FireServer("2", false)
                task.wait(0.5)
                ready:FireServer("3", false)
                task.wait(0.5)
                ready:FireServer("1", true)
            end)
        end
        notify("恢复投票系统", "准备中，恢复投票系统…")
        task.wait(6)
        local c = myChar()
        if c then
            pcall(function() c:PivotTo(CFrame.new(-220, -10, -600)) end)
        end
        task.wait(10)
        pcall(openVoteGui)
        pcall(function()
            local play = findPath(pg, { "Play" })
            if play and play:IsA("GuiObject") then play.Visible = true end
        end)
        notify("恢复投票系统", "投票系统已恢复，现在可以使用自动投票")
    end)
end

AUTO.Actions.Diag = function()
    task.spawn(function()
        local me = myChar()
        local tool = me and me:FindFirstChildOfClass("Tool")
        log("===== 环境自检 =====")
        log("角色：" .. nameOf(me) .. "   生命：" .. tostring(humOf(me) and math.floor(humOf(me).Health) or 0))
        log("武器：" .. nameOf(tool))
        if tool then
            local folder = tool:FindFirstChild("Folder")
            local hold = folder and folder:FindFirstChild("Hold")
            log("连发武器：" .. tostring(hold ~= nil))
        end
        log("技能数：" .. skillCount())
        log("Living：" .. tostring(living() ~= nil) .. "   敌人数：" .. enemyCount())
        log("BotBridge：" .. tostring(bot() ~= nil) .. "   MouseStream：" .. tostring(RS:FindFirstChild("MouseStream") ~= nil))
        log("准备区域检测：" .. tostring(workspace:FindFirstChild("AutoReady") ~= nil))
        log("投票阶段：" .. tostring(votePhase()) .. "   Vote 遥控：" .. tostring(RS:FindFirstChild("Vote") ~= nil))
        log("Play 界面：" .. tostring(pg:FindFirstChild("Play") ~= nil) .. "   SelectCharacter：" .. tostring(pg:FindFirstChild("SelectCharacter") ~= nil))
        log("投票建议：" .. tostring(AUTO.VoteState or "—") .. "   Normal票：" .. tostring(voteCount("Normal")))
        log("跳波界面：" .. tostring(pg:FindFirstChild("VoteSkip") ~= nil) .. "   跳波遥控：" .. tostring(RS:FindFirstChild("SkipWaveVote") ~= nil))
        log("设置目录：" .. tostring(player:FindFirstChild("SettingFolder") ~= nil) .. "   跳直升机界面：" .. tostring(pg:FindFirstChild("skip heli") ~= nil))
        log("换角色遥控：" .. tostring(RS:FindFirstChild("ForChangeCharacter") ~= nil) .. "   已解锁角色：" .. tostring(player:FindFirstChild("UnlockData") and #player.UnlockData:GetChildren() or 0))
        log("投射物躲闪：" .. tostring(AUTO.AutoDodge) .. "   瞬移贴脸：" .. tostring(AUTO.AutoTeleport))
        log("波次文本：" .. waveText() .. "   准备文本：" .. readyText())
        log("结算界面：" .. tostring(pg:FindFirstChild("ModeResult") ~= nil))
        notify("环境自检", "结果已写入日志页")
        refreshStatus()
    end)
end

----------------------------------------------------------------
-- ESP：给 workspace.Living 里的敌人模型加 Highlight
-- 0.5 秒扫一次；开关关闭时全部销毁
----------------------------------------------------------------
local espMap = {}
local espAllyMap = {}
local espItemMap = {}
local espItemStamp = 0

function nameInList(name, list)
    if type(list) ~= "table" or #list == 0 then return false end
    local low = string.lower(tostring(name or ""))
    for _, w in ipairs(list) do
        local pat = string.lower(tostring(w))
        if pat ~= "" then
            if low == pat then return true end
            if #low > #pat and low:sub(1, #pat) == pat then
                local ch = low:sub(#pat + 1, #pat + 1)
                if ch == " " or ch == "#" or ch == "_" or ch == "-" then return true end
            end
        end
    end
    return false
end

function addHighlight(model, map, fill, outlineTc)
    if map[model] then return end
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "YYa_ESP"
        hl.FillColor = fill
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = outlineTc
        hl.Adornee = model
        hl.Parent = model
        map[model] = hl
    end)
end

function clearHighlights(map)
    for model, hl in pairs(map) do
        pcall(function() hl:Destroy() end)
        map[model] = nil
    end
end

task.spawn(function()
    while AUTO.Running do
        task.wait(0.5)

        -- 敌人透视（红色）
        if AUTO.ESPEnable ~= false and AUTO.ESP then
            local lv = living()
            local seen = {}
            if lv then
                for _, m in ipairs(lv:GetChildren()) do
                    if isEnemy(m) then
                        seen[m] = true
                        addHighlight(m, espMap, Color3.fromRGB(255, 60, 60), 0.6)
                    end
                end
            end
            for model in pairs(espMap) do
                if not seen[model] then
                    pcall(function() espMap[model]:Destroy() end)
                    espMap[model] = nil
                end
            end
        elseif next(espMap) then
            clearHighlights(espMap)
        end

        -- 队友 / 玩家透视（绿色）
        if AUTO.ESPEnable ~= false and (AUTO.ESPAlly or AUTO.ESPPlayer) then
            local seen = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    seen[plr.Character] = true
                    addHighlight(plr.Character, espAllyMap, Color3.fromRGB(60, 255, 120), 0.6)
                end
            end
            for model in pairs(espAllyMap) do
                if not seen[model] then
                    pcall(function() espAllyMap[model]:Destroy() end)
                    espAllyMap[model] = nil
                end
            end
        elseif next(espAllyMap) then
            clearHighlights(espAllyMap)
        end

        -- 物品透视（金色，每 2 秒刷新一次目标列表）
        if AUTO.ESPEnable ~= false and AUTO.ESPItem and #(AUTO.ESPItems or {}) > 0 then
            if os.clock() - espItemStamp > 2 then
                espItemStamp = os.clock()
                local seen = {}
                for _, d in ipairs(workspace:GetDescendants()) do
                    if (d:IsA("Model") or d:IsA("BasePart")) and nameInList(d.Name, AUTO.ESPItems) then
                        seen[d] = true
                        addHighlight(d, espItemMap, Color3.fromRGB(255, 210, 40), 0.55)
                    end
                end
                for m in pairs(espItemMap) do
                    if not seen[m] or not m.Parent then
                        pcall(function() espItemMap[m]:Destroy() end)
                        espItemMap[m] = nil
                    end
                end
            end
        elseif next(espItemMap) then
            clearHighlights(espItemMap)
        end
    end
end)

----------------------------------------------------------------
-- 防踢
----------------------------------------------------------------
pcall(function()
    player.Idled:Connect(function()
        if not AUTO.AntiAfk then return end
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end)

----------------------------------------------------------------
-- 主循环
----------------------------------------------------------------
local equipDone = false
task.spawn(function()
    local started = os.clock()
    while AUTO.Running do
        local ok, err = pcall(function()
            if AUTO.Paused then return end

            local me = myChar()
            local h = humOf(me)
            local base = hrpOf(me)

            -- 救人（任何状态都先救）
            if AUTO.AutoRevive and every("revive", 0.9) then
                if tryRevive() > 0 then
                    AUTO.LastReason = "正在救倒地队友"
                end
            end

            -- 结算界面：自动准备下一局
            if AUTO.AutoContinue and every("result", 2.5) then
                if autoContinue() then
                    AUTO.Phase = "结算"
                    AUTO.LastReason = "已自动准备下一局"
                    stopFire()
                    stopAim()
                    return
                end
            end

            -- 角色死亡 / 重生中
            if not (me and h and base and h.Health > 0) then
                AUTO.Phase = "等待重生"
                AUTO.LastReason = "角色倒下了，等待复活"
                stopFire()
                stopAim()
                return
            end

            -- 大厅：打开投票界面 → 自动投票 → 发准备序列 → 自动开单人局
            if not inMatch() then
                AUTO.Phase = "大厅"
                stopFire()
                stopAim()
                if every("settings", 3) then
                    applySettings()
                end
                if AUTO.AutoEquipChar and AUTO.Character ~= "" and not equipDone and every("equip", 3) then
                    local pad2 = workspace:FindFirstChild("AutoReady")
                    local far = pad2 and (base.Position - pad2.Position).Magnitude > 40
                    if far and not votePhase() and equipNamed(AUTO.Character) then
                        equipDone = true
                    end
                end
                if AUTO.AutoOpenVote and every("openvote", 2) then
                    openVoteGui()
                end
                if AUTO.AutoVote or AUTO.AutoVoteInGame then
                    if every("vote", AUTO.VoteGap) then
                        autoVote()
                    end
                end
                if AUTO.AutoGameModeLobby then autoGameModeLobby() end
                if AUTO.AutoReady and every("ready", 0.8) then
                    autoReady()
                end
                if AUTO.AutoStart and every("start", 1.5) then
                    autoStartSolo()
                end
                -- 奖励 / 收集 / 商店类自动化（各自内部有开关与冷却）
                autoClaimRewards()
                autoClickClaim()
                autoGacha()
                if AUTO.AutoSquadQuest then autoSquadQuest() end
                if AUTO.AutoTitle and every("title", 6) then equipTitle(AUTO.TitleName) end
                if AUTO.AutoUseMoney then useMoneyBag() end
                if AUTO.AutoBoost then useBoost() end
                if AUTO.AutoSkillTree then autoSkillTree() end
                if AUTO.AutoRestartVote then autoRestartVote() end
                useAutoItem()
                shopStep()
                flushStep()
                -- 扩展自动化队列：大厅阶段
                xRunLobbyModules()
                return
            end

            -- 战斗中
            AUTO.Phase = "战斗"

            -- 直升机过场 / 设置开关（战斗前也会用到）
            if every("heli", 1.5) then
                autoSkipHeli()
            end
            if every("settings2", 5) then
                applySettings()
            end

            -- 扩展：Jeffrey / 冲刷 / 重置波次 / 收集 / 商店
            jeffreyStep()
            flushStep()
            resetWaveStep()
            collectStep()
            shopStep()
            useAutoItem()

            -- 上帝模式 / 安全模式
            if every("safety", 0.5) then
                local sh = humOf(myChar())
                if sh and sh.MaxHealth > 0 and sh.Health > 0 then
                    local pct = sh.Health / sh.MaxHealth * 100
                    if AUTO.GodMode and pct < (AUTO.GodHp or 30) then
                        -- 原版上帝模式：本地写 Health 服务端不认，必须打掉 Head 强制重生
                        local c = myChar()
                        local head = c and c:FindFirstChild("Head")
                        if head then
                            pcall(function() head:Destroy() end)
                        else
                            pcall(function() sh.Health = 0 end)
                        end
                        if AUTO.AutoBuyHP then buyHP() end
                        if every("godlog", 5) then log("上帝模式：血量低于阈值，已强制重生") end
                    end
                    if AUTO.AutoFarm and pct <= (AUTO.SafeHp or 30) then
                        if every("saferetreat", 1.5) then
                            retreatSafe(string.format("血量 %.0f%%", pct))
                        end
                    end
                end
            end

            -- 跳波投票（界面出现时自动跟票）
            if AUTO.AutoSkipVote and every("skipvote", 1.2) then
                autoSkipVote()
            end

            -- 无限复活：残血就重置角色，瞬间重生
            if AUTO.AutoRespawn and every("respawn", 0.4) then
                local hh = humOf(myChar())
                if hh and hh.MaxHealth > 0 and hh.Health > 0 then
                    local pct = hh.Health / hh.MaxHealth * 100
                    if pct <= AUTO.ReviveHp then
                        forceRespawn(string.format("血量 %.0f%%", pct))
                    end
                end
            end

            -- 低血自动补血 / 喝药（不影响无限复活，二者可同时开）
            if (AUTO.AutoBuyHP or AUTO.AutoPotion) and every("healcheck", 0.5) then
                local hh = humOf(myChar())
                if hh and hh.MaxHealth > 0 and hh.Health > 0 then
                    local pct = hh.Health / hh.MaxHealth * 100
                    if pct <= AUTO.ReviveHp then
                        if AUTO.AutoBuyHP then buyHP() end
                        if AUTO.AutoPotion then usePotion() end
                    end
                end
            end
            if AUTO.AutoUseMoney then useMoneyBag() end
            if AUTO.AutoBoost then useBoost() end
            if AUTO.AutoRestartVote then autoRestartVote() end

            -- 扩展自动化队列：战斗阶段
            xRunCombatModules()

            -- 先看有没有导弹/投掷物朝脸上飞，有就侧向瞬移躲开
            dodgeProjectile(base)

            local enemy, dist = nearestEnemy(AUTO.Range)
            if enemy then
                local p = hrpOf(enemy)
                if p then
                    if AUTO.AutoAim then
                        aimAt(p.Position + Vector3.new(0, 1.2, 0))
                    end
                    ensureFire()

                    if AUTO.AutoFarm then
                        farmStep()
                    end

                    if AUTO.AutoSkill and every("skill", math.max(0.2, tonumber(AUTO.SkillDelay) or AUTO.SkillTick)) then
                        useSkills(p.Position)
                    end

                    -- 太远：直接瞬移到敌人身边（开了自动刷怪则由刷怪位置控制，不再强制贴脸）
                    local teleported = false
                    if not AUTO.AutoFarm then
                        teleported = combatTeleport(base, p.Position)
                    end
                    if not AUTO.AutoFarm and not teleported and AUTO.AutoApproach and dist and dist > AUTO.TurnDist then
                        local delta = p.Position - base.Position
                        if delta.Magnitude > 0 then
                            local stand = p.Position - delta.Unit * 12 + Vector3.new(0, 4, 0)
                            local okTp = pcall(function()
                                myChar():PivotTo(CFrame.lookAt(stand, p.Position))
                            end)
                            if not okTp then
                                pcall(function() base.CFrame = CFrame.lookAt(stand, p.Position) end)
                            end
                            pcall(function()
                                base.AssemblyLinearVelocity = Vector3.zero
                                base.AssemblyAngularVelocity = Vector3.zero
                            end)
                            teleported = true
                        end
                    end

                    AUTO.Target = enemy.Name
                    if not teleported then
                        AUTO.LastReason = string.format("锁定 %s（%d 格）", enemy.Name, math.floor(dist or 0))
                    end
                end
            else
                stopFire()
                AUTO.Target = nil
                AUTO.LastReason = "本波已清空，等待下一波"
                if AUTO.AutoFarm then farmStep() end
            end
        end)

        if not ok then
            log("循环异常：" .. tostring(err))
        end
        task.wait(0.18)
    end

    stopFire()
    stopAim()
end)

-- 状态面板刷新
task.spawn(function()
    refreshStatus()
    while AUTO.Running do
        task.wait(1)
        if AUTO.Running then
            pcall(refreshStatus)
        end
    end
end)

-- 常驻模块循环（跳服 / 统计 / 日志 / 配置备份等，与战斗循环互不影响）
task.spawn(function()
    while AUTO.Running do
        task.wait(1)
        if AUTO.Running and not AUTO.Paused then
            pcall(xRunAlwaysModules)
        end
    end
end)

-- 启动时把游戏的自动跳波打开
task.spawn(function()
    task.wait(3)
    for _ = 1, 10 do
        if not AUTO.Running then break end
        enableAutoSkip()
        task.wait(20)
    end
end)

log("引擎已启动：所有功能默认关闭，请在界面里手动打开需要的开关（投票 / 准备 / 开局 / 战斗 / 复活等）")
notify("难度模式 至尊版", "已加载：功能默认全关，打开菜单手动启用")

end
