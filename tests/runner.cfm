<!---
*******************************************************************************
Coldthumbs
Copyright 2018 - Simian Enterprises Ltd.
www.simianenterprises.co.uk
*******************************************************************************
Author: Gary Stanton 
Twitter: @SimianE
--->
<cfsetting showDebugOutput="false">
<!--- Executes all tests in the 'specs' folder with simple reporter by default --->
<cfparam name="url.reporter" 			default="simple">
<cfparam name="url.directory" 			default="tests.specs">
<cfparam name="url.recurse" 			default="true" type="boolean">
<cfparam name="url.bundles" 			default="">
<cfparam name="url.labels" 				default="">
<cfparam name="url.reportpath" 			default="#expandPath( "/tests/results" )#">
<cfparam name="url.propertiesFilename" 	default="TEST.properties">
<cfparam name="url.propertiesSummary" 	default="false" type="boolean">

<!--- Include the TestBox HTML Runner --->
<cfif (fileExists(getDirectoryFromPath(getCurrentTemplatePath()) & '../testbox/system/runners/HTMLRunner.cfm'))>
	<cfinclude template="../testbox/system/runners/HTMLRunner.cfm" >
<cfelse>
	<h2>Testbox is not installed</h2><p>Have you run `install` from CommandBox?</p>
</cfif>