--[[
    ULTIMATE OPTIMIZER + MINI UI TAB
    - Học hỏi cấu trúc UI từ Apex AI
    - Tự động co giãn (UIScale)
    - Hiệu ứng chuyển tab (Fade + Underline)
    - Fix lag thông minh (Không xóa sổ)
]]

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Dọn dẹp UI cũ
for _, name in ipairs({"ApexOptimizerUI"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ==========================================================
-- PHẦN 1: LOGIC TỐI ƯU (GIỐNG BẢN TRƯỚC)
-- ==========================================================
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.ClockTime = 13.5
Lighting.Brightness = 3
Lighting.ExposureCompensation = 0.5

for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("Atmosphere") then
        obj.Enabled = false
    end
end

local colorCorrection = Lighting:FindFirstChild("MapColor") or Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "MapColor"
colorCorrection.Parent = Lighting
colorCorrection.Enabled = true
colorCorrection.Brightness = 0.05
colorCorrection.Contrast = 0.05
colorCorrection.Saturation = 0.08

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    setfpscap(240) 
end)

local function smartOptimize(obj)
    if obj:IsA("BasePart") then
        pcall(function()
            obj.CastShadow = false
            if not obj.Anchored and obj.Name ~= "HumanoidRootPart" then
                obj.CanCollide = false
            end
        end)
    end
    if obj:IsA("ParticleEmitter") then
        pcall(function()
            obj.Rate = math.min(obj.Rate, 5)
            obj.Lifetime = NumberRange.new(0.2, 0.5)
        end)
    end
    if obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("PointLight") then
        obj.Enabled = false
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do smartOptimize(obj) end
Workspace.DescendantAdded:Connect(function(obj) task.wait(0.1); smartOptimize(obj) end)
task.spawn(function()
    while task.wait(1) do
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("BasePart") then smartOptimize(obj) end
        end
    end
end)

-- ==========================================================
-- PHẦN 2: UI TAB MINI (HỌC HỎI TỪ APEX AI)
-- ==========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ApexOptimizerUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

-- UIScale để tự động co giãn trên điện thoại
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = screenGui

-- Khung chính (Nằm góc trên trái)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(200, 140)
mainFrame.Position = UDim2.fromOffset(20, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(80, 80, 100); ms.Thickness = 1; ms.Parent = mainFrame

-- Thanh Tab
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame
local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0, 8); tbc.Parent = tabContainer

-- Nội dung hiển thị
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -40)
contentFrame.Position = UDim2.fromOffset(5, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Tạo 2 trang (Tab 1: Thông số, Tab 2: Cài đặt)
local pages = {}
for i = 1, 2 do
    local page = Instance.new("Frame")
    page.Name = "Page"..i
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    page.Parent = contentFrame
    pages[i] = page
end

-- Trang 1: Hiển thị FPS
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 30)
fpsLabel.Position = UDim2.fromOffset(0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: Đang tính..."
fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 16
fpsLabel.Parent = pages[1]

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, 0, 0, 20)
pingLabel.Position = UDim2.fromOffset(0, 40)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "Ping: Đang tính..."
pingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
pingLabel.Font = Enum.Font.Gotham
pingLabel.TextSize = 14
pingLabel.Parent = pages[1]

-- Trang 2: Nút bấm
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 30)
resetBtn.Position = UDim2.fromOffset(0, 10)
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
resetBtn.Text = "Khôi phục đồ họa"
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 13
resetBtn.Parent = pages[2]
local rbc = Instance.new("UICorner"); rbc.CornerRadius = UDim.new(0, 6); rbc.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = true
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    pcall(function() setfpscap(60) end)
    resetBtn.Text = "Đã khôi phục!"
    task.wait(2)
    resetBtn.Text = "Khôi phục đồ họa"
end)

-- Tạo các TabButton
local tabNames = {"Info", "Tools"}
local tabButtons = {}
local buttonWidth = 0.5

for i = 1, 2 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(buttonWidth, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*buttonWidth, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = tabContainer

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 1
    txt.Text = tabNames[i]
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 13
    txt.TextColor3 = (i==1) and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
    txt.Parent = btn

    -- Gạch chân (Underline)
    local underline = Instance.new("Frame")
    underline.Size = UDim2.new(0.6, 0, 0, 2)
    underline.Position = UDim2.new(0.2, 0, 0.95, 0)
    underline.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
    underline.BackgroundTransparency = (i==1) and 0 or 1
    underline.Parent = btn

    tabButtons[i] = { Button = btn, Label = txt, Underline = underline }
end

-- Hàm chuyển Tab (Fade)
local currentTab = 1
local function setActiveTab(newIndex)
    if newIndex == currentTab then return end

    local oldPage = pages[currentTab]
    TweenService:Create(oldPage, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    task.delay(0.2, function() oldPage.Visible = false end)

    local oldBtn = tabButtons[currentTab]
    TweenService:Create(oldBtn.Underline, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(oldBtn.Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150,150,150)}):Play()

    local newPage = pages[newIndex]
    newPage.Visible = true
    newPage.BackgroundTransparency = 1
    TweenService:Create(newPage, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()

    local newBtn = tabButtons[newIndex]
    TweenService:Create(newBtn.Underline, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    TweenService:Create(newBtn.Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()

    currentTab = newIndex
end

for i, data in ipairs(tabButtons) do
    data.Button.MouseButton1Click:Connect(function() setActiveTab(i) end)
end

-- Cập nhật FPS/Ping
task.spawn(function()
    local frames = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTime >= 1 then
            local fps = math.floor(frames / (tick() - lastTime))
            fpsLabel.Text = "FPS: " .. fps
            frames = 0
            lastTime = tick()
        end
    end)
end)

-- Cập nhật Ping (Giả lập hoặc lấy từ Stats)
pcall(function()
    local Stats = game:GetService("Stats")
    task.spawn(function()
        while task.wait(2) do
            local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            pingLabel.Text = "Ping: " .. math.floor(ping) .. " ms"
        end
    end)
end)

-- Tự động co giãn UI trên điện thoại
local function updateScale()
    local viewport = workspace.CurrentCamera.ViewportSize
    if viewport.X < 800 then
        uiScale.Scale = viewport.X / 800
    else
        uiScale.Scale = 1
    end
end
RunService.RenderStepped:Connect(updateScale)
updateScale()

print("✅ APEX OPTIMIZER + MINI UI: ON")
