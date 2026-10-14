local cloneref = (cloneref or clonereference or function(i) return i end)

local Players          = cloneref(game:GetService("Players"))
local CoreGui          = cloneref(game:GetService("CoreGui"))
local RunService       = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService     = cloneref(game:GetService("TweenService"))
local HttpService      = cloneref(game:GetService("HttpService"))
local StarterGui       = cloneref(game:GetService("StarterGui"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

if _G.BANANAUI and _G.BANANAUI.Destroy then
    pcall(function() _G.BANANAUI.Destroy() end)
end

local LocalPlayer = Players.LocalPlayer
local guiParent = (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui")) or CoreGui

local function IsExploit()
    return (typeof(request) == "function") or (typeof(game.HttpGet) == "function")
end

local function Get(url)
    if IsExploit() then
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok then return res end
    end
    local ok2, res2 = pcall(function() return HttpService:GetAsync(url) end)
    if ok2 then return res2 end
    local remote = ReplicatedStorage:FindFirstChild("Request")
    if remote then
        local ok3, res3 = pcall(function() return remote:InvokeServer({ Url = url }) end)
        if ok3 then return res3 end
    end
    return nil
end

local function Loadstring(src)
    if loadstring then return loadstring(src) end
    if loadstring_ then return loadstring_(src) end
    local remote = ReplicatedStorage:FindFirstChild("Loadstring")
    if remote then
        return function() return remote:InvokeServer(src) end
    end
    return nil
end

local IconPacks = {}
local IconPackURLs = {
    banana1 = "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/NEWICONS1",
    banana2 = "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/NEWICON2",
    banana3 = "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/NEWICON3",
    banana4 = "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/NEWICONS4",
    banana5 = "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/NEWICON5",
    banana6 = "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/NEWICON6",
}

local function loadIconPack(name, url)
    local ok, data = pcall(function()
        local src = Get(url)
        if not src then return nil end
        local fn = Loadstring(src)
        if not fn then return nil end
        return fn()
    end)
    if ok and type(data) == "table" then
        IconPacks[name] = data
    end
end

for name, url in pairs(IconPackURLs) do
    task.spawn(loadIconPack, name, url)
end

local LegacyIcons = {}
local LegacySources = {
    "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/OLDICONS1",
    "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/OLDICONS2",
    "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/OLDICONS3",
    "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/OLDICONS4",
}
for _, url in ipairs(LegacySources) do
    pcall(function()
        local data = loadstring(game:HttpGet(url))()
        if type(data) == "table" then
            for k, v in pairs(data) do LegacyIcons[k] = v end
        end
    end)
end

local function parseIconString(iconString)
    if type(iconString) == "string" then
        local splitIndex = iconString:find(":")
        if splitIndex then
            return iconString:sub(1, splitIndex - 1), iconString:sub(splitIndex + 1)
        end
    end
    return nil, iconString
end

local DefaultIconType = "banana2"

local function resolveIcon(source, defaultType)
    if source == nil then return nil end
    if type(source) == "number" then
        return { imageId = "rbxassetid://"..tostring(source) }
    end
    if type(source) ~= "string" or source == "" then return nil end

    if source:match("^rbxassetid://") or source:match("^rbxthumb://") or source:match("^rbxasset://") then
        return { imageId = source }
    end
    if source:match("^%d+$") then
        return { imageId = "rbxassetid://"..source }
    end
    if source:match("^https?://") then
        local cached = normalizeImage(source)
        if cached ~= "" then return { imageId = cached } end
        return nil
    end

    local t, n = parseIconString(source)
    t = t or defaultType or DefaultIconType

    local pack = IconPacks[t]
    if pack then
        local icons = pack.Icons or pack
        local spritesheets = pack.Spritesheets or {}
        local data = icons[n]
        if data then
            if type(data) == "string" then
                return { imageId = data }
            elseif type(data) == "table" then
                local imgId = data.Image
                if type(imgId) == "number" then
                    imgId = spritesheets[tostring(imgId)] or spritesheets[imgId] or imgId
                end
                return {
                    imageId = imgId,
                    rectSize = data.ImageRectSize,
                    rectOffset = data.ImageRectPosition,
                    parts = data.Parts,
                }
            end
        end
    end

    if LegacyIcons[source] then
        return resolveIcon(LegacyIcons[source], defaultType)
    end

    return nil
end

local function hex(h)
    h = tostring(h):gsub("#", "")
    return Color3.fromRGB(tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16))
end

local function normalizeImage(src)
    if src == nil then return "" end
    if type(src) == "number" then return "rbxassetid://"..tostring(src) end
    if type(src) ~= "string" or src == "" then return "" end
    if src:match("^rbxassetid://") or src:match("^rbxthumb://") or src:match("^rbxasset://") then return src end
    if src:match("^%d+$") then return "rbxassetid://"..src end
    if src:match("^https?://") then
        if writefile and isfile and getcustomasset and makefolder and isfolder then
            local safe = "BANANA_Cache/"..src:gsub("[^%w]", "_")..".png"
            local ok = pcall(function()
                if not isfolder("BANANA_Cache") then makefolder("BANANA_Cache") end
                if not isfile(safe) then writefile(safe, game:HttpGet(src)) end
            end)
            if ok then
                local a, b = pcall(function() return getcustomasset(safe) end)
                if a and b then return b end
            end
        end
        return ""
    end
    if LegacyIcons[src] then return normalizeImage(LegacyIcons[src]) end
    return src
end

local THEMES = {
    { name="Aqua",      colors={ bg="#0A0A0A", bg2="#121212", bg3="#1A1A1A", line="#3C3C3C", line2="#5A5A5A", text="#F0F0F0", text2="#8C8C8C", text3="#5A5A5A", accent="#FFFFFF" }},
    { name="Banana",    colors={ accent="#FFE135", line2="#FFF176", line="#FFD600", bg3="#221A00", text="#FFFDE7", text2="#D4C56A", bg="#0A0900", bg2="#151200", text3="#FFE135" }},
    { name="Sovereign", colors={ accent="#D4AF37", line2="#F0D580", line="#D4AF37", bg3="#221A08", text="#FFF8E7", text2="#C9B98A", bg="#0A0805", bg2="#15110A", text3="#F0D580" }},
    { name="Blood",     colors={ accent="#FF1A1A", line2="#FF2A2A", line="#FF1A1A", bg3="#220000", text="#F0F0F0", text2="#9A9A9A", bg="#000000", bg2="#0A0A0A", text3="#FF1A1A" }},
    { name="Ocean",     colors={ accent="#1E90FF", line2="#4FB3FF", line="#1E90FF", bg3="#0E1A2A", text="#EAF4FF", text2="#88A6C9", bg="#050A14", bg2="#0B1424", text3="#4FB3FF" }},
    { name="Emerald",   colors={ accent="#00E676", line2="#5CFFAE", line="#00E676", bg3="#0A2018", text="#E8FFF3", text2="#7FB89A", bg="#05100B", bg2="#0A1C14", text3="#5CFFAE" }},
    { name="Violet",    colors={ accent="#B14CFF", line2="#D08CFF", line="#B14CFF", bg3="#1A0A28", text="#F5EAFF", text2="#A488C9", bg="#0A0514", bg2="#160A24", text3="#D08CFF" }},
    { name="Cyber",     colors={ accent="#00FFFF", line2="#FF00AA", line="#00FFFF", bg3="#0A1224", text="#F0FDFF", text2="#7FBDC9", bg="#050814", bg2="#0A1224", text3="#00FFFF" }},
    { name="Sunset",    colors={ accent="#FF7A1A", line2="#FFB25C", line="#FF7A1A", bg3="#2A1505", text="#FFF3E6", text2="#C99A7A", bg="#100600", bg2="#1C0E05", text3="#FFB25C" }},
    { name="Rose",      colors={ accent="#FF4D88", line2="#FF8CB3", line="#FF4D88", bg3="#280A18", text="#FFEEF4", text2="#C9889E", bg="#100510", bg2="#1C0A14", text3="#FF8CB3" }},
    { name="Mono",      colors={ accent="#FFFFFF", line2="#B0B0B0", line="#707070", bg3="#1A1A1A", text="#F2F2F2", text2="#8A8A8A", bg="#000000", bg2="#101010", text3="#FFFFFF" }},
}

local THEME_ALIAS = {
    Dark="Mono", Light="Aqua", Blue="Ocean", Red="Blood", Green="Emerald",
    Purple="Violet", Yellow="Banana", Orange="Sunset", Pink="Rose",
    Cyan="Cyber", Gold="Sovereign", Wind="Banana", Default="Banana",
}

local currentThemeName = "Banana"
local C = {
    bg=Color3.fromRGB(10,9,0), bg2=Color3.fromRGB(21,18,0), bg3=Color3.fromRGB(34,26,0),
    line=Color3.fromRGB(255,214,0), line2=Color3.fromRGB(255,241,118),
    text=Color3.fromRGB(255,253,231), text2=Color3.fromRGB(212,197,106), text3=Color3.fromRGB(255,225,53),
    white=Color3.fromRGB(255,225,53), black=Color3.fromRGB(0,0,0),
}
local themeEls, allScanLines = {}, {}

local function regTheme(el, prop, role)
    table.insert(themeEls, {el=el, prop=prop, role=role}); return el
end

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 3); c.Parent = p; return c
end
local function stroke(p, color, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = color or C.line; s.Thickness = t or 1; s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end
local function shade(color, amount)
    if typeof(color) ~= "Color3" then return Color3.fromRGB(20,20,24) end
    amount = amount or 0.07
    local lum = 0.299*color.R + 0.587*color.G + 0.114*color.B
    if lum > 0.5 then
        return Color3.new(math.max(0,color.R-amount), math.max(0,color.G-amount), math.max(0,color.B-amount))
    end
    return Color3.new(math.min(1,color.R+amount), math.min(1,color.G+amount), math.min(1,color.B+amount))
end
local function Tween(o, t, p)
    local a = TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p)
    a:Play(); return a
end
local function copyClip(t)
    pcall(function() setclipboard(t) end)
    pcall(function() toclipboard(t) end)
end
local function pickDefault(cfg, fallback)
    if cfg.Default ~= nil then return cfg.Default end
    if cfg.Value ~= nil and type(cfg.Value) ~= "table" then return cfg.Value end
    return fallback
end
local function parseSliderValue(cfg)
    if type(cfg.Value) == "table" then
        return cfg.Value.Min or cfg.Value[1] or 0,
               cfg.Value.Max or cfg.Value[2] or 100,
               cfg.Value.Default or cfg.Value.Value or cfg.Value[3] or (cfg.Value.Min or 0)
    end
    return cfg.Min or 0, cfg.Max or 100, pickDefault(cfg, cfg.Min or 0)
end

local function applyIconColor(img, color, register)
    if typeof(color) == "Color3" then
        img.ImageColor3 = color
    elseif type(color) == "string" then
        local role = color:lower()
        local val = C[role] or C.white
        img.ImageColor3 = val
        if register ~= false then regTheme(img, "ImageColor3", role) end
    else
        img.ImageColor3 = C.white
    end
end

local function newIcon(parent, source, size, color)
    if source == nil then return nil end
    local resolved = resolveIcon(source)
    if not resolved or not resolved.imageId then return nil end

    local img = Instance.new("ImageLabel")
    img.Size = size or UDim2.fromOffset(14,14)
    img.BackgroundTransparency = 1
    img.Image = resolved.imageId
    if resolved.rectSize then
        img.ImageRectSize = resolved.rectSize
        img.ImageRectOffset = resolved.rectOffset
        img.ScaleType = Enum.ScaleType.Fit
    else
        img.ScaleType = Enum.ScaleType.Crop
    end
    applyIconColor(img, color or C.white)
    img.ZIndex = 10
    img.Parent = parent
    img:SetAttribute("CustomIcon", true)

    if resolved.parts then
        for i, partName in ipairs(resolved.parts) do
            local pr = resolveIcon(partName)
            if pr and pr.imageId then
                local p = Instance.new("ImageLabel")
                p.Size = UDim2.fromScale(1, 1)
                p.BackgroundTransparency = 1
                p.Image = pr.imageId
                if pr.rectSize then
                    p.ImageRectSize = pr.rectSize
                    p.ImageRectOffset = pr.rectOffset
                    p.ScaleType = Enum.ScaleType.Fit
                else
                    p.ScaleType = Enum.ScaleType.Crop
                end
                p.ImageColor3 = C.white
                p.ZIndex = 11
                p.Parent = img
            end
        end
    end

    return img
end

local IconModule = {
    IconsType = DefaultIconType,
    Icons = IconPacks,
}

function IconModule:AddIcons(packName, iconsData)
    if type(packName) ~= "string" or type(iconsData) ~= "table" then return end
    if not IconPacks[packName] then
        IconPacks[packName] = { Icons = {}, Spritesheets = {} }
    end
    local pack = IconPacks[packName]
    pack.Icons = pack.Icons or {}
    pack.Spritesheets = pack.Spritesheets or {}

    for iconName, iconValue in pairs(iconsData) do
        if type(iconValue) == "number" then
            local imageId = "rbxassetid://"..tostring(iconValue)
            pack.Icons[iconName] = { Image = imageId, ImageRectSize = Vector2.new(0,0), ImageRectPosition = Vector2.new(0,0) }
            pack.Spritesheets[imageId] = imageId
        elseif type(iconValue) == "string" then
            pack.Icons[iconName] = { Image = iconValue, ImageRectSize = Vector2.new(0,0), ImageRectPosition = Vector2.new(0,0) }
            pack.Spritesheets[iconValue] = iconValue
        elseif type(iconValue) == "table" and iconValue.Image then
            local imageId = iconValue.Image
            if type(imageId) == "number" then imageId = "rbxassetid://"..tostring(imageId) end
            pack.Icons[iconName] = {
                Image = imageId,
                ImageRectSize = iconValue.ImageRectSize,
                ImageRectPosition = iconValue.ImageRectPosition,
                Parts = iconValue.Parts,
            }
            pack.Spritesheets[imageId] = imageId
        end
    end
end

function IconModule:SetIconsType(t)
    if type(t) == "string" then
        DefaultIconType = t
        IconModule.IconsType = t
    end
end

function IconModule:Get(url, callback)
    task.spawn(function()
        local src = Get(url)
        if src and callback then callback(src) end
    end)
end

function IconModule:Resolve(source, t)
    return resolveIcon(source, t)
end

function IconModule:New(parent, source, size, color)
    return newIcon(parent, source, size, color)
end

local function createScanLines(parent, count, length, speed)
    count, length, speed = count or 4, length or 60, speed or 2.5
    local scanLines = {}
    local function makeLine(side, index)
        local line = Instance.new("Frame")
        line.BackgroundColor3 = C.white; line.BackgroundTransparency = 0.25
        line.BorderSizePixel = 0; line.ZIndex = 15
        local grad = Instance.new("UIGradient")
        if side == "top" then
            line.Size = UDim2.new(0, length, 0, 1)
            line.Position = UDim2.new(0, 0, 0, 1 + (index-1)*2)
        elseif side == "bottom" then
            line.Size = UDim2.new(0, length, 0, 1)
            line.Position = UDim2.new(0, 0, 1, -(2 + (index-1)*2))
        elseif side == "left" then
            line.Size = UDim2.new(0, 1, 0, length)
            line.Position = UDim2.new(0, 1 + (index-1)*2, 0, 0)
            grad.Rotation = 90
        else
            line.Size = UDim2.new(0, 1, 0, length)
            line.Position = UDim2.new(1, -(2 + (index-1)*2), 0, 0)
            grad.Rotation = 90
        end
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        grad.Parent = line; line.Parent = parent
        table.insert(allScanLines, line)
        return line, side
    end
    for _, side in ipairs({"top","bottom","left","right"}) do
        for i = 1, count do
            local line, s = makeLine(side, i)
            table.insert(scanLines, {line = line, side = s, index = i})
        end
    end
    for _, item in ipairs(scanLines) do
        task.spawn(function()
            task.wait((item.index-1) * 0.35)
            local line = item.line
            while line and line.Parent do
                if item.side == "top" or item.side == "bottom" then
                    local t1 = TweenService:Create(line, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(1, -length, line.Position.Y.Scale, line.Position.Y.Offset) })
                    t1:Play(); t1.Completed:Wait()
                    if not line.Parent then break end
                    local t2 = TweenService:Create(line, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, line.Position.Y.Scale, line.Position.Y.Offset) })
                    t2:Play(); t2.Completed:Wait()
                else
                    local t1 = TweenService:Create(line, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(line.Position.X.Scale, line.Position.X.Offset, 1, -length) })
                    t1:Play(); t1.Completed:Wait()
                    if not line.Parent then break end
                    local t2 = TweenService:Create(line, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(line.Position.X.Scale, line.Position.X.Offset, 0, 0) })
                    t2:Play(); t2.Completed:Wait()
                end
            end
        end)
    end
    return scanLines
end

local CONFIG = { UI_W = 500, UI_H = 320, Sidebar_W = 80 }

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BANANAUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, CONFIG.UI_W, 0, CONFIG.UI_H)
MainFrame.Position = UDim2.new(0.5, -CONFIG.UI_W/2, 0.5, -CONFIG.UI_H/2)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
corner(MainFrame, 4)
regTheme(MainFrame, "BackgroundColor3", "bg")

local UI_SCALE_OBJ = Instance.new("UIScale")
UI_SCALE_OBJ.Parent = MainFrame
local function recalcUIScale()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local s = math.min(vp.X / (CONFIG.UI_W + 80), vp.Y / (CONFIG.UI_H + 80), 1)
    UI_SCALE_OBJ.Scale = math.clamp(s, 0.4, 1)
end
recalcUIScale()
pcall(function() workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(recalcUIScale) end)

local MainStroke = stroke(MainFrame, C.line2, 1)
regTheme(MainStroke, "Color", "line2")
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new(C.black, C.white)
MainGradient.Rotation = 90
MainGradient.Parent = MainStroke

local cornerFrames = {}
local function bracket(pos, size)
    local f = Instance.new("Frame")
    f.Size = size; f.Position = pos
    f.BackgroundColor3 = C.white; f.BorderSizePixel = 0; f.ZIndex = 20
    f.Parent = MainFrame
    regTheme(f, "BackgroundColor3", "accent")
    cornerFrames[#cornerFrames+1] = f
end
bracket(UDim2.new(0,-1,0,-1), UDim2.new(0,12,0,2))
bracket(UDim2.new(0,-1,0,-1), UDim2.new(0,2,0,12))
bracket(UDim2.new(1,-11,0,-1), UDim2.new(0,12,0,2))
bracket(UDim2.new(1,0,0,-1), UDim2.new(0,2,0,12))
bracket(UDim2.new(0,-1,1,0), UDim2.new(0,12,0,2))
bracket(UDim2.new(0,-1,1,-11), UDim2.new(0,2,0,12))
bracket(UDim2.new(1,-11,1,0), UDim2.new(0,12,0,2))
bracket(UDim2.new(1,0,1,-11), UDim2.new(0,2,0,12))
createScanLines(MainFrame, 4, 45, 3.2)

local THEME_MENU_H = 180
local THEME_ITEM_H = 18
local ThemeMenu = Instance.new("ScrollingFrame")
ThemeMenu.Size = UDim2.new(0, 110, 0, THEME_MENU_H)
ThemeMenu.Position = UDim2.new(1, -122, 0, 26)
ThemeMenu.BackgroundColor3 = C.bg2
ThemeMenu.BorderSizePixel = 0
ThemeMenu.Visible = false
ThemeMenu.ZIndex = 90
ThemeMenu.Parent = MainFrame
ThemeMenu.ScrollBarThickness = 6
ThemeMenu.ScrollBarImageColor3 = C.line2
ThemeMenu.CanvasSize = UDim2.new(0, 0, 0, 8 + (#THEMES * THEME_ITEM_H))
ThemeMenu.ClipsDescendants = true
corner(ThemeMenu, 3)
local themeMenuStroke = stroke(ThemeMenu, C.line2, 1)
regTheme(ThemeMenu, "BackgroundColor3", "bg2")
regTheme(themeMenuStroke, "Color", "line2")

local themeMenuPad = Instance.new("UIPadding")
themeMenuPad.PaddingTop = UDim.new(0, 4)
themeMenuPad.PaddingLeft = UDim.new(0, 4)
themeMenuPad.PaddingRight = UDim.new(0, 10)
themeMenuPad.PaddingBottom = UDim.new(0, 4)
themeMenuPad.Parent = ThemeMenu
local themeMenuList = Instance.new("UIListLayout")
themeMenuList.SortOrder = Enum.SortOrder.LayoutOrder
themeMenuList.Padding = UDim.new(0, 2)
themeMenuList.Parent = ThemeMenu

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 26)
TitleBar.Position = UDim2.new(0, 0, 0, 10)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 3
TitleBar.Parent = MainFrame

local prompt = Instance.new("TextLabel")
prompt.Size = UDim2.new(0.5, 0, 1, 0)
prompt.Position = UDim2.new(0, 10, 0, 0)
prompt.BackgroundTransparency = 1
prompt.Text = "$ banana --ui"
prompt.TextColor3 = C.white
prompt.TextSize = 11
prompt.Font = Enum.Font.Code
prompt.TextXAlignment = Enum.TextXAlignment.Left
prompt.ZIndex = 3
prompt.Parent = TitleBar
regTheme(prompt, "TextColor3", "accent")

local cursor = Instance.new("TextLabel")
cursor.Size = UDim2.new(0, 8, 1, 0)
cursor.Position = UDim2.new(0, 148, 0, 0)
cursor.BackgroundTransparency = 1
cursor.Text = "|"
cursor.TextColor3 = C.white
cursor.TextSize = 11
cursor.Font = Enum.Font.Code
cursor.ZIndex = 3
cursor.Parent = TitleBar
regTheme(cursor, "TextColor3", "accent")

local UserInfo = Instance.new("Frame")
UserInfo.Size = UDim2.new(0, 0, 0, 20)
UserInfo.AutomaticSize = Enum.AutomaticSize.X
UserInfo.Position = UDim2.new(0.5, -40, 0.5, -10)
UserInfo.BackgroundColor3 = C.bg2
UserInfo.BorderSizePixel = 0
UserInfo.ZIndex = 3
UserInfo.Visible = false
UserInfo.Parent = TitleBar
corner(UserInfo, 2)
local uis = stroke(UserInfo, C.line, 1, 0.5)
regTheme(UserInfo, "BackgroundColor3", "bg2")
regTheme(uis, "Color", "line")

local userPad = Instance.new("UIPadding")
userPad.PaddingLeft = UDim.new(0, 4); userPad.PaddingRight = UDim.new(0, 6)
userPad.Parent = UserInfo
local userList = Instance.new("UIListLayout")
userList.FillDirection = Enum.FillDirection.Horizontal
userList.VerticalAlignment = Enum.VerticalAlignment.Center
userList.Padding = UDim.new(0, 4)
userList.Parent = UserInfo

local userAvatar = Instance.new("ImageLabel")
userAvatar.Size = UDim2.fromOffset(14,14)
userAvatar.BackgroundTransparency = 1
userAvatar.ZIndex = 4
userAvatar.Parent = UserInfo
corner(userAvatar, 7)

local userName = Instance.new("TextLabel")
userName.Size = UDim2.new(0, 0, 1, 0)
userName.AutomaticSize = Enum.AutomaticSize.X
userName.BackgroundTransparency = 1
userName.Text = LocalPlayer.DisplayName or LocalPlayer.Name
userName.Font = Enum.Font.Code
userName.TextSize = 9
userName.TextColor3 = C.text
userName.ZIndex = 4
userName.Parent = UserInfo
regTheme(userName, "TextColor3", "text")

local SearchBar = Instance.new("Frame")
SearchBar.Size = UDim2.new(0, 120, 0, 18)
SearchBar.Position = UDim2.new(0.5, -60, 0.5, -9)
SearchBar.BackgroundColor3 = C.bg3
SearchBar.BorderSizePixel = 0
SearchBar.ZIndex = 3
SearchBar.Visible = false
SearchBar.Parent = TitleBar
corner(SearchBar, 2)
local sbs = stroke(SearchBar, C.line, 1, 0.5)
regTheme(SearchBar, "BackgroundColor3", "bg3")
regTheme(sbs, "Color", "line")

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -20, 1, 0)
SearchBox.Position = UDim2.new(0, 18, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = C.text3
SearchBox.Text = ""
SearchBox.TextColor3 = C.text
SearchBox.Font = Enum.Font.Code
SearchBox.TextSize = 9
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 4
SearchBox.Parent = SearchBar
regTheme(SearchBox, "TextColor3", "text")

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.fromOffset(14, 14)
SearchIcon.Position = UDim2.new(0, 3, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "⌕"
SearchIcon.TextColor3 = C.text3
SearchIcon.TextSize = 12
SearchIcon.Font = Enum.Font.Code
SearchIcon.ZIndex = 4
SearchIcon.Parent = SearchBar
regTheme(SearchIcon, "TextColor3", "text3")

local function mkTitleBtn(text, xOff, width)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width or 20, 0, 18)
    b.Position = UDim2.new(1, xOff, 0, 4)
    b.BackgroundColor3 = C.bg3
    b.Text = text; b.TextColor3 = C.text; b.TextSize = 12
    b.Font = Enum.Font.Code; b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.ZIndex = 3; b.Parent = TitleBar
    corner(b, 2)
    local s = stroke(b, C.line, 1)
    regTheme(b, "BackgroundColor3", "bg3")
    regTheme(b, "TextColor3", "text")
    regTheme(s, "Color", "line")
    b.MouseEnter:Connect(function() b.BackgroundColor3 = C.bg2; b.TextColor3 = C.white; s.Color = C.line2 end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = C.bg3; b.TextColor3 = C.text; s.Color = C.line end)
    return b
end
local RefreshBtn = mkTitleBtn("⟳", -74)
local ThemeBtn   = mkTitleBtn("◈", -50)
local CloseBtn   = mkTitleBtn("×", -26, 20)
CloseBtn.TextSize = 14
CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = C.white; CloseBtn.TextColor3 = C.black end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = C.bg3; CloseBtn.TextColor3 = C.text end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, CONFIG.Sidebar_W, 1, -64)
Sidebar.Position = UDim2.new(0, 10, 0, 64)
Sidebar.BackgroundColor3 = C.bg2
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame
corner(Sidebar, 3); stroke(Sidebar, C.line, 1)
regTheme(Sidebar, "BackgroundColor3", "bg2")

local sideList = Instance.new("UIListLayout")
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Padding = UDim.new(0, 2)
sideList.Parent = Sidebar
local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 4); sidePad.PaddingLeft = UDim.new(0, 4)
sidePad.PaddingRight = UDim.new(0, 4); sidePad.PaddingBottom = UDim.new(0, 4)
sidePad.Parent = Sidebar

local ContentX = 10 + CONFIG.Sidebar_W + 6
local ContentW = CONFIG.UI_W - ContentX - 10
local ContentHost = Instance.new("Frame")
ContentHost.Size = UDim2.new(0, ContentW, 1, -64)
ContentHost.Position = UDim2.new(0, ContentX, 0, 64)
ContentHost.BackgroundTransparency = 1
ContentHost.ZIndex = 3
ContentHost.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 0, 0, 38)
ToggleButton.AutomaticSize = Enum.AutomaticSize.X
ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleButton.Position = UDim2.new(0.5, 0, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.new(1, 1, 1)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = ""
ToggleButton.Visible = true
ToggleButton.Active = true
ToggleButton.AutoButtonColor = false
ToggleButton.ZIndex = 100
ToggleButton.Parent = ScreenGui
corner(ToggleButton, 19)

local ToggleStroke = stroke(ToggleButton, C.line2, 2, 0)
regTheme(ToggleStroke, "Color", "line2")

local ToggleLaserGrad = Instance.new("UIGradient")
ToggleLaserGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.line2),
    ColorSequenceKeypoint.new(0.5, C.white),
    ColorSequenceKeypoint.new(1, C.line2),
})
ToggleLaserGrad.Parent = ToggleStroke

local ToggleBgGrad = Instance.new("UIGradient")
ToggleBgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.bg2),
    ColorSequenceKeypoint.new(0.5, C.bg),
    ColorSequenceKeypoint.new(1, C.bg2),
})
ToggleBgGrad.Rotation = 0
ToggleBgGrad.Parent = ToggleButton

local togglePad = Instance.new("UIPadding")
togglePad.PaddingLeft = UDim.new(0, 22)
togglePad.PaddingRight = UDim.new(0, 22)
togglePad.PaddingTop = UDim.new(0, 10)
togglePad.PaddingBottom = UDim.new(0, 10)
togglePad.Parent = ToggleButton

local OpenBtnText = Instance.new("TextLabel")
OpenBtnText.Name = "OpenBtnText"
OpenBtnText.Size = UDim2.new(0, 0, 0, 18)
OpenBtnText.AutomaticSize = Enum.AutomaticSize.X
OpenBtnText.BackgroundTransparency = 1
OpenBtnText.Text = "OPEN UI"
OpenBtnText.TextColor3 = C.white
OpenBtnText.TextSize = 12
OpenBtnText.Font = Enum.Font.GothamBold
OpenBtnText.TextXAlignment = Enum.TextXAlignment.Center
OpenBtnText.TextYAlignment = Enum.TextYAlignment.Center
OpenBtnText.ZIndex = 101
OpenBtnText.Parent = ToggleButton
regTheme(OpenBtnText, "TextColor3", "accent")

local btnScale = Instance.new("UIScale")
btnScale.Scale = 1
btnScale.Parent = ToggleButton

ToggleButton.MouseEnter:Connect(function()
    TweenService:Create(btnScale, TweenInfo.new(0.15, Enum.EasingStyle.Quart), { Scale = 1.06 }):Play()
end)
ToggleButton.MouseLeave:Connect(function()
    TweenService:Create(btnScale, TweenInfo.new(0.15, Enum.EasingStyle.Quart), { Scale = 1 }):Play()
end)

local btnDragging, btnDragInput, btnDragStart, btnStartPos, btnDidDrag = false, nil, nil, nil, false
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDidDrag = false
        btnDragStart = input.Position
        btnStartPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then btnDragging = false end
        end)
    end
end)
ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        btnDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == btnDragInput and btnDragging then
        local d = input.Position - btnDragStart
        if d.Magnitude > 4 then btnDidDrag = true end
        ToggleButton.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + d.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + d.Y)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    if not btnDidDrag then
        ToggleButton.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, CONFIG.UI_W, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, CONFIG.UI_W, 0, CONFIG.UI_H)
        }):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ToggleButton.Visible = true end)
RefreshBtn.MouseButton1Click:Connect(function() RefreshBtn.Text = "…"; task.wait(0.6); RefreshBtn.Text = "⟳" end)

local Tabs, TabByName = {}, {}
local activeTabId = nil
local tabCounter = 0

local function selectTab(id)
    activeTabId = id
    for tid, t in pairs(Tabs) do
        local isActive = (tid == id)
        t.btn.BackgroundColor3 = isActive and C.bg3 or C.bg2
        if t.btn:GetAttribute("HasIconLabel") then
            for _, ch in ipairs(t.btn:GetChildren()) do
                if ch:IsA("TextLabel") then ch.TextColor3 = isActive and C.white or C.text2 end
            end
        else
            t.btn.TextColor3 = isActive and C.white or C.text2
        end
        t.ind.Visible = isActive
        t.content.Visible = isActive
    end
end

local function makeTab(cfg)
    if type(cfg) == "string" then cfg = { Title = cfg } end
    cfg = cfg or {}
    local name = cfg.Name or cfg.Title or "Tab"
    local icon = cfg.Icon
    local bgSource = cfg.Background or cfg.BackgroundImage or cfg.Bg
    local bgTransparency = cfg.BackgroundTransparency
    if bgTransparency == nil then bgTransparency = 0.55 end
    local bgSize = cfg.BackgroundSize or 90
    local bgPadding = cfg.BackgroundPadding or 6

    tabCounter = tabCounter + 1
    local id = "tab_"..tabCounter

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundColor3 = C.bg2
    btn.Text = string.upper(tostring(name))
    btn.TextColor3 = C.text2
    btn.TextSize = 9; btn.Font = Enum.Font.Code
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    btn.ZIndex = 4; btn.Parent = Sidebar
    corner(btn, 2)
    regTheme(btn, "BackgroundColor3", "bg2")

    if icon then
        local ic = newIcon(btn, icon, UDim2.fromOffset(10,10), C.white)
        if ic then
            ic.Position = UDim2.new(0, 4, 0.5, -5)
            btn.Text = ""
            local tlbl = Instance.new("TextLabel")
            tlbl.Size = UDim2.new(1, -18, 1, 0)
            tlbl.Position = UDim2.new(0, 16, 0, 0)
            tlbl.BackgroundTransparency = 1
            tlbl.Text = string.upper(tostring(name))
            tlbl.TextColor3 = C.text2
            tlbl.TextSize = 9; tlbl.Font = Enum.Font.Code
            tlbl.TextXAlignment = Enum.TextXAlignment.Left
            tlbl.ZIndex = 6; tlbl.Parent = btn
            btn:SetAttribute("HasIconLabel", true)
        end
    end

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 2, 0.6, 0)
    ind.Position = UDim2.new(0, 0, 0.5, 0)
    ind.AnchorPoint = Vector2.new(0, 0.5)
    ind.BackgroundColor3 = C.white
    ind.BorderSizePixel = 0; ind.ZIndex = 5
    ind.Visible = false; ind.Parent = btn
    regTheme(ind, "BackgroundColor3", "accent")

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.fromScale(1, 1)
    content.BackgroundColor3 = C.bg2
    content.BorderSizePixel = 0
    content.Visible = false
    content.ZIndex = 3
    content.ScrollBarThickness = 2
    content.ScrollBarImageColor3 = C.line2
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = ContentHost
    corner(content, 3); stroke(content, C.line, 1)
    regTheme(content, "BackgroundColor3", "bg2")

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 5); pad.PaddingBottom = UDim.new(0, 5)
    pad.PaddingLeft = UDim.new(0, 5); pad.PaddingRight = UDim.new(0, 5)
    pad.Parent = content

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 5)
    list.Parent = content

    local bgImg
    if bgSource then
        local resolved = normalizeImage(bgSource)
        if resolved ~= "" then
            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(0, 0, 0, 0)
            wrap.BackgroundTransparency = 1
            wrap.LayoutOrder = -100000
            wrap.ZIndex = 1
            wrap.Parent = content
            bgImg = Instance.new("ImageLabel")
            bgImg.Size = UDim2.fromOffset(bgSize, bgSize)
            bgImg.Position = UDim2.new(0, bgPadding, 0, bgPadding)
            bgImg.BackgroundTransparency = 1
            bgImg.Image = resolved
            bgImg.ImageTransparency = bgTransparency
            bgImg.ScaleType = Enum.ScaleType.Fit
            bgImg.ZIndex = 1
            bgImg.Parent = wrap
        end
    end

    Tabs[id] = { btn = btn, ind = ind, content = content, list = list }

    btn.MouseButton1Click:Connect(function() selectTab(id) end)
    btn.MouseEnter:Connect(function()
        if activeTabId ~= id then btn.BackgroundColor3 = C.bg3 end
    end)
    btn.MouseLeave:Connect(function()
        if activeTabId ~= id then btn.BackgroundColor3 = C.bg2 end
    end)

    local Tab = { _id = id, _name = name, _content = content, _list = list, Sections = {} }

    function Tab:CreateSection(scfg, callback)
        if type(scfg) == "function" then callback = scfg; scfg = {} end
        if type(scfg) ~= "table" then scfg = { Name = tostring(scfg or "Section") } end

        local sName = scfg.Name or scfg.Title or "Section"
        local sIcon = scfg.Icon
        local opened = scfg.Opened
        if opened == nil then opened = true end

        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, 0, 0, 0)
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.BackgroundColor3 = C.bg3
        holder.BackgroundTransparency = 0.55
        holder.BorderSizePixel = 0
        holder.ZIndex = 5
        holder.Parent = content
        corner(holder, 3)
        local holderStroke = stroke(holder, C.line, 1, 0.4)
        regTheme(holderStroke, "Color", "line")

        local holderPad = Instance.new("UIPadding")
        holderPad.PaddingTop = UDim.new(0, 5); holderPad.PaddingBottom = UDim.new(0, 5)
        holderPad.PaddingLeft = UDim.new(0, 5); holderPad.PaddingRight = UDim.new(0, 5)
        holderPad.Parent = holder

        local holderList = Instance.new("UIListLayout")
        holderList.SortOrder = Enum.SortOrder.LayoutOrder
        holderList.Padding = UDim.new(0, 4)
        holderList.Parent = holder

        local headRow = Instance.new("TextButton")
        headRow.Size = UDim2.new(1, 0, 0, 14)
        headRow.BackgroundTransparency = 1
        headRow.Text = ""; headRow.AutoButtonColor = false
        headRow.ZIndex = 6; headRow.Parent = holder

        local headLbl = Instance.new("TextLabel")
        headLbl.Size = UDim2.new(1, -18, 1, 0)
        headLbl.Position = UDim2.new(0, 16, 0, 0)
        headLbl.BackgroundTransparency = 1
        headLbl.Text = string.upper(tostring(sName))
        headLbl.Font = Enum.Font.Code; headLbl.TextSize = 9
        headLbl.TextColor3 = C.text2
        headLbl.TextXAlignment = Enum.TextXAlignment.Left
        headLbl.ZIndex = 7; headLbl.Parent = headRow
        regTheme(headLbl, "TextColor3", "text2")

        local headAccent = Instance.new("Frame")
        headAccent.Size = UDim2.new(0, 8, 0, 1)
        headAccent.Position = UDim2.new(0, 0, 0.5, 0)
        headAccent.BackgroundColor3 = C.white
        headAccent.BorderSizePixel = 0; headAccent.ZIndex = 7
        headAccent.Parent = headRow
        regTheme(headAccent, "BackgroundColor3", "accent")

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.fromOffset(10, 10)
        arrow.Position = UDim2.new(1, -12, 0.5, -5)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▾"
        arrow.Font = Enum.Font.Code; arrow.TextSize = 10
        arrow.TextColor3 = C.text2
        arrow.ZIndex = 7; arrow.Parent = headRow
        regTheme(arrow, "TextColor3", "text2")

        if sIcon then
            local ic = newIcon(headRow, sIcon, UDim2.fromOffset(9,9), C.text2)
            if ic then ic.Position = UDim2.new(0,0,0.5,-4) end
        end

        local bodyHost = Instance.new("Frame")
        bodyHost.Size = UDim2.new(1, 0, 0, 0)
        bodyHost.AutomaticSize = Enum.AutomaticSize.Y
        bodyHost.BackgroundTransparency = 1
        bodyHost.ZIndex = 6
        bodyHost.Visible = opened
        bodyHost.Parent = holder

        local bodyList = Instance.new("UIListLayout")
        bodyList.SortOrder = Enum.SortOrder.LayoutOrder
        bodyList.Padding = UDim.new(0, 4)
        bodyList.Parent = bodyHost

        local Section = { _holder = holder, _body = bodyHost, _list = bodyList, _opened = opened, Elements = {} }

        headRow.MouseButton1Click:Connect(function()
            opened = not opened
            bodyHost.Visible = opened
            arrow.Text = opened and "▾" or "▸"
        end)
        function Section:SetOpened(v) opened = v and true or false; bodyHost.Visible = opened; arrow.Text = opened and "▾" or "▸" end
        function Section:Toggle() Section:SetOpened(not opened) end
        function Section:IsOpened() return opened end
        function Section:Add(instance)
            if typeof(instance) == "Instance" then
                instance.Parent = bodyHost
                instance.ZIndex = math.max(instance.ZIndex, 6)
                table.insert(Section.Elements, instance)
                return instance
            end
        end

        local function rowBase(height)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, height or 28)
            row.BackgroundColor3 = C.bg2
            row.BorderSizePixel = 0
            row.ZIndex = 6
            row.Parent = bodyHost
            corner(row, 2)
            local s = stroke(row, C.line, 1, 0.5)
            regTheme(row, "BackgroundColor3", "bg2")
            regTheme(s, "Color", "line")
            return row, s
        end

        local function attachIcon(row, cfg2, lbl)
            if not cfg2 or not cfg2.Icon then return nil end
            local pos = cfg2.IconPosition or "Left"
            local ic = newIcon(row, cfg2.Icon, UDim2.fromOffset(11,11), C.white)
            if not ic then return nil end
            ic.AnchorPoint = Vector2.new(pos == "Right" and 1 or 0, 0.5)
            ic.Position = pos == "Right" and UDim2.new(1,-10,0.5,0) or UDim2.new(0,9,0.5,0)
            if lbl and pos == "Left" then
                lbl.Position = UDim2.new(0, 24, lbl.Position.Y.Scale, lbl.Position.Y.Offset)
                lbl.Size = UDim2.new(lbl.Size.X.Scale, lbl.Size.X.Offset - 20, lbl.Size.Y.Scale, lbl.Size.Y.Offset)
            end
            return ic
        end

        function Section:CreateToggle(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Toggle"
            local desc = cfg.Desc or cfg.Description or ""
            local default = false
            if type(cfg.Value) == "boolean" then default = cfg.Value
            else default = pickDefault(cfg, false) end
            local callback = cfg.Callback or function() end
            local flag = cfg.Flag
            if flag and _G.BANANAUI_Flags and _G.BANANAUI_Flags[flag] ~= nil then default = _G.BANANAUI_Flags[flag] end

            local h = (desc ~= "" and 42 or 28)
            local row = rowBase(h)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -60, 0, 13)
            lbl.Position = UDim2.new(0, 9, 0, desc ~= "" and 5 or 8)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = C.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 8; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, cfg, lbl)

            if desc ~= "" then
                local d = Instance.new("TextLabel")
                d.Size = UDim2.new(1, -18, 0, 16)
                d.Position = UDim2.new(0, 9, 0, 20)
                d.BackgroundTransparency = 1
                d.Text = desc; d.Font = Enum.Font.Code; d.TextSize = 8
                d.TextColor3 = C.text3
                d.TextXAlignment = Enum.TextXAlignment.Left
                d.TextYAlignment = Enum.TextYAlignment.Top
                d.TextWrapped = true; d.ZIndex = 8; d.Parent = row
                regTheme(d, "TextColor3", "text3")
            end

            local track = Instance.new("TextButton")
            track.Size = UDim2.fromOffset(28, 14)
            track.Position = UDim2.new(1, -38, 0.5, -7)
            track.BackgroundColor3 = default and C.white or C.bg3
            track.Text = ""; track.AutoButtonColor = false
            track.ZIndex = 8; track.Parent = row
            corner(track, 7)
            local trackStroke = stroke(track, C.line, 1, 0.2)
            regTheme(trackStroke, "Color", "line")

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(10, 10)
            knob.Position = default and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
            knob.BackgroundColor3 = default and C.black or C.text2
            knob.BorderSizePixel = 0; knob.ZIndex = 9
            knob.Parent = track
            corner(knob, 5)

            local state = default
            local function refresh(anim)
                local pos = state and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)
                local kc = state and C.black or C.text2
                if anim then
                    Tween(knob, 0.15, { Position = pos, BackgroundColor3 = kc })
                    Tween(track, 0.15, { BackgroundColor3 = state and C.white or C.bg3 })
                else
                    knob.Position = pos; knob.BackgroundColor3 = kc
                    track.BackgroundColor3 = state and C.white or C.bg3
                end
            end
            refresh(false)

            track.MouseButton1Click:Connect(function()
                state = not state
                if flag then
                    _G.BANANAUI_Flags = _G.BANANAUI_Flags or {}
                    _G.BANANAUI_Flags[flag] = state
                end
                refresh(true); callback(state)
            end)
            table.insert(themeEls, { el = track, prop = "BackgroundColor3", role = "dynamic_toggle", state = function() return state end })

            local obj = {}
            function obj:Set(v) state = v; refresh(true); callback(state) end
            function obj:Get() return state end
            return obj
        end

        function Section:CreateSlider(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Slider"
            local min, max, default = parseSliderValue(cfg)
            local callback = cfg.Callback or function() end
            local suffix = cfg.Suffix or ""
            local step = cfg.Step or 1

            local row = rowBase(34)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -55, 0, 13)
            lbl.Position = UDim2.new(0, 9, 0, 3)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = C.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 8; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, cfg, lbl)

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.fromOffset(44, 13)
            valLbl.Position = UDim2.new(1, -50, 0, 3)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(default)..suffix
            valLbl.Font = Enum.Font.Code; valLbl.TextSize = 9
            valLbl.TextColor3 = C.white
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.ZIndex = 8; valLbl.Parent = row
            regTheme(valLbl, "TextColor3", "accent")

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -18, 0, 3)
            track.Position = UDim2.new(0, 9, 0, 23)
            track.BackgroundColor3 = C.bg3
            track.BorderSizePixel = 0; track.ZIndex = 8
            track.Parent = row
            regTheme(track, "BackgroundColor3", "bg3")

            local fill = Instance.new("Frame")
            local t0 = (default - min) / math.max(max - min, 1)
            fill.Size = UDim2.new(t0, 0, 1, 0)
            fill.BackgroundColor3 = C.white
            fill.BorderSizePixel = 0; fill.ZIndex = 9
            fill.Parent = track
            regTheme(fill, "BackgroundColor3", "accent")

            local handle = Instance.new("Frame")
            handle.Size = UDim2.fromOffset(8, 8)
            handle.AnchorPoint = Vector2.new(0.5, 0.5)
            handle.Position = UDim2.new(t0, 0, 0.5, 0)
            handle.Rotation = 45
            handle.BackgroundColor3 = C.white
            handle.BorderSizePixel = 0; handle.ZIndex = 10
            handle.Parent = track
            regTheme(handle, "BackgroundColor3", "accent")

            local hitbox = Instance.new("TextButton")
            hitbox.Size = UDim2.new(1, 0, 0, 26)
            hitbox.Position = UDim2.new(0, 0, 0, 12)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""; hitbox.AutoButtonColor = false
            hitbox.ZIndex = 11; hitbox.Parent = row

            local dragging = false
            local function apply(v)
                v = math.clamp(math.floor(v/step + 0.5)*step, min, max)
                valLbl.Text = tostring(v)..suffix
                local t = (v - min) / math.max(max - min, 1)
                fill.Size = UDim2.new(t, 0, 1, 0)
                handle.Position = UDim2.new(t, 0, 0.5, 0)
                callback(v)
            end
            local function fromX(x)
                local ax = track.AbsolutePosition.X
                local sx = track.AbsoluteSize.X
                if sx <= 0 then return end
                apply(min + math.clamp((x - ax) / sx, 0, 1) * (max - min))
            end
            hitbox.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; fromX(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    fromX(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function() dragging = false end)

            local obj = {}
            function obj:Set(v) apply(v) end
            function obj:Get() return tonumber(valLbl.Text) end
            return obj
        end

        function Section:CreateButton(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Button"
            local desc = cfg.Description or cfg.Desc
            local icon = cfg.Icon
            local bannerSrc = cfg.Image or cfg.Banner
            local bannerH = cfg.ImageHeight or 50
            local callback = cfg.Callback or function() end
            local customColor = cfg.Color or cfg.ButtonColor
            if type(customColor) == "string" then
                local ok, col = pcall(function() return hex(customColor) end)
                customColor = ok and col or nil
            elseif typeof(customColor) ~= "Color3" then
                customColor = nil
            end

            local hasBanner = (bannerSrc ~= nil) and (normalizeImage(bannerSrc) ~= "")
            local hasIcon = icon ~= nil
            local textTop = hasBanner and (bannerH + 5) or 5
            local textLeft = hasIcon and 26 or 9
            local textBlockH = desc and 26 or 13
            local totalH = textTop + textBlockH + 7

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, totalH)
            btn.BackgroundColor3 = customColor or C.bg2
            btn.Text = ""; btn.AutoButtonColor = false
            btn.ClipsDescendants = true
            btn.ZIndex = 6; btn.Parent = bodyHost
            corner(btn, 2)
            local st = stroke(btn, C.line, 1, 0.4)
            regTheme(btn, "BackgroundColor3", customColor and "dynamic_btn" or "bg2")
            btn:SetAttribute("CustomBg", customColor ~= nil)
            regTheme(st, "Color", "line")

            local accent = Instance.new("Frame")
            accent.Size = UDim2.new(0, 2, 1, -8)
            accent.Position = UDim2.new(0, 0, 0, 4)
            accent.BackgroundColor3 = C.white
            accent.BorderSizePixel = 0; accent.ZIndex = 7
            accent.Parent = btn
            regTheme(accent, "BackgroundColor3", "accent")

            if hasBanner then
                local bg = Instance.new("ImageLabel")
                bg.Size = UDim2.new(1, 0, 0, bannerH)
                bg.BackgroundTransparency = 1
                bg.Image = normalizeImage(bannerSrc)
                bg.ScaleType = Enum.ScaleType.Crop
                bg.ZIndex = 7; bg.Parent = btn
            end

            if hasIcon then
                local ic = newIcon(btn, icon, UDim2.fromOffset(12,12), C.white)
                if ic then ic.Position = UDim2.new(0, 9, 0, textTop + math.floor(textBlockH/2) - 6) end
            end

            local title = Instance.new("TextLabel")
            title.Position = UDim2.new(0, textLeft, 0, textTop)
            title.Size = UDim2.new(1, -(textLeft + 9), 0, 13)
            title.BackgroundTransparency = 1
            title.Text = name
            title.Font = Enum.Font.Code; title.TextSize = 10
            title.TextColor3 = C.text
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 8; title.Parent = btn
            regTheme(title, "TextColor3", "text")

            if desc then
                local dl = Instance.new("TextLabel")
                dl.Position = UDim2.new(0, textLeft, 0, textTop + 13)
                dl.Size = UDim2.new(1, -(textLeft + 9), 0, 13)
                dl.BackgroundTransparency = 1
                dl.Text = desc; dl.Font = Enum.Font.Code; dl.TextSize = 8
                dl.TextColor3 = C.text3
                dl.TextXAlignment = Enum.TextXAlignment.Left
                dl.TextWrapped = true
                dl.ZIndex = 8; dl.Parent = btn
                regTheme(dl, "TextColor3", "text3")
            end

            btn.MouseEnter:Connect(function()
                if not customColor then Tween(btn, 0.12, { BackgroundColor3 = C.bg3 })
                else Tween(btn, 0.12, { BackgroundColor3 = shade(customColor, 0.1) }) end
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, 0.12, { BackgroundColor3 = customColor or C.bg2 })
            end)
            btn.MouseButton1Click:Connect(function() callback() end)
        end

        function Section:CreateBanner(cfg)
            cfg = cfg or {}
            local image = cfg.Image or cfg.Banner
            local height = cfg.Height or 70
            local bTitle = cfg.Title or cfg.Name
            local caption = cfg.Caption or cfg.Description

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, height)
            frame.BackgroundColor3 = C.bg2
            frame.ClipsDescendants = true
            frame.ZIndex = 6; frame.Parent = bodyHost
            corner(frame, 2)
            local st = stroke(frame, C.line, 1, 0.4)
            regTheme(frame, "BackgroundColor3", "bg2")
            regTheme(st, "Color", "line")

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.fromScale(1, 1)
            img.BackgroundTransparency = 1
            img.Image = normalizeImage(image)
            img.ScaleType = Enum.ScaleType.Crop
            img.ZIndex = 7; img.Parent = frame

            if bTitle or caption then
                local ov = Instance.new("Frame")
                ov.Size = UDim2.fromScale(1, 1)
                ov.BackgroundColor3 = Color3.new(0,0,0)
                ov.BackgroundTransparency = 0.4
                ov.ZIndex = 8; ov.Parent = frame
                local g = Instance.new("UIGradient")
                g.Rotation = 90
                g.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.55, 0.85),
                    NumberSequenceKeypoint.new(1, 0.2),
                })
                g.Parent = ov

                local tag = Instance.new("Frame")
                tag.Size = UDim2.new(0, 14, 0, 2)
                tag.Position = UDim2.new(0, 9, 1, -(caption and 34 or 22))
                tag.BackgroundColor3 = C.white
                tag.BorderSizePixel = 0; tag.ZIndex = 9; tag.Parent = frame
                regTheme(tag, "BackgroundColor3", "accent")

                if bTitle then
                    local tl = Instance.new("TextLabel")
                    tl.Position = UDim2.new(0, 9, 1, -(caption and 26 or 16))
                    tl.Size = UDim2.new(1, -18, 0, 14)
                    tl.BackgroundTransparency = 1
                    tl.Text = bTitle; tl.Font = Enum.Font.Code; tl.TextSize = 11
                    tl.TextColor3 = Color3.new(1,1,1)
                    tl.TextXAlignment = Enum.TextXAlignment.Left
                    tl.ZIndex = 9; tl.Parent = frame
                end
                if caption then
                    local cl = Instance.new("TextLabel")
                    cl.Position = UDim2.new(0, 9, 1, -14)
                    cl.Size = UDim2.new(1, -18, 0, 11)
                    cl.BackgroundTransparency = 1
                    cl.Text = caption; cl.Font = Enum.Font.Code; cl.TextSize = 8
                    cl.TextColor3 = Color3.fromRGB(225,225,230)
                    cl.TextXAlignment = Enum.TextXAlignment.Left
                    cl.ZIndex = 9; cl.Parent = frame
                end
            end
            local obj = {}
            function obj:SetImage(src) img.Image = normalizeImage(src) end
            return obj
        end

        function Section:CreateHero(cfg)
            cfg = cfg or {}
            local hTitle = cfg.Title or cfg.Name or ""
            local contentTxt = cfg.Content or cfg.Description or cfg.Text or ""
            local image = cfg.Image
            local imageW = cfg.ImageWidth or 70
            local height = cfg.Height or 90

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, height)
            frame.BackgroundColor3 = C.bg2
            frame.ClipsDescendants = true
            frame.ZIndex = 6; frame.Parent = bodyHost
            corner(frame, 3)
            local st = stroke(frame, C.line, 1, 0.4)
            regTheme(frame, "BackgroundColor3", "bg2")
            regTheme(st, "Color", "line")

            local accent = Instance.new("Frame")
            accent.Size = UDim2.new(1, 0, 0, 1)
            accent.BackgroundColor3 = C.white
            accent.BorderSizePixel = 0; accent.ZIndex = 7; accent.Parent = frame
            regTheme(accent, "BackgroundColor3", "accent")

            local resolvedImg = normalizeImage(image)
            local hasImage = resolvedImg ~= ""

            local textHolder = Instance.new("Frame")
            textHolder.Size = hasImage and UDim2.new(1, -(imageW + 20), 1, -14) or UDim2.new(1, -14, 1, -14)
            textHolder.Position = UDim2.new(0, 9, 0, 8)
            textHolder.BackgroundTransparency = 1
            textHolder.ZIndex = 7; textHolder.Parent = frame

            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 0, 14)
            tl.BackgroundTransparency = 1
            tl.Text = hTitle; tl.Font = Enum.Font.Code; tl.TextSize = 11
            tl.TextColor3 = C.text
            tl.TextXAlignment = Enum.TextXAlignment.Left
            tl.ZIndex = 8; tl.Parent = textHolder
            regTheme(tl, "TextColor3", "text")

            local cl = Instance.new("TextLabel")
            cl.Size = UDim2.new(1, 0, 1, -18)
            cl.Position = UDim2.new(0, 0, 0, 18)
            cl.BackgroundTransparency = 1
            cl.Text = contentTxt; cl.Font = Enum.Font.Code; cl.TextSize = 8
            cl.TextColor3 = C.text3
            cl.TextWrapped = true
            cl.TextXAlignment = Enum.TextXAlignment.Left
            cl.TextYAlignment = Enum.TextYAlignment.Top
            cl.ZIndex = 8; cl.Parent = textHolder
            regTheme(cl, "TextColor3", "text3")

            local heroImg
            if hasImage then
                heroImg = Instance.new("ImageLabel")
                heroImg.Size = UDim2.fromOffset(imageW, height - 14)
                heroImg.Position = UDim2.new(1, -imageW - 9, 0.5, -(height-14)/2)
                heroImg.BackgroundTransparency = 1
                heroImg.Image = resolvedImg
                heroImg.ScaleType = Enum.ScaleType.Fit
                heroImg.ZIndex = 7; heroImg.Parent = frame
            end
            local obj = {}
            function obj:SetImage(src) if heroImg then heroImg.Image = normalizeImage(src) end end
            function obj:SetText(t, ct) if t then tl.Text = t end; if ct then cl.Text = ct end end
            return obj
        end

        function Section:CreateCardGrid(cfg)
            cfg = cfg or {}
            local cards = cfg.Cards or {}
            local columns = cfg.Columns or 2
            local cardH = cfg.CardHeight or 80

            local grid = Instance.new("Frame")
            grid.Size = UDim2.new(1, 0, 0, 0)
            grid.AutomaticSize = Enum.AutomaticSize.Y
            grid.BackgroundTransparency = 1
            grid.ZIndex = 6; grid.Parent = bodyHost

            local gl = Instance.new("UIGridLayout")
            gl.CellPadding = UDim2.new(0, 5, 0, 5)
            gl.CellSize = UDim2.new(1/columns, -(5*(columns-1)/columns), 0, cardH)
            gl.FillDirectionMaxCells = 0
            gl.SortOrder = Enum.SortOrder.LayoutOrder
            gl.Parent = grid

            local objs = {}
            for i, cc in ipairs(cards) do
                local card = Instance.new("Frame")
                card.BackgroundColor3 = C.bg2
                card.ClipsDescendants = true
                card.ZIndex = 6; card.LayoutOrder = i; card.Parent = grid
                corner(card, 2)
                local cst = stroke(card, C.line, 1, 0.45)
                regTheme(card, "BackgroundColor3", "bg2")
                regTheme(cst, "Color", "line")

                local cIcon = cc.Icon
                local cTitle = cc.Title or cc.Name or ""
                local cDesc = cc.Description or cc.Content or ""
                local cBtn = cc.Button

                local head = Instance.new("Frame")
                head.Size = UDim2.new(1, -14, 0, 22)
                head.Position = UDim2.new(0, 7, 0, 7)
                head.BackgroundTransparency = 1
                head.ZIndex = 7; head.Parent = card

                local iconOffset = 0
                if cIcon then
                    local ih = Instance.new("Frame")
                    ih.Size = UDim2.fromOffset(18, 18)
                    ih.BackgroundColor3 = C.bg3
                    ih.BorderSizePixel = 0; ih.ZIndex = 7; ih.Parent = head
                    corner(ih, 3)
                    local ico = newIcon(ih, cIcon, UDim2.fromOffset(11,11), C.white)
                    if ico then ico.AnchorPoint = Vector2.new(0.5,0.5); ico.Position = UDim2.fromScale(0.5,0.5) end
                    iconOffset = 23
                end

                local tlbl = Instance.new("TextLabel")
                tlbl.Size = UDim2.new(1, -iconOffset, 1, 0)
                tlbl.Position = UDim2.new(0, iconOffset, 0, 0)
                tlbl.BackgroundTransparency = 1
                tlbl.Text = cTitle; tlbl.Font = Enum.Font.Code; tlbl.TextSize = 10
                tlbl.TextColor3 = C.text
                tlbl.TextXAlignment = Enum.TextXAlignment.Left
                tlbl.ZIndex = 8; tlbl.Parent = head
                regTheme(tlbl, "TextColor3", "text")

                local dlbl = Instance.new("TextLabel")
                dlbl.Size = UDim2.new(1, -14, 0, cBtn and (cardH - 68) or (cardH - 36))
                dlbl.Position = UDim2.new(0, 7, 0, 30)
                dlbl.BackgroundTransparency = 1
                dlbl.Text = cDesc; dlbl.Font = Enum.Font.Code; dlbl.TextSize = 8
                dlbl.TextColor3 = C.text3
                dlbl.TextWrapped = true
                dlbl.TextXAlignment = Enum.TextXAlignment.Left
                dlbl.TextYAlignment = Enum.TextYAlignment.Top
                dlbl.ZIndex = 8; dlbl.Parent = card
                regTheme(dlbl, "TextColor3", "text3")

                if cBtn then
                    local bb = Instance.new("TextButton")
                    bb.Size = UDim2.new(1, -14, 0, 22)
                    bb.Position = UDim2.new(0, 7, 1, -29)
                    bb.BackgroundColor3 = C.bg3
                    bb.Text = ""; bb.AutoButtonColor = false
                    bb.ZIndex = 7; bb.Parent = card
                    corner(bb, 2)
                    local bst = stroke(bb, C.line, 1, 0.4)
                    regTheme(bb, "BackgroundColor3", "bg3")
                    regTheme(bst, "Color", "line")

                    local btl = Instance.new("TextLabel")
                    btl.Size = UDim2.new(1, -20, 1, 0)
                    btl.Position = UDim2.new(0, 7, 0, 0)
                    btl.BackgroundTransparency = 1
                    btl.Text = cBtn.Text or "Open"
                    btl.Font = Enum.Font.Code; btl.TextSize = 9
                    btl.TextColor3 = C.text
                    btl.TextXAlignment = Enum.TextXAlignment.Left
                    btl.ZIndex = 8; btl.Parent = bb
                    regTheme(btl, "TextColor3", "text")

                    local arrow = Instance.new("TextLabel")
                    arrow.Size = UDim2.fromOffset(14, 14)
                    arrow.Position = UDim2.new(1, -20, 0.5, -7)
                    arrow.BackgroundTransparency = 1
                    arrow.Text = ">"; arrow.Font = Enum.Font.Code; arrow.TextSize = 10
                    arrow.TextColor3 = C.white
                    arrow.ZIndex = 8; arrow.Parent = bb
                    regTheme(arrow, "TextColor3", "accent")

                    bb.MouseEnter:Connect(function() Tween(bb, 0.1, { BackgroundColor3 = C.bg2 }) end)
                    bb.MouseLeave:Connect(function() Tween(bb, 0.12, { BackgroundColor3 = C.bg3 }) end)
                    bb.MouseButton1Click:Connect(function() if cBtn.Callback then pcall(cBtn.Callback) end end)
                end
                table.insert(objs, card)
            end
            return { Cards = objs }
        end

        function Section:CreateDropdown(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Dropdown"
            local options = cfg.Options or cfg.Values or cfg.Items or {}
            local multi = cfg.Multi == true or cfg.Multiple == true
            local default = cfg.Default
            if default == nil and type(cfg.Value) ~= "table" then default = cfg.Value end
            if default == nil and type(cfg.Value) == "table" then default = cfg.Value end
            local callback = cfg.Callback or function() end

            local selected
            if multi then
                selected = {}
                if type(default) == "table" then for _, v in ipairs(default) do selected[v] = true end
                elseif default ~= nil then selected[default] = true end
            else selected = default end

            local row = rowBase(28)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.45, 0, 1, 0)
            lbl.Position = UDim2.new(0, 9, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name; lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = C.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 8; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, cfg, lbl)

            local sel = Instance.new("TextButton")
            sel.Size = UDim2.new(0.55, -16, 0, 18)
            sel.Position = UDim2.new(0.44, 0, 0.5, -9)
            sel.BackgroundColor3 = C.bg3
            sel.Text = ""; sel.AutoButtonColor = false
            sel.ZIndex = 7; sel.Parent = row
            corner(sel, 2)
            local sst = stroke(sel, C.line, 1, 0.4)
            regTheme(sel, "BackgroundColor3", "bg3")
            regTheme(sst, "Color", "line")

            local function fmt()
                if multi then
                    local parts = {}
                    for _, o in ipairs(options) do
                        local v = type(o) == "table" and (o.Value or o.Text) or o
                        local t = type(o) == "table" and (o.Text or o.Value) or tostring(o)
                        if selected[v] then table.insert(parts, tostring(t)) end
                    end
                    if #parts == 0 then return "Select..." end
                    if #parts <= 2 then return table.concat(parts, ", ") end
                    return string.format("%d selected", #parts)
                end
                return selected ~= nil and tostring(selected) or "Select..."
            end

            local sLbl = Instance.new("TextLabel")
            sLbl.Size = UDim2.new(1, -10, 1, 0)
            sLbl.Position = UDim2.new(0, 5, 0, 0)
            sLbl.BackgroundTransparency = 1
            sLbl.Text = fmt(); sLbl.Font = Enum.Font.Code; sLbl.TextSize = 9
            sLbl.TextColor3 = C.text
            sLbl.TextXAlignment = Enum.TextXAlignment.Left
            sLbl.TextTruncate = Enum.TextTruncate.AtEnd
            sLbl.ZIndex = 8; sLbl.Parent = sel
            regTheme(sLbl, "TextColor3", "text")

            local list = Instance.new("ScrollingFrame")
            list.BackgroundColor3 = C.bg2
            list.BorderSizePixel = 0
            list.Visible = false
            list.ZIndex = 100
            list.ClipsDescendants = true
            list.ScrollBarThickness = 2
            list.ScrollBarImageColor3 = C.line2
            list.CanvasSize = UDim2.new(0, 0, 0, 0)
            list.Parent = ScreenGui
            corner(list, 3); stroke(list, C.line, 1, 0.15)
            regTheme(list, "BackgroundColor3", "bg2")

            local lp = Instance.new("UIPadding")
            lp.PaddingTop = UDim.new(0, 2); lp.PaddingBottom = UDim.new(0, 2)
            lp.Parent = list
            local ll = Instance.new("UIListLayout")
            ll.SortOrder = Enum.SortOrder.LayoutOrder
            ll.Parent = list

            local function getMultiArr()
                local arr = {}
                for _, o in ipairs(options) do
                    local v = type(o) == "table" and (o.Value or o.Text) or o
                    if selected[v] then table.insert(arr, v) end
                end
                return arr
            end

            local function build()
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, o in ipairs(options) do
                    local t = type(o) == "table" and (o.Text or o.Value) or tostring(o)
                    local v = type(o) == "table" and (o.Value or o.Text) or o
                    local isOn = multi and selected[v] or (selected == v)
                    local ob = Instance.new("TextButton")
                    ob.Size = UDim2.new(1, 0, 0, 18)
                    ob.BackgroundColor3 = C.bg2
                    ob.BackgroundTransparency = isOn and 0.6 or 1
                    ob.Text = " "..t
                    ob.Font = Enum.Font.Code; ob.TextSize = 9
                    ob.TextColor3 = isOn and C.white or C.text
                    ob.TextXAlignment = Enum.TextXAlignment.Left
                    ob.ZIndex = 101; ob.LayoutOrder = i; ob.Parent = list
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            selected[v] = not selected[v]
                            sLbl.Text = fmt()
                            build()
                            callback(getMultiArr())
                        else
                            selected = v
                            sLbl.Text = t
                            list.Visible = false
                            callback(v)
                        end
                    end)
                end
                list.CanvasSize = UDim2.new(0, 0, 0, (#options * 18) + 4)
            end
            build()

            local openList = false
            sel.MouseButton1Click:Connect(function()
                openList = not openList
                if openList then
                    local ax, ay = sel.AbsolutePosition.X, sel.AbsolutePosition.Y
                    local sx, sy = sel.AbsoluteSize.X, sel.AbsoluteSize.Y
                    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
                    local h = math.clamp(#options * 18 + 4, 18, 160)
                    local w = math.max(sx, 110)
                    local x = math.clamp(ax, 8, math.max(8, vp.X - w - 8))
                    local y = ay + sy + 2
                    if y + h > vp.Y - 8 then y = math.max(8, ay - h - 2) end
                    list.Size = UDim2.fromOffset(w, h)
                    list.Position = UDim2.fromOffset(x, y)
                    list.Visible = true
                else list.Visible = false end
            end)

            local obj = {}
            function obj:Set(v)
                if multi then
                    selected = {}
                    if type(v) == "table" then for _, x in ipairs(v) do selected[x] = true end end
                    sLbl.Text = fmt(); build()
                else selected = v; sLbl.Text = tostring(v) end
            end
            function obj:Get() return multi and getMultiArr() or selected end
            return obj
        end

        function Section:CreateColorPicker(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Color"
            local default = cfg.Default or cfg.Value or C.white
            if type(default) == "string" then default = hex(default) end
            local callback = cfg.Callback or function() end

            local row = rowBase(28)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -45, 1, 0)
            lbl.Position = UDim2.new(0, 9, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name; lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = C.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 8; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, cfg, lbl)

            local swatch = Instance.new("Frame")
            swatch.Size = UDim2.fromOffset(22, 14)
            swatch.Position = UDim2.new(1, -30, 0.5, -7)
            swatch.BackgroundColor3 = default
            swatch.BorderSizePixel = 0; swatch.ZIndex = 8; swatch.Parent = row
            corner(swatch, 2); stroke(swatch, C.black, 1, 0.3)

            local click = Instance.new("TextButton")
            click.Size = UDim2.fromScale(1,1)
            click.BackgroundTransparency = 1
            click.Text = ""; click.ZIndex = 9; click.Parent = row

            local overlay = Instance.new("Frame")
            overlay.Size = UDim2.fromScale(1,1)
            overlay.BackgroundColor3 = Color3.new(0,0,0)
            overlay.BackgroundTransparency = 0.5
            overlay.Visible = false
            overlay.ZIndex = 200
            overlay.Parent = MainFrame

            local closeOverlay = Instance.new("TextButton")
            closeOverlay.Size = UDim2.fromScale(1,1)
            closeOverlay.BackgroundTransparency = 1
            closeOverlay.Text = ""
            closeOverlay.ZIndex = 200
            closeOverlay.Parent = overlay
            closeOverlay.MouseButton1Click:Connect(function() overlay.Visible = false end)

            local popup = Instance.new("Frame")
            popup.Size = UDim2.fromOffset(200, 170)
            popup.Position = UDim2.fromScale(0.5, 0.5)
            popup.AnchorPoint = Vector2.new(0.5, 0.5)
            popup.BackgroundColor3 = C.bg2
            popup.BorderSizePixel = 0; popup.ZIndex = 201; popup.Parent = overlay
            corner(popup, 3); stroke(popup, C.line, 1, 0.2)

            local hue, sat, val = default:ToHSV()
            local selCol = default

            local sv = Instance.new("Frame")
            sv.Size = UDim2.new(1, -20, 0, 90)
            sv.Position = UDim2.new(0, 10, 0, 10)
            sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            sv.BorderSizePixel = 0; sv.ZIndex = 202; sv.Parent = popup
            corner(sv, 2)

            local white = Instance.new("Frame")
            white.Size = UDim2.fromScale(1,1)
            white.BackgroundColor3 = Color3.new(1,1,1)
            white.BorderSizePixel = 0; white.ZIndex = 202; white.Parent = sv
            local wg = Instance.new("UIGradient")
            wg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
            wg.Parent = white

            local blk = Instance.new("Frame")
            blk.Size = UDim2.fromScale(1,1)
            blk.BackgroundColor3 = Color3.new(0,0,0)
            blk.BorderSizePixel = 0; blk.ZIndex = 203; blk.Parent = sv
            local bg = Instance.new("UIGradient")
            bg.Rotation = 90
            bg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
            bg.Parent = blk

            local cursor = Instance.new("Frame")
            cursor.Size = UDim2.fromOffset(8, 8)
            cursor.AnchorPoint = Vector2.new(0.5,0.5)
            cursor.Position = UDim2.new(sat, 0, 1-val, 0)
            cursor.Rotation = 45
            cursor.BackgroundColor3 = Color3.new(1,1,1)
            cursor.BorderSizePixel = 0; cursor.ZIndex = 204; cursor.Parent = sv

            local hueTrack = Instance.new("Frame")
            hueTrack.Size = UDim2.new(1, -20, 0, 10)
            hueTrack.Position = UDim2.new(0, 10, 0, 108)
            hueTrack.BorderSizePixel = 0; hueTrack.ZIndex = 202; hueTrack.Parent = popup
            local hg = Instance.new("UIGradient")
            hg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)),
                ColorSequenceKeypoint.new(0.166, Color3.fromHSV(0.166,1,1)),
                ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333,1,1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                ColorSequenceKeypoint.new(0.666, Color3.fromHSV(0.666,1,1)),
                ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833,1,1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1)),
            })
            hg.Parent = hueTrack

            local hueKnob = Instance.new("Frame")
            hueKnob.Size = UDim2.fromOffset(3, 14)
            hueKnob.AnchorPoint = Vector2.new(0.5,0.5)
            hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
            hueKnob.BackgroundColor3 = Color3.new(1,1,1)
            hueKnob.BorderSizePixel = 0; hueKnob.ZIndex = 203; hueKnob.Parent = hueTrack

            local prev = Instance.new("Frame")
            prev.Size = UDim2.fromOffset(24, 18)
            prev.Position = UDim2.new(0, 10, 0, 130)
            prev.BackgroundColor3 = selCol
            prev.BorderSizePixel = 0; prev.ZIndex = 202; prev.Parent = popup
            corner(prev, 2); stroke(prev, C.black, 1, 0.3)

            local done = Instance.new("TextButton")
            done.Size = UDim2.fromOffset(50, 18)
            done.Position = UDim2.new(1, -60, 0, 130)
            done.BackgroundColor3 = C.bg3
            done.Text = "done"
            done.Font = Enum.Font.Code; done.TextSize = 10
            done.TextColor3 = C.text
            done.BorderSizePixel = 0; done.AutoButtonColor = false
            done.ZIndex = 202; done.Parent = popup
            corner(done, 2); stroke(done, C.line, 1, 0.3)
            done.MouseButton1Click:Connect(function() overlay.Visible = false end)

            local function recalc(fire)
                selCol = Color3.fromHSV(hue, sat, val)
                sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                cursor.Position = UDim2.new(sat, 0, 1-val, 0)
                hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
                swatch.BackgroundColor3 = selCol
                prev.BackgroundColor3 = selCol
                if fire then callback(selCol) end
            end

            local dSV, dH = false, false
            sv.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dSV = true
                    local ax, ay = sv.AbsolutePosition.X, sv.AbsolutePosition.Y
                    local sx, sy = sv.AbsoluteSize.X, sv.AbsoluteSize.Y
                    sat = math.clamp((i.Position.X - ax)/sx, 0, 1)
                    val = 1 - math.clamp((i.Position.Y - ay)/sy, 0, 1)
                    recalc(true)
                end
            end)
            hueTrack.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dH = true
                    local ax = hueTrack.AbsolutePosition.X
                    local sx = hueTrack.AbsoluteSize.X
                    hue = math.clamp((i.Position.X - ax)/sx, 0, 1)
                    recalc(true)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
                if dSV then
                    local ax, ay = sv.AbsolutePosition.X, sv.AbsolutePosition.Y
                    local sx, sy = sv.AbsoluteSize.X, sv.AbsoluteSize.Y
                    sat = math.clamp((i.Position.X - ax)/sx, 0, 1)
                    val = 1 - math.clamp((i.Position.Y - ay)/sy, 0, 1)
                    recalc(true)
                elseif dH then
                    local ax = hueTrack.AbsolutePosition.X
                    local sx = hueTrack.AbsoluteSize.X
                    hue = math.clamp((i.Position.X - ax)/sx, 0, 1)
                    recalc(true)
                end
            end)
            UserInputService.InputEnded:Connect(function() dSV = false; dH = false end)
            click.MouseButton1Click:Connect(function() overlay.Visible = true end)

            local obj = {}
            function obj:Set(c) hue, sat, val = c:ToHSV(); recalc(true) end
            function obj:Get() return selCol end
            return obj
        end

        function Section:CreateInput(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Input"
            local placeholder = cfg.Placeholder or "type..."
            local default = ""
            if type(cfg.Value) == "string" then default = cfg.Value
            else default = pickDefault(cfg, "") end
            local callback = cfg.Callback or function() end

            local row = rowBase(28)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.45, 0, 1, 0)
            lbl.Position = UDim2.new(0, 9, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name; lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = C.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 8; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, cfg, lbl)

            local boxFrame = Instance.new("Frame")
            boxFrame.Size = UDim2.new(0.55, -16, 0, 18)
            boxFrame.Position = UDim2.new(0.44, 0, 0.5, -9)
            boxFrame.BackgroundColor3 = C.bg3
            boxFrame.BorderSizePixel = 0; boxFrame.ZIndex = 7; boxFrame.Parent = row
            corner(boxFrame, 2)
            local bfst = stroke(boxFrame, C.line, 1, 0.4)
            regTheme(boxFrame, "BackgroundColor3", "bg3")
            regTheme(bfst, "Color", "line")

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 1, 0)
            box.Position = UDim2.new(0, 5, 0, 0)
            box.BackgroundTransparency = 1
            box.Text = default; box.PlaceholderText = placeholder
            box.PlaceholderColor3 = C.text3
            box.TextColor3 = C.text
            box.Font = Enum.Font.Code; box.TextSize = 9
            box.ClearTextOnFocus = false
            box.ZIndex = 8; box.Parent = boxFrame
            regTheme(box, "TextColor3", "text")

            box.FocusLost:Connect(function(enter) callback(box.Text, enter) end)

            local obj = {}
            function obj:Set(t) box.Text = t end
            function obj:Get() return box.Text end
            return obj
        end

        function Section:CreateKeybind(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Keybind"
            local default = cfg.Default or cfg.Value
            if type(default) == "string" then
                default = Enum.KeyCode[default] or Enum.KeyCode.E
            end
            local callback = cfg.Callback or function() end

            local row = rowBase(28)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -85, 1, 0)
            lbl.Position = UDim2.new(0, 9, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name; lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = C.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 8; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, cfg, lbl)

            local kb = Instance.new("TextButton")
            kb.Size = UDim2.fromOffset(60, 18)
            kb.Position = UDim2.new(1, -68, 0.5, -9)
            kb.BackgroundColor3 = C.bg3
            kb.Text = default and default.Name or "none"
            kb.Font = Enum.Font.Code; kb.TextSize = 9
            kb.TextColor3 = C.text
            kb.BorderSizePixel = 0; kb.AutoButtonColor = false
            kb.ZIndex = 7; kb.Parent = row
            corner(kb, 2)
            local kbst = stroke(kb, C.line, 1, 0.4)
            regTheme(kb, "BackgroundColor3", "bg3")
            regTheme(kb, "TextColor3", "text")
            regTheme(kbst, "Color", "line")

            local current = default
            local listening = false
            local conn

            kb.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                kb.Text = "..."
                if conn then conn:Disconnect() end
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        current = input.KeyCode
                        kb.Text = current.Name
                        listening = false
                        if conn then conn:Disconnect() end
                        callback(current)
                    end
                end)
            end)

            local obj = {}
            function obj:Set(k) current = k; kb.Text = k and k.Name or "none" end
            function obj:Get() return current end
            return obj
        end

        function Section:CreateProgressBar(cfg)
            cfg = cfg or {}
            local name = cfg.Name or cfg.Title or "Progress"
            local min, max, default = parseSliderValue(cfg)
            local showPct = cfg.ShowPercent
            if showPct == nil then showPct = true end

            local row = rowBase(30)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -55, 0, 13)
            lbl.Position = UDim2.new(0, 9, 0, 3)
            lbl.BackgroundTransparency = 1
            lbl.Text = name; lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = C.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 8; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, cfg, lbl)

            local pct = Instance.new("TextLabel")
            pct.Size = UDim2.fromOffset(44, 13)
            pct.Position = UDim2.new(1, -50, 0, 3)
            pct.BackgroundTransparency = 1
            pct.Font = Enum.Font.Code; pct.TextSize = 9
            pct.TextColor3 = C.white
            pct.TextXAlignment = Enum.TextXAlignment.Right
            pct.Visible = showPct
            pct.ZIndex = 8; pct.Parent = row
            regTheme(pct, "TextColor3", "accent")

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -18, 0, 3)
            track.Position = UDim2.new(0, 9, 0, 21)
            track.BackgroundColor3 = C.bg3
            track.BorderSizePixel = 0; track.ZIndex = 8; track.Parent = row
            regTheme(track, "BackgroundColor3", "bg3")

            local fill = Instance.new("Frame")
            fill.Size = UDim2.fromScale(0, 1)
            fill.BackgroundColor3 = C.white
            fill.BorderSizePixel = 0; fill.ZIndex = 9; fill.Parent = track
            regTheme(fill, "BackgroundColor3", "accent")

            local value = default
            local function redraw(anim)
                local t = math.clamp((value - min) / math.max(max - min, 1), 0, 1)
                if anim then Tween(fill, 0.25, { Size = UDim2.fromScale(t, 1) })
                else fill.Size = UDim2.fromScale(t, 1) end
                pct.Text = math.floor(t*100).."%"
            end
            redraw(false)

            local obj = {}
            function obj:Set(v, anim) value = math.clamp(v, min, max); redraw(anim ~= false) end
            function obj:Get() return value end
            return obj
        end

        function Section:CreateLabel(text, iconCfg)
            if type(text) == "table" then iconCfg = text; text = text.Text or text.Title or text.Desc or "" end
            local ic = type(iconCfg) == "table" and iconCfg or {}
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 14)
            row.BackgroundTransparency = 1
            row.ZIndex = 6; row.Parent = bodyHost

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 1, 0)
            lbl.Position = UDim2.new(0, 2, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = tostring(text)
            lbl.Font = Enum.Font.Code; lbl.TextSize = 9
            lbl.TextColor3 = C.text2
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 7; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text2")
            attachIcon(row, ic, lbl)
        end

        function Section:CreateParagraph(text, iconCfg)
            if type(text) == "table" then iconCfg = text; text = text.Text or text.Title or text.Desc or "" end
            local ic = type(iconCfg) == "table" and iconCfg or {}
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 0)
            row.AutomaticSize = Enum.AutomaticSize.Y
            row.BackgroundColor3 = C.bg2
            row.BackgroundTransparency = 0.3
            row.ZIndex = 6; row.Parent = bodyHost
            corner(row, 2)
            regTheme(row, "BackgroundColor3", "bg2")

            local pad = Instance.new("UIPadding")
            pad.PaddingTop = UDim.new(0, 5); pad.PaddingBottom = UDim.new(0, 5)
            pad.PaddingLeft = UDim.new(0, 7); pad.PaddingRight = UDim.new(0, 7)
            pad.Parent = row

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.BackgroundTransparency = 1
            lbl.Text = tostring(text)
            lbl.Font = Enum.Font.Code; lbl.TextSize = 9
            lbl.TextColor3 = C.text
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 7; lbl.Parent = row
            regTheme(lbl, "TextColor3", "text")
            attachIcon(row, ic, lbl)
        end

        function Section:CreateDivider()
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 6)
            row.BackgroundTransparency = 1
            row.ZIndex = 6; row.Parent = bodyHost
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 0.5, 0)
            line.BackgroundColor3 = C.line
            line.BackgroundTransparency = 0.5
            line.BorderSizePixel = 0; line.ZIndex = 7; line.Parent = row
            regTheme(line, "BackgroundColor3", "line")
        end

        Section.Toggle         = Section.CreateToggle
        Section.Slider         = Section.CreateSlider
        Section.Button         = Section.CreateButton
        Section.Banner         = Section.CreateBanner
        Section.Hero           = Section.CreateHero
        Section.CardGrid       = Section.CreateCardGrid
        Section.Dropdown       = Section.CreateDropdown
        Section.ColorPicker    = Section.CreateColorPicker
        Section.Colorpicker    = Section.CreateColorPicker
        Section.Input          = Section.CreateInput
        Section.Keybind        = Section.CreateKeybind
        Section.ProgressBar    = Section.CreateProgressBar
        Section.Label          = Section.CreateLabel
        Section.Paragraph      = Section.CreateParagraph
        Section.Divider        = Section.CreateDivider

        if type(callback) == "function" then
            pcall(callback, Section)
        end

        table.insert(Tab.Sections, Section)
        return Section
    end

    Tab.Section = Tab.CreateSection

    local autoSection
    local function getAuto()
        if not autoSection then autoSection = Tab:CreateSection({ Name = "" }) end
        return autoSection
    end

    function Tab:CreateToggle(...)      return getAuto():CreateToggle(...) end
    function Tab:CreateSlider(...)      return getAuto():CreateSlider(...) end
    function Tab:CreateButton(...)      return getAuto():CreateButton(...) end
    function Tab:CreateBanner(...)      return getAuto():CreateBanner(...) end
    function Tab:CreateHero(...)        return getAuto():CreateHero(...) end
    function Tab:CreateCardGrid(...)    return getAuto():CreateCardGrid(...) end
    function Tab:CreateDropdown(...)    return getAuto():CreateDropdown(...) end
    function Tab:CreateColorPicker(...) return getAuto():CreateColorPicker(...) end
    function Tab:CreateInput(...)       return getAuto():CreateInput(...) end
    function Tab:CreateKeybind(...)     return getAuto():CreateKeybind(...) end
    function Tab:CreateProgressBar(...) return getAuto():CreateProgressBar(...) end
    function Tab:CreateLabel(...)       return getAuto():CreateLabel(...) end
    function Tab:CreateParagraph(...)   return getAuto():CreateParagraph(...) end
    function Tab:CreateDivider(...)     return getAuto():CreateDivider(...) end

    Tab.Toggle       = Tab.CreateToggle
    Tab.Slider       = Tab.CreateSlider
    Tab.Button       = Tab.CreateButton
    Tab.Banner       = Tab.CreateBanner
    Tab.Hero         = Tab.CreateHero
    Tab.CardGrid     = Tab.CreateCardGrid
    Tab.Dropdown     = Tab.CreateDropdown
    Tab.ColorPicker  = Tab.CreateColorPicker
    Tab.Colorpicker  = Tab.CreateColorPicker
    Tab.Input        = Tab.CreateInput
    Tab.Keybind      = Tab.CreateKeybind
    Tab.ProgressBar  = Tab.CreateProgressBar
    Tab.Label        = Tab.CreateLabel
    Tab.Paragraph    = Tab.CreateParagraph
    Tab.Divider      = Tab.CreateDivider

    function Tab:Destroy()
        if not Tabs[id] then return end
        Tabs[id] = nil
        if TabByName[name] == Tab then TabByName[name] = nil end
        if activeTabId == id then
            activeTabId = nil
            for tid, _ in pairs(Tabs) do selectTab(tid); break end
        end
        pcall(function() btn:Destroy() end)
        pcall(function() content:Destroy() end)
    end
    function Tab:GetName() return name end
    function Tab:SetBackground(src, transparency, size)
        if bgImg then
            if src then bgImg.Image = normalizeImage(src) end
            if transparency ~= nil then bgImg.ImageTransparency = transparency end
            if size then bgImg.Size = UDim2.fromOffset(size, size) end
        end
    end

    TabByName[name] = Tab
    return Tab
end

local function applyTheme(name)
    if THEME_ALIAS[name] then name = THEME_ALIAS[name] end
    local theme = nil
    for _, t in ipairs(THEMES) do if t.name == name then theme = t; break end end
    if not theme then return end
    currentThemeName = name

    C.bg    = hex(theme.colors.bg)
    C.bg2   = hex(theme.colors.bg2)
    C.bg3   = hex(theme.colors.bg3)
    C.line  = hex(theme.colors.line)
    C.line2 = hex(theme.colors.line2)
    C.text  = hex(theme.colors.text)
    C.text2 = hex(theme.colors.text2)
    C.text3 = hex(theme.colors.text3)
    C.white = hex(theme.colors.accent)

    if ToggleBgGrad then
        ToggleBgGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.bg2),
            ColorSequenceKeypoint.new(0.5, C.bg),
            ColorSequenceKeypoint.new(1, C.bg2),
        })
    end
    if ToggleLaserGrad then
        ToggleLaserGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.line2),
            ColorSequenceKeypoint.new(0.5, C.white),
            ColorSequenceKeypoint.new(1, C.line2),
        })
    end

    for i = #themeEls, 1, -1 do
        local e = themeEls[i]
        if not e.el or not e.el.Parent then
            table.remove(themeEls, i)
        else
            local val = C[e.role]
            if e.role == "dynamic_toggle" then
                local ok, res = pcall(e.state)
                if ok then val = res and C.white or C.bg3 end
            elseif e.role == "dynamic_btn" then
                if not e.el:GetAttribute("CustomBg") then val = C.bg2 end
            end
            if val then
                local ok = pcall(function() e.el[e.prop] = val end)
                if not ok then table.remove(themeEls, i) end
            else
                table.remove(themeEls, i)
            end
        end
    end
    for i = #allScanLines, 1, -1 do
        local line = allScanLines[i]
        if not line or not line.Parent then table.remove(allScanLines, i)
        else pcall(function() line.BackgroundColor3 = C.white end) end
    end

    MainGradient.Color = ColorSequence.new(C.bg, C.white)
    for tid, t in pairs(Tabs) do
        t.btn.BackgroundColor3 = (tid == activeTabId) and C.bg3 or C.bg2
        if t.btn:GetAttribute("HasIconLabel") then
            for _, ch in ipairs(t.btn:GetChildren()) do
                if ch:IsA("TextLabel") then ch.TextColor3 = (tid == activeTabId) and C.white or C.text2 end
            end
        else
            t.btn.TextColor3 = (tid == activeTabId) and C.white or C.text2
        end
    end
end

local function closeThemeMenu() ThemeMenu.Visible = false end
local function buildThemeMenu()
    for _, c in ipairs(ThemeMenu:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for i, t in ipairs(THEMES) do
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, THEME_ITEM_H)
        item.BackgroundColor3 = C.bg2
        item.Text = ""; item.BorderSizePixel = 0
        item.AutoButtonColor = false
        item.LayoutOrder = i; item.ZIndex = 91; item.Parent = ThemeMenu
        corner(item, 2)

        local sw = Instance.new("Frame")
        sw.Size = UDim2.new(0, 8, 0, 8)
        sw.Position = UDim2.new(0, 4, 0.5, -4)
        sw.BackgroundColor3 = hex(t.colors.accent)
        sw.BorderSizePixel = 0; sw.ZIndex = 92; sw.Parent = item
        corner(sw, 1)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -18, 1, 0)
        lbl.Position = UDim2.new(0, 16, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = t.name
        lbl.TextColor3 = (t.name == currentThemeName) and C.white or C.text2
        lbl.TextSize = 9; lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 92; lbl.Parent = item

        item.MouseEnter:Connect(function() item.BackgroundColor3 = C.bg3; lbl.TextColor3 = C.white end)
        item.MouseLeave:Connect(function()
            item.BackgroundColor3 = C.bg2
            lbl.TextColor3 = (t.name == currentThemeName) and C.white or C.text2
        end)
        item.MouseButton1Click:Connect(function()
            applyTheme(t.name); buildThemeMenu(); closeThemeMenu()
        end)
    end
    ThemeMenu.CanvasSize = UDim2.new(0, 0, 0, 8 + (#THEMES * THEME_ITEM_H))
end
local function openThemeMenu()
    buildThemeMenu()
    ThemeMenu.Position = UDim2.new(1, -122, 0, 26)
    ThemeMenu.Visible = true
    ThemeMenu.CanvasPosition = Vector2.new(0, 0)
end
ThemeBtn.MouseButton1Click:Connect(function()
    if ThemeMenu.Visible then closeThemeMenu() else openThemeMenu() end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not ThemeMenu.Visible then return end
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local pos = input.Position
    local mAbs, mSize = ThemeMenu.AbsolutePosition, ThemeMenu.AbsoluteSize
    local bAbs, bSize = ThemeBtn.AbsolutePosition, ThemeBtn.AbsoluteSize
    local inMenu = pos.X >= mAbs.X and pos.X <= mAbs.X + mSize.X and pos.Y >= mAbs.Y and pos.Y <= mAbs.Y + mSize.Y
    local inBtn  = pos.X >= bAbs.X and pos.X <= bAbs.X + bSize.X and pos.Y >= bAbs.Y and pos.Y <= bAbs.Y + bSize.Y
    if not inMenu and not inBtn then closeThemeMenu() end
end)

local waterTime = 0
local waterConn = RunService.RenderStepped:Connect(function(dt)
    waterTime = waterTime + dt
    MainGradient.Rotation = (waterTime * 15) % 360
    MainGradient.Offset = Vector2.new(math.sin(waterTime * 0.8) * 0.5 + 0.5, 0)

    local wave1 = (math.sin(waterTime * 1.4) + 1) / 2
    local wave2 = (math.sin(waterTime * 1.4 + math.pi) + 1) / 2
    wave1 = wave1 * wave1 * (3 - 2 * wave1)
    wave2 = wave2 * wave2 * (3 - 2 * wave2)
    local accR, accG, accB = C.white.R, C.white.G, C.white.B
    local g1 = Color3.new(accR*wave1 + (1-wave1)*0.3, accG*wave1 + (1-wave1)*0.3, accB*wave1 + (1-wave1)*0.3)
    local g2 = Color3.new(accR*wave2 + (1-wave2)*0.3, accG*wave2 + (1-wave2)*0.3, accB*wave2 + (1-wave2)*0.3)
    for i = 1, 4 do if cornerFrames[i] then cornerFrames[i].BackgroundColor3 = g1 end end
    for i = 5, 8 do if cornerFrames[i] then cornerFrames[i].BackgroundColor3 = g2 end end

    if ToggleLaserGrad then
        ToggleLaserGrad.Rotation = (waterTime * 150) % 360
    end
    if ToggleBgGrad then
        ToggleBgGrad.Rotation = (waterTime * 20) % 360
    end

    cursor.TextTransparency = (math.sin(waterTime * 4) + 1) / 2 * 0.8
end)

local API = {}
API.__index = API

function API:CreateTab(a, b)
    if type(a) == "string" then return makeTab({ Title = a, Icon = b }) end
    return makeTab(a or {})
end
function API:RemoveTab(nameOrId)
    local tab = TabByName[nameOrId]
    if tab then tab:Destroy() end
end
function API:GetTab(name) return TabByName[name] end
function API:GetTabs()
    local list = {}
    for name, _ in pairs(TabByName) do table.insert(list, name) end
    return list
end
function API:SetTheme(name) if name then applyTheme(name) end end
function API:GetThemes()
    local list = {}
    for _, t in ipairs(THEMES) do table.insert(list, t.name) end
    return list
end
function API:Show() MainFrame.Visible = true; ToggleButton.Visible = false end
function API:Hide() MainFrame.Visible = false; ToggleButton.Visible = true end
function API:SelectTab(id) if Tabs[id] then selectTab(id) end end
function API:SetToggleButtonText(text)
    OpenBtnText.Text = tostring(text or "OPEN UI")
end
function API:Destroy()
    pcall(function() waterConn:Disconnect() end)
    pcall(function() ScreenGui:Destroy() end)
    _G.BANANAUI = nil
end
function API:GetScreenGui() return ScreenGui end
function API:GetMainFrame() return MainFrame end

local Window = {}
Window.__index = Window

function Window:Tab(cfg)
    if type(cfg) == "string" then cfg = { Title = cfg } end
    cfg = cfg or {}
    return makeTab({
        Name = cfg.Name or cfg.Title or "Tab",
        Icon = cfg.Icon,
        Background = cfg.Background or cfg.BackgroundImage,
        BackgroundTransparency = cfg.BackgroundTransparency,
        BackgroundSize = cfg.BackgroundSize,
        BackgroundPadding = cfg.BackgroundPadding,
    })
end
function Window:SelectTab(idOrTab)
    if type(idOrTab) == "table" and idOrTab._id then selectTab(idOrTab._id)
    elseif Tabs[idOrTab] then selectTab(idOrTab) end
end
function Window:RemoveTab(nameOrId)   API:RemoveTab(nameOrId) end
function Window:GetTab(name)          return API:GetTab(name) end
function Window:GetTabs()             return API:GetTabs() end
function Window:SetTheme(name)        API:SetTheme(name) end
function Window:GetThemes()           return API:GetThemes() end
function Window:Show()                API:Show() end
function Window:Hide()                API:Hide() end
function Window:Destroy()             API:Destroy() end
function Window:SetTitle(t)           prompt.Text = tostring(t or "$ banana --ui") end
function Window:SetToggleButtonText(t) API:SetToggleButtonText(t) end
function Window:SetSize(w, h)
    if w then CONFIG.UI_W = w end
    if h then CONFIG.UI_H = h end
    MainFrame.Size = UDim2.new(0, CONFIG.UI_W, 0, CONFIG.UI_H)
end

function Window:Notify(cfg)
    cfg = cfg or {}
    local text = cfg.Content or cfg.Text or cfg.Title or "Notification"
    local duration = cfg.Duration or 3
    local title = cfg.Title

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 240, 0, title and 44 or 34)
    notif.Position = UDim2.new(1, 260, 0, 20)
    notif.BackgroundColor3 = C.bg2
    notif.BorderSizePixel = 0
    notif.ZIndex = 300; notif.Parent = ScreenGui
    corner(notif, 3)
    local st = stroke(notif, C.line, 1, 0.3)
    regTheme(notif, "BackgroundColor3", "bg2")
    regTheme(st, "Color", "line")

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 2, 1, -8)
    accentBar.Position = UDim2.new(0, 0, 0, 4)
    accentBar.BackgroundColor3 = C.white
    accentBar.BorderSizePixel = 0; accentBar.ZIndex = 301; accentBar.Parent = notif
    regTheme(accentBar, "BackgroundColor3", "accent")

    if cfg.Icon then
        local ic = newIcon(notif, cfg.Icon, UDim2.fromOffset(14,14), C.white)
        if ic then ic.Position = UDim2.new(0, 8, 0.5, -7) end
    end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, title and 20 or 1, title and 0 or 0)
    if title then lbl.Position = UDim2.new(0, 10, 0, 6); lbl.Size = UDim2.new(1, -20, 0, 14)
    else lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Size = UDim2.new(1, -20, 1, 0) end
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(title or text)
    lbl.Font = Enum.Font.Code; lbl.TextSize = 10
    lbl.TextColor3 = C.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 301; lbl.Parent = notif
    regTheme(lbl, "TextColor3", "text")

    if title then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -20, 0, 12)
        d.Position = UDim2.new(0, 10, 0, 22)
        d.BackgroundTransparency = 1
        d.Text = tostring(text)
        d.Font = Enum.Font.Code; d.TextSize = 8
        d.TextColor3 = C.text3
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.ZIndex = 301; d.Parent = notif
        regTheme(d, "TextColor3", "text3")
    end

    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -260, 0, 20)
    }):Play()

    task.delay(duration, function()
        if notif and notif.Parent then
            local out = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 260, 0, 20)
            })
            out:Play(); out.Completed:Wait()
            pcall(function() notif:Destroy() end)
        end
    end)
end

function Window:Dialog(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Dialog"
    local content = cfg.Content or cfg.Text or ""
    local buttons = cfg.Buttons or { { Title = "OK", Variant = "Primary" } }

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1,1)
    overlay.BackgroundColor3 = Color3.new(0,0,0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 400
    overlay.Parent = MainFrame

    local modal = Instance.new("Frame")
    modal.Size = UDim2.fromOffset(280, 0)
    modal.AutomaticSize = Enum.AutomaticSize.Y
    modal.Position = UDim2.fromScale(0.5, 0.5)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.BackgroundColor3 = C.bg2
    modal.BorderSizePixel = 0
    modal.ZIndex = 401; modal.Parent = overlay
    corner(modal, 3)
    local ms = stroke(modal, C.line, 1, 0.2)
    regTheme(modal, "BackgroundColor3", "bg2")
    regTheme(ms, "Color", "line")

    local mp = Instance.new("UIPadding")
    mp.PaddingTop = UDim.new(0, 12); mp.PaddingBottom = UDim.new(0, 12)
    mp.PaddingLeft = UDim.new(0, 12); mp.PaddingRight = UDim.new(0, 12)
    mp.Parent = modal

    local ml = Instance.new("UIListLayout")
    ml.SortOrder = Enum.SortOrder.LayoutOrder
    ml.Padding = UDim.new(0, 8)
    ml.Parent = modal

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, 0, 0, 16)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = tostring(title)
    tLbl.Font = Enum.Font.Code; tLbl.TextSize = 12
    tLbl.TextColor3 = C.white
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.ZIndex = 402; tLbl.Parent = modal
    regTheme(tLbl, "TextColor3", "accent")

    local cLbl = Instance.new("TextLabel")
    cLbl.Size = UDim2.new(1, 0, 0, 0)
    cLbl.AutomaticSize = Enum.AutomaticSize.Y
    cLbl.BackgroundTransparency = 1
    cLbl.Text = tostring(content)
    cLbl.Font = Enum.Font.Code; cLbl.TextSize = 10
    cLbl.TextColor3 = C.text2
    cLbl.TextXAlignment = Enum.TextXAlignment.Left
    cLbl.TextWrapped = true
    cLbl.ZIndex = 402; cLbl.Parent = modal
    regTheme(cLbl, "TextColor3", "text2")

    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, 0, 0, 22)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 402; btnRow.Parent = modal
    local brl = Instance.new("UIListLayout")
    brl.FillDirection = Enum.FillDirection.Horizontal
    brl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    brl.Padding = UDim.new(0, 6)
    brl.Parent = btnRow

    for _, bcfg in ipairs(buttons) do
        local bb = Instance.new("TextButton")
        bb.Size = UDim2.fromOffset(70, 22)
        bb.BackgroundColor3 = C.bg3
        bb.Text = bcfg.Title or "OK"
        bb.Font = Enum.Font.Code; bb.TextSize = 10
        bb.TextColor3 = C.text
        bb.BorderSizePixel = 0; bb.AutoButtonColor = false
        bb.ZIndex = 403; bb.Parent = btnRow
        corner(bb, 2)
        local bs = stroke(bb, C.line, 1, 0.3)
        regTheme(bb, "BackgroundColor3", "bg3")
        regTheme(bb, "TextColor3", "text")
        regTheme(bs, "Color", "line")

        bb.MouseEnter:Connect(function() bb.BackgroundColor3 = C.bg2 end)
        bb.MouseLeave:Connect(function() bb.BackgroundColor3 = C.bg3 end)
        bb.MouseButton1Click:Connect(function()
            if type(bcfg.Callback) == "function" then pcall(bcfg.Callback) end
            overlay:Destroy()
        end)
    end
    return overlay
end

function Window:Tag(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Tag"
    local icon = cfg.Icon
    local color = cfg.Color or C.white

    local tag = Instance.new("Frame")
    tag.Size = UDim2.new(0, 0, 0, 18)
    tag.AutomaticSize = Enum.AutomaticSize.X
    tag.BackgroundColor3 = C.bg2
    tag.BorderSizePixel = 0
    tag.ZIndex = 250; tag.Parent = MainFrame
    corner(tag, 9)
    local ts = stroke(tag, color, 1, 0.4)
    regTheme(tag, "BackgroundColor3", "bg2")

    local tp = Instance.new("UIPadding")
    tp.PaddingLeft = UDim.new(0, 8); tp.PaddingRight = UDim.new(0, 8)
    tp.Parent = tag

    if icon then
        local ic = newIcon(tag, icon, UDim2.fromOffset(10,10), color)
        if ic then ic.Position = UDim2.new(0, 6, 0.5, -5) end
    end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(title)
    lbl.Font = Enum.Font.Code; lbl.TextSize = 9
    lbl.TextColor3 = color
    lbl.ZIndex = 251; lbl.Parent = tag
    return tag
end

local function runKeySystem(keyCfg, onSuccess)
    local validKeys = keyCfg.Key or keyCfg.Keys or {}
    if type(validKeys) == "string" then validKeys = { validKeys } end
    local note = keyCfg.Note or "Please enter a valid key"
    local thumb = keyCfg.Thumbnail
    local title = keyCfg.Title or "Key System"
    local saveFile = keyCfg.SaveFile or "BANANA_Key.txt"
    local useSave = keyCfg.Save ~= false

    if useSave and readfile and isfile then
        local ok, saved = pcall(function() return readfile(saveFile) end)
        if ok and saved then
            for _, k in ipairs(validKeys) do
                if saved == tostring(k) then
                    onSuccess(); return
                end
            end
        end
    end

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "BANANA_KeySystem"
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGui.Parent = guiParent

    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.fromScale(1,1)
    backdrop.BackgroundColor3 = Color3.new(0,0,0)
    backdrop.BackgroundTransparency = 0.35
    backdrop.BorderSizePixel = 0
    backdrop.Parent = keyGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(360, 260)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = C.bg
    frame.BorderSizePixel = 0
    frame.Parent = keyGui
    corner(frame, 4)
    local kfStroke = stroke(frame, C.line2, 1)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(C.black, C.white)
    grad.Rotation = 90
    grad.Parent = kfStroke

    local head = Instance.new("Frame")
    head.Size = UDim2.new(1, 0, 0, 28)
    head.BackgroundColor3 = C.bg2
    head.BorderSizePixel = 0
    head.Parent = frame
    corner(head, 4)

    local headLbl = Instance.new("TextLabel")
    headLbl.Size = UDim2.new(1, -20, 1, 0)
    headLbl.Position = UDim2.new(0, 10, 0, 0)
    headLbl.BackgroundTransparency = 1
    headLbl.Text = string.upper(title)
    headLbl.Font = Enum.Font.Code; headLbl.TextSize = 11
    headLbl.TextColor3 = C.white
    headLbl.TextXAlignment = Enum.TextXAlignment.Left
    headLbl.Parent = head

    if thumb then
        local thumbImg = Instance.new("ImageLabel")
        thumbImg.Size = UDim2.fromOffset(100, 100)
        thumbImg.Position = UDim2.new(0.5, -50, 0, 40)
        thumbImg.BackgroundTransparency = 1
        thumbImg.Image = normalizeImage(thumb)
        thumbImg.ScaleType = Enum.ScaleType.Fit
        thumbImg.Parent = frame
    end

    local noteLbl = Instance.new("TextLabel")
    noteLbl.Size = UDim2.new(1, -30, 0, 40)
    noteLbl.Position = UDim2.new(0, 15, 0, thumb and 145 or 50)
    noteLbl.BackgroundTransparency = 1
    noteLbl.Text = tostring(note)
    noteLbl.Font = Enum.Font.Code; noteLbl.TextSize = 10
    noteLbl.TextColor3 = C.text2
    noteLbl.TextWrapped = true
    noteLbl.Parent = frame
    regTheme(noteLbl, "TextColor3", "text2")

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -30, 0, 28)
    inputFrame.Position = UDim2.new(0, 15, 1, -76)
    inputFrame.BackgroundColor3 = C.bg2
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = frame
    corner(inputFrame, 2)
    local ifs = stroke(inputFrame, C.line, 1)
    regTheme(inputFrame, "BackgroundColor3", "bg2")
    regTheme(ifs, "Color", "line")

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -16, 1, 0)
    input.Position = UDim2.new(0, 8, 0, 0)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "Enter key..."
    input.PlaceholderColor3 = C.text3
    input.Text = ""
    input.TextColor3 = C.text
    input.Font = Enum.Font.Code; input.TextSize = 11
    input.ClearTextOnFocus = false
    input.Parent = inputFrame
    regTheme(input, "TextColor3", "text")

    local submit = Instance.new("TextButton")
    submit.Size = UDim2.new(1, -30, 0, 28)
    submit.Position = UDim2.new(0, 15, 1, -40)
    submit.BackgroundColor3 = C.bg3
    submit.Text = "SUBMIT"
    submit.Font = Enum.Font.Code; submit.TextSize = 11
    submit.TextColor3 = C.white
    submit.BorderSizePixel = 0
    submit.AutoButtonColor = false
    submit.Parent = frame
    corner(submit, 2)
    local ss = stroke(submit, C.line2, 1)
    regTheme(submit, "BackgroundColor3", "bg3")
    regTheme(submit, "TextColor3", "accent")
    regTheme(ss, "Color", "line2")

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -30, 0, 14)
    status.Position = UDim2.new(0, 15, 1, -14)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.Font = Enum.Font.Code; status.TextSize = 9
    status.TextColor3 = C.text3
    status.Parent = frame
    regTheme(status, "TextColor3", "text3")

    local function tryKey(k)
        k = tostring(k or "")
        for _, vk in ipairs(validKeys) do
            if k == tostring(vk) then
                if useSave and writefile then
                    pcall(function() writefile(saveFile, k) end)
                end
                submit.Text = "✓ SUCCESS"
                status.Text = "Key accepted!"
                task.wait(0.6)
                keyGui:Destroy()
                onSuccess()
                return true
            end
        end
        return false
    end

    submit.MouseButton1Click:Connect(function()
        if not tryKey(input.Text) then
            status.Text = "Invalid key, try again."
        end
    end)
    input.FocusLost:Connect(function(enter)
        if enter and not tryKey(input.Text) then
            status.Text = "Invalid key, try again."
        end
    end)
end

API.Window = Window

function API:CreateWindow(cfg)
    cfg = cfg or {}

    if cfg.User and cfg.User.Enabled then
        UserInfo.Visible = true
        SearchBar.Visible = false
        pcall(function()
            local content, isReady = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
            if content then userAvatar.Image = content end
        end)
        userName.Text = cfg.User.Name or LocalPlayer.DisplayName or LocalPlayer.Name
    else
        UserInfo.Visible = false
    end

    if cfg.SearchBar or cfg.Search then
        SearchBar.Visible = true
        UserInfo.Visible = false
        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = SearchBox.Text:lower()
            for tid, t in pairs(Tabs) do
                local nm = t.btn:GetAttribute("HasIconLabel") and
                    (function()
                        for _, ch in ipairs(t.btn:GetChildren()) do
                            if ch:IsA("TextLabel") then return ch.Text end
                        end
                        return ""
                    end)() or t.btn.Text
                t.btn.Visible = (q == "" or nm:lower():find(q, 1, true) ~= nil)
            end
        end)
    end

    if cfg.Theme then applyTheme(cfg.Theme) end
    if cfg.Title then prompt.Text = tostring(cfg.Title) end
    if cfg.ToggleText then OpenBtnText.Text = tostring(cfg.ToggleText) end

    if cfg.Size and typeof(cfg.Size) == "UDim2" then
        CONFIG.UI_W = cfg.Size.X.Offset
        CONFIG.UI_H = cfg.Size.Y.Offset
        MainFrame.Size = UDim2.new(0, CONFIG.UI_W, 0, CONFIG.UI_H)
    end

    if cfg.SideBarWidth then
        CONFIG.Sidebar_W = cfg.SideBarWidth
        Sidebar.Size = UDim2.new(0, CONFIG.Sidebar_W, 1, -64)
        local newX = 10 + CONFIG.Sidebar_W + 6
        ContentHost.Position = UDim2.new(0, newX, 0, 64)
        ContentHost.Size = UDim2.new(0, CONFIG.UI_W - newX - 10, 1, -64)
    end

    if cfg.Folder and makefolder and isfolder then
        pcall(function()
            if not isfolder(cfg.Folder) then makefolder(cfg.Folder) end
        end)
    end

    local w = setmetatable({}, Window)
    w._cfg = cfg

    if cfg.KeySystem then
        w._pendingUI = true
        task.spawn(function()
            runKeySystem(cfg.KeySystem, function()
                MainFrame.Visible = true
                ToggleButton.Visible = false
                w._pendingUI = false
            end)
        end)
    else
        MainFrame.Visible = true
        ToggleButton.Visible = false
    end

    return w
end

applyTheme(currentThemeName)

_G.BANANAUI = API
return API
