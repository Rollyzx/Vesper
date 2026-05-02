-- ============================================================
--  ESP_GUI.lua  |  LocalScript  →  StarterPlayerScripts
--  GUI de ESP con panel de previsualización en tiempo real
-- ============================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ──────────────────────────────────────────────
-- ESTADO DEL ESP
-- ──────────────────────────────────────────────
local espConfig = {
    BoundingBox = true,
    Skeleton    = true,
    HealthBar   = true,
    Name        = true,
    WeaponText  = false,
    Distance    = false,
}

local ACCENT   = Color3.fromRGB(0, 210, 80)
local BG_DARK  = Color3.fromRGB(18, 18, 18)
local BG_MED   = Color3.fromRGB(28, 28, 28)
local BG_LIGHT = Color3.fromRGB(38, 38, 38)
local TEXT_W   = Color3.fromRGB(230, 230, 230)
local TEXT_G   = Color3.fromRGB(150, 150, 150)
local RED_HP   = Color3.fromRGB(220, 50, 50)
local GREEN_HP = Color3.fromRGB(50, 200, 80)

-- ──────────────────────────────────────────────
-- CONSTRUCCIÓN DE LA GUI
-- ──────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name         = "ESP_GUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Ventana principal
local mainFrame = Instance.new("Frame")
mainFrame.Size            = UDim2.new(0, 500, 0, 370)
mainFrame.Position        = UDim2.new(0.5, -250, 0.5, -185)
mainFrame.BackgroundColor3 = BG_DARK
mainFrame.BorderSizePixel = 0
mainFrame.Parent          = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Size              = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3  = BG_MED
titleBar.BorderSizePixel   = 0
titleBar.Parent            = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size              = UDim2.new(1, -10, 1, 0)
titleLabel.Position          = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text              = "Extra Senses (ESP)"
titleLabel.TextColor3        = ACCENT
titleLabel.Font              = Enum.Font.GothamBold
titleLabel.TextSize          = 14
titleLabel.TextXAlignment     = Enum.TextXAlignment.Left
titleLabel.Parent            = titleBar

-- Botón cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size              = UDim2.new(0, 28, 0, 24)
closeBtn.Position          = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3  = Color3.fromRGB(180, 40, 40)
closeBtn.Text              = "✕"
closeBtn.TextColor3        = Color3.new(1,1,1)
closeBtn.Font              = Enum.Font.GothamBold
closeBtn.TextSize          = 12
closeBtn.BorderSizePixel   = 0
closeBtn.Parent            = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Drag logic
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos  = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ──────────────────────────────────────────────
-- PANEL IZQUIERDO: opciones
-- ──────────────────────────────────────────────
local leftPanel = Instance.new("Frame")
leftPanel.Size             = UDim2.new(0, 210, 1, -40)
leftPanel.Position         = UDim2.new(0, 8, 0, 38)
leftPanel.BackgroundColor3 = BG_MED
leftPanel.BorderSizePixel  = 0
leftPanel.Parent           = mainFrame
Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding         = UDim.new(0, 4)
listLayout.FillDirection   = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.Parent          = leftPanel

Instance.new("UIPadding", leftPanel).PaddingLeft = UDim.new(0, 8)

-- ──────────────────────────────────────────────
-- PANEL DERECHO: previsualización
-- ──────────────────────────────────────────────
local previewPanel = Instance.new("Frame")
previewPanel.Size             = UDim2.new(1, -230, 1, -40)
previewPanel.Position         = UDim2.new(0, 226, 0, 38)
previewPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
previewPanel.BorderSizePixel  = 0
previewPanel.Parent           = mainFrame
Instance.new("UICorner", previewPanel).CornerRadius = UDim.new(0, 6)

-- Borde verde izquierdo (estilo CS)
local greenBorder = Instance.new("Frame")
greenBorder.Size              = UDim2.new(0, 3, 1, 0)
greenBorder.BackgroundColor3  = ACCENT
greenBorder.BorderSizePixel   = 0
greenBorder.Parent            = previewPanel

-- Label "PREVIEW"
local previewTitle = Instance.new("TextLabel")
previewTitle.Size              = UDim2.new(1, 0, 0, 20)
previewTitle.Position          = UDim2.new(0, 0, 0, 2)
previewTitle.BackgroundTransparency = 1
previewTitle.Text              = "Preview"
previewTitle.TextColor3        = Color3.new(1,1,1)
previewTitle.Font              = Enum.Font.GothamBold
previewTitle.TextSize          = 12
previewTitle.TextXAlignment    = Enum.TextXAlignment.Center
previewTitle.Parent            = previewPanel

-- Canvas donde se dibuja el preview
local canvas = Instance.new("Frame")
canvas.Size              = UDim2.new(1, -16, 1, -28)
canvas.Position          = UDim2.new(0, 8, 0, 24)
canvas.BackgroundTransparency = 1
canvas.ClipsDescendants  = true
canvas.Parent            = previewPanel

-- ──────────────────────────────────────────────
-- ELEMENTOS DEL PREVIEW (dibujo con Frames y Lines)
-- ──────────────────────────────────────────────

-- Función helper: crea un "frame línea" entre dos puntos UDim2
local function makeLine(parent, x1, y1, x2, y2, color, thick)
    thick = thick or 2
    local dx = x2 - x1
    local dy = y2 - y1
    local len = math.sqrt(dx*dx + dy*dy)
    local angle = math.atan2(dy, dx)

    local line = Instance.new("Frame")
    line.AnchorPoint       = Vector2.new(0, 0.5)
    line.Position          = UDim2.new(0, x1, 0, y1)
    line.Size              = UDim2.new(0, len, 0, thick)
    line.Rotation          = math.deg(angle)
    line.BackgroundColor3  = color or Color3.new(1,1,1)
    line.BorderSizePixel   = 0
    line.Parent            = parent
    return line
end

-- Puntos del esqueleto (coordenadas absolutas dentro del canvas ~256x300)
-- Cabeza, cuello, hombros, codos, muñecas, cadera, rodillas, pies
local skelPoints = {
    head     = {128, 40},
    neck     = {128, 65},
    lshoulder= {100, 75},  rshoulder= {156, 75},
    lelbow   = {82,  110}, relbow   = {174, 110},
    lwrist   = {68,  145}, rwrist   = {188, 145},
    lhip     = {110, 150}, rhip     = {146, 150},
    lknee    = {104, 195}, rknee    = {152, 195},
    lfoot    = {98,  240}, rfoot    = {158, 240},
}

local skelLines = {}
local WHITE = Color3.new(1, 1, 1)

local function buildSkeleton()
    local pairs_ = {
        {"head","neck"},
        {"neck","lshoulder"}, {"neck","rshoulder"},
        {"lshoulder","lelbow"}, {"lelbow","lwrist"},
        {"rshoulder","relbow"}, {"relbow","rwrist"},
        {"neck","lhip"},       {"neck","rhip"},
        {"lhip","rhip"},
        {"lhip","lknee"},      {"lknee","lfoot"},
        {"rhip","rknee"},      {"rknee","rfoot"},
    }
    for _, p in ipairs(pairs_) do
        local a, b = skelPoints[p[1]], skelPoints[p[2]]
        local line = makeLine(canvas, a[1], a[2], b[1], b[2], WHITE, 2)
        line.Name = "SkelLine"
        table.insert(skelLines, line)
    end

    -- Cabeza (círculo simulado con frame cuadrado redondeado)
    local head = Instance.new("Frame")
    head.Size             = UDim2.new(0, 22, 0, 22)
    head.Position         = UDim2.new(0, 117, 0, 24)
    head.BackgroundColor3 = Color3.new(1,1,1)
    head.BorderSizePixel  = 0
    head.Name             = "SkelHead"
    Instance.new("UICorner", head).CornerRadius = UDim.new(1, 0)
    head.Parent = canvas
    table.insert(skelLines, head)
end
buildSkeleton()

-- Bounding box
local bbTop    = makeLine(canvas, 78, 22,  178, 22,  ACCENT, 2)
local bbBottom = makeLine(canvas, 78, 248, 178, 248, ACCENT, 2)
local bbLeft   = makeLine(canvas, 78, 22,  78,  248, ACCENT, 2)
local bbRight  = makeLine(canvas, 178, 22, 178, 248, ACCENT, 2)
local bbParts  = {bbTop, bbBottom, bbLeft, bbRight}
for _, p in ipairs(bbParts) do p.Name = "BBox" end

-- Health bar (izquierda del bbox)
local healthBg = Instance.new("Frame")
healthBg.Size             = UDim2.new(0, 6, 0, 226)
healthBg.Position         = UDim2.new(0, 66, 0, 22)
healthBg.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
healthBg.BorderSizePixel  = 0
healthBg.Name             = "HpBg"
healthBg.Parent           = canvas

local healthBar = Instance.new("Frame")
healthBar.Size             = UDim2.new(1, 0, 0.75, 0)  -- 75% HP
healthBar.Position         = UDim2.new(0, 0, 0.25, 0)
healthBar.BackgroundColor3 = GREEN_HP
healthBar.BorderSizePixel  = 0
healthBar.Name             = "HpBar"
healthBar.Parent           = healthBg

-- Name label
local nameLabel = Instance.new("TextLabel")
nameLabel.Size              = UDim2.new(0, 100, 0, 16)
nameLabel.Position          = UDim2.new(0, 78, 0, 4)
nameLabel.BackgroundTransparency = 1
nameLabel.Text              = "Player_ESP"
nameLabel.TextColor3        = Color3.new(1, 1, 1)
nameLabel.Font              = Enum.Font.GothamBold
nameLabel.TextSize          = 11
nameLabel.Name              = "NameLabel"
nameLabel.Parent            = canvas

-- Weapon text
local weaponLabel = Instance.new("TextLabel")
weaponLabel.Size              = UDim2.new(0, 100, 0, 14)
weaponLabel.Position          = UDim2.new(0, 78, 0, 252)
weaponLabel.BackgroundTransparency = 1
weaponLabel.Text              = "[ Tool ]"
weaponLabel.TextColor3        = Color3.fromRGB(255, 220, 50)
weaponLabel.Font              = Enum.Font.Gotham
weaponLabel.TextSize          = 10
weaponLabel.Name              = "WeaponLabel"
weaponLabel.Parent            = canvas

-- Distance label
local distLabel = Instance.new("TextLabel")
distLabel.Size              = UDim2.new(0, 100, 0, 14)
distLabel.Position          = UDim2.new(0, 78, 0, 266)
distLabel.BackgroundTransparency = 1
distLabel.Text              = "52m"
distLabel.TextColor3        = TEXT_G
distLabel.Font              = Enum.Font.Gotham
distLabel.TextSize          = 10
distLabel.Name              = "DistLabel"
distLabel.Parent            = canvas

-- ──────────────────────────────────────────────
-- FUNCIÓN: actualizar visibilidad del preview
-- ──────────────────────────────────────────────
local function updatePreview()
    -- Skeleton
    for _, l in ipairs(skelLines) do
        l.Visible = espConfig.Skeleton
    end
    -- BoundingBox
    for _, p in ipairs(bbParts) do
        p.Visible = espConfig.BoundingBox
    end
    -- HealthBar
    healthBg.Visible  = espConfig.HealthBar
    -- Name
    nameLabel.Visible = espConfig.Name
    -- Weapon
    weaponLabel.Visible = espConfig.WeaponText
    -- Distance
    distLabel.Visible   = espConfig.Distance
end

-- ──────────────────────────────────────────────
-- CREAR TOGGLE EN EL PANEL IZQUIERDO
-- ──────────────────────────────────────────────
local function createToggle(label, key)
    local row = Instance.new("Frame")
    row.Size              = UDim2.new(1, -8, 0, 30)
    row.BackgroundTransparency = 1
    row.Parent            = leftPanel

    -- Indicador cuadrado (como en la imagen)
    local indicator = Instance.new("Frame")
    indicator.Size            = UDim2.new(0, 13, 0, 13)
    indicator.Position        = UDim2.new(0, 0, 0.5, -6)
    indicator.BackgroundColor3 = espConfig[key] and ACCENT or Color3.fromRGB(60, 60, 60)
    indicator.BorderSizePixel  = 0
    indicator.Parent           = row
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -20, 1, 0)
    lbl.Position          = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = TEXT_W
    lbl.Font              = Enum.Font.Gotham
    lbl.TextSize          = 13
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.Parent            = row

    -- Clickable
    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text              = ""
    btn.Parent            = row

    btn.MouseButton1Click:Connect(function()
        espConfig[key] = not espConfig[key]
        indicator.BackgroundColor3 = espConfig[key] and ACCENT or Color3.fromRGB(60, 60, 60)
        updatePreview()
    end)

    -- Hover
    btn.MouseEnter:Connect(function()
        lbl.TextColor3 = ACCENT
    end)
    btn.MouseLeave:Connect(function()
        lbl.TextColor3 = TEXT_W
    end)

    return row
end

-- Spacer arriba
local topSpacer = Instance.new("Frame")
topSpacer.Size                    = UDim2.new(1, 0, 0, 6)
topSpacer.BackgroundTransparency  = 1
topSpacer.Parent                  = leftPanel

createToggle("Bounding Box", "BoundingBox")
createToggle("Skeleton",     "Skeleton")
createToggle("Health Bar",   "HealthBar")
createToggle("Name",         "Name")
createToggle("Weapon Text",  "WeaponText")
createToggle("Distance",     "Distance")

-- Separador
local sep = Instance.new("Frame")
sep.Size             = UDim2.new(1, -8, 0, 1)
sep.BackgroundColor3 = BG_LIGHT
sep.BorderSizePixel  = 0
sep.Parent           = leftPanel

-- Color picker simple (cambia color del ESP)
local colorRow = Instance.new("Frame")
colorRow.Size             = UDim2.new(1, -8, 0, 28)
colorRow.BackgroundTransparency = 1
colorRow.Parent           = leftPanel

local colorLbl = Instance.new("TextLabel")
colorLbl.Size             = UDim2.new(0, 80, 1, 0)
colorLbl.BackgroundTransparency = 1
colorLbl.Text             = "Color ESP:"
colorLbl.TextColor3       = TEXT_G
colorLbl.Font             = Enum.Font.Gotham
colorLbl.TextSize         = 12
colorLbl.TextXAlignment   = Enum.TextXAlignment.Left
colorLbl.Parent           = colorRow

local colorSwatches = {
    {Color3.fromRGB(0,210,80),   "Verde"},
    {Color3.fromRGB(255,60,60),  "Rojo"},
    {Color3.fromRGB(50,160,255), "Azul"},
    {Color3.fromRGB(255,220,30), "Amarillo"},
}

for i, cs in ipairs(colorSwatches) do
    local sw = Instance.new("TextButton")
    sw.Size             = UDim2.new(0, 18, 0, 18)
    sw.Position         = UDim2.new(0, 78 + (i-1)*24, 0.5, -9)
    sw.BackgroundColor3 = cs[1]
    sw.Text             = ""
    sw.BorderSizePixel  = 0
    sw.Parent           = colorRow
    Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 4)

    sw.MouseButton1Click:Connect(function()
        ACCENT = cs[1]
        -- Actualiza líneas del bbox
        for _, p in ipairs(bbParts) do p.BackgroundColor3 = cs[1] end
        greenBorder.BackgroundColor3 = cs[1]
    end)
end

-- ──────────────────────────────────────────────
-- ANIMACIÓN SUTIL: el muñeco "respira" (bounce)
-- ──────────────────────────────────────────────
local t = 0
RunService.RenderStepped:Connect(function(dt)
    t = t + dt
    local bob = math.sin(t * 1.5) * 3
    canvas.Position = UDim2.new(0, 8, 0, 24 + bob)
end)

-- ──────────────────────────────────────────────
-- INICIALIZAR PREVIEW
-- ──────────────────────────────────────────────
updatePreview()

-- Atajo de teclado: INSERT para abrir/cerrar
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("[ESP GUI] Cargado. Presiona INSERT para abrir/cerrar.")