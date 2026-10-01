--!strict

local Factory = require("../../src/server/application/CaptureFinalizationUseCase")
local VaultService = require("../../src/server/domains/vault/VaultService")
local Config = require("../../src/shared/config/VaultCapacityFixture")

return Factory.new(VaultService.new(Config))
