-- ============================================================================
-- MAIN SCRIPT
-- ============================================================================

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rollyzx/TS/refs/heads/main/GUI_Core.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rollyzx/TS/refs/heads/main/ESP.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rollyzx/TS/refs/heads/main/Radar.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Rollyzx/TS/refs/heads/main/SafeESP.lua"))()

	local window = library:CreateWindow({})
	--
	local rage = window:CreatePage({Icon = "rbxassetid://8547236654"})
	local antiaim = window:CreatePage({Icon = "rbxassetid://8547310764"})
	local aimbot = window:CreatePage({Icon = "rbxassetid://8547249956"})
	local visuals = window:CreatePage({Icon = "rbxassetid://8547254518"})
	local setting = window:CreatePage({Icon = "rbxassetid://8547256547"})
	local skins = window:CreatePage({Icon = "rbxassetid://8547258459"})
	local config = window:CreatePage({Icon = "rbxassetid://8547269749"})
	
	--
	local otheresp = visuals:CreateSection({Name = "Other ESP", Size = 200, Side = "Right"})
	local settingsSection = setting:CreateSection({Name = "Appearance", Size = 200, Side = "Left"})

		-- ============================================================================
	-- PLAYER ESP CONTROLS
	-- ============================================================================

-- ============================================================================
-- PLAYER ESP CONTROLS
-- ============================================================================
-- ============================================================================
-- EJEMPLO DE USO - SISTEMA DE SUBTABS
-- ============================================================================

-- Crear la sección principal
local espSection = visuals:CreateSection({
    Name = "ESP System", 
    Size = 450, 
    Side = "Left"
})

-- Crear las subtabs dentro de la sección
espSection:CreateSubtabs({
    Tabs = {"Player ESP", "Object ESP", "World ESP"}
})

-- IMPORTANTE: Después de crear las subtabs, todos los controles se añaden normalmente
-- El sistema automáticamente los coloca en la subtab actual

-- ============================================================================
-- SUBTAB 1: PLAYER ESP
-- ============================================================================

espSection:CreateToggle({
    Name = "Enable ESP",
    State = false,
    Callback = function(enabled)
        if enabled then
            _G.InitializeESP()
        else
            -- Desactivar ESP
        end
    end
})

espSection:CreateToggle({
    Name = "Box ESP",
    State = false,
    Callback = function(enabled)
        _G.ESPSettings.BoxEnabled = enabled
    end,
    Colorpickers = {
        {
            State = Color3.fromRGB(255, 255, 255),
            Callback = function(color)
                _G.ESPSettings.BoxColor = color
            end
        }
    }
})

espSection:CreateSlider({
    Name = "Box Thickness",
    State = 1,
    Min = 1,
    Max = 5,
    Decimals = 1,
    Callback = function(value)
        _G.ESPSettings.BoxThickness = value
    end
})

espSection:CreateToggle({
    Name = "Health Bar",
    State = false,
    Callback = function(enabled)
        _G.ESPSettings.HealthBarEnabled = enabled
    end
})

espSection:CreateToggle({
    Name = "Skeleton",
    State = false,
    Callback = function(enabled)
        _G.ESPSettings.SkeletonEnabled = enabled
    end
})

-- ============================================================================
-- CAMBIAR A SUBTAB 2: OBJECT ESP
-- ============================================================================

espSection:SwitchSubtab(2) -- Cambiar a "Object ESP"

espSection:CreateToggle({
    Name = "Show Items",
    State = false,
    Callback = function(enabled)
        print("Show items:", enabled)
    end
})

espSection:CreateToggle({
    Name = "Show Weapons",
    State = false,
    Callback = function(enabled)
        print("Show weapons:", enabled)
    end,
    Colorpickers = {
        {
            State = Color3.fromRGB(255, 200, 0),
            Callback = function(color)
                print("Weapon color:", color)
            end
        }
    }
})

espSection:CreateDropdown({
    Name = "Item Filter",
    State = 1,
    Options = {"All Items", "Weapons Only", "Consumables Only", "Important Only"},
    Callback = function(index)
        print("Filter changed to:", index)
    end
})

espSection:CreateSlider({
    Name = "Max Distance",
    State = 500,
    Min = 100,
    Max = 2000,
    Suffix = " studs",
    Callback = function(value)
        print("Max distance:", value)
    end
})

-- ============================================================================
-- CAMBIAR A SUBTAB 3: WORLD ESP
-- ============================================================================

espSection:SwitchSubtab(3) -- Cambiar a "World ESP"

espSection:CreateToggle({
    Name = "Show Objectives",
    State = false,
    Callback = function(enabled)
        print("Show objectives:", enabled)
    end
})

espSection:CreateToggle({
    Name = "Show Doors",
    State = false,
    Callback = function(enabled)
        print("Show doors:", enabled)
    end
})

espSection:CreateToggle({
    Name = "Show Vehicles",
    State = false,
    Callback = function(enabled)
        print("Show vehicles:", enabled)
    end,
    Colorpickers = {
        {
            State = Color3.fromRGB(100, 150, 255),
            Callback = function(color)
                print("Vehicle color:", color)
            end
        }
    }
})

espSection:CreateColorpicker({
    Name = "Objective Color",
    State = Color3.fromRGB(255, 255, 0),
    Callback = function(color)
        print("Objective color:", color)
    end
})

-- ============================================================================
-- VOLVER A LA PRIMERA SUBTAB
-- ============================================================================

espSection:SwitchSubtab(1) -- Volver a "Player ESP"

-- Los controles añadidos después seguirán yendo a Player ESP
espSection:CreateToggle({
    Name = "Show Distance",
    State = false,
    Callback = function(enabled)
        _G.ESPSettings.DistanceEnabled = enabled
    end
})

-- ============================================================================
-- EJEMPLO ADICIONAL: OTRA SECCIÓN CON SUBTABS
-- ============================================================================

local aimbotSection = aimbot:CreateSection({
    Name = "Aimbot Settings",
    Size = 400,
    Side = "Left"
})

aimbotSection:CreateSubtabs({
    Tabs = {"Targeting", "Smoothing", "FOV", "Prediction"}
})

-- Subtab 1: Targeting
aimbotSection:CreateToggle({
    Name = "Enable Aimbot",
    State = false,
    Callback = function(enabled)
        print("Aimbot:", enabled)
    end
})

aimbotSection:CreateDropdown({
    Name = "Target Part",
    State = 1,
    Options = {"Head", "Torso", "Closest"},
    Callback = function(index)
        print("Target part:", index)
    end
})

-- Cambiar a Smoothing
aimbotSection:SwitchSubtab(2)

aimbotSection:CreateSlider({
    Name = "Smoothness",
    State = 5,
    Min = 1,
    Max = 20,
    Decimals = 1,
    Callback = function(value)
        print("Smoothness:", value)
    end
})

aimbotSection:CreateToggle({
    Name = "Smooth X",
    State = true,
    Callback = function(enabled)
        print("Smooth X:", enabled)
    end
})

aimbotSection:CreateToggle({
    Name = "Smooth Y",
    State = true,
    Callback = function(enabled)
        print("Smooth Y:", enabled)
    end
})

-- Cambiar a FOV
aimbotSection:SwitchSubtab(3)

aimbotSection:CreateSlider({
    Name = "FOV Size",
    State = 100,
    Min = 50,
    Max = 500,
    Callback = function(value)
        print("FOV Size:", value)
    end
})

aimbotSection:CreateToggle({
    Name = "Show FOV Circle",
    State = true,
    Callback = function(enabled)
        print("Show FOV:", enabled)
    end,
    Colorpickers = {
        {
            State = Color3.fromRGB(255, 255, 255),
            Callback = function(color)
                print("FOV Color:", color)
            end
        }
    }
})

-- Cambiar a Prediction
aimbotSection:SwitchSubtab(4)

aimbotSection:CreateToggle({
    Name = "Enable Prediction",
    State = false,
    Callback = function(enabled)
        print("Prediction:", enabled)
    end
})

aimbotSection:CreateSlider({
    Name = "Prediction Amount",
    State = 0.15,
    Min = 0,
    Max = 1,
    Decimals = 2,
    Callback = function(value)
        print("Prediction:", value)
    end
})

-- ============================================================================
-- FUNCIONES ÚTILES
-- ============================================================================

-- Obtener la subtab actual
print("Subtab actual de espSection:", espSection.CurrentSubtab)

-- Verificar si una sección tiene subtabs
print("espSection tiene subtabs:", espSection.HasSubtabs)

-- Obtener nombre de subtab actual
if espSection.HasSubtabs then
    local currentTab = espSection.Subtabs[espSection.CurrentSubtab]
    print("Nombre de subtab actual:", currentTab.Name)
end

-- Cambiar subtab programáticamente
task.wait(5)
espSection:SwitchSubtab(2) -- Cambiar a Object ESP después de 5 segundos

-- ============================================================================
-- TIPS IMPORTANTES
-- ============================================================================

--[[
1. Las subtabs deben crearse ANTES de añadir controles
2. SwitchSubtab() cambia la subtab activa - los controles añadidos después irán a esa subtab
3. Todos los controles (Toggle, Slider, Dropdown, etc.) funcionan normalmente
4. Los colorpickers integrados en toggles también funcionan
5. El scroll se resetea automáticamente al cambiar de subtab
6. El diseño se adapta automáticamente al tema activo
7. Puedes tener múltiples secciones con subtabs en la misma página
8. No hay límite en el número de subtabs (pero se recomienda 3-5 para buena UX)
]]

	--
--colored models
	--
-- Toggle principal del radar en otheresp
otheresp:CreateToggle({
	Name = "Radar",
	State = false,
	Callback = function(enabled)
		if enabled and not _G.RadarSettings.Initialized then
			_G.InitializeRadar()
			_G.RadarSettings.Initialized = true
		end
		_G.RadarSettings:SetEnabled(enabled)
	end
})

-- Crear sección SEPARADA para configuración del radar
-- IMPORTANTE: Cambiar Side a "Right" para evitar conflictos con Appearance
local radarConfig = visuals:CreateSection({
	Name = "Radar Config",  -- Nombre diferente
	Size = 420,             -- Tamaño ajustado
	Side = "Left"          -- Lado DERECHO para evitar conflictos
})

-- ========== CONTROLES BÁSICOS ==========
radarConfig:CreateDropdown({
	Name = "Shape",
	State = 1,
	Options = {"Circle", "Square"},
	Callback = function(index)
		local shapes = {"Circle", "Square"}
		_G.RadarSettings:SetShape(shapes[index])
	end
})

radarConfig:CreateSlider({
	Name = "Size",
	State = 200,
	Min = 100,
	Max = 400,
	Decimals = 1,
	Callback = function(value)
		_G.RadarSettings:SetSize(value)
	end
})

radarConfig:CreateSlider({
	Name = "Range",
	State = 500,
	Min = 100,
	Max = 2000,
	Decimals = 1,
	Suffix = " studs",
	Callback = function(value)
		_G.RadarSettings:SetRange(value)
	end
})

-- ========== TOGGLES ==========
radarConfig:CreateToggle({
	Name = "Rotate With Camera",
	State = true,
	Callback = function(enabled)
		_G.RadarSettings.RotateWithCamera = enabled
	end
})

radarConfig:CreateToggle({
	Name = "Show Grid",
	State = true,
	Callback = function(enabled)
		_G.RadarSettings.GridEnabled = enabled
	end
})

radarConfig:CreateToggle({
	Name = "Show North",
	State = true,
	Callback = function(enabled)
		_G.RadarSettings.ShowNorthIndicator = enabled
	end
})

radarConfig:CreateToggle({
	Name = "Show Names",
	State = true,
	Callback = function(enabled)
		_G.RadarSettings.ShowPlayerNames = enabled
	end
})

radarConfig:CreateToggle({
	Name = "Pulse Effect",
	State = false,
	Callback = function(enabled)
		_G.RadarSettings.PulseEffect = enabled
	end
})

radarConfig:CreateToggle({
	Name = "Fade Edges",
	State = true,
	Callback = function(enabled)
		_G.RadarSettings.FadeEdges = enabled
	end
})

radarConfig:CreateToggle({
	Name = "Team Check",
	State = false,
	Callback = function(enabled)
		_G.RadarSettings.TeamCheck = enabled
	end
})

-- ========== OPCIONES DE PUNTOS ==========
radarConfig:CreateDropdown({
	Name = "Dot Shape",
	State = 1,
	Options = {"Circle", "Square", "Triangle", "Diamond"},
	Callback = function(index)
		local shapes = {"Circle", "Square", "Triangle", "Diamond"}
		_G.RadarSettings.PlayerDotShape = shapes[index]
		-- Limpiar blips existentes
		for _, blip in pairs(playerBlips or {}) do
			pcall(function() blip.Container:Destroy() end)
		end
		playerBlips = {}
	end
})

radarConfig:CreateSlider({
	Name = "Dot Size",
	State = 8,
	Min = 4,
	Max = 20,
	Decimals = 1,
	Callback = function(value)
		_G.RadarSettings.PlayerDotSize = value
	end
})

-- ========== COLORES (SIN COLORPICKERS INTEGRADOS) ==========
-- Nota: Los colorpickers integrados en toggles causan problemas
-- Por eso usamos colorpickers separados

radarConfig:CreateColorpicker({
	Name = "Background",
	State = Color3.fromRGB(20, 20, 25),
	Callback = function(color)
		_G.RadarSettings.BackgroundColor = color
		if radarFrame then
			radarFrame.BackgroundColor3 = color
		end
	end
})

radarConfig:CreateColorpicker({
	Name = "Local Player",
	State = Color3.fromRGB(100, 255, 100),
	Callback = function(color)
		_G.RadarSettings.LocalPlayerColor = color
	end
})

radarConfig:CreateColorpicker({
	Name = "Enemy",
	State = Color3.fromRGB(255, 100, 100),
	Callback = function(color)
		_G.RadarSettings.EnemyColor = color
	end
})

radarConfig:CreateColorpicker({
	Name = "Teammate",
	State = Color3.fromRGB(100, 150, 255),
	Callback = function(color)
		_G.RadarSettings.TeammateColor = color
	end
})

radarConfig:CreateSlider({
	Name = "BG Transparency",
	State = 0.3,
	Min = 0,
	Max = 1,
	Decimals = 2,
	Callback = function(value)
		_G.RadarSettings.BackgroundTransparency = value
		if radarFrame then
			radarFrame.BackgroundTransparency = value
		end
	end
})

	--
--effects

    -- == Keybinds debug & fallback (pegar tras crear 'config' y las otras secciones) ==
    local ToggleKey = Enum.KeyCode.Z
    local CloseKey  = Enum.KeyCode.X

    local keySection = config:CreateSection({Name = "Keybinds", Size = 200, Side = "Left"})

-- función que maneja la selección y actualiza ToggleKey
local function handleToggleSelection(selection)
    print("[Keybind DEBUG] toggle selection:", selection and selection[1], selection and selection[2])
    if selection and selection[1] == "KeyCode" and selection[2] then
        ToggleKey = Enum.KeyCode[selection[2]]
        print("[Keybind DEBUG] ToggleKey ahora:", ToggleKey.Name)
        if window then
            window.Key = ToggleKey    -- <- sincroniza con la librería
            print("[Keybind DEBUG] window.Key actualizado a:", window.Key.Name)
        end
    end
end


-- función que maneja la selección para cierre total
local function handleCloseSelection(selection)
    print("[Keybind DEBUG] close selection:", selection and selection[1], selection and selection[2])
    if selection and selection[1] == "KeyCode" and selection[2] then
        CloseKey = Enum.KeyCode[selection[2]]
        print("[Keybind DEBUG] CloseKey ahora:", CloseKey.Name)
        if window then
            window.CloseKey = CloseKey -- <- sincroniza con la librería
            print("[Keybind DEBUG] window.CloseKey actualizado a:", window.CloseKey.Name)
        end
    end
end


-- función auxiliar para restaurar/forzar la GUI visible después del bind
local function reopenWindowIfClosed()
    -- si la librería expone window.Enabled / window:Fade, lo usamos
    if window then
        -- fuerza a visible para que no quede cerrada por el press de bind
        window.Enabled = true
        if window.Fade then
            pcall(function() window:Fade(true) end)
        end
    end
end

-- Toggle GUI keybind (corregido)
keySection:CreateKeybind({
    Name = "Toggle GUI",
    State = {"KeyCode", ToggleKey.Name},
    Mode = "Toggle",
    callback = function(selection)
        if selection and selection[1] == "KeyCode" and selection[2] then
            -- actualiza variable local y sincroniza con la ventana
            ToggleKey = Enum.KeyCode[selection[2]]
            if window then window.Key = ToggleKey end

            -- reabre la ventana si estaba cerrada (si tienes esa función)
            if reopenWindowIfClosed then reopenWindowIfClosed() end

            -- evita el "rebote" que estaba cerrando la GUI inmediatamente
            justBound = true
            task.delay(0.18, function()
                justBound = false
            end)
        end
    end
})


-- Close GUI keybind (corregido)
keySection:CreateKeybind({
    Name = "Close GUI",
    State = {"KeyCode", CloseKey.Name},
    Mode = "Toggle",
    callback = function(selection)
        if selection and selection[1] == "KeyCode" and selection[2] then
            CloseKey = Enum.KeyCode[selection[2]]
            if window then window.CloseKey = CloseKey end

            if reopenWindowIfClosed then reopenWindowIfClosed() end

            justBound = true
            task.delay(0.18, function()
                justBound = false
            end)
        end
    end
})



-- crea la sección igual:
-- crea la sección de apariencia (usa la página 'setting' que ya existe)
local settingsSection = setting:CreateSection({Name = "Appearance", Size = 200, Side = "Left"})

-- lista fija de temas (coincide con Config.Themes)
local themeOptions = {"Dark","Light","Aqua","Sunset","Forest","Custom"}
-- calcular índice por defecto según Config.ThemeName
local defaultIndex = 1
for i,name in ipairs(themeOptions) do
    if name == (Config.ThemeName or "Dark") then defaultIndex = i break end
end

-- Dropdown: **use State (índice)** y el callback recibe índice
settingsSection:CreateDropdown({
    Name = "Theme",
    State = defaultIndex,
    Options = themeOptions,
    Callback = function(index)
        local sel = themeOptions[index] or "Dark"
        Config.ThemeName = sel
        local theme = (sel == "Custom") and Config.Custom or (Config.Themes and Config.Themes[sel]) or Config.Custom
        -- 'window' debe ser la variable que contiene la Window devuelta por CreateWindow
        applyTheme(window, theme)
    end
})
-- ===== TOPBAR: conectar controles de UI a la topbar integrada en la librería =====
window.Topbar:BindSettings(settingsSection)