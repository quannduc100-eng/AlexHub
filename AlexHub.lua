--[[
    ULTIMATE FIX LAG - TỔNG HỢP TẤT CẢ KỸ THUẬT
    Bao gồm: Tắt đồ họa, Xóa vật thể, Tối ưu Physics, Streaming, 
    và Ép xung nhịp (Unlocker).
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================================
-- CẤP ĐỘ 1: TỐI ƯU MÔI TRƯỜNG & ÁNH SÁNG (LIGHTING)
-- ==========================================================
local function tier1_Lighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.Brightness = 2

    -- Xóa mọi hiệu ứng hậu kỳ (Post-Processing)
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") 
        or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
            v:Destroy()
        end
    end
end

-- ==========================================================
-- CẤP ĐỘ 2: XÓA SỔ HIỆU ỨNG & VẬT THỂ (CLEANER)
-- ==========================================================
local function tier2_Cleaner(obj)
    -- Hiệu ứng hạt, khói, lửa
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") 
    or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        obj:Destroy()
    
    -- Đèn chiếu sáng
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj:Destroy()
        
    -- Text bay lên
    elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
        local parent = obj.Parent
        if parent and parent:IsA("BasePart") then
            local char = parent:FindFirstAncestorOfClass("Model")
            if char and Players:GetPlayerFromCharacter(char) == player then return end
        end
        obj:Destroy()
        
    -- Texture, Decal (Xóa hình ảnh)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()

    -- Âm thanh 3D (Sound)
    elseif obj:IsA("Sound") and obj.RollOffMaxDistance > 0 then
        obj:Destroy()
    end
end

-- ==========================================================
-- CẤP ĐỘ 3: TỐI ƯU VẬT LÝ & VẬT LIỆU (PHYSICS & MATERIAL)
-- ==========================================================
local function tier3_Physics()
    -- Ép tất cả BasePart thành SmoothPlastic, tắt phản chiếu, tắt bóng
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            pcall(function()
                if not obj.Anchored then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                end
            end)
        end
    end

    -- Tắt xử lý vật lý ở xa
    pcall(function()
        Workspace.StreamingEnabled = true
        Workspace.StreamingTargetRadius = 128 -- Giảm tầm nhìn
    end)
end

-- ==========================================================
-- CẤP ĐỘ 4: CAN THIỆP ENGINE (SETTINGS)
-- ==========================================================
local function tier4_Engine()
    pcall(function()
        -- Ép đồ họa Roblox xuống mức thấp nhất
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.EagerBulkExecution = true
        
        -- Tắt VSync (nếu có) để tăng FPS tối đa
        settings().Rendering.VSync = false
        
        -- Giảm chất lượng Physics
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
        settings().Physics.AllowSleep = true
    end)

    -- Unlock FPS (Tắt giới hạn 60fps)
    pcall(function()
        setfpscap(9999)
    end)
end

-- ==========================================================
-- CẤP ĐỘ 5: QUÉT LIÊN TỤC (LIVE CLEANER)
-- ==========================================================
local function tier5_LiveCleaner()
    -- Xóa mọi thứ mới sinh ra ngay lập tức
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        tier2_Cleaner(obj)
    end)

    -- Quét lại toàn bản đồ mỗi 0.5s (Siêu tốc)
    task.spawn(function()
        while task.wait(0.5) do
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("BillboardGui") 
                or obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("Trail") then
                    tier2_Cleaner(obj)
                end
            end
        end
    end)
end

-- ==========================================================
-- HÀM THÔNG BÁO (TOAST)
-- ==========================================================
local function showToast(text)
    local toastGui = Instance.new("ScreenGui")
    toastGui.Name = "UltimateToast"
    toastGui.ResetOnSpawn = false
    toastGui.IgnoreGuiInset = true
    toastGui.DisplayOrder = 999
    toastGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(320, 50)
    frame.Position = UDim2.new(0.5, -160, 0, -60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = toastGui

    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 10); corner.Parent = frame
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(100, 220, 150); stroke.Thickness = 2; stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0, 20)
    }):Play()

    task.delay(4, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -160, 0, -60)
        }):Play()
        task.wait(0.3)
        toastGui:Destroy()
    end)
end

-- ==========================================================
-- CHẠY TẤT CẢ CÁC CẤP ĐỘ
-- ==========================================================
local ok, err = pcall(function()
    tier1_Lighting()          -- Tối ưu ánh sáng
    tier4_Engine()            -- Tối ưu Engine & FPS (Chạy sớm để có tác dụng)
    
    -- Quét sạch sẽ lần đầu
    for _, obj in ipairs(Workspace:GetDescendants()) do 
        tier2_Cleaner(obj) 
    end
    
    tier3_Physics()           -- Tối ưu vật lý
    tier5_LiveCleaner()       -- Bật chế độ dọn rác liên tục
end)

if ok then 
    showToast("🔥 Ultimate Fix Lag: Đã tối ưu hóa mọi thứ!")
    print("[Ultimate Fix Lag] Loaded successfully.")
else
    showToast("❌ Lỗi: " .. tostring(err))
    warn("[Ultimate Fix Lag] Error: " .. tostring(err))
end
