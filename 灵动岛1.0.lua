-- Dynamic Island for Roblox
-- Author: xiaomao
-- Version: 1.0

local function SecurityCheck()
    if not game or not game.GetService then
        return false
    end
    
    local success = pcall(function()
        game:GetService("Players")
        game:GetService("CoreGui")
        game:GetService("TweenService")
    end)
    
    if not success then
        return false
    end
    
    local scriptSource = debug.getinfo(1, "S").source
    if scriptSource and scriptSource:find("loadstring") then
        warn("[OPAI] 警告：检测到可疑环境")
    end
    
    return true
end

if not SecurityCheck() then
    error("[OPAI] 安全检查失败：无法在当前环境运行")
    return
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    DemoMode = false,
    SavePosition = false,
    EnableSound = false,
    DefaultNotifDuration = 3.5,
    MaxQueueSize = 20,
    MaxConcurrentNotifications = 3,
    NotificationSpacing = 10,
}

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IsTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled

local MobileScale = IsMobile and 0.85 or 1
local IslandWidth = IsMobile and 160 or 200
local IslandHeight = IsMobile and 35 or 40
local IslandYPos = IsMobile and 5 or 10

local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Stroke = Color3.fromRGB(80, 80, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        StatusDot = Color3.fromRGB(0, 255, 100),
        NotifTitleColor = Color3.fromRGB(255, 255, 255),
        NotifContentColor = Color3.fromRGB(180, 180, 180),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Stroke = Color3.fromRGB(100, 100, 255),
        Text = Color3.fromRGB(20, 20, 20),
        SubText = Color3.fromRGB(60, 60, 60),
        StatusDot = Color3.fromRGB(0, 200, 80),
        NotifTitleColor = Color3.fromRGB(10, 10, 10),
        NotifContentColor = Color3.fromRGB(50, 50, 50),
    }
}

local CurrentTheme = "Dark"
local ActiveTheme = Themes[CurrentTheme]

local ActiveNotifications = {}
local NotificationQueue = {}
local NotificationCounter = 0
local IsVisible = true
local CurrentTweens = {}
local EventConnections = {}
local IsRunning = true

local HiddenContainer = Instance.new("ScreenGui")
HiddenContainer.Name = HttpService:GenerateGUID(false)
HiddenContainer.ResetOnSpawn = false
HiddenContainer.IgnoreGuiInset = true
HiddenContainer.DisplayOrder = -999
HiddenContainer.Parent = CoreGui

local DynamicIsland = Instance.new("ScreenGui")
DynamicIsland.Name = "DI_" .. HttpService:GenerateGUID(false):sub(1, 8)
DynamicIsland.ResetOnSpawn = false
DynamicIsland.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DynamicIsland.IgnoreGuiInset = true
DynamicIsland.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, IslandWidth, 0, IslandHeight)
MainFrame.Position = UDim2.new(0.5, -IslandWidth/2, 0, IslandYPos)
MainFrame.BackgroundColor3 = ActiveTheme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = DynamicIsland

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, IsMobile and 18 or 20)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = ActiveTheme.Stroke
Stroke.Thickness = IsMobile and 1.2 or 1.5
Stroke.Transparency = 0.5
Stroke.Parent = MainFrame

local Logo = Instance.new("TextLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, IsMobile and 60 or 80, 1, 0)
Logo.Position = UDim2.new(0, IsMobile and 8 or 10, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "OPAI"
Logo.TextColor3 = ActiveTheme.Text
Logo.TextSize = IsMobile and 14 or 16
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = MainFrame

local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, IsMobile and 6 or 8, 0, IsMobile and 6 or 8)
StatusDot.Position = UDim2.new(0, IsMobile and 72 or 95, 0.5, IsMobile and -3 or -4)
StatusDot.BackgroundColor3 = ActiveTheme.StatusDot
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Size = UDim2.new(0, IsMobile and 70 or 80, 1, 0)
TimeLabel.Position = UDim2.new(1, IsMobile and -75 or -90, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "00:00:00"
TimeLabel.TextColor3 = ActiveTheme.SubText
TimeLabel.TextSize = IsMobile and 12 or 14
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
TimeLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, IsMobile and 20 or 24, 0, IsMobile and 20 or 24)
CloseButton.Position = UDim2.new(1, IsMobile and -25 or -28, 0.5, IsMobile and -10 or -12)
CloseButton.BackgroundTransparency = 0.8
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = IsMobile and 12 or 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Visible = false
CloseButton.ZIndex = 20
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

local NotificationsContainer = Instance.new("Frame")
NotificationsContainer.Name = "NotificationsContainer"
local containerWidth = IsMobile and 280 or 340
NotificationsContainer.Size = UDim2.new(0, containerWidth, 0, 500)
NotificationsContainer.Position = UDim2.new(0.5, -containerWidth/2, 0, IslandYPos + IslandHeight + (IsMobile and 15 or 20))
NotificationsContainer.BackgroundTransparency = 1
NotificationsContainer.ZIndex = 10
NotificationsContainer.ClipsDescendants = false
NotificationsContainer.Parent = DynamicIsland

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, Config.NotificationSpacing)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NotifLayout.Parent = NotificationsContainer

local originalPos = MainFrame.Position

local function SavePosition(pos)
    if not Config.SavePosition then return end
end

local function CancelTween(name)
    if CurrentTweens[name] then
        CurrentTweens[name]:Cancel()
        CurrentTweens[name] = nil
    end
end

local function PlayTween(name, instance, tweenInfo, properties)
    CancelTween(name)
    CurrentTweens[name] = TweenService:Create(instance, tweenInfo, properties)
    CurrentTweens[name]:Play()
    return CurrentTweens[name]
end

local function ToggleTheme()
    CurrentTheme = CurrentTheme == "Dark" and "Light" or "Dark"
    ActiveTheme = Themes[CurrentTheme]
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
    PlayTween("theme_main", MainFrame, tweenInfo, {BackgroundColor3 = ActiveTheme.Background})
    PlayTween("theme_stroke", Stroke, tweenInfo, {Color = ActiveTheme.Stroke})
    PlayTween("theme_logo", Logo, tweenInfo, {TextColor3 = ActiveTheme.Text})
    PlayTween("theme_time", TimeLabel, tweenInfo, {TextColor3 = ActiveTheme.SubText})
    PlayTween("theme_dot", StatusDot, tweenInfo, {BackgroundColor3 = ActiveTheme.StatusDot})
    
    for _, activeNotif in ipairs(ActiveNotifications) do
        if activeNotif.ui then
            PlayTween("theme_notif_bg_" .. activeNotif.id, activeNotif.ui.Frame, 
                tweenInfo, {BackgroundColor3 = ActiveTheme.Background})
            PlayTween("theme_notif_title_" .. activeNotif.id, activeNotif.ui.Title, 
                tweenInfo, {TextColor3 = ActiveTheme.NotifTitleColor})
            PlayTween("theme_notif_content_" .. activeNotif.id, activeNotif.ui.Content, 
                tweenInfo, {TextColor3 = ActiveTheme.NotifContentColor})
        end
    end
end

local function ToggleVisibility()
    IsVisible = not IsVisible
    local targetPos = IsVisible and originalPos or UDim2.new(0.5, -IslandWidth/2, 0, -IslandHeight - 10)
    
    PlayTween("visibility", MainFrame, 
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
        {Position = targetPos}
    )
end

local function MainIslandPulse()
    local originalSize = MainFrame.Size
    local originalPos = MainFrame.Position
    
    local squashSize = UDim2.new(
        originalSize.X.Scale,
        originalSize.X.Offset + (IsMobile and 8 or 12),
        originalSize.Y.Scale,
        originalSize.Y.Offset - (IsMobile and 3 or 4)
    )
    local squashPos = UDim2.new(
        originalPos.X.Scale,
        originalPos.X.Offset - (IsMobile and 4 or 6),
        originalPos.Y.Scale,
        originalPos.Y.Offset + (IsMobile and 1.5 or 2)
    )
    
    PlayTween("island_jelly_squash", MainFrame,
        TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = squashSize, Position = squashPos}
    )
    
    task.wait(0.12)
    
    local stretchSize = UDim2.new(
        originalSize.X.Scale,
        originalSize.X.Offset - (IsMobile and 6 or 8),
        originalSize.Y.Scale,
        originalSize.Y.Offset + (IsMobile and 5 or 8)
    )
    local stretchPos = UDim2.new(
        originalPos.X.Scale,
        originalPos.X.Offset + (IsMobile and 3 or 4),
        originalPos.Y.Scale,
        originalPos.Y.Offset - (IsMobile and 2.5 or 4)
    )
    
    PlayTween("island_jelly_stretch", MainFrame,
        TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Size = stretchSize, Position = stretchPos}
    )
    
    task.wait(0.2)
    
    PlayTween("island_jelly_bounce", MainFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
        {Size = originalSize, Position = originalPos}
    )
end

local function CreateNotificationUI(notifId, layoutOrder)
    local notifWidth = IsMobile and 260 or 320
    local notifHeight = IsMobile and 50 or 60
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "Notification_" .. notifId
    NotifFrame.Size = UDim2.new(0, notifWidth, 0, notifHeight)
    NotifFrame.BackgroundColor3 = ActiveTheme.Background
    NotifFrame.BorderSizePixel = 0
    NotifFrame.LayoutOrder = layoutOrder
    NotifFrame.Position = UDim2.new(0.5, -notifWidth/2, 0, -(IslandYPos + IslandHeight + 20))
    NotifFrame.BackgroundTransparency = 1
    NotifFrame.Parent = NotificationsContainer
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, IsMobile and 12 or 15)
    NotifCorner.Parent = NotifFrame
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = ActiveTheme.Stroke
    NotifStroke.Thickness = IsMobile and 1.2 or 1.5
    NotifStroke.Transparency = 1
    NotifStroke.Parent = NotifFrame
    
    local Icon = Instance.new("TextLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, IsMobile and 30 or 35, 0, IsMobile and 30 or 35)
    Icon.Position = UDim2.new(0, IsMobile and 10 or 12, 0.5, IsMobile and -15 or -17.5)
    Icon.BackgroundTransparency = 1
    Icon.Text = "[+]"
    Icon.TextColor3 = Color3.fromRGB(0, 255, 150)
    Icon.TextSize = IsMobile and 18 or 22
    Icon.Font = Enum.Font.GothamBold
    Icon.TextTransparency = 1
    Icon.Parent = NotifFrame
    
    local TextContainer = Instance.new("Frame")
    TextContainer.Name = "TextContainer"
    TextContainer.Size = UDim2.new(1, IsMobile and -50 or -55, 1, 0)
    TextContainer.Position = UDim2.new(0, IsMobile and 45 or 50, 0, 0)
    TextContainer.BackgroundTransparency = 1
    TextContainer.Parent = NotifFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, IsMobile and 18 or 20)
    Title.Position = UDim2.new(0, 0, 0, IsMobile and 6 or 8)
    Title.BackgroundTransparency = 1
    Title.Text = "标题"
    Title.TextColor3 = ActiveTheme.NotifTitleColor
    Title.TextSize = IsMobile and 13 or 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTruncate = Enum.TextTruncate.AtEnd
    Title.TextTransparency = 1
    Title.Parent = TextContainer
    
    local Content = Instance.new("TextLabel")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 0, IsMobile and 16 or 18)
    Content.Position = UDim2.new(0, 0, 0, IsMobile and 24 or 28)
    Content.BackgroundTransparency = 1
    Content.Text = "内容"
    Content.TextColor3 = ActiveTheme.NotifContentColor
    Content.TextSize = IsMobile and 10 or 12
    Content.Font = Enum.Font.Gotham
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextTruncate = Enum.TextTruncate.AtEnd
    Content.TextTransparency = 1
    Content.Parent = TextContainer
    
    return {
        Frame = NotifFrame,
        Icon = Icon,
        Title = Title,
        Content = Content,
        Stroke = NotifStroke,
        TargetHeight = notifHeight,
        Width = notifWidth
    }
end

local function ProcessNotificationQueue()
    while #NotificationQueue > 0 and #ActiveNotifications < Config.MaxConcurrentNotifications do
        local notifData = table.remove(NotificationQueue, 1)
        task.spawn(function()
            ShowIslandNotification(
                notifData.title,
                notifData.content,
                notifData.notifType,
                notifData.duration,
                notifData.priority
            )
        end)
        task.wait(0.1)
    end
end

function ShowIslandNotification(title, content, notifType, duration, priority)
    duration = duration or Config.DefaultNotifDuration
    priority = priority or 1
    notifType = notifType or "info"
    
    if #ActiveNotifications >= Config.MaxConcurrentNotifications then
        if #NotificationQueue >= Config.MaxQueueSize then
            warn("[OPAI] 通知队列已满，丢弃通知: " .. title)
            return
        end
        
        local notifData = {
            title = title,
            content = content,
            notifType = notifType,
            duration = duration,
            priority = priority,
            timestamp = os.time()
        }
        
        if priority > 5 then
            table.insert(NotificationQueue, 1, notifData)
        else
            table.insert(NotificationQueue, notifData)
        end
        return
    end
    
    local notifId = HttpService:GenerateGUID(false):sub(1, 8)
    NotificationCounter = NotificationCounter + 1
    local layoutOrder = NotificationCounter
    
    local iconColor, iconText, strokeColor
    if notifType == "success" then
        iconColor = Color3.fromRGB(0, 255, 150)
        iconText = "✓"
        strokeColor = Color3.fromRGB(0, 255, 150)
    elseif notifType == "error" then
        iconColor = Color3.fromRGB(255, 80, 80)
        iconText = "✗"
        strokeColor = Color3.fromRGB(255, 80, 80)
    elseif notifType == "warning" then
        iconColor = Color3.fromRGB(255, 200, 0)
        iconText = "⚠"
        strokeColor = Color3.fromRGB(255, 200, 0)
    else
        iconColor = Color3.fromRGB(100, 150, 255)
        iconText = "ⓘ"
        strokeColor = Color3.fromRGB(100, 150, 255)
    end
    
    local notifUI = CreateNotificationUI(notifId, layoutOrder)
    notifUI.Icon.TextColor3 = iconColor
    notifUI.Icon.Text = iconText
    notifUI.Title.Text = title
    notifUI.Content.Text = content
    notifUI.Stroke.Color = strokeColor
    
    table.insert(ActiveNotifications, {
        id = notifId,
        ui = notifUI,
        startTime = tick()
    })
    
    task.spawn(function()
        MainIslandPulse()
    end)
    
    notifUI.Frame.Position = UDim2.new(0.5, -notifUI.Width/2, 0, -(IslandYPos + IslandHeight + 20))
    
    PlayTween("notif_" .. notifId .. "_fade_bg", notifUI.Frame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
    PlayTween("notif_" .. notifId .. "_fade_stroke", notifUI.Stroke,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Transparency = 0.5}
    )
    PlayTween("notif_" .. notifId .. "_fade_icon", notifUI.Icon,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0}
    )
    PlayTween("notif_" .. notifId .. "_fade_title", notifUI.Title,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0}
    )
    PlayTween("notif_" .. notifId .. "_fade_content", notifUI.Content,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {TextTransparency = 0}
    )
    
    task.wait(0.1)
    
    local targetYOffset = notifUI.TargetHeight * (#ActiveNotifications - 1) + Config.NotificationSpacing * (#ActiveNotifications - 1)
    
    local originalSize = notifUI.Frame.Size
    local shrinkSize = UDim2.new(0, notifUI.Width, 0, notifUI.TargetHeight * 0.8)
    notifUI.Frame.Size = shrinkSize
    
    PlayTween("notif_" .. notifId .. "_expand", notifUI.Frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, notifUI.Width, 0, notifUI.TargetHeight)}
    )
    
    task.wait(duration)
    
    PlayTween("notif_" .. notifId .. "_fade_out_bg", notifUI.Frame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    )
    PlayTween("notif_" .. notifId .. "_fade_out_stroke", notifUI.Stroke,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Transparency = 1}
    )
    PlayTween("notif_" .. notifId .. "_fade_out_icon", notifUI.Icon,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    PlayTween("notif_" .. notifId .. "_fade_out_title", notifUI.Title,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    PlayTween("notif_" .. notifId .. "_fade_out_content", notifUI.Content,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {TextTransparency = 1}
    )
    
    PlayTween("notif_" .. notifId .. "_shrink", notifUI.Frame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = UDim2.new(0, notifUI.Width, 0, 0)}
    )
    
    task.wait(0.45)
    
    if notifUI.Frame then
        notifUI.Frame:Destroy()
    end
    
    for i, activeNotif in ipairs(ActiveNotifications) do
        if activeNotif.id == notifId then
            table.remove(ActiveNotifications, i)
            break
    end
end

    ProcessNotificationQueue()
end

local ClickButton = Instance.new("TextButton")
ClickButton.Size = UDim2.new(1, 0, 1, 0)
ClickButton.BackgroundTransparency = 1
ClickButton.Text = ""
ClickButton.ZIndex = 15
ClickButton.AutoButtonColor = false
ClickButton.Parent = MainFrame

local clickStartTime = 0
local isDragging = false
local clickCount = 0
local lastClickTime = 0
local longPressActive = false

EventConnections.mouseEnter = ClickButton.MouseEnter:Connect(function()
    CloseButton.Visible = true
        local hoverWidth = IslandWidth + (IsMobile and 8 or 10)
        local hoverHeight = IslandHeight + (IsMobile and 2 or 2)
        
    PlayTween("hover", MainFrame, 
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {
            Size = UDim2.new(0, hoverWidth, 0, hoverHeight),
            Position = UDim2.new(0.5, -hoverWidth/2, originalPos.Y.Scale, originalPos.Y.Offset - 1)
        }
    )
end)

EventConnections.mouseLeave = ClickButton.MouseLeave:Connect(function()
    CloseButton.Visible = false
    PlayTween("hover_leave", MainFrame, 
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {
            Size = UDim2.new(0, IslandWidth, 0, IslandHeight),
            Position = originalPos
        }
    )
end)

EventConnections.mouseDown = ClickButton.MouseButton1Down:Connect(function()
    clickStartTime = tick()
    isDragging = false
    longPressActive = false
    
    task.spawn(function()
        task.wait(0.8)
        if tick() - clickStartTime >= 0.8 and not isDragging then
            longPressActive = true
        end
    end)
    
        local pressWidth = IslandWidth - 5
        local pressHeight = IslandHeight - 1
        
    PlayTween("press", MainFrame, 
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {
            Size = UDim2.new(0, pressWidth, 0, pressHeight),
            Position = UDim2.new(0.5, -pressWidth/2, originalPos.Y.Scale, originalPos.Y.Offset + 0.5)
        }
    )
end)

EventConnections.mouseUp = ClickButton.MouseButton1Up:Connect(function()
    local clickDuration = tick() - clickStartTime
    
    PlayTween("release", MainFrame, 
        TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), 
        {
            Size = UDim2.new(0, IslandWidth, 0, IslandHeight),
            Position = originalPos
        }
    )
    
    local currentTime = tick()
    if currentTime - lastClickTime < 0.3 then
        clickCount = clickCount + 1
        if clickCount == 2 then
            ToggleTheme()
            clickCount = 0
        end
    else
        clickCount = 1
    end
    lastClickTime = currentTime
    
    if clickDuration < 0.3 and not isDragging and not longPressActive then
        local VirtualInputManager = game:GetService("VirtualInputManager")
        
        task.spawn(function()
            task.wait(0.15)
            
            pcall(function()
                local keyCode = IsMobile and Enum.KeyCode.RightShift or Enum.KeyCode.K
                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            end)
        end)
    end
end)

EventConnections.closeButton = CloseButton.MouseButton1Click:Connect(function()
    ToggleVisibility()
end)

local dragging = false
local dragInput, dragStart, startPos
local touchAreaExpansion = IsMobile and 10 or 0
local inputChangedConnection = nil

local function updateDrag(input)
    local delta = input.Position - dragStart
    local distance = delta.Magnitude
    
    if distance > (IsMobile and 8 or 5) then
        isDragging = true
    end
    
    local newPos = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    
    MainFrame.Position = newPos
    originalPos = newPos
end

EventConnections.inputBegan = MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        if inputChangedConnection then
            inputChangedConnection:Disconnect()
        end
        
        inputChangedConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                
                if isDragging then
                    MainFrame.Size = UDim2.new(0, IslandWidth, 0, IslandHeight)
                    SavePosition(originalPos)
                end
                
                if inputChangedConnection then
                    inputChangedConnection:Disconnect()
                    inputChangedConnection = nil
                end
            end
        end)
    end
end)

EventConnections.inputChanged = MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

EventConnections.userInputChanged = UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

task.spawn(function()
    while IsRunning and MainFrame and MainFrame.Parent do
        task.wait(1)
        pcall(function()
            if TimeLabel and TimeLabel.Parent then
            TimeLabel.Text = os.date("%H:%M:%S")
            end
        end)
    end
end)

task.spawn(function()
    while IsRunning and MainFrame and MainFrame.Parent do
        pcall(function()
            if StatusDot and StatusDot.Parent then
            TweenService:Create(
                StatusDot,
                TweenInfo.new(1, Enum.EasingStyle.Sine),
                {BackgroundTransparency = 0.5}
            ):Play()
            end
        end)
        task.wait(1)
        
        pcall(function()
            if StatusDot and StatusDot.Parent then
            TweenService:Create(
                StatusDot,
                TweenInfo.new(1, Enum.EasingStyle.Sine),
                {BackgroundTransparency = 0}
            ):Play()
            end
        end)
        task.wait(1)
    end
end)

if Config.DemoMode then
    task.wait(1)
    ShowIslandNotification("灵动岛", "加载成功", "success", 2)
    
    task.wait(3)
    ShowIslandNotification("提示", "双击切换主题", "info", 2)
    
    task.wait(3)
    ShowIslandNotification("提示", "长按查看历史", "info", 2)
end

local function Destroy()
    IsRunning = false
    
    for name, connection in pairs(EventConnections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    
    if inputChangedConnection then
        inputChangedConnection:Disconnect()
        inputChangedConnection = nil
    end
    if panelInputChangedConnection then
        panelInputChangedConnection:Disconnect()
        panelInputChangedConnection = nil
    end
    
    for name, tween in pairs(CurrentTweens) do
        if tween then
            tween:Cancel()
        end
    end
    
    for _, activeNotif in ipairs(ActiveNotifications) do
        if activeNotif.ui and activeNotif.ui.Frame then
            activeNotif.ui.Frame:Destroy()
        end
    end
    
    ActiveNotifications = {}
    NotificationQueue = {}
    
    if DynamicIsland then
        DynamicIsland:Destroy()
    end
    if HiddenContainer then
        HiddenContainer:Destroy()
    end
    
    _G.ShowIslandNotification = nil
    _G.DynamicIsland = nil
    _G.OPAI_ISLAND_LOADED = nil
end

if _G.OPAI_ISLAND_LOADED then
    if _G.DynamicIsland and _G.DynamicIsland.Destroy then
        _G.DynamicIsland.Destroy()
    end
    task.wait(0.5)
end
_G.OPAI_ISLAND_LOADED = true

local DynamicIslandModule = {}

DynamicIslandModule.ShowNotification = ShowIslandNotification
DynamicIslandModule.ToggleTheme = ToggleTheme
DynamicIslandModule.ToggleVisibility = ToggleVisibility
DynamicIslandModule.Destroy = Destroy
DynamicIslandModule.Config = Config

_G.ShowIslandNotification = ShowIslandNotification
_G.DynamicIsland = DynamicIslandModule

return DynamicIslandModule
