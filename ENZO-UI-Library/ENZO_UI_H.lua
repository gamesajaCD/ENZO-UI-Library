--// ENZO UI - Fluent+ (Sunset Power)
--// v1.0.0-foundation
--// Author: ENZO UI (custom build by ChatGPT)

local ENZO = {}
ENZO.__index = ENZO
ENZO.Version = "1.0.0-foundation"

--// Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Stats = game:GetService("Stats")

--// Themes (6)
ENZO.Themes = {
	Aurora = {
		Bg = Color3.fromRGB(8, 12, 24),
		Panel = Color3.fromRGB(15, 21, 38),
		PanelSoft = Color3.fromRGB(22, 30, 52),
		Text = Color3.fromRGB(238, 244, 255),
		Muted = Color3.fromRGB(162, 177, 214),
		Accent1 = Color3.fromRGB(141, 104, 255),
		Accent2 = Color3.fromRGB(35, 201, 255),
		Success = Color3.fromRGB(40, 190, 120),
		Warning = Color3.fromRGB(255, 193, 72),
		Error = Color3.fromRGB(228, 77, 77),
		Info = Color3.fromRGB(97, 170, 255),
		Stroke = Color3.fromRGB(61, 79, 125),
	},
	Sunset = {
		Bg = Color3.fromRGB(11, 11, 18),
		Panel = Color3.fromRGB(24, 21, 30),
		PanelSoft = Color3.fromRGB(35, 31, 44),
		Text = Color3.fromRGB(245, 240, 255),
		Muted = Color3.fromRGB(201, 182, 214),
		Accent1 = Color3.fromRGB(255, 122, 69),
		Accent2 = Color3.fromRGB(255, 61, 94),
		Success = Color3.fromRGB(56, 193, 121),
		Warning = Color3.fromRGB(255, 196, 80),
		Error = Color3.fromRGB(236, 81, 81),
		Info = Color3.fromRGB(86, 164, 255),
		Stroke = Color3.fromRGB(94, 70, 86),
	},
	Ocean = {
		Bg = Color3.fromRGB(7, 16, 24),
		Panel = Color3.fromRGB(13, 26, 40),
		PanelSoft = Color3.fromRGB(21, 38, 57),
		Text = Color3.fromRGB(235, 247, 255),
		Muted = Color3.fromRGB(150, 186, 214),
		Accent1 = Color3.fromRGB(70, 144, 255),
		Accent2 = Color3.fromRGB(36, 219, 255),
		Success = Color3.fromRGB(43, 195, 133),
		Warning = Color3.fromRGB(255, 203, 88),
		Error = Color3.fromRGB(236, 84, 84),
		Info = Color3.fromRGB(84, 178, 255),
		Stroke = Color3.fromRGB(58, 90, 117),
	},
	Forest = {
		Bg = Color3.fromRGB(10, 18, 14),
		Panel = Color3.fromRGB(18, 30, 23),
		PanelSoft = Color3.fromRGB(26, 44, 33),
		Text = Color3.fromRGB(235, 255, 241),
		Muted = Color3.fromRGB(158, 195, 171),
		Accent1 = Color3.fromRGB(78, 182, 108),
		Accent2 = Color3.fromRGB(135, 214, 120),
		Success = Color3.fromRGB(72, 200, 105),
		Warning = Color3.fromRGB(238, 194, 84),
		Error = Color3.fromRGB(222, 88, 88),
		Info = Color3.fromRGB(97, 170, 255),
		Stroke = Color3.fromRGB(65, 97, 72),
	},
	Sakura = {
		Bg = Color3.fromRGB(20, 12, 20),
		Panel = Color3.fromRGB(33, 20, 33),
		PanelSoft = Color3.fromRGB(45, 27, 45),
		Text = Color3.fromRGB(255, 237, 248),
		Muted = Color3.fromRGB(219, 173, 202),
		Accent1 = Color3.fromRGB(255, 105, 176),
		Accent2 = Color3.fromRGB(255, 156, 217),
		Success = Color3.fromRGB(70, 194, 125),
		Warning = Color3.fromRGB(255, 204, 102),
		Error = Color3.fromRGB(233, 88, 108),
		Info = Color3.fromRGB(108, 181, 255),
		Stroke = Color3.fromRGB(109, 74, 96),
	},
	Midnight = {
		Bg = Color3.fromRGB(8, 7, 14),
		Panel = Color3.fromRGB(18, 15, 30),
		PanelSoft = Color3.fromRGB(28, 22, 46),
		Text = Color3.fromRGB(236, 232, 255),
		Muted = Color3.fromRGB(171, 160, 213),
		Accent1 = Color3.fromRGB(122, 92, 255),
		Accent2 = Color3.fromRGB(87, 52, 170),
		Success = Color3.fromRGB(65, 188, 122),
		Warning = Color3.fromRGB(247, 194, 84),
		Error = Color3.fromRGB(235, 83, 95),
		Info = Color3.fromRGB(95, 165, 255),
		Stroke = Color3.fromRGB(72, 61, 108),
	},
}

--// Prototypes
local TabProto = {}
TabProto.__index = TabProto

local SectionProto = {}
SectionProto.__index = SectionProto

--// Utility
local function safecall(fn, ...)
	if type(fn) ~= "function" then
		return false
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[ENZO UI] Error:", err)
	end
	return ok
end

local function clamp(n, a, b)
	return math.max(a, math.min(b, n))
end

local function randomName(len)
	len = len or 12
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local out = {}
	for i = 1, len do
		local r = math.random(1, #chars)
		out[i] = chars:sub(r, r)
	end
	return table.concat(out)
end

local function sanitize(str)
	str = tostring(str or "item"):lower()
	str = str:gsub("[^%w]+", "_")
	str = str:gsub("^_+", ""):gsub("_+$", "")
	if str == "" then str = "item" end
	return str
end

local function resolveKeyCode(v)
	if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then
		return v
	end
	if type(v) == "string" then
		v = v:gsub("Enum.KeyCode.", "")
		return Enum.KeyCode[v] or Enum.KeyCode.RightShift
	end
	return Enum.KeyCode.RightShift
end

local function resolveSize(v)
	if typeof(v) == "UDim2" then
		return v
	elseif typeof(v) == "Vector2" then
		return UDim2.fromOffset(v.X, v.Y)
	elseif type(v) == "table" then
		local w = v.X or v.x or v[1] or 920
		local h = v.Y or v.y or v[2] or 620
		return UDim2.fromOffset(w, h)
	end
	return UDim2.fromOffset(920, 620)
end

local function New(className, props)
	local o = Instance.new(className)
	o.Name = randomName(10)

	if props then
		local parent = props.Parent
		props.Parent = nil
		for k, v in pairs(props) do
			o[k] = v
		end
		props.Parent = parent
		if parent then
			o.Parent = parent
		end
	end

	return o
end

local function pickFunction(...)
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if type(v) == "function" then
			return v
		end
	end
	return nil
end

local makefolderFn = pickFunction(makefolder, syn and syn.makefolder)
local isfolderFn = pickFunction(isfolder, syn and syn.isfolder)
local writefileFn = pickFunction(writefile, syn and syn.writefile)
local readfileFn = pickFunction(readfile, syn and syn.readfile)
local delfileFn = pickFunction(delfile, syn and syn.delfile)
local listfilesFn = pickFunction(listfiles, syn and syn.listfiles)

local function ensureFolder(path)
	if not makefolderFn then return false end
	if isfolderFn and isfolderFn(path) then return true end

	local current = ""
	for part in path:gmatch("[^/\\]+") do
		if current == "" then
			current = part
		else
			current = current .. "/" .. part
		end
		if not isfolderFn or not isfolderFn(current) then
			pcall(makefolderFn, current)
		end
	end
	return true
end

local function basename(path)
	return path:match("([^/\\]+)$") or path
end

local function toHex(c3)
	local r = math.floor(c3.R * 255 + 0.5)
	local g = math.floor(c3.G * 255 + 0.5)
	local b = math.floor(c3.B * 255 + 0.5)
	return string.format("#%02X%02X%02X", r, g, b)
end

local function fromHex(hex)
	hex = tostring(hex or ""):gsub("#", "")
	if #hex ~= 6 then return nil end
	local num = tonumber(hex, 16)
	if not num then return nil end
	local r = bit32.rshift(num, 16) % 256
	local g = bit32.rshift(num, 8) % 256
	local b = num % 256
	return Color3.fromRGB(r, g, b)
end

local function serializeValue(v)
	local t = typeof(v)
	if t == "Color3" then
		return { __type = "Color3", r = v.R, g = v.G, b = v.B }
	elseif t == "EnumItem" then
		return { __type = "EnumItem", enum = tostring(v.EnumType), name = v.Name }
	elseif t == "table" then
		local out = {}
		for k, vv in pairs(v) do
			out[k] = serializeValue(vv)
		end
		return out
	end
	return v
end

local function deserializeValue(v)
	if type(v) == "table" and v.__type == "Color3" then
		return Color3.new(v.r or 1, v.g or 1, v.b or 1)
	elseif type(v) == "table" and v.__type == "EnumItem" then
		if tostring(v.enum):find("KeyCode") then
			return Enum.KeyCode[v.name] or Enum.KeyCode.Unknown
		end
		return v.name
	elseif type(v) == "table" then
		local out = {}
		for k, vv in pairs(v) do
			out[k] = deserializeValue(vv)
		end
		return out
	end
	return v
end

--// ENZO methods
function ENZO:_connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._connections, c)
	return c
end

function ENZO:_safeCall(fn, ...)
	return safecall(fn, ...)
end

function ENZO:_bindTheme(fn)
	table.insert(self._themeBinders, fn)
	safecall(fn, self.Theme)
end

function ENZO:_registerOpacityTarget(inst, baseTransparency)
	table.insert(self._opacityTargets, { Inst = inst, Base = baseTransparency or 0 })
end

function ENZO:_applyOpacity()
	for _, item in ipairs(self._opacityTargets) do
		if item.Inst and item.Inst.Parent then
			local t = clamp(item.Base + (1 - self.Opacity) * 0.65, 0, 1)
			item.Inst.BackgroundTransparency = t
		end
	end
end

function ENZO:SetTheme(themeName)
	local t = ENZO.Themes[themeName]
	if not t then return end
	self.ThemeName = themeName
	self.Theme = t

	for _, fn in ipairs(self._themeBinders) do
		safecall(fn, t)
	end
end

function ENZO:_makeDraggable(handle, target)
	local dragging = false
	local dragStart, startPos

	local function update(inputPos)
		if not dragging then return end
		local delta = inputPos - dragStart
		target.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	self:_connect(handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
		end
	end)

	self:_connect(handle.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	self:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position)
		end
	end)
end

function ENZO:_attachTooltip(target, text)
	if not text or text == "" then return end
	local tip = self._tooltip
	if not tip then return end

	self:_connect(target.MouseEnter, function()
		tip.TextLabel.Text = text
		local size = TextService:GetTextSize(text, 14, Enum.Font.GothamMedium, Vector2.new(300, 999))
		tip.Size = UDim2.fromOffset(size.X + 18, size.Y + 14)
		tip.Visible = true
	end)

	self:_connect(target.MouseLeave, function()
		tip.Visible = false
	end)
end

function ENZO:_createToast(data)
	local title = data.Title or "Notification"
	local content = data.Content or ""
	local ntype = (data.Type or "Info"):lower()
	local duration = tonumber(data.Duration) or 4

	local map = {
		info = { Color = self.Theme.Info, Icon = "ℹ️" },
		success = { Color = self.Theme.Success, Icon = "✅" },
		warning = { Color = self.Theme.Warning, Icon = "⚠️" },
		error = { Color = self.Theme.Error, Icon = "❌" },
	}
	local cfg = map[ntype] or map.info

	local card = New("Frame", {
		Parent = self.NotifHolder,
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
	})
	New("UICorner", { Parent = card, CornerRadius = UDim.new(0, 12) })
	New("UIStroke", { Parent = card, Color = self.Theme.Stroke, Transparency = 0.15, Thickness = 1 })

	local head = New("Frame", {
		Parent = card,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.fromOffset(4, 4),
	})

	local icon = New("TextLabel", {
		Parent = head,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(26, 24),
		Position = UDim2.fromOffset(6, 4),
		Text = cfg.Icon,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255,255,255),
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local titleLbl = New("TextLabel", {
		Parent = head,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -66, 0, 20),
		Position = UDim2.fromOffset(34, 2),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = self.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local contentLbl = New("TextLabel", {
		Parent = head,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -66, 0, 28),
		Position = UDim2.fromOffset(34, 24),
		TextWrapped = true,
		Text = content,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = self.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	local closeBtn = New("TextButton", {
		Parent = head,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -24, 0, 3),
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = self.Theme.Muted,
	})

	local bar = New("Frame", {
		Parent = card,
		Size = UDim2.new(1, 0, 0, 3),
		Position = UDim2.new(0, 0, 1, -3),
		BorderSizePixel = 0,
		BackgroundColor3 = cfg.Color,
	})

	local removed = false
	local function remove()
		if removed then return end
		removed = true
		local tw = TweenService:Create(card, TweenInfo.new(0.2), { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) })
		tw:Play()
		task.delay(0.22, function()
			if card and card.Parent then card:Destroy() end
		end)
	end

	self:_connect(closeBtn.MouseButton1Click, remove)

	local t = TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) })
	t:Play()
	task.delay(duration, remove)
end

function ENZO:Notify(a, b, c, d)
	if type(a) == "table" then
		self:_createToast(a)
	else
		self:_createToast({
			Title = a,
			Content = b,
			Type = c,
			Duration = d
		})
	end
end

function ENZO:SetBlur(state)
	self.BlurEnabled = state and true or false

	if self.BlurEnabled then
		if not self._blur then
			local blur = Instance.new("BlurEffect")
			blur.Name = "ENZO_Blur_" .. randomName(6)
			blur.Size = 20
			blur.Parent = Lighting
			self._blur = blur
		end
	else
		if self._blur then
			self._blur:Destroy()
			self._blur = nil
		end
	end
end

function ENZO:Toggle()
	self.Visible = not self.Visible
	self.Main.Visible = self.Visible
end

function ENZO:Minimize()
	if self.Minimized then return end
	self.Minimized = true
	self._oldSize = self.Main.Size
	self.Body.Visible = false
	self.Main.Size = UDim2.new(self.Main.Size.X.Scale, self.Main.Size.X.Offset, 0, 58)
end

function ENZO:Restore()
	if not self.Minimized then return end
	self.Minimized = false
	self.Body.Visible = true
	self.Main.Size = self._oldSize or self.Main.Size
end

function ENZO:Destroy()
	for _, c in ipairs(self._connections) do
		pcall(function() c:Disconnect() end)
	end
	self._connections = {}

	if self._blur then
		self._blur:Destroy()
		self._blur = nil
	end

	if self.Gui then
		self.Gui:Destroy()
	end

	if self._watermark then
		self._watermark:Destroy()
	end

	_G.__ENZO_WINDOW = nil
end

function ENZO:_registerElement(meta)
	self.Registry[meta.ID] = meta
	table.insert(self.Elements, meta)
end

function ENZO:_makeID(tabTitle, sectionTitle, title)
	self._idCount += 1
	return sanitize(tabTitle .. "_" .. sectionTitle .. "_" .. title .. "_" .. tostring(self._idCount))
end

function ENZO:_applySearch(query)
	query = string.lower(query or "")
	if not self.ActiveTab then return end

	for _, section in ipairs(self.ActiveTab.Sections) do
		local anyVisible = false
		for _, elem in ipairs(section.Elements) do
			local hit = (query == "") or (string.find(elem.Search, query, 1, true) ~= nil)
			elem.Root.Visible = hit
			if hit then anyVisible = true end
		end
		section.Frame.Visible = anyVisible
	end
end

function ENZO:_updateTabVisual()
	for _, tab in ipairs(self.Tabs) do
		local active = (tab == self.ActiveTab)
		tab.Button.BackgroundTransparency = active and 0.05 or 0.25
		tab.Button.TextColor3 = active and self.Theme.Text or self.Theme.Muted
		tab.Page.Visible = active
	end
	self:_applySearch(self.SearchBox and self.SearchBox.Text or "")
end

function ENZO:_setActiveTab(tab)
	self.ActiveTab = tab
	self:_updateTabVisual()
end

function ENZO:AddTab(opts)
	opts = opts or {}
	local title = opts.Title or "Tab"
	local icon = opts.Icon or "📄"

	local btn = New("TextButton", {
		Parent = self.TabList,
		Size = UDim2.new(1, -10, 0, 36),
		BackgroundColor3 = self.Theme.PanelSoft,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Text = icon .. "  " .. title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = self.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
	})
	New("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 10) })
	New("UIPadding", { Parent = btn, PaddingLeft = UDim.new(0, 10) })

	local badge = New("TextLabel", {
		Parent = btn,
		BackgroundColor3 = self.Theme.Accent2,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(1, -24, 0.5, -9),
		Text = "",
		Visible = false,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Color3.new(1,1,1),
	})
	New("UICorner", { Parent = badge, CornerRadius = UDim.new(1, 0) })

	local page = New("ScrollingFrame", {
		Parent = self.PageHolder,
		Size = UDim2.new(1, -12, 1, -12),
		Position = UDim2.fromOffset(6, 6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0,0),
		ScrollBarThickness = 6,
		Visible = false,
	})

	local content = New("Frame", {
		Parent = page,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -8, 0, 0),
		Position = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local cols = New("Frame", {
		Parent = content,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local left = New("Frame", {
		Parent = cols,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -6, 0, 0),
		Position = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	local right = New("Frame", {
		Parent = cols,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -6, 0, 0),
		Position = UDim2.new(0.5, 6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	local ll = New("UIListLayout", { Parent = left, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
	local rl = New("UIListLayout", { Parent = right, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })

	local tab = setmetatable({
		Window = self,
		Title = title,
		Icon = icon,
		Button = btn,
		Badge = badge,
		Page = page,
		Left = left,
		Right = right,
		LeftLayout = ll,
		RightLayout = rl,
		Sections = {},
	}, TabProto)

	local function updateCanvas()
		local h = math.max(ll.AbsoluteContentSize.Y, rl.AbsoluteContentSize.Y) + 18
		page.CanvasSize = UDim2.fromOffset(0, h)
	end
	self:_connect(ll:GetPropertyChangedSignal("AbsoluteContentSize"), updateCanvas)
	self:_connect(rl:GetPropertyChangedSignal("AbsoluteContentSize"), updateCanvas)

	self:_connect(btn.MouseButton1Click, function()
		self:_setActiveTab(tab)
	end)

	self:_bindTheme(function(theme)
		btn.BackgroundColor3 = theme.PanelSoft
		badge.BackgroundColor3 = theme.Accent2
	end)

	table.insert(self.Tabs, tab)
	if not self.ActiveTab then
		self:_setActiveTab(tab)
	end

	return tab
end

function TabProto:SetBadge(value)
	value = tonumber(value) or 0
	if value <= 0 then
		self.Badge.Visible = false
		self.Badge.Text = ""
	else
		self.Badge.Visible = true
		self.Badge.Text = tostring(value)
	end
end

function TabProto:AddSection(opts)
	opts = opts or {}
	local title = opts.Title or "Section"
	local side = tostring(opts.Side or "Left"):lower()
	local icon = opts.Icon or "📦"

	local parentColumn = self.Left
	local useRight = (side == "right")
	if useRight and not UserInputService.TouchEnabled and (self.Window.Main.AbsoluteSize.X > 650) then
		parentColumn = self.Right
	end

	local frame = New("Frame", {
		Parent = parentColumn,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		BackgroundColor3 = self.Window.Theme.Panel,
	})
	New("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 12) })
	New("UIStroke", { Parent = frame, Color = self.Window.Theme.Stroke, Transparency = 0.25, Thickness = 1 })

	local header = New("TextLabel", {
		Parent = frame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.fromOffset(8, 6),
		Text = icon .. "  " .. title,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local line = New("Frame", {
		Parent = frame,
		Size = UDim2.new(1, -16, 0, 1),
		Position = UDim2.fromOffset(8, 36),
		BorderSizePixel = 0,
		BackgroundColor3 = self.Window.Theme.Stroke,
		BackgroundTransparency = 0.3,
	})

	local body = New("Frame", {
		Parent = frame,
		Position = UDim2.fromOffset(8, 44),
		Size = UDim2.new(1, -16, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	})

	New("UIListLayout", {
		Parent = body,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	New("UIPadding", {
		Parent = frame,
		PaddingBottom = UDim.new(0, 8)
	})

	local section = setmetatable({
		Window = self.Window,
		Tab = self,
		Title = title,
		Side = side,
		Frame = frame,
		Body = body,
		Elements = {},
	}, SectionProto)

	self.Window:_bindTheme(function(theme)
		frame.BackgroundColor3 = theme.Panel
		header.TextColor3 = theme.Text
		line.BackgroundColor3 = theme.Stroke
	end)

	table.insert(self.Sections, section)
	return section
end

function SectionProto:_addElementRoot()
	local r = New("Frame", {
		Parent = self.Body,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	})
	return r
end

function SectionProto:_register(id, root, title, getFn, setFn, extraSearch)
	local search = string.lower((title or "") .. " " .. (extraSearch or ""))
	local meta = {
		ID = id,
		Root = root,
		Search = search,
		Get = getFn,
		Set = setFn,
		Section = self,
		Tab = self.Tab,
	}
	self.Window:_registerElement(meta)
	table.insert(self.Elements, meta)
	return meta
end

function SectionProto:AddLabel(opts)
	if type(opts) == "string" then opts = { Text = opts } end
	opts = opts or {}
	local text = opts.Text or opts.Title or "Label"

	local root = self:_addElementRoot()
	local lbl = New("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Text = text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
	})

	self.Window:_bindTheme(function(theme)
		lbl.TextColor3 = theme.Text
	end)

	local id = self.Window:_makeID(self.Tab.Title, self.Title, text)
	local obj = {}
	function obj:Set(v) lbl.Text = tostring(v) end
	function obj:Get() return lbl.Text end

	self:_register(id, root, text, obj.Get, function(v) obj:Set(v) end, opts.Description or "")
	return obj
end

function SectionProto:AddDivider(opts)
	opts = opts or {}
	local text = opts.Text or opts.Title or ""

	local root = self:_addElementRoot()
	root.Size = UDim2.new(1,0,0,22)
	root.AutomaticSize = Enum.AutomaticSize.None

	local line = New("Frame", {
		Parent = root,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0.5, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = self.Window.Theme.Stroke,
		BackgroundTransparency = 0.3,
	})

	local txt
	if text ~= "" then
		txt = New("TextLabel", {
			Parent = root,
			BackgroundColor3 = self.Window.Theme.Panel,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(180, 20),
			Position = UDim2.fromOffset(8, 1),
			Text = "  " .. text .. "  ",
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = self.Window.Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end

	self.Window:_bindTheme(function(theme)
		line.BackgroundColor3 = theme.Stroke
		if txt then
			txt.BackgroundColor3 = theme.Panel
			txt.TextColor3 = theme.Muted
		end
	end)

	local id = self.Window:_makeID(self.Tab.Title, self.Title, "divider_" .. text)
	local obj = {}
	function obj:Get() return text end
	function obj:Set(v)
		text = tostring(v or "")
		if txt then txt.Text = "  " .. text .. "  " end
	end
	self:_register(id, root, "divider " .. text, obj.Get, obj.Set)
	return obj
end

function SectionProto:AddToggle(opts)
	opts = opts or {}
	local title = opts.Title or "Toggle"
	local desc = opts.Description or ""
	local value = opts.Default or false
	local callback = opts.Callback
	local tooltip = opts.Tooltip

	local root = self:_addElementRoot()
	local main = New("Frame", {
		Parent = root,
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
	})

	local titleLbl = New("TextLabel", {
		Parent = main,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -70, 0, 20),
		Position = UDim2.fromOffset(0, 0),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local descLbl
	if desc ~= "" then
		descLbl = New("TextLabel", {
			Parent = main,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -70, 0, 22),
			Position = UDim2.fromOffset(0, 22),
			Text = desc,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = self.Window.Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end

	local sw = New("TextButton", {
		Parent = main,
		Size = UDim2.fromOffset(46, 24),
		Position = UDim2.new(1, -50, 0, 10),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0,
		Text = "",
	})
	New("UICorner", { Parent = sw, CornerRadius = UDim.new(1, 0) })

	local knob = New("Frame", {
		Parent = sw,
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0,
	})
	New("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

	local function render()
		local tw1 = TweenService:Create(sw, TweenInfo.new(0.18), {
			BackgroundColor3 = value and self.Window.Theme.Accent1 or self.Window.Theme.PanelSoft
		})
		local tw2 = TweenService:Create(knob, TweenInfo.new(0.18), {
			Position = value and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2)
		})
		tw1:Play(); tw2:Play()
	end

	local function set(v, silent)
		value = v and true or false
		render()
		if not silent then
			self.Window:_safeCall(callback, value)
		end
	end

	self.Window:_connect(sw.MouseButton1Click, function()
		set(not value, false)
	end)

	render()
	self.Window:_attachTooltip(sw, tooltip)

	self.Window:_bindTheme(function(theme)
		titleLbl.TextColor3 = theme.Text
		if descLbl then descLbl.TextColor3 = theme.Muted end
		if not value then sw.BackgroundColor3 = theme.PanelSoft end
	end)

	local id = opts.ID or self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Set(v) set(v, false) end
	function obj:Get() return value end
	function obj:Toggle() set(not value, false) end

	self:_register(id, root, title, obj.Get, function(v, silent) set(v, silent) end, desc)
	return obj
end

function SectionProto:AddSlider(opts)
	opts = opts or {}
	local title = opts.Title or "Slider"
	local desc = opts.Description or ""
	local min = tonumber(opts.Min) or 0
	local max = tonumber(opts.Max) or 100
	local value = tonumber(opts.Default) or min
	local suffix = opts.Suffix or ""
	local allowInput = opts.AllowInput and true or false
	local callback = opts.Callback
	local tooltip = opts.Tooltip

	value = clamp(value, min, max)

	local root = self:_addElementRoot()
	local main = New("Frame", {
		Parent = root,
		Size = UDim2.new(1,0,0, allowInput and 74 or 58),
		BackgroundTransparency = 1,
	})

	local titleLbl = New("TextLabel", {
		Parent = main,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -90, 0, 20),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local valueLbl = New("TextLabel", {
		Parent = main,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(84,20),
		Position = UDim2.new(1,-84,0,0),
		Text = tostring(value) .. suffix,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = self.Window.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Right
	})

	local descLbl
	if desc ~= "" then
		descLbl = New("TextLabel", {
			Parent = main,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,16),
			Position = UDim2.fromOffset(0,18),
			Text = desc,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = self.Window.Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	local barY = (desc ~= "" and 38 or 24)
	local bar = New("Frame", {
		Parent = main,
		Size = UDim2.new(1, allowInput and -74 or 0, 0, 8),
		Position = UDim2.fromOffset(0, barY),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = bar, CornerRadius = UDim.new(1,0) })

	local fill = New("Frame", {
		Parent = bar,
		Size = UDim2.new(0,0,1,0),
		BackgroundColor3 = self.Window.Theme.Accent1,
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = fill, CornerRadius = UDim.new(1,0) })

	local inputBox
	if allowInput then
		inputBox = New("TextBox", {
			Parent = main,
			Size = UDim2.fromOffset(66, 24),
			Position = UDim2.new(1,-66,0,barY-8),
			BackgroundColor3 = self.Window.Theme.PanelSoft,
			TextColor3 = self.Window.Theme.Text,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			Text = tostring(value),
			PlaceholderText = tostring(min) .. "-" .. tostring(max),
			ClearTextOnFocus = false
		})
		New("UICorner", { Parent = inputBox, CornerRadius = UDim.new(0,8) })
	end

	local dragging = false

	local function render()
		local alpha = (value - min) / math.max(1, (max - min))
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		valueLbl.Text = tostring(math.floor(value * 1000)/1000) .. suffix
		if inputBox then
			inputBox.Text = tostring(math.floor(value * 1000)/1000)
		end
	end

	local function set(v, silent)
		v = tonumber(v) or min
		v = clamp(v, min, max)
		value = v
		render()
		if not silent then
			self.Window:_safeCall(callback, value)
		end
	end

	local function setFromPos(px)
		local rel = clamp((px - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X), 0, 1)
		local v = min + (max - min) * rel
		set(v, false)
	end

	self.Window:_connect(bar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromPos(input.Position.X)
		end
	end)

	self.Window:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromPos(input.Position.X)
		end
	end)

	self.Window:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	if inputBox then
		self.Window:_connect(inputBox.FocusLost, function()
			set(inputBox.Text, false)
		end)
	end

	render()
	self.Window:_attachTooltip(bar, tooltip)

	self.Window:_bindTheme(function(theme)
		titleLbl.TextColor3 = theme.Text
		valueLbl.TextColor3 = theme.Muted
		if descLbl then descLbl.TextColor3 = theme.Muted end
		bar.BackgroundColor3 = theme.PanelSoft
		fill.BackgroundColor3 = theme.Accent1
		if inputBox then
			inputBox.BackgroundColor3 = theme.PanelSoft
			inputBox.TextColor3 = theme.Text
		end
	end)

	local id = opts.ID or self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Set(v) set(v, false) end
	function obj:Get() return value end

	self:_register(id, root, title, obj.Get, function(v, silent) set(v, silent) end, desc)
	return obj
end

function SectionProto:AddButton(opts)
	opts = opts or {}
	local title = opts.Title or "Button"
	local style = string.lower(opts.Style or "Primary")
	local callback = opts.Callback
	local tooltip = opts.Tooltip

	local root = self:_addElementRoot()
	local btn = New("TextButton", {
		Parent = root,
		Size = UDim2.new(1,0,0,34),
		BackgroundColor3 = self.Window.Theme.Accent1,
		BorderSizePixel = 0,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.new(1,1,1), -- always white (contrast)
		AutoButtonColor = false
	})
	New("UICorner", { Parent = btn, CornerRadius = UDim.new(0,10) })

	local function getStyleColor(theme)
		if style == "secondary" then
			return Color3.fromRGB(72, 78, 95)
		elseif style == "success" then
			return theme.Success
		elseif style == "danger" then
			return theme.Error
		else
			return theme.Accent1 -- primary
		end
	end

	self.Window:_bindTheme(function(theme)
		btn.BackgroundColor3 = getStyleColor(theme)
	end)

	self.Window:_connect(btn.MouseEnter, function()
		local c = getStyleColor(self.Window.Theme)
		local hover = c:Lerp(Color3.new(1,1,1), 0.08)
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = hover }):Play()
	end)

	self.Window:_connect(btn.MouseLeave, function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = getStyleColor(self.Window.Theme) }):Play()
	end)

	self.Window:_connect(btn.MouseButton1Click, function()
		TweenService:Create(btn, TweenInfo.new(0.08), { Size = UDim2.new(1,-2,0,32) }):Play()
		task.delay(0.08, function()
			if btn and btn.Parent then
				TweenService:Create(btn, TweenInfo.new(0.08), { Size = UDim2.new(1,0,0,34) }):Play()
			end
		end)
		self.Window:_safeCall(callback)
	end)

	self.Window:_attachTooltip(btn, tooltip)

	local id = opts.ID or self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Press() self.Window:_safeCall(callback) end
	function obj:Get() return title end
	function obj:Set(v) btn.Text = tostring(v) end

	self:_register(id, root, title, obj.Get, function(v) obj:Set(v) end)
	return obj
end

function SectionProto:AddInput(opts)
	opts = opts or {}
	local title = opts.Title or "Input"
	local desc = opts.Description or ""
	local placeholder = opts.Placeholder or ""
	local itype = string.lower(opts.Type or "String")
	local min = opts.Min
	local max = opts.Max
	local value = opts.Default or ""
	local callback = opts.Callback
	local tooltip = opts.Tooltip

	local root = self:_addElementRoot()

	local titleLbl = New("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,20),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local descLbl
	local topY = 20
	if desc ~= "" then
		descLbl = New("TextLabel", {
			Parent = root,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,16),
			Position = UDim2.fromOffset(0,20),
			Text = desc,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = self.Window.Theme.Muted,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		topY = 36
	end

	local box = New("TextBox", {
		Parent = root,
		Size = UDim2.new(1,0,0,32),
		Position = UDim2.fromOffset(0,topY),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		Text = tostring(value),
		PlaceholderText = placeholder,
		TextColor3 = self.Window.Theme.Text,
		ClearTextOnFocus = false
	})
	New("UICorner", { Parent = box, CornerRadius = UDim.new(0,10) })

	root.Size = UDim2.new(1,0,0, topY + 32)

	local function parse(v)
		if itype == "number" or itype == "integer" then
			local n = tonumber(v)
			if not n then
				n = tonumber(value) or 0
			end
			if itype == "integer" then n = math.floor(n + 0.5) end
			if min ~= nil then n = math.max(n, min) end
			if max ~= nil then n = math.min(n, max) end
			return n
		end
		return tostring(v)
	end

	local function set(v, silent)
		value = parse(v)
		box.Text = tostring(value)
		if not silent then
			self.Window:_safeCall(callback, value)
		end
	end

	self.Window:_connect(box.FocusLost, function()
		set(box.Text, false)
	end)

	self.Window:_attachTooltip(box, tooltip)

	self.Window:_bindTheme(function(theme)
		titleLbl.TextColor3 = theme.Text
		if descLbl then descLbl.TextColor3 = theme.Muted end
		box.BackgroundColor3 = theme.PanelSoft
		box.TextColor3 = theme.Text
	end)

	local id = opts.ID or self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Set(v) set(v, false) end
	function obj:Get() return value end

	self:_register(id, root, title, obj.Get, function(v, silent) set(v, silent) end, desc)
	return obj
end

function SectionProto:AddDropdown(opts)
	opts = opts or {}
	local title = opts.Title or "Dropdown"
	local items = opts.Items or {}
	local multi = opts.Multi or false
	local callback = opts.Callback
	local tooltip = opts.Tooltip

	local selected = multi and {} or (opts.Default or (items[1] or ""))

	local root = self:_addElementRoot()

	local titleLbl = New("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,20),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local open = false
	local topBtn = New("TextButton", {
		Parent = root,
		Size = UDim2.new(1,0,0,32),
		Position = UDim2.fromOffset(0,22),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	})
	New("UICorner", { Parent = topBtn, CornerRadius = UDim.new(0,10) })

	local valueLbl = New("TextLabel", {
		Parent = topBtn,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-30,1,0),
		Position = UDim2.fromOffset(10,0),
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local arrow = New("TextLabel", {
		Parent = topBtn,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(20,20),
		Position = UDim2.new(1,-24,0.5,-10),
		Text = "▼",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = self.Window.Theme.Muted
	})

	local list = New("Frame", {
		Parent = root,
		Position = UDim2.fromOffset(0, 58),
		Size = UDim2.new(1,0,0,0),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0,
		Visible = false
	})
	New("UICorner", { Parent = list, CornerRadius = UDim.new(0,10) })

	local listPadding = New("UIPadding", {
		Parent = list,
		PaddingTop = UDim.new(0,6),
		PaddingBottom = UDim.new(0,6),
		PaddingLeft = UDim.new(0,6),
		PaddingRight = UDim.new(0,6),
	})

	local listLayout = New("UIListLayout", {
		Parent = list,
		Padding = UDim.new(0,4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local optionButtons = {}

	local function getDisplayText()
		if multi then
			local t = {}
			for k, v in pairs(selected) do
				if v then table.insert(t, k) end
			end
			table.sort(t)
			if #t == 0 then return "Pilih..." end
			return table.concat(t, ", ")
		else
			if selected == nil or selected == "" then return "Pilih..." end
			return tostring(selected)
		end
	end

	local function fireCallback()
		if multi then
			local out = {}
			for k, v in pairs(selected) do
				if v then table.insert(out, k) end
			end
			table.sort(out)
			self.Window:_safeCall(callback, out)
		else
			self.Window:_safeCall(callback, selected)
		end
	end

	local function refreshValue()
		valueLbl.Text = getDisplayText()
	end

	local function clearOptions()
		for _, b in ipairs(optionButtons) do
			if b and b.Parent then b:Destroy() end
		end
		optionButtons = {}
	end

	local function rebuildOptions()
		clearOptions()

		if multi then
			local row = New("Frame", {
				Parent = list,
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,26)
			})

			local selectAll = New("TextButton", {
				Parent = row,
				Size = UDim2.new(0.5,-3,1,0),
				BackgroundColor3 = self.Window.Theme.Accent1,
				BorderSizePixel = 0,
				Text = "Select All",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Color3.new(1,1,1)
			})
			New("UICorner", { Parent = selectAll, CornerRadius = UDim.new(0,8) })

			local clearAll = New("TextButton", {
				Parent = row,
				Position = UDim2.new(0.5,3,0,0),
				Size = UDim2.new(0.5,-3,1,0),
				BackgroundColor3 = Color3.fromRGB(72,78,95),
				BorderSizePixel = 0,
				Text = "Clear All",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Color3.new(1,1,1)
			})
			New("UICorner", { Parent = clearAll, CornerRadius = UDim.new(0,8) })

			self.Window:_connect(selectAll.MouseButton1Click, function()
				for _, item in ipairs(items) do
					selected[item] = true
				end
				refreshValue()
				fireCallback()
			end)

			self.Window:_connect(clearAll.MouseButton1Click, function()
				selected = {}
				refreshValue()
				fireCallback()
			end)

			table.insert(optionButtons, row)
		end

		for _, item in ipairs(items) do
			local btn = New("TextButton", {
				Parent = list,
				Size = UDim2.new(1,0,0,28),
				BackgroundColor3 = self.Window.Theme.Panel,
				BorderSizePixel = 0,
				Text = tostring(item),
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = self.Window.Theme.Text,
				AutoButtonColor = false,
			})
			New("UICorner", { Parent = btn, CornerRadius = UDim.new(0,8) })

			local function redraw()
				if multi then
					local on = selected[item] and true or false
					btn.BackgroundColor3 = on and self.Window.Theme.Accent1 or self.Window.Theme.Panel
					btn.TextColor3 = Color3.new(1,1,1)
				else
					local on = (selected == item)
					btn.BackgroundColor3 = on and self.Window.Theme.Accent1 or self.Window.Theme.Panel
					btn.TextColor3 = Color3.new(1,1,1)
				end
			end

			self.Window:_connect(btn.MouseButton1Click, function()
				if multi then
					selected[item] = not selected[item]
				else
					selected = item
					open = false
					list.Visible = false
					list.Size = UDim2.new(1,0,0,0)
				end
				redraw()
				refreshValue()
				fireCallback()
			end)

			table.insert(optionButtons, btn)
			redraw()
		end

		local h = listLayout.AbsoluteContentSize.Y + listPadding.PaddingTop.Offset + listPadding.PaddingBottom.Offset
		if open then
			list.Size = UDim2.new(1,0,0,math.min(h, 200))
		end
		root.Size = UDim2.new(1,0,0, open and (58 + math.min(h,200)) or 58)
	end

	self.Window:_connect(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if open then
			local h = listLayout.AbsoluteContentSize.Y + listPadding.PaddingTop.Offset + listPadding.PaddingBottom.Offset
			list.Size = UDim2.new(1,0,0,math.min(h,200))
			root.Size = UDim2.new(1,0,0,58 + math.min(h,200))
		end
	end)

	self.Window:_connect(topBtn.MouseButton1Click, function()
		open = not open
		list.Visible = open
		arrow.Text = open and "▲" or "▼"
		if open then
			local h = listLayout.AbsoluteContentSize.Y + listPadding.PaddingTop.Offset + listPadding.PaddingBottom.Offset
			list.Size = UDim2.new(1,0,0,math.min(h,200))
			root.Size = UDim2.new(1,0,0,58 + math.min(h,200))
		else
			list.Size = UDim2.new(1,0,0,0)
			root.Size = UDim2.new(1,0,0,58)
		end
	end)

	self.Window:_attachTooltip(topBtn, tooltip)

	local function set(v, silent)
		if multi then
			selected = {}
			if type(v) == "table" then
				for _, name in ipairs(v) do
					selected[name] = true
				end
			end
		else
			selected = v
		end
		refreshValue()
		rebuildOptions()
		if not silent then
			fireCallback()
		end
	end

	refreshValue()
	rebuildOptions()

	self.Window:_bindTheme(function(theme)
		titleLbl.TextColor3 = theme.Text
		topBtn.BackgroundColor3 = theme.PanelSoft
		valueLbl.TextColor3 = theme.Text
		arrow.TextColor3 = theme.Muted
		list.BackgroundColor3 = theme.PanelSoft
	end)

	local id = opts.ID or self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Set(v) set(v, false) end
	function obj:Get()
		if multi then
			local out = {}
			for k, vv in pairs(selected) do
				if vv then table.insert(out, k) end
			end
			table.sort(out)
			return out
		end
		return selected
	end
	function obj:SetItems(newItems)
		items = newItems or {}
		rebuildOptions()
		refreshValue()
	end

	self:_register(id, root, title, obj.Get, function(v, silent) set(v, silent) end)
	return obj
end

function SectionProto:AddKeybind(opts)
	opts = opts or {}
	local title = opts.Title or "Keybind"
	local callback = opts.Callback
	local tooltip = opts.Tooltip
	local isToggleKey = opts.IsToggleKey and true or false
	local key = resolveKeyCode(opts.Default or Enum.KeyCode.Unknown)

	local root = self:_addElementRoot()
	root.Size = UDim2.new(1,0,0,34)
	root.AutomaticSize = Enum.AutomaticSize.None

	local titleLbl = New("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-130,1,0),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local bindBtn = New("TextButton", {
		Parent = root,
		Size = UDim2.fromOffset(120, 30),
		Position = UDim2.new(1,-120,0,2),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0,
		Text = key.Name,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = self.Window.Theme.Text,
		AutoButtonColor = false
	})
	New("UICorner", { Parent = bindBtn, CornerRadius = UDim.new(0,8) })

	local listening = false
	local function set(newKey, silent)
		key = resolveKeyCode(newKey)
		bindBtn.Text = key.Name
		if isToggleKey then
			self.Window.ToggleKey = key
		end
		if not silent then
			self.Window:_safeCall(callback, key)
		end
	end

	self.Window:_connect(bindBtn.MouseButton1Click, function()
		listening = true
		bindBtn.Text = "..."
	end)

	self.Window:_connect(UserInputService.InputBegan, function(input, gp)
		if gp then return end
		if listening then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				listening = false
				set(input.KeyCode, false)
			end
		end
	end)

	table.insert(self.Window.Keybinds, {
		GetKey = function() return key end,
		Callback = function()
			self.Window:_safeCall(callback, key)
		end
	})

	self.Window:_attachTooltip(bindBtn, tooltip)

	self.Window:_bindTheme(function(theme)
		titleLbl.TextColor3 = theme.Text
		bindBtn.BackgroundColor3 = theme.PanelSoft
		bindBtn.TextColor3 = theme.Text
	end)

	if isToggleKey then
		self.Window.ToggleKey = key
	end

	local id = opts.ID or self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Set(v) set(v, false) end
	function obj:Get() return key end

	self:_register(id, root, title, obj.Get, function(v, silent) set(v, silent) end)
	return obj
end

function SectionProto:AddColorPicker(opts)
	opts = opts or {}
	local title = opts.Title or "Color Picker"
	local callback = opts.Callback
	local tooltip = opts.Tooltip
	local color = opts.Default or Color3.fromRGB(255, 255, 255)

	local h, s, v = Color3.toHSV(color)
	local open = false

	local root = self:_addElementRoot()
	root.Size = UDim2.new(1,0,0,36)
	root.AutomaticSize = Enum.AutomaticSize.None

	local titleLbl = New("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-80,0,30),
		Position = UDim2.fromOffset(0,3),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local previewBtn = New("TextButton", {
		Parent = root,
		Size = UDim2.fromOffset(70,30),
		Position = UDim2.new(1,-70,0,3),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Text = "",
	})
	New("UICorner", { Parent = previewBtn, CornerRadius = UDim.new(0,8) })
	New("UIStroke", { Parent = previewBtn, Color = self.Window.Theme.Stroke, Transparency = 0.2, Thickness = 1 })

	local panel = New("Frame", {
		Parent = root,
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1,0,0,176),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0,
		Visible = false
	})
	New("UICorner", { Parent = panel, CornerRadius = UDim.new(0,10) })

	local sv = New("Frame", {
		Parent = panel,
		Size = UDim2.fromOffset(160,120),
		Position = UDim2.fromOffset(8,8),
		BackgroundColor3 = Color3.fromHSV(h,1,1),
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = sv, CornerRadius = UDim.new(0,8) })

	local whiteOverlay = New("Frame", {
		Parent = sv,
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0,
	})
	New("UICorner", { Parent = whiteOverlay, CornerRadius = UDim.new(0,8) })
	local wg = New("UIGradient", {
		Parent = whiteOverlay,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,0),
			NumberSequenceKeypoint.new(1,1)
		}),
		Rotation = 0
	})

	local blackOverlay = New("Frame", {
		Parent = sv,
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.new(0,0,0),
		BorderSizePixel = 0,
	})
	New("UICorner", { Parent = blackOverlay, CornerRadius = UDim.new(0,8) })
	local bg = New("UIGradient", {
		Parent = blackOverlay,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(1,0)
		}),
		Rotation = 90
	})

	local svCursor = New("Frame", {
		Parent = sv,
		Size = UDim2.fromOffset(10,10),
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(s,1-v),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = svCursor, CornerRadius = UDim.new(1,0) })
	New("UIStroke", { Parent = svCursor, Color = Color3.new(0,0,0), Thickness = 1 })

	local hue = New("Frame", {
		Parent = panel,
		Size = UDim2.fromOffset(16,120),
		Position = UDim2.fromOffset(174,8),
		BackgroundColor3 = Color3.new(1,0,0),
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = hue, CornerRadius = UDim.new(1,0) })
	New("UIGradient", {
		Parent = hue,
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
		})
	})

	local hueCursor = New("Frame", {
		Parent = hue,
		Size = UDim2.new(1,0,0,4),
		Position = UDim2.new(0,0,h, -2),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = hueCursor, CornerRadius = UDim.new(1,0) })

	local hexBox = New("TextBox", {
		Parent = panel,
		Size = UDim2.new(1,-16,0,30),
		Position = UDim2.fromOffset(8,136),
		BackgroundColor3 = self.Window.Theme.Panel,
		BorderSizePixel = 0,
		TextColor3 = self.Window.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		ClearTextOnFocus = false,
		Text = toHex(color),
		PlaceholderText = "#RRGGBB"
	})
	New("UICorner", { Parent = hexBox, CornerRadius = UDim.new(0,8) })

	local draggingSV = false
	local draggingHue = false

	local function getColor()
		return Color3.fromHSV(h, s, v)
	end

	local function render(silent)
		color = getColor()
		sv.BackgroundColor3 = Color3.fromHSV(h,1,1)
		svCursor.Position = UDim2.fromScale(s, 1-v)
		hueCursor.Position = UDim2.new(0,0,h, -2)
		previewBtn.BackgroundColor3 = color
		hexBox.Text = toHex(color)
		if not silent then
			self.Window:_safeCall(callback, color)
		end
	end

	local function setFromSV(pos)
		local x = clamp((pos.X - sv.AbsolutePosition.X) / math.max(1, sv.AbsoluteSize.X), 0, 1)
		local y = clamp((pos.Y - sv.AbsolutePosition.Y) / math.max(1, sv.AbsoluteSize.Y), 0, 1)
		s = x
		v = 1 - y
		render(false)
	end

	local function setFromHue(pos)
		local y = clamp((pos.Y - hue.AbsolutePosition.Y) / math.max(1, hue.AbsoluteSize.Y), 0, 1)
		h = y
		render(false)
	end

	self.Window:_connect(sv.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = true
			setFromSV(input.Position)
		end
	end)

	self.Window:_connect(hue.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
			setFromHue(input.Position)
		end
	end)

	self.Window:_connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if draggingSV then setFromSV(input.Position) end
			if draggingHue then setFromHue(input.Position) end
		end
	end)

	self.Window:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = false
			draggingHue = false
		end
	end)

	self.Window:_connect(hexBox.FocusLost, function()
		local c = fromHex(hexBox.Text)
		if c then
			h,s,v = Color3.toHSV(c)
			render(false)
		else
			hexBox.Text = toHex(color)
		end
	end)

	self.Window:_connect(previewBtn.MouseButton1Click, function()
		open = not open
		panel.Visible = open
		root.Size = UDim2.new(1,0,0, open and 224 or 36)
	end)

	self.Window:_attachTooltip(previewBtn, tooltip)

	local function set(vv, silent)
		if typeof(vv) == "Color3" then
			h,s,v = Color3.toHSV(vv)
			render(silent)
		end
	end

	render(true)

	self.Window:_bindTheme(function(theme)
		titleLbl.TextColor3 = theme.Text
		panel.BackgroundColor3 = theme.PanelSoft
		hexBox.BackgroundColor3 = theme.Panel
		hexBox.TextColor3 = theme.Text
	end)

	local id = opts.ID or self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Set(v) set(v, false) end
	function obj:Get() return color end

	self:_register(id, root, title, obj.Get, function(v, silent) set(v, silent) end)
	return obj
end

function SectionProto:AddImage(opts)
	opts = opts or {}
	local image = opts.Image or "rbxassetid://0"
	local height = tonumber(opts.Height) or 120
	local rounded = opts.Rounded ~= false

	if type(image) == "number" then
		image = "rbxassetid://" .. tostring(image)
	elseif type(image) == "string" and not image:find("rbxassetid://") and image:match("^%d+$") then
		image = "rbxassetid://" .. image
	end

	local root = self:_addElementRoot()

	local img = New("ImageLabel", {
		Parent = root,
		Size = UDim2.new(1,0,0,height),
		BackgroundColor3 = self.Window.Theme.PanelSoft,
		BorderSizePixel = 0,
		Image = image,
		ScaleType = Enum.ScaleType.Crop,
	})
	if rounded then
		New("UICorner", { Parent = img, CornerRadius = UDim.new(0,10) })
	end

	self.Window:_bindTheme(function(theme)
		img.BackgroundColor3 = theme.PanelSoft
	end)

	local id = self.Window:_makeID(self.Tab.Title, self.Title, "image")
	local obj = {}
	function obj:Set(v) img.Image = tostring(v) end
	function obj:Get() return img.Image end

	self:_register(id, root, "image", obj.Get, function(v) obj:Set(v) end)
	return obj
end

function SectionProto:AddParagraph(opts)
	opts = opts or {}
	local title = opts.Title or "Paragraph"
	local content = opts.Content or ""

	local root = self:_addElementRoot()

	local titleLbl = New("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,20),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Window.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local contentLbl = New("TextLabel", {
		Parent = root,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		Position = UDim2.fromOffset(0,22),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextWrapped = true,
		Text = content,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = self.Window.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	})

	root.Size = UDim2.new(1,0,0,22)
	root.AutomaticSize = Enum.AutomaticSize.Y

	self.Window:_bindTheme(function(theme)
		titleLbl.TextColor3 = theme.Text
		contentLbl.TextColor3 = theme.Muted
	end)

	local id = self.Window:_makeID(self.Tab.Title, self.Title, title)
	local obj = {}
	function obj:Set(v) contentLbl.Text = tostring(v) end
	function obj:Get() return contentLbl.Text end

	self:_register(id, root, title, obj.Get, function(v) obj:Set(v) end, content)
	return obj
end

function SectionProto:AddTextBox(opts)
	return self:AddInput(opts) -- legacy alias
end

--// Config system
function ENZO:_snapshot()
	local values = {}
	for id, meta in pairs(self.Registry) do
		if meta.Get then
			values[id] = serializeValue(meta.Get())
		end
	end

	return {
		__enzo = true,
		version = self.Version,
		theme = self.ThemeName,
		favorites = self.Favorites,
		values = values
	}
end

function ENZO:_applySnapshot(data)
	if type(data) ~= "table" then return false end

	if data.theme then
		self:SetTheme(data.theme)
	end

	if type(data.favorites) == "table" then
		self.Favorites = data.favorites
	end

	local values = data.values or data
	for id, serialized in pairs(values) do
		local meta = self.Registry[id]
		if meta and meta.Set then
			local value = deserializeValue(serialized)
			safecall(meta.Set, value, true) -- silent load
		end
	end

	return true
end

function ENZO:_configPath(name)
	return self.ConfigFolder .. "/" .. tostring(name) .. ".json"
end

function ENZO:Save(name)
	name = tostring(name or "default")
	local snap = self:_snapshot()
	local json = HttpService:JSONEncode(snap)

	if writefileFn then
		ensureFolder(self.ConfigFolder)
		local ok = pcall(writefileFn, self:_configPath(name), json)
		if ok then return true end
	end

	self._memoryConfigs[name] = json
	return true
end

function ENZO:Load(name)
	name = tostring(name or "default")
	local json

	if readfileFn then
		local ok, data = pcall(readfileFn, self:_configPath(name))
		if ok then
			json = data
		end
	end

	if not json then
		json = self._memoryConfigs[name]
	end

	if not json then
		return false, "Config not found"
	end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	if not ok then
		return false, "Invalid JSON config"
	end

	return self:_applySnapshot(data)
end

function ENZO:Delete(name)
	name = tostring(name or "default")
	self._memoryConfigs[name] = nil
	if delfileFn then
		pcall(delfileFn, self:_configPath(name))
	end
	return true
end

function ENZO:GetConfigs()
	local out = {}

	if listfilesFn then
		ensureFolder(self.ConfigFolder)
		local ok, files = pcall(listfilesFn, self.ConfigFolder)
		if ok and type(files) == "table" then
			for _, p in ipairs(files) do
				local b = basename(p)
				local n = b:gsub("%.json$", "")
				table.insert(out, n)
			end
		end
	end

	for k, _ in pairs(self._memoryConfigs) do
		local found = false
		for _, v in ipairs(out) do
			if v == k then found = true break end
		end
		if not found then
			table.insert(out, k)
		end
	end

	table.sort(out)
	return out
end

function ENZO:Export()
	local snap = self:_snapshot()
	return HttpService:JSONEncode(snap)
end

function ENZO:Import(json)
	local ok, data = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	if not ok then
		return false, "Invalid JSON"
	end
	return self:_applySnapshot(data)
end

function ENZO:ToggleFavorite(id)
	if not id then return false end
	self.Favorites[id] = not self.Favorites[id]
	return self.Favorites[id]
end

function ENZO:IsFavorite(id)
	return self.Favorites[id] == true
end

function ENZO:AddConfigManager()
	local tab = self:AddTab({ Title = "Config Manager", Icon = "💾" })
	local sec1 = tab:AddSection({ Title = "Config Files", Side = "Left", Icon = "📁" })
	local sec2 = tab:AddSection({ Title = "Import / Export", Side = "Right", Icon = "📤" })

	local nameInput = sec1:AddInput({
		Title = "Config Name",
		Default = "default",
		Placeholder = "nama config..."
	})

	local listDropdown = sec1:AddDropdown({
		Title = "Available Configs",
		Items = self:GetConfigs(),
		Default = "",
		Multi = false,
		Callback = function(v)
			if v and v ~= "" then
				nameInput:Set(v)
			end
		end
	})

	sec1:AddButton({
		Title = "Refresh Config List",
		Style = "Secondary",
		Callback = function()
			listDropdown:SetItems(self:GetConfigs())
			self:Notify("Config", "Daftar config diperbarui", "Info", 3)
		end
	})

	sec1:AddButton({
		Title = "Save Config",
		Style = "Success",
		Callback = function()
			local n = nameInput:Get()
			self:Save(n)
			listDropdown:SetItems(self:GetConfigs())
			self:Notify("Config Saved", "Config '" .. tostring(n) .. "' berhasil disimpan", "Success", 3)
		end
	})

	sec1:AddButton({
		Title = "Load Config",
		Style = "Primary",
		Callback = function()
			local n = nameInput:Get()
			local ok, err = self:Load(n)
			if ok then
				self:Notify("Config Loaded", "Config '" .. tostring(n) .. "' berhasil dimuat", "Success", 3)
			else
				self:Notify("Load Failed", tostring(err), "Error", 4)
			end
		end
	})

	sec1:AddButton({
		Title = "Delete Config",
		Style = "Danger",
		Callback = function()
			local n = nameInput:Get()
			self:Delete(n)
			listDropdown:SetItems(self:GetConfigs())
			self:Notify("Config Deleted", "Config '" .. tostring(n) .. "' dihapus", "Warning", 3)
		end
	})

	local exportBox = sec2:AddInput({
		Title = "JSON Data",
		Placeholder = "tempel / copy JSON di sini",
		Default = ""
	})

	sec2:AddButton({
		Title = "Export Current -> JSON",
		Style = "Primary",
		Callback = function()
			local json = self:Export()
			exportBox:Set(json)
			self:Notify("Export", "JSON export berhasil", "Success", 3)
		end
	})

	sec2:AddButton({
		Title = "Import JSON -> Apply",
		Style = "Secondary",
		Callback = function()
			local ok, err = self:Import(exportBox:Get())
			if ok then
				self:Notify("Import", "JSON berhasil di-apply", "Success", 3)
			else
				self:Notify("Import Failed", tostring(err), "Error", 4)
			end
		end
	})

	sec2:AddParagraph({
		Title = "Tips",
		Content = "Jika executor tidak support file API, config tetap disimpan di memory selama session berjalan."
	})

	return tab
end

--// Create Window
function ENZO.CreateWindow(opts)
	opts = opts or {}

	-- safe cleanup old
	if _G.__ENZO_WINDOW and type(_G.__ENZO_WINDOW.Destroy) == "function" then
		pcall(function()
			_G.__ENZO_WINDOW:Destroy()
		end)
	end

	local self = setmetatable({}, ENZO)
	self._connections = {}
	self._themeBinders = {}
	self._opacityTargets = {}
	self._memoryConfigs = {}
	self.Registry = {}
	self.Elements = {}
	self.Tabs = {}
	self.Keybinds = {}
	self.Favorites = {}
	self._idCount = 0
	self.Minimized = false
	self.Visible = true
	self.StartTick = tick()

	self.Title = opts.Title or "ENZO UI"
	self.SubTitle = opts.SubTitle or "Fluent+ Library"
	self.Size = resolveSize(opts.Size)
	self.Logo = opts.Logo
	self.ThemeName = opts.Theme or "Sunset" -- Preview B default
	self.Theme = ENZO.Themes[self.ThemeName] or ENZO.Themes.Sunset
	self.ToggleKey = resolveKeyCode(opts.ToggleKey or Enum.KeyCode.RightShift)
	self.Version = opts.Version or ENZO.Version
	self.UpdateURL = opts.UpdateURL
	self.ConfigFolder = opts.ConfigFolder or "ENZO_UI_Configs"
	self.Opacity = 1
	self.BlurEnabled = opts.Blur and true or false

	local guiParent = CoreGui
	pcall(function()
		if gethui then
			guiParent = gethui()
		end
	end)

	local gui = New("ScreenGui", {
		Parent = guiParent,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	if protectgui then pcall(protectgui, gui) end
	if protect_gui then pcall(protect_gui, gui) end

	self.Gui = gui

	-- background container
	local root = New("Frame", {
		Parent = gui,
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1
	})

	-- main window
	local main = New("Frame", {
		Parent = root,
		Size = self.Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
	})
	New("UICorner", { Parent = main, CornerRadius = UDim.new(0,16) })
	local mainStroke = New("UIStroke", { Parent = main, Color = self.Theme.Stroke, Thickness = 1, Transparency = 0.12 })

	self.Main = main
	self.MainStroke = mainStroke
	self:_registerOpacityTarget(main, 0.06)

	-- glow strip (aurora style)
	local topGlow = New("Frame", {
		Parent = main,
		Size = UDim2.new(1,0,0,3),
		BackgroundColor3 = self.Theme.Accent1,
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = topGlow, CornerRadius = UDim.new(0,16) })
	local glowGrad = New("UIGradient", {
		Parent = topGlow,
		Rotation = 0,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.Theme.Accent1),
			ColorSequenceKeypoint.new(0.5, self.Theme.Accent2),
			ColorSequenceKeypoint.new(1, self.Theme.Accent1),
		})
	})

	-- header
	local header = New("Frame", {
		Parent = main,
		Size = UDim2.new(1,0,0,56),
		BackgroundColor3 = self.Theme.PanelSoft,
		BorderSizePixel = 0,
	})
	New("UICorner", { Parent = header, CornerRadius = UDim.new(0,16) })
	self:_registerOpacityTarget(header, 0.12)

	local logo = New("ImageLabel", {
		Parent = header,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(32,32),
		Position = UDim2.fromOffset(10,12),
		Image = self.Logo or "",
	})
	if not self.Logo then
		logo.Visible = false
	end

	local titleLbl = New("TextLabel", {
		Parent = header,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5,0,0,20),
		Position = UDim2.fromOffset(self.Logo and 48 or 12, 8),
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = self.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local subLbl = New("TextLabel", {
		Parent = header,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6,0,0,16),
		Position = UDim2.fromOffset(self.Logo and 48 or 12, 30),
		Text = self.SubTitle .. " • " .. self.Version,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = self.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local search = New("TextBox", {
		Parent = header,
		Size = UDim2.fromOffset(170, 30),
		Position = UDim2.new(1,-276,0,13),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = "Search elements...",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = self.Theme.Text,
		ClearTextOnFocus = false
	})
	New("UICorner", { Parent = search, CornerRadius = UDim.new(0,8) })
	self:_registerOpacityTarget(search, 0.2)
	self.SearchBox = search

	local minBtn = New("TextButton", {
		Parent = header,
		Size = UDim2.fromOffset(30,30),
		Position = UDim2.new(1,-96,0,13),
		BackgroundColor3 = Color3.fromRGB(72,78,95),
		BorderSizePixel = 0,
		Text = "—",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.new(1,1,1),
	})
	New("UICorner", { Parent = minBtn, CornerRadius = UDim.new(0,8) })

	local settingsBtn = New("TextButton", {
		Parent = header,
		Size = UDim2.fromOffset(30,30),
		Position = UDim2.new(1,-62,0,13),
		BackgroundColor3 = self.Theme.Accent1,
		BorderSizePixel = 0,
		Text = "⚙",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.new(1,1,1),
	})
	New("UICorner", { Parent = settingsBtn, CornerRadius = UDim.new(0,8) })

	local closeBtn = New("TextButton", {
		Parent = header,
		Size = UDim2.fromOffset(30,30),
		Position = UDim2.new(1,-28,0,13),
		BackgroundColor3 = self.Theme.Error,
		BorderSizePixel = 0,
		Text = "✕",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.new(1,1,1),
	})
	New("UICorner", { Parent = closeBtn, CornerRadius = UDim.new(0,8) })

	-- body
	local body = New("Frame", {
		Parent = main,
		Position = UDim2.fromOffset(0,58),
		Size = UDim2.new(1,0,1,-58),
		BackgroundTransparency = 1
	})
	self.Body = body

	local tabsFrame = New("ScrollingFrame", {
		Parent = body,
		Size = UDim2.new(0,178,1,-8),
		Position = UDim2.fromOffset(8,4),
		BackgroundColor3 = self.Theme.PanelSoft,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.fromOffset(0,0),
	})
	New("UICorner", { Parent = tabsFrame, CornerRadius = UDim.new(0,12) })
	self:_registerOpacityTarget(tabsFrame, 0.18)

	local tabPad = New("UIPadding", {
		Parent = tabsFrame,
		PaddingTop = UDim.new(0,8),
		PaddingBottom = UDim.new(0,8),
		PaddingLeft = UDim.new(0,5),
		PaddingRight = UDim.new(0,5),
	})
	local tabLayout = New("UIListLayout", {
		Parent = tabsFrame,
		Padding = UDim.new(0,7),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local pageHolder = New("Frame", {
		Parent = body,
		Position = UDim2.fromOffset(194, 4),
		Size = UDim2.new(1,-202,1,-8),
		BackgroundColor3 = self.Theme.PanelSoft,
		BorderSizePixel = 0,
	})
	New("UICorner", { Parent = pageHolder, CornerRadius = UDim.new(0,12) })
	self:_registerOpacityTarget(pageHolder, 0.16)

	self.TabList = tabsFrame
	self.PageHolder = pageHolder

	-- settings panel
	local settingsPanel = New("Frame", {
		Parent = main,
		Size = UDim2.fromOffset(260, 250),
		Position = UDim2.new(1, -268, 0, 62),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
		Visible = false
	})
	New("UICorner", { Parent = settingsPanel, CornerRadius = UDim.new(0,12) })
	New("UIStroke", { Parent = settingsPanel, Color = self.Theme.Stroke, Transparency = 0.2, Thickness = 1 })

	local spTitle = New("TextLabel", {
		Parent = settingsPanel,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-16,0,24),
		Position = UDim2.fromOffset(8,8),
		Text = "Settings",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = self.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local themeLbl = New("TextLabel", {
		Parent = settingsPanel,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-16,0,16),
		Position = UDim2.fromOffset(8,36),
		Text = "Theme",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = self.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local themeWrap = New("Frame", {
		Parent = settingsPanel,
		Position = UDim2.fromOffset(8,56),
		Size = UDim2.new(1,-16,0,100),
		BackgroundTransparency = 1,
	})
	local tl = New("UIGridLayout", {
		Parent = themeWrap,
		CellSize = UDim2.new(0.5,-4,0,24),
		CellPadding = UDim2.fromOffset(8,6),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local themeNames = {"Aurora", "Sunset", "Ocean", "Forest", "Sakura", "Midnight"}
	for _, name in ipairs(themeNames) do
		local b = New("TextButton", {
			Parent = themeWrap,
			BackgroundColor3 = self.Theme.PanelSoft,
			BorderSizePixel = 0,
			Text = name,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = Color3.new(1,1,1),
			AutoButtonColor = false
		})
		New("UICorner", { Parent = b, CornerRadius = UDim.new(0,8) })

		self:_connect(b.MouseButton1Click, function()
			self:SetTheme(name)
		end)
	end

	local opLbl = New("TextLabel", {
		Parent = settingsPanel,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-16,0,16),
		Position = UDim2.fromOffset(8,166),
		Text = "Opacity",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = self.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local opacitySlider = New("Frame", {
		Parent = settingsPanel,
		Size = UDim2.new(1,-16,0,8),
		Position = UDim2.fromOffset(8,190),
		BackgroundColor3 = self.Theme.PanelSoft,
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = opacitySlider, CornerRadius = UDim.new(1,0) })

	local opacityFill = New("Frame", {
		Parent = opacitySlider,
		Size = UDim2.new(1,0,1,0),
		BackgroundColor3 = self.Theme.Accent1,
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = opacityFill, CornerRadius = UDim.new(1,0) })

	local opValue = New("TextLabel", {
		Parent = settingsPanel,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-16,0,16),
		Position = UDim2.fromOffset(8,202),
		Text = "100%",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = self.Theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local draggingOpacity = false
	local function setOpacityFromX(x)
		local rel = clamp((x - opacitySlider.AbsolutePosition.X) / math.max(1, opacitySlider.AbsoluteSize.X), 0, 1)
		self.Opacity = rel
		opacityFill.Size = UDim2.new(rel,0,1,0)
		opValue.Text = tostring(math.floor(rel * 100 + 0.5)) .. "%"
		self:_applyOpacity()
	end

	self:_connect(opacitySlider.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingOpacity = true
			setOpacityFromX(input.Position.X)
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if draggingOpacity and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setOpacityFromX(input.Position.X)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingOpacity = false
		end
	end)

	-- tooltip
	local tooltip = New("Frame", {
		Parent = gui,
		Size = UDim2.fromOffset(120, 28),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 999
	})
	New("UICorner", { Parent = tooltip, CornerRadius = UDim.new(0,8) })
	New("UIStroke", { Parent = tooltip, Color = self.Theme.Stroke, Transparency = 0.2, Thickness = 1 })
	local tipLabel = New("TextLabel", {
		Parent = tooltip,
		Size = UDim2.new(1,-12,1,-8),
		Position = UDim2.fromOffset(6,4),
		BackgroundTransparency = 1,
		Text = "",
		TextWrapped = true,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = self.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
	})
	tooltip.TextLabel = tipLabel
	self._tooltip = tooltip

	-- notifications stack
	local notifHolder = New("Frame", {
		Parent = gui,
		Size = UDim2.fromOffset(330, 360),
		Position = UDim2.new(1,-340,1,-12),
		AnchorPoint = Vector2.new(0,1),
		BackgroundTransparency = 1
	})
	local nlayout = New("UIListLayout", {
		Parent = notifHolder,
		Padding = UDim.new(0,8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom
	})
	self.NotifHolder = notifHolder

	-- watermark
	if opts.Watermark ~= false then
		local wm = New("Frame", {
			Parent = gui,
			Size = UDim2.fromOffset(270, 30),
			Position = UDim2.fromOffset(16, 12),
			BackgroundColor3 = self.Theme.Panel,
			BorderSizePixel = 0
		})
		New("UICorner", { Parent = wm, CornerRadius = UDim.new(0,10) })
		New("UIStroke", { Parent = wm, Color = self.Theme.Stroke, Transparency = 0.2, Thickness = 1 })

		local wmText = New("TextLabel", {
			Parent = wm,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.fromOffset(8,0),
			Text = "FPS: -- | Ping: --ms | Session: 00:00:00",
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = self.Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		self:_makeDraggable(wm, wm)
		self._watermark = wm

		local frameCount = 0
		local fps = 0
		local elapsed = 0

		self:_connect(RunService.RenderStepped, function(dt)
			frameCount += 1
			elapsed += dt
			if elapsed >= 1 then
				fps = frameCount
				frameCount = 0
				elapsed = 0

				local pingText = "--"
				pcall(function()
					local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
					if pingItem then
						local raw = pingItem:GetValueString() -- e.g. "43.2 ms"
						pingText = tostring(raw):gsub("ms", ""):gsub("%s+", "")
					end
				end)

				local sess = math.floor(tick() - self.StartTick)
				local hh = math.floor(sess / 3600)
				local mm = math.floor((sess % 3600) / 60)
				local ss = sess % 60
				local tstr = string.format("%02d:%02d:%02d", hh, mm, ss)

				wmText.Text = string.format("FPS: %d | Ping: %sms | Session: %s", fps, pingText, tstr)
			end
		end)
	end

	-- mobile floating toggle
	if UserInputService.TouchEnabled then
		local mobileBtn = New("TextButton", {
			Parent = gui,
			Size = UDim2.fromOffset(52,52),
			Position = UDim2.new(0, 18, 1, -76),
			BackgroundColor3 = self.Theme.Accent1,
			BorderSizePixel = 0,
			Text = "EN",
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = Color3.new(1,1,1),
			AutoButtonColor = false
		})
		New("UICorner", { Parent = mobileBtn, CornerRadius = UDim.new(1,0) })

		self:_connect(mobileBtn.MouseButton1Click, function()
			self:Toggle()
		end)
		self:_makeDraggable(mobileBtn, mobileBtn)
	end

	-- Resize handle
	local resizeHandle = New("Frame", {
		Parent = main,
		Size = UDim2.fromOffset(14,14),
		Position = UDim2.new(1,-16,1,-16),
		BackgroundColor3 = self.Theme.Accent1,
		BorderSizePixel = 0
	})
	New("UICorner", { Parent = resizeHandle, CornerRadius = UDim.new(1,0) })

	local resizing = false
	local resizeStart, sizeStart
	self:_connect(resizeHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			sizeStart = main.Size
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - resizeStart
			local newW = math.max(620, sizeStart.X.Offset + d.X)
			local newH = math.max(420, sizeStart.Y.Offset + d.Y)
			main.Size = UDim2.fromOffset(newW, newH)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)

	-- interactions
	self:_makeDraggable(header, main)

	self:_connect(minBtn.MouseButton1Click, function()
		if self.Minimized then self:Restore() else self:Minimize() end
	end)

	self:_connect(closeBtn.MouseButton1Click, function()
		self:Destroy()
	end)

	self:_connect(settingsBtn.MouseButton1Click, function()
		settingsPanel.Visible = not settingsPanel.Visible
	end)

	self:_connect(search:GetPropertyChangedSignal("Text"), function()
		self:_applySearch(search.Text)
	end)

	-- toggle key + keybind trigger
	self:_connect(UserInputService.InputBegan, function(input, gp)
		if gp then return end
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
		end

		for _, kb in ipairs(self.Keybinds) do
			local k = kb.GetKey and kb.GetKey()
			if k and input.KeyCode == k then
				safecall(kb.Callback)
			end
		end
	end)

	-- tooltip follow mouse
	self:_connect(RunService.RenderStepped, function()
		if tooltip.Visible then
			local m = UserInputService:GetMouseLocation()
			tooltip.Position = UDim2.fromOffset(m.X + 14, m.Y + 14)
		end
		glowGrad.Rotation = (glowGrad.Rotation + 0.4) % 360
	end)

	-- tab list canvas
	self:_connect(tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		tabsFrame.CanvasSize = UDim2.fromOffset(0, tabLayout.AbsoluteContentSize.Y + 16)
	end)

	-- theme binding master
	self:_bindTheme(function(theme)
		main.BackgroundColor3 = theme.Panel
		mainStroke.Color = theme.Stroke
		header.BackgroundColor3 = theme.PanelSoft
		topGlow.BackgroundColor3 = theme.Accent1
		glowGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.Accent1),
			ColorSequenceKeypoint.new(0.5, theme.Accent2),
			ColorSequenceKeypoint.new(1, theme.Accent1),
		})

		titleLbl.TextColor3 = theme.Text
		subLbl.TextColor3 = theme.Muted
		search.BackgroundColor3 = theme.Panel
		search.TextColor3 = theme.Text
		settingsBtn.BackgroundColor3 = theme.Accent1
		closeBtn.BackgroundColor3 = theme.Error

		tabsFrame.BackgroundColor3 = theme.PanelSoft
		pageHolder.BackgroundColor3 = theme.PanelSoft

		settingsPanel.BackgroundColor3 = theme.Panel
		spTitle.TextColor3 = theme.Text
		themeLbl.TextColor3 = theme.Muted
		opLbl.TextColor3 = theme.Muted
		opacitySlider.BackgroundColor3 = theme.PanelSoft
		opacityFill.BackgroundColor3 = theme.Accent1
		opValue.TextColor3 = theme.Muted

		tooltip.BackgroundColor3 = theme.Panel
		tipLabel.TextColor3 = theme.Text
		resizeHandle.BackgroundColor3 = theme.Accent1
	end)

	self:_applyOpacity()
	self:SetBlur(self.BlurEnabled)

	-- optional update check
	if self.UpdateURL and type(self.UpdateURL) == "string" and self.UpdateURL ~= "" then
		task.spawn(function()
			local ok, data = pcall(function()
				return game:HttpGet(self.UpdateURL)
			end)
			if ok and type(data) == "string" and #data > 0 then
				local remote = data:match("([%w%._%-]+)")
				if remote and remote ~= self.Version then
					self:Notify("Update Available", "Versi baru: " .. tostring(remote), "Info", 6)
				end
			end
		end)
	end

	_G.__ENZO_WINDOW = self
	return self
end

return ENZO