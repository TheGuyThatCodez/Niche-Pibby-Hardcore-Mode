local allachievements = {
	TestAchievement = {
		Title = "Test",
		Desc = "Desc",
		Reason = "Reason",
		BadgeId = 0,
		Image = "rbxassetid://0",

		Gradient = "Redyellow"
	}
}

local achievementframe = game:GetService("Players").LocalPlayer.PlayerGui.MainUI.LobbyFrame.Achievements

if not achievementframe.Frame:FindFirstChild("CantApply") then
	local button = achievementframe.Frame:FindFirstChild("Applied"):Clone()
	button.Text = "Cannot display this achievement"
	button.Name = "CantApply"
	button.Parent = achievementframe.Frame
end

for i,v in pairs(allachievements) do
	local newbadge = achievementframe.List.Badge:Clone()
	newbadge.Visible = true
	newbadge.Parent = achievementframe.List
	newbadge.Name = `_Custom_{i}`

	local gradient = Instance.new("UIGradient")
	require(game:GetService("ReplicatedStorage").ModulesClient.BadgeGradients)(gradient,v.Gradient)

	gradient.Parent = newbadge.OutlineImage
	newbadge.Image = v.Image

	local got = false
	local achievements = string.split(readfile("nichemode/achievements.txt"),"\n")
	if table.find(achievements,i) then
		print("I Have It!")
		newbadge.ImageColor3 = Color3.new(1,1,1)
		newbadge.ImageTransparency = 0
		newbadge.OutlineImage.ImageColor3 = Color3.new(1,1,1)
		got = true
	end

	newbadge.Activated:Connect(function()
		achievementframe.Frame.TextHolder.Title.Text = v.Title
		achievementframe.Frame.TextHolder.Desc.Text = v.Desc
		achievementframe.Frame.TextHolder.Reason.Text = v.Reason
		if got == false then
			achievementframe.Frame.TextHolder.Title.Text = "Locked Achievement"
			achievementframe.Frame.TextHolder.Desc.Text = "Unlock this achievement to view its description!"
			achievementframe.Frame.TextHolder.Reason.Text = v.Reason
		end
		achievementframe.Frame.TextHolder.IsSecret.Visible = false

		achievementframe.Frame.CheckHolder.Visible = false
		achievementframe.Frame.Applied.Visible = false
		achievementframe.Frame.Apply.Visible = false
		--achievementframe.Frame.CantApply.Visible = true
		achievementframe.Frame.ImageLabel.Image = v.Image
		achievementframe.Frame.ImageLabel.OutlineImage.Image = "rbxassetid://116382081183309"

		require(game:GetService("ReplicatedStorage").ModulesClient.BadgeGradients)(achievementframe.Frame.ImageLabel.OutlineImage.ThemeGradient,v.Gradient)
		require(game:GetService("ReplicatedStorage").ModulesClient.BadgeGradients)(achievementframe.Frame.TextHolder.Title.ThemeGradient,v.Gradient)
	end)
end