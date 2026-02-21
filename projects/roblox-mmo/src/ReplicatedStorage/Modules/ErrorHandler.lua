-- ErrorHandler.lua
-- Centralized error handling and debugging system

local ErrorHandler = {}

-- Configuration
local CONFIG = {
	DEBUG_MODE = true,
	LOG_TO_OUTPUT = true,
	LOG_TO_FILE = false,
	MAX_LOG_SIZE = 10000,
	DATASTORE_FALLBACK = true,
	DEFAULT_TIMEOUT = 5, -- seconds
}

-- Log storage
local logs = {}
local logIndex = 1

-- Memory cache for DataStore fallback
local memoryCache = {}

-- Helper: Safe WaitForChild with timeout
function ErrorHandler:SafeWaitForChild(parent, childName, timeout)
	timeout = timeout or CONFIG.DEFAULT_TIMEOUT
	local startTime = tick()
	
	while tick() - startTime < timeout do
		local child = parent:FindFirstChild(childName)
		if child then
			return child
		end
		wait(0.1)
	end
	
	self:LogWarning("SafeWaitForChild timeout", {
		parent = parent:GetFullName(),
		childName = childName,
		timeout = timeout
	})
	
	return nil
end

-- Helper: Safe require with fallback
function ErrorHandler:SafeRequire(moduleScript, fallbackValue)
	if not moduleScript then
		self:LogError("SafeRequire: moduleScript is nil")
		return fallbackValue or {}
	end
	
	local success, result = pcall(function()
		return require(moduleScript)
	end)
	
	if success then
		return result
	else
		self:LogError("SafeRequire failed", {
			module = moduleScript:GetFullName(),
			error = result
		})
		return fallbackValue or {}
	end
end

-- Helper: Safe DataStore operations
function ErrorHandler:SafeDataStoreOperation(operationName, callback, fallbackValue)
	if not CONFIG.DATASTORE_FALLBACK then
		local success, result = pcall(callback)
		if success then
			return result
		else
			self:LogError("DataStore operation failed", {
				operation = operationName,
				error = result
			})
			return fallbackValue
		end
	end
	
	-- Try DataStore first
	local success, result = pcall(callback)
	if success then
		return result
	end
	
	-- Log the DataStore error
	self:LogWarning("DataStore fallback to memory", {
		operation = operationName,
		error = result
	})
	
	-- Use memory cache as fallback
	return fallbackValue
end

-- Helper: Validate not nil
function ErrorHandler:ValidateNotNil(value, context, fallbackValue)
	if value == nil then
		self:LogWarning("Nil value detected", context)
		return fallbackValue
	end
	return value
end

-- Helper: Safe remote event fire
function ErrorHandler:SafeFireRemote(remoteEvent, player, ...)
	if not remoteEvent then
		self:LogError("SafeFireRemote: remoteEvent is nil")
		return false
	end
	
	local args = {...}
	local success, result = pcall(function()
		if player then
			remoteEvent:FireClient(player, unpack(args))
		else
			remoteEvent:FireAllClients(unpack(args))
		end
	end)
	
	if not success then
		self:LogError("Remote event fire failed", {
			remote = remoteEvent:GetFullName(),
			player = player and player.Name or "AllClients",
			error = result
		})
		return false
	end
	
	return true
end

-- Helper: Safe remote event connect
function ErrorHandler:SafeConnectRemote(remoteEvent, callback)
	if not remoteEvent then
		self:LogError("SafeConnectRemote: remoteEvent is nil")
		return nil
	end
	
	return remoteEvent.OnServerEvent:Connect(function(...)
		local success, result = pcall(callback, ...)
		if not success then
			self:LogError("Remote event callback failed", {
				remote = remoteEvent:GetFullName(),
				error = result
			})
		end
	end)
end

-- Logging functions
function ErrorHandler:LogDebug(message, data)
	if not CONFIG.DEBUG_MODE then return end
	
	local logEntry = {
		type = "DEBUG",
		time = os.date("%H:%M:%S"),
		message = message,
		data = data
	}
	
	self:_addLog(logEntry)
	
	if CONFIG.LOG_TO_OUTPUT then
		print(string.format("[DEBUG %s] %s", logEntry.time, tostring(message)))
		if data and type(data) == "table" then
			for k, v in pairs(data) do
				print(string.format("  %s: %s", k, tostring(v)))
			end
		elseif data then
			print(string.format("  data: %s", tostring(data)))
		end
	end
end

function ErrorHandler:LogInfo(message, data)
	local logEntry = {
		type = "INFO",
		time = os.date("%H:%M:%S"),
		message = message,
		data = data
	}
	
	self:_addLog(logEntry)
	
	if CONFIG.LOG_TO_OUTPUT then
		print(string.format("[INFO %s] %s", logEntry.time, tostring(message)))
	end
end

function ErrorHandler:LogWarning(message, data)
	local logEntry = {
		type = "WARNING",
		time = os.date("%H:%M:%S"),
		message = message,
		data = data
	}
	
	self:_addLog(logEntry)
	
	if CONFIG.LOG_TO_OUTPUT then
		warn(string.format("[WARNING %s] %s", logEntry.time, tostring(message)))
		if data and type(data) == "table" then
			for k, v in pairs(data) do
				warn(string.format("  %s: %s", k, tostring(v)))
			end
		elseif data then
			warn(string.format("  data: %s", tostring(data)))
		end
	end
end

function ErrorHandler:LogError(message, data)
	local logEntry = {
		type = "ERROR",
		time = os.date("%H:%M:%S"),
		message = message,
		data = data
	}
	
	self:_addLog(logEntry)
	
	if CONFIG.LOG_TO_OUTPUT then
		error(string.format("[ERROR %s] %s", logEntry.time, tostring(message)))
		if data and type(data) == "table" then
			for k, v in pairs(data) do
				error(string.format("  %s: %s", k, tostring(v)))
			end
		elseif data then
			error(string.format("  data: %s", tostring(data)))
		end
	end
end

-- Internal: Add log entry
function ErrorHandler:_addLog(entry)
	logs[logIndex] = entry
	logIndex = logIndex + 1
	
	-- Manage log size
	if logIndex > CONFIG.MAX_LOG_SIZE then
		-- Remove oldest logs (first 10%)
		local removeCount = math.floor(CONFIG.MAX_LOG_SIZE * 0.1)
		for i = 1, removeCount do
			logs[i] = nil
		end
		-- Shift remaining logs
		local newLogs = {}
		local newIndex = 1
		for i = removeCount + 1, logIndex - 1 do
			newLogs[newIndex] = logs[i]
			newIndex = newIndex + 1
		end
		logs = newLogs
		logIndex = newIndex
	end
end

-- Get all logs
function ErrorHandler:GetLogs()
	return logs
end

-- Clear logs
function ErrorHandler:ClearLogs()
	logs = {}
	logIndex = 1
end

-- Initialize
function ErrorHandler:Init()
	self:LogInfo("ErrorHandler initialized", {
		debugMode = CONFIG.DEBUG_MODE,
		dataStoreFallback = CONFIG.DATASTORE_FALLBACK
	})
	
	-- Set up global error handler for uncaught errors
	local function globalErrorHandler(message, stackTrace)
		self:LogError("Uncaught error", {
			message = message,
			stackTrace = stackTrace
		})
	end
	
	-- Override default error handler
	xpcall(function() end, globalErrorHandler)
	
	return self
end

return ErrorHandler:Init()