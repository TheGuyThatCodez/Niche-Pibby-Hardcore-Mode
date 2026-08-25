
local dropevent = game:GetService("ReplicatedStorage").RemotesFolder.DropItem

local crucifix = game.Players.LocalPlayer.Character:FindFirstChild("Crucifix")
if crucifix then
	local event = nil
	event = workspace.Drops.ChildAdded:Connect(function(child)
		print(child)
		if child.Name == "Crucifix" then
			for i=0,1,0.05 do
				for i,v in ipairs(child:GetDescendants()) do
					if v:IsA("Part") then 
						v:PivotTo(v.CFrame*CFrame.new(0,-20,0))
						--v:SetNetworkOwner(game.Players.LocalPlayer)	
					end
				end
				task.wait(0.05)
			end
			child:Destroy()
			child.Parent = nil
			event:Disconnect()
		end
	end)
	dropevent:FireServer(crucifix)
end