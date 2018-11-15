--
--   Simple routine to handle logging for this addon copied from Shared User Manager
--

function Log(msg)
	LogDebug(settings.LogLabel .. ": " .. msg);
end

function LogError(msg, err)
	LogDebug("Error Logged: " .. msg);
	LogDebug("Error message: ".. err.Message);
	LogDebug("Inner exception error message: " .. err.InnerException.Message);
    LogDebug("Inner inner exception error message: " .. err.InnerException.InnerException.Message);
end