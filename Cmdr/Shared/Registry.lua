local Util = require(script.Parent.Util)

--- The registry keeps track of all the commands and types that Cmdr knows about.
local Registry = {
	TypeMethods = Util.MakeDictionary({"Transform", "Validate", "Autocomplete", "Parse", "Name"});
	CommandMethods = Util.MakeDictionary({"Name", "Aliases", "Description", "Args", "Run", "Data"});
	CommandArgProps = Util.MakeDictionary({"Name", "Type", "Description", "Optional"});
	Types = {};
	Commands = {};
	CommandsArray = {};
	Cmdr = nil;
	Hooks = {
		BeforeRun = {};
		AfterRun = {}
	}
}

--- Registers a type in the system.
-- name: The type Name. This must be unique.
function Registry:RegisterType (name, typeObject)
	for key in pairs(typeObject) do
		if self.TypeMethods[key] == nil then
			error("Unknown key/method in type \"" .. name .. "\": " .. key)
		end
	end

	if self.Types[name] ~= nil then
		error(('Type "%s" has already been registered.'):format(name))
	end

	typeObject.Name = name

	self.Types[name] = typeObject
end

--- Helper method that registers types from all module scripts in a specific container.
function Registry:RegisterTypesIn (container)
	for _, typeScript in pairs(container:GetChildren()) do
		typeScript.Parent = self.Cmdr.ReplicatedRoot.Types

		require(typeScript)(self)
	end
end

--- Registers a command based purely on its definition.
-- Prefer using Registry:RegisterCommand for proper handling of server/client model.
function Registry:RegisterCommandObject (commandObject)
	for key in pairs(commandObject) do
		if self.CommandMethods[key] == nil then
			error("Unknown key/method in command " .. (commandObject.Name or "unknown command") .. ": " .. key)
		end
	end

	if commandObject.Args then
		for i, arg in pairs(commandObject.Args) do
			for key in pairs(arg) do
				if self.CommandArgProps[key] == nil then
					error(('Unknown propery in command "%s" argument #%d: %s'):format(commandObject.Name or "unknown", i, key))
				end
			end
		end
	end

	self.Commands[commandObject.Name:lower()] = commandObject
	self.CommandsArray[#self.CommandsArray + 1] = commandObject

	if commandObject.Aliases then
		for _, alias in pairs(commandObject.Aliases) do
			self.Commands[alias:lower()] = commandObject
		end
	end
end

--- Registers a command definition and its server equivalent.
-- Handles replicating the definition to the client.
function Registry:RegisterCommand (commandScript, commandServerScript)
	local commandObject = require(commandScript)

	if commandServerScript then
		commandObject.Run = require(commandServerScript)
	else
		commandObject.Run = nil
	end

	self:RegisterCommandObject(commandObject)

	commandScript.Parent = self.Cmdr.ReplicatedRoot.Commands
end

--- A helper method that registers all commands inside a specific container.
function Registry:RegisterCommandsIn (container)
	local skippedServerScripts = {}
	local usedServerScripts = {}

	for _, commandScript in pairs(container:GetChildren()) do
		if not commandScript.Name:find("Server") then
			local serverCommandScript = container:FindFirstChild(commandScript.Name .. "Server")

			if serverCommandScript then
				usedServerScripts[serverCommandScript] = true
			end

			self:RegisterCommand(commandScript, serverCommandScript)
		else
			skippedServerScripts[commandScript] = true
		end
	end

	for skippedScript in pairs(skippedServerScripts) do
		if not usedServerScripts[skippedScript] then
			warn("Command script " .. skippedScript.Name .. " was skipped because it has 'Server' in its name, and has no equivalent shared script.")
		end
	end
end

--- Gets a command definition by name. (Can be an alias)
function Registry:GetCommand (name)
	name = name or ""
	return self.Commands[name:lower()]
end

--- Returns a unique array of all registered commands (not including aliases)
function Registry:GetCommands ()
	return self.CommandsArray
end

--- Returns an array of the names of all registered commands (not including aliases)
function Registry:GetCommandsAsStrings ()
	local commands = {}

	for _, command in pairs(self.CommandsArray) do
		commands[#commands + 1] = command.Name
	end

	return commands
end

--- Gets a type definition by name.
function Registry:GetType (name)
	return self.Types[name]
end

return function (cmdr)
	Registry.Cmdr = cmdr

	return Registry
end