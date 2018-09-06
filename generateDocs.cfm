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
	// create with default strategy
	docbox = new docbox.DocBox( properties = { 
		projectTitle = "ColdThumbs documentation", 
		outputDir    = "#expandPath( '/docs' )#"
	});

	docbox.generate(
	    source  = "#expandPath( '/models' )#",
	    mapping = "models"
	);

	location(url='/docs/index.html', addtoken=false);
</cfscript>