/**
*******************************************************************************
* Coldthumbs
* Copyright 2018 - Simian Enterprises Ltd.
* www.simianenterprises.co.uk
*******************************************************************************
* @author Gary Stanton 
*/

component extends="coldbox.system.testing.BaseTestCase" appMapping="/tests" {
	
	/*********************************** LIFE CYCLE Methods ***********************************/
	function beforeAll(){
		structDelete( application, getColdboxAppKey() );
		super.beforeAll();
	}
}
