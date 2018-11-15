--- Event handlers related to archivespace search, event registration usually in main.lua

function BarcodeSubmitCheck(sender, args)
	if tostring(args.KeyCode) == "Return: 13" then
		SearchBarcode();
	end
end

function SeriesSubmitCheck(sender, args)
	if tostring(args.KeyCode) == "Return: 13" then
		SearchSeries();
	end
end

function SeriesSelectCheck(sender, args)
    local keyCode = tostring(args.KeyCode);
	if (keyCode == "Return: 13") then
		GetBoxes();
--    else 
--        Log(keyCode);
	end
end

function ItemSelectCheck(sender, args)
    local keyCode = tostring(args.KeyCode);
	if (keyCode == "Return: 13") then
		DoItemImport();
	end
end

function TabSwitched(sender, args)
	--https://documentation.devexpress.com/#WindowsForms/DevExpressXtraTabXtraTabControl_SelectedPageChangedtopic
	--We have an issue here that the tabs weren't defined in code (because that was a brutal process) so they were
	--defined directly in the layout.xml. Therefore their names aren't very descriptive and their text isn't set
	--in the addon code. That means that we're hard coding in a value here that has to be manually kept in sync with
	--whatever is in Layout.xml unless the addon is refactored to generate the tabs in code.
	--Note a gotcha that Ribbons["BC"].Page.Ribbon.SelectedPage = Ribbons["BC"].Page; *seems* like what you want to 
	--do but *actually* the ribbon focus needs to be set in the main ribbon which has to be retrieved from the interfaceManager
	local tabText = args.Page.Text;
	Log("Tab switched to: " .. tabText); --This should never be null
	if	(tabText == "Barcode Search") then
		makeRibbonVisible(Ribbons["BC"], true);
		makeRibbonVisible(Ribbons["CN"], false);
		globalInterfaceMngr.TargetRibbon.SelectedPage = Ribbons["BC"].Page;
	elseif	(tabText == "CallNumber Search") then
		makeRibbonVisible(Ribbons["CN"], true);
		makeRibbonVisible(Ribbons["BC"], false);
		globalInterfaceMngr.TargetRibbon.SelectedPage = Ribbons["CN"].Page;
	end
end

function handleBarcodeGridDoubleClick(sender, args)
	Log("Double clicked barcode grid");
	DoItemImportBarcode();
end

function handleSeriesGridDoubleClick(sender, args)
    Log("Double click in series grid");
    local pt = sender.GridControl:PointToClient((Types["System.Windows.Forms.Control"]).MousePosition);
	local info = sender:CalcHitInfo(pt);
	if info.InRow or info.InRowCell then
		seriesId = tostring(sender:GetRowCellValue(info.RowHandle, "series_id"));
		if seriesId ~= nil and isnumeric(seriesId) then
            Log("Series selected: " .. seriesId);
			GetBoxes(seriesId);
        else
            Log("Series ID null or non-numeric");
		end
	end
end

function handleItemGridDoubleClick(sender, args)
    Log("Double click in container grid");
    local pt = sender.GridControl:PointToClient((Types["System.Windows.Forms.Control"]).MousePosition);
	local info = sender:CalcHitInfo(pt);
	if info.InRow or info.InRowCell then
            Log("Row selected");
			DoItemImport();
    else
        Log("Click was not in an item row");
    end
end