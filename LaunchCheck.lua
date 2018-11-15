--
--   Functions to determine whether the addon should be launched or not
--

function CheckAddonShouldLaunch()
    Log("Checking if launch conditions have been met");
    --We want to ensure that the addon doesn't launch when irrelevant

    local activeEnvironmentMatchesAddonConfig = CheckActiveEnvironmentMatchesAddonConfig();
    if not activeEnvironmentMatchesAddonConfig then
        return false;
    end

    return true;
end

function CheckActiveEnvironmentMatchesAddonConfig()
    Log("Checking current environment (test vs prod)");
    -- make a test database connection and check to see if the active database
    --   indicates the addon should load
    --
    -- this allows a different version of the same addon to load depending on
    --   which database is configured in the Atlas SQL Alias Manager    
        
    local dbname = getScalarValueNoParams(sql_getCurrentDatabase(), {});
    local dbname = dbname:lower();
    
    Log("Active database value returned from query: " .. dbname);

    local expectedDbNames = string.lower(settings.ExpectedDBNames);
    Log("Checking to see if the addon should load based on the active database:");
    Log("  ExpectedDBNames (pipe separated): " .. expectedDbNames);
    Log("  Active database: " .. dbname);
    local expectedDbNameTable = string.split(expectedDbNames,"|");

    if (table.contains(expectedDbNameTable, dbname)) then
        Log("database in configuration file matches active database");
        return true;
    else
        -- stop the addon
        Log("database in configuration file DOES NOT MATCH active database");
        return false;		
    end
end

--These have been included here since they are not relevant to the rest of the addon
function getScalarValueNoParams(sql)
	-- SQL Query MUST have only a scalar result (1 column, 1 row)
	local cn = CreateManagedDatabaseConnection();
	cn.QueryString = sql;
	cn:Connect();
	local result = cn:ExecuteScalar(); -- returns a number or nil
	cn:Dispose();
	return result; --null should be handled by the caller
end

function sql_getCurrentDatabase()
	return "SELECT DB_Name()";
end

function string.split(s, sep)
	if sep == nil then
		sep = "%s"
	end
	t={} ; i=1
	for str in string.gmatch(s, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

-- from: http://stackoverflow.com/questions/2282444/how-to-check-if-a-table-contains-an-element-in-lua
function table.contains(table, element)
  for key, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end