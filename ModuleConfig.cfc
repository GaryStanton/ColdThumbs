// Shamelessly adapted from the bCrypt ModuleConfig.cfc
component {

	// Module Properties
	this.modelNamespace		= "coldthumbs";
	this.cfmapping			= "coldthumbs";
	
	function configure(){

		// Skip information vars if the box.json file has been removed
		if( fileExists( modulePath & '/box.json' ) ){
			// Read in our box.json file for so we don't duplicate the information above
			var moduleInfo = deserializeJSON( fileRead( modulePath & '/box.json' ) );

			this.title 				= moduleInfo.name;
			this.author 			= moduleInfo.author;
			this.webURL 			= moduleInfo.homepage;
			this.description 		= moduleInfo.shortDescription;
			this.version			= moduleInfo.version;
			
		}

	}
}