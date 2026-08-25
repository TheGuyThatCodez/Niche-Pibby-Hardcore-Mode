local RepStorage = game:GetService("ReplicatedStorage")

RepStorage.RemotesFolder.CaptionClient:Fire(`Loading...`)

local rusherspawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/DOORS-Entity-Spawner-V2/main/init.luau"))()

local seed = Random.new(RepStorage.GameData.GameSeed.Value)
local tweenservice = game:GetService("TweenService")
local collectionservice = game:GetService("CollectionService")

local door = RepStorage.GameData.LatestRoom

--
local alldeathhints = {
	["Shady"] = {
		name = "Shady",
		hint_moonlight = {
			"You died to Shady...",
			"Make sure it cannot reach you when it attacks.",
			"You may need to backtrack to find a suitable hiding spot.",
			"Don't give up!"
		},
		hint_starlight = {
			"Hmm. What was it this time?",
			"Oh... That one.",
			"Hmm, lets say...",
			"Make sure you arent too hurt.",
			"And remember where to hide if need be.",
			"See you next time.",
		},
		hint_glitch = {
			"CAUSE OF DEATH:\n\n    [SHADY]",
			"THIS ENTITY TARGETS LOW HEALTH PREY",
			"IT ATTEMPTS TO PICK THEM OFF \nWHEN NO HIDING SPOTS ARE READILY ACCESSIBLE",
			"TO SURVIVE, KEEP YOUR \nHEALTH ABOVE \n\n[60] \n\nTO BE FULLY SAFE",
			"OTHERWISE, HIDE WHEN BIRD NOISES AND A SLIGHT \nSATURATION LOSS IS DETECTED",
		}
	}
}
--
local subfloors = {"Rooms","Backdoor","Garden","Archives"}
local function KillWithReason(reason: string)
	local hintdata = alldeathhints[reason]
	local deathscreentype = {"Blue","moonlight"}
	if RepStorage.GameData.Floor.Value == "Party" then
		deathscreentype = nil
	elseif RepStorage.GameData.IsVision.Value then
		deathscreentype = {"Glitch","glitch"}
	elseif table.find(subfloors,RepStorage.GameData.Floor.Value) then
		deathscreentype = {"Yellow","starlight"}
	end

	replicatesignal(game.Players.LocalPlayer.Kill)

	task.defer(function()
		for i=1,5,0.05 do
			task.wait(0.05)
			RepStorage.GameStats[`Player_{game.Players.LocalPlayer.Name}`].Total.DeathCause.Value = hintdata.name
			if deathscreentype ~= nil then
				firesignal(RepStorage.RemotesFolder.DeathHint.OnClientEvent,hintdata[`hint_{deathscreentype[2]}`],deathscreentype[1])
			end
		end
	end)
end
--[[
CheckChases and CheckMilestone are from a range of 0-2
0 = Do not check at all
1 = Check, but only if it specifically the values
2 = Check, but also with padding of 4 rooms after
]]
local function CheckSpawnability(CheckChases:number, CheckMilestone:number, CheckSpecial:boolean)
	if typeof(CheckChases) ~= "number" then CheckChases = 2 end
	if typeof(CheckMilestone) ~= "number" then CheckMilestone = 2 end
	if typeof(CheckSpecial) ~= "boolean" then CheckSpecial = true end

	local ChaseFloors = {"Hotel", "Mines", "Garden"}
	local SpecialChecks = {
		CurrentRooms = {"SkellyFriend", "El Goblino", "Grampy"}
	}
	local ManualMilestones = {
		Backdoor = {50},
		Hotel = {50,89,99,100},
		Mines = {49,50,100},
		Garden = {35},
		Rooms = {1000},
		Archives = {-1},
	}
	
	local floor = RepStorage.GameData.Floor.Value
	local specific = RepStorage.GameData.FloorDestination.Value
	if floor == "Party" then
		return true
	end
	if CheckSpecial then
		if workspace.CurrentCamera:FindFirstChild("Shade", true) then
			return false
		end
		for the,sigma in pairs(SpecialChecks) do
			if workspace:FindFirstChild(the) then
				for i,v in pairs(sigma) do
					if workspace:FindFirstChild(the):FindFirstChild(sigma, true) then
						return false --🌯WORLD'S MOST OPTIMIZED CODE?BRO S
					end
				end
			end
		end
	end
	if ChaseFloors[floor] ~= nil then
		if (CheckChases == 1 and door.Value >= RepStorage.GameData.ChaseEnd.Value) or (CheckChases >= 2 and door.Value >= RepStorage.GameData.ChaseEnd.Value + 4) then
			return false
		end
	end
	if CheckMilestone > 0 and ManualMilestones[floor] ~= nil then
		for i,v in pairs(ManualMilestones[floor]) do
			if (CheckMilestone == 1 and door.Value == v) or (CheckMilestone == 2 and math.abs(door.Value-v) < 4) then
				return false
			end
		end
	end
	return true
end
--
local function Polaroid_Attack()
	local muffle = Instance.new("EqualizerSoundEffect")
	muffle.LowGain = 0
	muffle.HighGain = 0
	muffle.MidGain = 0
	muffle.Name = "LivePolaroidEffect"
	muffle.Parent = game:GetService("SoundService").Main
	print(muffle.Parent)
	for i,v in ipairs(collectionservice:GetTagged("LightSource")) do
		local neon = v:FindFirstChild("Neon",true)
		if neon then 
			neon:SetAttribute("PrePolaroid",neon.Color)
			tweenservice:Create(neon,TweenInfo.new(3),{Color = neon.Color:Lerp(Color3.new(0,0,0),0.5)}):Play()
		end
		for i2,v2 in ipairs(v:GetDescendants()) do
			if v2:IsA("Light") then
				v2:SetAttribute("PrePolaroid",v2.Brightness)
				tweenservice:Create(v2,TweenInfo.new(3),{Brightness = v2.Brightness*0.3}):Play()
				v2:SetAttribute("PrePolaroidRange",v2.Range)
				tweenservice:Create(v2,TweenInfo.new(3),{Range = v2.Range*0.3}):Play()
			end
		end
	end

	local entity = rusherspawner:Create({
		Entity = {
			Name = "Polaroid",
			Asset = "https://github.com/TheGuyThatCodez/Niche-Pibby-Hardcore-Mode/raw/main/Models/Polaroid.rbxm",
			HeightOffset = 2
		},
		Lights = {
			Flicker = {
				Enabled = false,
				Duration = 1
			},
			Shatter = false,
			Repair = false
		},
		Earthquake = {
			Enabled = false
		},
		CameraShake = {
			Enabled = true,
			Range = 30,
			Values = {1.5, 1, 0.1, 1} -- Magnitude, Roughness, FadeIn, FadeOut
		},
		Movement = {
			Speed = 70,
			Delay = 5,
			Reversed = false
		},
		Rebounding = {
			Enabled = false,
			Type = "Ambush", -- "Blitz"
			Min = 1,
			Max = 1,
			Delay = 2
		},
		Damage = {
			Enabled = true,
			IgnoreHiding = false,
			Range = 30,
			Amount = 0 --Death is handled by custom function, not the entity spawner
		},
		Crucifixion = {
			Type = "Guiding",
			Enabled = true,
			Range = 40,
			Resist = false,
			Break = true
		},
		Death = {
			Type = "Guiding", -- "Curious"
			Hints = {},
			Cause = ""
		}
	})
	entity:SetCallback("OnDamagePlayer", function(newHealth: number)
		KillWithReason("Polaroid")
	end)
	entity:SetCallback("OnDespawning", function()
		for i,v in ipairs(collectionservice:GetTagged("LightSource")) do
			local neon = v:FindFirstChild("Neon",true)
			if neon and neon:GetAttribute("PrePolaroid") then 
				tweenservice:Create(neon,TweenInfo.new(3),{Color = neon:GetAttribute("PrePolaroid",neon.Color)}):Play()
			end
			for i2,v2 in ipairs(v:GetDescendants()) do
				if v2:IsA("Light") and v2:GetAttribute("PrePolaroid") then
					tweenservice:Create(v2,TweenInfo.new(3),{Brightness = v2:GetAttribute("PrePolaroid")}):Play()
					tweenservice:Create(v2,TweenInfo.new(3),{Range = v2:GetAttribute("PrePolaroidRange")}):Play()
				end
			end
		end
	end)
	entity:Run(true)
	task.defer(function()
		while entity.Model and entity.Model.Parent do
			local distance = (workspace.CurrentCamera.CFrame.Position-entity.Model.Main.Position).Magnitude
			tweenservice:Create(muffle,TweenInfo.new(0.5),{
				LowGain = -(1/distance)*400,
				MidGain = -(1/distance)*900,
				HighGain = -(1/distance)*1500,
			}):Play()
			print(muffle.MidGain)
			task.wait()
		end
		tweenservice:Create(muffle,TweenInfo.new(2),{
			LowGain = 0,
			MidGain = 0,
			HighGain = 0,
		})
		task.wait(2)
		muffle:Destroy()
	end)
end

local function Shady_Attack()
	local shadygui = Instance.new("ImageLabel")
	shadygui.Size = UDim2.fromScale(2,2)
	shadygui.Position = UDim2.fromScale(0.5,0.5)
	shadygui.AnchorPoint = Vector2.new(0.5,0.5)
	shadygui.BackgroundTransparency = 1
	shadygui.ImageTransparency = 1
	shadygui.Image = "rbxassetid://134429536911936"
	shadygui.Parent = game.Players.LocalPlayer.PlayerGui.MainUI
	shadygui.ResampleMode = Enum.ResamplerMode.Pixelated
	shadygui.ScaleType = Enum.ScaleType.Crop
	shadygui.Name = "LiveShadyUi" --🌯BRO DIDNT CAPITALIZE HER I --🐟 Don't even talk to me BLUD.

	local effect = Instance.new("ColorCorrectionEffect")
	effect.Name = "LiveShadyEffect"
	effect.Parent = workspace.CurrentCamera

	local nearattack = Instance.new("Sound")
	nearattack.Parent = shadygui
	nearattack.SoundId = "rbxassetid://1837834352"
	local soundgroup = Instance.new("SoundGroup")
	soundgroup.Parent = nearattack
	local reverb = Instance.new("ReverbSoundEffect")
	reverb.DecayTime = 8
	reverb.Parent = soundgroup
	nearattack.SoundGroup = soundgroup

	local ambient = Instance.new("Sound")
	ambient.Parent = shadygui
	ambient.SoundId = "rbxassetid://130762806"
	ambient.Volume = 0
	ambient.PlaybackSpeed = 0
	ambient:Play()
	tweenservice:Create(ambient,TweenInfo.new(5,Enum.EasingStyle.Linear),{Volume = 0.3,PlaybackSpeed = 0.8}):Play()

	tweenservice:Create(shadygui,TweenInfo.new(2,Enum.EasingStyle.Cubic),{Size = UDim2.fromScale(1.3,1.3),ImageTransparency = 0.6}):Play()
	tweenservice:Create(effect,TweenInfo.new(3,Enum.EasingStyle.Cubic),{Saturation = -0.6}):Play()
	RepStorage.RemotesFolder.CamShakeClient:Fire(1,4,9,0.75,Vector3.zero,Vector3.one)
	task.wait(2)
	tweenservice:Create(shadygui,TweenInfo.new(6.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.In),{Size = UDim2.fromScale(1.2,1.2),ImageTransparency = 0.5}):Play()
	task.wait(3)
	nearattack:Play()
	task.wait(4)

	shadygui.Size = UDim2.fromScale(1,1)
	shadygui.ImageTransparency = 0.2
	effect.Brightness = 0.1
	effect.Saturation = -1
	RepStorage.RemotesFolder.CamShakeClient:Fire(6,4,0.1,0.75,Vector3.zero,Vector3.one)
	task.wait(0.1)
	local character = game.Players.LocalPlayer.Character
	if not character:GetAttribute("Hiding") then
		KillWithReason("Shady")
	end
	tweenservice:Create(effect,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Saturation = 0,Brightness = 0}):Play()
	tweenservice:Create(shadygui,TweenInfo.new(5,Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut),{Size = UDim2.fromScale(3,3),ImageTransparency = 1}):Play()

	ambient.SoundGroup = nearattack.SoundGroup
	task.wait(0.5)
	ambient:Stop()

	task.wait(10)
	shadygui:Destroy()
	effect:Destroy()
end
--
RepStorage.RemotesFolder.CaptionClient:Fire(`Nichemode made by:`)
RepStorage.RemotesFolder.CaptionClient:Fire(`Willow & Nick`)
RepStorage.RemotesFolder.CaptionClient:Fire(`Shady by Ping, Polaroid by Bungus`)
door.Changed:Connect(function()
	local currroom = workspace.CurrentRooms[`{door.Value}`]
	local prevroom = workspace.CurrentRooms[`{door.Value-1}`]
	local shadyspawn = seed:NextInteger(1,100)
	local polaroidspawn = seed:NextInteger(1,100)
	--RepStorage.RemotesFolder.CaptionClient:Fire(shadyspawn)
	local isSomeoneLow = false
	for i,v in ipairs(game.Players:GetPlayers()) do
		if v.Character == nil then continue end
		if v.Character.Humanoid.Health > 0 and v.Character.Humanoid.Health <= 60 then
			isSomeoneLow = true
			break
		end
	end
	if RepStorage.GameData.Floor.Value == "Party" then
		isSomeoneLow = true
	end
	task.defer(function()
		if isSomeoneLow and CheckSpawnability(2, 2, true) and shadyspawn < 50 and not currroom:FindFirstChild("HidePrompt",true) and prevroom:FindFirstChild("HidePrompt",true) then
			task.wait(seed:NextNumber(0.5,3))
			Shady_Attack()
		end
	end)
	task.defer(function()
		--RepStorage.RemotesFolder.CaptionClient:Fire(`{polaroidspawn}<{math.lerp(15,80,door.Value/100)}`)
		if CheckSpawnability(2, 2, true) and polaroidspawn < math.lerp(15,80,door.Value/100) and currroom:FindFirstChild("HidePrompt",true) and door.Value > 8 then
			task.wait(seed:NextNumber(0.5,3))
			Polaroid_Attack()
		end
	end)
end)

game:GetService("TextChatService").MessageReceived:Connect(function(a0: TextChatMessage)
	if a0.Text == "/shady" then
		Shady_Attack()
	end
	if a0.Text == "/polaroid" then
		Polaroid_Attack()
	end
end)
