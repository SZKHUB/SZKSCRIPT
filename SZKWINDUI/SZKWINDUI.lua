local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Lib = { Version = "2.0", Flags = {}, Windows = {} }

Lib.Themes = {
    Dark = {
        Background = Color3.fromRGB(10, 10, 10), Sidebar = Color3.fromRGB(14, 14, 14),
        Element = Color3.fromRGB(22, 22, 22), Hover = Color3.fromRGB(38, 38, 38),
        Stroke = Color3.fromRGB(58, 58, 58), Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(245, 245, 245), SubText = Color3.fromRGB(150, 150, 150),
        OnAccent = Color3.fromRGB(12, 12, 12),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 243), Sidebar = Color3.fromRGB(230, 230, 235),
        Element = Color3.fromRGB(250, 250, 252), Hover = Color3.fromRGB(215, 215, 222),
        Stroke = Color3.fromRGB(190, 190, 200), Accent = Color3.fromRGB(25, 25, 30),
        Text = Color3.fromRGB(20, 20, 24), SubText = Color3.fromRGB(100, 100, 110),
        OnAccent = Color3.fromRGB(245, 245, 245),
    },
    Midnight = {
        Background = Color3.fromRGB(8, 10, 22), Sidebar = Color3.fromRGB(12, 15, 32),
        Element = Color3.fromRGB(18, 22, 44), Hover = Color3.fromRGB(32, 38, 72),
        Stroke = Color3.fromRGB(52, 60, 110), Accent = Color3.fromRGB(120, 150, 255),
        Text = Color3.fromRGB(235, 238, 255), SubText = Color3.fromRGB(135, 145, 185),
        OnAccent = Color3.fromRGB(10, 12, 30),
    },
    Rose = {
        Background = Color3.fromRGB(18, 9, 12), Sidebar = Color3.fromRGB(24, 12, 16),
        Element = Color3.fromRGB(34, 18, 24), Hover = Color3.fromRGB(58, 30, 40),
        Stroke = Color3.fromRGB(96, 50, 66), Accent = Color3.fromRGB(255, 120, 160),
        Text = Color3.fromRGB(255, 238, 242), SubText = Color3.fromRGB(190, 140, 155),
        OnAccent = Color3.fromRGB(30, 8, 16),
    },
}

Lib.Theme = {}
for k, v in pairs(Lib.Themes.Dark) do Lib.Theme[k] = v end
Lib.CurrentTheme = "Dark"
local T = Lib.Theme
local PanelT = 0

Lib.Localization = { Enabled = false, Prefix = "loc:", Language = "en", Translations = {} }
Lib.Font = nil

local ICON_BASE = "https://raw.githubusercontent.com/SZKHUB/SZKSCRIPT/refs/heads/main/"
Lib.IconSets = {
    icons1 = { Url = ICON_BASE .. "NEWICONS1" },
    icons2 = { Url = ICON_BASE .. "NEWICON2" },
    icons3 = { Url = ICON_BASE .. "NEWICON3" },
    icons4 = { Url = ICON_BASE .. "NEWICONS4" },
    icons5 = { Url = ICON_BASE .. "NEWICON5" },
    icons6 = { Url = ICON_BASE .. "NEWICON6" },
}
Lib.IconOrder = { "icons1", "icons2", "icons3", "icons4", "icons5", "icons6" }
local IconCache = {}

local Reg = {}
local Themed = {}
local COLOR_PROPS = {
    BackgroundColor3 = true, TextColor3 = true, Color = true, ImageColor3 = true,
    PlaceholderColor3 = true, ScrollBarImageColor3 = true,
}

local function themeKey(c)
    for k, v in pairs(T) do
        if v == c then return k end
    end
end

local function Unreg(obj)
    for i = #Reg, 1, -1 do
        if Reg[i][1] == obj then table.remove(Reg, i) end
    end
end

local function OnTheme(inst, fn)
    table.insert(Themed, { inst, fn })
end

local function Loc(text)
    text = tostring(text == nil and "" or text)
    local L = Lib.Localization
    if L and L.Enabled and L.Prefix ~= "" and text:sub(1, #L.Prefix) == L.Prefix then
        local key = text:sub(#L.Prefix + 1)
        local tr = L.Translations[L.Language]
        return (tr and tr[key]) or key
    end
    return text
end

local function New(class, props, children)
    local o = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            o[k] = v
            if COLOR_PROPS[k] and typeof(v) == "Color3" then
                local tk = themeKey(v)
                if tk then table.insert(Reg, { o, k, tk }) end
            end
        end
    end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if parent then o.Parent = parent end
    return o
end

local function Corner(r)
    return New("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function Stroke(color, th, trans)
    return New("UIStroke", {
        Color = color or T.Stroke,
        Thickness = th or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Pad(l, t, r, b)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
        PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b),
    })
end

local function List(gap, dir)
    return New("UIListLayout", {
        Padding = UDim.new(0, gap or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = dir or Enum.FillDirection.Vertical,
    })
end

local function Tween(o, t, p)
    TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

local function TweenEx(o, t, p, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
    tw:Play()
    return tw
end

local function FadeOut(root, t)
    local info = TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function go(o)
        local p = {}
        if o:IsA("GuiObject") then
            if o.BackgroundTransparency < 1 then p.BackgroundTransparency = 1 end
            if o:IsA("TextLabel") or o:IsA("TextButton") then p.TextTransparency = 1 end
            if o:IsA("ImageLabel") then p.ImageTransparency = 1 end
        elseif o:IsA("UIStroke") then
            p.Transparency = 1
        end
        if next(p) then TweenService:Create(o, info, p):Play() end
    end
    go(root)
    for _, d in ipairs(root:GetDescendants()) do go(d) end
end

local function Label(parent, text, size, color, font, xalign)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        Text = Loc(text),
        TextSize = size or 14,
        TextColor3 = color or T.Text,
        Font = Lib.Font or font or Enum.Font.GothamMedium,
        TextXAlignment = xalign or Enum.TextXAlignment.Left,
        Parent = parent,
    })
end

local function O(opt)
    if type(opt) ~= "table" then opt = { Title = opt } end
    opt.Title = opt.Title or opt.Name
    return opt
end

local function Bind(signal, fn, owner)
    local c = signal:Connect(fn)
    if owner then
        owner.Destroying:Connect(function() c:Disconnect() end)
    end
    return c
end

local function ScreenPos(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        return Vector2.new(input.Position.X, input.Position.Y + GuiService:GetGuiInset().Y)
    end
    return UIS:GetMouseLocation()
end

local function IsPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

local Fluid = {}

local function FluidStroke(stroke, dim)
    Unreg(stroke)
    stroke.Color = Color3.new(1, 1, 1)
    local seq
    if dim then
        seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(28, 28, 28)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120)),
        })
    else
        seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(40, 40, 40)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
        })
    end
    local g = New("UIGradient", { Color = seq, Parent = stroke })
    table.insert(Fluid, g)
    return g
end

local fluidFrame = 0
RunService.RenderStepped:Connect(function()
    fluidFrame = fluidFrame + 1
    local t = os.clock()
    local rot = (t * 70) % 360
    local off = Vector2.new(math.sin(t * 1.2) * 0.25, 0)
    local sweep = (fluidFrame % 120 == 0)
    for i = #Fluid, 1, -1 do
        local g = Fluid[i]
        if sweep then
            local gui = g:FindFirstAncestorOfClass("ScreenGui")
            if not gui or not gui.Parent then
                table.remove(Fluid, i)
                g = nil
            end
        end
        if g then
            g.Rotation = rot
            g.Offset = off
        end
    end
end)

local BUILTIN_ICONS = {
    x = true, minus = true, grid = true, sliders = true, settings = true, home = true,
    user = true, info = true, search = true, terminal = true, tag = true, check = true,
    chevron = true, lock = true, copy = true,
}

local function loadIconSet(setName)
    local s = Lib.IconSets[setName]
    if not s then return nil end
    if s.Data == nil then
        local ok, data = pcall(function()
            return loadstring(game:HttpGet(s.Url))()
        end)
        s.Data = (ok and type(data) == "table") and data or false
    end
    return s.Data or nil
end

local function toImage(v)
    if type(v) == "number" then return "rbxassetid://" .. v end
    return v
end

local function lookupIcon(setName, key)
    local data = loadIconSet(setName)
    if not data then return nil end
    local icons = data.Icons or data
    local e = icons[key]
    if e == nil then return nil end
    if type(e) ~= "table" then
        return { { Image = toImage(e) } }
    end
    local sheets = data.Spritesheets
    local layers = {}
    local function add(entry)
        local img = sheets and sheets[tostring(entry.Image)] or entry.Image
        table.insert(layers, {
            Image = toImage(img),
            Pos = entry.ImageRectPosition,
            Size = entry.ImageRectSize,
        })
    end
    add(e)
    for _, p in ipairs(e.Parts or {}) do
        local pe = icons[p]
        if type(pe) == "table" then add(pe) end
    end
    return layers
end

local function resolveIcon(name)
    if IconCache[name] ~= nil then return IconCache[name] or nil end
    local layers
    local setName, key = name:match("^([%w_]+):(.+)$")
    if setName and Lib.IconSets[setName] then
        layers = lookupIcon(setName, key)
    else
        for _, sn in ipairs(Lib.IconOrder) do
            layers = lookupIcon(sn, name)
            if layers then break end
        end
    end
    IconCache[name] = layers or false
    return layers
end

function Lib:AddIconSet(name, url, first)
    Lib.IconSets[name] = { Url = url }
    if first then
        table.insert(Lib.IconOrder, 1, name)
    else
        table.insert(Lib.IconOrder, name)
    end
end

function Lib:GetIcons(setName)
    local data = loadIconSet(setName)
    local out = {}
    if data then
        for k in pairs(data.Icons or data) do table.insert(out, k) end
        table.sort(out)
    end
    return out
end

local function Icon(name, parent, size, color)
    color = color or T.Text
    local holder = New("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size),
        Parent = parent,
    })

    if type(name) == "string" and name:find("rbxasset") then
        local img = New("ImageLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
            Image = name, ImageColor3 = color, Parent = holder,
        })
        return holder, function(c) img.ImageColor3 = c end
    end

    if type(name) == "string" and not BUILTIN_ICONS[name] then
        local layers = resolveIcon(name)
        if layers then
            local imgs = {}
            for _, L in ipairs(layers) do
                local img = New("ImageLabel", {
                    BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
                    Image = L.Image, ImageColor3 = color, Parent = holder,
                })
                if L.Pos then
                    img.ImageRectOffset = L.Pos
                    img.ImageRectSize = L.Size
                end
                table.insert(imgs, img)
            end
            return holder, function(c)
                for _, im in ipairs(imgs) do im.ImageColor3 = c end
            end
        end
    end

    local fills, strokes = {}, {}

    local function rect(x, y, w, h, rot, round)
        local f = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(x, y),
            Size = UDim2.fromScale(w, h),
            Rotation = rot or 0,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = holder,
        }, { New("UICorner", { CornerRadius = UDim.new(round or 0, 0) }) })
        table.insert(fills, f)
        return f
    end

    local function ring(x, y, d)
        local f = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(x, y),
            Size = UDim2.fromScale(d, d),
            BackgroundTransparency = 1,
            Parent = holder,
        }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
        local s = New("UIStroke", { Color = color, Thickness = math.max(1.5, size * 0.09), Parent = f })
        table.insert(strokes, s)
        return f
    end

    if name == "x" then
        rect(0.5, 0.5, 0.95, 0.12, 45, 0.5)
        rect(0.5, 0.5, 0.95, 0.12, -45, 0.5)
    elseif name == "minus" then
        rect(0.5, 0.5, 0.8, 0.12, 0, 0.5)
    elseif name == "grid" then
        rect(0.28, 0.28, 0.34, 0.34, 0, 0.22)
        rect(0.72, 0.28, 0.34, 0.34, 0, 0.22)
        rect(0.28, 0.72, 0.34, 0.34, 0, 0.22)
        rect(0.72, 0.72, 0.34, 0.34, 0, 0.22)
    elseif name == "sliders" or name == "settings" then
        rect(0.5, 0.25, 0.84, 0.1, 0, 0.5)
        rect(0.5, 0.5, 0.84, 0.1, 0, 0.5)
        rect(0.5, 0.75, 0.84, 0.1, 0, 0.5)
        rect(0.30, 0.25, 0.26, 0.26, 0, 1)
        rect(0.68, 0.5, 0.26, 0.26, 0, 1)
        rect(0.42, 0.75, 0.26, 0.26, 0, 1)
    elseif name == "home" then
        rect(0.5, 0.36, 0.46, 0.46, 45, 0.08)
        rect(0.5, 0.7, 0.58, 0.44, 0, 0.1)
    elseif name == "user" then
        rect(0.5, 0.3, 0.36, 0.36, 0, 1)
        rect(0.5, 0.78, 0.72, 0.38, 0, 0.5)
    elseif name == "info" then
        ring(0.5, 0.5, 0.86)
        rect(0.5, 0.3, 0.1, 0.1, 0, 1)
        rect(0.5, 0.58, 0.1, 0.3, 0, 0.5)
    elseif name == "search" then
        ring(0.43, 0.43, 0.56)
        rect(0.8, 0.8, 0.3, 0.1, 45, 0.5)
    elseif name == "terminal" then
        rect(0.3, 0.38, 0.34, 0.12, 45, 0.5)
        rect(0.3, 0.62, 0.34, 0.12, -45, 0.5)
        rect(0.72, 0.78, 0.3, 0.12, 0, 0.5)
    elseif name == "tag" then
        rect(0.5, 0.5, 0.6, 0.6, 45, 0.16)
        rect(0.5, 0.3, 0.15, 0.15, 0, 1).BackgroundColor3 = T.Element
    elseif name == "check" then
        rect(0.3, 0.6, 0.34, 0.13, 45, 0.5)
        rect(0.6, 0.5, 0.64, 0.13, -45, 0.5)
    elseif name == "chevron" then
        rect(0.37, 0.5, 0.52, 0.12, 45, 0.5)
        rect(0.63, 0.5, 0.52, 0.12, -45, 0.5)
    elseif name == "lock" then
        ring(0.5, 0.3, 0.5)
        rect(0.5, 0.68, 0.74, 0.5, 0, 0.18)
    elseif name == "copy" then
        rect(0.38, 0.38, 0.5, 0.5, 0, 0.14)
        local front = rect(0.62, 0.62, 0.5, 0.5, 0, 0.14)
        New("UIStroke", { Color = T.Element, Thickness = 2, Parent = front })
    else
        rect(0.5, 0.5, 0.5, 0.5, 0, 0.2)
    end

    return holder, function(c)
        for _, f in ipairs(fills) do f.BackgroundColor3 = c end
        for _, s in ipairs(strokes) do s.Color = c end
    end
end

local function MakeDraggable(handle, target)
    local dragging, startInput, startPos, moved = false, nil, nil, false

    handle.InputBegan:Connect(function(i)
        if IsPress(i) then
            dragging, moved = true, false
            startInput, startPos = i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    Bind(UIS.InputChanged, function(i)
        if dragging and IsMove(i) then
            local d = i.Position - startInput
            if d.Magnitude > 6 then moved = true end
            if moved then
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end
    end, handle)

    return function() return moved end
end

local Tip = {}

local function Tooltip(obj, text)
    if not text or text == "" then return end
    obj.MouseEnter:Connect(function()
        if Tip.frame and Tip.frame.Parent then
            Tip.label.Text = Loc(text)
            Tip.frame.Visible = true
        end
    end)
    obj.MouseLeave:Connect(function()
        if Tip.frame then Tip.frame.Visible = false end
    end)
end

RunService.RenderStepped:Connect(function()
    if Tip.frame and Tip.frame.Parent and Tip.frame.Visible then
        local m = UIS:GetMouseLocation()
        Tip.frame.Position = UDim2.fromOffset(m.X + 14, m.Y + 14)
    end
end)

local function Row(parent, h)
    local r = New("Frame", {
        BackgroundColor3 = T.Element,
        BackgroundTransparency = PanelT,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, h or 40),
        ClipsDescendants = true,
        Parent = parent,
    }, { Corner(8), Stroke(T.Stroke) })
    FluidStroke(r:FindFirstChildOfClass("UIStroke"), true)
    return r
end

local function Finish(row, opt, api, titleLabel)
    local lock
    function api:Lock()
        if lock then return end
        lock = New("Frame", {
            BackgroundColor3 = T.Background, BackgroundTransparency = 0.4, BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1), ZIndex = 20, Active = true, Parent = row,
        }, { Corner(8) })
        local ic = Icon("lock", lock, 12, T.SubText)
        ic.AnchorPoint = Vector2.new(1, 0.5)
        ic.Position = UDim2.new(1, -10, 0, 16)
    end
    function api:Unlock()
        if lock then lock:Destroy() lock = nil end
    end
    function api:SetTitle(t)
        if titleLabel then titleLabel.Text = Loc(t) end
    end
    function api:SetVisible(v) row.Visible = v end
    function api:Destroy() row:Destroy() end
    if opt.Locked then api:Lock() end
    Tooltip(row, opt.Tooltip)
    if opt.Flag then Lib.Flags[opt.Flag] = api end
    return api
end

local function fgFor(c)
    local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
    return lum > 0.55 and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(245, 245, 245)
end

local function Attach(obj, container, isPage)

    function obj:Label(text)
        local row = Row(container, 26)
        row.AutomaticSize = Enum.AutomaticSize.Y
        Pad(12, 5, 12, 5).Parent = row
        local l = Label(row, type(text) == "table" and (text.Title or "") or text, 13, T.SubText)
        l.Size = UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.TextWrapped = true
        l.TextYAlignment = Enum.TextYAlignment.Top
        local api = {}
        function api:Set(t) l.Text = Loc(t) end
        return Finish(row, type(text) == "table" and text or {}, api, l)
    end

    function obj:Paragraph(opt)
        opt = O(opt)
        local row = Row(container, 30)
        row.AutomaticSize = Enum.AutomaticSize.Y
        local inner = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
        }, { Pad(12, 8, 12, 8), List(3) })
        if opt.Image then
            New("ImageLabel", {
                BackgroundColor3 = T.Hover, BorderSizePixel = 0, LayoutOrder = 0,
                Size = UDim2.new(1, 0, 0, opt.ImageHeight or 60), Image = opt.Image,
                ScaleType = Enum.ScaleType.Crop, Parent = inner,
            }, { Corner(8) })
        end
        local t = Label(inner, opt.Title or "", 13, T.Text, Enum.Font.GothamBold)
        t.Size = UDim2.new(1, 0, 0, 0)
        t.AutomaticSize = Enum.AutomaticSize.Y
        t.TextWrapped = true
        t.TextYAlignment = Enum.TextYAlignment.Top
        t.LayoutOrder = 1
        t.Visible = (opt.Title ~= nil and opt.Title ~= "")
        local d = Label(inner, opt.Desc or "", 12, T.SubText, Enum.Font.Gotham)
        d.Size = UDim2.new(1, 0, 0, 0)
        d.AutomaticSize = Enum.AutomaticSize.Y
        d.TextWrapped = true
        d.TextYAlignment = Enum.TextYAlignment.Top
        d.LayoutOrder = 2
        local api = {}
        function api:SetDesc(x) d.Text = Loc(x) end
        function api:Set(x) d.Text = Loc(x) end
        return Finish(row, { Locked = opt.Locked, Tooltip = opt.Tooltip, Flag = opt.Flag }, api, t)
    end

    function obj:Code(opt)
        opt = O(opt)
        local code = opt.Code or ""
        local row = Row(container, 40)
        row.AutomaticSize = Enum.AutomaticSize.Y
        local inner = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = row,
        }, { Pad(10, 8, 10, 8), List(6) })
        local head = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1, Parent = inner,
        })
        local tl = Label(head, opt.Title or "Code", 12, T.SubText, Enum.Font.GothamBold)
        tl.Size = UDim2.new(1, -28, 1, 0)
        local cb = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(22, 20), BackgroundColor3 = T.Hover,
            Text = "", AutoButtonColor = false, Parent = head,
        }, { Corner(6) })
        local ci, setCi = Icon("copy", cb, 11, T.SubText)
        ci.AnchorPoint = Vector2.new(0.5, 0.5)
        ci.Position = UDim2.fromScale(0.5, 0.5)
        local box = New("Frame", {
            BackgroundColor3 = T.Background, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = inner,
        }, { Corner(6), Pad(8, 6, 8, 6) })
        local cl = New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Text = code, TextColor3 = T.Text,
            Font = Enum.Font.Code, TextSize = 11, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            Parent = box,
        })
        cb.MouseButton1Click:Connect(function()
            if setclipboard then pcall(setclipboard, code) end
            setCi(T.Accent)
            task.delay(1, function() setCi(T.SubText) end)
            if opt.Callback then task.spawn(opt.Callback, code) end
        end)
        local api = {}
        function api:SetCode(c) code = c cl.Text = c end
        function api:Get() return code end
        return Finish(row, opt, api, tl)
    end

    function obj:Banner(opt)
        opt = O(opt)
        local H = opt.Height or 90
        local mode = opt.ScaleType or "Fit"
        local row = Row(container, H)

        local back
        if mode == "Fit" then
            local br = opt.BackdropBrightness or 0.4
            back = New("ImageLabel", {
                BackgroundColor3 = T.Hover, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
                Image = opt.Image or "", ScaleType = Enum.ScaleType.Crop,
                ImageColor3 = Color3.new(br, br, br), Parent = row,
            }, { Corner(8) })
        end

        local img = New("ImageLabel", {
            BackgroundTransparency = (mode == "Fit") and 1 or 0,
            BackgroundColor3 = T.Hover, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
            Image = opt.Image or "",
            ScaleType = (mode == "Crop" and Enum.ScaleType.Crop)
                or (mode == "Stretch" and Enum.ScaleType.Stretch)
                or Enum.ScaleType.Fit,
            Parent = row,
        }, { Corner(8) })

        local t1
        if opt.Title then
            New("Frame", {
                Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0, Parent = img,
            }, { Corner(8), New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.15),
                }),
            }) })
            t1 = Label(img, opt.Title, 14, T.Text, Enum.Font.GothamBold)
            t1.Position = UDim2.new(0, 10, 1, -38)
            t1.Size = UDim2.new(1, -20, 0, 18)
            t1.TextTruncate = Enum.TextTruncate.AtEnd
            local t2 = Label(img, opt.Subtitle or "", 11, T.SubText, Enum.Font.Gotham)
            t2.Position = UDim2.new(0, 10, 1, -20)
            t2.Size = UDim2.new(1, -20, 0, 14)
            t2.TextTruncate = Enum.TextTruncate.AtEnd
        end
        local api = {}
        function api:SetImage(id)
            img.Image = id
            if back then back.Image = id end
        end
        return Finish(row, opt, api, t1)
    end
    obj.Image = obj.Banner

    function obj:Logo(opt)
        opt = O(opt)
        local row = Row(container, 52)
        local img = New("ImageLabel", {
            BackgroundColor3 = T.Hover, BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(36, 36),
            Image = opt.Image or "", ScaleType = Enum.ScaleType.Crop, Parent = row,
        }, { Corner(8) })
        local t1 = Label(row, opt.Title or "", 14, T.Text, Enum.Font.GothamBold)
        t1.Position = UDim2.fromOffset(52, 9)
        t1.Size = UDim2.new(1, -60, 0, 18)
        t1.TextTruncate = Enum.TextTruncate.AtEnd
        local t2 = Label(row, opt.Subtitle or "", 11, T.SubText, Enum.Font.Gotham)
        t2.Position = UDim2.fromOffset(52, 27)
        t2.Size = UDim2.new(1, -60, 0, 14)
        t2.TextTruncate = Enum.TextTruncate.AtEnd
        local api = {}
        function api:SetImage(id) img.Image = id end
        return Finish(row, opt, api, t1)
    end

    function obj:Divider()
        local holder = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 9), Parent = container,
        })
        New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke,
            BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = holder,
        })
        local api = {}
        function api:Destroy() holder:Destroy() end
        return api
    end

    function obj:Space(opt)
        local h = type(opt) == "number" and opt or (type(opt) == "table" and opt.Size) or 8
        local f = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, h), Parent = container,
        })
        local api = {}
        function api:Destroy() f:Destroy() end
        return api
    end

    function obj:Tag(opt)
        opt = O(opt)
        local holder = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Parent = container,
        })
        local color = opt.Color
        local chip = New("Frame", {
            Position = UDim2.fromOffset(0, 1), Size = UDim2.fromOffset(0, 22),
            AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = color or T.Element, Parent = holder,
        }, {
            Corner(6), Pad(7, 0, 8, 0),
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
                VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        if not color then
            local st = Stroke(T.Stroke)
            st.Parent = chip
        end
        local ic, setIc
        local function fg() return color and fgFor(color) or T.Text end
        local function buildIcon(name)
            if ic then ic:Destroy() ic = nil end
            if name then
                ic, setIc = Icon(name, chip, 11, color and fgFor(color) or T.Accent)
                ic.LayoutOrder = 1
            end
        end
        buildIcon(opt.Icon)
        local tl = Label(chip, opt.Title or "Tag", 10, fg(), Enum.Font.GothamBold)
        tl.AutomaticSize = Enum.AutomaticSize.X
        tl.Size = UDim2.new(0, 0, 1, 0)
        tl.LayoutOrder = 2
        local api = {}
        function api:SetTitle(t) tl.Text = Loc(t) end
        function api:SetIcon(name) buildIcon(name) end
        function api:SetColor(c)
            color = c
            chip.BackgroundColor3 = c
            tl.TextColor3 = fgFor(c)
            if setIc then setIc(fgFor(c)) end
        end
        function api:Destroy() holder:Destroy() end
        return api
    end

    function obj:Button(opt)
        opt = O(opt)
        local primary = (opt.Variant == "Primary")
        local row = Row(container, 32)
        if primary then row.BackgroundColor3 = T.Accent end
        local btn = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row,
        })
        local fg = primary and T.OnAccent or T.Text
        local l = Label(btn, opt.Title or "Button", 13, fg)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -52, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)
        local ic, setC = Icon(opt.Icon or "chevron", btn, 13, primary and T.OnAccent or T.SubText)
        ic.AnchorPoint = Vector2.new(1, 0.5)
        ic.Position = UDim2.new(1, -12, 0.5, 0)
        if not opt.Icon then ic.Rotation = -90 end

        local base = primary and T.Accent or T.Element
        local over = primary and T.Accent:Lerp(T.Hover, 0.25) or T.Hover
        btn.MouseEnter:Connect(function()
            Tween(row, 0.15, { BackgroundColor3 = over })
            if not primary then setC(T.Accent) end
        end)
        btn.MouseLeave:Connect(function()
            Tween(row, 0.15, { BackgroundColor3 = base })
            if not primary then setC(T.SubText) end
        end)
        btn.MouseButton1Click:Connect(function()
            if opt.Callback then task.spawn(opt.Callback) end
        end)
        local api = {}
        return Finish(row, opt, api, l)
    end

    function obj:Toggle(opt)
        opt = O(opt)
        local state = opt.Value
        if state == nil then state = opt.Default end
        state = state and true or false
        local row = Row(container, 32)
        local btn = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), Parent = row,
        })
        local l = Label(btn, opt.Title or "Toggle", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -70, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)

        local sw = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(34, 18), BackgroundColor3 = T.Hover, Parent = btn,
        }, { Corner(9) })
        local knob = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
            Size = UDim2.fromOffset(12, 12), BackgroundColor3 = T.Text, Parent = sw,
        }, { Corner(6) })

        local api = {}
        local function render(anim)
            local pos = state and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            local col = state and T.Accent or T.Hover
            local kcol = state and T.OnAccent or T.Text
            if anim then
                Tween(knob, 0.18, { Position = pos, BackgroundColor3 = kcol })
                Tween(sw, 0.18, { BackgroundColor3 = col })
            else
                knob.Position = pos
                knob.BackgroundColor3 = kcol
                sw.BackgroundColor3 = col
            end
        end
        function api:Set(v, silent)
            state = v and true or false
            render(true)
            if not silent and opt.Callback then task.spawn(opt.Callback, state) end
        end
        function api:Get() return state end
        btn.MouseButton1Click:Connect(function() api:Set(not state) end)
        render(false)
        OnTheme(row, function() render(false) end)
        return Finish(row, opt, api, l)
    end

    function obj:Slider(opt)
        opt = O(opt)
        local min, max, def
        if type(opt.Value) == "table" then
            min, max, def = opt.Value.Min, opt.Value.Max, opt.Value.Default
        else
            min, max, def = opt.Min, opt.Max, opt.Default or opt.Value
        end
        min, max = min or 0, max or 100
        local inc = opt.Step or opt.Increment or 1
        local value = math.clamp(def or min, min, max)

        local row = Row(container, 44)
        local l = Label(row, opt.Title or "Slider", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -90, 0, 20)
        l.Position = UDim2.fromOffset(12, 4)
        local vl = Label(row, tostring(value), 13, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Right)
        vl.Size = UDim2.fromOffset(70, 20)
        vl.Position = UDim2.new(1, -82, 0, 4)

        local track = New("Frame", {
            Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -24, 0, 5),
            BackgroundColor3 = T.Hover, Parent = row,
        }, { Corner(3) })
        local fill = New("Frame", {
            Size = UDim2.fromScale(0, 1), BackgroundColor3 = T.Accent, Parent = track,
        }, { Corner(3) })
        local knob = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.fromOffset(12, 12), BackgroundColor3 = T.Text, Parent = track,
        }, { Corner(6), Stroke(T.Background, 2) })
        local hit = New("TextButton", {
            BackgroundTransparency = 1, Text = "",
            Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 24), Parent = row,
        })

        local api = {}
        local function set(v, silent)
            v = math.clamp(math.floor(v / inc + 0.5) * inc, min, max)
            v = tonumber(string.format("%.6g", v))
            value = v
            local p = (max == min) and 0 or (v - min) / (max - min)
            fill.Size = UDim2.fromScale(p, 1)
            knob.Position = UDim2.fromScale(p, 0.5)
            vl.Text = tostring(v)
            if not silent and opt.Callback then task.spawn(opt.Callback, v) end
        end
        function api:Set(v, silent) set(v, silent) end
        function api:Get() return value end

        local dragging = false
        local function fromX(x)
            local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            set(min + p * (max - min))
        end
        hit.InputBegan:Connect(function(i)
            if IsPress(i) then
                dragging = true
                fromX(i.Position.X)
            end
        end)
        Bind(UIS.InputEnded, function(i)
            if IsPress(i) then dragging = false end
        end, row)
        Bind(UIS.InputChanged, function(i)
            if dragging and IsMove(i) then fromX(i.Position.X) end
        end, row)
        set(value, true)
        return Finish(row, opt, api, l)
    end

    function obj:Input(opt)
        opt = O(opt)
        local area = (opt.Type == "Textarea")
        local row = Row(container, area and 84 or 32)
        local l = Label(row, opt.Title or "Input", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        local box
        if area then
            l.Size = UDim2.new(1, -24, 0, 22)
            l.Position = UDim2.fromOffset(12, 3)
            box = New("TextBox", {
                Position = UDim2.fromOffset(8, 28), Size = UDim2.new(1, -16, 1, -36),
                BackgroundColor3 = T.Hover, Text = opt.Value or opt.Default or "",
                PlaceholderText = opt.Placeholder or "", PlaceholderColor3 = T.SubText,
                TextColor3 = T.Text, TextSize = 12, Font = Enum.Font.Gotham,
                ClearTextOnFocus = false, MultiLine = true, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
                Parent = row,
            }, { Corner(6), Pad(8, 6, 8, 6) })
        else
            l.Size = UDim2.new(0.5, -12, 1, 0)
            l.Position = UDim2.fromOffset(12, 0)
            box = New("TextBox", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0.5, -16, 0, 22), BackgroundColor3 = T.Hover,
                Text = opt.Value or opt.Default or "", PlaceholderText = opt.Placeholder or "",
                PlaceholderColor3 = T.SubText, TextColor3 = T.Text, TextSize = 12,
                Font = Enum.Font.Gotham, ClearTextOnFocus = false, Parent = row,
            }, { Corner(6), Pad(8, 0, 8, 0) })
        end
        box.FocusLost:Connect(function(enter)
            if opt.Callback then task.spawn(opt.Callback, box.Text, enter) end
        end)
        local api = {}
        function api:Set(t, silent)
            box.Text = tostring(t)
            if not silent and opt.Callback then task.spawn(opt.Callback, box.Text, false) end
        end
        function api:Get() return box.Text end
        return Finish(row, opt, api, l)
    end

    function obj:Dropdown(opt)
        opt = O(opt)
        local options = opt.Values or opt.Options or {}
        local multi = (opt.Multi == true)
        local selected = multi and {} or nil
        local d = opt.Value
        if d == nil then d = opt.Default end
        if multi then
            if type(d) == "table" then
                for _, x in ipairs(d) do selected[x] = true end
            elseif d ~= nil then
                selected[d] = true
            end
        else
            selected = d
        end
        local open = false
        local function listH()
            local n = math.min(#options, 5)
            return n * 26 + math.max(n - 1, 0) * 2
        end
        local LIST_H = listH()

        local row = Row(container, 32)
        local head = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 32), Parent = row,
        })
        local l = Label(head, opt.Title or "Dropdown", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(0.5, -12, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)
        local cur = Label(head, "", 12, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Right)
        cur.Size = UDim2.new(0.5, -40, 1, 0)
        cur.Position = UDim2.new(0.5, 0, 0, 0)
        cur.TextTruncate = Enum.TextTruncate.AtEnd
        local chev = Icon("chevron", head, 13, T.SubText)
        chev.AnchorPoint = Vector2.new(1, 0.5)
        chev.Position = UDim2.new(1, -12, 0.5, 0)

        local list = New("ScrollingFrame", {
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 36), Size = UDim2.new(1, -16, 0, LIST_H),
            ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = row,
        }, { List(2) })

        local api = {}
        local btns = {}

        local function isOn(o)
            if multi then return selected[o] == true end
            return selected == o
        end
        local function text()
            if multi then
                local t = {}
                for _, o in ipairs(options) do
                    if selected[o] then table.insert(t, tostring(o)) end
                end
                return #t > 0 and table.concat(t, ", ") or "None"
            end
            return selected ~= nil and tostring(selected) or "Select"
        end
        local function marks()
            cur.Text = text()
            for o, b in pairs(btns) do
                local on = isOn(o)
                b.BackgroundColor3 = on and T.Accent or T.Hover
                b.BackgroundTransparency = on and 0 or 0.4
                b.TextColor3 = on and T.OnAccent or T.Text
            end
        end
        local function emit()
            if opt.Callback then task.spawn(opt.Callback, api:Get()) end
        end
        local function setOpen(v)
            open = v
            Tween(row, 0.2, { Size = UDim2.new(row.Size.X.Scale, row.Size.X.Offset, 0, open and (32 + 4 + LIST_H + 4) or 32) })
            Tween(chev, 0.2, { Rotation = open and 180 or 0 })
        end

        local function build()
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            btns = {}
            for _, o in ipairs(options) do
                local b = New("TextButton", {
                    BackgroundColor3 = T.Hover, BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, 26), Text = tostring(o), TextColor3 = T.Text,
                    TextSize = 12, Font = Enum.Font.Gotham, AutoButtonColor = false, Parent = list,
                }, { Corner(6) })
                btns[o] = b
                b.MouseEnter:Connect(function()
                    if not isOn(o) then Tween(b, 0.12, { BackgroundTransparency = 0 }) end
                end)
                b.MouseLeave:Connect(function()
                    if not isOn(o) then Tween(b, 0.12, { BackgroundTransparency = 0.4 }) end
                end)
                b.MouseButton1Click:Connect(function()
                    if multi then
                        selected[o] = (not selected[o]) or nil
                        marks()
                        emit()
                    else
                        selected = o
                        marks()
                        setOpen(false)
                        emit()
                    end
                end)
            end
            marks()
        end

        head.MouseButton1Click:Connect(function() setOpen(not open) end)

        function api:Get()
            if multi then
                local t = {}
                for _, o in ipairs(options) do
                    if selected[o] then table.insert(t, o) end
                end
                return t
            end
            return selected
        end
        function api:Set(v, silent)
            if multi then
                selected = {}
                if type(v) == "table" then
                    for _, x in ipairs(v) do selected[x] = true end
                elseif v ~= nil then
                    selected[v] = true
                end
            else
                selected = v
            end
            marks()
            if not silent then emit() end
        end
        function api:Refresh(newOptions)
            options = newOptions
            LIST_H = listH()
            list.Size = UDim2.new(1, -16, 0, LIST_H)
            if open then setOpen(true) end
            build()
        end
        build()
        return Finish(row, opt, api, l)
    end

    function obj:Colorpicker(opt)
        opt = O(opt)
        local color = opt.Default or opt.Value or Color3.fromRGB(255, 255, 255)
        local h, s, v = color:ToHSV()
        local PANEL = 100
        local open = false

        local row = Row(container, 32)
        local head = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 32), Parent = row,
        })
        local l = Label(head, opt.Title or "Color", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -70, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)
        local swatch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(30, 16), BackgroundColor3 = color, Parent = head,
        }, { Corner(5), Stroke(T.Stroke) })

        local panel = New("Frame", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 38),
            Size = UDim2.new(1, -16, 0, PANEL), Parent = row,
        })
        local sv = New("Frame", {
            Size = UDim2.new(1, -26, 1, 0), BackgroundColor3 = Color3.fromHSV(h, 1, 1), Parent = panel,
        }, { Corner(6) })
        New("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = sv,
        }, { Corner(6), New("UIGradient", {
            Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
        }) })
        New("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = sv,
        }, { Corner(6), New("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }),
        }) })
        local svKnob = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(9, 9), ZIndex = 3,
            BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv,
        }, { Corner(5), New("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
        local svHit = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = sv,
        })

        local hue = New("Frame", {
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 18, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = panel,
        }, { Corner(6), New("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
                ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
                ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
                ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
                ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
            }),
        }) })
        local hueKnob = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 4, 0, 4), ZIndex = 3,
            BackgroundColor3 = Color3.new(1, 1, 1), Parent = hue,
        }, { Corner(2), New("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5 }) })
        local hueHit = New("TextButton", {
            BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = hue,
        })

        local api = {}
        local function apply(silent)
            color = Color3.fromHSV(h, s, v)
            sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            swatch.BackgroundColor3 = color
            svKnob.Position = UDim2.fromScale(s, 1 - v)
            hueKnob.Position = UDim2.fromScale(0.5, h)
            if not silent and opt.Callback then task.spawn(opt.Callback, color) end
        end

        local drag
        local function upd(i)
            local p = ScreenPos(i)
            if drag == "sv" then
                s = math.clamp((p.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            elseif drag == "hue" then
                h = math.clamp((p.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
            end
            apply()
        end
        svHit.InputBegan:Connect(function(i)
            if IsPress(i) then drag = "sv" upd(i) end
        end)
        hueHit.InputBegan:Connect(function(i)
            if IsPress(i) then drag = "hue" upd(i) end
        end)
        Bind(UIS.InputChanged, function(i)
            if drag and IsMove(i) then upd(i) end
        end, row)
        Bind(UIS.InputEnded, function(i)
            if IsPress(i) then drag = nil end
        end, row)

        head.MouseButton1Click:Connect(function()
            open = not open
            Tween(row, 0.2, { Size = UDim2.new(row.Size.X.Scale, row.Size.X.Offset, 0, open and (32 + 6 + PANEL + 8) or 32) })
        end)

        function api:Get() return color end
        function api:Set(c, silent)
            if type(c) == "table" and c.R then c = Color3.new(c.R, c.G, c.B) end
            h, s, v = c:ToHSV()
            apply(silent)
        end
        apply(true)
        return Finish(row, opt, api, l)
    end

    function obj:Keybind(opt)
        opt = O(opt)
        local function toKey(k)
            if typeof(k) == "EnumItem" then return k end
            local ok, kc = pcall(function() return Enum.KeyCode[k] end)
            return ok and kc or nil
        end
        local keycode = toKey(opt.Value or opt.Default or "E")
        local listening = false

        local row = Row(container, 32)
        local l = Label(row, opt.Title or "Keybind", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -90, 1, 0)
        l.Position = UDim2.fromOffset(12, 0)
        local kb = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(70, 22), BackgroundColor3 = T.Hover, AutoButtonColor = false,
            Text = keycode and keycode.Name or "None", TextColor3 = T.Text, TextSize = 12,
            Font = Lib.Font or Enum.Font.GothamBold, Parent = row,
        }, { Corner(6), Stroke(T.Stroke) })

        local api = {}
        function api:Get() return keycode end
        function api:Set(k)
            keycode = toKey(k)
            kb.Text = keycode and keycode.Name or "None"
            if opt.OnChange then task.spawn(opt.OnChange, keycode) end
        end
        kb.MouseButton1Click:Connect(function()
            listening = true
            kb.Text = "..."
        end)
        Bind(UIS.InputBegan, function(i, gp)
            if listening then
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    if i.KeyCode == Enum.KeyCode.Escape then
                        kb.Text = keycode and keycode.Name or "None"
                    else
                        api:Set(i.KeyCode)
                    end
                end
            elseif not gp and keycode and i.KeyCode == keycode then
                if opt.Callback then task.spawn(opt.Callback, keycode) end
            end
        end, row)
        return Finish(row, opt, api, l)
    end

    function obj:ProgressBar(opt)
        opt = O(opt)
        local value = math.clamp(opt.Value or opt.Default or 0, 0, 100)
        local row = Row(container, 40)
        local l = Label(row, opt.Title or "Progress", 13)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Size = UDim2.new(1, -90, 0, 20)
        l.Position = UDim2.fromOffset(12, 4)
        local vl = Label(row, "", 13, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Right)
        vl.Size = UDim2.fromOffset(70, 20)
        vl.Position = UDim2.new(1, -82, 0, 4)
        local track = New("Frame", {
            Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -24, 0, 6),
            BackgroundColor3 = T.Hover, Parent = row,
        }, { Corner(3) })
        local fill = New("Frame", {
            Size = UDim2.fromScale(value / 100, 1), BackgroundColor3 = T.Accent, Parent = track,
        }, { Corner(3) })
        vl.Text = math.floor(value + 0.5) .. "%"
        local api = {}
        function api:Set(x)
            value = math.clamp(x, 0, 100)
            Tween(fill, 0.25, { Size = UDim2.fromScale(value / 100, 1) })
            vl.Text = math.floor(value + 0.5) .. "%"
            if opt.Callback then task.spawn(opt.Callback, value) end
        end
        function api:Get() return value end
        return Finish(row, opt, api, l)
    end

    local function stack(kind)
        local horizontal = (kind == "HStack")
        local f = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = container,
        }, {
            New("UIListLayout", {
                FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            }),
        })
        if kind == "Group" then
            f.BackgroundTransparency = 0
            f.BackgroundColor3 = T.Sidebar
            f.BackgroundTransparency = PanelT
            Corner(10).Parent = f
            Stroke(T.Stroke, 1, 0.3).Parent = f
            Pad(6, 6, 6, 6).Parent = f
        end
        if horizontal then
            local function reflow()
                local kids = {}
                for _, c in ipairs(f:GetChildren()) do
                    if c:IsA("GuiObject") then table.insert(kids, c) end
                end
                local n = #kids
                for _, c in ipairs(kids) do
                    c.Size = UDim2.new(1 / n, -(6 * (n - 1)) / n, c.Size.Y.Scale, c.Size.Y.Offset)
                end
            end
            f.ChildAdded:Connect(function() task.defer(reflow) end)
        end
        local s = {}
        Attach(s, f)
        function s:Destroy() f:Destroy() end
        return s
    end
    function obj:HStack() return stack("HStack") end
    function obj:VStack() return stack("VStack") end
    function obj:Group() return stack("Group") end

    obj.AddLabel = obj.Label
    obj.AddButton = obj.Button
    obj.AddToggle = obj.Toggle
    obj.AddSlider = obj.Slider
    obj.AddInput = obj.Input
    obj.AddDropdown = obj.Dropdown
    obj.AddBanner = obj.Banner
    obj.AddLogo = obj.Logo

    if isPage then
        local cols, colL, colR
        local orderPage, orderL, orderR = 0, 0, 0
        local nextSide = "left"

        local function newCols()
            orderPage = orderPage + 1
            cols = New("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = orderPage, Parent = container,
            }, { New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
            }) })
            local function col(o)
                return New("Frame", {
                    BackgroundTransparency = 1, Size = UDim2.new(0.5, -4, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = o, Parent = cols,
                }, { New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
            end
            colL, colR = col(1), col(2)
            orderL, orderR = 0, 0
            nextSide = "left"
        end

        function obj:Section(opt, icon, side)
            if type(opt) ~= "table" then
                if icon == "left" or icon == "right" or icon == "full" then side, icon = icon, nil end
                opt = { Title = opt, Icon = icon, Side = side }
            end
            opt = O(opt)
            side = opt.Side

            local parent, lo
            if side == "full" then
                orderPage = orderPage + 1
                parent, lo = container, orderPage
                cols = nil
            else
                if not cols then newCols() end
                if side ~= "left" and side ~= "right" then
                    side = nextSide
                    nextSide = (side == "left") and "right" or "left"
                end
                if side == "left" then
                    orderL = orderL + 1
                    parent, lo = colL, orderL
                else
                    orderR = orderR + 1
                    parent, lo = colR, orderR
                end
            end

            local card = New("Frame", {
                BackgroundColor3 = T.Sidebar, BackgroundTransparency = PanelT, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true,
                LayoutOrder = lo, Parent = parent,
            }, { Corner(10), Stroke(T.Stroke, 1, 0.3) })
            local inner = New("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, Parent = card,
            }, { List(0) })

            local head = New("TextButton", {
                BackgroundColor3 = T.Element, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
                Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1, Parent = inner,
            }, { Corner(10) })
            New("Frame", {
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = T.Element,
                BorderSizePixel = 0, Parent = head,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke,
                BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 2, Parent = head,
            })
            local hx = 12
            if opt.Icon then
                local ic = Icon(opt.Icon, head, 13, T.Accent)
                ic.AnchorPoint = Vector2.new(0, 0.5)
                ic.Position = UDim2.new(0, 11, 0.5, 0)
                hx = 31
            end
            local ttl = Label(head, string.upper(Loc(opt.Title or "SECTION")), 11, T.Text, Enum.Font.GothamBold)
            ttl.Position = UDim2.fromOffset(hx, 0)
            ttl.Size = UDim2.new(1, -(hx + 28), 1, 0)
            ttl.TextTruncate = Enum.TextTruncate.AtEnd
            local chev = Icon("chevron", head, 11, T.SubText)
            chev.AnchorPoint = Vector2.new(1, 0.5)
            chev.Position = UDim2.new(1, -10, 0.5, 0)

            local body = New("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = inner,
            }, { List(6), Pad(6, 6, 6, 6) })

            local opened = (opt.Opened ~= false)
            local function applyOpen()
                body.Visible = opened
                Tween(chev, 0.2, { Rotation = opened and 0 or -90 })
            end
            applyOpen()
            head.MouseButton1Click:Connect(function()
                opened = not opened
                applyOpen()
            end)

            local sec = {}
            Attach(sec, body)

            local lock
            function sec:Lock()
                if lock then return end
                lock = New("Frame", {
                    BackgroundColor3 = T.Background, BackgroundTransparency = 0.4, BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1), ZIndex = 20, Active = true, Parent = card,
                }, { Corner(10) })
            end
            function sec:Unlock()
                if lock then lock:Destroy() lock = nil end
            end
            function sec:SetTitle(t) ttl.Text = string.upper(Loc(t)) end
            function sec:Open() opened = true applyOpen() end
            function sec:Close() opened = false applyOpen() end
            function sec:Destroy() card:Destroy() end
            if opt.Locked then sec:Lock() end
            return sec
        end
        obj.AddSection = obj.Section
    end
end

function Lib:AddTheme(name, tbl)
    local base = {}
    for k, v in pairs(Lib.Themes.Dark) do base[k] = v end
    for k, v in pairs(tbl) do base[k] = v end
    Lib.Themes[name] = base
end

function Lib:GetThemes()
    local t = {}
    for k in pairs(Lib.Themes) do table.insert(t, k) end
    table.sort(t)
    return t
end

function Lib:GetCurrentTheme() return Lib.CurrentTheme end

function Lib:SetTheme(name)
    local th = type(name) == "table" and name or Lib.Themes[name]
    if not th then return false end
    for k, v in pairs(th) do T[k] = v end
    Lib.CurrentTheme = type(name) == "string" and name or "Custom"
    for i = #Reg, 1, -1 do
        local e = Reg[i]
        if e[1].Parent == nil then
            table.remove(Reg, i)
        else
            pcall(function() e[1][e[2]] = T[e[3]] end)
        end
    end
    for _, e in ipairs(Themed) do
        if e[1].Parent ~= nil then pcall(e[2]) end
    end
    for _, w in ipairs(Lib.Windows) do
        if w._refresh then pcall(w._refresh) end
    end
    return true
end

function Lib:SetFont(font)
    Lib.Font = font
    for _, w in ipairs(Lib.Windows) do
        if w.Gui then
            for _, d in ipairs(w.Gui:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and d.Font ~= Enum.Font.Code then
                    d.Font = font
                end
            end
        end
    end
end

function Lib:SetLocalization(cfg)
    for k, v in pairs(cfg or {}) do Lib.Localization[k] = v end
end

function Lib:Notify(opt)
    if Lib._last then return Lib._last:Notify(opt) end
end

function Lib:Popup(opt)
    if Lib._last then return Lib._last:Popup(opt) end
end

local function encodeValue(v)
    if typeof(v) == "Color3" then return { __t = "Color3", r = v.R, g = v.G, b = v.B } end
    if typeof(v) == "EnumItem" then return { __t = "Key", name = v.Name } end
    return v
end

local function decodeValue(v)
    if type(v) == "table" then
        if v.__t == "Color3" then return Color3.new(v.r, v.g, v.b) end
        if v.__t == "Key" then return v.name end
    end
    return v
end

local function MakeConfigManager(folder)
    local CM = { Folder = folder }
    local function path(n) return folder .. "/" .. n .. ".json" end

    function CM:Save(name)
        if not writefile then return false, "this executor has no file system" end
        pcall(function()
            if makefolder and not (isfolder and isfolder(folder)) then makefolder(folder) end
        end)
        local data = {}
        for flag, api in pairs(Lib.Flags) do
            if api.Get then
                local ok, val = pcall(api.Get, api)
                if ok then data[flag] = encodeValue(val) end
            end
        end
        local ok, err = pcall(function() writefile(path(name), HttpService:JSONEncode(data)) end)
        return ok, err
    end

    function CM:Load(name)
        if not (readfile and isfile) then return false, "this executor has no file system" end
        if not isfile(path(name)) then return false, "config not found" end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path(name))) end)
        if not ok then return false, "invalid config file" end
        for flag, val in pairs(data) do
            local api = Lib.Flags[flag]
            if api and api.Set then pcall(api.Set, api, decodeValue(val)) end
        end
        return true
    end

    function CM:List()
        local out = {}
        if listfiles and isfolder and isfolder(folder) then
            for _, f in ipairs(listfiles(folder)) do
                local n = tostring(f):match("([^/\\]+)%.json$")
                if n then table.insert(out, n) end
            end
        end
        return out
    end

    function CM:Delete(name)
        if delfile and isfile and isfile(path(name)) then
            delfile(path(name))
            return true
        end
        return false
    end

    return CM
end

local function KeyGate(gui, ks)
    local keys = ks.Key
    if type(keys) == "string" then keys = { keys } end
    local file = ks.FileName or "STARZKUI_Key.txt"

    local function valid(k)
        k = (tostring(k or ""):gsub("%s+", ""))
        if k == "" then return false end
        if ks.KeyValidator then
            local ok, res = pcall(ks.KeyValidator, k)
            return ok and res == true
        end
        for _, x in ipairs(keys or {}) do
            if x == k then return true end
        end
        return false
    end

    if ks.SaveKey ~= false and readfile and isfile then
        local ok, saved = pcall(function()
            if isfile(file) then return readfile(file) end
        end)
        if ok and saved and valid(saved) then return end
    end

    local done = false
    local ov = New("Frame", {
        Name = "KeyGate", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35,
        Size = UDim2.fromScale(1, 1), Active = true, Parent = gui,
    })
    local card = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(270, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Background, Parent = ov,
    }, { Corner(12), Stroke(T.Stroke), Pad(14, 14, 14, 14), List(8) })
    FluidStroke(card:FindFirstChildOfClass("UIStroke"), true)

    local t = Label(card, ks.Title or "Key System", 14, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    t.Size = UDim2.new(1, 0, 0, 18)
    t.LayoutOrder = 1
    if ks.Note then
        local n = Label(card, ks.Note, 11, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Center)
        n.Size = UDim2.new(1, 0, 0, 0)
        n.AutomaticSize = Enum.AutomaticSize.Y
        n.TextWrapped = true
        n.LayoutOrder = 2
    end
    local box = New("TextBox", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = T.Element, Text = "",
        PlaceholderText = "Enter your key", PlaceholderColor3 = T.SubText, TextColor3 = T.Text,
        TextSize = 12, Font = Enum.Font.Gotham, ClearTextOnFocus = false, LayoutOrder = 3, Parent = card,
    }, { Corner(8), Stroke(T.Stroke), Pad(10, 0, 10, 0) })
    local status = Label(card, "", 11, Color3.fromRGB(255, 100, 100), Enum.Font.Gotham, Enum.TextXAlignment.Center)
    status.Size = UDim2.new(1, 0, 0, 14)
    status.LayoutOrder = 4

    local bar = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 5, Parent = card,
    }, { New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }) })

    local hasGet = (ks.URL ~= nil) or (ks.GetKey ~= nil)
    local function mk(text, primary, order)
        local b = New("TextButton", {
            Size = hasGet and UDim2.new(0.5, -3, 1, 0) or UDim2.fromScale(1, 1),
            BackgroundColor3 = primary and T.Accent or T.Element, AutoButtonColor = false,
            Text = Loc(text), TextColor3 = primary and T.OnAccent or T.Text, TextSize = 12,
            Font = Lib.Font or Enum.Font.GothamBold, LayoutOrder = order, Parent = bar,
        }, { Corner(8) })
        if not primary then Stroke(T.Stroke).Parent = b end
        return b
    end

    local function submit()
        local k = box.Text
        if valid(k) then
            if ks.SaveKey ~= false and writefile then pcall(writefile, file, (k:gsub("%s+", ""))) end
            done = true
            ov:Destroy()
        else
            status.Text = "Invalid key"
        end
    end
    local sb = mk("Submit", true, 1)
    sb.MouseButton1Click:Connect(submit)
    box.FocusLost:Connect(function(enter) if enter then submit() end end)
    if hasGet then
        local gb = mk("Get Key", false, 2)
        gb.MouseButton1Click:Connect(function()
            if ks.GetKey then
                task.spawn(ks.GetKey)
            elseif ks.URL and setclipboard then
                pcall(setclipboard, ks.URL)
                status.Text = "Link copied to clipboard"
            end
        end)
    end

    repeat task.wait() until done or not ov.Parent
end

function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    if cfg.Theme then Lib:SetTheme(cfg.Theme) end
    local Window = {}
    local tabs, current = {}, nil

    local parentGui = (gethui and gethui()) or CoreGui
    local gui = New("ScreenGui", {
        Name = "STARZKUI", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    if not pcall(function() gui.Parent = parentGui end) then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    Window.Gui = gui

    do
        local tf = New("Frame", {
            BackgroundColor3 = T.Background, Size = UDim2.fromOffset(0, 0),
            AutomaticSize = Enum.AutomaticSize.XY, Visible = false, ZIndex = 500, Parent = gui,
        }, { Corner(6), Stroke(T.Stroke), Pad(7, 4, 7, 4) })
        local tl = Label(tf, "", 11, T.Text, Enum.Font.Gotham)
        tl.AutomaticSize = Enum.AutomaticSize.XY
        tl.Size = UDim2.fromOffset(0, 0)
        Tip.frame, Tip.label = tf, tl
    end

    if cfg.KeySystem then KeyGate(gui, cfg.KeySystem) end

    local BASE = cfg.Scale or 0.75
    local baseSize = cfg.Size or UDim2.fromOffset(520, 340)
    local useT = (cfg.Background ~= nil and cfg.Background ~= "") or cfg.Transparent == true
    local hasBg = cfg.Background ~= nil and cfg.Background ~= ""
    PanelT = useT and 0.25 or 0

    local main = New("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(baseSize.X.Offset * BASE, baseSize.Y.Offset * BASE),
        BackgroundColor3 = T.Background, BackgroundTransparency = (cfg.Transparent and not hasBg) and 0.2 or 0,
        BorderSizePixel = 0, Parent = gui,
    }, { Corner(14), Stroke(T.Stroke) })
    local scale = New("UIScale", { Scale = 1, Parent = main })
    local mainStroke = main:FindFirstChildOfClass("UIStroke")
    mainStroke.Thickness = 1.5
    FluidStroke(mainStroke)

    local blur
    if cfg.Acrylic then
        blur = Instance.new("BlurEffect")
        blur.Size = 14
        blur.Parent = Lighting
    end

    if hasBg then
        local br = cfg.BackgroundBrightness or 0.55
        New("ImageLabel", {
            Name = "Background", ZIndex = 0, BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1), Image = cfg.Background,
            ImageColor3 = Color3.new(br, br, br), ScaleType = Enum.ScaleType.Crop,
            Parent = main,
        }, { Corner(14) })
    end

    local body = New("Frame", {
        Name = "Body", BackgroundTransparency = 1, Size = UDim2.fromScale(1 / BASE, 1 / BASE), Parent = main,
    }, { New("UIScale", { Scale = BASE }) })

    local top = New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = body,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke, BorderSizePixel = 0, Parent = top,
    })

    local logo = New("Frame", {
        Position = UDim2.fromOffset(10, 8), Size = UDim2.fromOffset(24, 24),
        BackgroundColor3 = T.Accent, Parent = top,
    }, { Corner(8) })
    local lg = Icon(cfg.Icon or "grid", logo, 13, T.OnAccent)
    lg.AnchorPoint = Vector2.new(0.5, 0.5)
    lg.Position = UDim2.fromScale(0.5, 0.5)

    local author = cfg.Author or cfg.Subtitle or ""
    local title = Label(top, cfg.Title or "STARZKUI", 13, T.Text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(42, 4)
    title.Size = UDim2.fromOffset(200, 16)
    local sub = Label(top, author, 10, T.SubText, Enum.Font.Gotham)
    sub.Position = UDim2.fromOffset(53, 20)
    sub.Size = UDim2.fromOffset(150, 12)
    if author ~= "" then
        New("Frame", {
            Position = UDim2.fromOffset(43, 23), Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = T.Text, Parent = top,
        }, { Corner(3) })
    end

    local function topButton(iconName, offsetX)
        local b = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, offsetX, 0.5, 0),
            Size = UDim2.fromOffset(22, 22), BackgroundColor3 = T.Element,
            Text = "", AutoButtonColor = false, Parent = top,
        }, { Corner(8) })
        local ic, setC = Icon(iconName, b, 11, T.SubText)
        ic.AnchorPoint = Vector2.new(0.5, 0.5)
        ic.Position = UDim2.fromScale(0.5, 0.5)
        b.MouseEnter:Connect(function() Tween(b, 0.15, { BackgroundColor3 = T.Hover }) setC(T.Text) end)
        b.MouseLeave:Connect(function() Tween(b, 0.15, { BackgroundColor3 = T.Element }) setC(T.SubText) end)
        return b
    end
    local closeBtn = topButton("x", -10)
    local minBtn = topButton("minus", -36)

    local chipHolder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -64, 0.5, 0),
        Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, Parent = top,
    }, { New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
    }) })

    local function chip(iconName, text, order)
        local c = New("Frame", {
            Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = T.Element, LayoutOrder = order, Parent = chipHolder,
        }, {
            Corner(6), Stroke(T.Stroke), Pad(7, 0, 8, 0),
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
                VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        FluidStroke(c:FindFirstChildOfClass("UIStroke"), true)
        local ic = Icon(iconName, c, 11, T.Accent)
        ic.LayoutOrder = 1
        local tl = Label(c, text, 10, T.Text, Enum.Font.GothamBold)
        tl.AutomaticSize = Enum.AutomaticSize.X
        tl.Size = UDim2.new(0, 0, 1, 0)
        tl.LayoutOrder = 2
    end
    if cfg.Version then chip("terminal", cfg.Version, 1) end
    if cfg.Tag then chip("tag", cfg.Tag, 2) end

    MakeDraggable(top, main)

    local side = New("Frame", {
        Position = UDim2.fromOffset(0, 41), Size = UDim2.new(0, 112, 1, -41),
        BackgroundColor3 = T.Sidebar, BackgroundTransparency = useT and 1 or 0, BorderSizePixel = 0, Parent = body,
    }, { New("UICorner", { CornerRadius = UDim.new(0, 14) }) })
    New("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundColor3 = T.Sidebar, BackgroundTransparency = useT and 1 or 0, BorderSizePixel = 0, Parent = side })
    New("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 16, 1, 0), BackgroundColor3 = T.Sidebar, BackgroundTransparency = useT and 1 or 0, BorderSizePixel = 0, Parent = side,
    })

    if useT then
        New("Frame", {
            Position = UDim2.fromOffset(112, 41), Size = UDim2.new(0, 1, 1, -55),
            BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.35, BorderSizePixel = 0, Parent = body,
        })
    end

    local tabList = New("ScrollingFrame", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 1, -50),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = side,
    }, { List(3), Pad(6, 6, 6, 6) })

    local prof = New("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 6, 1, -6),
        Size = UDim2.new(1, -12, 0, 38), BackgroundColor3 = T.Element, Parent = side,
    }, { Corner(10), Stroke(T.Stroke) })
    FluidStroke(prof:FindFirstChildOfClass("UIStroke"), true)
    local av = New("ImageLabel", {
        Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = T.Hover, Parent = prof,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    task.spawn(function()
        local ok, img = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        if ok then av.Image = img end
    end)
    local pn = Label(prof, LocalPlayer.DisplayName, 11, T.Text, Enum.Font.GothamBold)
    pn.Position = UDim2.fromOffset(38, 5)
    pn.Size = UDim2.new(1, -42, 0, 14)
    pn.TextTruncate = Enum.TextTruncate.AtEnd
    local pu = Label(prof, "@" .. LocalPlayer.Name, 10, T.SubText, Enum.Font.Gotham)
    pu.Position = UDim2.fromOffset(38, 19)
    pu.Size = UDim2.new(1, -42, 0, 12)
    pu.TextTruncate = Enum.TextTruncate.AtEnd

    local content = New("Frame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(112, 41),
        Size = UDim2.new(1, -112, 1, -41), ClipsDescendants = true, Parent = body,
    })

    if cfg.Resizable ~= false then
        local grip = New("TextButton", {
            AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -3, 1, -3),
            Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, Text = "", ZIndex = 10, Parent = main,
        })
        New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.6, 0.6), Rotation = -45,
            Size = UDim2.fromOffset(11, 2), BackgroundColor3 = T.SubText, BorderSizePixel = 0, Parent = grip,
        }, { Corner(1) })
        New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.8, 0.8), Rotation = -45,
            Size = UDim2.fromOffset(5, 2), BackgroundColor3 = T.SubText, BorderSizePixel = 0, Parent = grip,
        }, { Corner(1) })
        local resizing, startP, startS, startPos = false, nil, nil, nil
        local MINW, MINH = 320, 220
        grip.InputBegan:Connect(function(i)
            if IsPress(i) then
                resizing = true
                startP = i.Position
                startS = Vector2.new(main.Size.X.Offset, main.Size.Y.Offset)
                startPos = main.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then resizing = false end
                end)
            end
        end)
        Bind(UIS.InputChanged, function(i)
            if resizing and IsMove(i) then
                local d = (i.Position - startP) / scale.Scale
                local w = math.max(MINW, startS.X + d.X)
                local h = math.max(MINH, startS.Y + d.Y)
                main.Size = UDim2.fromOffset(w, h)

                main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + (w - startS.X) / 2,
                    startPos.Y.Scale, startPos.Y.Offset + (h - startS.Y) / 2
                )
            end
        end, grip)
    end

    function Window:Popup(opt)
        opt = O(opt)
        if body:FindFirstChild("PopupOverlay") then return end
        local ov = New("TextButton", {
            Name = "PopupOverlay", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
            Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = body,
        }, { Corner(14) })
        Tween(ov, 0.2, { BackgroundTransparency = 0.4 })

        local card = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0, 214, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.Background, Parent = ov,
        }, { Corner(10), Stroke(T.Stroke), Pad(12, 12, 12, 12), List(6) })
        FluidStroke(card:FindFirstChildOfClass("UIStroke"), true)

        local cs = New("UIScale", { Scale = 0.6, Parent = card })
        TweenEx(cs, 0.35, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local q = Label(card, opt.Title or "Notice", 13, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        q.Size = UDim2.new(1, 0, 0, 0)
        q.AutomaticSize = Enum.AutomaticSize.Y
        q.TextWrapped = true
        q.LayoutOrder = 1
        if opt.Content then
            local qs = Label(card, opt.Content, 11, T.SubText, Enum.Font.Gotham, Enum.TextXAlignment.Center)
            qs.Size = UDim2.new(1, 0, 0, 0)
            qs.AutomaticSize = Enum.AutomaticSize.Y
            qs.TextWrapped = true
            qs.LayoutOrder = 2
        end

        local bar = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 3, Parent = card,
        }, { New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }) })

        local closing = false
        local function close()
            if closing then return end
            closing = true
            TweenEx(cs, 0.18, { Scale = 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(ov, 0.18, { BackgroundTransparency = 1 })
            task.delay(0.18, function()
                if ov.Parent then ov:Destroy() end
            end)
        end

        local buttons = opt.Buttons or { { Title = "OK", Variant = "Primary" } }
        local n = #buttons
        for i, b in ipairs(buttons) do
            local primary = (b.Variant == "Primary")
            local fg = primary and T.OnAccent or T.Text
            local btn = New("TextButton", {
                Size = UDim2.new(1 / n, -(6 * (n - 1)) / n, 1, 0), LayoutOrder = i,
                BackgroundColor3 = primary and T.Accent or T.Element,
                Text = "", AutoButtonColor = false, Parent = bar,
            }, {
                Corner(8),
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),
            })
            if not primary then Stroke(T.Stroke).Parent = btn end
            if b.Icon then
                local ic = Icon(b.Icon, btn, 11, fg)
                ic.LayoutOrder = 1
            end
            local tl = Label(btn, b.Title or "OK", 12, fg, Enum.Font.GothamBold)
            tl.AutomaticSize = Enum.AutomaticSize.X
            tl.Size = UDim2.new(0, 0, 1, 0)
            tl.LayoutOrder = 2
            btn.MouseButton1Click:Connect(function()
                close()
                if b.Callback then task.spawn(b.Callback) end
            end)
        end
        return close
    end
    Window.Dialog = Window.Popup

    local openBtn = New("TextButton", {
        Name = "OpenButton", AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14), Size = UDim2.fromOffset(0, 38),
        AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = T.Background,
        Text = "", AutoButtonColor = false, Visible = false, Parent = gui,
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Pad(15, 0, 17, 0),
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    local obStroke = Stroke(Color3.new(1, 1, 1), 2)
    obStroke.Parent = openBtn
    FluidStroke(obStroke)
    local oi = Icon(cfg.Icon or "grid", openBtn, 18, T.Accent)
    oi.LayoutOrder = 1
    local ot = Label(openBtn, cfg.Title or "STARZKUI", 14, T.Text, Enum.Font.GothamBold)
    ot.AutomaticSize = Enum.AutomaticSize.X
    ot.Size = UDim2.new(0, 0, 1, 0)
    ot.LayoutOrder = 2
    local obScale = New("UIScale", { Scale = 1, Parent = openBtn })
    local wasMoved = MakeDraggable(openBtn, openBtn)

    local visible = true
    local busy = false
    local destroying = false

    local tabsShown = (cfg.Intro == false)
    local function ShowTabs(show)
        tabsShown = show
        for i, t in ipairs(tabs) do
            local delay = math.min(i - 1, 6) * (show and 0.06 or 0.025)
            local target = show and UDim2.new(0, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
            task.delay(delay, function()
                if t.Btn and t.Btn.Parent and tabsShown == show then
                    TweenEx(t.Btn, show and 0.5 or 0.2, { Position = target },
                        show and Enum.EasingStyle.Quint or Enum.EasingStyle.Quad,
                        show and Enum.EasingDirection.Out or Enum.EasingDirection.In)
                end
            end)
        end
    end

    local cover = New("Frame", {
        Name = "Cover", BackgroundColor3 = T.Background, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1), ZIndex = 200, Visible = false, Parent = body,
    }, { Corner(14) })

    local BACK = Enum.EasingStyle.Back

    function Window:Toggle(v)
        if busy or destroying then return end
        if v == nil then v = not visible end
        if v == visible then return end
        visible = v
        busy = true
        if blur then blur.Enabled = v end

        if v then
            TweenEx(obScale, 0.2, { Scale = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.2, function() openBtn.Visible = false end)

            main.Visible = true
            scale.Scale = 0.55
            cover.Visible = true
            cover.BackgroundTransparency = 0
            TweenEx(scale, 0.5, { Scale = 1 }, BACK, Enum.EasingDirection.Out)
            TweenEx(cover, 0.4, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.delay(0.38, function() ShowTabs(true) end)
            task.delay(0.5, function()
                cover.Visible = false
                busy = false
            end)
        else
            ShowTabs(false)
            task.delay(0.22, function()
                cover.Visible = true
                cover.BackgroundTransparency = 1
                TweenEx(cover, 0.25, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                TweenEx(scale, 0.32, { Scale = 0.5 }, BACK, Enum.EasingDirection.In)
                task.delay(0.32, function()
                    main.Visible = false
                    scale.Scale = 1
                    cover.Visible = false
                    obScale.Scale = 0
                    openBtn.Visible = true
                    TweenEx(obScale, 0.45, { Scale = 1 }, BACK, Enum.EasingDirection.Out)
                    busy = false
                end)
            end)
        end
    end

    local keyConn
    function Window:Destroy()
        if destroying then return end
        destroying = true
        busy = true
        if keyConn then keyConn:Disconnect() end
        openBtn.Visible = false

        cover.Visible = true
        cover.BackgroundTransparency = 1
        TweenEx(cover, 0.3, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenEx(main, 0.5, { Rotation = -8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenEx(scale, 0.5, { Scale = 0 }, BACK, Enum.EasingDirection.In)
        task.delay(0.55, function()
            for i = #Reg, 1, -1 do
                if Reg[i][1]:IsDescendantOf(gui) then table.remove(Reg, i) end
            end
            for i = #Lib.Windows, 1, -1 do
                if Lib.Windows[i] == Window then table.remove(Lib.Windows, i) end
            end
            if Lib._last == Window then Lib._last = Lib.Windows[#Lib.Windows] end
            if blur then blur:Destroy() end
            gui:Destroy()
        end)
    end

    openBtn.MouseButton1Click:Connect(function()
        if not wasMoved() then Window:Toggle() end
    end)
    minBtn.MouseButton1Click:Connect(function() Window:Toggle(false) end)
    closeBtn.MouseButton1Click:Connect(function()
        Window:Popup({
            Title = "Close " .. (cfg.Title or "STARZKUI") .. "?",
            Content = "The interface will be deleted",
            Buttons = {
                { Title = "Yes", Icon = "check", Variant = "Primary", Callback = function() Window:Destroy() end },
                { Title = "No", Icon = "x" },
            },
        })
    end)
    if cfg.ToggleKey then
        local tk = cfg.ToggleKey
        if type(tk) == "string" then
            local ok, kc = pcall(function() return Enum.KeyCode[tk] end)
            tk = ok and kc or nil
        end
        if tk then
            keyConn = Bind(UIS.InputBegan, function(i, gp)
                if not gp and i.KeyCode == tk then Window:Toggle() end
            end, gui)
        end
    end

    local notifHolder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10),
        Size = UDim2.fromOffset(180, 200), BackgroundTransparency = 1, Parent = gui,
    }, { New("UIListLayout", {
        Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }) })

    function Window:Notify(opt)
        opt = O(opt)
        local wrap = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Parent = notifHolder,
        })
        local card = New("Frame", {
            Position = UDim2.new(1, 30, 0, 0), Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Background, Parent = wrap,
        }, { Corner(8), Stroke(T.Stroke), Pad(8, 6, 8, 6), List(3) })
        FluidStroke(card:FindFirstChildOfClass("UIStroke"), true)

        local head = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1, Parent = card,
        })
        local hi = Icon(opt.Icon or "info", head, 11, T.Accent)
        hi.AnchorPoint = Vector2.new(0, 0.5)
        hi.Position = UDim2.new(0, 0, 0.5, 0)
        local nt = Label(head, opt.Title or "Notice", 11, T.Text, Enum.Font.GothamBold)
        nt.Position = UDim2.fromOffset(16, 0)
        nt.Size = UDim2.new(1, -16, 1, 0)
        nt.TextTruncate = Enum.TextTruncate.AtEnd

        local nc = Label(card, opt.Content or "", 10, T.SubText, Enum.Font.Gotham)
        nc.Size = UDim2.new(1, 0, 0, 0)
        nc.AutomaticSize = Enum.AutomaticSize.Y
        nc.TextWrapped = true
        nc.TextYAlignment = Enum.TextYAlignment.Top
        nc.LayoutOrder = 2

        local function dismiss()
            if card.Parent then
                Tween(card, 0.3, { Position = UDim2.new(1, 30, 0, 0) })
                task.wait(0.32)
                wrap:Destroy()
            end
        end

        if opt.Buttons and #opt.Buttons > 0 then
            local n = #opt.Buttons
            local bar = New("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 3, Parent = card,
            }, { New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }) })
            for i, b in ipairs(opt.Buttons) do
                local nb = New("TextButton", {
                    Size = UDim2.new(1 / n, -(5 * (n - 1)) / n, 1, 0), LayoutOrder = i,
                    BackgroundColor3 = T.Element, AutoButtonColor = false, Text = Loc(b.Title or "OK"),
                    TextColor3 = T.Text, TextSize = 10, Font = Lib.Font or Enum.Font.GothamBold, Parent = bar,
                }, { Corner(6), Stroke(T.Stroke) })
                nb.MouseButton1Click:Connect(function()
                    if b.Callback then task.spawn(b.Callback) end
                    task.spawn(dismiss)
                end)
            end
        end

        Tween(card, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
        task.delay(opt.Duration or 4, dismiss)
    end

    local function selectTab(tab)
        if current == tab or tab.Locked then return end
        for _, t in ipairs(tabs) do
            local on = (t == tab)
            t.Page.Visible = on
            Tween(t.Btn, 0.18, { BackgroundTransparency = on and 0.82 or 1 })
            Tween(t.Bar, 0.18, { BackgroundTransparency = on and 0 or 1 })
            t.SetIcon(on and T.Accent or T.SubText)
            Tween(t.Name, 0.18, { TextColor3 = on and T.Text or T.SubText })
        end
        current = tab
    end

    function Window:SelectTab(x)
        if type(x) == "number" then x = tabs[x] end
        if x then selectTab(x) end
    end

    Window._refresh = function()
        local c = current
        current = nil
        if c then selectTab(c) end
    end

    function Window:Section(opt)
        opt = O(opt)
        local lbl = Label(tabList, string.upper(Loc(opt.Title or "")), 9, T.SubText, Enum.Font.GothamBold)
        lbl.Size = UDim2.new(1, 0, 0, 18)
        Pad(6, 0, 0, 0).Parent = lbl
        local s = {}
        function s:Tab(o) return Window:Tab(o) end
        function s:Destroy() lbl:Destroy() end
        return s
    end

    function Window:Tab(opt, icon)
        if type(opt) ~= "table" then opt = { Title = opt, Icon = icon } end
        opt = O(opt)
        local tab = {}

        local holder = New("Frame", {
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
            ClipsDescendants = true, Parent = tabList,
        })
        local btn = New("TextButton", {
            BackgroundColor3 = T.Accent, BackgroundTransparency = 1,
            Position = tabsShown and UDim2.new(0, 0, 0, 0) or UDim2.new(-1, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0), Text = "", AutoButtonColor = false, Parent = holder,
        }, { Corner(8) })
        local bar = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(3, 12), BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1, Parent = btn,
        }, { Corner(2) })
        local ic, setIc = Icon(opt.Icon or "grid", btn, 14, T.SubText)
        ic.AnchorPoint = Vector2.new(0, 0.5)
        ic.Position = UDim2.new(0, 10, 0.5, 0)
        local nm = Label(btn, opt.Title or "Tab", 12, T.SubText)
        nm.Position = UDim2.fromOffset(32, 0)
        nm.Size = UDim2.new(1, -36, 1, 0)
        nm.TextTruncate = Enum.TextTruncate.AtEnd

        local page = New("ScrollingFrame", {
            BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
            Size = UDim2.fromScale(1, 1), ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = content,
        }, { List(8), Pad(8, 8, 10, 8) })

        tab.Btn, tab.Bar, tab.Name, tab.Page, tab.SetIcon = btn, bar, nm, page, setIc
        tab.Locked = false
        Attach(tab, page, true)

        function tab:Lock()
            tab.Locked = true
            nm.TextTransparency = 0.5
            Tween(btn, 0.15, { BackgroundTransparency = 1 })
            if current == tab then

                for _, t in ipairs(tabs) do
                    if t ~= tab and not t.Locked then
                        current = nil
                        selectTab(t)
                        break
                    end
                end
            end
        end
        function tab:Unlock()
            tab.Locked = false
            nm.TextTransparency = 0
        end
        function tab:SetTitle(t) nm.Text = Loc(t) end
        function tab:Select() selectTab(tab) end
        function tab:Destroy()
            holder:Destroy()
            page:Destroy()
            for i, t in ipairs(tabs) do
                if t == tab then table.remove(tabs, i) break end
            end
            if current == tab then current = nil end
        end

        btn.MouseButton1Click:Connect(function() selectTab(tab) end)
        btn.MouseEnter:Connect(function()
            if current ~= tab and not tab.Locked then Tween(btn, 0.15, { BackgroundTransparency = 0.92 }) end
        end)
        btn.MouseLeave:Connect(function()
            if current ~= tab then Tween(btn, 0.15, { BackgroundTransparency = 1 }) end
        end)

        table.insert(tabs, tab)
        if opt.Locked then tab:Lock() end
        if #tabs == 1 and not tab.Locked then selectTab(tab) end
        return tab
    end
    Window.AddTab = Window.Tab

    Window.ConfigManager = MakeConfigManager(cfg.ConfigFolder or "STARZKUI")
    Window.Flags = Lib.Flags

    local function PlayIntro()
        busy = true
        local splash = New("Frame", {
            Name = "Splash", BackgroundColor3 = T.Background, Size = UDim2.fromScale(1, 1),
            ZIndex = 100, Active = true, Parent = body,
        }, { Corner(14) })

        local BLOCK, GAP = 20, 4
        local grid = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -26),
            Size = UDim2.fromOffset(BLOCK * 2 + GAP, BLOCK * 2 + GAP),
            BackgroundTransparency = 1, Parent = splash,
        })
        local slots = {
            UDim2.fromOffset(0, 0),
            UDim2.fromOffset(BLOCK + GAP, 0),
            UDim2.fromOffset(BLOCK + GAP, BLOCK + GAP),
            UDim2.fromOffset(0, BLOCK + GAP),
        }
        local blocks, scales = {}, {}
        for i = 1, 4 do
            local sc = New("UIScale", { Scale = 0 })
            blocks[i] = New("Frame", {
                Position = slots[i], Size = UDim2.fromOffset(BLOCK, BLOCK),
                BackgroundColor3 = T.Accent:Lerp(T.Hover, (i - 1) * 0.25),
                BorderSizePixel = 0, Parent = grid,
            }, { Corner(6), sc })
            scales[i] = sc
        end

        local loadLbl = Label(splash, "LOADING", 13, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        loadLbl.Position = UDim2.new(0, 0, 0.5, 8)
        loadLbl.Size = UDim2.new(1, 0, 0, 18)
        loadLbl.TextTransparency = 1

        local pctLbl = Label(splash, "0%", 12, T.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        pctLbl.Position = UDim2.new(0, 0, 0.5, 28)
        pctLbl.Size = UDim2.new(1, 0, 0, 16)
        pctLbl.TextTransparency = 1

        scale.Scale = 0.55
        TweenEx(scale, 0.5, { Scale = 1 }, BACK, Enum.EasingDirection.Out)
        task.wait(0.25)

        for i = 1, 4 do
            task.delay((i - 1) * 0.07, function()
                TweenEx(scales[i], 0.4, { Scale = 1 }, BACK, Enum.EasingDirection.Out)
            end)
        end
        TweenEx(loadLbl, 0.4, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
        TweenEx(pctLbl, 0.4, { TextTransparency = 0 }, Enum.EasingStyle.Quad)
        task.wait(0.35)

        local loading = true
        task.spawn(function()
            local step = 0
            while loading and splash.Parent do
                step = step + 1
                for i, blk in ipairs(blocks) do
                    local slot = slots[((i - 1 + step) % 4) + 1]
                    task.delay((i - 1) * 0.05, function()
                        TweenEx(blk, 0.35, { Position = slot }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
                    end)
                end
                task.wait(0.55)
            end
        end)

        local DURATION = 2.6
        local t0 = os.clock()
        while true do
            local a = math.clamp((os.clock() - t0) / DURATION, 0, 1)
            local e = (a < 0.5) and (2 * a * a) or (1 - ((-2 * a + 2) ^ 2) / 2)
            pctLbl.Text = tostring(math.floor(e * 100 + 0.5)) .. "%"
            if a >= 1 then break end
            task.wait()
        end
        pctLbl.Text = "100%"
        task.wait(0.3)
        loading = false

        FadeOut(splash, 0.4)
        task.wait(0.45)
        splash:Destroy()
        ShowTabs(true)
        busy = false
    end

    if cfg.Intro ~= false then task.spawn(PlayIntro) end

    table.insert(Lib.Windows, Window)
    Lib._last = Window
    return Window
end

return Lib
