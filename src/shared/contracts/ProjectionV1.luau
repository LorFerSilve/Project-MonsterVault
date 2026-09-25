--!strict

-- IMP-4 exposes only the session projection. Domain state expands through
-- explicit schemas in its owning implementation phase.
local ProjectionV1 = {}

local function finiteRevision(value: any): boolean
	return type(value) == "number" and value >= 0 and value % 1 == 0 and value < math.huge
end

function ProjectionV1.validSession(value: any): boolean
	if type(value) ~= "table" then
		return false
	end
	local count = 0
	for key in value do
		count += 1
		if count > 2 or (key ~= "status" and key ~= "profileRevision") then
			return false
		end
	end
	if value.status ~= "Loading" and value.status ~= "Ready" and value.status ~= "Protected" then
		return false
	end
	if value.status == "Ready" then
		return finiteRevision(value.profileRevision)
	end
	return value.profileRevision == nil
end

function ProjectionV1.validSnapshot(value: any): boolean
	return type(value) == "table"
		and value.domain == "session"
		and finiteRevision(value.revision)
		and value.revision >= 1
		and ProjectionV1.validSession(value.state)
		and (function()
			for key in value do
				if key ~= "domain" and key ~= "revision" and key ~= "state" then
					return false
				end
			end
			return true
		end)()
end

function ProjectionV1.validDelta(value: any): boolean
	return type(value) == "table"
		and value.domain == "session"
		and finiteRevision(value.baseRevision)
		and finiteRevision(value.revision)
		and value.revision == value.baseRevision + 1
		and ProjectionV1.validSession(value.state)
		and (function()
			for key in value do
				if
					key ~= "domain"
					and key ~= "baseRevision"
					and key ~= "revision"
					and key ~= "state"
				then
					return false
				end
			end
			return true
		end)()
end

return table.freeze(ProjectionV1)
