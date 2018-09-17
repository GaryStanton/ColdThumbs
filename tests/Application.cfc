/**
*******************************************************************************
* Coldthumbs
* Copyright 2018 - Simian Enterprises Ltd.
* www.simianenterprises.co.uk
*******************************************************************************
* @author Gary Stanton 
*/

component{
	
	this.name 						= hash( getCurrentTemplatePath() );
	this.mappings[ '/root' ]        = expandPath( getDirectoryFromPath( getCurrentTemplatePath() ) & '../../' );
	this.mappings[ '/tests' ]       = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings[ '/testbox' ]  	= getDirectoryFromPath( getCurrentTemplatePath() ) & '../testbox/';
	this.mappings[ '/coldbox' ]  	= getDirectoryFromPath( getCurrentTemplatePath() ) & '../coldbox/';
	this.mappings[ '/models' ]  	= getDirectoryFromPath( getCurrentTemplatePath() ) & '../models/';

	function onError(e){
		writeDump(e);
	}
}