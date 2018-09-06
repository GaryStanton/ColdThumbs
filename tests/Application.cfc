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
}