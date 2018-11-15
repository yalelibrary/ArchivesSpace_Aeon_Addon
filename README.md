Aeon\_Addon\_AS\_Basic
===================

A minimal archivesSpace addon designed to be a replacement in functionality for previous ATK Addon. It retrieves data from the aeon ajax service currently used for self-filling webforms.

## Bugfixing Notes
Based on responses from the prioritization, scores have been applied to issues ranked or highlighted by one or more people, and weighted by list position. These issues will be marked for fixing first, along with any that require minimal effort to change (e.g., label changes).

## Expected Operation
The addon retrieves information from the legacy ajax service. That service is currently hosted in a named folder on [Aeon Server]-c:\inetpub\wwwroot.  Source code is located [here](https://github.com/yalelibrary/ArchivesSpace_Aeon_Middleware).

The service prepopulates the call number text box with the call number, if any, presently in the transaction. If the autosearch setting is set to "true" then the addon will also execute a search to retrieve archival objects marked at the "series" level for the collection. It does this by performing a search for resources with a call number match and then retrieving their top children using the /tree endpoint on resources. The finding aid link is retrieved using a second trip to resources (this time to the numbered endpoint) and the series title is retrieved by looping through every returned series to access its /archival_object endpoint - the only place where series subdivision is reliably stored. Once a series is selected pressing "get boxes" will retrieve all top-level containers associated with a series. Pressing the import button will then load those items into the transaction.

The TCID field is the ArchivesSpace internal identifier for the top container. It is not imported. The imported fields are as follows:


-   CallNumber (from item - resources search)
-   ItemTitle (from series - resources tree collection title)
-   ItemSubtitle (from series - archival object series title)
-   ItemIssue (from item - resources search - top container)
-   ReferenceNumber (from item - barcode)
-   Location (from item - location display text)
-   SubLocation (from item - type, through a regex)
-   ItemInfo1 (from item - restriction info as y/n)
-   EADNumber (from series - resource ead link)

## Installation ##
The addon should be retrieved automatically from the addon directory by Aeon. If this does not happen then the addon can be manually installed by droping it in the Aeon\Addons folder in the "My Documents" folder of the relevant user.

The deploy.ps1 powershell script can be used in conjunction with a cd tool dynamically choose a configuration file and bump the version number in order to ensure that the newest version of the addon is always retrieved by clients.

## Known Issues ##
There are several issues that may cause problems with the addon. 

- A malformed call number may yield empty results - this was user preference over closest match.
- Tags in text are stripped and text xml encoded at the webservice, but it is undetermined whether there are any that will cause problems.
