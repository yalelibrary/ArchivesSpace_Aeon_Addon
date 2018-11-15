LogDebug("*******INIT ASpace Basic Loading Settings********");
settings = {} --settings is a global to allow other lua files access
settings["AutoSearch"] = GetSetting("AutoSearch");
settings["BaseUrl"] = GetSetting("BaseUrl");
settings["defaultSite"] = GetSetting("defaultSite");
settings["ExpectedDBNames"] = GetSetting("ExpectedDBNames");
settings["TabName"] = GetSetting("TabName");
settings["DefaultSearch"] = GetSetting("DefaultSearch");

-- Logging needs to precede all but settings to enable supporting libraries to log
globalInterfaceMngr = GetInterfaceManager();
settings["AddonName"] = globalInterfaceMngr.environment.Info.Name;
settings["AddonVersion"] = globalInterfaceMngr.environment.Info.Version;
settings["LogLabel"] = settings.AddonName .. " v" .. settings.AddonVersion;
require("Logging");

Log("Launching ASpace Basic Plugin");
Log("Loading Assemblies");
Log("Loading System Data Assembly");
luanet.load_assembly("System");
luanet.load_assembly("System.Data");
luanet.load_assembly("DevExpress.Data");
luanet.load_assembly("System.Windows.Forms");
luanet.load_assembly("System.Threading.Tasks");
luanet.load_assembly("DevExpress.XtraBars");
luanet.load_assembly("AtlasSystems.Core");

Log("Loading .NET Types");
Types = {};
Types["System.Data.DataTable"] = luanet.import_type("System.Data.DataTable");
Types["System.Data.DataSet"] = luanet.import_type("System.Data.DataSet");
Types["System.Net.WebClient"] = luanet.import_type("System.Net.WebClient");
Types["System.IO.StreamReader"] = luanet.import_type("System.IO.StreamReader");
Types["System.IO.StringReader"] = luanet.import_type("System.IO.StringReader");
Types["DevExpress.Data.ColumnSortOrder"] = luanet.import_type("DevExpress.Data.ColumnSortOrder");
Types["System.Windows.Forms.Control"] = luanet.import_type("System.Windows.Forms.Control");
Types["System.Threading.Tasks.Task"] = luanet.import_type("System.Threading.Tasks.Task");
Types["System.Action"] = luanet.import_type("System.Action");
Types["System.Console"] = luanet.import_type("System.Console");
Types["DevExpress.XtraBars.BarItemVisibility"] = luanet.import_type("DevExpress.XtraBars.BarItemVisibility");
Types["AtlasSystems.Configuration.Settings"] = luanet.import_type("AtlasSystems.Configuration.Settings");

Log("Create empty table for buttons");
Buttons = {};

Log("Create empty table for ribbons");
Ribbons = {};

Log("Create empty table for tabs");
Tabs={};

Log("Load additional lua libraries");
require("Helpers");
require("WebRequest");
require("LaunchCheck");
require("EventHandlers");
require("Grids");

local repo;

local form = nil;
local interfaceMngr = nil;

local mySqlGrid = nil;

--Form elements are
--Form
--Ribbons
----Buttons
--Controls
----Browser/Grid/Etc.

function Init()
	local addonShouldLaunch = CheckAddonShouldLaunch();
	if addonShouldLaunch then	
		interfaceMngr = GetInterfaceManager();

		-- Create the testing form.
		form = interfaceMngr:CreateForm(settings.TabName, "ArchivesSpace");

		-- Since we didn't create a ribbon explicitly before creating our browser, it will have created one using the name we passed the CreateBrowser method.  We can retrieve that one and add our buttons to it.
		Ribbons["CN"] = form:CreateRibbonPage("Call Number Search");
		Ribbons["BC"] = form:CreateRibbonPage("Barcode Search");

		if (AddonInfo.CurrentForm == "FormRequest") then
			Buttons["CNS-GTC"] = Ribbons["CN"]:CreateButton("Get Top Components", GetClientImage("srch_32x32"), "SearchSeries", "Call Number Search");
			Buttons["CNS-GB"] = Ribbons["CN"]:CreateButton("Get Boxes", GetClientImage("smicn_32x32"), "GetBoxes", "Call Number Search");
			Buttons["CNS-I"] = Ribbons["CN"]:CreateButton("Import", GetClientImage("impt_32x32"), "DoItemImport", "Call Number Search");

			Buttons["BCS-S"] = Ribbons["BC"]:CreateButton("Search by Barcode", GetClientImage("srch_32x32"), "SearchBarcode", "Barcode Search");
			Buttons["BCS-I"] = Ribbons["BC"]:CreateButton("Import", GetClientImage("impt_32x32"), "DoItemImportBarcode", "Barcode Search");

			asItemsGrid = form:CreateGrid("MySqlGrid", "ArchivesSpace Results");
			asItemsGrid.GridControl.MainView.OptionsView.ShowGroupPanel = false;
			asItemsGrid.GridControl.MainView.DoubleClick:Add(handleItemGridDoubleClick);
			asItemsGrid.GridControl.MainView.KeyDown:Add(ItemSelectCheck);
			asSeriesGrid = form:CreateGrid("MySeriesGrid", "AS Series Search");
			asSeriesGrid.GridControl.MainView.OptionsView.ShowGroupPanel = false; --Otherwise it's awkward when the grids suddenly change height as the grouping area is removed later.
			asSeriesGrid.GridControl.MainView.DoubleClick:Add(handleSeriesGridDoubleClick);
			asSeriesGrid.GridControl.MainView.KeyDown:Add(SeriesSelectCheck);
			asBarcodeGrid = form:CreateGrid("BarcodeResultGrid", "Barcode Search Results");
			asBarcodeGrid.GridControl.MainView.OptionsView.ShowGroupPanel = false;
			asBarcodeGrid.GridControl.MainView.DoubleClick:Add(handleBarcodeGridDoubleClick);
		end

		--Buttons["CNS-GTC"].BarButton.Enabled = False;
		--Log(Buttons["CNS-GTC"]:ToString());
		--Buttons["BCS-S"].BarButton.Visibility = Types["DevExpress.XtraBars.BarItemVisibility"].Never;
		--Buttons["BCS-I"].BarButton.Visibility = Types["DevExpress.XtraBars.BarItemVisibility"].Never;



		--Build the "Request" TextEdit Box
		searchTerm = form:CreateTextEdit("Search", "Enter Call Number");
		searchTerm.Value = GetFieldValue("Transaction", "CallNumber");
		searchTerm.Editor.KeyDown:Add(SeriesSubmitCheck);

		--Make a barcode search box
		searchBarcode = form:CreateTextEdit("Search Barcode", "Enter Barcode");
		searchBarcode.Value = GetFieldValue("Transaction", "ReferenceNumber");
		searchBarcode.Editor.KeyDown:Add(BarcodeSubmitCheck);

		--Add a spot for collection title
		collectionTitle = form:CreateTextEdit("CollectionTitle", "Collection Title");
		collectionTitle.ReadOnly = true;

		form:LoadLayout("layout.xml");
		RegisterTabControl(form);

		--Set the repository to search in ASpace
		local transactionSite = GetFieldValue("Transaction", "Site");
		if ((transactionSite == nil) or (transactionSite == "")) then
			repo = getSiteFromDBContext();
			Log("Using current database context to search repository: " .. repo);
		else
			repo = transactionSite;
			Log("Using current transaction's site value to search repository: " .. repo);
		end

		form:Show();
		if settings.AutoSearch then
			if ((searchTerm.Value ~= nil) and (searchTerm.Value ~= "")) then
				SearchSeries();
			end
		end 
	else
		Log("Addon did not meet launch criteria");
	end
end

function getRepo()
	-- determine if the repo code should change for Fortunoff based on current conditions
	if ((searchTerm.Value == nil) or (searchTerm.Value == "")) then
		return repo;
	end
	local hvt = "hvt-";
	if string.sub(searchTerm.Value:lower(), 1, string.len(hvt)) == hvt then
		return "HVT";
	end
	return repo;
end

function SearchBarcode()
		clearTable(asBarcodeGrid); --Clear item grid to avoid mixed series/items
		if ((searchBarcode.Value == nil) or (searchBarcode.Value == "")) then
			Log("Barcode search run but no barcode provided");
			return;
		end
		
		local seriesXml = getUrlStream(settings.BaseUrl .. "/combinedBarcodeSearch?barcode=" .. searchBarcode.Value .. "&repo=" .. repo);
		if (seriesXml ~= nil) then
			Log("Barcode grid - Initializing data structures");
			local asBarcodeDataset = Types["System.Data.DataSet"]();

			asBarcodeDataset:ReadXml(seriesXml);
			asBarcodeDataset:AcceptChanges();

			if (asBarcodeDataset.Tables.Count ~= 0) then
				asBarcodeGrid.PrimaryTable = asBarcodeDataset.Tables:get_Item(0);
				local barcodeGridControl = asBarcodeGrid.GridControl;
				fillBarcodeTable(barcodeGridControl);
			else
				Log("No results returned from webservice on barcode search");
				collectionTitle.Value = "No results from barcode search";
			end
		else
			Log("No value returned from webservice on barcode search");
			collectionTitle.Value = "No results from barcode search";
		end
end

function SearchSeries()
		clearTable(asSeriesGrid);
		clearTable(asItemsGrid); --Clear item grid to avoid mixed series/items
		if ((searchTerm.Value == nil) or (searchTerm.Value == "")) then
			collectionTitle.Value = "Please enter a search term";
			return;
		end
		--asBarcodeGrid.GridControl.MainView:ShowLoadingPanel(); --Loading panels don't work because the addon code is always executed synchronously - the panel freezes and then immediately disappears
		
		local seriesXml = getUrlStream(settings.BaseUrl .. "/get_atkcache_series.ashx?call_no=" .. searchTerm.Value .. "&repo=" .. getRepo());
		if (seriesXml ~= nil) then
			Log("Initializing data structures");
			local asSeriesDataset = Types["System.Data.DataSet"]();

			asSeriesDataset:ReadXml(seriesXml);
			asSeriesDataset:AcceptChanges();

			if (asSeriesDataset.Tables.Count ~= 0) then
				asSeriesGrid.PrimaryTable = asSeriesDataset.Tables:get_Item(0);
				local seriesGridControl = asSeriesGrid.GridControl;
				fillSeriesTable(seriesGridControl);
			else
				Log("No results returned from webservice on series search");
				collectionTitle.Value = "No results from collection search";
			end
		else
			Log("No value returned from webservice on series search");
			collectionTitle.Value = "Error on collection search";
		end
		--asBarcodeGrid.GridControl.MainView:HideLoadingPanel();
end

function GetBoxes(seriesId) --no overloading in lua so need to have a parameter that is tested for nil
		Log("Retrieving boxes.");
		clearTable(asItemsGrid); --Clear item grid to avoid mixed series/items
		if (seriesId == nil) then
			Log("Series ID value was null, attempting to retrieve from grid");
			local seriesRow = asSeriesGrid.GridControl.MainView:GetFocusedRow();
			seriesId = seriesRow:get_Item("series_id");
		end
		if (seriesId == nil) then
			--Still nothing
			Log("No series selected.");
			return;
		end;
		local boxesXml = getUrlStream(settings.BaseUrl .. "/get_atkcache_enums.ashx?series_id=" .. seriesId .. "&repo=" .. getRepo());

		if (boxesXml ~= nil) then
			Log("Series ID: " .. seriesId);

			Log("Initializing data structures");
			local asItemsDataSet = Types["System.Data.DataSet"](); --Can remove reference to datatable since using through dataset

			asItemsDataSet:ReadXml(boxesXml);
			asItemsDataSet:AcceptChanges();

			if (asItemsDataSet.Tables.Count ~= 0) then
				asItemsGrid.PrimaryTable = asItemsDataSet.Tables:get_Item(0);
				local itemGridControl = asItemsGrid.GridControl;
				fillItemTable(itemGridControl);
				asItemsGrid.GridControl:Focus();
			else
				Log("No results returned from webservice on box search");
			end
		else
			Log("No value returned from webservice on box search");
		end
end

function DoItemImport() --note no ID since even for the event handler the selected row is the one which has been double clicked
	Log("Performing Import");

	Log("Retrieving import row.");
	local itemRow = asItemsGrid.GridControl.MainView:GetFocusedRow();
	local seriesRow = asSeriesGrid.GridControl.MainView:GetFocusedRow();

	if ((itemRow == nil) or (seriesRow == nil)) then
		Log("No rows selected - aborting");
		return;
	end;

	local callNumber = itemRow:get_Item("callNumber");
	local itemTitle = seriesRow:get_Item("collection_title");
	local itemSubTitle = seriesRow:get_Item("series_title");
	local itemIssue = seriesRow:get_Item("series_div");
	local itemVolume = itemRow:get_Item("enumeration");
	local referenceNumber = itemRow:get_Item("item_barcode");
	local location = itemRow:get_Item("location");
	local subLocation = itemRow:get_Item("subLocation");
	local itemInfo1 = itemRow:get_Item("suppress_in_opac");
	local eadNumber = seriesRow:get_Item("ead_location");
	local docType = computeDocType(callNumber);

	-- Update the item object with the new values.
	Log("Updating the item object.");
	SetFieldValue("Transaction", "CallNumber", callNumber);
	SetFieldValue("Transaction", "ItemTitle", itemTitle);
	SetFieldValue("Transaction", "ItemSubTitle", itemSubTitle);
	SetFieldValue("Transaction", "ItemIssue", itemIssue);
	SetFieldValue("Transaction", "ItemVolume", itemVolume);
	SetFieldValue("Transaction", "ReferenceNumber", referenceNumber);
	SetFieldValue("Transaction", "Location", location);
	SetFieldValue("Transaction", "SubLocation", subLocation);
	SetFieldValue("Transaction", "ItemInfo1", itemInfo1);
	SetFieldValue("Transaction", "EADNumber", eadNumber);
	SetFieldValue("Transaction", "DocumentType", docType);

	Log("Switching to the detail tab.");
	ExecuteCommand("SwitchTab", {"Detail"});
end

function DoItemImportBarcode() --Same as above but for the barcode table
	Log("Performing Import");

	Log("Retrieving import row.");
	local itemRow = asBarcodeGrid.GridControl.MainView:GetFocusedRow();

	if (itemRow == nil) then
		Log("No rows selected - aborting");
		return;
	end;

	local callNumber = itemRow:get_Item("CallNumber");
	local itemTitle = itemRow:get_Item("ResourceTitle");
	local itemSubTitle = itemRow:get_Item("SeriesTitle");
	local itemIssue = itemRow:get_Item("SeriesDivision");
	local itemVolume = itemRow:get_Item("BoxNumber");
	local referenceNumber = searchBarcode.Value;
	local location = itemRow:get_Item("Location");
	local subLocation = "";-- Should be box format, e.g., Paige 15
	local itemInfo1 = itemRow:get_Item("Restriction");
	local eadNumber = itemRow:get_Item("Handle");
	local docType = computeDocType(callNumber);

	-- Update the item object with the new values.
	Log("Updating the item object.");
	SetFieldValue("Transaction", "CallNumber", callNumber);
	SetFieldValue("Transaction", "ItemTitle", itemTitle);
	SetFieldValue("Transaction", "ItemSubTitle", itemSubTitle);
	SetFieldValue("Transaction", "ItemIssue", itemIssue);
	SetFieldValue("Transaction", "ItemVolume", itemVolume);
	SetFieldValue("Transaction", "ReferenceNumber", referenceNumber);
	SetFieldValue("Transaction", "Location", location);
	SetFieldValue("Transaction", "SubLocation", subLocation);
	SetFieldValue("Transaction", "ItemInfo1", itemInfo1);
	SetFieldValue("Transaction", "EADNumber", eadNumber);
	SetFieldValue("Transaction", "DocumentType", docType);

	Log("Switching to the detail tab.");
	ExecuteCommand("SwitchTab", {"Detail"});
end

function computeDocType(callNumber)
	if(string.find(callNumber,"MS") ~= nil) then
		return "Manuscript";
	end
	if(string.find(callNumber,"RU") ~= nil) then
		return "Archives";
	end
	if(string.find(callNumber,"HVT") ~= nil) then
		return "Fortunoff";
	end
	if(string.find(callNumber,"HM") ~= nil) then
		return "Microform";
	end
	return "";
end

function RegisterTabControl(form)
	-- get a handle for the tab control
	-- first, obtain the DevExpress Panel control
	local dePanel = findObjectTypeInCollection(form.Form.Controls, "DevExpress.XtraEditors.PanelControl:");
	if dePanel == nil then
		Log("COULD NOT FIND A DevExpress.XtraEditors.PanelControl " ..
			 "OBJECT IN THE ADDON FORM... EXITING!");
		return;
	end

	-- then the Layout control for the Panel
	local deLayout = findObjectTypeInCollection(dePanel.Controls, "DevExpress.XtraLayout.LayoutControl:");
	if deLayout == nil then
		Log("COULD NOT FIND A DevExpress.XtraEditors.LayoutControl " ..
			 "OBJECT IN THE ADDON FORM... EXITING!");
		return;
	end

	-- the tab control within that Layout
	local tabControl = deLayout.Root.Items:get_Item(0);
	if not string.startsWith(tostring(tabControl), "DevExpress.XtraLayout.TabbedControlGroup:") then
		Log("COULD NOT FIND A DevExpress.XtraLayout.TabbedControlGroup " ..
			 "OBJECT IN THE ADDON FORM... EXITING!");
		return;
	end

	--Store the tabs for later use
	Tabs["Control"] = tabControl;
	Tabs["CN"] = tabControl.TabPages:get_Item(0);
	Tabs["BC"] = tabControl.TabPages:get_Item(1);

	--Set the tab page per user preference
	tabControl.SelectedTabPage = GetStartingTab();

	-- handle the tab switching event
	-- this is set after the tab is set to avoid having the ribbon switching
	-- while the user is still on the detail tab without moving to the addon
	tabControl.SelectedPageChanged:Add(TabSwitched);
end

function GetStartingTab()
	if (settings["DefaultSearch"] == "CN") then
		makeRibbonVisible(Ribbons["CN"], true);
		makeRibbonVisible(Ribbons["BC"], false);
		return Tabs["CN"];
	elseif (settings["DefaultSearch"] == "BC") then
		makeRibbonVisible(Ribbons["BC"], true);
		makeRibbonVisible(Ribbons["CN"], false);
		return Tabs["BC"];
	else
		Log(string.format("Invalid default search option [ ] specified. Valid options are 'BC' or 'CN'. Defaulting to CN",settings["DefaultSearch"]));
		return Tabs["CN"];
	end
end

function OnError(ex)
	Log("Error message: ".. ex.Message);
	Log("Inner exception error message: " .. ex.InnerException.Message);
    Log("Inner inner exception error message: " .. ex.InnerException.InnerException.Message);
end
