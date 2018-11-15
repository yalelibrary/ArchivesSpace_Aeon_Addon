--
-- Methods related to filling grid controls
--

function clearTable(gridControl)
	if (gridControl.MainView ~= nil) then
		if (gridControl.PrimaryTable ~= nil) then
			gridControl.PrimaryTable:Clear();
		end
		if (gridControl.MainView.Columns ~= nil) then
			gridControl.MainView.Columns:Clear();
		end
	end
end

function fillSeriesTable(gridControl)

	-- Set the grid view options
	local gridView = gridControl.MainView;
	gridView.Columns:Clear();
	gridView.OptionsView.ShowIndicator = false;
	gridView.OptionsView.ShowGroupPanel = false;
	gridView.OptionsView.RowAutoHeight = true;
	gridView.OptionsView.ColumnAutoWidth = false;
	gridView.OptionsBehavior.AutoExpandAllGroups = true;
	gridView.OptionsBehavior.Editable = false;

	-- Add the grid columns
	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "SID";
	gridColumn.FieldName = "series_id";
	gridColumn.Name = "gcSeries_id";
	gridColumn.Visible = false;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Collection Title";
	gridColumn.FieldName = "collection_title";
	gridColumn.Name = "gcCollection_title";
	gridColumn.Visible = false;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Finding Aid Link";
	gridColumn.FieldName = "ead_location";
	gridColumn.Name = "gcEad_location";
	gridColumn.Visible = false;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Subdivision";
	gridColumn.FieldName = "series_div";
	gridColumn.Name = "gcSeriesDiv";
	gridColumn.Width = 115;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 2;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Title";
	gridColumn.FieldName = "series_title";
	gridColumn.Name = "gcSeriesTitle";
	gridColumn.Width = 185;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 3;
	gridColumn.OptionsColumn.ReadOnly = true;

	collectionTitle.Value = "Empty or No Result Found";
	local firstRow = asSeriesGrid.GridControl.MainView:GetRow(0);
	collectionTitle.Value = firstRow:get_Item("collection_title");

end


function fillItemTable(gridControl)

	Log("Initializing item grid control");

	-- Set the grid view options
	local gridView = gridControl.MainView;
	gridView.Columns:Clear();
	gridView.OptionsView.ShowIndicator = false;
	gridView.OptionsView.ShowGroupPanel = false;
	gridView.OptionsView.RowAutoHeight = true;
	gridView.OptionsView.ColumnAutoWidth = false;
	gridView.OptionsBehavior.AutoExpandAllGroups = true;
	gridView.OptionsBehavior.Editable = false;

	-- Add the grid columns
	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "CallNumber";
	gridColumn.FieldName = "callNumber";
	gridColumn.Name = "gcCallNumber";
	gridColumn.Width = 80;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 0;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Container";
	gridColumn.FieldName = "enumeration";
	gridColumn.Name = "gcEnumeration";
	gridColumn.Width = 150;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 1;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Barcode";
	gridColumn.FieldName = "item_barcode";
	gridColumn.Name = "gcItemBarcode";
	gridColumn.Width = 100;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 2;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Location";
	gridColumn.FieldName = "location";
	gridColumn.Name = "gcLocation";
	gridColumn.Width = 150;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 3;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Type";
	gridColumn.FieldName = "subLocation";
	gridColumn.Name = "gcType";
	gridColumn.Width = 110;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 4;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Restrictions";
	gridColumn.FieldName = "suppress_in_opac";
	gridColumn.Name = "gcRestrictions";
	gridColumn.Width = 110;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 5;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "TCID";
	gridColumn.FieldName = "item_id";
	gridColumn.Name = "gcItem_Id";
	gridColumn.Width = 50;
	gridColumn.Visible = true;
	gridColumn.VisibleIndex = 6;
	gridColumn.OptionsColumn.ReadOnly = true;
	--gridColumn.SortOrder = Types["DevExpress.Data.ColumnSortOrder"].Ascending;

end

function fillBarcodeTable(gridControl)

	-- Set the grid view options
	local gridView = gridControl.MainView;
	gridView.Columns:Clear();
	gridView.OptionsView.ShowIndicator = false;
	gridView.OptionsView.ShowGroupPanel = false;
	gridView.OptionsView.RowAutoHeight = true;
	gridView.OptionsView.ColumnAutoWidth = false;
	gridView.OptionsBehavior.AutoExpandAllGroups = true;
	gridView.OptionsBehavior.Editable = false;

	-- Add the grid columns
	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Origin";
	gridColumn.FieldName = "Origin";
	gridColumn.Name = "gcOrigin";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Resource Title";
	gridColumn.FieldName = "ResourceTitle";
	gridColumn.Name = "gcResourceTitle";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Resource/Bib Id";
	gridColumn.FieldName = "ResourceId";
	gridColumn.Name = "RcResourceId";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Author";
	gridColumn.FieldName = "Author";
	gridColumn.Name = "gcAuthor";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "CallNumer";
	gridColumn.FieldName = "CallNumber";
	gridColumn.Name = "gcCallNumber";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Series Title";
	gridColumn.FieldName = "SeriesTitle";
	gridColumn.Name = "gcSeriesTitle";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Series Division";
	gridColumn.FieldName = "SeriesDivision";
	gridColumn.Name = "gcSeriesDivision";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Restriction";
	gridColumn.FieldName = "Restriction";
	gridColumn.Name = "gcRestriction";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "BoxNumber";
	gridColumn.FieldName = "BoxNumber";
	gridColumn.Name = "gcBoxNumber";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Location";
	gridColumn.FieldName = "Location";
	gridColumn.Name = "gcLocation";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	local gridColumn;
	gridColumn = gridView.Columns:Add();
	gridColumn.Caption = "Handle";
	gridColumn.FieldName = "Handle";
	gridColumn.Name = "gcHandle";
	gridColumn.Visible = true;
	gridColumn.OptionsColumn.ReadOnly = true;

	collectionTitle.Value = "Empty or No Result Found";
	local firstRow = asBarcodeGrid.GridControl.MainView:GetRow(0);
	collectionTitle.Value = firstRow:get_Item("ResourceTitle");
end
