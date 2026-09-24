--!strict

-- Public wire shape only. A matching shape never grants permission or readiness.
local ProtocolV1 = {
	version = 1,
	remoteNames = table.freeze({
		command = "Command",
		event = "Event",
		unreliableEvent = "UnreliableEvent",
	}),
}

export type CommandEnvelope = {
	protocolVersion: number,
	routeId: string,
	requestId: string,
	expectedRevision: number?,
	payload: { [string]: unknown },
}

export type EventEnvelope = {
	protocolVersion: number,
	routeId: string,
	correlationId: string?,
	revision: number?,
	payload: { [string]: unknown },
}

export type UnreliableEventEnvelope = EventEnvelope

function ProtocolV1.isSupportedVersion(value: unknown): boolean
	return value == ProtocolV1.version
end

return table.freeze(ProtocolV1)
