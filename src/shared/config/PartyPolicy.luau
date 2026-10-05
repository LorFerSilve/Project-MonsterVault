--!strict

-- DEV tuning, not new GDS semantics. Four seats is the locked GDS-10 maximum.
return table.freeze({
	maxMembers = 4,
	maxParties = 60,
	maxLiveUsers = 60,
	maxInvitesPerParty = 4,
	maxIncomingInvites = 2,
	maxPingsPerParty = 2,
	pingSeconds = 6,
	maxChallenges = 30,
	challengeOfferSeconds = 20,
	challengeActiveSeconds = 30,
	challengeResultSeconds = 6,
	inviteSeconds = 30,
	rejoinSeconds = 30,
	senderCooldownSeconds = 3,
	recipientCooldownSeconds = 3,
})
