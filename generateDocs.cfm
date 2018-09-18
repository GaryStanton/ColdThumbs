<!---
*******************************************************************************
Coldthumbs
Copyright 2018 - Simian Enterprises Ltd.
www.simianenterprises.co.uk
*******************************************************************************
Author: Gary Stanton 
Twitter: @SimianE
--->

<cfscript>
	// Check we have docbox installed
	if (fileExists(getDirectoryFromPath(getCurrentTemplatePath()) & 'docbox/DocBox.cfc')) {
		// create with default strategy
		docbox = new docbox.DocBox( properties = { 
			projectTitle = "ColdThumbs documentation", 
			outputDir    = "#expandPath( 'docs/' )#"
		});

		docbox.generate(
		    source  = "#expandPath( 'models/' )#",
		    mapping = "models"
		);

		location(url='docs/', addtoken=false);
	}
	else {
		writeOutput('<h2>Docbox is not installed</h2><p>Have you run `install` from CommandBox?</p>');
	}
</cfscript>