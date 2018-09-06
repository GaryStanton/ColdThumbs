<cfscript>
	try {
		directoryDelete(expandPath('./cached'), true);
	}
	catch (any e) {
		
	}
	location(url = CGI.HTTP_REFERER, addtoken = false);
</cfscript>