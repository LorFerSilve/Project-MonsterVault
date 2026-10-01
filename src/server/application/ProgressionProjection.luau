--!strict

local ProgressionProjection = {}
function ProgressionProjection.fromProfile(
	profile: any,
	progression: any,
	vault: any,
	quote: any?,
	unlockId: string?
): any
	local d = progression.definition(unlockId)
	local index = 1
	for i, candidate in progression.definitions do
		if candidate.unlockId == d.unlockId then
			index = i
		end
	end
	local receipt = profile.progression.purchasesByUnlockId[d.unlockId]
	return {
		domain = "progression",
		revision = profile.profileRevision,
		state = {
			unlockId = d.unlockId,
			label = d.label,
			catalogIndex = index,
			catalogSize = #progression.definitions,
			energyUnits = profile.economy.energyUnits,
			collectionCapacity = vault.collectionStatus(profile).capacity,
			owned = progression.owned(profile, d.unlockId),
			gateReason = progression.eligible(profile, d.unlockId) or "",
			receiptQuoteId = if receipt then receipt.quoteId else "",
			receiptExpectedRevision = if receipt then receipt.expectedRevision else 0,
			receiptPriceUnits = if receipt then receipt.priceUnits else 0,
			quote = quote,
		},
	}
end
return ProgressionProjection
