--!strict

-- One authored DEV rule set. Social state observes ordinary travel only.
return table.freeze({
	id = "challenge/home-return-dev-v1",
	version = 1,
	title = "Home Return (DEV)",
	rules = "Both start at discovered Starter Travel with ordinary Home Hub travel ready. First server-confirmed return after consent wins; same-time finishes use server admission order. Reset, recovery, disconnect or other travel cancels. No rewards.",
	sourceNodeId = "travel-node/starter",
	targetNodeId = "travel-node/home-hub",
})
