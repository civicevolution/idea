window.onload=function(){
	if(!xmlSupport()){
		document.getElementById('browser_not_ie_ff').style.display='block';
		document.getElementById('firefox2').src = "http://sfx-images.mozilla.org/affiliates/Buttons/firefox2/firefox-spread-btn-1b.png";
	}
	try{
		// update the page with signin or user name
		var firstName = getCookie('first_name');
		if(firstName){
			var div = document.getElementById('showUser');
			div.getElementsByTagName('SPAN')[0].innerHTML = firstName;
			div.style.display = 'block';
		}else{
			document.getElementById('showSignIn').style.display = 'block';
			
		}
	}catch(e){}
/*	
	// update links to ce5.net if the location is not civicevolution.org
	var a_s = document.getElementsByTagName('A');
	var a;
	var i=0;
	var host = document.location.host;
	while(a=a_s[i++]){
		a.href = a.href.replace(/[\w\.]*civicevolution.org/i, host);	
	}
*/	
	var email = getCookie('email');
	//var email;
	//if (document.cookie.match(/email=.*/)) email = document.cookie.match(/email=([^;]*)/)[1];
	//alert("email is " + email);
	var e = (document.forms[0])?document.forms[0].__e:null;
	if(e){ 
		e.value=email;
		e.onchange=saveCookie;
	}
	var u = (document.forms[0])?document.forms[0].u:null;
	if(u){ 
		u.value=email;
		//u.onchange=saveCookie;
	}
	testJSandCookie();
}
function saveCookie(){
	if(e.value!=email){
		var expDate = new Date(new Date().getTime() + 7776000000);
		document.cookie = "email=" + e.value + ";path=/;expires="+expDate;
	}
}

function setCookie(name,value,days,path,domain,sec){
	var nameval=name+"="+encodeURIComponent(value);
	days = days || 0;
	path = path || '/';
	domain = domain || getHostname(2);
	var exp = new Date();exp.setTime(exp.getTime()+days*1000*60*60*24);exp=exp.toGMTString();
	var str=nameval+
		((exp)?"; expires="+exp:"")+
		((path)?"; path="+path:"")+
		((domain)?"; domain="+domain:"")+
		((sec)?"; secure":"");
	if((name.length>0)&&(nameval.length<4000)){
		document.cookie=str;
		return(value==getCookie(name));
	}
}

function removeCookie(name){
	var exp=new Date(90,1,1);
	return setCookie(name,"",exp.toGMTString(),"/",getHostname(2));
}


function getCookie(name){
	name=' '+name+'=';
	var i,cookies;
	cookies=' '+document.cookie+';';
	if((i=cookies.indexOf(name))>=0){
		i+=name.length;
		cookies=cookies.substring(i,cookies.indexOf(';',i));
		return decodeURIComponent(cookies);
	}
	return"";
}

function getHostname(level){
	var hostname=document.location.hostname;
	if("number"==typeof(level)&&0<level){
		var aParts=hostname.split(".");
		aParts.reverse();hostname="";
		for(var i=0;i<level&&i<aParts.length;i++){
			hostname="."+aParts[i]+hostname;
		}
		hostname=hostname.substring(1);
	}
	return hostname;
}	


function testJSandCookie(){
	// make sure this browser has enuf js capability and then set cookie:
	//I need js1.2 functionality, primarily match, so test for it
	var test = "testString";
	if( test.match && test.match(/test/)){
		document.cookie = "js=ok;path=/;";
	}
}
function showSignInStatus(){
	var email = getCookie('email');
	//email = document.cookie.match(/\bemail=([^;]*)/);
	if (email && email.length>1) 
		email = email[1];
	else 
		email=null;
	var s;
	var signin = getCookie('signin');
	//if(document.cookie.match(/\bsignin=true/)){
	if(signin == 'true'){
		s = '<a href="/ce/post?__fn=signout" target="_top">Sign-out</a>';
		signedIn = true;
	}else{
		s = '<a href="/ce/signin.html" target="_top">Sign-in</a>';
	}
	document.write(s);
}

	
	
function xmlSupport(){
	getMsxmlAXstr();
 	if(msxmlAXstr && msxmlVer < "2.3.0" ){
		return false;
	}else if(msxmlAXstr){
		return true;
	}
	try{
		var xsltProcessor = new XSLTProcessor();
	}catch(e){
		return false;
	}
	if ( typeof XSLTProcessor != "undefined"){
		return true;
//		alert("XSLTProcessor ok, navigator.userAgent: " +navigator.userAgent );
//		var gecko = navigator.userAgent.match(/.*Gecko\/(\d*)/);
//		if (gecko && gecko[1]>"20020529"){
//			//return false;
//			return true;			
//		}else{
//			return false;
//		}
	}
	return false;
}

var msxmlAXstr;
var msxmlVer;
function getMsxmlAXstr() {
	var stylesheet;
	if( typeof ActiveXObject == "undefined"){
		msxmlAXstr = null;
		msxmlVer = null;
		return;
	}
	try{
		stylesheet = new ActiveXObject("Msxml2.DOMDocument.3.0");
		msxmlAXstr = "Msxml2.DOMDocument.3.0";
		msxmlVer = "2.3.0";
		return;
	}catch(e){}
	try{
		stylesheet = new ActiveXObject("Msxml2.DOMDocument.2.6");
		msxmlAXstr = "Msxml2.DOMDocument.2.6";
		msxmlVer = "2.2.6";
		return;
	}catch(e){}
	try{
		stylesheet = new ActiveXObject("Msxml2.DOMDocument");
		msxmlAXstr = "Msxml2.DOMDocument";
		msxmlVer = "2.0.0";
		return;
	}catch(e){}
	try{
		stylesheet = new ActiveXObject("Msxml.DOMDocument");
		msxmlAXstr = "Msxml.DOMDocument";
		msxmlVer = "1.0.0";
		return;
	}catch(e){
		msxmlAXstr = null;
		msxmlVer = null;
		return;
	}
}
