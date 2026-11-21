--[[
    Steal An Egg - Ultimate Cleaner + Anti-AFK
    Xóa sạch mọi hiệu ứng lag, giữ đồ họa mượt nhất có thể.
    Chạy ngầm - Không UI.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ================== THÔNG BÁO ==================
local function showToast(text)
    local toastGui = Instance.new("ScreenGui")
    toastGui.Name = "SAE_Toast"
    toastGui.ResetOnSpawn = false
    toastGui.IgnoreGuiInset = true
    toastGui.DisplayOrder = 999
    toastGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(300, 50)
    frame.Position = UDim2.new(0.5, -150, 0, -60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = toastGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 220, 150)
    stroke.Thickness = 2
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0, 20)
    }):Play()

    task.delay(3, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -150, 0, -60)
        }):Play()
        task.wait(0.3)
        toastGui:Destroy()
    end)
end

-- ================== HÀM XÓA HIỆU ỨNG (CLEANER) ==================
local function cleanObject(obj)
    -- Xóa Particle (hiệu ứng hạt của pet, trứng, kỹ năng)
    if obj:IsA("ParticleEmitter") then
        obj.Enabled = false
        obj:Destroy() -- Xóa luôn cho nhẹ
    end
    
    -- Xóa Trail (vệt sáng khi chạy)
    if obj:IsA("Trail") then
        obj.Enabled = false
        obj:Destroy()
    end
    
    -- Xóa Beam (tia sáng)
    if obj:IsA("Beam") then
        obj.Enabled = false
        obj:Destroy()
    end
    
    -- Tắt đèn (đèn từ pet, môi trường)
    if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Enabled = false
        obj:Destroy()
    end
    
    -- Xóa Text bay lên (kiếm tiền, thông báo rác)
    if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
        -- Giữ lại GUI của nhân vật chính (để không mất UI của mình)
        local parent = obj.Parent
        if parent and parent:IsA("BasePart") then
            local char = parent:FindFirstAncestorOfClass("Model")
            if char then
                local plr = Players:GetPlayerFromCharacter(char)
                if plr == player then return end -- Bỏ qua GUI của mình
            end
        end
        obj.Enabled = false
        obj:Destroy()
    end
    
    -- Xóa hiệu ứng âm thanh 3D (nếu có)
    if obj:IsA("Sound") and obj.RollOffMaxDistance > 0 then
        obj:Destroy()
    end
end

-- ================== TỐI ƯU HÓA MÔI TRƯỜNG ==================
local function optimizeEnvironment()
    -- Tắt bóng đổ, sương mù
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    
    -- Tắt mọi hiệu ứng hậu kỳ (Bloom, Blur, v.v.)
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then
            v.Enabled = false
            v:Destroy()
        end
    end
    
    -- Chỉnh chất lượng đồ họa của Roblox xuống thấp nhất
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
end

-- ================== QUÉT SẠCH TOÀN BỘ BẢN ĐỒ ==================
local function fullClean()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        cleanObject(obj)
    end
end

-- ================== TỰ ĐỘNG DỌN DẸP LIÊN TỤC ==================
local function setupLiveCleaner()
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.3) -- Đợi object load xong
        cleanObject(obj)
    end)
    
    -- Quét lại mỗi 5 giây để đảm bảo không sót
    task.spawn(function()
        while task.wait(5) do
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("BillboardGui") then
                    cleanObject(obj)
                end
            end
        end
    end)
end

-- ================== ANTI-AFK ==================
-- Tự động nhấn Space hoặc di chuyển để không bị đá
local function setupAntiAFK()
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("[Anti-AFK] Đã chống đá (Idle)")
    end)
    
    -- Gửi tín hiệu chuột mỗi 60s cho chắc
    task.spawn(function()
        while task.wait(60) do
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

-- ================== CHẠY SCRIPT ==================
local ok, err = pcall(function()
    optimizeEnvironment()
    fullClean()
    setupLiveCleaner()
    setupAntiAFK()
end)

if ok then
    showToast("🧹 Đã dọn sạch hiệu ứng & Bật Anti-AFK!")
    print("[Steal An Egg Ultimate Cleaner] Loaded.")
else
    showToast("❌ Lỗi: " .. tostring(err))
    warn("[Cleaner] Error: " .. tostring(err))
end
