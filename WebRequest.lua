-- Functions related to web requests

function getURL(url) --ToDo: Put this in a pcall also
	Log("Attempting to retrieve URL: " .. url);
	local results = '';
	myWebClient = Types["System.Net.WebClient"]();
	myStream = myWebClient:OpenRead(url);
	sr = Types["System.IO.StreamReader"](myStream);
	results = sr:ReadLine();
	myStream:Close();
	return results;
end

function getUrlStream(url)
	Log("Attempting to retrieve URL Stream: " .. url);
	local results;
	local sr;
	local streamResults;
	myWebClient = Types["System.Net.WebClient"]();
	myWebClient.Headers:Add("Accept","application/xml");
	local suc,err = pcall(function() --Lua's try/catch
		myStream = myWebClient:OpenRead(url);
		sr = Types["System.IO.StreamReader"](myStream);
	end)
	if suc then
		results = sr:ReadToEnd(); --Read all lines at once in case there are newlines in the xml
		results = incomingStringCleaner(results);
		--Log(results);
		streamResults = Types["System.IO.StringReader"](results); -- I can't get it to pass the stream directly without closing the connection early.
		myStream:Close();
		Log("Success reading webservice, returning value");
		return streamResults;
	else
		myStream:Close();
		Log("error caught returning webstream");
		return nil;
	end
end