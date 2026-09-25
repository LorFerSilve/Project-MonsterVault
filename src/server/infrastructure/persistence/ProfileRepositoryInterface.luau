--!strict

-- update() invokes a pure, non-yielding transform, potentially more than once.
-- Successful writes return the committed value and metadata. Aborts and errors
-- never mean an absent/new profile.
export type Decision =
	{ kind: "write", value: any, metadata: { [string]: any } }
	| { kind: "abort", reason: string }
export type Result =
	{ status: "ok", value: any, metadata: { [string]: any } }
	| { status: "aborted", reason: string }
	| { status: "error", reason: string, retryable: boolean }
export type Repository = {
	update: (key: string, transform: (any, { [string]: any }) -> Decision) -> Result,
}

return {}
