local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NevermoreEngine   = require(ReplicatedStorage:WaitForChild("NevermoreEngine"))
local LoadCustomLibrary = NevermoreEngine.LoadLibrary

local qSystems          = LoadCustomLibrary("qSystems")
local RbxUtility	= LoadLibrary("RbxUtility")

qSystems:Import(getfenv(1))


local ClientAuthenticationService = {} do
	local RequestStream = NevermoreEngine.GetRemoteFunction("AuthenticationServiceRequestor")
	local EventStream   = NevermoreEngine.GetRemoteEvent("AuthenticationServiceEventStream")

	ClientAuthenticationService.AuthenticationChanged = RbxUtility.CreateSignal()
	--CreateSignal() was recognized as a table value, and was therefore replaced with a more direct usage

	EventStream.OnClientEvent:connect(function(AuthenticationChange)
		if type(AuthenticationChange) == "string" then
			AuthenticationChange = AuthenticationChange:lower()

			if AuthenticationChange == "authorized" then
				ClientAuthenticationService.AuthenticationChanged:fire(true)
			elseif AuthenticationChange == "deauthorized" then
				ClientAuthenticationService.AuthenticationChanged:fire(false)
			else -- Oh noes!
				warn("[ClientAuthenticationService] - Unable to process AuthenticationChange event, AuthenticationChange value = '" .. tostring(AuthenticationChange) .. "'")
			end
		else
			warn("[ClientAuthenticationService] - Unable to process AuthenticationChange event, AuthenticationChange value is not a string. It is a '" .. type(AuthenticationChange) .. "' value.")
		end
	end)

	local function IsAuthorized(PlayerName)
		-- [PlayerName] Optional playername to check

		return RequestStream:InvokeServer("IsAuthorized", PlayerName)
	end
	ClientAuthenticationService.IsAuthorized = IsAuthorized
	ClientAuthenticationService.isAuthorized = IsAuthorized
end

return ClientAuthenticationService
