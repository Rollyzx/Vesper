-- ============================================================================
-- ESP.lua — Player ESP System
-- Cargado desde main.lua con: loadstring(game:HttpGet(URL))()
-- Expone: _G.ESPSettings, _G.InitializeESP
-- ============================================================================

-- [[ // ESP SYSTEM OPTIMIZADO // ]]
do
	local RunService  = game:GetService("RunService")
	local Workspace   = game:GetService("Workspace")
	local Camera      = Workspace.CurrentCamera
	local Players     = game:GetService("Players")
	local localPlayer = Players.LocalPlayer

	print("=== INICIANDO ESP SYSTEM OPTIMIZADO ===")

	-- ============================================================================
	-- CONFIGURACIÓN GLOBAL
	-- ============================================================================
	_G.ESPSettings = {
		-- General
		Enabled           = false,
		SelfESP           = false,          -- ← NUEVO

		-- Box
		BoxEnabled        = false,
		BoxColor          = Color3.fromRGB(255, 255, 255),
		BoxOutlineEnabled = true,
		BoxOutlineColor   = Color3.fromRGB(0, 0, 0),
		BoxThickness      = 1,
		BoxType           = "Normal",       -- ← NUEVO: "Normal", "Corner"
		CornerSize        = 0.25,           -- ← NUEVO: porcentaje del box (0.1 - 0.5)

		-- Box Fill
		BoxFillEnabled      = false,
		BoxFillColor        = Color3.fromRGB(255, 60, 60),
		BoxFillTransparency = 0.7,

		-- Health Bar
		HealthBarEnabled   = false,
		HealthBarGradient  = true,
		HealthBarColorHigh = Color3.fromRGB(0, 255, 100),
		HealthBarColorLow  = Color3.fromRGB(255, 50, 50),

		-- Skeleton
		SkeletonEnabled      = false,
		SkeletonColor        = Color3.fromRGB(255, 255, 255),
		SkeletonOutlineColor = Color3.fromRGB(0, 0, 0),
		SkeletonThickness    = 1,

		-- Glow
		GlowEnabled      = false,
		GlowType         = "Both",          -- ← NUEVO: "Fill", "Outline", "Both"
		GlowColor        = Color3.fromRGB(0, 255, 0),
		GlowTransparency = 0.5,
		SoftESP          = false,

		-- Name
		NameEnabled        = false,
		NameColor          = Color3.fromRGB(255, 255, 255),
		NameOutline        = true,
		NameOutlineColor   = Color3.fromRGB(0, 0, 0),
		NameSize           = 13,
		NameGradient       = false,         -- ← NUEVO
		NameGradientColor1 = Color3.fromRGB(255, 100, 100),
		NameGradientColor2 = Color3.fromRGB(100, 100, 255),

		-- Distance
		DistanceEnabled = false,
		DistanceColor   = Color3.fromRGB(200, 200, 200),
		DistanceOutline = true,
		MaxDistance     = 1000,

		-- Tracers
		TracersEnabled   = false,
		TracersColor     = Color3.fromRGB(255, 255, 255),
		TracersOrigin    = "Bottom",        -- ← NUEVO combobox
		TracersThickness = 1,

		-- Visible Check
		VisibleCheck      = false,          -- ← NUEVO
		VisibleColor      = Color3.fromRGB(100, 255, 100),
		NotVisibleColor   = Color3.fromRGB(255, 100, 100),

		-- Team
		TeamCheck      = false,
		TeamColor      = Color3.fromRGB(100, 255, 100),
		EnemyColor     = Color3.fromRGB(255, 100, 100),
		UseTeamColors  = false,

		-- Sizing
		RenderDistance = 10000,
		SizingType     = "Dynamic",
		FixedSize      = Vector2.new(100, 150),
		ScaleFactor    = 1.0,

		-- Rainbow
		RainbowMode  = false,
		RainbowSpeed = 0.5,

		-- Interno
		TrackedPlayers = {},
		FOV_TanHalf    = math.tan(math.rad(Camera.FieldOfView * 0.5)),
	}

	-- ============================================================================
	-- THROTTLE — contadores de frame
	-- ============================================================================
	local frameCount = 0
	-- Skeleton  → cada 3 frames (~20fps a 60fps)
	-- Text      → cada 6 frames (~10fps) — suficiente para nombres y distancia
	-- Parts     → cada 90 frames (~1.5s) — los huesos no cambian frecuentemente
	local SKELETON_EVERY = 3
	local TEXT_EVERY     = 6
	local PARTS_EVERY    = 90

	-- ============================================================================
	-- UTILIDADES
	-- ============================================================================
	local function IsTeammate(player)
		if not _G.ESPSettings.TeamCheck then return false end
		if not player or not localPlayer then return false end
		return player.Team == localPlayer.Team
	end

	local function IsVisible(fromPos, toPos, ignoreModel)
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Blacklist
		rp.FilterDescendantsInstances = {localPlayer.Character, ignoreModel}
		rp.IgnoreWater = true
		return Workspace:Raycast(fromPos, toPos - fromPos, rp) == nil
	end

	local function FindHeadAndTorso(model)
		local head  = model:FindFirstChild("Head")
		local torso = model:FindFirstChild("Torso")
			or model:FindFirstChild("UpperTorso")
			or model:FindFirstChild("LowerTorso")
		return (head and torso) and head or nil,
		       (head and torso) and torso or nil
	end

	-- Cacheable — solo se llama cada PARTS_EVERY frames
	local function GetCharacterParts(model)
		local p = {
			Head          = model:FindFirstChild("Head"),
			UpperTorso    = model:FindFirstChild("UpperTorso"),
			LowerTorso    = model:FindFirstChild("LowerTorso"),
			LeftUpperArm  = model:FindFirstChild("LeftUpperArm"),
			LeftLowerArm  = model:FindFirstChild("LeftLowerArm"),
			LeftHand      = model:FindFirstChild("LeftHand"),
			RightUpperArm = model:FindFirstChild("RightUpperArm"),
			RightLowerArm = model:FindFirstChild("RightLowerArm"),
			RightHand     = model:FindFirstChild("RightHand"),
			LeftUpperLeg  = model:FindFirstChild("LeftUpperLeg"),
			LeftLowerLeg  = model:FindFirstChild("LeftLowerLeg"),
			LeftFoot      = model:FindFirstChild("LeftFoot"),
			RightUpperLeg = model:FindFirstChild("RightUpperLeg"),
			RightLowerLeg = model:FindFirstChild("RightLowerLeg"),
			RightFoot     = model:FindFirstChild("RightFoot"),
		}
		if not p.UpperTorso then
			p.Torso    = model:FindFirstChild("Torso")
			p.LeftArm  = model:FindFirstChild("Left Arm")
			p.RightArm = model:FindFirstChild("Right Arm")
			p.LeftLeg  = model:FindFirstChild("Left Leg")
			p.RightLeg = model:FindFirstChild("Right Leg")
		end
		return p
	end

	local function GetHealthColor(pct)
		return _G.ESPSettings.HealthBarColorLow:Lerp(_G.ESPSettings.HealthBarColorHigh, pct)
	end

	local function GetDynamicColor(isTeammate, isVisible)
		if _G.ESPSettings.UseTeamColors then
			return isTeammate and _G.ESPSettings.TeamColor or _G.ESPSettings.EnemyColor
		elseif _G.ESPSettings.VisibleCheck then
			return isVisible and _G.ESPSettings.VisibleColor or _G.ESPSettings.NotVisibleColor
		end
		return _G.ESPSettings.BoxColor
	end

	-- Helper: crea una Line reutilizable
	local function NewLine(z)
		local l = Drawing.new("Line")
		l.Visible = false
		l.ZIndex  = z or 2
		return l
	end

	local rainbowHue = 0

	-- ============================================================================
	-- CREAR ESP
	-- ============================================================================
	local function CreateESP(model)
		if _G.ESPSettings.TrackedPlayers[model] then return end

		local head, torso = FindHeadAndTorso(model)
		if not (head and torso) then return end

		local player = Players:GetPlayerFromCharacter(model)
		-- Self ESP check
		if player == localPlayer and not _G.ESPSettings.SelfESP then return end

		-- ── Box Normal ──
		local boxOutline = Drawing.new("Square")
		boxOutline.Thickness = 3; boxOutline.Filled = false
		boxOutline.Color = _G.ESPSettings.BoxOutlineColor; boxOutline.Visible = false; boxOutline.ZIndex = 1

		local box = Drawing.new("Square")
		box.Thickness = 1; box.Filled = false
		box.Color = _G.ESPSettings.BoxColor; box.Visible = false; box.ZIndex = 2

		-- ── Box Fill ──
		local boxFill = Drawing.new("Square")
		boxFill.Filled = true; boxFill.Thickness = 1
		boxFill.Color = _G.ESPSettings.BoxFillColor
		boxFill.Transparency = _G.ESPSettings.BoxFillTransparency
		boxFill.Visible = false; boxFill.ZIndex = 1

		-- ── Corner Box (8 líneas: 2 por esquina) ──
		-- Orden: TL_H, TL_V, TR_H, TR_V, BL_H, BL_V, BR_H, BR_V
		local cornerLines = {}
		for i = 1, 8 do
			local l = NewLine(2); table.insert(cornerLines, l)
		end
		local cornerOutlines = {}
		for i = 1, 8 do
			local l = NewLine(1); table.insert(cornerOutlines, l)
		end

		-- ── Health Bar ──
		local hbOutline = Drawing.new("Square")
		hbOutline.Filled = true; hbOutline.Color = Color3.fromRGB(0,0,0)
		hbOutline.Visible = false; hbOutline.ZIndex = 1

		local hb = Drawing.new("Square")
		hb.Filled = true; hb.Color = _G.ESPSettings.HealthBarColorHigh
		hb.Visible = false; hb.ZIndex = 2

		-- ── Name ──
		local nameLabel = Drawing.new("Text")
		nameLabel.Text = model.Name; nameLabel.Size = _G.ESPSettings.NameSize
		nameLabel.Center = true; nameLabel.Outline = true
		nameLabel.OutlineColor = _G.ESPSettings.NameOutlineColor
		nameLabel.Color = _G.ESPSettings.NameColor
		nameLabel.Visible = false; nameLabel.ZIndex = 3

		-- ── Distance ──
		local distLabel = Drawing.new("Text")
		distLabel.Text = "0m"; distLabel.Size = 12
		distLabel.Center = true; distLabel.Outline = true
		distLabel.OutlineColor = Color3.fromRGB(0,0,0)
		distLabel.Color = _G.ESPSettings.DistanceColor
		distLabel.Visible = false; distLabel.ZIndex = 3

		-- ── Tracer ──
		local tracer = Drawing.new("Line")
		tracer.Thickness = 1; tracer.Color = _G.ESPSettings.TracersColor
		tracer.Visible = false; tracer.ZIndex = 1

		-- ── Skeleton (principal + outline) ──
		local skelLines, skelOutlines = {}, {}
		for i = 1, 15 do
			local l  = NewLine(2); l.Color = _G.ESPSettings.SkeletonColor; table.insert(skelLines, l)
			local lo = NewLine(1); lo.Color = _G.ESPSettings.SkeletonOutlineColor; table.insert(skelOutlines, lo)
		end

		-- ── Glow ──
		local highlight = Instance.new("Highlight")
		highlight.Name               = "ESPGlow"
		highlight.Adornee            = model
		highlight.FillColor          = _G.ESPSettings.GlowColor
		highlight.OutlineColor       = _G.ESPSettings.GlowColor
		highlight.FillTransparency   = 1
		highlight.OutlineTransparency = 1
		highlight.Enabled            = false
		highlight.Parent             = model

		_G.ESPSettings.TrackedPlayers[model] = {
			-- drawings
			box = box, boxOutline = boxOutline, boxFill = boxFill,
			cornerLines = cornerLines, cornerOutlines = cornerOutlines,
			hb = hb, hbOutline = hbOutline,
			nameLabel = nameLabel, distLabel = distLabel,
			tracer = tracer,
			skelLines = skelLines, skelOutlines = skelOutlines,
			highlight = highlight,
			-- refs
			head = head, torso = torso,
			player = player,
			humanoid = model:FindFirstChildOfClass("Humanoid"),
			-- cache
			cachedParts = GetCharacterParts(model),
			partsCacheFrame = 0,
			-- estado visible check (se actualiza en throttle lento)
			isVisible = true,
		}

		model.Destroying:Connect(function()
			pcall(function()
				box:Remove(); boxOutline:Remove(); boxFill:Remove()
				for _, l in ipairs(cornerLines)   do l:Remove() end
				for _, l in ipairs(cornerOutlines) do l:Remove() end
				hb:Remove(); hbOutline:Remove()
				nameLabel:Remove(); distLabel:Remove(); tracer:Remove()
				for _, l in ipairs(skelLines)   do l:Remove() end
				for _, l in ipairs(skelOutlines) do l:Remove() end
				highlight:Destroy()
			end)
			_G.ESPSettings.TrackedPlayers[model] = nil
		end)
	end

	-- ============================================================================
	-- INICIALIZAR
	-- ============================================================================
	_G.InitializeESP = function()
		local n = 0
		for _, m in ipairs(Workspace:GetChildren()) do
			if m:IsA("Model") and m ~= localPlayer.Character then
				CreateESP(m); n = n + 1
			end
		end
		print("ESP inicializado:", n, "modelos")
	end

	Workspace.ChildAdded:Connect(function(child)
		if child:IsA("Model") then task.wait(0.1); CreateESP(child) end
	end)

	-- ============================================================================
	-- HELPER: ocultar todos los drawings de un espData
	-- ============================================================================
	local function HideAll(d)
		d.box.Visible = false; d.boxOutline.Visible = false; d.boxFill.Visible = false
		for _, l in ipairs(d.cornerLines)   do l.Visible = false end
		for _, l in ipairs(d.cornerOutlines) do l.Visible = false end
		d.hb.Visible = false; d.hbOutline.Visible = false
		d.nameLabel.Visible = false; d.distLabel.Visible = false
		d.tracer.Visible = false; d.highlight.Enabled = false
		for _, l in ipairs(d.skelLines)   do l.Visible = false end
		for _, l in ipairs(d.skelOutlines) do l.Visible = false end
	end

	-- ============================================================================
	-- HELPER: dibujar corner box
	-- ============================================================================
	local function DrawCornerBox(d, px, py, bw, bh, color, thickness)
		local cs = math.floor(math.min(bw, bh) * _G.ESPSettings.CornerSize)
		-- TL
		d.cornerLines[1].From = Vector2.new(px,      py);      d.cornerLines[1].To = Vector2.new(px+cs,   py)
		d.cornerLines[2].From = Vector2.new(px,      py);      d.cornerLines[2].To = Vector2.new(px,      py+cs)
		-- TR
		d.cornerLines[3].From = Vector2.new(px+bw,   py);      d.cornerLines[3].To = Vector2.new(px+bw-cs,py)
		d.cornerLines[4].From = Vector2.new(px+bw,   py);      d.cornerLines[4].To = Vector2.new(px+bw,   py+cs)
		-- BL
		d.cornerLines[5].From = Vector2.new(px,      py+bh);   d.cornerLines[5].To = Vector2.new(px+cs,   py+bh)
		d.cornerLines[6].From = Vector2.new(px,      py+bh);   d.cornerLines[6].To = Vector2.new(px,      py+bh-cs)
		-- BR
		d.cornerLines[7].From = Vector2.new(px+bw,   py+bh);   d.cornerLines[7].To = Vector2.new(px+bw-cs,py+bh)
		d.cornerLines[8].From = Vector2.new(px+bw,   py+bh);   d.cornerLines[8].To = Vector2.new(px+bw,   py+bh-cs)

		for _, l in ipairs(d.cornerLines) do
			l.Color = color; l.Thickness = thickness; l.Visible = true
		end
	end

	local function DrawCornerOutline(d, px, py, bw, bh, thickness)
		local cs = math.floor(math.min(bw, bh) * _G.ESPSettings.CornerSize)
		local ot = thickness + 2
		local c  = _G.ESPSettings.BoxOutlineColor

		d.cornerOutlines[1].From = Vector2.new(px-1,    py-1);     d.cornerOutlines[1].To = Vector2.new(px+cs+1,  py-1)
		d.cornerOutlines[2].From = Vector2.new(px-1,    py-1);     d.cornerOutlines[2].To = Vector2.new(px-1,     py+cs+1)
		d.cornerOutlines[3].From = Vector2.new(px+bw+1, py-1);     d.cornerOutlines[3].To = Vector2.new(px+bw-cs-1,py-1)
		d.cornerOutlines[4].From = Vector2.new(px+bw+1, py-1);     d.cornerOutlines[4].To = Vector2.new(px+bw+1,  py+cs+1)
		d.cornerOutlines[5].From = Vector2.new(px-1,    py+bh+1);  d.cornerOutlines[5].To = Vector2.new(px+cs+1,  py+bh+1)
		d.cornerOutlines[6].From = Vector2.new(px-1,    py+bh+1);  d.cornerOutlines[6].To = Vector2.new(px-1,     py+bh-cs-1)
		d.cornerOutlines[7].From = Vector2.new(px+bw+1, py+bh+1);  d.cornerOutlines[7].To = Vector2.new(px+bw-cs-1,py+bh+1)
		d.cornerOutlines[8].From = Vector2.new(px+bw+1, py+bh+1);  d.cornerOutlines[8].To = Vector2.new(px+bw+1,  py+bh-cs-1)

		for _, l in ipairs(d.cornerOutlines) do
			l.Color = c; l.Thickness = ot; l.Visible = true
		end
	end

	-- ============================================================================
	-- RENDER LOOP OPTIMIZADO
	-- ============================================================================
	RunService.RenderStepped:Connect(function(dt)
		frameCount = frameCount + 1

		local cameraPos    = Camera.CFrame.Position
		local viewportSize = Camera.ViewportSize

		if _G.ESPSettings.RainbowMode then
			rainbowHue = (rainbowHue + dt * _G.ESPSettings.RainbowSpeed) % 1
		end

		local doSkeleton = (frameCount % SKELETON_EVERY == 0)
		local doText     = (frameCount % TEXT_EVERY     == 0)

		for model, d in pairs(_G.ESPSettings.TrackedPlayers) do
			local head  = d.head
			local torso = d.torso

			if not (model and model.Parent and head and head.Parent and torso and torso.Parent) then
				HideAll(d); continue
			end

			local centerPos = (head.Position + torso.Position) * 0.5
			local distance  = (centerPos - cameraPos).Magnitude
			local maxDist   = math.min(_G.ESPSettings.MaxDistance, _G.ESPSettings.RenderDistance)

			if distance > maxDist then HideAll(d); continue end

			local isTeammate = d.player and IsTeammate(d.player)
			if isTeammate and _G.ESPSettings.TeamCheck then HideAll(d); continue end

			-- Visible check — costoso, solo en frames de skeleton
			if doSkeleton and _G.ESPSettings.VisibleCheck then
				d.isVisible = IsVisible(cameraPos, centerPos, model)
			end

			local screenPos, onScreen = Camera:WorldToViewportPoint(centerPos)

			if not (onScreen and screenPos.Z > 0) then HideAll(d); continue end

			local dynamicColor = GetDynamicColor(isTeammate, d.isVisible)
			if _G.ESPSettings.RainbowMode then
				dynamicColor = Color3.fromHSV(rainbowHue, 1, 1)
			end

			-- ── Calcular dimensiones del box ──
			local bw, bh, px, py
			local needBox = _G.ESPSettings.BoxEnabled
				or _G.ESPSettings.BoxFillEnabled
				or _G.ESPSettings.HealthBarEnabled
				or _G.ESPSettings.DistanceEnabled
				or _G.ESPSettings.NameEnabled

			if needBox then
				if _G.ESPSettings.SizingType == "Fixed" then
					bw = _G.ESPSettings.FixedSize.X
					bh = _G.ESPSettings.FixedSize.Y
				elseif _G.ESPSettings.SizingType == "Scaled" then
					local s = (1000 / distance) * (_G.ESPSettings.ScaleFactor or 1)
					bw = math.clamp(math.floor(4.5 * s), 10, 300)
					bh = math.clamp(math.floor(6   * s), 14, 400)
				else
					local s = 1000 / (distance * _G.ESPSettings.FOV_TanHalf * 2)
					bw = math.clamp(math.floor(4.5 * s), 10, 300)
					bh = math.clamp(math.floor(6   * s), 14, 400)
				end
				px = math.floor(screenPos.X - bw * 0.5)
				py = math.floor(screenPos.Y - bh * 0.5)
			end

			-- ══════════════════════════════════════════
			-- BOX / CORNER BOX
			-- ══════════════════════════════════════════
			if _G.ESPSettings.BoxEnabled and bw then
				local boxType = _G.ESPSettings.BoxType

				if boxType == "Corner" then
					-- ocultar square box
					d.box.Visible = false; d.boxOutline.Visible = false
					-- outline corners
					if _G.ESPSettings.BoxOutlineEnabled then
						DrawCornerOutline(d, px, py, bw, bh, _G.ESPSettings.BoxThickness)
					else
						for _, l in ipairs(d.cornerOutlines) do l.Visible = false end
					end
					DrawCornerBox(d, px, py, bw, bh, dynamicColor, _G.ESPSettings.BoxThickness)
				else -- Normal
					for _, l in ipairs(d.cornerLines)   do l.Visible = false end
					for _, l in ipairs(d.cornerOutlines) do l.Visible = false end
					if _G.ESPSettings.BoxOutlineEnabled then
						d.boxOutline.Size     = Vector2.new(bw, bh)
						d.boxOutline.Position = Vector2.new(px, py)
						d.boxOutline.Color    = _G.ESPSettings.BoxOutlineColor
						d.boxOutline.Visible  = true
					else
						d.boxOutline.Visible = false
					end
					d.box.Size      = Vector2.new(bw, bh)
					d.box.Position  = Vector2.new(px, py)
					d.box.Color     = dynamicColor
					d.box.Thickness = _G.ESPSettings.BoxThickness
					d.box.Visible   = true
				end
			else
				d.box.Visible = false; d.boxOutline.Visible = false
				for _, l in ipairs(d.cornerLines)   do l.Visible = false end
				for _, l in ipairs(d.cornerOutlines) do l.Visible = false end
			end

			-- ══════════════════════════════════════════
			-- BOX FILL
			-- ══════════════════════════════════════════
			if _G.ESPSettings.BoxFillEnabled and bw then
				d.boxFill.Size         = Vector2.new(bw, bh)
				d.boxFill.Position     = Vector2.new(px, py)
				d.boxFill.Color        = _G.ESPSettings.BoxFillColor
				d.boxFill.Transparency = _G.ESPSettings.BoxFillTransparency
				d.boxFill.Visible      = true
			else
				d.boxFill.Visible = false
			end

			-- ══════════════════════════════════════════
			-- HEALTH BAR
			-- ══════════════════════════════════════════
			if _G.ESPSettings.HealthBarEnabled and d.humanoid and bw then
				local pct = math.clamp(d.humanoid.Health / math.max(d.humanoid.MaxHealth, 1), 0, 1)
				local barW = 4
				local barX = px - barW - 2
				local fillH = math.floor(bh * pct)

				d.hbOutline.Size     = Vector2.new(barW, bh)
				d.hbOutline.Position = Vector2.new(barX, py)
				d.hbOutline.Visible  = true

				d.hb.Size     = Vector2.new(barW - 2, fillH)
				d.hb.Position = Vector2.new(barX + 1, py + bh - fillH)
				d.hb.Color    = GetHealthColor(pct)
				d.hb.Visible  = true
			else
				d.hb.Visible = false; d.hbOutline.Visible = false
			end

			-- ══════════════════════════════════════════
			-- NAME  (throttled a ~10fps)
			-- ══════════════════════════════════════════
			if _G.ESPSettings.NameEnabled then
				if doText then
					local namePosY = py and (py - 16) or (screenPos.Y - 30)
					d.nameLabel.Position     = Vector2.new(screenPos.X, namePosY)
					d.nameLabel.Size         = _G.ESPSettings.NameSize
					d.nameLabel.Outline      = _G.ESPSettings.NameOutline
					d.nameLabel.OutlineColor = _G.ESPSettings.NameOutlineColor

					if _G.ESPSettings.NameGradient then
						local t = ((frameCount * 0.01) + screenPos.X * 0.003) % 1
						d.nameLabel.Color = _G.ESPSettings.NameGradientColor1:Lerp(
							_G.ESPSettings.NameGradientColor2, t
						)
					else
						d.nameLabel.Color = _G.ESPSettings.NameColor
					end
				end
				d.nameLabel.Visible = true
			else
				d.nameLabel.Visible = false
			end

			-- ══════════════════════════════════════════
			-- DISTANCE  (throttled a ~10fps)
			-- ══════════════════════════════════════════
			if _G.ESPSettings.DistanceEnabled then
				if doText then
					local labelY = (py and bh) and (py + bh + 2) or (screenPos.Y + 16)
					d.distLabel.Text     = math.floor(distance) .. "m"
					d.distLabel.Position = Vector2.new(screenPos.X, labelY)
					d.distLabel.Color    = _G.ESPSettings.DistanceColor
					d.distLabel.Outline  = _G.ESPSettings.DistanceOutline
				end
				d.distLabel.Visible = true
			else
				d.distLabel.Visible = false
			end

			-- ══════════════════════════════════════════
			-- TRACER
			-- ══════════════════════════════════════════
			if _G.ESPSettings.TracersEnabled then
				local o = _G.ESPSettings.TracersOrigin
				local fp
				if     o == "Top"         then fp = Vector2.new(viewportSize.X/2, 0)
				elseif o == "Center"      then fp = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
				elseif o == "Bottom"      then fp = Vector2.new(viewportSize.X/2, viewportSize.Y)
				elseif o == "Top-Left"    then fp = Vector2.new(0, 0)
				elseif o == "Top-Right"   then fp = Vector2.new(viewportSize.X, 0)
				elseif o == "Bottom-Left" then fp = Vector2.new(0, viewportSize.Y)
				elseif o == "Bottom-Right"then fp = Vector2.new(viewportSize.X, viewportSize.Y)
				else                           fp = Vector2.new(viewportSize.X/2, viewportSize.Y)
				end
				d.tracer.From      = fp
				d.tracer.To        = Vector2.new(screenPos.X, screenPos.Y)
				d.tracer.Color     = _G.ESPSettings.TracersColor
				d.tracer.Thickness = _G.ESPSettings.TracersThickness
				d.tracer.Visible   = true
			else
				d.tracer.Visible = false
			end

			-- ══════════════════════════════════════════
			-- SKELETON  (throttled a ~20fps)
			-- ══════════════════════════════════════════
			if _G.ESPSettings.SkeletonEnabled and doSkeleton then
				-- Refrescar partes cacheadas cada ~1.5s
				if (frameCount - (d.partsCacheFrame or 0)) >= PARTS_EVERY then
					d.cachedParts    = GetCharacterParts(model)
					d.partsCacheFrame = frameCount
				end
				local parts = d.cachedParts
				local li    = 1

				local function drawBone(p1, p2)
					if not (p1 and p2 and p1.Parent and p2.Parent) then return end
					if li > #d.skelLines then return end
					local s1, v1 = Camera:WorldToViewportPoint(p1.Position)
					local s2, v2 = Camera:WorldToViewportPoint(p2.Position)
					if v1 and v2 then
						local a, b = Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y)
						-- outline
						d.skelOutlines[li].From      = a; d.skelOutlines[li].To        = b
						d.skelOutlines[li].Color     = _G.ESPSettings.SkeletonOutlineColor
						d.skelOutlines[li].Thickness = _G.ESPSettings.SkeletonThickness + 2
						d.skelOutlines[li].Visible   = true
						-- principal
						d.skelLines[li].From      = a; d.skelLines[li].To        = b
						d.skelLines[li].Color     = _G.ESPSettings.SkeletonColor
						d.skelLines[li].Thickness = _G.ESPSettings.SkeletonThickness
						d.skelLines[li].Visible   = true
						li = li + 1
					end
				end

				if parts.UpperTorso then
					drawBone(parts.Head,          parts.UpperTorso)
					drawBone(parts.UpperTorso,    parts.LowerTorso)
					drawBone(parts.UpperTorso,    parts.RightUpperArm)
					drawBone(parts.RightUpperArm, parts.RightLowerArm)
					drawBone(parts.RightLowerArm, parts.RightHand)
					drawBone(parts.UpperTorso,    parts.LeftUpperArm)
					drawBone(parts.LeftUpperArm,  parts.LeftLowerArm)
					drawBone(parts.LeftLowerArm,  parts.LeftHand)
					drawBone(parts.LowerTorso,    parts.RightUpperLeg)
					drawBone(parts.RightUpperLeg, parts.RightLowerLeg)
					drawBone(parts.RightLowerLeg, parts.RightFoot)
					drawBone(parts.LowerTorso,    parts.LeftUpperLeg)
					drawBone(parts.LeftUpperLeg,  parts.LeftLowerLeg)
					drawBone(parts.LeftLowerLeg,  parts.LeftFoot)
				elseif parts.Torso then
					drawBone(parts.Head,   parts.Torso)
					drawBone(parts.Torso,  parts.RightArm)
					drawBone(parts.Torso,  parts.LeftArm)
					drawBone(parts.Torso,  parts.RightLeg)
					drawBone(parts.Torso,  parts.LeftLeg)
				end

				for i = li, #d.skelLines do
					d.skelLines[i].Visible    = false
					d.skelOutlines[i].Visible = false
				end

			elseif not _G.ESPSettings.SkeletonEnabled then
				for _, l in ipairs(d.skelLines)    do l.Visible = false end
				for _, l in ipairs(d.skelOutlines) do l.Visible = false end
			end

			-- ══════════════════════════════════════════
			-- GLOW (tipos)
			-- ══════════════════════════════════════════
			if _G.ESPSettings.GlowEnabled then
				local gType  = _G.ESPSettings.GlowType
				local fillT  = 1 - _G.ESPSettings.GlowTransparency
				local softFill = _G.ESPSettings.SoftESP and math.max(0, fillT - 0.3) or fillT
				local outT   = _G.ESPSettings.SoftESP and 0.7 or 0

				d.highlight.FillColor    = _G.ESPSettings.GlowColor
				d.highlight.OutlineColor = _G.ESPSettings.GlowColor

				if gType == "Fill" then
					d.highlight.FillTransparency    = softFill
					d.highlight.OutlineTransparency = 1   -- outline invisible
				elseif gType == "Outline" then
					d.highlight.FillTransparency    = 1   -- fill invisible
					d.highlight.OutlineTransparency = outT
				else -- Both
					d.highlight.FillTransparency    = softFill
					d.highlight.OutlineTransparency = outT
				end
				d.highlight.Enabled = true
			else
				d.highlight.Enabled = false
			end
		end
	end)

	print("=== ESP SYSTEM OPTIMIZADO CARGADO ===")
end