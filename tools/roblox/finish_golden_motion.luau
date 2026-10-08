-- Edit-only extension of the existing accumulator. No economy or interaction owner.
return function()
	assert(not game:GetService("RunService"):IsRunning(), "Edit only")
	local mv = game.ReplicatedStorage.MonsterVault
	local paletteSource = mv.Shared.config.MaterialPalette:Clone()
	paletteSource.Parent = game.ServerStorage
	local palette = require(paletteSource)
	paletteSource:Destroy()
	local accumulator = workspace.MonsterVaultPresentation.VaultFoundry.EnergyAccumulator
	local old = accumulator:FindFirstChild("BufferGauge")
	if old then
		old:Destroy()
	end
	local gauge = Instance.new("Model")
	gauge.Name, gauge.Parent = "BufferGauge", accumulator
	local cf = accumulator:GetPivot()
	for step = 1, 8 do
		local bar = Instance.new("Part")
		bar.Name, bar.Size = "BufferSegment" .. step, Vector3.new(0.22, 0.18, 0.05)
		bar.CFrame = cf * CFrame.new(-1.05 + (step - 1) * 0.3, 1.17, -2.64)
		bar.Material, bar.Color = palette.EnergyGreen.material, palette.EnergyGreen.color
		bar:SetAttribute("MaterialGroup", "EnergyGreen")
		bar:SetAttribute("BufferStep", step)
		bar.Anchored, bar.CanCollide, bar.CanTouch, bar.CanQuery, bar.CastShadow =
			true, false, false, false, false
		bar.TopSurface, bar.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		bar.Parent = gauge
	end
	gauge.WorldPivot = cf
	return gauge
end
