// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};
var temp = {};
var templates_loaded = false;

Function.prototype.bind = function (obj) {
	var fn = this;
	return function () {
		return fn.apply(obj, arguments);
	}
};

String.prototype.trim = String.prototype.trim || function() {
        return this.replace(/^\s+|\s+$/,"");
}

jQuery(function() {
	
		if( ($.browser.msie  && parseInt($.browser.version, 10) <= 7) ? true : false  ){
			$('<div><p class="warn">CivicEvolution has evolved and no longer works with version ' + parseInt($.browser.version, 10) + ' of Microsoft Explorer</p><p>Please use Google Chrome, Firefox, Safari or Internet Explorer version 8 or greater</p></div>').dialog({title: 'Error', modal: true});
		}
	
	//console.log("********** Update support.borderRadius")
	jQuery.support.borderRadius = false;
	jQuery.each(['BorderRadius','borderRadius','MozBorderRadius','WebkitBorderRadius','OBorderRadius','KhtmlBorderRadius'], function() {
		if(document.body.style[this] !== undefined) jQuery.support.borderRadius = true;
		return (!jQuery.support.borderRadius);
	});
});
var AUTH_TOKEN;
$(function(){
		AUTH_TOKEN = $("meta[name='csrf-token']").attr("content");
		$(document).ajaxSend(function(e, xhr, options) {
		  xhr.setRequestHeader("X-CSRF-Token", AUTH_TOKEN);
		});	
		if(params['video']=='play'){
			setTimeout(function(){ $('a#play_intro_video').click(); },1000);
		}
		if (typeof JSON == 'undefined' || !JSON) { console.log("load json2"); $.getScript('/assets/opt/json2-min.js'); }
});

function ajaxDisableElement(el){
	var element = $(el);
	element.data('ujs:enable_with', element.html()); // store enabled state+     
	if(element.attr('wait') == 'gif'){
		element.html( element.attr('data-disable-with') || '<img src="/assets/wait5.gif"/>' ); // set to disabled state
	}else{
		element.html( element.attr('data-disable-with') || 'Loading...' ); // set to disabled state
	}
	element.addClass('loading');
	//element.bind('click.railsDisable', function(e) { // prevent further clicking
	//	return rails.stopEverything(e)
	//});
}

// restore element to its original state which was disabled by 'disableElement' above
function ajaxEnableElement(el){
	var element = $(el);
	if (element.data('ujs:enable_with') !== undefined) {
		element.html(element.data('ujs:enable_with')); // set to old enabled state
		element.removeClass('loading');
		element.removeData('ujs:enable_with'); // clean up cache
	}
	element.unbind('click.railsDisable'); // enable element
}

$('a[data-remote]').live('ajax:beforeSend', 
	function(){
		//console.log("ajax beforeSend");
		ajaxDisableElement(this);
	}
).live('ajax:complete', 
	function(){
		//console.log("ajax complete")
		ajaxEnableElement(this)	
	}
)

$('form[data-remote]').live('ajax:beforeSend', 
	function(){
		//console.log("form ajax beforeSend");
		$(this).find('div#errorExplanation').remove();
		$(this).find(':submit').hide().after('<img class="wait" src="/assets/wait5.gif"/>');
	}
).live('ajax:complete', 
	function(){
		//console.log("form ajax complete")
		$(this).find(':submit').show().end().find('img').remove();
	}
)


$('div.right_side form.signin_form').attr('data-remote','true');
$('form.signin_form').live('ajax:beforeSend', 
	function(){
		$(this).closest('div.member').find('p.error').remove();
	}
);

$('a.tgl_sign_in').die('click').live('click',
	function(){
		var link = $(this);
		//console.log("change form to " + link.attr('id') );
	  switch(link.attr('id')){
	  	case 'reset':
	  		link.closest('table').find('tr').hide().end().find('tr.reset').show();
	  		link.closest('table').find('tr :submit').attr('disabled','disabled').end().find('tr.reset :submit').removeAttr('disabled');
	  		break;
	  	case 'signin':
	  		link.closest('table').find('tr').hide().end().find('tr.signin').show();
	  		link.closest('table').find('tr :submit').attr('disabled','disabled').end().find('tr.signin :submit').removeAttr('disabled');
	  		break;
	  	case 'signup':
	  		link.closest('table').find('tr').hide().end().find('tr.signup').show();
	  		link.closest('table').find('tr :submit').attr('disabled','disabled').end().find('tr.signup :submit').removeAttr('disabled');
	  		break;
  		case 'signup_error_link':
	  		link.closest('div').find('table tr').hide().end().find('tr.signup').show();
	  		link.closest('div').find('table tr :submit').attr('disabled','disabled').end().find('tr.signup :submit').removeAttr('disabled');
	  		break;
	  }
	  link.closest('div.member').find('p.error').remove();
		return false;
	}
);

function activate_text_counters_grow(els, height){
	if(!$('body').autoGrow) return;
	height = height? height : 50
	els.each(
		function(){
			var el = $(this);
			var span = el.next().find('span.char_ctr');
			while(span.size() == 0 && !el[0].nodeName.match(/BODY/i) ){
				el = el.parent();
				span = el.find('span.char_ctr');
			}
			if(span.size() == 1){
				el = $(this);
				try{
				var cnt = Number(span.html().match(/\d+/));
				el.show_char_limit(cnt, {
			    error_element: span,
					status_element: span
			  });
				span.siblings('a.clear').click(
					function(){
						el.val('');
						el.next('div.attachments').find('img.delete').each( function(){ $(this).click(); } );
						el.focus();
						return false;
					}
				);
			}catch(e){}
				if(el[0].nodeName == 'TEXTAREA'){
					// if the el is not displayed, IE gives it a width of 0 and the el cannot be setup to grow
					if(el[0].offsetWidth > 0){
						el.autoGrow({
							minHeight  : height,
							maxHeight : 500
						});
					}
				}
			}
		}
	)
}


function init_add_this(){
	if( typeof _atd != 'undefined' ) return 
	
	var addthis_config = {"data_track_clickback":true};
	var addthisScript = "http://s7.addthis.com/js/250/addthis_widget.js#username=civicevolution"

	function initAddthis(){ 
		if (window.addthis){ 
			window.addthis.ost = 0; 
			window.addthis.init(); 
		} 
	} 

	$.getScript( addthisScript , function(){
		initAddthis()
	});
	
}

function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}
var params = getUrlVars();

function demo_type_text(selector,text){
	var target = $(selector);
	var ctr = 1;
	var chars = text.split('');
	setTimeout(function(){
		target.val('');
		addChar();
	}, 3000);
	function addChar(){
		target[0].value += chars.shift();
		target.focus();
		if(chars.length > 0){
			setTimeout(addChar, 60);
		}
	}
}

$('body').on('dialogopen', 'div.ui-dialog-content', function(event) {
	var dlg = $(this);
	if(dlg.dialog('option','modal')){
		$('body').addClass('modal-open');
		setTimeout(function(){
			this.css('overflow-y','auto');
			this.find('a,select').blur();
			this.find('input[type="text"]:first').focus();
			}.bind(dlg),500
		);
		dlg.bind('dialogbeforeclose', function(event) {
			var dlg = $(this);
			if(dlg.dialog('option','modal')){
				$('body').removeClass('modal-open');
			}
		});
		dlg.bind('dialogclose', function(event) {
			var dlg = $(this);
			dlg.dialog('destroy').remove();
		});
	}
});	


//
// adjust the # of comments displayed and truncate long comments
//

$('body').on('click', 'a.show-all-comments',
	function(){
		var div = $(this).closest('div.show_all');
		var stream = div.closest('div.activity_stream').find('div.comment').show(350);
		setTimeout(function(){ truncate_comments( this )}.bind(stream), 700 );
		div.hide(350,function(){$(this).remove();});
		return false;
	}
);

function truncate_comments(section){
	section = section || $('body');
	section.find('div.com_text').each( 
		function(){
			var inner = $(this);
			if(inner.height() > 100){
				inner.addClass('truncated').append('<p class="more">More...</p>');
			}
		}
	);
}

$('body').on('click', 'div.com_text p.more',
	function(){
		$(this).closest('div.com_text').removeClass('truncated').find('p.more').remove();
	}
);