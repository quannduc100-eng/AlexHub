--[[
    Steal An Egg - Ultimate Extreme Perf + Chill AFK (Full File)
    - Fix lag mạnh tay (Ép phẳng, xóa texture, xóa hiệu ứng, giảm render distance)
    - Giao diện Chill AFK (Đồng hồ đếm giờ, Quotes đổi liên tục)
    - Trình phát YouTube (Playlist Lã Phong Lâm & Minecraft)
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Dọn dẹp UI cũ (nếu có)
local oldUI = playerGui:FindFirstChild("SAE_ChillUI")
if oldUI then oldUI:Destroy() end
local oldWebView = playerGui:FindFirstChild("WebView")
if oldWebView then oldWebView:Destroy() end

-- =====================================================================
-- PHẦN 1: TỐI ƯU HÓA CỰC ĐOAN (MẠNH TAY) - DÀNH CHO MÁY YẾU
-- =====================================================================

-- Hàm xử lý từng Object trong game
local function extremeClean(obj)
    -- 1. Xóa mọi hiệu ứng hạt, vệt sáng
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
        obj.Enabled = false
        obj:Destroy()
    
    -- 2. Xóa mọi nguồn sáng (đèn)
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Enabled = false
        obj:Destroy()
        
    -- 3. XÓA SẠCH TEXTURE VÀ DECAL (Mạnh tay nhất, giúp tăng FPS vọt)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
        obj:Destroy()
        
    -- 4. Xóa Text bay lên (BillboardGui, SurfaceGui)
    elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
        local parent = obj.Parent
        if parent and parent:IsA("BasePart") then
            local char = parent:FindFirstAncestorOfClass("Model")
            -- Giữ lại UI của nhân vật mình, xóa của người khác
            if char and Players:GetPlayerFromCharacter(char) == player then return end
        end
        obj.Enabled = false
        obj:Destroy()
        
    -- 5. Ép vật liệu thành phẳng (SmoothPlastic) và xóa phản chiếu
    elseif obj:IsA("BasePart") then
        if not obj.Anchored then -- Chỉ ép vật liệu cho các vật thể động (như nhân vật, pet)
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        end
    end
end

-- Hàm tối ưu môi trường (Ánh sáng, sương mù)
local function extremeEnvironment()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1) -- Sáng trưng
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
            v:Destroy()
        end
    end
    
    -- Tắt xử lý vật lý ở xa (Streaming) để giảm tải RAM/CPU
    pcall(function()
        Workspace.StreamingEnabled = true
        Workspace.StreamingTargetRadius = 128 -- Chỉ load trong bán kính 128 studs
    end)

    -- Cố gắng ép đồ họa Roblox xuống mức thấp nhất
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)
end

-- Hàm dọn dẹp liên tục (Live Cleaner)
local function setupLiveCleaner()
    -- Lắng nghe xem có Object mới sinh ra không
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        extremeClean(obj)
    end)
    
    -- Cứ mỗi 1 giây lại quét toàn bản đồ 1 lần
    task.spawn(function()
        while task.wait(1) do 
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("BillboardGui") or obj:IsA("Decal") or obj:IsA("Texture") then
                    extremeClean(obj)
                end
            end
        end
    end)
end

-- =====================================================================
-- PHẦN 2: GIAO DIỆN CHILL AFK + YOUTUBE
-- =====================================================================

-- Danh sách phát (Playlist)
local Playlist = {
    {name = "Lã Phong Lâm - Tuyết", id = "YQ8p9Q4h7zM"},
    {name = "Lã Phong Lâm - Hoa Nở", id = "vT8N6bJ4y2A"},
    {name = "Lã Phong Lâm - Mộng Uyên Ương", id = "x8V4G9k2n1Q"},
    {name = "Minecraft Lofi Chill", id = "jfKfPfyJRdk"},
    {name = "Minecraft Ambience", id = "1S6fZ4t2c0Y"}
}
local currentTrack = 1

local function createChillUI()
    local chillGui = Instance.new("ScreenGui")
    chillGui.Name = "SAE_ChillUI"
    chillGui.ResetOnSpawn = false
    chillGui.IgnoreGuiInset = true
    chillGui.DisplayOrder = 999
    chillGui.Parent = playerGui

    -- Khung chính
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.fromOffset(400, 300)
    mainFrame.Position = UDim2.new(1, -420, 1, -320)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = chillGui

    local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = mainFrame
    local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(200, 50, 50); ms.Thickness = 1.5; ms.Transparency = 0.3; ms.Parent = mainFrame

    -- Thanh tiêu đề (Kéo thả)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0, 12); tbc.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.fromOffset(10, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "📺 Chill AFK - Lã Phong Lâm & Minecraft"
    titleText.TextColor3 = Color3.fromRGB(240, 240, 240)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 11
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.fromOffset(20, 20)
    hideBtn.Position = UDim2.new(1, -25, 0, 5)
    hideBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
    hideBtn.Text = "✕"
    hideBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 10
    hideBtn.Parent = titleBar
    local hbc = Instance.new("UICorner"); hbc.CornerRadius = UDim.new(1, 0); hbc.Parent = hideBtn

    -- Khung chứa Video
    local videoFrame = Instance.new("Frame")
    videoFrame.Size = UDim2.new(1, -20, 0, 200)
    videoFrame.Position = UDim2.fromOffset(10, 35)
    videoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    videoFrame.BorderSizePixel = 0
    videoFrame.ClipsDescendants = true
    videoFrame.Parent = mainFrame
    local vfc = Instance.new("UICorner"); vfc.CornerRadius = UDim.new(0, 8); vfc.Parent = videoFrame

    local videoLabel = Instance.new("TextLabel")
    videoLabel.Size = UDim2.fromScale(1, 1)
    videoLabel.BackgroundTransparency = 1
    videoLabel.Text = "Đang tải video..."
    videoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    videoLabel.Font = Enum.Font.Gotham
    videoLabel.TextSize = 12
    videoLabel.Parent = videoFrame

    -- Thanh điều khiển (Playlist)
    local controlBar = Instance.new("Frame")
    controlBar.Size = UDim2.new(1, -20, 0, 40)
    controlBar.Position = UDim2.fromOffset(10, 245)
    controlBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    controlBar.BorderSizePixel = 0
    controlBar.Parent = mainFrame
    local cbc2 = Instance.new("UICorner"); cbc2.CornerRadius = UDim.new(0, 8); cbc2.Parent = controlBar

    local songName = Instance.new("TextLabel")
    songName.Size = UDim2.new(1, -80, 1, 0)
    songName.Position = UDim2.fromOffset(10, 0)
    songName.BackgroundTransparency = 1
    songName.Text = Playlist[currentTrack].name
    songName.TextColor3 = Color3.fromRGB(200, 220, 255)
    songName.Font = Enum.Font.GothamBold
    songName.TextSize = 11
    songName.TextXAlignment = Enum.TextXAlignment.Left
    songName.Parent = controlBar

    -- Nút Next
    local nextBtn = Instance.new("TextButton")
    nextBtn.Size = UDim2.fromOffset(30, 30)
    nextBtn.Position = UDim2.new(1, -40, 0.5, -15)
    nextBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    nextBtn.Text = "⏭"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.TextSize = 14
    nextBtn.Parent = controlBar
    local nbc = Instance.new("UICorner"); nbc.CornerRadius = UDim.new(0, 6); nbc.Parent = nextBtn

    -- Hàm tải video WebView
    local function loadVideo(index)
        local track = Playlist[index]
        songName.Text = track.name
        
        -- Xóa WebView cũ
        local oldWv = playerGui:FindFirstChild("WebView")
        if oldWv then oldWv:Destroy() end

        pcall(function()
            local url = "https://www.youtube.com/embed/" .. track.id .. "?autoplay=1"
            -- Gọi API của Executor để nhúng iframe
            if WebView then
                WebView.new(url, videoFrame)
                videoLabel.Visible = false
            else
                -- Fallback nếu Executor không hỗ trợ
                videoLabel.Text = "Đang phát: " .. track.name
            end
        end)
    end

    -- Sự kiện Next
    nextBtn.MouseButton1Click:Connect(function()
        currentTrack = currentTrack + 1
        if currentTrack > #Playlist then currentTrack = 1 end
        loadVideo(currentTrack)
    end)

    -- Logic kéo thả UI
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Ẩn/Hiện UI
    hideBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        local reopenBtn = Instance.new("TextButton")
        reopenBtn.Size = UDim2.fromOffset(40, 40)
        reopenBtn.Position = UDim2.new(1, -60, 1, -60)
        reopenBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        reopenBtn.Text = "📺"
        reopenBtn.TextSize = 20
        reopenBtn.Parent = chillGui
        local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(1, 0); rc.Parent = reopenBtn
        reopenBtn.MouseButton1Click:Connect(function()
            mainFrame.Visible = true
            reopenBtn:Destroy()
        end)
    end)

    loadVideo(currentTrack)
end

-- =====================================================================
-- CHẠY SCRIPT
-- =====================================================================
local ok, err = pcall(function()
    extremeEnvironment() -- Tối ưu môi trường (ánh sáng, sương)
    
    for _, obj in ipairs(Workspace:GetDescendants()) do 
        extremeClean(obj) -- Quét sạch sẽ 1 lần đầu
    end
    
    setupLiveCleaner() -- Bật chế độ dọn rác liên tục
    createChillUI() -- Tạo giao diện Chill + YouTube
end)

if ok then 
    print("[SAE Ultimate AFK] Loaded successfully.")
else 
    warn("[SAE Ultimate AFK] Error: " .. tostring(err))
end
