local allachievements = {
	TestAchievement = {
		Title = "Test",
		Desc = "Desc",
		Reason = "Reason",
		BadgeId = 0,
	}
}

local function GiveAchievement(id)
	local achievements = string.split(readfile("nichemode/achievements.txt"),"\n")
	if table.find(achievements,id) or allachievements[id].GotThisSession then
		warn("ALREADY HAS ACHIEVEMENT!!!",id)
		return
	end

	local achievementmodule = require(game:GetService("ReplicatedStorage").ModulesShared.Achievements)
	local giveachievement = require(game.Players.LocalPlayer.PlayerGui.MainUI:FindFirstChild("AchievementUnlock",true))

	local achievementplaceholder = `Custom{tick()}`
	achievementmodule[achievementplaceholder] = {
		GetInfo = function()
			return allachievements[id]
		end
	}

	giveachievement(achievementmodule,achievementplaceholder)
	allachievements[id].GotThisSession = true
	appendfile("nichemode/achievements.txt",`\n{id}`)
end

GiveAchievement("TestAchievement")