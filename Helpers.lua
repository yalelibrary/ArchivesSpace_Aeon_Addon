-- Utility Functions

function makeRibbonVisible(ribbon, visibilitySetting)
	--ribbon is of type AtlasSystems.Scripting.UI.ScriptRibbonPage
	--visibilitySetting is a boolean value
	--this should probably be switched to a "show only" that searches the parent
	--and deactivates all but the specified ribbon within a particular group
	ribbon.Page.Visible = visibilitySetting;
end

function findObjectTypeInCollection(obj, typestr)
	local ctrlCount = getLength(obj);
	local idx = 0;
	local target = nil;
	while idx < ctrlCount do
		target = obj:get_Item(idx);
		if string.startsWith(tostring(target), typestr) then
			return target;
		end
		idx = idx + 1;
	end
	if idx == ctrlCount then
		return nil;
	end

end

function getLength(obj)
	local idx = 0;
	while true do
		if pcall(function () local test = obj:get_Item(idx) end) then
			idx = idx + 1;
		else
			break;
		end
	end
	return idx;
end

function string.startsWith(original, test)
	return string.sub(original, 1, string.len(test))==test;
end

function incomingStringCleaner(text)
	text = string.gsub(text,"(Accession)","Accn");
	return text
end

function isnumeric(val)
	if (val == nil) then
		return false;
	end
	-- make sure the string val is all numeric
	return string.match(val, "^[0-9]+$") ~= nil;
end

function getDBUserId()
	local userId = Types["AtlasSystems.Configuration.Settings"].logonSettings.connectionSettings.UserId;
	Log("Active database connection UserId: " .. userId);
	return userId;
end

function getSiteFromDBContext()
	-- look up site from connection string user; otherwise, return the default site
	-- site label assumed to be an exact match with the database login
	local success, site = pcall(getDBUserId);
	if not success then
		Log("Unexpected error: Failed to obtain AtlasSystems.Configuration.Settings.logonSettings.connectionSettings.UserId!");
		return settings.defaultSite;
	elseif site == "aeon" or site == nil or site == "" then
		return settings.defaultSite;
	else
		return site;
	end
end
