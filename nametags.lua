local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local TextChatService = game:GetService("TextChatService")

local TELEPORT_CONFIG = { DISTANCE = 5, HEIGHT = 0.5 }

local Styles = {
  AK = {
    Ranks = {
      ["AK OWNER"] = {
        users = {}, primary = Color3.fromRGB(20, 20, 20), GlitchName = true,
        accent = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 128, 128)), ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 255, 230)) },
        emoji = "👑", image = ""
      }
    },
    Config = {
      TAG_SIZE = UDim2.new(0, 0, 0, 32), 
      TAG_OFFSET = Vector3.new(0, 2.2, 0), 
      MAX_DISTANCE = 200000,
      DISTANCE_THRESHOLD = 50, HYSTERESIS = 5, CORNER_RADIUS = UDim.new(0, 10),
      PARTICLE_COUNT = 100, PARTICLE_SPEED = 1, 
      MINI_OFFSET = Vector3.new(0, 1.7, 0)
    }
  },
  DC = {
    Ranks = {
      ["OWNER"] = {
        users = {"xcanobae"}, primary = Color3.fromRGB(30, 31, 34), accent = Color3.fromRGB(255, 255, 255),
        nameplateImage = "rbxassetid://104260777190687", aspectRatio = 4.5, profileFrame = "rbxassetid://99476252618929",
        profileDecoration = "rbxassetid://128640287934877", statusIcon = "rbxassetid://109657483570183"
      },
      ["SYNC USER"] = {
        users = {}, primary = Color3.fromRGB(30, 31, 34), accent = Color3.fromRGB(88, 101, 242),
        nameplateImage = "rbxassetid://104260777190687", aspectRatio = 4.0, profileFrame = "",
        profileDecoration = "rbxassetid://119461307952420", statusIcon = "rbxassetid://137693122197794"
      }
    },
    Config = {
      TAG_HEIGHT = 50, 
      TAG_OFFSET = Vector3.new(0, 2.4, 0), 
      MINI_OFFSET = Vector3.new(0, 2.2, 0),
      MAX_DISTANCE = 200, DISTANCE_THRESHOLD = 15, HYSTERESIS = 5, CORNER_RADIUS = UDim.new(0, 8),
      WIDTH_MULTIPLIER = 1.15
    }
  },
  PH = {
    Ranks = {
      ["emre-lean"] = {
        users = {"pashaprada7", "Phibi"}, name1 = "emre", name2 = "lean"
      },
      ["your-name"] = {
        users = {"pashaprada8"}, name1 = "Your", name2 = "Name"
      }
    },
    Config = {
      TAG_HEIGHT = 40, MINI_WIDTH = 50, MINI_HEIGHT = 55, 
      TAG_OFFSET = Vector3.new(0, 2.7, 0), 
      MINI_OFFSET = Vector3.new(0, 2.5, 0), 
      MAX_DISTANCE = 200, DISTANCE_THRESHOLD = 15, HYSTERESIS = 5, 
      ANIMATION_SPEED = 0.4, ANIMATION_EASING = Enum.EasingStyle.Quart,
    }
  }
}

local ChatWhitelist = {}; local playerToTagInfo = {}
for styleName, styleData in pairs(Styles) do for rankName, rankData in pairs(styleData.Ranks) do if rankData.users then for _, username in ipairs(rankData.users) do playerToTagInfo[username:lower()] = {style = styleName, rank = rankName} end end end end

local function teleportToPlayer(targetPlayer)
  local localPlayer = Players.LocalPlayer; local character = localPlayer.Character; local targetCharacter = targetPlayer.Character; if not (character and targetCharacter) then return end; local hrp = character:FindFirstChild("HumanoidRootPart"); local targetHRP = targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("HumanoidRootPart"); if not (hrp and targetHRP) then return end; local targetCFrame = targetHRP.CFrame; local teleportPosition = targetCFrame.Position - (targetCFrame.LookVector * TELEPORT_CONFIG.DISTANCE) + Vector3.new(0, TELEPORT_CONFIG.HEIGHT, 0); local function createParticles(position) local part = Instance.new("Part", workspace); part.Transparency = 1; part.Anchored = true; part.CanCollide = false; part.Position = position; local emitter = Instance.new("ParticleEmitter", part); emitter.Texture = "http://www.roblox.com/asset/?id=89296104222585"; emitter.Size = NumberSequence.new(4); emitter.Lifetime = NumberRange.new(0.15, 0.15); emitter.Rate = 100; emitter.TimeScale = 0.25; game.Debris:AddItem(part, 2) end; createParticles(hrp.Position); createParticles(teleportPosition); local fadeTime = 0.1; local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out); local characterParts = {}; for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then table.insert(characterParts, part); TweenService:Create(part, tweenInfo, {Transparency = 1}):Play() end end; task.wait(fadeTime); hrp.CFrame = CFrame.new(teleportPosition, targetHRP.Position); local sound = Instance.new("Sound", hrp); sound.SoundId = "rbxassetid://5066021887"; sound.Volume = 0.5; sound:Play(); game.Debris:AddItem(sound, 2); for _, part in ipairs(characterParts) do if part and part.Parent then TweenService:Create(part, tweenInfo, {Transparency = 0}):Play() end end
end

local function getTextWidth(text, font, textSize, referenceHeight)
  local ySize = referenceHeight or 50; return math.ceil(TextService:GetTextSize(text, textSize, font, Vector2.new(2000, ySize)).X)
end

local function createAkParticles(tag, parent, accentColor, styleConfig)
  for i = 1, styleConfig.PARTICLE_COUNT do local particle = Instance.new("Frame", parent); particle.Name = "Particle_" .. i; particle.Size = UDim2.new(0, math.random(1, 6), 0, math.random(1, 6)); particle.Position = UDim2.new(math.random(), math.random(-10, 10), 1 + math.random() * 0.5, 0); particle.BackgroundTransparency = math.random(0, 0.4); particle.BorderSizePixel = 0; local pCorner = Instance.new("UICorner", particle); pCorner.CornerRadius = UDim.new(1, 10); if typeof(accentColor) == "ColorSequence" then local g = Instance.new("UIGradient", particle); g.Color = accentColor; g.Rotation = math.random(0, 360) else particle.BackgroundColor3 = accentColor end; spawn(function() while tag and tag.Parent do local startX, startOffsetX = math.random(), math.random(-10, 10); particle.Position = UDim2.new(startX, startOffsetX, 1 + math.random() * 0.5, 0); particle.Size = UDim2.new(0, math.random(1, 6), 0, math.random(1, 6)); particle.BackgroundTransparency = math.random(0, 0.4); local duration = math.random(10, 40) / (styleConfig.PARTICLE_SPEED * 10); local endX = startX + (math.random() - 0.5) * 0.3; local tween = TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Position = UDim2.new(endX, startOffsetX, -0.5, math.random(-20, 20)), BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0) }); tween:Play(); task.wait(duration) end end) end
end

local function createAkTag(character, player, rankName, rankData, styleConfig)
  local head = character:FindFirstChild("Head"); if not head then return end
  if character:FindFirstChildOfClass("Humanoid") then character:FindFirstChildOfClass("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
  local tag = Instance.new("BillboardGui", Players.LocalPlayer.PlayerGui); tag.Name = "RankTag"; tag.Adornee = head; tag.MaxDistance = styleConfig.MAX_DISTANCE; tag.LightInfluence = 0; tag.ResetOnSpawn = false;
  tag.Active = true; tag.AlwaysOnTop = true

  if typeof(rankData.accent) == "ColorSequence" then local bC = Instance.new("Frame", tag); bC.Name = "TagBorderContainer"; bC.Size = UDim2.new(1, 3, 1, 3); bC.Position = UDim2.new(0, -1.5, 0, -1.5); bC.BackgroundTransparency = 1; bC.ZIndex = 0; local gL = Instance.new("Frame", bC); gL.Size = UDim2.new(1, 0, 1, 0); gL.BackgroundColor3 = Color3.new(1, 1, 1); gL.BorderSizePixel = 0; local g = Instance.new("UIGradient", gL); g.Color = rankData.accent; local bCr = Instance.new("UICorner", gL); bCr.CornerRadius = styleConfig.CORNER_RADIUS end
  
  local container = Instance.new("TextButton", tag); container.Name = "TagContainer"; container.Size = UDim2.new(1, 0, 1, 0); container.BackgroundColor3 = rankData.primary; container.BackgroundTransparency = 0.15; container.BorderSizePixel = 0; container.ClipsDescendants = true; container.ZIndex = 1; container.Text = ""; container.AutoButtonColor = false
  if player ~= Players.LocalPlayer then container.MouseButton1Click:Connect(function() teleportToPlayer(player) end) end
  
  local containerCorner = Instance.new("UICorner", container); containerCorner.CornerRadius = styleConfig.CORNER_RADIUS
  local particlesContainer = Instance.new("Frame", container); particlesContainer.Name = "ParticlesContainer"; particlesContainer.Size = UDim2.new(1, 0, 1, 0); particlesContainer.BackgroundTransparency = 1; particlesContainer.ZIndex = 2; particlesContainer.ClipsDescendants = true
  createAkParticles(tag, particlesContainer, rankData.accent, styleConfig)
  
  local icon; if rankData.image and rankData.image ~= "" then icon = Instance.new("ImageLabel", container); icon.Image = rankData.image else icon = Instance.new("TextLabel", container); icon.Text = rankData.emoji or "⭐"; icon.Font = Enum.Font.GothamBold; icon.TextSize = 22; icon.TextColor3 = Color3.new(1, 1, 1) end; icon.Name = "Icon"; icon.Size = UDim2.new(0, 30, 0, 30); icon.Position = UDim2.new(0, 8, 0.5, -15); icon.BackgroundTransparency = 1; icon.ZIndex = 5
  local dNLabel = Instance.new("TextLabel", container); dNLabel.Name = "DisplayNameLabel"; dNLabel.BackgroundTransparency = 1; dNLabel.Text = "@" .. (player.DisplayName or player.Name); dNLabel.TextSize = 10; dNLabel.Font = Enum.Font.GothamBold; dNLabel.TextXAlignment = Enum.TextXAlignment.Left; dNLabel.ZIndex = 5; if typeof(rankData.accent) == "ColorSequence" then local g = Instance.new("UIGradient", dNLabel); g.Color = rankData.accent; dNLabel.TextColor3 = Color3.new(1, 1, 1) else dNLabel.TextColor3 = rankData.accent end
  local rLabel = Instance.new("TextLabel", container); rLabel.Name = "RankLabel"; rLabel.BackgroundTransparency = 1; rLabel.Text = rankName; rLabel.TextSize = 14; rLabel.Font = Enum.Font.GothamBold; rLabel.TextXAlignment = Enum.TextXAlignment.Left; rLabel.ZIndex = 5; if typeof(rankData.accent) == "ColorSequence" then local g = Instance.new("UIGradient", rLabel); g.Color = rankData.accent; rLabel.TextColor3 = Color3.new(1, 1, 1) else rLabel.TextColor3 = rankData.accent end
  
  spawn(function() while tag and tag.Parent do if rankData.GlitchName then local t = rankName; local d = 0.05; local nD = 0.3; local c = {"@", "#", "$", "%", "&", "!"}; for _ = 1, 5 do if not rLabel.Parent then return end; rLabel.Text = t; task.wait(nD); for _ = 1, 3 do local gT = ""; for i = 1, #t do if math.random() < 0.3 then gT ..= c[math.random(#c)] else gT ..= string.sub(t, i, i) end end; rLabel.Text = gT; task.wait(d) end end; rLabel.Text = t end; task.wait(3) end end)
  task.wait(); local rW = getTextWidth(rLabel.Text, rLabel.Font, rLabel.TextSize, styleConfig.TAG_SIZE.Y.Offset); local nW = getTextWidth(dNLabel.Text, dNLabel.Font, dNLabel.TextSize, styleConfig.TAG_SIZE.Y.Offset); local totalWidth = 8 + 30 + 8 + math.max(rW, nW) + 16
  tag.Size = UDim2.new(0, totalWidth, 0, styleConfig.TAG_SIZE.Y.Offset); tag.StudsOffset = styleConfig.TAG_OFFSET; local tBX = 8 + 30 + 8; rLabel.Position = UDim2.new(0, tBX, 0, 3); rLabel.Size = UDim2.new(0, rW, 0, 16); dNLabel.Position = UDim2.new(0, tBX, 0, 17); dNLabel.Size = UDim2.new(0, nW, 0, 16)
  
  local isMinimized = false; local FULL_SIZE = UDim2.new(0, totalWidth, 0, styleConfig.TAG_SIZE.Y.Offset); local MINI_SIZE = UDim2.new(0, 40, 0, 40)
  spawn(function() while tag and tag.Parent do local lH = Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head"); if lH and head.Parent then local dist = (lH.Position - head.Position).Magnitude; local tI = TweenInfo.new(0.5); if dist > (styleConfig.DISTANCE_THRESHOLD + styleConfig.HYSTERESIS) and not isMinimized then isMinimized = true; TweenService:Create(tag, tI, {Size = MINI_SIZE, StudsOffset = styleConfig.MINI_OFFSET}):Play(); TweenService:Create(rLabel, tI, {TextTransparency = 1}):Play(); TweenService:Create(dNLabel, tI, {TextTransparency = 1}):Play(); TweenService:Create(icon, tI, {Position = UDim2.new(0.5, -15, 0.5, -15)}):Play(); TweenService:Create(containerCorner, tI, {CornerRadius = UDim.new(1, 0)}):Play() elseif dist < (styleConfig.DISTANCE_THRESHOLD - styleConfig.HYSTERESIS) and isMinimized then isMinimized = false; TweenService:Create(tag, tI, {Size = FULL_SIZE, StudsOffset = styleConfig.TAG_OFFSET}):Play(); TweenService:Create(rLabel, tI, {TextTransparency = 0}):Play(); TweenService:Create(dNLabel, tI, {TextTransparency = 0}):Play(); TweenService:Create(icon, tI, {Position = UDim2.new(0, 8, 0.5, -15)}):Play(); TweenService:Create(containerCorner, tI, {CornerRadius = styleConfig.CORNER_RADIUS}):Play() end end; task.wait(0.2) end end)
end

local function createDcTag(character, player, rankName, rankData, styleConfig)
    local head = character and character:FindFirstChild("Head"); if not head then return end
    local tag = Instance.new("BillboardGui", Players.LocalPlayer.PlayerGui); tag.Name = "RankTag"; tag.Adornee = head; tag.MaxDistance = styleConfig.MAX_DISTANCE; tag.LightInfluence = 0; tag.ResetOnSpawn = false
    tag.Active = true
    tag.AlwaysOnTop = true

    local mainFrame = Instance.new("TextButton", tag); mainFrame.Name = "MainFrame"; mainFrame.BackgroundColor3 = rankData.primary or Color3.fromRGB(30, 31, 34); mainFrame.ClipsDescendants = true; mainFrame.Size = UDim2.new(1,0,1,0); mainFrame.Text = ""; mainFrame.AutoButtonColor = false
    if player ~= Players.LocalPlayer then mainFrame.MouseButton1Click:Connect(function() teleportToPlayer(player) end) end

    local frameCorner = Instance.new("UICorner", mainFrame); frameCorner.CornerRadius = styleConfig.CORNER_RADIUS
    local nameplate = Instance.new("ImageLabel", mainFrame); nameplate.Name = "Nameplate"; nameplate.Size = UDim2.new(1, 0, 1, 0); nameplate.BackgroundTransparency = 1; nameplate.Image = rankData.nameplateImage or ""; nameplate.ImageTransparency = 0.5; nameplate.ZIndex = 1; nameplate.ScaleType = Enum.ScaleType.Stretch
    
    local pC = Instance.new("Frame", mainFrame); pC.Name = "ProfileContainer"; pC.Size = UDim2.new(0, 48, 0, 48); pC.Position = UDim2.new(0, 5, 0.5, -24); pC.BackgroundTransparency = 1; pC.ZIndex = 5
    local pIUrl = rankData.profileFrame; if not pIUrl or pIUrl == "" then local s, t = pcall(Players.GetUserThumbnailAsync, Players, player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48); if s and t then pIUrl = t end end
    if pIUrl then local p = Instance.new("ImageLabel", pC); p.Name = "ProfilePic"; p.Size = UDim2.new(0, 40, 0, 40); p.Position = UDim2.new(0.5, -20, 0.5, -20); p.Image = pIUrl; p.BackgroundTransparency = 1; p.ZIndex = 4; local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(1, 0) end
    if rankData.profileDecoration and rankData.profileDecoration ~= "" then local d = Instance.new("ImageLabel", pC); d.Name = "Decoration"; d.Size = UDim2.new(0, 48, 0, 48); d.Position = UDim2.new(0.5, -24, 0.5, -24); d.Image = rankData.profileDecoration; d.BackgroundTransparency = 1; d.ZIndex = 5 end
    if rankData.statusIcon and rankData.statusIcon ~= "" then
        local statusBg = Instance.new("Frame", pC); statusBg.Name = "StatusBackground"; statusBg.Size = UDim2.new(0, 16, 0, 16); statusBg.Position = UDim2.new(1, -16, 1, -16); statusBg.BackgroundColor3 = mainFrame.BackgroundColor3; statusBg.ZIndex = 6
        local statusBgCorner = Instance.new("UICorner", statusBg); statusBgCorner.CornerRadius = UDim.new(1, 0)
        local aspectConstraint = Instance.new("UIAspectRatioConstraint", statusBg); aspectConstraint.AspectRatio = 1.0
        local statusIcon = Instance.new("ImageLabel", statusBg); statusIcon.Name = "StatusIcon"; statusIcon.Size = UDim2.new(1, -6, 1, -6); statusIcon.Position = UDim2.new(0.5, 0, 0.5, 0); statusIcon.AnchorPoint = Vector2.new(0.5, 0.5); statusIcon.Image = rankData.statusIcon; statusIcon.BackgroundTransparency = 1; statusIcon.ZIndex = 7
    end
    local tC = Instance.new("Frame", mainFrame); tC.Name = "TextContainer"; tC.Position = UDim2.new(0, 60, 0, 0); tC.BackgroundTransparency = 1; tC.ZIndex = 4; local uLL = Instance.new("UIListLayout", tC); uLL.FillDirection = Enum.FillDirection.Vertical; uLL.VerticalAlignment = Enum.VerticalAlignment.Center; uLL.Padding = UDim.new(0, -2); uLL.SortOrder = Enum.SortOrder.LayoutOrder
    local rL = Instance.new("TextLabel", tC); rL.Name = "RankLabel"; rL.Font = Enum.Font.GothamBold; rL.Text = rankName; rL.TextSize = 18; rL.TextColor3 = rankData.accent or Color3.new(1,1,1); rL.BackgroundTransparency = 1; rL.TextXAlignment = Enum.TextXAlignment.Left; rL.Size = UDim2.new(1, -5, 0, 20); rL.LayoutOrder = 1
    local pNL = Instance.new("TextLabel", tC); pNL.Name = "PlayerNameLabel"; pNL.Font = Enum.Font.Gotham; pNL.Text = player.DisplayName; pNL.TextSize = 12; pNL.TextColor3 = Color3.fromRGB(255, 255, 255); pNL.BackgroundTransparency = 1; pNL.TextXAlignment = Enum.TextXAlignment.Left; pNL.Size = UDim2.new(1, -5, 0, 15); pNL.LayoutOrder = 2
    task.wait(); local totalWidth = ((rankData.aspectRatio and rankData.aspectRatio > 0) and (styleConfig.TAG_HEIGHT * rankData.aspectRatio) or 220) * (styleConfig.WIDTH_MULTIPLIER or 1); local FULL_SIZE = UDim2.new(0, totalWidth, 0, styleConfig.TAG_HEIGHT)
    tag.Size = FULL_SIZE; tag.StudsOffset = styleConfig.TAG_OFFSET; tC.Size = UDim2.new(1, -70, 1, -10)
    local isMinimized = false; local MINI_SIZE = UDim2.new(0, 50, 0, 50)
    spawn(function() while tag and tag.Parent do local lPC = Players.LocalPlayer and Players.LocalPlayer.Character; if lPC and lPC:FindFirstChild("Head") and head and head.Parent then local dist = (lPC.Head.Position - head.Position).Magnitude; local tI = TweenInfo.new(0.3); if dist > (styleConfig.DISTANCE_THRESHOLD + styleConfig.HYSTERESIS) and not isMinimized then isMinimized = true; TweenService:Create(tag, tI, {Size = MINI_SIZE, StudsOffset = styleConfig.MINI_OFFSET}):Play(); TweenService:Create(frameCorner, tI, {CornerRadius = UDim.new(1, 0)}):Play(); TweenService:Create(nameplate, tI, {ImageTransparency = 1}):Play(); TweenService:Create(pC, tI, {Position = UDim2.new(0.5, -24, 0.5, -24)}):Play(); for _, c in ipairs(tC:GetChildren()) do if c:IsA("TextLabel") then TweenService:Create(c, tI, {TextTransparency = 1}):Play() end end elseif dist < (styleConfig.DISTANCE_THRESHOLD - styleConfig.HYSTERESIS) and isMinimized then isMinimized = false; TweenService:Create(tag, tI, {Size = FULL_SIZE, StudsOffset = styleConfig.TAG_OFFSET}):Play(); TweenService:Create(frameCorner, tI, {CornerRadius = styleConfig.CORNER_RADIUS}):Play(); TweenService:Create(nameplate, tI, {ImageTransparency = 0.5}):Play(); TweenService:Create(pC, tI, {Position = UDim2.new(0, 5, 0.5, -24)}):Play(); for _, c in ipairs(tC:GetChildren()) do if c:IsA("TextLabel") then TweenService:Create(c, tI, {TextTransparency = 0}):Play() end end end end; task.wait(0.2) end end)
end

local function createPhTag(character, player, rankName, rankData, styleConfig)
    local head = character:FindFirstChild("Head"); if not head then return end
    if character:FindFirstChildOfClass("Humanoid") then character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
    local tag = Instance.new("BillboardGui", Players.LocalPlayer.PlayerGui); tag.Name = "RankTag"; tag.Adornee = head; tag.MaxDistance = styleConfig.MAX_DISTANCE; tag.LightInfluence = 0; tag.ResetOnSpawn = false
    tag.Active = true
    tag.AlwaysOnTop = true

    local mainFrame = Instance.new("TextButton", tag); mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18); mainFrame.Size = UDim2.new(1,0,1,0); mainFrame.Text = ""; mainFrame.AutoButtonColor = false
    if player ~= Players.LocalPlayer then mainFrame.MouseButton1Click:Connect(function() teleportToPlayer(player) end) end

    local mainStroke = Instance.new("UIStroke", mainFrame); mainStroke.Color = Color3.fromRGB(70, 70, 70); mainStroke.Thickness = 1.5; mainStroke.LineJoinMode = Enum.LineJoinMode.Round
    local mainCorner = Instance.new("UICorner", mainFrame); mainCorner.CornerRadius = UDim.new(0, 8)
    local n1L = Instance.new("TextLabel", mainFrame); n1L.Font = Enum.Font.GothamBold; n1L.Text = rankData.name1; n1L.TextSize = 22; n1L.TextColor3 = Color3.fromRGB(255, 255, 255); n1L.BackgroundTransparency = 1; n1L.AnchorPoint = Vector2.new(0.5, 0.5)
    local n2F = Instance.new("Frame", mainFrame); n2F.BackgroundColor3 = Color3.fromRGB(249, 166, 25); n2F.AnchorPoint = Vector2.new(0.5, 0.5); local n2C = Instance.new("UICorner", n2F); n2C.CornerRadius = UDim.new(0, 6)
    local n2L = Instance.new("TextLabel", n2F); n2L.Font = Enum.Font.GothamBold; n2L.Text = rankData.name2; n2L.TextSize = 22; n2L.TextColor3 = Color3.fromRGB(0, 0, 0); n2L.BackgroundTransparency = 1; n2L.Size = UDim2.new(1, 0, 1, 0)
    
    local n1W = getTextWidth(n1L.Text, n1L.Font, n1L.TextSize); local n2W = getTextWidth(n2L.Text, n2L.Font, n2L.TextSize); local n2FW = n2W + 20; local tW = 10 + n1W + 8 + n2FW + 10
    local m_n1TS = math.floor(styleConfig.MINI_HEIGHT * 0.3); local m_n2TS = math.floor(styleConfig.MINI_HEIGHT * 0.3); local m_n1W = getTextWidth(rankData.name1, n1L.Font, m_n1TS); local m_n2FH = math.floor(styleConfig.MINI_HEIGHT * 0.4); local m_n2FW = getTextWidth(rankData.name2, n2L.Font, m_n2TS) + 12

    local normalState = {TagSize = UDim2.new(0, tW, 0, styleConfig.TAG_HEIGHT), FrameCorner = UDim.new(0, 8), n1P = UDim2.new(0, 10 + n1W/2, 0.5, 0), n2P = UDim2.new(1, -(10 + n2FW/2), 0.5, 0), n1S = UDim2.new(0, n1W, 0, 24), n2FS = UDim2.new(0, n2FW, 0, 30), n1TS = 22, n2TS = 22}
    local miniState = {TagSize = UDim2.new(0, styleConfig.MINI_WIDTH, 0, styleConfig.MINI_HEIGHT), FrameCorner = UDim.new(0, 12), n1P = UDim2.new(0.5, 0, 0.3, 0), n2P = UDim2.new(0.5, 0, 0.68, 0), n1S = UDim2.new(0, m_n1W, 0, m_n1TS), n2FS = UDim2.new(0, m_n2FW, 0, m_n2FH), n1TS = m_n1TS, n2TS = m_n2TS}
    
    tag.Size = normalState.TagSize; tag.StudsOffset = styleConfig.TAG_OFFSET; n1L.Position = normalState.n1P; n1L.Size = normalState.n1S; n2F.Position = normalState.n2P; n2F.Size = normalState.n2FS

    local isMinimized = false; local active = true; tag.Destroying:Connect(function() active = false end); local tweenInfo = TweenInfo.new(styleConfig.ANIMATION_SPEED, styleConfig.ANIMATION_EASING)
    task.spawn(function() while active do local lPC = Players.LocalPlayer and Players.LocalPlayer.Character; if lPC and head.Parent then local dist = (lPC.Head.Position - head.Position).Magnitude; if dist > (styleConfig.DISTANCE_THRESHOLD + styleConfig.HYSTERESIS) and not isMinimized then isMinimized = true; TweenService:Create(tag, tweenInfo, {Size = miniState.TagSize, StudsOffset = styleConfig.MINI_OFFSET}):Play(); TweenService:Create(mainCorner, tweenInfo, {CornerRadius = miniState.FrameCorner}):Play(); TweenService:Create(n1L, tweenInfo, {Position = miniState.n1P, Size = miniState.n1S, TextSize = miniState.n1TS}):Play(); TweenService:Create(n2F, tweenInfo, {Position = miniState.n2P, Size = miniState.n2FS}):Play(); TweenService:Create(n2L, tweenInfo, {TextSize = miniState.n2TS}):Play() elseif dist < (styleConfig.DISTANCE_THRESHOLD - styleConfig.HYSTERESIS) and isMinimized then isMinimized = false; TweenService:Create(tag, tweenInfo, {Size = normalState.TagSize, StudsOffset = styleConfig.TAG_OFFSET}):Play(); TweenService:Create(mainCorner, tweenInfo, {CornerRadius = normalState.FrameCorner}):Play(); TweenService:Create(n1L, tweenInfo, {Position = normalState.n1P, Size = normalState.n1S, TextSize = normalState.n1TS}):Play(); TweenService:Create(n2F, tweenInfo, {Position = normalState.n2P, Size = normalState.n2FS}):Play(); TweenService:Create(n2L, tweenInfo, {TextSize = normalState.n2TS}):Play() end else active = false end; task.wait(0.2) end end)
end

local function applyPlayerTag(player)
    if not player or not player.Character then return end
    local tagInfo = playerToTagInfo[player.Name:lower()] or (ChatWhitelist[player.Name:lower()] and {style = "DC", rank = "SYNC USER"})
    if tagInfo then
        local styleData = Styles[tagInfo.style]; local rankData = styleData and styleData.Ranks[tagInfo.rank]
        if rankData and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                for _, gui in ipairs(Players.LocalPlayer.PlayerGui:GetChildren()) do if gui:IsA("BillboardGui") and gui.Name == "RankTag" and gui.Adornee == head then gui:Destroy() end end
                if tagInfo.style == "DC" then createDcTag(player.Character, player, tagInfo.rank, rankData, styleData.Config)
                elseif tagInfo.style == "AK" then createAkTag(player.Character, player, tagInfo.rank, rankData, styleData.Config)
                elseif tagInfo.style == "PH" then createPhTag(player.Character, player, tagInfo.rank, rankData, styleData.Config)
                end
            end
        end
    end
end

local playerConnections = {}
local function setupPlayer(player)
    playerConnections[player] = player.CharacterAdded:Connect(function(character) task.wait(1); applyPlayerTag(player) end)
    if player.Character then task.spawn(applyPlayerTag, player) end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player) if playerConnections[player] then playerConnections[player]:Disconnect(); playerConnections[player] = nil end end)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

task.wait(1)
local localPlayer = Players.LocalPlayer
if localPlayer and not playerToTagInfo[localPlayer.Name:lower()] then
    ChatWhitelist[localPlayer.Name:lower()] = true
    task.spawn(applyPlayerTag, localPlayer)
    pcall(function() if TextChatService and TextChatService.TextChannels:FindFirstChild("RBXGeneral") then TextChatService.TextChannels.RBXGeneral:SendAsync("     ") end end)
end

