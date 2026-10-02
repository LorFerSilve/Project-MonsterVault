--!strict
-- Install beside EnergyCoreAppearance; one pass when the asset enters the game.
-- Edit-time authoring calls the same module explicitly and saves its properties.

local applyAppearance = require(script.Parent:WaitForChild("EnergyCoreAppearance") :: ModuleScript)
applyAppearance(script.Parent)
