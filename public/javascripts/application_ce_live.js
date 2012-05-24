// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};
temp = {};

//console.log("Loading application.js");

jQuery(function() {
	//console.log("********** Update support.borderRadius")
	jQuery.support.borderRadius = false;
	jQuery.each(['BorderRadius','borderRadius','MozBorderRadius','WebkitBorderRadius','OBorderRadius','KhtmlBorderRadius'], function() {
		if(document.body.style[this] !== undefined) jQuery.support.borderRadius = true;
		return (!jQuery.support.borderRadius);
	});
});

$(function(){
		$(document).ajaxSend(function(e, xhr, options) {
		  var token = $("meta[name='csrf-token']").attr("content");
		  xhr.setRequestHeader("X-CSRF-Token", token);
		});	
		if (typeof JSON == 'undefined' || !JSON) { console.log("load json2"); $.getScript('/javascripts/json2-min.js'); }
		activate_text_counters_grow($('textarea'), 120);
});

function ajaxDisableElement(el){
	var element = $(el);
	element.data('ujs:enable_with', element.html()); // store enabled state+      
	element.html( element.attr('data-disable-with') || 'Loading...' ); // set to disabled state
	//element.html( element.attr('data-disable-with') || '<img src="/images/wait5.gif"/>' ); // set to disabled state
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
		$(this).find(':submit').hide().after('<img src="/images/wait5.gif"/>');
	}
).live('ajax:complete', 
	function(){
		//console.log("form ajax complete")
		$(this).find(':submit').show().end().find('img').remove();
	}
)

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

Function.prototype.bind = function (obj) {
	var fn = this;
	return function () {
		return fn.apply(obj, arguments);
	}
};

function post_theme_changes( data ){
  console.log("post theme data to server");
  data.live_session_id = live_session_id;
  var url = '/live/post_theme';
  $.ajax({
	  url: url, 
	  data: data,
	  type: 'POST',
	  dataType: 'script'
	});
	if(post_theme_changes.update_fn){
	  setTimeout(post_theme_changes.update_fn,1200);
	}
}

function editing_disabled(){
  if(disable_editing){
    if(published){
      var msg = 'Editing is disabled because themes have been published'
    }else{
      var msg = 'You do not have editing privileges'
    }
		var dialog = $('<p class="warn">' + msg + '</p>').dialog( {title : 'Sorry', modal : true, width : '200px', closeOnEscape: true, close: function(){$(this).remove()} });
		return true;
	}else{
	  return false;
	}
}
var font_resize_factor = 1;
$('a.resize').die('click').live('click',
  function(){
    var link = $(this);
    if(link.hasClass('increase')){
      //console.log("increase font");
      font_resize_factor = 1.08 * font_resize_factor;
      $('div.content').css('font-size', font_resize_factor + 'em');
    }else{
      //console.log("descrease font");
      font_resize_factor = 0.92 * font_resize_factor;
      $('div.content').css('font-size', font_resize_factor + 'em');
    }
    return false;
  }
);