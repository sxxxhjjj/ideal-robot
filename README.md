
local a={cache={},load=function(b)if not a.cache[b]then a.cache[b]={c=a[b]()}end return a.cache[b].c end}do function a.a()
local b=game:GetService"RunService"local d=
b.Heartbeat
local e=game:GetService"UserInputService"
local f=game:GetService"TweenService"
local g=game:GetService"LocalizationService"

-- 内联图标加载器（替代外部 mian f Yuan.lua）
local h = {
    SetIconsType = function() end,
    Icon = function(self, name)
        return {"rbxassetid://0", {ImageRectSize=Vector2.new(0,0), ImageRectOffset=Vector2.new(0,0)}}
    end,
    Image = function(self, opts)
        local img = Instance.new("ImageLabel")
        img.Image = "rbxassetid://0"
        img.Size = opts.Size or UDim2.new(0,24,0,24)
        img.BackgroundTransparency = 1
        return {IconFrame = img}
    end,
    Init = function() end,
    AddIcons = function() end,
}

local i
local j={
Font="rbxassetid://12187365364",
Localization=nil,
CanDraggable=true,
Theme=nil,
Themes=nil,
Signals={},
Objects={},
LocalizationObjects={},
FontObjects={},
Language=string.match(g.SystemLocaleId,"^[a-z]+"),
Request=http_request or(syn and syn.request)or request,
DefaultProperties={
ScreenGui={
ResetOnSpawn=false,
ZIndexBehavior="Sibling",
},
CanvasGroup={
BorderSizePixel=0,
BackgroundColor3=Color3.new(1,1,1),
},
Frame={
BorderSizePixel=0,
BackgroundColor3=Color3.new(1,1,1),
},
TextLabel={
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
Text="",
RichText=true,
TextColor3=Color3.new(1,1,1),
TextSize=14,
},TextButton={
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
Text="",
AutoButtonColor=false,
TextColor3=Color3.new(1,1,1),
TextSize=14,
},
TextBox={
BackgroundColor3=Color3.new(1,1,1),
BorderColor3=Color3.new(0,0,0),
ClearTextOnFocus=false,
Text="",
TextColor3=Color3.new(0,0,0),
TextSize=14,
},
ImageLabel={
BackgroundTransparency=1,
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
},
ImageButton={
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
AutoButtonColor=false,
},
UIListLayout={
SortOrder="LayoutOrder",
},
ScrollingFrame={
ScrollBarImageTransparency=1,
BorderSizePixel=0,
},
VideoFrame={
BorderSizePixel=0,
}
},
Colors={
Red="#e53935",
Orange="#f57c00",
Green="#43a047",
Blue="#039be5",
White="#ffffff",
Grey="#484848",
},
}
function j.Init(l)
i=l
end
function j.AddSignal(l,m)
table.insert(j.Signals,l:Connect(m))
end
function j.DisconnectAll()
for l,m in next,j.Signals do
local p=table.remove(j.Signals,l)
p:Disconnect()
end
end
function j.SafeCallback(l,...)
if not l then
return
end
local m,p=pcall(l,...)
if not m then local
r, u=p:find":%d+: "
warn("[ WindUI: DEBUG Mode ] "..p)
return i:Notify{
Title="DEBUG Mode: Error",
Content=not u and p or p:sub(u+1),
Duration=8,
}
end
end
function j.SetTheme(l)
j.Theme=l
j.UpdateTheme(nil,true)
end
function j.AddFontObject(l)
table.insert(j.FontObjects,l)
j.UpdateFont(j.Font)
end
function j.UpdateFont(l)
j.Font=l
for m,p in next,j.FontObjects do
p.FontFace=Font.new(l,p.FontFace.Weight,p.FontFace.Style)
end
end
function j.GetThemeProperty(l,m)
return m[l]or j.Themes.Dark[l]
end
function j.AddThemeObject(l,m)
j.Objects[l]={Object=l,Properties=m}
j.UpdateTheme(l,false)
return l
end
function j.AddLangObject(l)
local m=j.LocalizationObjects[l]
local p=m.Object
local r=currentObjTranslationId
j.UpdateLang(p,r)
return p
end
function j.UpdateTheme(l,m)
local function ApplyTheme(p)
for r,u in pairs(p.Properties or{})do
local v=j.GetThemeProperty(u,j.Theme)
if v then
if not m then
p.Object[r]=Color3.fromHex(v)
else
j.Tween(p.Object,0.08,{[r]=Color3.fromHex(v)}):Play()
end
end
end
end
if l then
local p=j.Objects[l]
if p then
ApplyTheme(p)
end
else
for p,r in pairs(j.Objects)do
ApplyTheme(r)
end
end
end
function j.SetLangForObject(l)
if j.Localization and j.Localization.Enabled then
local m=j.LocalizationObjects[l]
if not m then return end
local p=m.Object
local r=m.TranslationId
local u=j.Localization.Translations[j.Language]
if u and u[r]then
p.Text=u[r]
else
local v=j.Localization and j.Localization.Translations and j.Localization.Translations.en or nil
if v and v[r]then
p.Text=v[r]
else
p.Text="["..r.."]"
end
end
end
end
function j.ChangeTranslationKey(l,m,p)
if j.Localization and j.Localization.Enabled then
local r=string.match(p,"^"..j.Localization.Prefix.."(.+)")
if r then
for u,v in ipairs(j.LocalizationObjects)do
if v.Object==m then
v.TranslationId=r
j.SetLangForObject(u)
return
end
end
table.insert(j.LocalizationObjects,{
TranslationId=r,
Object=m
})
j.SetLangForObject(#j.LocalizationObjects)
end
end
end
function j.UpdateLang(l)
if l then
j.Language=l
end
for m=1,#j.LocalizationObjects do
local p=j.LocalizationObjects[m]
if p.Object and p.Object.Parent~=nil then
j.SetLangForObject(m)
else
j.LocalizationObjects[m]=nil
end
end
end
function j.SetLanguage(l)
j.Language=l
j.UpdateLang()
end
function j.Icon(l)
return h.Icon(l)
end
function j.New(l,m,p)
local r=Instance.new(l)
for u,v in next,j.DefaultProperties[l]or{}do
r[u]=v
end
for x,z in next,m or{}do
if x~="ThemeTag"then
r[x]=z
end
if j.Localization and j.Localization.Enabled and x=="Text"then
local A=string.match(z,"^"..j.Localization.Prefix.."(.+)")
if A then
local B=#j.LocalizationObjects+1
j.LocalizationObjects[B]={TranslationId=A,Object=r}
j.SetLangForObject(B)
end
end
end
for A,B in next,p or{}do
B.Parent=r
end
if m and m.ThemeTag then
j.AddThemeObject(r,m.ThemeTag)
end
if m and m.FontFace then
j.AddFontObject(r)
end
return r
end
function j.Tween(l,m,p,...)
return f:Create(l,TweenInfo.new(m,...),p)
end
function j.NewRoundFrame(l,m,p,r,x)
local z=j.New(x and"ImageButton"or"ImageLabel",{
Image=m=="Squircle"and"rbxassetid://80999662900595"
or m=="SquircleOutline"and"rbxassetid://117788349049947"
or m=="SquircleOutline2"and"rbxassetid://117817408534198"
or m=="Shadow-sm"and"rbxassetid://84825982946844"
or m=="Squircle-TL-TR"and"rbxassetid://73569156276236",
ScaleType="Slice",
SliceCenter=m~="Shadow-sm"and Rect.new(256
,256
,256
,256
)or Rect.new(512,512,512,512),
SliceScale=1,
BackgroundTransparency=1,
ThemeTag=p.ThemeTag and p.ThemeTag
},r)
for A,B in pairs(p or{})do
if A~="ThemeTag"then
z[A]=B
end
end
local function UpdateSliceScale(C)
local F=m~="Shadow-sm"and(C/(256))or(C/512)
z.SliceScale=math.max(F,0.0001)
end
UpdateSliceScale(l)
return z
end
local l=j.New local m=
j.Tween
function j.SetDraggable(p)
j.CanDraggable=p
end
function j.Drag(p,r,x)
local z
local A,B,C,F
local G={
CanDraggable=true
}
if not r or type(r)~="table"then
r={p}
end
local function update(H)
local J=H.Position-C
j.Tween(p,0.02,{Position=UDim2.new(
F.X.Scale,F.X.Offset+J.X,
F.Y.Scale,F.Y.Offset+J.Y
)}):Play()
end
for H,J in pairs(r)do
J.InputBegan:Connect(function(L)
if(L.UserInputType==Enum.UserInputType.MouseButton1 or L.UserInputType==Enum.UserInputType.Touch)and G.CanDraggable then
if z==nil then
z=J
A=true
C=L.Position
F=p.Position
if x and type(x)=="function"then
x(true,z)
end
L.Changed:Connect(function()
if L.UserInputState==Enum.UserInputState.End then
A=false
z=nil
if x and type(x)=="function"then
x(false,z)
end
end
end)
end
end
end)
J.InputChanged:Connect(function(L)
if z==J and A then
if L.UserInputType==Enum.UserInputType.MouseMovement or L.UserInputType==Enum.UserInputType.Touch then
B=L
end
end
end)
end
e.InputChanged:Connect(function(L)
if L==B and A and z~=nil then
if G.CanDraggable then
update(L)
end
end
end)
function G.Set(L,M)
G.CanDraggable=M
end
return G
end
h.Init(l,"Icon")
function j.Image(p,r,x,z,A,B,C)
local function SanitizeFilename(F)
F=F:gsub("[%s/\\:*?\"<>|]+","-")
F=F:gsub("[^%w%-_%.]","")
return F
end
z=z or"Temp"
r=SanitizeFilename(r)
local F=l("Frame",{
Size=UDim2.new(0,0,0,0),
BackgroundTransparency=1,
},{
l("ImageLabel",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
ScaleType="Crop",
ThemeTag=(j.Icon(p)or C)and{
ImageColor3=B and"Icon"or nil
}or nil,
},{
l("UICorner",{
CornerRadius=UDim.new(0,x)
})
})
})
if j.Icon(p)then
F.ImageLabel:Destroy()
local G=h.Image{
Icon=p,
Size=UDim2.new(1,0,1,0),
Colors={
(B and"Icon"or false),
"Button"
}
}.IconFrame
G.Parent=F
elseif string.find(p,"http")then
local G="WindUI/"..z.."/Assets/."..A.."-"..r..".png"
local H,J=pcall(function()
task.spawn(function()
if not isfile(G)then
local H=j.Request{
Url=p,
Method="GET",
}.Body
writefile(G,H)
end
F.ImageLabel.Image=getcustomasset(G)
end)
end)
if not H then
warn("[ WindUI.Creator ]  '"..identifyexecutor().."' doesnt support the URL Images. Error: "..J)
F:Destroy()
end
else
F.ImageLabel.Image=p
end
return F
end
return j end function a.b()
local b={}
function b.New(e,f,g)
local h={
Enabled=f.Enabled or false,
Translations=f.Translations or{},
Prefix=f.Prefix or"loc:",
DefaultLanguage=f.DefaultLanguage or"en"
}
g.Localization=h
return h
end
return b end function a.c()
local b=a.load'a'
local e=b.New
local f=b.Tween
local g={
Size=UDim2.new(0,300,1,-156),
SizeLower=UDim2.new(0,300,1,-56),
UICorner=13,
UIPadding=14,
Holder=nil,
NotificationIndex=0,
Notifications={}
}
function g.Init(h)
local i={
Lower=false
}
function i.SetLower(j)
i.Lower=j
i.Frame.Size=j and g.SizeLower or g.Size
end
i.Frame=e("Frame",{
Position=UDim2.new(1,-29,0,56),
AnchorPoint=Vector2.new(1,0),
Size=g.Size,
Parent=h,
BackgroundTransparency=1,
},{
e("UIListLayout",{
HorizontalAlignment="Center",
SortOrder="LayoutOrder",
VerticalAlignment="Bottom",
Padding=UDim.new(0,8),
}),
e("UIPadding",{
PaddingBottom=UDim.new(0,29)
})
})
return i
end
function g.New(h)
local i={
Title=h.Title or"Notification",
Content=h.Content or nil,
Icon=h.Icon or nil,
IconThemed=h.IconThemed,
Background=h.Background,
BackgroundImageTransparency=h.BackgroundImageTransparency,
Duration=h.Duration or 5,
Buttons=h.Buttons or{},
CanClose=true,
UIElements={},
Closed=false,
}
if i.CanClose==nil then
i.CanClose=true
end
g.NotificationIndex=g.NotificationIndex+1
g.Notifications[g.NotificationIndex]=i
local j
if i.Icon then
j=b.Image(
i.Icon,
i.Title..":"..i.Icon,
0,
h.Window,
"Notification",
i.IconThemed
)
j.Size=UDim2.new(0,26,0,26)
j.Position=UDim2.new(0,g.UIPadding,0,g.UIPadding)
end
local l
if i.CanClose then
l=e("ImageButton",{
Image=b.Icon"x"[1],
ImageRectSize=b.Icon"x"[2].ImageRectSize,
ImageRectOffset=b.Icon"x"[2].ImageRectPosition,
BackgroundTransparency=1,
Size=UDim2.new(0,16,0,16),
Position=UDim2.new(1,-g.UIPadding,0,g.UIPadding),
AnchorPoint=Vector2.new(1,0),
ThemeTag={
ImageColor3="Text"
},
ImageTransparency=.4,
},{
e("TextButton",{
Size=UDim2.new(1,8,1,8),
BackgroundTransparency=1,
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,0),
Text="",
})
})
end
local m=e("Frame",{
Size=UDim2.new(0,0,1,0),
BackgroundTransparency=.95,
ThemeTag={
BackgroundColor3="Text",
},
})
local p=e("Frame",{
Size=UDim2.new(1,
i.Icon and-28-g.UIPadding or 0,
1,0),
Position=UDim2.new(1,0,0,0),
AnchorPoint=Vector2.new(1,0),
BackgroundTransparency=1,
AutomaticSize="Y",
},{
e("UIPadding",{
PaddingTop=UDim.new(0,g.UIPadding),
PaddingLeft=UDim.new(0,g.UIPadding),
PaddingRight=UDim.new(0,g.UIPadding),
PaddingBottom=UDim.new(0,g.UIPadding),
}),
e("TextLabel",{
AutomaticSize="Y",
Size=UDim2.new(1,-30-g.UIPadding,0,0),
TextWrapped=true,
TextXAlignment="Left",
RichText=true,
BackgroundTransparency=1,
TextSize=16,
ThemeTag={
TextColor3="Text"
},
Text=i.Title,
FontFace=Font.new(b.Font,Enum.FontWeight.Medium)
}),
e("UIListLayout",{
Padding=UDim.new(0,g.UIPadding/3)
})
})
if i.Content then
e("TextLabel",{
AutomaticSize="Y",
Size=UDim2.new(1,0,0,0),
TextWrapped=true,
TextXAlignment="Left",
RichText=true,
BackgroundTransparency=1,
TextTransparency=.4,
TextSize=15,
ThemeTag={
TextColor3="Text"
},
Text=i.Content,
FontFace=Font.new(b.Font,Enum.FontWeight.Medium),
Parent=p
})
end
local r=b.NewRoundFrame(g.UICorner,"Squircle",{
Size=UDim2.new(1,0,0,0),
Position=UDim2.new(2,0,1,0),
AnchorPoint=Vector2.new(0,1),
AutomaticSize="Y",
ImageTransparency=.05,
ThemeTag={
ImageColor3="Background"
},
},{
e("CanvasGroup",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
},{
m,
e("UICorner",{
CornerRadius=UDim.new(0,g.UICorner),
})
}),
e("ImageLabel",{
Name="Background",
Image=i.Background,
BackgroundTransparency=1,
Size=UDim2.new(1,0,1,0),
ScaleType="Crop",
ImageTransparency=i.BackgroundImageTransparency
},{
e("UICorner",{
CornerRadius=UDim.new(0,g.UICorner),
})
}),
p,
j,l,
})
local x=e("Frame",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,0,0),
Parent=h.Holder
},{
r
})
function i.Close(z)
if not i.Closed then
i.Closed=true
f(x,0.45,{Size=UDim2.new(1,0,0,-8)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
f(r,0.55,{Position=UDim2.new(2,0,1,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
task.wait(.45)
x:Destroy()
end
end
task.spawn(function()
task.wait()
f(x,0.45,{Size=UDim2.new(
1,
0,
0,
r.AbsoluteSize.Y
)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
f(r,0.45,{Position=UDim2.new(0,0,1,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
if i.Duration then
f(m,i.Duration,{Size=UDim2.new(1,0,1,0)},Enum.EasingStyle.Linear,Enum.EasingDirection.InOut):Play()
task.wait(i.Duration)
i:Close()
end
end)
if l then
b.AddSignal(l.TextButton.MouseButton1Click,function()
i:Close()
end)
end
return i
end
return g end function a.d()
return{
Dark={
Name="Dark",
Accent="#18181b",
Dialog="#161616",
Outline="#FFFFFF",
Text="#FFFFFF",
Placeholder="#999999",
Background="#101010",
Button="#52525b",
Icon="#a1a1aa",
},
Light={
Name="Light",
Accent="#FFFFFF",
Dialog="#f4f4f5",
Outline="#09090b",
Text="#000000",
Placeholder="#777777",
Background="#e4e4e7",
Button="#18181b",
Icon="#52525b",
},
Rose={
Name="Rose",
Accent="#f43f5e",
Outline="#ffe4e6",
Text="#ffe4e6",
Placeholder="#fda4af",
Background="#881337",
Button="#e11d48",
Icon="#fecdd3",
},
Plant={
Name="Plant",
Accent="#22c55e",
Outline="#dcfce7",
Text="#dcfce7",
Placeholder="#bbf7d0",
Background="#14532d",
Button="#22c55e",
Icon="#86efac",
},
Red={
Name="Red",
Accent="#ef4444",
Outline="#fee2e2",
Text="#ffe4e6",
Placeholder="#fca5a5",
Background="#7f1d1d",
Button="#ef4444",
Icon="#fecaca",
},
Indigo={
Name="Indigo",
Accent="#6366f1",
Outline="#e0e7ff",
Text="#e0e7ff",
Placeholder="#a5b4fc",
Background="#312e81",
Button="#6366f1",
Icon="#c7d2fe",
},
Sky={
Name="Sky",
Accent="#0ea5e9",
Outline="#e0f2fe",
Text="#e0f2fe",
Placeholder="#7dd3fc",
Background="#075985",
Button="#0ea5e9",
Icon="#bae6fd",
},
Violet={
Name="Violet",
Accent="#8b5cf6",
Outline="#ede9fe",
Text="#ede9fe",
Placeholder="#c4b5fd",
Background="#4c1d95",
Button="#8b5cf6",
Icon="#ddd6fe",
},
Amber={
Name="Amber",
Accent="#f59e0b",
Outline="#fef3c7",
Text="#fef3c7",
Placeholder="#fcd34d",
Background="#78350f",
Button="#f59e0b",
Icon="#fde68a",
},
Emerald={
Name="Emerald",
Accent="#10b981",
Outline="#d1fae5",
Text="#d1fae5",
Placeholder="#6ee7b7",
Background="#064e3b",
Button="#10b981",
Icon="#a7f3d0",
},
Midnight={
Name="Midnight",
Accent="#1e3a8a",
Outline="#93c5fd",
Text="#bfdbfe",
Placeholder="#60a5fa",
Background="#0f172a",
Button="#2563eb",
Icon="#3b82f6",
},
Crimson={
Name="Crimson",
Accent="#d32f2f",
Outline="#ff5252",
Text="#f5f5f5",
Placeholder="#9e9e9e",
Background="#121212",
Button="#b71c1c",
Icon="#e53935",
},
MonokaiPro={
Name="Monokai Pro",
Accent="#fc9867",
Outline="#727072",
Text="#f5f4f1",
Placeholder="#939293",
Background="#2d2a2e",
Button="#ab9df2",
Icon="#78dce8",
},
CottonCandy={
Name="Cotton Candy",
Accent="#FF95B3",
Outline="#A98CF6",
Text="#f6d5e1",
Placeholder="#87D7FF",
Background="#492C37",
Button="#F5B0DE",
Icon="#78E0E8",
},
}end function a.e()
local b=4294967296;local e=b-1;local function c(f,g)local h,i=0,1;while f~=0 or g~=0 do local j,l=f%2,g%2;local m=(j+l)%2;h=h+m*i;f=math.floor(f/2)g=math.floor(g/2)i=i*2 end;return h%b end;local function k(f,g,h,...)local i;if g then f=f%b;g=g%b;i=c(f,g)if h then i=k(i,h,...)end;return i elseif f then return f%b else return 0 end end;local function n(f,g,h,...)local i;if g then f=f%b;g=g%b;i=(f+g-c(f,g))/2;if h then i=n(i,h,...)end;return i elseif f then return f%b else return e end end;local function o(f)return e-f end;local function q(f,g)if g<0 then return lshift(f,-g)end;return math.floor(f%4294967296/2^g)end;local function s(f,g)if g>31 or g<-31 then return 0 end;return q(f%b,g)end;local function lshift(f,g)if g<0 then return s(f,-g)end;return f*2^g%4294967296 end;local function t(f,g)f=f%b;g=g%32;local h=n(f,2^g-1)return s(f,g)+lshift(h,32-g)end;local f={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(g)return string.gsub(g,".",function(h)return string.format("%02x",string.byte(h))end)end;local function y(g,h)local i=""for j=1,h do local l=g%256;i=string.char(l)..i;g=(g-l)/256 end;return i end;local function D(g,h)local i=0;for j=h,h+3 do i=i*256+string.byte(g,j)end;return i end;local function E(g,h)local i=64-(h+9)%64;h=y(8*h,8)g=g.."\128"..string.rep("\0",i)..h;assert(#g%64==0)return g end;local function I(g)g[1]=0x6a09e667;g[2]=0xbb67ae85;g[3]=0x3c6ef372;g[4]=0xa54ff53a;g[5]=0x510e527f;g[6]=0x9b05688c;g[7]=0x1f83d9ab;g[8]=0x5be0cd19;return g end;local function K(g,h,i)local j={}for l=1,16 do j[l]=D(g,h+(l-1)*4)end;for l=17,64 do local m=j[l-15]local p=k(t(m,7),t(m,18),s(m,3))m=j[l-2]j[l]=(j[l-16]+p+j[l-7]+k(t(m,17),t(m,19),s(m,10)))%b end;local l,m,p,r,x,z,A,B=i[1],i[2],i[3],i[4],i[5],i[6],i[7],i[8]for C=1,64 do local F=k(t(l,2),t(l,13),t(l,22))local G=k(n(l,m),n(l,p),n(m,p))local H=(F+G)%b;local J=k(t(x,6),t(x,11),t(x,25))local L=k(n(x,z),n(o(x),A))local M=(B+J+L+f[C]+j[C])%b;B=A;A=z;z=x;x=(r+M)%b;r=p;p=m;m=l;l=(M+H)%b end;i[1]=(i[1]+l)%b;i[2]=(i[2]+m)%b;i[3]=(i[3]+p)%b;i[4]=(i[4]+r)%b;i[5]=(i[5]+x)%b;i[6]=(i[6]+z)%b;i[7]=(i[7]+A)%b;i[8]=(i[8]+B)%b end;local function Z(g)g=E(g,#g)local h=I{}for i=1,#g,64 do K(g,i,h)end;return w(y(h[1],4)..y(h[2],4)..y(h[3],4)..y(h[4],4)..y(h[5],4)..y(h[6],4)..y(h[7],4)..y(h[8],4))end;local g;local h={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local i={["/"]="/"}for j,l in pairs(h)do i[l]=j end;local m=function(m)return"\\"..(h[m]or string.format("u%04x",m:byte()))end;local p=function(p)return"null"end;local r=function(r,x)local z={}x=x or{}if x[r]then error"circular reference"end;x[r]=true;if rawget(r,1)~=nil or next(r)==nil then local A=0;for B in pairs(r)do if type(B)~="number"then error"invalid table: mixed or invalid key types"end;A=A+1 end;if A~=#r then error"invalid table: sparse array"end;for C,F in ipairs(r)do table.insert(z,g(F,x))end;x[r]=nil;return"["..table.concat(z,",").."]"else for A,B in pairs(r)do if type(A)~="string"then error"invalid table: mixed or invalid key types"end;table.insert(z,g(A,x)..":"..g(B,x))end;x[r]=nil;return"{"..table.concat(z,",").."}"end end;local x=function(x)return'"'..x:gsub('[%z\1-\31\\"]',m)..'"'end;local z=function(z)if z~=z or z<=-math.huge or z>=math.huge then error("unexpected number value '"..tostring(z).."'")end;return string.format("%.14g",z)end;local A={["nil"]=p,table=r,string=x,number=z,boolean=tostring}g=function(B,C)local F=type(B)local G=A[F]if G then return G(B,C)end;error("unexpected type '"..F.."'")end;local B=function(B)return g(B)end;local C;local F=function(...)local F={}for G=1,select("#",...)do F[select(G,...)]=true end;return F end;local G=F(" ","\t","\r","\n")local H=F(" ","\t","\r","\n","]","}",",")local J=F("\\","/",'"',"b","f","n","r","t","u")local L=F("true","false","null")local M={["true"]=true,["false"]=false,null=nil}local N=function(N,O,P,Q)for R=O,#N do if P[N:sub(R,R)]~=Q then return R end end;return#N+1 end;local O=function(O,P,Q)local R=1;local S=1;for T=1,P-1 do S=S+1;if O:sub(T,T)=="\n"then R=R+1;S=1 end end;error(string.format("%s at line %d col %d",Q,R,S))end;local P=function(P)local Q=math.floor;if P<=0x7f then return string.char(P)elseif P<=0x7ff then return string.char(Q(P/64)+192,P%64+128)elseif P<=0xffff then return string.char(Q(P/4096)+224,Q(P%4096/64)+128,P%64+128)elseif P<=0x10ffff then return string.char(Q(P/262144)+240,Q(P%262144/4096)+128,Q(P%4096/64)+128,P%64+128)end;error(string.format("invalid unicode codepoint '%x'",P))end;local Q=function(Q)local R=tonumber(Q:sub(1,4),16)local S=tonumber(Q:sub(7,10),16)if S then return P((R-0xd800)*0x400+S-0xdc00+0x10000)else return P(R)end end;local R=function(R,S)local T=""local U=S+1;local V=U;while U<=#R do local W=R:byte(U)if W<32 then O(R,U,"control character in string")elseif W==92 then T=T..R:sub(V,U-1)U=U+1;local X=R:sub(U,U)if X=="u"then local Y=R:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",U+1)or R:match("^%x%x%x%x",U+1)or O(R,U-1,"invalid unicode escape in string")T=T..Q(Y)U=U+#Y else if not J[X]then O(R,U-1,"invalid escape char '"..X.."' in string")end;T=T..i[X]end;V=U+1 elseif W==34 then T=T..R:sub(V,U-1)return T,U+1 end;U=U+1 end;O(R,S,"expected closing quote for string")end;local S=function(S,T)local U=N(S,T,H)local V=S:sub(T,U-1)local W=tonumber(V)if not W then O(S,T,"invalid number '"..V.."'")end;return W,U end;local T=function(T,U)local V=N(T,U,H)local W=T:sub(U,V-1)if not L[W]then O(T,U,"invalid literal '"..W.."'")end;return M[W],V end;local U=function(U,V)local W={}local X=1;V=V+1;while 1 do local Y;V=N(U,V,G,true)if U:sub(V,V)=="]"then V=V+1;break end;Y,V=C(U,V)W[X]=Y;X=X+1;V=N(U,V,G,true)local _=U:sub(V,V)V=V+1;if _=="]"then break end;if _~=","then O(U,V,"expected ']' or ','")end end;return W,V end;local aa=function(V,W)local X={}W=W+1;while 1 do local Y,_;W=N(V,W,G,true)if V:sub(W,W)=="}"then W=W+1;break end;if V:sub(W,W)~='"'then O(V,W,"expected string for key")end;Y,W=C(V,W)W=N(V,W,G,true)if V:sub(W,W)~=":"then O(V,W,"expected ':' after key")end;W=N(V,W+1,G,true)_,W=C(V,W)X[Y]=_;W=N(V,W,G,true)local aa=V:sub(W,W)W=W+1;if aa=="}"then break end;if aa~=","then O(V,W,"expected '}' or ','")end end;return X,W end;local V={['"']=R,["0"]=S,["1"]=S,["2"]=S,["3"]=S,["4"]=S,["5"]=S,["6"]=S,["7"]=S,["8"]=S,["9"]=S,["-"]=S,t=T,f=T,n=T,["["]=U,["{"]=aa}C=function(W,X)local Y=W:sub(X,X)local _=V[Y]if _ then return _(W,X)end;O(W,X,"unexpected character '"..Y.."'")end;local W=function(W)if type(W)~="string"then error("expected argument of type string, got "..type(W))end;local X,Y=C(W,N(W,1,G,true))Y=N(W,Y,G,true)if Y<=#W then O(W,Y,"trailing garbage")end;return X end;
local X,Y,_=B,W,Z;
local ab={}
function ab.New(ac,ad)
local ae=ac;
local af=ad;
local ag=true;
local ah=function(ah)end;
repeat task.wait(1)until game:IsLoaded();
local ai=false;
local aj,ak,al,am,an,ao,ap,aq,ar=setclipboard or toclipboard,request or http_request or syn_request,string.char,tostring,string.sub,os.time,math.random,math.floor,gethwid or function()return game:GetService"Players".LocalPlayer.UserId end
local as,at="",0;
local au="https://api.platoboost.com";
local av=ak{
Url=au.."/public/connectivity",
Method="GET"
};
if av.StatusCode~=200 or av.StatusCode~=429 then
au="https://api.platoboost.net";
end
function cacheLink()
if at+(600)<ao()then
local aw=ak{
Url=au.."/public/start",
Method="POST",
Body=X{
service=ae,
identifier=_(ar())
},
Headers={
["Content-Type"]="application/json"
}
};
if aw.StatusCode==200 then
local ax=Y(aw.Body);
if ax.success==true then
as=ax.data.url;
at=ao();
return true,as
else
ah(ax.message);
return false,ax.message
end
elseif aw.StatusCode==429 then
local ax="you are being rate limited, please wait 20 seconds and try again.";
ah(ax);
return false,ax
end
local ax="Failed to cache link.";
ah(ax);
return false,ax
else
return true,as
end
end
cacheLink();
local aw=function()
local aw=""
for ax=1,16 do
aw=aw..al(aq(ap()*(26))+97)
end
return aw
end
for ax=1,5 do
local ay=aw();
task.wait(0.2)
if aw()==ay then
local az="platoboost nonce error.";
ah(az);
error(az);
end
end
local ax=function()
local ax,ay=cacheLink();
if ax then
aj(ay);
end
end
local ay=function(ay)
local az=aw();
local aA=au.."/public/redeem/"..am(ae);
local aB={
identifier=_(ar()),
key=ay
}
if ag then
aB.nonce=az;
end
local aC=ak{
Url=aA,
Method="POST",
Body=X(aB),
Headers={
["Content-Type"]="application/json"
}
};
if aC.StatusCode==200 then
local aD=Y(aC.Body);
if aD.success==true then
if aD.data.valid==true then
if ag then
if aD.data.hash==_("true".."-"..az.."-"..af)then
return true
else
ah"failed to verify integrity.";
return false
end
else
return true
end
else
ah"key is invalid.";
return false
end
else
if an(aD.message,1,27)=="unique constraint violation"then
ah"you already have an active key, please wait for it to expire before redeeming it.";
return false
else
ah(aD.message);
return false
end
end
elseif aC.StatusCode==429 then
ah"you are being rate limited, please wait 20 seconds and try again.";
return false
else
ah"server returned an invalid status code, please try again later.";
return false
end
end
local az=function(az)
if ai==true then
return false,("A request is already being sent, please slow down.")
else
ai=true;
end
local aA=aw();
local aB=au.."/public/whitelist/"..am(ae).."?identifier=".._(ar()).."&key="..az;
if ag then
aB=aB.."&nonce="..aA;
end
local aC=ak{
Url=aB,
Method="GET",
};
ai=false;
if aC.StatusCode==200 then
local aD=Y(aC.Body);
if aD.success==true then
if aD.data.valid==true then
if ag then
if aD.data.hash==_("true".."-"..aA.."-"..af)then
return true,""
else
return false,("failed to verify integrity.")
end
else
return true
end
else
if an(az,1,4)=="KEY_"then
return true,ay(az)
else
return false,("Key is invalid.")
end
end
else
return false,(aD.message)
end
elseif aC.StatusCode==429 then
return false,("You are being rate limited, please wait 20 seconds and try again.")
else
return false,("Server returned an invalid status code, please try again later.")
end
end
local aA=function(aA)
local aB=aw();
local aC=au.."/public/flag/"..am(ae).."?name="..aA;
if ag then
aC=aC.."&nonce="..aB;
end
local aD=ak{
Url=aC,
Method="GET",
};
if aD.StatusCode==200 then
local aE=Y(aD.Body);
if aE.success==true then
if ag then
if aE.data.hash==_(am(aE.data.value).."-"..aB.."-"..af)then
return aE.data.value
else
ah"failed to verify integrity.";
return nil
end
else
return aE.data.value
end
else
ah(aE.message);
return nil
end
else
return nil
end
end
return{
Verify=az,
GetFlag=aA,
Copy=ax,
}
end
return ab end function a.f()
local aa=game:GetService"HttpService"
local ab={}
function ab.New(ac)
local ad=gethwid or function()return game:GetService"Players".LocalPlayer.UserId end
local ae,af=request or http_request or syn_request,setclipboard or toclipboard
function ValidateKey(ag)
local ah="https://pandadevelopment.net/v2_validation?key="..tostring(ag).."&service="..tostring(ac).."&hwid="..tostring(ad())
local ai,aj=pcall(function()
return ae{
Url=ah,
Method="GET",
Headers={["User-Agent"]="Roblox/Exploit"}
}
end)
if ai and aj then
if aj.Success then
local ak,al=pcall(function()
return aa:JSONDecode(aj.Body)
end)
if ak and al then
if al.V2_Authentication and al.V2_Authentication=="success"then
return true,"Authenticated"
else
local am=al.Key_Information.Notes or"Unknown reason"
return false,"Authentication failed: "..am
end
else
return false,"JSON decode error"
end
else
warn("[Pelinda Ov2.5] HTTP request was not successful. Code: "..tostring(aj.StatusCode).." Message: "..aj.StatusMessage)
return false,"HTTP request failed: "..aj.StatusMessage
end
else
return false,"Request pcall error"
end
end
function GetKeyLink()
return"https://pandadevelopment.net/getkey?service="..tostring(ac).."&hwid="..tostring(ad)
end
function CopyLink()
return af(GetKeyLink())
end
return{
Verify=ValidateKey,
Copy=CopyLink
}
end
return ab end function a.g()
local aa={}
function aa.New(ab,ac)
local ad=loadstring(game:HttpGet"https://sdkapi-public.luarmor.net/library.lua")()
local ae=setclipboard or toclipboard
ad.script_id=ab
function ValidateKey(af)
local ag=ad.check_key(af);
print(ag)
if(ag.code=="KEY_VALID")then
return true,"Whitelisted!"
elseif(ag.code=="KEY_HWID_LOCKED")then
return false,"Key linked to a different HWID. Please reset it using our bot"
elseif(ag.code=="KEY_INCORRECT")then
return false,"Key is wrong or deleted!"
else
return false,"Key check failed:"..ag.message.." Code: "..ag.code
end
end
function CopyLink()
ae(tostring(ac))
end
return{
Verify=ValidateKey,
Copy=CopyLink
}
end
return aa end function a.h()
return{
platoboost={
Name="Platoboost",
Icon="rbxassetid://75920162824531",
Args={"ServiceId","Secret"},
New=a.load'e'.New
},
pandadevelopment={
Name="Panda Development",
Icon="panda",
Args={"ServiceId"},
New=a.load'f'.New
},
luarmor={
Name="Luarmor",
Icon="rbxassetid://130918283130165",
Args={"ScriptId","Discord"},
New=a.load'g'.New
},
}end function a.i()
return[[{
    "name": "<制作者霖溺>",
    "version": "霖溺脚本-版本:免费",
    "main": "./dist/main.lua",
    "repository": "https://github.com/Footagesus/WindUI",
    "discord": "not",
    "author": "Footagesus",
    "description": "Roblox UI Library for scripts",
    "license": "MIT"
}]]end function a.j()
local aa={}
local ab=a.load'a'
local ac=ab.New
local ad=ab.Tween
function aa.New(ae,af,ag,ah,ai,aj,ak)
ah=ah or"Primary"
local al=not ak and 10 or 99
local am
if af and af~=""then
am=ac("ImageLabel",{
Image=ab.Icon(af)[1],
ImageRectSize=ab.Icon(af)[2].ImageRectSize,
ImageRectOffset=ab.Icon(af)[2].ImageRectPosition,
Size=UDim2.new(0,21,0,21),
BackgroundTransparency=1,
ThemeTag={
ImageColor3="Icon",
}
})
end
local an=ac("TextButton",{
Size=UDim2.new(0,0,1,0),
AutomaticSize="X",
Parent=ai,
BackgroundTransparency=1
},{
ab.NewRoundFrame(al,"Squircle",{
ThemeTag={
ImageColor3=ah~="White"and"Button"or nil,
},
ImageColor3=ah=="White"and Color3.new(1,1,1)or nil,
Size=UDim2.new(1,0,1,0),
Name="Squircle",
ImageTransparency=ah=="Primary"and 0 or ah=="White"and 0 or 1
}),
ab.NewRoundFrame(al,"Squircle",{
ImageColor3=Color3.new(1,1,1),
Size=UDim2.new(1,0,1,0),
Name="Special",
ImageTransparency=ah=="Secondary"and 0.95 or 1
}),
ab.NewRoundFrame(al,"Shadow-sm",{
ImageColor3=Color3.new(0,0,0),
Size=UDim2.new(1,3,1,3),
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,0),
Name="Shadow",
ImageTransparency=1,
Visible=not ak
}),
ab.NewRoundFrame(al,not ak and"SquircleOutline"or"SquircleOutline2",{
ThemeTag={
ImageColor3=ah~="White"and"Outline"or nil,
},
Size=UDim2.new(1,0,1,0),
ImageColor3=ah=="White"and Color3.new(0,0,0)or nil,
ImageTransparency=ah=="Primary"and.95 or.85,
Name="SquircleOutline",
},{
ac("UIGradient",{
Rotation=70,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.0,Color3.fromRGB(255,255,255)),
},
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0.0,0.1),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1.0,0.1),
}
})
}),
ab.NewRoundFrame(al,"Squircle",{
Size=UDim2.new(1,0,1,0),
Name="Frame",
ThemeTag={
ImageColor3=ah~="White"and"Text"or nil
},
ImageColor3=ah=="White"and Color3.new(0,0,0)or nil,
ImageTransparency=1
},{
ac("UIPadding",{
PaddingLeft=UDim.new(0,16),
PaddingRight=UDim.new(0,16),
}),
ac("UIListLayout",{
FillDirection="Horizontal",
Padding=UDim.new(0,8),
VerticalAlignment="Center",
HorizontalAlignment="Center",
}),
am,
ac("TextLabel",{
BackgroundTransparency=1,
FontFace=Font.new(ab.Font,Enum.FontWeight.SemiBold),
Text=ae or"Button",
ThemeTag={
TextColor3=(ah~="Primary"and ah~="White")and"Text",
},
TextColor3=ah=="Primary"and Color3.new(1,1,1)or ah=="White"and Color3.new(0,0,0)or nil,
AutomaticSize="XY",
TextSize=18,
})
})
})
ab.AddSignal(an.MouseEnter,function()
ad(an.Frame,.047,{ImageTransparency=.95}):Play()
end)
ab.AddSignal(an.MouseLeave,function()
ad(an.Frame,.047,{ImageTransparency=1}):Play()
end)
ab.AddSignal(an.MouseButton1Up,function()
if aj then
aj:Close()()
end
if ag then
ab.SafeCallback(ag)
end
end)
return an
end
return aa end function a.k()
local aa={}
local ab=a.load'a'
local ac=ab.New local ad=
ab.Tween
function aa.New(ae,af,ag,ah,ai)
ah=ah or"Input"
local aj=10
local ak
if af and af~=""then
ak=ac("ImageLabel",{
Image=ab.Icon(af)[1],
ImageRectSize=ab.Icon(af)[2].ImageRectSize,
ImageRectOffset=ab.Icon(af)[2].ImageRectPosition,
Size=UDim2.new(0,21,0,21),
BackgroundTransparency=1,
ThemeTag={
ImageColor3="Icon",
}
})
end
local al=ah~="Input"
local am=ac("TextBox",{
BackgroundTransparency=1,
TextSize=17,
FontFace=Font.new(ab.Font,Enum.FontWeight.Regular),
Size=UDim2.new(1,ak and-29 or 0,1,0),
PlaceholderText=ae,
ClearTextOnFocus=false,
ClipsDescendants=true,
TextWrapped=al,
MultiLine=al,
TextXAlignment="Left",
TextYAlignment=ah=="Input"and"Center"or"Top",
ThemeTag={
PlaceholderColor3="PlaceholderText",
TextColor3="Text",
},
})
local an=ac("Frame",{
Size=UDim2.new(1,0,0,42),
Parent=ag,
BackgroundTransparency=1
},{
ac("Frame",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
},{
ab.NewRoundFrame(aj,"Squircle",{
ThemeTag={
ImageColor3="Accent",
},
Size=UDim2.new(1,0,1,0),
ImageTransparency=.85,
}),
ab.NewRoundFrame(aj,"SquircleOutline",{
ThemeTag={
ImageColor3="Outline",
},
Size=UDim2.new(1,0,1,0),
ImageTransparency=.9,
},{
ac("UIGradient",{
Rotation=70,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.0,Color3.fromRGB(255,255,255)),
},
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0.0,0.1),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1.0,0.1),
}
})
}),
ab.NewRoundFrame(aj,"Squircle",{
Size=UDim2.new(1,0,1,0),
Name="Frame",
ImageColor3=Color3.new(1,1,1),
ImageTransparency=.95
},{
ac("UIPadding",{
PaddingTop=UDim.new(0,ah=="Input"and 0 or 12),
PaddingLeft=UDim.new(0,12),
PaddingRight=UDim.new(0,12),
PaddingBottom=UDim.new(0,ah=="Input"and 0 or 12),
}),
ac("UIListLayout",{
FillDirection="Horizontal",
Padding=UDim.new(0,8),
VerticalAlignment=ah=="Input"and"Center"or"Top",
HorizontalAlignment="Left",
}),
ak,
am,
})
})
})
ab.AddSignal(am.FocusLost,function()
if ai then
ab.SafeCallback(ai,am.Text)
end
end)
return an
end
return aa end function a.l()
local aa=a.load'a'
local ab=aa.New
local ac=aa.NewRoundFrame
local ad=aa.Tween
game:GetService"UserInputService"
local function Color3ToHSB(ae)
local af,ag,ah=ae.R,ae.G,ae.B
local ai=math.max(af,ag,ah)
local aj=math.min(af,ag,ah)
local ak=ai-aj
local al=0
if ak~=0 then
if ai==af then
al=(ag-ah)/ak%6
elseif ai==ag then
al=(ah-af)/ak+2
else
al=(af-ag)/ak+4
end
al=al*60
else
al=0
end
local am=(ai==0)and 0 or(ak/ai)
local an=ai
return{
h=math.floor(al+0.5),
s=am,
b=an
}
end
local function GetPerceivedBrightness(ae)
local af=ae.R
local ag=ae.G
local ah=ae.B
return 0.299*af+0.587*ag+0.114*ah
end
local function GetTextColorForHSB(ae)
local af=Color3ToHSB(ae)local
ag, ah, ai=af.h, af.s, af.b
if GetPerceivedBrightness(ae)>0.5 then
return Color3.fromHSV(ag/360,0,0.05)
else
return Color3.fromHSV(ag/360,0,0.98)
end
end
return function(ae)
local af={
Title=ae.Title,
Desc=ae.Desc or nil,
Hover=ae.Hover,
Thumbnail=ae.Thumbnail,
ThumbnailSize=ae.ThumbnailSize or 80,
Image=ae.Image,
IconThemed=ae.IconThemed or false,
ImageSize=ae.ImageSize or 30,
Color=ae.Color,
Scalable=ae.Scalable,
Parent=ae.Parent,
UIPadding=13,
UICorner=12,
UIElements={}
}
local ag=af.ImageSize
local ah=af.ThumbnailSize
local ai=true
local aj=0
local ak
local al
if af.Thumbnail then
ak=aa.Image(
af.Thumbnail,
af.Title,
af.UICorner-3,
ae.Window.Folder,
"Thumbnail",
false,
af.IconThemed
)
ak.Size=UDim2.new(1,0,0,ah)
end
if af.Image then
al=aa.Image(
af.Image,
af.Title,
af.UICorner-3,
ae.Window.Folder,
"Image",
not af.Color and true or false
)
if typeof(af.Color)=="string"then
al.ImageLabel.ImageColor3=GetTextColorForHSB(Color3.fromHex(aa.Colors[af.Color]))
elseif typeof(af.Color)=="Color3"then
al.ImageLabel.ImageColor3=GetTextColorForHSB(af.Color)
end
al.Size=UDim2.new(0,ag,0,ag)
aj=ag
end
local function CreateText(am,an)
local ao=typeof(af.Color)=="string"
and GetTextColorForHSB(Color3.fromHex(aa.Colors[af.Color]))
or typeof(af.Color)=="Color3"
and GetTextColorForHSB(af.Color)
return ab("TextLabel",{
BackgroundTransparency=1,
Text=am or"",
TextSize=an=="Desc"and 14 or 16,
TextXAlignment="Left",
ThemeTag={
TextColor3=not af.Color and"Text"or nil,
},
TextColor3=af.Color and ao or nil,
TextTransparency=an=="Desc"and.25 or 0,
TextWrapped=true,
Size=UDim2.new(1,0,0,0),
AutomaticSize="Y",
FontFace=Font.new(aa.Font,Enum.FontWeight.Medium)
})
end
local am=CreateText(af.Title,"Title")
local an=CreateText(af.Desc,"Desc")
if not af.Desc or af.Desc==""then
an.Visible=false
end
af.UIElements.Container=ab("Frame",{
Size=UDim2.new(1,0,0,0),
AutomaticSize="Y",
BackgroundTransparency=1,
},{
ab("UIListLayout",{
Padding=UDim.new(0,af.UIPadding),
FillDirection="Vertical",
VerticalAlignment="Top",
HorizontalAlignment="Left",
}),
ak,
ab("Frame",{
Size=UDim2.new(1,-ae.TextOffset,0,0),
AutomaticSize="Y",
BackgroundTransparency=1,
},{
ab("UIListLayout",{
Padding=UDim.new(0,af.UIPadding),
FillDirection="Horizontal",
VerticalAlignment="Top",
HorizontalAlignment="Left",
}),
al,
ab("Frame",{
BackgroundTransparency=1,
AutomaticSize="Y",
Size=UDim2.new(1,-aj,0,(50-(af.UIPadding*2)))
},{
ab("UIListLayout",{
Padding=UDim.new(0,6),
FillDirection="Vertical",
VerticalAlignment="Center",
HorizontalAlignment="Left",
}),
am,
an
}),
})
})
af.UIElements.Locked=ac(af.UICorner,"Squircle",{
Size=UDim2.new(1,af.UIPadding*2,1,af.UIPadding*2),
ImageTransparency=.4,
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,0),
ImageColor3=Color3.new(0,0,0),
Visible=false,
Active=false,
ZIndex=9999999,
})
af.UIElements.Main=ac(af.UICorner,"Squircle",{
Size=UDim2.new(1,0,0,50),
AutomaticSize="Y",
ImageTransparency=af.Color and.05 or.95,
Parent=ae.Parent,
ThemeTag={
ImageColor3=not af.Color and"Text"or nil
},
ImageColor3=af.Color and
(
typeof(af.Color)=="string"
and Color3.fromHex(aa.Colors[af.Color])
or typeof(af.Color)=="Color3"
and af.Color
)or nil
},{
af.UIElements.Container,
af.UIElements.Locked,
ab("UIPadding",{
PaddingTop=UDim.new(0,af.UIPadding),
PaddingLeft=UDim.new(0,af.UIPadding),
PaddingRight=UDim.new(0,af.UIPadding),
PaddingBottom=UDim.new(0,af.UIPadding),
}),
},true)
if af.Hover then
aa.AddSignal(af.UIElements.Main.MouseEnter,function()
if ai then
ad(af.UIElements.Main,.05,{ImageTransparency=af.Color and.15 or.9}):Play()
end
end)
aa.AddSignal(af.UIElements.Main.InputEnded,function()
if ai then
ad(af.UIElements.Main,.05,{ImageTransparency=af.Color and.05 or.95}):Play()
end
end)
end
function af.SetTitle(ao,ap)
am.Text=ap
end
function af.SetDesc(ao,ap)
an.Text=ap or""
if not ap then
an.Visible=false
elseif not an.Visible then
an.Visible=true
end
end
function af.Destroy(ao)
af.UIElements.Main:Destroy()
end
function af.Lock(ao)
ai=false
af.UIElements.Locked.Active=true
af.UIElements.Locked.Visible=true
end
function af.Unlock(ao)
ai=true
af.UIElements.Locked.Active=false
af.UIElements.Locked.Visible=false
end
return af
end end function a.z()
local aa=a.load'a'
local ab=aa.New
local ac={}
local ad=a.load'j'.New
function ac.New(ae,af)
af.Hover=false
af.TextOffset=0
af.IsButtons=af.Buttons and#af.Buttons>0 and true or false
local ag={
__type="Paragraph",
Title=af.Title or"Paragraph",
Desc=af.Desc or nil,
Locked=af.Locked or false,
}
local ah=a.load'y'(af)
ag.ParagraphFrame=ah
if af.Buttons and#af.Buttons>0 then
local ai=ab("Frame",{
Size=UDim2.new(1,0,0,38),
BackgroundTransparency=1,
AutomaticSize="Y",
Parent=ah.UIElements.Container
},{
ab("UIListLayout",{
Padding=UDim.new(0,10),
FillDirection="Vertical",
})
})
for aj,ak in next,af.Buttons do
local al=ad(ak.Title,ak.Icon,ak.Callback,"White",ai)
al.Size=UDim2.new(1,0,0,38)
end
end
return ag.__type,ag
end
return ac end function a.A()
local aa=a.load'a'
local ab=aa.New
local ac={}
function ac.New(ad,ae)
local af={
__type="Button",
Title=ae.Title or"Button",
Desc=ae.Desc or nil,
Locked=ae.Locked or false,
Callback=ae.Callback or function()end,
UIElements={}
}
local ag=true
af.ButtonFrame=a.load'y'{
Title=af.Title,
Desc=af.Desc,
Parent=ae.Parent,
Window=ae.Window,
TextOffset=20,
Hover=true,
Scalable=true,
}
af.UIElements.ButtonIcon=ab("ImageLabel",{
Image=aa.Icon"mouse-pointer-click"[1],
ImageRectOffset=aa.Icon"mouse-pointer-click"[2].ImageRectPosition,
ImageRectSize=aa.Icon"mouse-pointer-click"[2].ImageRectSize,
BackgroundTransparency=1,
Parent=af.ButtonFrame.UIElements.Main,
Size=UDim2.new(0,20,0,20),
AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,0,0.5,0),
ThemeTag={
ImageColor3="Text"
}
})
function af.Lock(ah)
ag=false
return af.ButtonFrame:Lock()
end
function af.Unlock(ah)
ag=true
return af.ButtonFrame:Unlock()
end
if af.Locked then
af:Lock()
end
aa.AddSignal(af.ButtonFrame.UIElements.Main.MouseButton1Click,function()
if ag then
task.spawn(function()
aa.SafeCallback(af.Callback)
end)
end
end)
return af.__type,af
end
return ac end function a.B()
local aa={}
local ab=a.load'a'
local ac=ab.New
local ad=ab.Tween
function aa.New(ae,af,ag,ah)
local ai={}
local aj=13
local ak
if af and af~=""then
ak=ac("ImageLabel",{
Size=UDim2.new(1,-7,1,-7),
BackgroundTransparency=1,
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,0),
Image=ab.Icon(af)[1],
ImageRectOffset=ab.Icon(af)[2].ImageRectPosition,
ImageRectSize=ab.Icon(af)[2].ImageRectSize,
ImageTransparency=1,
ImageColor3=Color3.new(0,0,0),
})
end
local al=ab.NewRoundFrame(aj,"Squircle",{
ImageTransparency=.95,
ThemeTag={
ImageColor3="Text"
},
Parent=ag,
Size=UDim2.new(0,42,0,26),
},{
ab.NewRoundFrame(aj,"Squircle",{
Size=UDim2.new(1,0,1,0),
Name="Layer",
ThemeTag={
ImageColor3="Button",
},
ImageTransparency=1,
}),
ab.NewRoundFrame(aj,"SquircleOutline",{
Size=UDim2.new(1,0,1,0),
Name="Stroke",
ImageColor3=Color3.new(1,1,1),
ImageTransparency=1,
},{
ac("UIGradient",{
Rotation=90,
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0,0),
NumberSequenceKeypoint.new(1,1),
}
})
}),
ab.NewRoundFrame(aj,"Squircle",{
Size=UDim2.new(0,18,0,18),
Position=UDim2.new(0,3,0.5,0),
AnchorPoint=Vector2.new(0,0.5),
ImageTransparency=0,
ImageColor3=Color3.new(1,1,1),
Name="Frame",
},{
ak,
})
})
function ai.Set(am,an)
if an then
ad(al.Frame,0.1,{
Position=UDim2.new(1,-22,0.5,0),
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
ad(al.Layer,0.1,{
ImageTransparency=0,
}):Play()
ad(al.Stroke,0.1,{
ImageTransparency=0.95,
}):Play()
if ak then
ad(ak,0.1,{
ImageTransparency=0,
}):Play()
end
else
ad(al.Frame,0.1,{
Position=UDim2.new(0,4,0.5,0),
Size=UDim2.new(0,18,0,18),
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
ad(al.Layer,0.1,{
ImageTransparency=1,
}):Play()
ad(al.Stroke,0.1,{
ImageTransparency=1,
}):Play()
if ak then
ad(ak,0.1,{
ImageTransparency=1,
}):Play()
end
end
task.spawn(function()
if ah then
ab.SafeCallback(ah,an)
end
end)
end
return al,ai
end
return aa end function a.C()
local aa={}
local ab=a.load'a'
local ac=ab.New
local ad=ab.Tween
function aa.New(ae,af,ag,ah)
local ai={}
af=af or"check"
local aj=10
local ak=ac("ImageLabel",{
Size=UDim2.new(1,-10,1,-10),
BackgroundTransparency=1,
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,0),
Image=ab.Icon(af)[1],
ImageRectOffset=ab.Icon(af)[2].ImageRectPosition,
ImageRectSize=ab.Icon(af)[2].ImageRectSize,
ImageTransparency=1,
ImageColor3=Color3.new(1,1,1),
})
local al=ab.NewRoundFrame(aj,"Squircle",{
ImageTransparency=.95,
ThemeTag={
ImageColor3="Text"
},
Parent=ag,
Size=UDim2.new(0,27,0,27),
},{
ab.NewRoundFrame(aj,"Squircle",{
Size=UDim2.new(1,0,1,0),
Name="Layer",
ThemeTag={
ImageColor3="Button",
},
ImageTransparency=1,
}),
ab.NewRoundFrame(aj,"SquircleOutline",{
Size=UDim2.new(1,0,1,0),
Name="Stroke",
ImageColor3=Color3.new(1,1,1),
ImageTransparency=1,
},{
ac("UIGradient",{
Rotation=90,
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0,0),
NumberSequenceKeypoint.new(1,1),
}
})
}),
ak,
})
function ai.Set(am,an)
if an then
ad(al.Layer,0.06,{
ImageTransparency=0,
}):Play()
ad(al.Stroke,0.06,{
ImageTransparency=0.95,
}):Play()
ad(ak,0.06,{
ImageTransparency=0,
}):Play()
else
ad(al.Layer,0.05,{
ImageTransparency=1,
}):Play()
ad(al.Stroke,0.05,{
ImageTransparency=1,
}):Play()
ad(ak,0.06,{
ImageTransparency=1,
}):Play()
end
task.spawn(function()
if ah then
ab.SafeCallback(ah,an)
end
end)
end
return al,ai
end
return aa end function a.D()
local aa=a.load'a'local ab=
aa.New local ac=
aa.Tween
local ad=a.load'B'.New
local ae=a.load'C'.New
local af={}
function af.New(ag,ah)
local ai={
__type="Toggle",
Title=ah.Title or"Toggle",
Desc=ah.Desc or nil,
Value=ah.Value,
Icon=ah.Icon or nil,
Type=ah.Type or"Toggle",
Callback=ah.Callback or function()end,
UIElements={}
}
ai.ToggleFrame=a.load'y'{
Title=ai.Title,
Desc=ai.Desc,
Window=ah.Window,
Parent=ah.Parent,
TextOffset=44,
Hover=false,
}
local aj=true
if ai.Value==nil then
ai.Value=false
end
function ai.Lock(ak)
aj=false
return ai.ToggleFrame:Lock()
end
function ai.Unlock(ak)
aj=true
return ai.ToggleFrame:Unlock()
end
if ai.Locked then
ai:Lock()
end
local ak=ai.Value
local al,am
if ai.Type=="Toggle"then
al,am=ad(ak,ai.Icon,ai.ToggleFrame.UIElements.Main,ai.Callback)
elseif ai.Type=="Checkbox"then
al,am=ae(ak,ai.Icon,ai.ToggleFrame.UIElements.Main,ai.Callback)
else
error("Unknown Toggle Type: "..tostring(ai.Type))
end
al.AnchorPoint=Vector2.new(1,0.5)
al.Position=UDim2.new(1,0,0.5,0)
function ai.Set(an,ao)
if aj then
am:Set(ao)
ak=ao
ai.Value=ao
end
end
ai:Set(ak)
aa.AddSignal(ai.ToggleFrame.UIElements.Main.MouseButton1Click,function()
ai:Set(not ak)
end)
return ai.__type,ai
end
return af end function a.E()
local aa=a.load'a'
local ac=aa.New
local ad=aa.Tween
local ae={}
local af=false
function ae.New(ag,ah)
local ai={
__type="Slider",
Title=ah.Title or"Slider",
Desc=ah.Desc or nil,
Locked=ah.Locked or nil,
Value=ah.Value or{},
Step=ah.Step or 1,
Callback=ah.Callback or function()end,
UIElements={},
IsFocusing=false,
Width=130,
TextBoxWidth=30,
}
local aj
local ak
local al
local am=ai.Value.Default or ai.Value.Min or 0
local an=am
local ao=(am-(ai.Value.Min or 0))/((ai.Value.Max or 100)-(ai.Value.Min or 0))
local ap=true
local aq=ai.Step%1~=0
local function FormatValue(ar)
if aq then
return string.format("%.2f",ar)
else
return tostring(math.floor(ar+0.5))
end
end
local function CalculateValue(ar)
if aq then
return math.floor(ar/ai.Step+0.5)*ai.Step
else
return math.floor(ar/ai.Step+0.5)*ai.Step
end
end
ai.SliderFrame=a.load'y'{
Title=ai.Title,
Desc=ai.Desc,
Parent=ah.Parent,
TextOffset=ai.Width,
Hover=false,
}
ai.UIElements.SliderIcon=aa.NewRoundFrame(99,"Squircle",{
ImageTransparency=.95,
Size=UDim2.new(1,-ai.TextBoxWidth-8,0,4),
Name="Frame",
ThemeTag={
ImageColor3="Text",
},
},{
aa.NewRoundFrame(99,"Squircle",{
Name="Frame",
Size=UDim2.new(ao,0,1,0),
ImageTransparency=.1,
ThemeTag={
ImageColor3="Button",
},
},{
aa.NewRoundFrame(99,"Squircle",{
Size=UDim2.new(0,13,0,13),
Position=UDim2.new(1,0,0.5,0),
AnchorPoint=Vector2.new(0.5,0.5),
ThemeTag={
ImageColor3="Text",
},
})
})
})
ai.UIElements.SliderContainer=ac("Frame",{
Size=UDim2.new(0,ai.Width,0,0),
AutomaticSize="Y",
Position=UDim2.new(1,0,.5,0),
AnchorPoint=Vector2.new(1,0.5),
BackgroundTransparency=1,
Parent=ai.SliderFrame.UIElements.Main,
},{
ac("UIListLayout",{
Padding=UDim.new(0,8),
FillDirection="Horizontal",
VerticalAlignment="Center",
}),
ai.UIElements.SliderIcon,
ac("TextBox",{
Size=UDim2.new(0,ai.TextBoxWidth,0,0),
TextXAlignment="Left",
Text=FormatValue(am),
ThemeTag={
TextColor3="Text"
},
TextTransparency=.4,
AutomaticSize="Y",
TextSize=15,
FontFace=Font.new(aa.Font,Enum.FontWeight.Medium),
BackgroundTransparency=1,
LayoutOrder=-1,
})
})
function ai.Lock(ar)
ap=false
return ai.SliderFrame:Lock()
end
function ai.Unlock(ar)
ap=true
return ai.SliderFrame:Unlock()
end
if ai.Locked then
ai:Lock()
end
local ar=ai.SliderFrame.Parent:IsA"ScrollingFrame"and ai.SliderFrame.Parent or ai.SliderFrame.Parent.Parent.Parent
function ai.Set(as,at,au)
if ap then
if not ai.IsFocusing and not af and(not au or(au.UserInputType==Enum.UserInputType.MouseButton1 or au.UserInputType==Enum.UserInputType.Touch))then
at=math.clamp(at,ai.Value.Min or 0,ai.Value.Max or 100)
local av=math.clamp((at-(ai.Value.Min or 0))/((ai.Value.Max or 100)-(ai.Value.Min or 0)),0,1)
at=CalculateValue(ai.Value.Min+av*(ai.Value.Max-ai.Value.Min))
if at~=an then
ad(ai.UIElements.SliderIcon.Frame,0.08,{Size=UDim2.new(av,0,1,0)}):Play()
ai.UIElements.SliderContainer.TextBox.Text=FormatValue(at)
ai.Value.Default=FormatValue(at)
an=at
aa.SafeCallback(ai.Callback,FormatValue(at))
end
if au then
aj=(au.UserInputType==Enum.UserInputType.Touch)
ar.ScrollingEnabled=false
af=true
ak=game:GetService"RunService".RenderStepped:Connect(function()
local aw=aj and au.Position.X or game:GetService"UserInputService":GetMouseLocation().X
local ax=math.clamp((aw-ai.UIElements.SliderIcon.AbsolutePosition.X)/ai.UIElements.SliderIcon.AbsoluteSize.X,0,1)
at=CalculateValue(ai.Value.Min+ax*(ai.Value.Max-ai.Value.Min))
if at~=an then
ad(ai.UIElements.SliderIcon.Frame,0.08,{Size=UDim2.new(ax,0,1,0)}):Play()
ai.UIElements.SliderContainer.TextBox.Text=FormatValue(at)
ai.Value.Default=FormatValue(at)
an=at
aa.SafeCallback(ai.Callback,FormatValue(at))
end
end)
al=game:GetService"UserInputService".InputEnded:Connect(function(aw)
if(aw.UserInputType==Enum.UserInputType.MouseButton1 or aw.UserInputType==Enum.UserInputType.Touch)and au==aw then
ak:Disconnect()
al:Disconnect()
af=false
ar.ScrollingEnabled=true
end
end)
end
end
end
end
aa.AddSignal(ai.UIElements.SliderContainer.TextBox.FocusLost,function(as)
if as then
local at=tonumber(ai.UIElements.SliderContainer.TextBox.Text)
if at then
ai:Set(at)
else
ai.UIElements.SliderContainer.TextBox.Text=FormatValue(an)
end
end
end)
aa.AddSignal(ai.UIElements.SliderContainer.InputBegan,function(as)
ai:Set(am,as)
end)
return ai.__type,ai
end
return ae end function a.F()
local aa=game:GetService"UserInputService"
local ac=a.load'a'
local ad=ac.New local ae=
ac.Tween
local af={
UICorner=6,
UIPadding=8,
}
local ag=a.load's'.New
function af.New(ah,ai)
local aj={
__type="Keybind",
Title=ai.Title or"Keybind",
Desc=ai.Desc or nil,
Locked=ai.Locked or false,
Value=ai.Value or"F",
Callback=ai.Callback or function()end,
CanChange=ai.CanChange or true,
Picking=false,
UIElements={},
}
local ak=true
aj.KeybindFrame=a.load'y'{
Title=aj.Title,
Desc=aj.Desc,
Parent=ai.Parent,
TextOffset=85,
Hover=aj.CanChange,
}
aj.UIElements.Keybind=ag(aj.Value,nil,aj.KeybindFrame.UIElements.Main)
aj.UIElements.Keybind.Size=UDim2.new(
0,24
+aj.UIElements.Keybind.Frame.Frame.TextLabel.TextBounds.X,
0,
42
)
aj.UIElements.Keybind.AnchorPoint=Vector2.new(1,0.5)
aj.UIElements.Keybind.Position=UDim2.new(1,0,0.5,0)
ad("UIScale",{
Parent=aj.UIElements.Keybind,
Scale=.85,
})
ac.AddSignal(aj.UIElements.Keybind.Frame.Frame.TextLabel:GetPropertyChangedSignal"TextBounds",function()
aj.UIElements.Keybind.Size=UDim2.new(
0,24
+aj.UIElements.Keybind.Frame.Frame.TextLabel.TextBounds.X,
0,
42
)
end)
function aj.Lock(al)
ak=false
return aj.KeybindFrame:Lock()
end
function aj.Unlock(al)
ak=true
return aj.KeybindFrame:Unlock()
end
function aj.Set(al,am)
aj.Value=am
aj.UIElements.Keybind.Frame.Frame.TextLabel.Text=am
end
if aj.Locked then
aj:Lock()
end
ac.AddSignal(aj.KeybindFrame.UIElements.Main.MouseButton1Click,function()
if ak then
if aj.CanChange then
aj.Picking=true
aj.UIElements.Keybind.Frame.Frame.TextLabel.Text="..."
task.wait(0.2)
local al
al=aa.InputBegan:Connect(function(am)
local an
if am.UserInputType==Enum.UserInputType.Keyboard then
an=am.KeyCode.Name
elseif am.UserInputType==Enum.UserInputType.MouseButton1 then
an="MouseLeft"
elseif am.UserInputType==Enum.UserInputType.MouseButton2 then
an="MouseRight"
end
local ao
ao=aa.InputEnded:Connect(function(ap)
if ap.KeyCode.Name==an or an=="MouseLeft"and ap.UserInputType==Enum.UserInputType.MouseButton1 or an=="MouseRight"and ap.UserInputType==Enum.UserInputType.MouseButton2 then
aj.Picking=false
aj.UIElements.Keybind.Frame.Frame.TextLabel.Text=an
aj.Value=an
al:Disconnect()
ao:Disconnect()
end
end)
end)
end
end
end)
ac.AddSignal(aa.InputBegan,function(al)
if ak then
if al.KeyCode.Name==aj.Value then
ac.SafeCallback(aj.Callback,al.KeyCode.Name)
end
end
end)
return aj.__type,aj
end
return af end function a.G()
local aa=a.load'a'
local ac=aa.New local ad=
aa.Tween
local ae={
UICorner=8,
UIPadding=8,
}local af=a.load'j'
.New
local ag=a.load'k'.New
function ae.New(ah,ai)
local aj={
__type="Input",
Title=ai.Title or"Input",
Desc=ai.Desc or nil,
Type=ai.Type or"Input",
Locked=ai.Locked or false,
InputIcon=ai.InputIcon or false,
Placeholder=ai.Placeholder or"Enter Text...",
Value=ai.Value or"",
Callback=ai.Callback or function()end,
ClearTextOnFocus=ai.ClearTextOnFocus or false,
UIElements={},
Width=150,
}
local ak=true
aj.InputFrame=a.load'y'{
Title=aj.Title,
Desc=aj.Desc,
Parent=ai.Parent,
TextOffset=aj.Width,
Hover=false,
}
local al=ag(aj.Placeholder,aj.InputIcon,not aj.Type=="Input"and aj.InputFrame.UIElements.Container or aj.InputFrame.UIElements.Main,aj.Type,function(al)
aj:Set(al)
end)
if aj.Type=="Input"then
al.Size=UDim2.new(0,aj.Width,0,36)
al.Position=UDim2.new(1,0,0.5,0)
al.AnchorPoint=Vector2.new(1,0.5)
else
al.Size=UDim2.new(1,0,0,148)
end
ac("UIScale",{
Parent=al,
Scale=1,
})
function aj.Lock(am)
ak=false
return aj.InputFrame:Lock()
end
function aj.Unlock(am)
ak=true
return aj.InputFrame:Unlock()
end
function aj.Set(am,an)
if ak then
aa.SafeCallback(aj.Callback,an)
al.Frame.Frame.TextBox.Text=an
aj.Value=an
end
end
function aj.SetPlaceholder(am,an)
al.Frame.Frame.TextBox.PlaceholderText=an
aj.Placeholder=an
end
aj:Set(aj.Value)
if aj.Locked then
aj:Lock()
end
return aj.__type,aj
end
return ae end function a.H()
local aa=game:GetService"UserInputService"
local ac=game:GetService"Players".LocalPlayer:GetMouse()
local ae=game:GetService"Workspace".CurrentCamera
local af=a.load'a'
local ag=af.New
local ah=af.Tween
local ai={
UICorner=8,
UIPadding=8,
MenuCorner=15,
MenuPadding=5,
TabPadding=10,
}
function ai.New(aj,ak)
local al={
__type="Dropdown",
Title=ak.Title or"Dropdown",
Desc=ak.Desc or nil,
Locked=ak.Locked or false,
Values=ak.Values or{},
MenuWidth=ak.MenuWidth or 170,
Value=ak.Value,
AllowNone=ak.AllowNone,
Multi=ak.Multi,
Callback=ak.Callback or function()end,
UIElements={},
Opened=false,
Tabs={},
Width=150,
}
if al.Multi and not al.Value then
al.Value={}
end
local an=true
al.DropdownFrame=a.load'y'{
Title=al.Title,
Desc=al.Desc,
Parent=ak.Parent,
TextOffset=al.Width,
Hover=false,
}
al.UIElements.Dropdown=a.load's'.New("",nil,al.DropdownFrame.UIElements.Main)
al.UIElements.Dropdown.Frame.Frame.TextLabel.TextTruncate="AtEnd"
al.UIElements.Dropdown.Frame.Frame.TextLabel.Size=UDim2.new(1,al.UIElements.Dropdown.Frame.Frame.TextLabel.Size.X.Offset-18-12-12,0,0)
al.UIElements.Dropdown.Size=UDim2.new(0,al.Width,0,36)
al.UIElements.Dropdown.Position=UDim2.new(1,0,0.5,0)
al.UIElements.Dropdown.AnchorPoint=Vector2.new(1,0.5)
ag("ImageLabel",{
Image=af.Icon"chevrons-up-down"[1],
ImageRectOffset=af.Icon"chevrons-up-down"[2].ImageRectPosition,
ImageRectSize=af.Icon"chevrons-up-down"[2].ImageRectSize,
Size=UDim2.new(0,18,0,18),
Position=UDim2.new(1,-12,0.5,0),
ThemeTag={
ImageColor3="Icon"
},
AnchorPoint=Vector2.new(1,0.5),
Parent=al.UIElements.Dropdown.Frame
})
al.UIElements.UIListLayout=ag("UIListLayout",{
Padding=UDim.new(0,ai.MenuPadding),
FillDirection="Vertical"
})
al.UIElements.Menu=af.NewRoundFrame(ai.MenuCorner,"Squircle",{
ThemeTag={
ImageColor3="Background",
},
ImageTransparency=1,
Size=UDim2.new(1,0,1,0),
AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,0,0,0),
},{
ag("UIPadding",{
PaddingTop=UDim.new(0,ai.MenuPadding),
PaddingLeft=UDim.new(0,ai.MenuPadding),
PaddingRight=UDim.new(0,ai.MenuPadding),
PaddingBottom=UDim.new(0,ai.MenuPadding),
}),
ag("Frame",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,1,0),
ClipsDescendants=true
},{
ag("UICorner",{
CornerRadius=UDim.new(0,ai.MenuCorner-ai.MenuPadding),
}),
ag("ScrollingFrame",{
Size=UDim2.new(1,0,1,0),
ScrollBarThickness=0,
ScrollingDirection="Y",
AutomaticCanvasSize="Y",
CanvasSize=UDim2.new(0,0,0,0),
BackgroundTransparency=1,
ScrollBarImageTransparency=1,
},{
al.UIElements.UIListLayout,
})
})
})
al.UIElements.MenuCanvas=ag("Frame",{
Size=UDim2.new(0,al.MenuWidth,0,300),
BackgroundTransparency=1,
Position=UDim2.new(-10,0,-10,0),
Visible=false,
Active=false,
Parent=ak.WindUI.DropdownGui,
AnchorPoint=Vector2.new(1,0),
},{
al.UIElements.Menu,
ag("UISizeConstraint",{
MinSize=Vector2.new(170,0)
})
})
function al.Lock(ao)
an=false
return al.DropdownFrame:Lock()
end
function al.Unlock(ao)
an=true
return al.DropdownFrame:Unlock()
end
if al.Locked then
al:Lock()
end
local function RecalculateCanvasSize()
al.UIElements.Menu.Frame.ScrollingFrame.CanvasSize=UDim2.fromOffset(0,al.UIElements.UIListLayout.AbsoluteContentSize.Y)
end
local function RecalculateListSize()
if#al.Values>10 then
al.UIElements.MenuCanvas.Size=UDim2.fromOffset(al.UIElements.MenuCanvas.AbsoluteSize.X,392)
else
al.UIElements.MenuCanvas.Size=UDim2.fromOffset(al.UIElements.MenuCanvas.AbsoluteSize.X,al.UIElements.UIListLayout.AbsoluteContentSize.Y+(ai.MenuPadding*2))
end
end
function UpdatePosition()
local ao=al.UIElements.Dropdown
local ap=al.UIElements.MenuCanvas
local aq=ae.ViewportSize.Y-(ao.AbsolutePosition.Y+ao.AbsoluteSize.Y)-ai.MenuPadding-54
local ar=ap.AbsoluteSize.Y+ai.MenuPadding
local as=-54
if aq<ar then
as=ar-aq-54
end
ap.Position=UDim2.new(
0,
ao.AbsolutePosition.X+ao.AbsoluteSize.X,
0,
ao.AbsolutePosition.Y+ao.AbsoluteSize.Y-as+ai.MenuPadding
)
end
function al.Display(ao)
local ap=al.Values
local aq=""
if al.Multi then
for ar,as in next,ap do
if table.find(al.Value,as)then
aq=aq..as..", "
end
end
aq=aq:sub(1,#aq-2)
else
aq=al.Value or""
end
al.UIElements.Dropdown.Frame.Frame.TextLabel.Text=(aq==""and"--"or aq)
end
function al.Refresh(ao,ap)
for aq,ar in next,al.UIElements.Menu.Frame.ScrollingFrame:GetChildren()do
if not ar:IsA"UIListLayout"then
ar:Destroy()
end
end
al.Tabs={}
for as,at in next,ap do
local au={
Name=at,
Selected=false,
UIElements={},
}
au.UIElements.TabItem=af.NewRoundFrame(ai.MenuCorner-ai.MenuPadding,"Squircle",{
Size=UDim2.new(1,0,0,36),
ImageTransparency=1,
Parent=al.UIElements.Menu.Frame.ScrollingFrame,
ImageColor3=Color3.new(1,1,1),
},{
af.NewRoundFrame(ai.MenuCorner-ai.MenuPadding,"SquircleOutline",{
Size=UDim2.new(1,0,1,0),
ImageColor3=Color3.new(1,1,1),
ImageTransparency=1,
Name="Highlight",
},{
ag("UIGradient",{
Rotation=80,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.0,Color3.fromRGB(255,255,255)),
},
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0.0,0.1),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1.0,0.1),
}
}),
}),
ag("Frame",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
},{
ag("UIPadding",{
PaddingLeft=UDim.new(0,ai.TabPadding),
PaddingRight=UDim.new(0,ai.TabPadding),
}),
ag("UICorner",{
CornerRadius=UDim.new(0,ai.MenuCorner-ai.MenuPadding)
}),
ag("TextLabel",{
Text=at,
TextXAlignment="Left",
FontFace=Font.new(af.Font,Enum.FontWeight.Regular),
ThemeTag={
TextColor3="Text",
BackgroundColor3="Text"
},
TextSize=15,
BackgroundTransparency=1,
TextTransparency=.4,
AutomaticSize="Y",
Size=UDim2.new(1,0,0,0),
AnchorPoint=Vector2.new(0,0.5),
Position=UDim2.new(0,0,0.5,0),
})
})
},true)
if al.Multi then
au.Selected=table.find(al.Value or{},au.Name)
else
au.Selected=al.Value==au.Name
end
if au.Selected then
au.UIElements.TabItem.ImageTransparency=.95
au.UIElements.TabItem.Highlight.ImageTransparency=.75
au.UIElements.TabItem.Frame.TextLabel.TextTransparency=0.05
end
al.Tabs[as]=au
al:Display()
local function Callback()
al:Display()
task.spawn(function()
af.SafeCallback(al.Callback,al.Value)
end)
end
af.AddSignal(au.UIElements.TabItem.MouseButton1Click,function()
if al.Multi then
if not au.Selected then
au.Selected=true
ah(au.UIElements.TabItem,0.1,{ImageTransparency=.95}):Play()
ah(au.UIElements.TabItem.Highlight,0.1,{ImageTransparency=.75}):Play()
ah(au.UIElements.TabItem.Frame.TextLabel,0.1,{TextTransparency=0}):Play()
table.insert(al.Value,au.Name)
else
if not al.AllowNone and#al.Value==1 then
return
end
au.Selected=false
ah(au.UIElements.TabItem,0.1,{ImageTransparency=1}):Play()
ah(au.UIElements.TabItem.Highlight,0.1,{ImageTransparency=1}):Play()
ah(au.UIElements.TabItem.Frame.TextLabel,0.1,{TextTransparency=.4}):Play()
for av,aw in ipairs(al.Value)do
if aw==au.Name then
table.remove(al.Value,av)
break
end
end
end
else
for av,aw in next,al.Tabs do
ah(aw.UIElements.TabItem,0.1,{ImageTransparency=1}):Play()
ah(aw.UIElements.TabItem.Highlight,0.1,{ImageTransparency=1}):Play()
ah(aw.UIElements.TabItem.Frame.TextLabel,0.1,{TextTransparency=.5}):Play()
aw.Selected=false
end
au.Selected=true
ah(au.UIElements.TabItem,0.1,{ImageTransparency=.95}):Play()
ah(au.UIElements.TabItem.Highlight,0.1,{ImageTransparency=.75}):Play()
ah(au.UIElements.TabItem.Frame.TextLabel,0.1,{TextTransparency=0.05}):Play()
al.Value=au.Name
end
Callback()
end)
RecalculateCanvasSize()
RecalculateListSize()
end
local au=0
for av,aw in next,al.Tabs do
if aw.UIElements.TabItem.Frame.TextLabel then
local ax=aw.UIElements.TabItem.Frame.TextLabel.TextBounds.X
au=math.max(au,ax)
end
end
al.UIElements.MenuCanvas.Size=UDim2.new(0,au+6+6+5+5+18+6+6,al.UIElements.MenuCanvas.Size.Y.Scale,al.UIElements.MenuCanvas.Size.Y.Offset)
end
al:Refresh(al.Values)
RecalculateListSize()
function al.Select(ao,ap)
if ap then
al.Value=ap
else
if al.Multi then
al.Value={}
else
al.Value=nil
end
end
al:Refresh(al.Values)
end
function al.Open(ao)
if an then
al.UIElements.Menu.Visible=true
al.UIElements.MenuCanvas.Visible=true
al.UIElements.MenuCanvas.Active=true
al.UIElements.Menu.Size=UDim2.new(
1,0,
0,0
)
ah(al.UIElements.Menu,0.1,{
Size=UDim2.new(
1,0,
1,0
),
ImageTransparency=0.05
},Enum.EasingStyle.Quart,Enum.EasingDirection.Out):Play()
task.spawn(function()
task.wait(.1)
al.Opened=true
end)
UpdatePosition()
end
end
function al.Close(ao)
al.Opened=false
ah(al.UIElements.Menu,0.25,{
Size=UDim2.new(
1,0,
0,0
),
ImageTransparency=1,
},Enum.EasingStyle.Quart,Enum.EasingDirection.Out):Play()
task.spawn(function()
task.wait(.1)
al.UIElements.Menu.Visible=false
end)
task.spawn(function()
task.wait(.25)
al.UIElements.MenuCanvas.Visible=false
al.UIElements.MenuCanvas.Active=false
end)
end
af.AddSignal(al.UIElements.Dropdown.MouseButton1Click,function()
al:Open()
end)
af.AddSignal(aa.InputBegan,function(ao)
if
ao.UserInputType==Enum.UserInputType.MouseButton1
or ao.UserInputType==Enum.UserInputType.Touch
then
local ap,ar=al.UIElements.MenuCanvas.AbsolutePosition,al.UIElements.MenuCanvas.AbsoluteSize
if
ak.Window.CanDropdown
and al.Opened
and(ac.X<ap.X
or ac.X>ap.X+ar.X
or ac.Y<(ap.Y-20-1)
or ac.Y>ap.Y+ar.Y
)
then
al:Close()
end
end
end)
af.AddSignal(al.UIElements.Dropdown:GetPropertyChangedSignal"AbsolutePosition",UpdatePosition)
return al.__type,al
end
return ai end function a.M()
local aa=a.load'a'
local ac=aa.New
local ad=aa.Tween
local ae={}
function ae.New(af,ag)
local ah={
__type="Section",
Title=ag.Title or"Section",
Icon=ag.Icon,
TextXAlignment=ag.TextXAlignment or"Left",
TextSize=ag.TextSize or 19,
UIElements={},
HeaderSize=42,
IconSize=24,
Elements={},
Expandable=false,
}
local ai
function ah.SetIcon(ak,al)
ah.Icon=al or nil
if ai then ai:Destroy()end
if al then
ai=aa.Image(
al,
al..":"..ah.Title,
0,
ag.Window.Folder,
ah.__type,
true
)
ai.Size=UDim2.new(0,ah.IconSize,0,ah.IconSize)
end
end
local ak=ac("Frame",{
Size=UDim2.new(0,ai.IconSize,0,ai.IconSize),
BackgroundTransparency=1,
Visible=false
},{
ac("ImageLabel",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
Image=aa.Icon"chevron-down"[1],
ImageRectSize=aa.Icon"chevron-down"[2].ImageRectSize,
ImageRectOffset=aa.Icon"chevron-down"[2].ImageRectPosition,
ThemeTag={
ImageColor3="Icon",
},
ImageTransparency=.7,
})
})
if ah.Icon then
ah:SetIcon(ah.Icon)
end
local al=ac("TextLabel",{
BackgroundTransparency=1,
TextXAlignment="Left",
AutomaticSize="Y",
TextSize=ah.TextSize,
ThemeTag={
TextColor3="Text",
},
FontFace=Font.new(aa.Font,Enum.FontWeight.SemiBold),
Text=ah.Title,
Size=UDim2.new(
1,
ai and(-ah.IconSize-8)*2
or(-ah.IconSize-8),
1,
0
),
TextWrapped=true,
})
local am=ac("Frame",{
Size=UDim2.new(1,0,0,ah.HeaderSize),
BackgroundTransparency=1,
Parent=ag.Parent,
ClipsDescendants=true,
},{
ac("TextButton",{
Size=UDim2.new(1,0,0,ah.HeaderSize),
BackgroundTransparency=1,
Text="",
},{
ai,
al,
ac("UIListLayout",{
Padding=UDim.new(0,8),
FillDirection="Horizontal",
VerticalAlignment="Center",
HorizontalAlignment=not ai and ah.TextXAlignment or"Left",
}),
ac("UIPadding",{
PaddingTop=UDim.new(0,4),
PaddingBottom=UDim.new(0,2),
}),
ak,
}),
ac("Frame",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,0,0),
AutomaticSize="Y",
Name="Content",
Visible=true,
Position=UDim2.new(0,0,0,ah.HeaderSize)
},{
ac("UIListLayout",{
FillDirection="Vertical",
Padding=UDim.new(0,6),
VerticalAlignment="Bottom",
}),
})
})
local an=ag.ElementsModule
an.Load(ah,am.Content,an.Elements,ag.Window,ag.WindUI,function()
if not ah.Expandable then
ah.Expandable=true
ak.Visible=true
end
end)
function ah.SetTitle(ao,ap)
al.Text=ap
end
function ah.Destroy(ao)
for ap,ar in next,ah.Elements do
ar:Destroy()
end
am:Destroy()
end
function ah.Open(ao)
if ah.Expandable then
ah.Opened=true
ad(am,0.33,{
Size=UDim2.new(1,0,0,ah.HeaderSize+(am.Content.AbsoluteSize.Y/ag.UIScale))
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
ad(ak.ImageLabel,0.1,{Rotation=180},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
end
function ah.Close(ao)
if ah.Expandable then
ah.Opened=false
ad(am,0.26,{
Size=UDim2.new(1,0,0,ah.HeaderSize)
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
ad(ak.ImageLabel,0.1,{Rotation=0},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
end
aa.AddSignal(am.TextButton.MouseButton1Click,function()
if ah.Expandable then
if ah.Opened then
ah:Close()
else
ah:Open()
end
end
end)
if ah.Opened then
task.spawn(function()
task.wait()
ah:Open()
end)
end
return ah.__type,ah
end
return ae end function a.N()
local aa=a.load'a'
local ac=aa.New
local ae={}
function ae.New(af,ag)
local ah=ac("Frame",{
Size=UDim2.new(1,0,0,1),
Position=UDim2.new(0.5,0,0.5,0),
AnchorPoint=Vector2.new(0.5,0.5),
BackgroundTransparency=.9,
ThemeTag={
BackgroundColor3="Text"
}
})
ac("Frame",{
Parent=ag.Parent,
Size=UDim2.new(1,-7,0,5),
BackgroundTransparency=1,
},{
ah
})
return"Divider",{}
end
return ae end function a.O()
return{
Elements={
Paragraph=a.load'z',
Button=a.load'A',
Toggle=a.load'D',
Slider=a.load'E',
Keybind=a.load'F',
Input=a.load'G',
Dropdown=a.load'H',
Section=a.load'M',
Divider=a.load'N',
},
Load=function(aa,ac,ae,af,ag,ah,ai,aj)
for ak,al in pairs(ae)do
aa[ak]=function(am,an)
an=an or{}
an.Parent=ac
an.Window=af
an.WindUI=ag
an.UIScale=aj
an.ElementsModule=ai local
ao, ap=al:New(an)
table.insert(aa.Elements,ap)
local ar
for as,at in pairs(ap)do
if typeof(at)=="table"and as:match"Frame$"then
ar=at
break
end
end
if ar then
function ap.SetTitle(au,av)
ar:SetTitle(av)
end
function ap.SetDesc(au,av)
ar:SetDesc(av)
end
function ap.Destroy(au)
ar:Destroy()
end
end
if ah then
ah()
end
return ap
end
end
end
}end function a.P()
game:GetService"UserInputService"
local aa=game.Players.LocalPlayer:GetMouse()
local ac=a.load'a'
local ae=ac.New
local af=ac.Tween
local ag=a.load'x'.New
local ah=a.load't'.New
local ai={
Tabs={},
Containers={},
SelectedTab=nil,
TabCount=0,
ToolTipParent=nil,
TabHighlight=nil,
OnChangeFunc=function(ai)end
}
function ai.Init(aj,ak,al,am)
Window=aj
WindUI=ak
ai.ToolTipParent=al
ai.TabHighlight=am
return ai
end
function ai.New(aj,ak)
local al={
__type="Tab",
Title=aj.Title or"Tab",
Desc=aj.Desc,
Icon=aj.Icon,
IconThemed=aj.IconThemed,
Locked=aj.Locked,
ShowTabTitle=aj.ShowTabTitle,
Selected=false,
Index=nil,
Parent=aj.Parent,
UIElements={},
Elements={},
ContainerFrame=nil,
UICorner=Window.UICorner-(Window.UIPadding/2),
}
ai.TabCount=ai.TabCount+1
local am=ai.TabCount
al.Index=am
al.UIElements.Main=ac.NewRoundFrame(al.UICorner,"Squircle",{
BackgroundTransparency=1,
Size=UDim2.new(1,-7,0,0),
AutomaticSize="Y",
Parent=aj.Parent,
ThemeTag={
ImageColor3="Text",
},
ImageTransparency=1,
},{
ac.NewRoundFrame(al.UICorner,"SquircleOutline",{
Size=UDim2.new(1,0,1,0),
ThemeTag={
ImageColor3="Text",
},
ImageTransparency=1,
Name="Outline"
},{
ae("UIGradient",{
Rotation=80,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.0,Color3.fromRGB(255,255,255)),
},
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0.0,0.1),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1.0,0.1),
}
}),
}),
ac.NewRoundFrame(al.UICorner,"Squircle",{
Size=UDim2.new(1,0,0,0),
AutomaticSize="Y",
ThemeTag={
ImageColor3="Text",
},
ImageTransparency=1,
Name="Frame",
},{
ae("UIListLayout",{
SortOrder="LayoutOrder",
Padding=UDim.new(0,10),
FillDirection="Horizontal",
VerticalAlignment="Center",
}),
ae("TextLabel",{
Text=al.Title,
ThemeTag={
TextColor3="Text"
},
TextTransparency=not al.Locked and 0.4 or.7,
TextSize=15,
Size=UDim2.new(1,0,0,0),
FontFace=Font.new(ac.Font,Enum.FontWeight.Medium),
TextWrapped=true,
RichText=true,
AutomaticSize="Y",
LayoutOrder=2,
TextXAlignment="Left",
BackgroundTransparency=1,
}),
ae("UIPadding",{
PaddingTop=UDim.new(0,2+(Window.UIPadding/2)),
PaddingLeft=UDim.new(0,4+(Window.UIPadding/2)),
PaddingRight=UDim.new(0,4+(Window.UIPadding/2)),
PaddingBottom=UDim.new(0,2+(Window.UIPadding/2)),
})
}),
},true)
local an=0
local ao
local ap
if al.Icon then
ao=ac.Image(
al.Icon,
al.Icon..":"..al.Title,
0,
Window.Folder,
al.__type,
true,
al.IconThemed
)
ao.Size=UDim2.new(0,16,0,16)
ao.Parent=al.UIElements.Main.Frame
ao.ImageLabel.ImageTransparency=not al.Locked and 0 or.7
al.UIElements.Main.Frame.TextLabel.Size=UDim2.new(1,-30,0,0)
an=-30
al.UIElements.Icon=ao
ap=ac.Image(
al.Icon,
al.Icon..":"..al.Title,
0,
Window.Folder,
al.__type,
true,
al.IconThemed
)
ap.Size=UDim2.new(0,16,0,16)
ap.ImageLabel.ImageTransparency=not al.Locked and 0 or.7
an=-30
end
al.UIElements.ContainerFrame=ae("ScrollingFrame",{
Size=UDim2.new(1,0,1,al.ShowTabTitle and-((Window.UIPadding*2.4)+12)or 0),
BackgroundTransparency=1,
ScrollBarThickness=0,
ElasticBehavior="Never",
CanvasSize=UDim2.new(0,0,0,0),
AnchorPoint=Vector2.new(0,1),
Position=UDim2.new(0,0,1,0),
AutomaticCanvasSize="Y",
ScrollingDirection="Y",
},{
ae("UIPadding",{
PaddingTop=UDim.new(0,20),
PaddingLeft=UDim.new(0,20),
PaddingRight=UDim.new(0,20),
PaddingBottom=UDim.new(0,20),
}),
ae("UIListLayout",{
SortOrder="LayoutOrder",
Padding=UDim.new(0,6),
HorizontalAlignment="Center",
})
})
al.UIElements.ContainerFrameCanvas=ae("Frame",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
Visible=false,
Parent=Window.UIElements.MainBar,
ZIndex=5,
},{
al.UIElements.ContainerFrame,
ae("Frame",{
Size=UDim2.new(1,0,0,((Window.UIPadding*2.4)+12)),
BackgroundTransparency=1,
Visible=al.ShowTabTitle or false,
Name="TabTitle"
},{
ap,
ae("TextLabel",{
Text=al.Title,
ThemeTag={
TextColor3="Text"
},
TextSize=20,
TextTransparency=.1,
Size=UDim2.new(1,-an,1,0),
FontFace=Font.new(ac.Font,Enum.FontWeight.SemiBold),
TextTruncate="AtEnd",
RichText=true,
LayoutOrder=2,
TextXAlignment="Left",
BackgroundTransparency=1,
}),
ae("UIPadding",{
PaddingTop=UDim.new(0,20),
PaddingLeft=UDim.new(0,20),
PaddingRight=UDim.new(0,20),
PaddingBottom=UDim.new(0,20),
}),
ae("UIListLayout",{
SortOrder="LayoutOrder",
Padding=UDim.new(0,10),
FillDirection="Horizontal",
VerticalAlignment="Center",
})
}),
ae("Frame",{
Size=UDim2.new(1,0,0,1),
BackgroundTransparency=.9,
ThemeTag={
BackgroundColor3="Text"
},
Position=UDim2.new(0,0,0,((Window.UIPadding*2.4)+12)),
Visible=al.ShowTabTitle or false,
})
})
ai.Containers[am]=al.UIElements.ContainerFrameCanvas
ai.Tabs[am]=al
al.ContainerFrame=ContainerFrameCanvas
ac.AddSignal(al.UIElements.Main.MouseButton1Click,function()
if not al.Locked then
ai:SelectTab(am)
end
end)
ah(al.UIElements.ContainerFrame,al.UIElements.ContainerFrameCanvas,Window,3)
local ar
local as
local at
local au=false
if al.Desc then
ac.AddSignal(al.UIElements.Main.InputBegan,function()
au=true
as=task.spawn(function()
task.wait(0.35)
if au and not ar then
ar=ag(al.Desc,ai.ToolTipParent)
local function updatePosition()
if ar then
ar.Container.Position=UDim2.new(0,aa.X,0,aa.Y-20)
end
end
updatePosition()
at=aa.Move:Connect(updatePosition)
ar:Open()
end
end)
end)
end
ac.AddSignal(al.UIElements.Main.MouseEnter,function()
if not al.Locked then
af(al.UIElements.Main.Frame,0.08,{ImageTransparency=.97}):Play()
end
end)
ac.AddSignal(al.UIElements.Main.InputEnded,function()
if al.Desc then
au=false
if as then
task.cancel(as)
as=nil
end
if at then
at:Disconnect()
at=nil
end
if ar then
ar:Close()
ar=nil
end
end
if not al.Locked then
af(al.UIElements.Main.Frame,0.08,{ImageTransparency=1}):Play()
end
end)
local av=a.load'O'
av.Load(al,al.UIElements.ContainerFrame,av.Elements,Window,WindUI,nil,av,ak)
task.spawn(function()
local aw=ae("Frame",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,1,-Window.UIElements.Main.Main.Topbar.AbsoluteSize.Y),
Parent=al.UIElements.ContainerFrame
},{
ae("UIListLayout",{
Padding=UDim.new(0,8),
SortOrder="LayoutOrder",
VerticalAlignment="Center",
HorizontalAlignment="Center",
FillDirection="Vertical",
}),
ae("ImageLabel",{
Size=UDim2.new(0,48,0,48),
Image=ac.Icon"frown"[1],
ImageRectOffset=ac.Icon"frown"[2].ImageRectPosition,
ImageRectSize=ac.Icon"frown"[2].ImageRectSize,
ThemeTag={
ImageColor3="Icon"
},
BackgroundTransparency=1,
ImageTransparency=.6,
}),
ae("TextLabel",{
AutomaticSize="XY",
Text="This tab is empty",
ThemeTag={
TextColor3="Text"
},
TextSize=18,
TextTransparency=.5,
BackgroundTransparency=1,
FontFace=Font.new(ac.Font,Enum.FontWeight.Medium),
})
})
ac.AddSignal(al.UIElements.ContainerFrame.ChildAdded,function()
aw.Visible=false
end)
end)
return al
end
function ai.OnChange(aj,ak)
ai.OnChangeFunc=ak
end
function ai.SelectTab(aj,ak)
if not ai.Tabs[ak].Locked then
ai.SelectedTab=ak
for al,am in next,ai.Tabs do
if not am.Locked then
af(am.UIElements.Main,0.15,{ImageTransparency=1}):Play()
af(am.UIElements.Main.Outline,0.15,{ImageTransparency=1}):Play()
af(am.UIElements.Main.Frame.TextLabel,0.15,{TextTransparency=0.3}):Play()
if am.UIElements.Icon then
af(am.UIElements.Icon.ImageLabel,0.15,{ImageTransparency=0.4}):Play()
end
am.Selected=false
end
end
af(ai.Tabs[ak].UIElements.Main,0.15,{ImageTransparency=0.95}):Play()
af(ai.Tabs[ak].UIElements.Main.Outline,0.15,{ImageTransparency=0.85}):Play()
af(ai.Tabs[ak].UIElements.Main.Frame.TextLabel,0.15,{TextTransparency=0}):Play()
if ai.Tabs[ak].UIElements.Icon then
af(ai.Tabs[ak].UIElements.Icon.ImageLabel,0.15,{ImageTransparency=0.1}):Play()
end
ai.Tabs[ak].Selected=true
task.spawn(function()
for an,ao in next,ai.Containers do
ao.AnchorPoint=Vector2.new(0,0.05)
ao.Visible=false
end
ai.Containers[ak].Visible=true
af(ai.Containers[ak],0.15,{AnchorPoint=Vector2.new(0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out):Play()
end)
ai.OnChangeFunc(ak)
end
end
return ai end function a.Q()
local aa={}
local ac=a.load'a'
local ae=ac.New
local af=ac.Tween
local ag=a.load'P'
function aa.New(ah,ai,aj,ak)
local al={
Title=ah.Title or"Section",
Icon=ah.Icon,
IconThemed=ah.IconThemed,
Opened=ah.Opened or false,
HeaderSize=42,
IconSize=18,
Expandable=false,
}
local am
if al.Icon then
am=ac.Image(
al.Icon,
al.Icon,
0,
aj,
"Section",
true,
al.IconThemed
)
am.Size=UDim2.new(0,al.IconSize,0,al.IconSize)
am.ImageLabel.ImageTransparency=.25
end
local an=ae("Frame",{
Size=UDim2.new(0,al.IconSize,0,al.IconSize),
BackgroundTransparency=1,
Visible=false
},{
ae("ImageLabel",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
Image=ac.Icon"chevron-down"[1],
ImageRectSize=ac.Icon"chevron-down"[2].ImageRectSize,
ImageRectOffset=ac.Icon"chevron-down"[2].ImageRectPosition,
ThemeTag={
ImageColor3="Icon",
},
ImageTransparency=.7,
})
})
local ao=ae("Frame",{
Size=UDim2.new(1,0,0,al.HeaderSize),
BackgroundTransparency=1,
Parent=ai,
ClipsDescendants=true,
},{
ae("TextButton",{
Size=UDim2.new(1,0,0,al.HeaderSize),
BackgroundTransparency=1,
Text="",
},{
am,
ae("TextLabel",{
Text=al.Title,
TextXAlignment="Left",
Size=UDim2.new(
1,
am and(-al.IconSize-10)*2
or(-al.IconSize-10),
1,
0
),
ThemeTag={
TextColor3="Text",
},
FontFace=Font.new(ac.Font,Enum.FontWeight.SemiBold),
TextSize=14,
BackgroundTransparency=1,
TextTransparency=.7,
TextWrapped=true
}),
ae("UIListLayout",{
FillDirection="Horizontal",
VerticalAlignment="Center",
Padding=UDim.new(0,10)
}),
an,
ae("UIPadding",{
PaddingLeft=UDim.new(0,11),
PaddingRight=UDim.new(0,11),
})
}),
ae("Frame",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,0,0),
AutomaticSize="Y",
Name="Content",
Visible=true,
Position=UDim2.new(0,0,0,al.HeaderSize)
},{
ae("UIListLayout",{
FillDirection="Vertical",
Padding=UDim.new(0,0),
VerticalAlignment="Bottom",
}),
})
})
function al.Tab(ap,ar)
if not al.Expandable then
al.Expandable=true
an.Visible=true
end
ar.Parent=ao.Content
return ag.New(ar,ak)
end
function al.Open(ap)
if al.Expandable then
al.Opened=true
af(ao,0.33,{
Size=UDim2.new(1,0,0,al.HeaderSize+(ao.Content.AbsoluteSize.Y/ak))
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
af(an.ImageLabel,0.1,{Rotation=180},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
end
function al.Close(ap)
if al.Expandable then
al.Opened=false
af(ao,0.26,{
Size=UDim2.new(1,0,0,al.HeaderSize)
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
af(an.ImageLabel,0.1,{Rotation=0},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
end
ac.AddSignal(ao.TextButton.MouseButton1Click,function()
if al.Expandable then
if al.Opened then
al:Close()
else
al:Open()
end
end
end)
if al.Opened then
task.spawn(function()
task.wait()
al:Open()
end)
end
return al
end
return aa end function a.R()
return{
Tab="table-of-contents",
Paragraph="type",
Button="square-mouse-pointer",
Toggle="toggle-right",
Slider="sliders-horizontal",
Keybind="command",
Input="text-cursor-input",
Dropdown="chevrons-up-down",
}end function a.s()
local aa={}
local ab=a.load'a'
local ac=ab.New local ad=
ab.Tween
function aa.New(ae,af,ag)
local ah=10
local ai
if af and af~=""then
ai=ac("ImageLabel",{
Image=ab.Icon(af)[1],
ImageRectSize=ab.Icon(af)[2].ImageRectSize,
ImageRectOffset=ab.Icon(af)[2].ImageRectPosition,
Size=UDim2.new(0,21,0,21),
BackgroundTransparency=1,
ThemeTag={
ImageColor3="Icon",
}
})
end
local aj=ac("TextLabel",{
BackgroundTransparency=1,
TextSize=17,
FontFace=Font.new(ab.Font,Enum.FontWeight.Regular),
Size=UDim2.new(1,ai and-29 or 0,1,0),
TextXAlignment="Left",
ThemeTag={
TextColor3="Text",
},
Text=ae,
})
local ak=ac("TextButton",{
Size=UDim2.new(1,0,0,42),
Parent=ag,
BackgroundTransparency=1,
Text="",
},{
ac("Frame",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
},{
ab.NewRoundFrame(ah,"Squircle",{
ThemeTag={
ImageColor3="Accent",
},
Size=UDim2.new(1,0,1,0),
ImageTransparency=.85,
}),
ab.NewRoundFrame(ah,"SquircleOutline",{
ThemeTag={
ImageColor3="Outline",
},
Size=UDim2.new(1,0,1,0),
ImageTransparency=.9,
},{
ac("UIGradient",{
Rotation=70,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.0,Color3.fromRGB(255,255,255)),
},
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0.0,0.1),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1.0,0.1),
}
})
}),
ab.NewRoundFrame(ah,"Squircle",{
Size=UDim2.new(1,0,1,0),
Name="Frame",
ImageColor3=Color3.new(1,1,1),
ImageTransparency=.95
},{
ac("UIPadding",{
PaddingLeft=UDim.new(0,12),
PaddingRight=UDim.new(0,12),
}),
ac("UIListLayout",{
FillDirection="Horizontal",
Padding=UDim.new(0,8),
VerticalAlignment="Center",
HorizontalAlignment="Left",
}),
ai,
aj,
})
})
})
return ak
end
return aa end function a.t()
local aa={}
local ab=game:GetService"UserInputService"
local ac=a.load'a'
local ad=ac.New local ae=
ac.Tween
function aa.New(af,ag,ah,ai)
local aj=ad("Frame",{
Size=UDim2.new(0,ai,1,0),
BackgroundTransparency=1,
Position=UDim2.new(1,0,0,0),
AnchorPoint=Vector2.new(1,0),
Parent=ag,
ZIndex=999,
Active=true,
})
local ak=ac.NewRoundFrame(ai/2,"Squircle",{
Size=UDim2.new(1,0,0,0),
ImageTransparency=0.85,
ThemeTag={ImageColor3="Text"},
Parent=aj,
})
local al=ad("Frame",{
Size=UDim2.new(1,12,1,12),
Position=UDim2.new(0.5,0,0.5,0),
AnchorPoint=Vector2.new(0.5,0.5),
BackgroundTransparency=1,
Active=true,
ZIndex=999,
Parent=ak,
})
local am=false
local an=0
local function updateSliderSize()
local ao=af
local ap=ao.AbsoluteCanvasSize.Y
local aq=ao.AbsoluteWindowSize.Y
if ap<=aq then
ak.Visible=false
return
end
local ar=math.clamp(aq/ap,0.1,1)
ak.Size=UDim2.new(1,0,ar,0)
ak.Visible=true
end
local function updateScrollingFramePosition()
local ao=ak.Position.Y.Scale
local ap=af.AbsoluteCanvasSize.Y
local aq=af.AbsoluteWindowSize.Y
local ar=math.max(ap-aq,0)
if ar<=0 then return end
local as=math.max(1-ak.Size.Y.Scale,0)
if as<=0 then return end
local at=ao/as
af.CanvasPosition=Vector2.new(
af.CanvasPosition.X,
at*ar
)
end
local function updateThumbPosition()
if am then return end
local ao=af.CanvasPosition.Y
local ap=af.AbsoluteCanvasSize.Y
local aq=af.AbsoluteWindowSize.Y
local ar=math.max(ap-aq,0)
if ar<=0 then
ak.Position=UDim2.new(0,0,0,0)
return
end
local as=ao/ar
local at=math.max(1-ak.Size.Y.Scale,0)
local au=math.clamp(as*at,0,at)
ak.Position=UDim2.new(0,0,au,0)
end
ac.AddSignal(aj.InputBegan,function(ao)
if(ao.UserInputType==Enum.UserInputType.MouseButton1 or ao.UserInputType==Enum.UserInputType.Touch)then
local ap=ak.AbsolutePosition.Y
local aq=ap+ak.AbsoluteSize.Y
if not(ao.Position.Y>=ap and ao.Position.Y<=aq)then
local ar=aj.AbsolutePosition.Y
local as=aj.AbsoluteSize.Y
local at=ak.AbsoluteSize.Y
local au=ao.Position.Y-ar-at/2
local av=as-at
local aw=math.clamp(au/av,0,1-ak.Size.Y.Scale)
ak.Position=UDim2.new(0,0,aw,0)
updateScrollingFramePosition()
end
end
end)
ac.AddSignal(al.InputBegan,function(ao)
if ao.UserInputType==Enum.UserInputType.MouseButton1 or ao.UserInputType==Enum.UserInputType.Touch then
am=true
an=ao.Position.Y-ak.AbsolutePosition.Y
local ap
local aq
ap=ab.InputChanged:Connect(function(ar)
if ar.UserInputType==Enum.UserInputType.MouseMovement or ar.UserInputType==Enum.UserInputType.Touch then
local as=aj.AbsolutePosition.Y
local at=aj.AbsoluteSize.Y
local au=ak.AbsoluteSize.Y
local av=ar.Position.Y-as-an
local aw=at-au
local ax=math.clamp(av/aw,0,1-ak.Size.Y.Scale)
ak.Position=UDim2.new(0,0,ax,0)
updateScrollingFramePosition()
end
end)
aq=ab.InputEnded:Connect(function(ar)
if ar.UserInputType==Enum.UserInputType.MouseButton1 or ar.UserInputType==Enum.UserInputType.Touch then
am=false
if ap then ap:Disconnect()end
if aq then aq:Disconnect()end
end
end)
end
end)
ac.AddSignal(af:GetPropertyChangedSignal"AbsoluteWindowSize",function()
updateSliderSize()
updateThumbPosition()
end)
ac.AddSignal(af:GetPropertyChangedSignal"AbsoluteCanvasSize",function()
updateSliderSize()
updateThumbPosition()
end)
ac.AddSignal(af:GetPropertyChangedSignal"CanvasPosition",function()
if not am then
updateThumbPosition()
end
end)
updateSliderSize()
updateThumbPosition()
return aj
end
return aa end function a.T()
local aa=game:GetService"UserInputService"
game:GetService"RunService"
local ac=workspace.CurrentCamera
local ae=a.load'q'
local af=a.load'a'
local ag=af.New
local ah=af.Tween
local ai={
UICorner=8,
UIPadding=8,
}
local aj=a.load'j'.New
local ak=a.load'k'.New
local al=a.load't'.New
local am=a.load'u'
local an=a.load'v'
return function(ao)
local ap={
Title=ao.Title or"UI Library",
Author=ao.Author,
Icon=ao.Icon,
IconThemed=ao.IconThemed,
Folder=ao.Folder,
Resizable=ao.Resizable,
Background=ao.Background,
BackgroundImageTransparency=ao.BackgroundImageTransparency or 0,
User=ao.User or{},
Size=ao.Size and UDim2.new(
0,math.clamp(ao.Size.X.Offset,560,700),
0,math.clamp(ao.Size.Y.Offset,350,520))or UDim2.new(0,580,0,460),
ToggleKey=ao.ToggleKey or Enum.KeyCode.G,
Transparent=ao.Transparent or false,
HideSearchBar=ao.HideSearchBar,
ScrollBarEnabled=ao.ScrollBarEnabled or false,
SideBarWidth=ao.SideBarWidth or 200,
Acrylic=ao.Acrylic or false,
Position=UDim2.new(0.5,0,0.5,0),
IconSize=22,
UICorner=16,
UIPadding=14,
UIElements={},
CanDropdown=true,
Closed=false,
Parent=ao.Parent,
Destroyed=false,
IsFullscreen=false,
CanResize=false,
IsOpenButtonEnabled=true,
ConfigManager=nil,
AcrylicPaint=nil,
CurrentTab=nil,
TabModule=nil,
OnCloseCallback=nil,
OnDestroyCallback=nil,
TopBarButtons={},
}
if ap.HideSearchBar~=false then
ap.HideSearchBar=true
end
if ap.Resizable~=false then
ap.CanResize=true
ap.Resizable=true
end
if ap.Folder then
makefolder("WindUI/"..ap.Folder)
end local
ar, as=ae.AcrylicPaint{UseAcrylic=ap.Acrylic}
ap.AcrylicPaint=ar
local at=ag("UICorner",{
CornerRadius=UDim.new(0,ap.UICorner)
})
if ap.Folder then
ap.ConfigManager=an:Init(ap)
end
local au=ag("Frame",{
Size=UDim2.new(0,32,0,32),
Position=UDim2.new(1,0,1,0),
AnchorPoint=Vector2.new(.5,.5),
BackgroundTransparency=1,
ZIndex=99,
Active=true
},{
ag("ImageLabel",{
Size=UDim2.new(0,96,0,96),
BackgroundTransparency=1,
Image="rbxassetid://120997033468887",
Position=UDim2.new(0.5,-16,0.5,-16),
AnchorPoint=Vector2.new(0.5,0.5),
ImageTransparency=1,
})
})
local av=af.NewRoundFrame(ap.UICorner,"Squircle",{
Size=UDim2.new(1,0,1,0),
ImageTransparency=1,
ImageColor3=Color3.new(0,0,0),
ZIndex=98,
Active=false,
},{
ag("ImageLabel",{
Size=UDim2.new(0,70,0,70),
Image=af.Icon"expand"[1],
ImageRectOffset=af.Icon"expand"[2].ImageRectPosition,
ImageRectSize=af.Icon"expand"[2].ImageRectSize,
BackgroundTransparency=1,
Position=UDim2.new(0.5,0,0.5,0),
AnchorPoint=Vector2.new(0.5,0.5),
ImageTransparency=1,
}),
})
local aw=af.NewRoundFrame(ap.UICorner,"Squircle",{
Size=UDim2.new(1,0,1,0),
ImageTransparency=1,
ImageColor3=Color3.new(0,0,0),
ZIndex=999,
Active=false,
})
ap.UIElements.SideBar=ag("ScrollingFrame",{
Size=UDim2.new(
1,
ap.ScrollBarEnabled and-3-(ap.UIPadding/2)or 0,
1,
not ap.HideSearchBar and-45 or 0
),
Position=UDim2.new(0,0,1,0),
AnchorPoint=Vector2.new(0,1),
BackgroundTransparency=1,
ScrollBarThickness=0,
ElasticBehavior="Never",
CanvasSize=UDim2.new(0,0,0,0),
AutomaticCanvasSize="Y",
ScrollingDirection="Y",
ClipsDescendants=true,
VerticalScrollBarPosition="Left",
},{
ag("Frame",{
BackgroundTransparency=1,
AutomaticSize="Y",
Size=UDim2.new(1,0,0,0),
Name="Frame",
},{
ag("UIPadding",{
PaddingTop=UDim.new(0,ap.UIPadding/2),
PaddingBottom=UDim.new(0,ap.UIPadding/2),
}),
ag("UIListLayout",{
SortOrder="LayoutOrder",
Padding=UDim.new(0,0)
})
}),
ag("UIPadding",{
PaddingLeft=UDim.new(0,ap.UIPadding/2),
PaddingRight=UDim.new(0,ap.UIPadding/2),
}),
})
ap.UIElements.SideBarContainer=ag("Frame",{
Size=UDim2.new(0,ap.SideBarWidth,1,ap.User.Enabled and-94-(ap.UIPadding*2)or-52),
Position=UDim2.new(0,0,0,52),
BackgroundTransparency=1,
Visible=true,
},{
ag("Frame",{
Name="Content",
BackgroundTransparency=1,
Size=UDim2.new(
1,
0,
1,
not ap.HideSearchBar and-45-ap.UIPadding/2 or 0
),
Position=UDim2.new(0,0,1,0),
AnchorPoint=Vector2.new(0,1),
}),
ap.UIElements.SideBar,
})
if ap.ScrollBarEnabled then
al(ap.UIElements.SideBar,ap.UIElements.SideBarContainer.Content,ap,3)
end
ap.UIElements.MainBar=ag("Frame",{
Size=UDim2.new(1,-ap.UIElements.SideBarContainer.AbsoluteSize.X,1,-52),
Position=UDim2.new(1,0,1,0),
AnchorPoint=Vector2.new(1,1),
BackgroundTransparency=1,
},{
af.NewRoundFrame(ap.UICorner-(ap.UIPadding/2),"Squircle",{
Size=UDim2.new(1,0,1,0),
ImageColor3=Color3.new(1,1,1),
ZIndex=3,
ImageTransparency=.95,
Name="Background",
}),
ag("UIPadding",{
PaddingTop=UDim.new(0,ap.UIPadding/2),
PaddingLeft=UDim.new(0,ap.UIPadding/2),
PaddingRight=UDim.new(0,ap.UIPadding/2),
PaddingBottom=UDim.new(0,ap.UIPadding/2),
})
})
local ax=ag("ImageLabel",{
Image="rbxassetid://8992230677",
ImageColor3=Color3.new(0,0,0),
ImageTransparency=1,
Size=UDim2.new(1,120,1,116),
Position=UDim2.new(0,-60,0,-58),
ScaleType="Slice",
SliceCenter=Rect.new(99,99,99,99),
BackgroundTransparency=1,
ZIndex=-999999999999999,
Name="Blur",
})
local ay
if aa.TouchEnabled and not aa.KeyboardEnabled then
ay=false
elseif aa.KeyboardEnabled then
ay=true
else
ay=nil
end
local az
local aA
if ap.User.Enabled then local
aB, aC=game.Players:GetUserThumbnailAsync(
ap.User.Anonymous and 1 or game.Players.LocalPlayer.UserId,
Enum.ThumbnailType.HeadShot,
Enum.ThumbnailSize.Size420x420
)
aA=ag("TextButton",{
Size=UDim2.new(0,
(ap.UIElements.SideBarContainer.AbsoluteSize.X)-(ap.UIPadding/2),
0,
42+(ap.UIPadding)
),
Position=UDim2.new(0,ap.UIPadding/2,1,-(ap.UIPadding/2)),
AnchorPoint=Vector2.new(0,1),
BackgroundTransparency=1,
},{
af.NewRoundFrame(ap.UICorner-(ap.UIPadding/2),"SquircleOutline",{
Size=UDim2.new(1,0,1,0),
ThemeTag={
ImageColor3="Text",
},
ImageTransparency=1,
Name="Outline"
},{
ag("UIGradient",{
Rotation=78,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.0,Color3.fromRGB(255,255,255)),
},
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0.0,0.1),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1.0,0.1),
}
}),
}),
af.NewRoundFrame(ap.UICorner-(ap.UIPadding/2),"Squircle",{
Size=UDim2.new(1,0,1,0),
ThemeTag={
ImageColor3="Text",
},
ImageTransparency=1,
Name="UserIcon",
},{
ag("ImageLabel",{
Image=aB,
BackgroundTransparency=1,
Size=UDim2.new(0,42,0,42),
ThemeTag={
BackgroundColor3="Text",
},
BackgroundTransparency=.93,
},{
ag("UICorner",{
CornerRadius=UDim.new(1,0)
})
}),
ag("Frame",{
AutomaticSize="XY",
BackgroundTransparency=1,
},{
ag("TextLabel",{
Text=ap.User.Anonymous and"Anonymous"or game.Players.LocalPlayer.DisplayName,
TextSize=17,
ThemeTag={
TextColor3="Text",
},
FontFace=Font.new(af.Font,Enum.FontWeight.SemiBold),
AutomaticSize="Y",
BackgroundTransparency=1,
Size=UDim2.new(1,-27,0,0),
TextTruncate="AtEnd",
TextXAlignment="Left",
}),
ag("TextLabel",{
Text=ap.User.Anonymous and"@anonymous"or"@"..game.Players.LocalPlayer.Name,
TextSize=15,
TextTransparency=.6,
ThemeTag={
TextColor3="Text",
},
FontFace=Font.new(af.Font,Enum.FontWeight.Medium),
AutomaticSize="Y",
BackgroundTransparency=1,
Size=UDim2.new(1,-27,0,0),
TextTruncate="AtEnd",
TextXAlignment="Left",
}),
ag("UIListLayout",{
Padding=UDim.new(0,4),
HorizontalAlignment="Left",
})
}),
ag("UIListLayout",{
Padding=UDim.new(0,ap.UIPadding),
FillDirection="Horizontal",
VerticalAlignment="Center",
}),
ag("UIPadding",{
PaddingLeft=UDim.new(0,ap.UIPadding/2),
PaddingRight=UDim.new(0,ap.UIPadding/2),
})
})
})
if ap.User.Callback then
af.AddSignal(aA.MouseButton1Click,function()
ap.User.Callback()
end)
af.AddSignal(aA.MouseEnter,function()
ah(aA.UserIcon,0.04,{ImageTransparency=.95}):Play()
ah(aA.Outline,0.04,{ImageTransparency=.85}):Play()
end)
af.AddSignal(aA.InputEnded,function()
ah(aA.UserIcon,0.04,{ImageTransparency=1}):Play()
ah(aA.Outline,0.04,{ImageTransparency=1}):Play()
end)
end
end
local aB
local aC=false
local aD=typeof(ap.Background)=="string"and string.match(ap.Background,"^video:(.+)")or nil
if typeof(ap.Background)=="string"and aD then
aC=true
if string.find(aD,"http")then
local function SanitizeFilename(aE)
aE=aE:gsub("[%s/\\:*?\"<>|]+","-")
aE=aE:gsub("[^%w%-_%.]","")
return aE
end
local aE=ap.Folder.."/Assets/."..SanitizeFilename(aD)..".webm"
if not isfile(aE)then
local b,e=pcall(function()
local b=game:HttpGet(aD)
writefile(aE,b)
end)
if not b then
warn("[ WindUI.Background ]  Failed to download video: "..tostring(e))
return
end
end
aD=getcustomasset(aE)
end
aB=ag("VideoFrame",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,1,0),
Video=aD,
Looped=true,
Volume=0,
},{
ag("UICorner",{
CornerRadius=UDim.new(0,ap.UICorner)
}),
})
aB:Play()
elseif ap.Background then
aB=ag("ImageLabel",{
BackgroundTransparency=1,
Size=UDim2.new(1,0,1,0),
Image=typeof(ap.Background)=="string"and ap.Background or"",
ImageTransparency=1,
ScaleType="Crop",
},{
ag("UICorner",{
CornerRadius=UDim.new(0,ap.UICorner)
}),
})
end
local aE=af.NewRoundFrame(99,"Squircle",{
ImageTransparency=.8,
ImageColor3=Color3.new(1,1,1),
Size=UDim2.new(0,0,0,4),
Position=UDim2.new(0.5,0,1,4),
AnchorPoint=Vector2.new(0.5,0),
},{
ag("Frame",{
Size=UDim2.new(1,12,1,12),
BackgroundTransparency=1,
Position=UDim2.new(0.5,0,0.5,0),
AnchorPoint=Vector2.new(0.5,0.5),
Active=true,
ZIndex=99,
})
})
function createAuthor(b)
return ag("TextLabel",{
Text=b,
FontFace=Font.new(af.Font,Enum.FontWeight.Medium),
BackgroundTransparency=1,
TextTransparency=0.35,
AutomaticSize="XY",
Parent=ap.UIElements.Main and ap.UIElements.Main.Main.Topbar.Left.Title,
TextXAlignment="Left",
TextSize=13,
LayoutOrder=2,
ThemeTag={
TextColor3="Text"
},
Name="Author",
})
end
local b
local e
if ap.Author then
b=createAuthor(ap.Author)
end
local g=ag("TextLabel",{
Text=ap.Title,
FontFace=Font.new(af.Font,Enum.FontWeight.SemiBold),
BackgroundTransparency=1,
AutomaticSize="XY",
Name="Title",
TextXAlignment="Left",
TextSize=16,
ThemeTag={
TextColor3="Text"
}
})
ap.UIElements.Main=ag("Frame",{
Size=ap.Size,
Position=ap.Position,
BackgroundTransparency=1,
Parent=ao.Parent,
AnchorPoint=Vector2.new(0.5,0.5),
Active=true,
},{
ap.AcrylicPaint.Frame,
ax,
af.NewRoundFrame(ap.UICorner,"Squircle",{
ImageTransparency=1,
Size=UDim2.new(1,0,1,-240),
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,0,0.5,0),
Name="Background",
ThemeTag={
ImageColor3="Background"
},
},{
aB,
aE,
at,
}),
UIStroke,
au,
av,
aw,
ag("Frame",{
Size=UDim2.new(1,0,1,0),
BackgroundTransparency=1,
Name="Main",
Visible=false,
ZIndex=97,
},{
ag("UICorner",{
CornerRadius=UDim.new(0,ap.UICorner)
}),
ap.UIElements.SideBarContainer,
ap.UIElements.MainBar,
aA,
ag("Frame",{
Size=UDim2.new(1,0,0,52),
BackgroundTransparency=1,
Name="Topbar"
},{
ag("Frame",{
AutomaticSize="X",
Size=UDim2.new(0,0,1,0),
BackgroundTransparency=1,
Name="Left"
},{
ag("UIListLayout",{
Padding=UDim.new(0,ap.UIPadding+4),
SortOrder="LayoutOrder",
FillDirection="Horizontal",
VerticalAlignment="Center",
}),
ag("Frame",{
AutomaticSize="XY",
BackgroundTransparency=1,
Name="Title",
Size=UDim2.new(0,0,1,0),
LayoutOrder=2,
},{
ag("UIListLayout",{
Padding=UDim.new(0,0),
SortOrder="LayoutOrder",
FillDirection="Vertical",
VerticalAlignment="Center",
}),
g,
b,
}),
ag("UIPadding",{
PaddingLeft=UDim.new(0,4)
})
}),
ag("ScrollingFrame",{
Name="Center",
BackgroundTransparency=1,
AutomaticSize="Y",
ScrollBarThickness=0,
ScrollingDirection="X",
AutomaticCanvasSize="X",
CanvasSize=UDim2.new(0,0,0,0),
Size=UDim2.new(0,0,1,0),
AnchorPoint=Vector2.new(0,0.5),
Position=UDim2.new(0,0,0.5,0),
Visible=false,
},{
ag("UIListLayout",{
FillDirection="Horizontal",
VerticalAlignment="Center",
HorizontalAlignment="Left",
Padding=UDim.new(0,ap.UIPadding/2)
})
}),
ag("Frame",{
AutomaticSize="XY",
BackgroundTransparency=1,
Position=UDim2.new(1,0,0.5,0),
AnchorPoint=Vector2.new(1,0.5),
Name="Right",
},{
ag("UIListLayout",{
Padding=UDim.new(0,9),
FillDirection="Horizontal",
SortOrder="LayoutOrder",
}),
}),
ag("UIPadding",{
PaddingTop=UDim.new(0,ap.UIPadding),
PaddingLeft=UDim.new(0,ap.UIPadding),
PaddingRight=UDim.new(0,8),
PaddingBottom=UDim.new(0,ap.UIPadding),
})
})
})
})
af.AddSignal(ap.UIElements.Main.Main.Topbar.Left:GetPropertyChangedSignal"AbsoluteSize",function()
local h=0
local i=ap.UIElements.Main.Main.Topbar.Right.UIListLayout.AbsoluteContentSize.X
if g and b then
h=math.max(g.TextBounds.X,b.TextBounds.X)
else
h=g.TextBounds.X
end
if e then
h=h+ap.IconSize+ap.UIPadding+4
end
ap.UIElements.Main.Main.Topbar.Center.Position=UDim2.new(0,h+ap.UIPadding,0.5,0)
ap.UIElements.Main.Main.Topbar.Center.Size=UDim2.new(
1,
-h-i-(ap.UIPadding*2),
1,
0
)
end)
function ap.CreateTopbarButton(h,i,j,l,m,p)
local r=af.Image(
j,
j,
0,
ap.Folder,
"TopbarIcon",
true,
p
)
r.Size=UDim2.new(0,16,0,16)
r.AnchorPoint=Vector2.new(0.5,0.5)
r.Position=UDim2.new(0.5,0,0.5,0)
local x=af.NewRoundFrame(9,"Squircle",{
Size=UDim2.new(0,36,0,36),
LayoutOrder=m or 999,
Parent=ap.UIElements.Main.Main.Topbar.Right,
ZIndex=9999,
ThemeTag={
ImageColor3="Text"
},
ImageTransparency=1
},{
af.NewRoundFrame(9,"SquircleOutline",{
Size=UDim2.new(1,0,1,0),
ThemeTag={
ImageColor3="Text",
},
ImageTransparency=1,
Name="Outline"
},{
ag("UIGradient",{
Rotation=45,
Color=ColorSequence.new{
ColorSequenceKeypoint.new(0.0,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
ColorSequenceKeypoint.new(1.0,Color3.fromRGB(255,255,255)),
},
Transparency=NumberSequence.new{
NumberSequenceKeypoint.new(0.0,0.1),
NumberSequenceKeypoint.new(0.5,1),
NumberSequenceKeypoint.new(1.0,0.1),
}
}),
}),
r
},true)
ap.TopBarButtons[100-m]={
Name=i,
Object=x
}
af.AddSignal(x.MouseButton1Click,function()
l()
end)
af.AddSignal(x.MouseEnter,function()
ah(x,.15,{ImageTransparency=.93}):Play()
ah(x.Outline,.15,{ImageTransparency=.75}):Play()
end)
af.AddSignal(x.MouseLeave,function()
ah(x,.1,{ImageTransparency=1}):Play()
ah(x.Outline,.1,{ImageTransparency=1}):Play()
end)
return x
end
local h=af.Drag(
ap.UIElements.Main,
{ap.UIElements.Main.Main.Topbar,aE.Frame},
function(h,i)
if not ap.Closed then
if h and i==aE.Frame then
ah(aE,.1,{ImageTransparency=.35}):Play()
else
ah(aE,.2,{ImageTransparency=.8}):Play()
end
end
end
)
if not aC and ap.Background and typeof(ap.Background)=="table"then
local i=ag"UIGradient"
for j,l in next,ap.Background do
i[j]=l
end
ap.UIElements.BackgroundGradient=af.NewRoundFrame(ap.UICorner,"Squircle",{
Size=UDim2.new(1,0,1,0),
Parent=ap.UIElements.Main.Background,
ImageTransparency=ap.Transparent and an.WindUI.TransparencyValue or 0
},{
i
})
end
local i=a.load'w'.New(ap)
task.spawn(function()
if ap.Icon then
e=af.Image(
ap.Icon,
ap.Title,
0,
ap.Folder,
"Window",
true,
ap.IconThemed
)
e.Parent=ap.UIElements.Main.Main.Topbar.Left
e.Size=UDim2.new(0,ap.IconSize,0,ap.IconSize)
i:SetIcon(ap.Icon)
else
i:SetIcon(ap.Icon)
end
end)
function ap.SetToggleKey(j,l)
ap.ToggleKey=l
end
function ap.SetTitle(j,l)
ap.Title=l
g.Text=l
end
function ap.SetAuthor(j,l)
ap.Author=l
if not b then
b=createAuthor(ap.Author)
end
b.Text=l
end
function ap.SetBackgroundImage(j,l)
ap.UIElements.Main.Background.ImageLabel.Image=l
end
function ap.SetBackgroundImageTransparency(j,l)
ap.UIElements.Main.Background.ImageLabel.ImageTransparency=l
ap.BackgroundImageTransparency=l
end
local j
local l
af.Icon"minimize"
af.Icon"maximize"
ap:CreateTopbarButton("Fullscreen","maximize",function()
ap:ToggleFullscreen()
end,998)
function ap.ToggleFullscreen(m)
local p=ap.IsFullscreen
h:Set(p)
if not p then
j=ap.UIElements.Main.Position
l=ap.UIElements.Main.Size
ap.CanResize=false
else
if ap.Resizable then
ap.CanResize=true
end
end
ah(ap.UIElements.Main,0.45,{Size=p and l or UDim2.new(1,-20,1,-72)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
ah(ap.UIElements.Main,0.45,{Position=p and j or UDim2.new(0.5,0,0.5,26)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
ap.IsFullscreen=not p
end
ap:CreateTopbarButton("Minimize","minus",function()
ap:Close()
task.spawn(function()
task.wait(.3)
if not ay and ap.IsOpenButtonEnabled then
i:Visible(true)
end
end)
end,997)
function ap.OnClose(m,p)
ap.OnCloseCallback=p
end
function ap.OnDestroy(m,p)
ap.OnDestroyCallback=p
end
function ap.Open(m)
task.spawn(function()
task.wait(.06)
ap.Closed=false
ah(ap.UIElements.Main.Background,0.2,{
ImageTransparency=ap.Transparent and an.WindUI.TransparencyValue or 0,
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
if ap.UIElements.BackgroundGradient then
ah(ap.UIElements.BackgroundGradient,0.2,{
ImageTransparency=0,
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
ah(ap.UIElements.Main.Background,0.4,{
Size=UDim2.new(1,0,1,0),
},Enum.EasingStyle.Exponential,Enum.EasingDirection.Out):Play()
if aB then
if aB:IsA"VideoFrame"then
aB.Visible=true
end
ah(aB,0.2,{
ImageTransparency=aB:IsA"ImageLabel"and 0 or nil,
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
ah(ax,0.25,{ImageTransparency=.7},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
if UIStroke then
ah(UIStroke,0.25,{Transparency=.8},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
task.spawn(function()
task.wait(.5)
ah(aE,.45,{Size=UDim2.new(0,200,0,4),ImageTransparency=.8},Enum.EasingStyle.Exponential,Enum.EasingDirection.Out):Play()
h:Set(true)
task.wait(.45)
if ap.Resizable then
ah(av.ImageLabel,.45,{ImageTransparency=.8},Enum.EasingStyle.Exponential,Enum.EasingDirection.Out):Play()
ap.CanResize=true
end
end)
ap.CanDropdown=true
ap.UIElements.Main.Visible=true
task.spawn(function()
task.wait(.05)
ap.UIElements.Main:WaitForChild"Main".Visible=true
an.WindUI:ToggleAcrylic(true)
end)
end)
end
function ap.Close(m)
local p={}
if ap.OnCloseCallback then
task.spawn(function()
af.SafeCallback(ap.OnCloseCallback)
end)
end
an.WindUI:ToggleAcrylic(false)
ap.UIElements.Main:WaitForChild"Main".Visible=false
ap.CanDropdown=false
ap.Closed=true
ah(ap.UIElements.Main.Background,0.32,{
ImageTransparency=1,
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut):Play()
if ap.UIElements.BackgroundGradient then
ah(ap.UIElements.BackgroundGradient,0.32,{
ImageTransparency=1,
},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut):Play()
end
ah(ap.UIElements.Main.Background,0.4,{
Size=UDim2.new(1,0,1,-240),
},Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut):Play()
if aB then
if aB:IsA"VideoFrame"then
aB.Visible=false
end
ah(aB,0.2,{
ImageTransparency=aB:IsA"ImageLabel"and 1 or nil,
},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
ah(ax,0.25,{ImageTransparency=1},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
if UIStroke then
ah(UIStroke,0.25,{Transparency=1},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
ah(aE,.3,{Size=UDim2.new(0,0,0,4),ImageTransparency=1},Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut):Play()
ah(av.ImageLabel,.3,{ImageTransparency=1},Enum.EasingStyle.Exponential,Enum.EasingDirection.Out):Play()
h:Set(false)
ap.CanResize=false
task.spawn(function()
task.wait(0.4)
ap.UIElements.Main.Visible=false
end)
function p.Destroy(r)
if ap.OnDestroyCallback then
task.spawn(function()
af.SafeCallback(ap.OnDestroyCallback)
end)
end
if ap.AcrylicPaint.Model then
ap.AcrylicPaint.Model:Destroy()
end
ap.Destroyed=true
task.wait(0.4)
ao.Parent.Parent:Destroy()
end
return p
end
function ap.Destroy(m)
ap:Close():Destroy()
end
function ap.ToggleTransparency(m,p)
ap.Transparent=p
an.WindUI.Transparent=p
ap.UIElements.Main.Background.ImageTransparency=p and an.WindUI.TransparencyValue or 0
ap.UIElements.MainBar.Background.ImageTransparency=p and 0.97 or 0.95
end
function ap.SetUIScale(m,p)
an.WindUI.UIScale=p
ah(an.WindUI.ScreenGui.UIScale,.2,{Scale=p},Enum.EasingStyle.Quint,Enum.EasingDirection.Out):Play()
end
do
if(ac.ViewportSize.X-40<ap.UIElements.Main.AbsoluteSize.X)
or(ac.ViewportSize.Y-40<ap.UIElements.Main.AbsoluteSize.Y)then
if not ap.IsFullscreen then
ap:SetUIScale(.9)
end
end
end
if not ay and ap.IsOpenButtonEnabled then
af.AddSignal(i.Button.TextButton.MouseButton1Click,function()
i:Visible(false)
ap:Open()
end)
end
af.AddSignal(aa.InputBegan,function(m,p)
if p then return end
if m.KeyCode==ap.ToggleKey then
if ap.Closed then
ap:Open()
else
ap:Close()
end
end
end)
task.spawn(function()
ap:Open()
end)
function ap.EditOpenButton(m,p)
return i:Edit(p)
end
local m=a.load'P'
local p=a.load'Q'
local r=m.Init(ap,an.WindUI,an.Parent.Parent.ToolTips)
r:OnChange(function(x)ap.CurrentTab=x end)
ap.TabModule=m
function ap.Tab(x,z)
z.Parent=ap.UIElements.SideBar.Frame
return r.New(z,an.WindUI.UIScale)
end
function ap.SelectTab(x,z)
r:SelectTab(z)
end
function ap.Section(x,z)
return p.New(z,ap.UIElements.SideBar.Frame,ap.Folder,an.WindUI.UIScale)
end
function ap.IsResizable(x,z)
ap.Resizable=z
ap.CanResize=z
end
function ap.Divider(x)
local z=ag("Frame",{
Size=UDim2.new(1,0,0,1),
Position=UDim2.new(0.5,0,0,0),
AnchorPoint=Vector2.new(0.5,0),
BackgroundTransparency=.9,
ThemeTag={
BackgroundColor3="Text"
}
})
local A=ag("Frame",{
Parent=ap.UIElements.SideBar.Frame,
Size=UDim2.new(1,-7,0,5),
BackgroundTransparency=1,
},{
z
})
return A
end
return ap
end end end
local aa={
Window=nil,
Theme=nil,
Creator=a.load'a',
LocalizationModule=a.load'b',
NotificationModule=a.load'c',
Themes=a.load'd',
Transparent=false,
TransparencyValue=.15,
UIScale=1,
Version="1.6.45",
Services=a.load'h',
OnThemeChangeFunction=nil,
}
local ac=game:GetService"HttpService"
local ae=ac:JSONDecode(a.load'i')
if ae then
aa.Version=ae.version
end
local af=a.load'm'local ag=
aa.Services
local ah=aa.Themes
local ai=aa.Creator
local aj=ai.New local ak=
ai.Tween
ai.Themes=ah
local al=a.load'q'local am=
game:GetService"Players"and game:GetService"Players".LocalPlayer or nil
local an=protectgui or(syn and syn.protect_gui)or function()end
local ao=gethui and gethui()or game.CoreGui
aa.ScreenGui=aj("ScreenGui",{
Name="WindUI",
Parent=ao,
IgnoreGuiInset=true,
ScreenInsets="None",
},{
aj("UIScale",{
Scale=aa.Scale,
}),
aj("Folder",{
Name="Window"
}),
aj("Folder",{
Name="KeySystem"
}),
aj("Folder",{
Name="Popups"
}),
aj("Folder",{
Name="ToolTips"
})
})
aa.NotificationGui=aj("ScreenGui",{
Name="WindUI/Notifications",
Parent=ao,
IgnoreGuiInset=true,
})
aa.DropdownGui=aj("ScreenGui",{
Name="WindUI/Dropdowns",
Parent=ao,
IgnoreGuiInset=true,
})
an(aa.ScreenGui)
an(aa.NotificationGui)
an(aa.DropdownGui)
ai.Init(aa)
math.clamp(aa.TransparencyValue,0,1)
local ap=aa.NotificationModule.Init(aa.NotificationGui)
function aa.Notify(ar,as)
as.Holder=ap.Frame
as.Window=aa.Window
return aa.NotificationModule.New(as)
end
function aa.SetNotificationLower(ar,as)
ap.SetLower(as)
end
function aa.SetFont(ar,as)
ai.UpdateFont(as)
end
function aa.OnThemeChange(ar,as)
aa.OnThemeChangeFunction=as
end
function aa.AddTheme(ar,as)
ah[as.Name]=as
return as
end
function aa.SetTheme(ar,as)
if ah[as]then
aa.Theme=ah[as]
ai.SetTheme(ah[as])
if aa.OnThemeChangeFunction then
aa.OnThemeChangeFunction(as)
end
return ah[as]
end
return nil
end
function aa.GetThemes(ar)
return ah
end
function aa.GetCurrentTheme(ar)
return aa.Theme.Name
end
function aa.GetTransparency(ar)
return aa.Transparent or false
end
function aa.GetWindowSize(ar)
return Window.UIElements.Main.Size
end
function aa.Localization(ar,as)
return aa.LocalizationModule:New(as,ai)
end
function aa.SetLanguage(ar,as)
if ai.Localization then
return ai.SetLanguage(as)
end
return false
end
function aa.ToggleAcrylic(ar,as)
if aa.Window and aa.Window.AcrylicPaint and aa.Window.AcrylicPaint.Model then
aa.Window.Acrylic=as
aa.Window.AcrylicPaint.Model.Transparency=as and 0.98 or 1
if as then
al.Enable()
else
al.Disable()
end
end
end
aa:SetTheme"Dark"
aa:SetLanguage(ai.Language)
function aa.Gradient(ar,as,at)
local au={}
local av={}
for aw,ax in next,as do
local ay=tonumber(aw)
if ay then
ay=math.clamp(ay/100,0,1)
table.insert(au,ColorSequenceKeypoint.new(ay,ax.Color))
table.insert(av,NumberSequenceKeypoint.new(ay,ax.Transparency or 0))
end
end
table.sort(au,function(ay,az)return ay.Time<az.Time end)
table.sort(av,function(ay,az)return ay.Time<az.Time end)
if#au<2 then
error"ColorSequence requires at least 2 keypoints"
end
local ay={
Color=ColorSequence.new(au),
Transparency=NumberSequence.new(av),
}
if at then
for az,aA in pairs(at)do
ay[az]=aA
end
end
return ay
end
function aa.Popup(ar,as)
as.WindUI=aa
return a.load'r'.new(as)
end
function aa.CreateWindow(ar,as)
local at=a.load'T'
if not isfolder"WindUI"then
makefolder"WindUI"
end
if as.Folder then
makefolder(as.Folder)
else
makefolder(as.Title)
end
as.WindUI=aa
as.Parent=aa.ScreenGui.Window
if aa.Window then
warn"You cannot create more than one window"
return
end
local au=true
local av=ah[as.Theme or"Dark"]
ai.SetTheme(av)
local aw=gethwid or function()
return game:GetService"Players".LocalPlayer.UserId
end
local ax=aw()
if as.KeySystem then
au=false
local function loadKeysystem()
af.new(as,ax,function(ay)au=ay end)
end
local ay=as.Folder.."/"..ax..".key"
if not as.KeySystem.API then
if as.KeySystem.SaveKey and isfile(ay)then
local az=readfile(ay)
local aA=(type(as.KeySystem.Key)=="table")
and table.find(as.KeySystem.Key,az)
or tostring(as.KeySystem.Key)==tostring(az)
if aA then
au=true
else
loadKeysystem()
end
else
loadKeysystem()
end
else
if isfile(ay)then
local az=readfile(ay)
local aA=false
for aB,aC in next,as.KeySystem.API do
local aD=aa.Services[aC.Type]
if aD then
local aE={}
for b,e in next,aD.Args do
table.insert(aE,aC[e])
end
local g=aD.New(table.unpack(aE))
local h=g.Verify(az)
if h then
aA=true
break
end
end
end
au=aA
if not aA then loadKeysystem()end
else
loadKeysystem()
end
end
repeat task.wait()until au
end
local ay=at(as)
aa.Transparent=as.Transparent
aa.Window=ay
if as.Acrylic then
al.init()
end
return ay
end

local library = {
    flags = {},
    _window = nil,
    _tabs = {},
    _sections = {}
}

function library:new(title, theme)
    local window = aa.CreateWindow(nil, {
        Title = title,
        Theme = theme or "Dark",
        Size = UDim2.new(0, 700, 0, 500),
        Folder = "BlackHoleCenter"
    })
    self._window = window
    self.flags = setmetatable({}, {
        __index = function(t, k)
            return rawget(t, k)
        end,
        __newindex = function(t, k, v)
            rawset(t, k, v)
        end
    })
    return window
end

function library:ToggleUILib()
    if self._window then
        if self._window.Closed then
            self._window:Open()
        else
            self._window:Close()
        end
    end
end

function library:UiDestroy()
    if self._window then
        self._window:Destroy()
    end
end

local ElementsModule = a.load'O'

local function wrapElement(element, flag, elementType)
    if flag then
        library.flags[flag] = element.Value or false
        local originalCallback = element.Callback
        element.Callback = function(...)
            local args = {...}
            if elementType == "Toggle" then
                library.flags[flag] = args[1]
            elseif elementType == "Slider" then
                library.flags[flag] = args[1]
            elseif elementType == "Dropdown" then
                library.flags[flag] = args[1]
            elseif elementType == "Input" then
                library.flags[flag] = args[1]
            elseif elementType == "Keybind" then
                library.flags[flag] = args[1]
            end
            if originalCallback then
                originalCallback(...)
            end
        end
    end
    return element
end

local function createSectionMethods(section, window, tab)
    function section:Label(text)
        local label = section.Paragraph({
            Title = text,
            Desc = ""
        })
        local wrapped = {}
        setmetatable(wrapped, {
            __index = function(t, k)
                if k == "Text" then
                    return label.ParagraphFrame.UIElements.Container.Frame.TextLabel.Text
                end
                return label[k]
            end,
            __newindex = function(t, k, v)
                if k == "Text" then
                    label:SetTitle(v)
                elseif k == "TextColor3" then
                    label.ParagraphFrame.UIElements.Container.Frame.TextLabel.TextColor3 = v
                end
            end
        })
        return wrapped
    end
    
    function section:Button(text, callback)
        return section.Button({
            Title = text,
            Callback = callback
        })
    end
    
    function section:Toggle(text, flag, default, callback)
        local toggle = section.Toggle({
            Title = text,
            Value = default or false,
            Callback = callback
        })
        local wrapped = wrapElement(toggle, flag, "Toggle")
        function wrapped:SetState(state)
            if state == nil then
                state = not toggle.Value
            end
            toggle:Set(state)
            library.flags[flag] = state
        end
        return wrapped
    end
    
    function section:Slider(text, flag, default, min, max, isFloat, callback)
        local sliderData = {
            Title = text,
            Value = {
                Min = min or 0,
                Max = max or 100,
                Default = default or min or 0
            },
            Step = isFloat and 0.01 or 1,
            Callback = callback
        }
        local slider = section.Slider(sliderData)
        local wrapped = wrapElement(slider, flag, "Slider")
        function wrapped:SetValue(val)
            slider:Set(val)
            library.flags[flag] = val
        end
        return wrapped
    end
    
    function section:Keybind(text, default, callback)
        local keybind = section.Keybind({
            Title = text,
            Value = default or "F",
            Callback = callback
        })
        return wrapElement(keybind, nil, "Keybind")
    end
    
    function section:Dropdown(text, flag, options, callback)
        local dropdown = section.Dropdown({
            Title = text,
            Values = options or {},
            Value = options and options[1] or nil,
            Callback = callback
        })
        local wrapped = wrapElement(dropdown, flag, "Dropdown")
        function wrapped:AddOption(opt)
            local newValues = dropdown.Values
            table.insert(newValues, opt)
            dropdown:Refresh(newValues)
        end
        function wrapped:RemoveOption(opt)
            local newValues = {}
            for _, v in ipairs(dropdown.Values) do
                if v ~= opt then
                    table.insert(newValues, v)
                end
            end
            dropdown:Refresh(newValues)
        end
        function wrapped:SetOptions(opts)
            dropdown:Refresh(opts)
        end
        return wrapped
    end
    
    function section:Textbox(text, flag, placeholder, callback)
        local input = section.Input({
            Title = text,
            Placeholder = placeholder or "Enter text...",
            Value = "",
            Callback = callback
        })
        local wrapped = wrapElement(input, flag, "Input")
        function wrapped:Set(text)
            input:Set(text)
            library.flags[flag] = text
        end
        return wrapped
    end
end

local function wrapSection(sectionObj, window, tab)
    createSectionMethods(sectionObj, window, tab)
    return sectionObj
end

local function wrapTab(tabObj, window)
    function tabObj:section(title, isOpen)
        local section = tabObj.Section({
            Title = title,
            Opened = isOpen or false
        })
        return wrapSection(section, window, tabObj)
    end
    return tabObj
end

local originalCreateWindow = aa.CreateWindow
function aa.CreateWindow(ar, as)
    local window = originalCreateWindow(ar, as)
    library._window = window
    function window:Tab(name, icon)
        local tab = window.Tab({
            Title = name,
            Icon = icon and "rbxassetid://"..icon or nil
        })
        library._tabs[name] = tab
        return wrapTab(tab, window)
    end
    return window
end

return library
