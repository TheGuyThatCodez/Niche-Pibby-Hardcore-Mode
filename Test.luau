local seed = Random.new(game:GetService("ReplicatedStorage").GameData.GameSeed.Value)
local tweenservice = game:GetService("TweenService")
local door = game:GetService("ReplicatedStorage").GameData.LatestRoom

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
local function KillWithReason(reason: string)
	local hintdata = alldeathhints[reason]

	replicatesignal(game.Players.LocalPlayer.Kill)

	for i=1,5,0.05 do
		task.wait(0.05)
		game:GetService("ReplicatedStorage").GameStats[`Player_{game.Players.LocalPlayer.Name}`].Total.DeathCause.Value = hintdata.name
		firesignal(game:GetService("ReplicatedStorage").RemotesFolder.DeathHint.OnClientEvent,hintdata.hint_moonlight,"Blue")
	end
end
--
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
	shadygui.Name = "LiveShadyUi" --🌯BRO DIDNT CAPITALIZE HER I

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

	task.wait(2)
	tweenservice:Create(shadygui,TweenInfo.new(6.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.In),{Size = UDim2.fromScale(1.2,1.2),ImageTransparency = 0.5}):Play()
	task.wait(3)
	nearattack:Play()
	task.wait(4)

	shadygui.Size = UDim2.fromScale(1,1)
	shadygui.ImageTransparency = 0.2
	effect.Brightness = 0.1
	effect.Saturation = -1
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
game:GetService("ReplicatedStorage").RemotesFolder.CaptionClient:Fire(`SEED: {game:GetService("ReplicatedStorage").GameData.GameSeed.Value}`)
door.Changed:Connect(function()
	local currroom = workspace.CurrentRooms[`{door.Value}`]
	local prevroom = workspace.CurrentRooms[`{door.Value-1}`]
	local shadyspawn = seed:NextInteger(1,100)
	--game:GetService("ReplicatedStorage").RemotesFolder.CaptionClient:Fire(shadyspawn)
	if shadyspawn < 30 and not currroom:FindFirstChild("HidePrompt",true) and prevroom:FindFirstChild("HidePrompt",true) then
		task.wait(seed:NextNumber(0.5,3))
		Shady_Attack()
	end
end)
