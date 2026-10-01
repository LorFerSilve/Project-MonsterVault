--!strict

local ProgressionProjection = {}
function ProgressionProjection.fromProfile(
	profile: any,
	progression: any,
	vault: any,
	quote: any?
): any
	local d = progression.definition()
	local receipt = profile.progression.purchasesByUnlockId[d.unlockId]
	return {
		domain = "progression",
		revision = profile.profileRevision,
		state = {
			unlockId = d.unlockId,
			energyUnits = profile.economy.energyUnits,
			collectionCapacity = vault.collectionStatus(profile).capacity,
			owned = progression.owned(profile),
			gateReason = progression.eligible(profile) or "",
			receiptQuoteId = if receipt then receipt.quoteId else "",
			receiptExpectedRevision = if receipt then receipt.expectedRevision else 0,
			receiptPriceUnits = if receipt then receipt.priceUnits else 0,
			quote = quote,
		},
	}
end
return ProgressionProjection
