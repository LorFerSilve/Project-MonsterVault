--!strict

local Ids = require("../../src/shared/types/Ids")

local function check(condition: boolean, message: string?)
	if not condition then
		error(message or "ID contract assertion failed", 2)
	end
end

local function run()
	check(Ids.isStaticContentId("species/ember-fox", "species"))
	check(Ids.isStaticContentId("mutation/gilded", "mutation"))
	check(Ids.isStaticContentId("landmark/starter-grove/old-oak", "landmark"))
	check(Ids.isStaticContentId("event/template/rift-surge", "event"))
	check(Ids.isStaticContentId("species/a1-b2", "species"))

	check(not Ids.isStaticContentId("species/ember-fox", "mutation"))
	check(not Ids.isStaticContentId("species/ember-fox", "SPECIES"))
	check(not Ids.isStaticContentId("species"))
	check(not Ids.isStaticContentId("/ember-fox"))
	check(not Ids.isStaticContentId("species/"))
	check(not Ids.isStaticContentId("species//ember-fox"))
	check(not Ids.isStaticContentId("Species/ember-fox"))
	check(not Ids.isStaticContentId("species/Ember Fox"))
	check(not Ids.isStaticContentId("species/2ember-fox"))
	check(not Ids.isStaticContentId("species/-ember-fox"))
	check(not Ids.isStaticContentId("species/ember-fox-"))
	check(not Ids.isStaticContentId("species/ember--fox"))
	check(not Ids.isStaticContentId("species/ember_fox"))
	check(not Ids.isStaticContentId("species/émber-fox"))
	check(not Ids.isStaticContentId(123))
	check(not Ids.isStaticContentId({}))
end

return { run = run }
