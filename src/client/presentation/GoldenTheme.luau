--!strict
local globals: any = getfenv()
local Instance, Enum, Color3, UDim, UDim2 =
	globals.Instance, globals.Enum, globals.Color3, globals.UDim, globals.UDim2
local catalog = require(
	game:GetService("ReplicatedStorage").MonsterVault.Shared.config.CreaturePresentationCatalog
)
local Theme = {}
local RarityTokens = require(script.Parent.RarityTokens)
local images = require(
	game:GetService("ReplicatedStorage").MonsterVault.Shared.config.RefreshPresentationImages
)
Theme.colors = table.freeze({
	panel = Color3.fromRGB(19, 25, 33),
	inset = Color3.fromRGB(30, 41, 49),
	text = Color3.fromRGB(241, 246, 227),
	muted = Color3.fromRGB(162, 185, 185),
	energy = Color3.fromRGB(76, 255, 110),
	border = Color3.fromRGB(66, 87, 96),
	rare = Color3.fromRGB(99, 221, 244),
	legendary = Color3.fromRGB(255, 208, 91),
	disabled = Color3.fromRGB(59, 73, 77),
})
function Theme.round(object: any, radius: number?)
	if not object:FindFirstChild("GoldenCorner") then
		local corner = Instance.new("UICorner")
		corner.Name, corner.CornerRadius, corner.Parent =
			"GoldenCorner", UDim.new(0, radius or 12), object
	end
end
function Theme.panel(object: any)
	object.BackgroundColor3, object.BorderSizePixel = Theme.colors.panel, 0
	object.BackgroundTransparency = 0
	Theme.round(object)
	if not object:FindFirstChild("GoldenStroke") then
		local stroke = Instance.new("UIStroke")
		stroke.Name, stroke.Color, stroke.Transparency, stroke.Parent =
			"GoldenStroke", Theme.colors.border, 0.3, object
	end
	if not object:FindFirstChild("GoldenDepth") then
		local gradient = Instance.new("UIGradient")
		gradient.Name, gradient.Rotation = "GoldenDepth", 90
		gradient.Color =
			globals.ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(208, 225, 227))
		gradient.Parent = object
	end
end
function Theme.header(object: any)
	if object:FindFirstChild("FoundryHeader") then
		return
	end
	local accent = Instance.new("ImageLabel")
	accent.Name, accent.BackgroundTransparency, accent.Image =
		"FoundryHeader", 1, images.panelHeader
	accent.Position, accent.Size = UDim2.fromOffset(18, 3), UDim2.new(1, -36, 0, 6)
	accent.ScaleType, accent.SliceCenter = Enum.ScaleType.Slice, globals.Rect.new(9, 9, 72, 44)
	accent.ImageTransparency, accent.Parent = 0.25, object
end
-- Decorative prompts accompany the native binding text. No input route or
-- controller family is inferred from the connected-device count.
function Theme.inputGlyph(button: any, glyph: string, visible: boolean)
	local key = ({
		E = "keyboardE",
		Square = "playstationSquare",
		["□"] = "playstationSquare",
		Triangle = "playstationTriangle",
		["△"] = "playstationTriangle",
		X = "xboxX",
		Y = "xboxY",
	} :: any)[glyph]
	local icon = button:FindFirstChild("InputGlyph")
	if not icon then
		icon = Instance.new("ImageLabel")
		icon.Name, icon.BackgroundTransparency = "InputGlyph", 1
		icon.AnchorPoint, icon.Position, icon.Size =
			globals.Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0), UDim2.fromOffset(28, 28)
		icon.ScaleType, icon.Parent = Enum.ScaleType.Fit, button
	end
	icon.Visible = visible and key ~= nil and button.AbsoluteSize.X >= 280
	icon.Image = if key then (images :: any)[key] else ""
	icon.ImageColor3 = if button:GetAttribute("GoldenPrimary")
		then Theme.colors.panel
		else Theme.colors.text
end
function Theme.text(object: any, size: number?, bold: boolean?)
	object.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	object.TextSize, object.TextColor3 = size or 16, Theme.colors.text
	object.TextWrapped, object.TextXAlignment = true, Enum.TextXAlignment.Left
	object.BackgroundTransparency, object.BorderSizePixel = 1, 0
end
function Theme.button(object: any, primary: boolean?)
	object.Font, object.TextSize, object.BorderSizePixel = Enum.Font.GothamBold, 16, 0
	object.TextColor3 = if primary then Theme.colors.panel else Theme.colors.text
	object.BackgroundColor3 = if primary then Theme.colors.energy else Theme.colors.inset
	object.TextWrapped = true
	if object:IsA("GuiButton") then
		object.AutoButtonColor = true
	end
	Theme.round(object, 8)
end
function Theme.enabled(button: any, value: boolean)
	button.Active, button.Interactable, button.Selectable = value, value, value
	button.BackgroundColor3 = if value then Theme.colors.inset else Theme.colors.disabled
	button.TextColor3 = if value then Theme.colors.text else Theme.colors.muted
end
function Theme.rarity(id: string?): (string, any)
	local token = id and (RarityTokens :: any)[id]
	if token then
		return token.label, Color3.fromRGB(table.unpack(token.rgb))
	end
	return "IDENTITY UNAVAILABLE", Theme.colors.muted
end
-- Native geometry keeps rarity readable without depending on font glyph coverage.
function Theme.rarityBadge(parent: any, id: string?): any
	local text, color = Theme.rarity(id)
	local token = id and (RarityTokens :: any)[id]
	local badge = Instance.new("Frame")
	badge.Name, badge.BackgroundTransparency, badge.Size, badge.AutomaticSize =
		"IntrinsicRarity", 1, UDim2.new(1, 0, 0, 22), Enum.AutomaticSize.Y
	local icon = Instance.new("Frame")
	icon.Name, icon.BackgroundTransparency, icon.Position, icon.Size, icon.Parent =
		"RarityMark", 1, UDim2.fromOffset(0, 2), UDim2.fromOffset(20, 20), badge
	local function piece(
		x: number,
		y: number,
		w: number,
		h: number,
		rotation: number?,
		outline: boolean?
	): any
		local mark = Instance.new("Frame")
		mark.BackgroundColor3, mark.BorderSizePixel = color, 0
		mark.Position, mark.Size, mark.Rotation =
			UDim2.fromOffset(x, y), UDim2.fromOffset(w, h), rotation or 0
		if outline then
			mark.BackgroundTransparency = 1
			local stroke = Instance.new("UIStroke")
			stroke.Color, stroke.Thickness, stroke.Parent = color, 1.5, mark
		end
		mark.Parent = icon
		return mark
	end
	local shape = token and token.shape
	if shape == "circle" then
		Theme.round(piece(5, 5, 10, 10), 10)
	elseif shape == "chevron" then
		piece(4, 6, 4, 11, 45)
		piece(11, 6, 4, 11, -45)
	elseif shape == "diamond" then
		piece(5, 5, 10, 10, 45, true)
	elseif shape == "doubleDiamond" then
		piece(2, 6, 8, 8, 45)
		piece(11, 6, 8, 8, 45)
	elseif shape == "crown" then
		piece(3, 8, 4, 8, -12)
		piece(8, 4, 4, 12)
		piece(13, 8, 4, 8, 12)
		piece(3, 15, 14, 3)
	end
	local label = Instance.new("TextLabel")
	Theme.text(label, 14, true)
	label.Name, label.Text, label.TextColor3 = "Label", text, color
	label.Position, label.Size, label.AutomaticSize, label.Parent =
		UDim2.fromOffset(26, 0), UDim2.new(1, -26, 0, 22), Enum.AutomaticSize.Y, badge
	badge.Parent = parent
	return badge
end
function Theme.definition(speciesId: string?, rarityId: string?): any
	local definition = if speciesId then (catalog :: any)[speciesId] else nil
	return if definition and definition.rarity == rarityId then definition else nil
end
function Theme.viewport(parent: any, speciesId: string?, rarityId: string?): any
	local frame = Instance.new("ViewportFrame")
	frame.Name, frame.BackgroundColor3, frame.BorderSizePixel =
		"CreaturePortrait", Theme.colors.inset, 0
	frame.Ambient, frame.LightColor = Color3.fromRGB(174, 190, 178), Color3.fromRGB(255, 244, 206)
	frame.LightDirection = globals.Vector3.new(-1, -1, -2)
	Theme.round(frame, 10)
	-- Register the viewport before adding its scene/camera. A detached scene
	-- can retain an empty render cache when first revealed inside a modal.
	frame.Parent = parent
	local definition = Theme.definition(speciesId, rarityId)
	local prefab = if definition
		then game:GetService("ReplicatedStorage").MonsterVault.PresentationAssets
			:FindFirstChild(definition.asset)
		else nil
	if prefab then
		local world = Instance.new("WorldModel")
		world.Parent = frame
		local creature = prefab:Clone()
		creature.Parent = world
		local bounds, size = creature:GetBoundingBox()
		local camera = Instance.new("Camera")
		camera.FieldOfView = 36
		camera.Parent, frame.CurrentCamera = frame, camera
		local function fit()
			local viewportSize = frame.AbsoluteSize
			local aspect = math.max(0.35, viewportSize.X / math.max(1, viewportSize.Y))
			local radius = math.max(size.X, size.Y, size.Z) * 0.6
			local distance = radius / (math.tan(math.rad(18)) * math.min(1, aspect)) + size.Z * 0.5
			camera.CFrame = globals.CFrame.lookAt(
				bounds.Position + globals.Vector3.new(distance * 0.12, distance * 0.08, distance),
				bounds.Position
			)
			camera.Focus = bounds
		end
		frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
		fit()
	end
	return frame
end
function Theme.factLabel(id: string): string
	local label = id:match("([^/]+)$") or id
	label = label:gsub("^fixture%-", ""):gsub("%-", " ")
	return (
		label:gsub("%a[%w]*", function(word: string)
			return word:sub(1, 1):upper() .. word:sub(2)
		end)
	)
end
function Theme.card(parent: any, facts: any, readOnly: boolean): any
	local rarityId = facts.speciesRarityId or facts.rarityId
	local card = Instance.new("Frame")
	card.Name, card.Size, card.Parent = "CreatureCard", UDim2.new(1, -12, 0, 224), parent
	card:SetAttribute("PresentedCreatureInstanceId", facts.creatureInstanceId)
	Theme.panel(card)
	local definition = Theme.definition(facts.speciesId, rarityId)
	if definition then
		local portrait = Theme.viewport(card, facts.speciesId, rarityId)
		portrait.Size, portrait.Position = UDim2.new(0.35, -8, 0, 180), UDim2.fromOffset(10, 12)
	end
	local copy = Instance.new("Frame")
	copy.Name, copy.BackgroundTransparency, copy.Position, copy.Size, copy.AutomaticSize, copy.Parent =
		"Facts",
		1,
		if definition then UDim2.new(0.35, 4, 0, 12) else UDim2.fromOffset(12, 12),
		if definition then UDim2.new(0.65, -20, 0, 0) else UDim2.new(1, -24, 0, 0),
		Enum.AutomaticSize.Y,
		card
	local layout = Instance.new("UIListLayout")
	layout.Padding, layout.SortOrder, layout.Parent =
		UDim.new(0, 8), Enum.SortOrder.LayoutOrder, copy
	local function line(
		name: string,
		content: string,
		size: number,
		color: any,
		order: number,
		bold: boolean?
	)
		local label = Instance.new("TextLabel")
		Theme.text(label, size, bold)
		label.Name, label.Text, label.TextColor3 = name, content, color
		label.Size, label.AutomaticSize, label.LayoutOrder, label.Parent =
			UDim2.new(1, 0, 0, size + 4), Enum.AutomaticSize.Y, order, copy
	end
	line(
		"Name",
		if definition then definition.label else "Owned creature",
		22,
		Theme.colors.text,
		1,
		true
	)
	if rarityId then
		Theme.rarityBadge(copy, rarityId).LayoutOrder = 2
	end
	local function labels(ids: any): string
		local result = {}
		for _, id in ids or {} do
			table.insert(result, Theme.factLabel(id))
		end
		return if #result == 0 then "None" else table.concat(result, ", ")
	end
	line(
		"IntrinsicFacts",
		if facts.speciesId
			then "Mutation · " .. labels(facts.mutationIds) .. "\nTrait · " .. labels(
				facts.traitIds
			)
			else "Saved in your Collection. Open Vault to choose a display or production role.",
		16,
		Theme.colors.muted,
		3
	)
	local role = if facts.displaySlotId
		then "Display " .. (facts.displaySlotId:match("/(%d+)$") or "")
		elseif facts.productionSlotId then "Producing Energy"
		else "Collection"
	line(
		"Access",
		(if readOnly then "READ ONLY" else "OWNED") .. " · " .. role,
		14,
		Theme.colors.text,
		4,
		true
	)
	local function fit()
		card.Size = UDim2.new(
			1,
			-12,
			0,
			math.max(if definition then 224 else 112, layout.AbsoluteContentSize.Y + 26)
		)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)
	fit()
	return card
end
return Theme
