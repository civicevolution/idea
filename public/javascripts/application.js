// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};
temp = {};

console.log("Loading application.js");

jQuery(function() {
	console.log("********** Update support.borderRadius")
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
		init_page();
		if(params['video']=='play'){
			setTimeout(function(){ $('a#play_intro_video').click(); },1000);
		}
		if (typeof JSON == 'undefined' || !JSON) { console.log("load json2"); $.getScript('/javascripts/json2-min.js'); }
});

function ajaxDisableElement(el){
	var element = $(el);
	element.data('ujs:enable_with', element.html()); // store enabled state+      
	element.html( element.attr('disable-with') || 'Loading...' ); // set to disabled state
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

$('a.display_worksheet').live('ajax:beforeSend', 
	function(){
		// if the WS is already open, return false
		var id = Number($(this).attr('href').match(/\d+/));
		var disable_flag = $('div.worksheet[id="' + id + '"]').size() > 0 ? true : false
		console.log("display_worksheet beforeSend disable_flag: " + disable_flag )
		if(disable_flag){
			// make sure the link is restored
			temp.dw_link = this;
			setTimeout(function(){ajaxEnableElement(this)}.bind(this),10);
			return false;
		}else{
			open_question_worksheet(this);
		}
	}
)

$('a.close_worksheet').live('ajax:beforeSend', 
	function(){
		close_question_worksheet(this);
		//return false;
	}
)

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

function init_page(){
	//console.log("init_page")
	init_worksheet();
	var q_tabs = $('div.list_tabs');
	if(q_tabs.size()>0){
		var tab_template = q_tabs.find('ul').html();
		q_tabs.find('ul').html(''); // remove the tab model
		tab_template = tab_template.replace('#tab_curated_q1','#{href}').replace('Q1','#{label}');
		$("div.list_tabs").tabs({tabTemplate: tab_template, select: tab_select});
	}
	if(typeof right_panel_init != "undefined"){
		right_panel_init();
	}
	
	if(!$.support.borderRadius){ 
		console.log("load corner support script and activate");
		$.getScript('/javascripts/jquery.corner.js', 
			function(){
				//console.log("corner has been loaded")
				//var non_worksheet_corners = $('.corner');
				//if( non_worksheet_corners.size() > 0 ){
				//	non_worksheet_corners.corner();
				//}
				$('div.right_side div.corner').css('background-color','#eee').corner();
			}
		);
	}else{
		// define dummy corner function
		$.fn.corner = function(){ return this; }
	}
	try{
		init_add_this();
	}catch(e){}
	try{
		$("a[rel^='prettyPhoto']").prettyPhoto({theme: 'dark_rounded'});
		//console.log("pretty photo is okay")
	}catch(e){}
	
	// temp init of suggested action call to action show me link
	$('div.suggested_action a.show_me').die('click').live('click',
		function(){
			console.log("show how to rate");
			$.getScript('/visual_help',function(){
				setTimeout( function(){$.scrollTo('h3.rating_talking_points',600)}, 1000)
			});
			return false;
		}
	);
	
	
	
	
}

function tab_select(event,ui){
	setTimeout(right_panel_resize,100);
}

function init_worksheet(){
	remove_worksheet_form();
	reformat_talking_point_entries();
	activate_text_counters_grow($('textarea, input[type="text"]'), 120);
}

function remove_worksheet_form(){
	$('input.submit_ratings').remove();
	var form = $('form.update_worksheet');
	var div = $('<div class="form_replace"></div>').html( form.children().remove() );	
	form.after(div);
	form.remove();
}

function reformat_talking_point_entries(){
	$('div.my_rating').addClass('js') // arrange for compressed javascript enabled format
	$('div.community_rating').removeClass('no_js');
	$('div.graph.no_js').remove();
}

$('div.my_rating :radio').die('change').live('change',
	function(){
		var id = $(this).closest('.talking_point_entry').attr('id');
		if(id==0){
			alert('This is an example of a talking point and you cannot act on it.'); 
		}else{
			$.post('/talking_points/' + id + '/rate', {rating: this.value}, function(){}, "script");
			$(this).closest('div.radios').find('p.option').html('Saving...');
		}
	}
);

$('div.radios div').live('mouseover mouseout', function(event) {
	var el = $(this);
	var p = el.closest('div.my_rating').find('p.option').removeClass('please_rate')
  if (event.type == 'mouseover') {
		var title = el.find('input').attr('title');
		p.html(title)
  } else {
		p.html(p.attr('title'))
  }
});

$('div.talking_point_acceptable.rated').live('mouseover mouseout', function(event) {
	var com_rate = $(this).find('div.community_rating');
	var radios = com_rate.next('div.radios');
  if (event.type == 'mouseover') {
		com_rate.addClass('hide');
		radios.removeClass('hide');
  } else {
		com_rate.removeClass('hide');
		radios.addClass('hide');
  }
});

$('div.talking_point_entry').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
		$(this).addClass('mouseover');
  } else {
  	$(this).removeClass('mouseover');
	}
});

$('div.radios label').live('click', function() {
	var el = $(this);
	var p = el.closest('div.my_rating').find('p.option');
	var title = el.find('input').attr('title');
	p.html(title);
	p.attr('title',title);
});

$('input.fav_button').die('mouseup mousedown')
	.live('mouseout',
		function(){
			$(this).removeClass('mousedown');
		}
	)
	.live('mouseup',
		function(){
			var button = $(this);
			button.removeClass('mousedown');
			var id = button.closest('.talking_point_entry').attr('id');
			if(id==0){
				alert('This is an example of a talking point and you cannot act on it.'); 
			}else if( !button.hasClass('saving') ) {
				var new_pref = button.hasClass('fav') ? 'false' : 'true';
				button.addClass('saving');
				$.post('/talking_points/' + id + '/prefer', {prefer: new_pref}, function(){}, "script");
			}
		}
	)
	.live('mousedown',
		function(){
			$(this).addClass('mousedown')
			//var button = $(this);
			//button.addClass('mousedown');
			//var id = button.closest('.talking_point_entry').attr('id');
			//if(id==0){
			//	alert('This is an example of a talking point and you cannot act on it.'); 
			//}else{
			//	var new_pref = button.hasClass('fav') ? 'false' : 'true';
			//	button.addClass('saving');
			//	$.post('/talking_points/' + id + '/prefer', {prefer: new_pref}, function(){}, "script");
			//}
		}
	);
	
//$('div.favorite button').die('click').live('click',
//	function(){
//		var button = $(this);
//		var id = button.closest('.talking_point_entry').attr('id');
//		if(id==0){
//			alert('This is an example of a talking point and you cannot act on it.'); 
//		}else{
//			$.post('/talking_points/' + id + '/prefer', {prefer: button.attr('val')}, function(){}, "script");
//		}
//	}
//);

$('div.home_page table.proposal_stats').die('click').live('click',
	function(){
		document.location = '/plan/' + $(this).closest('div.notebook').attr('id')
	}
)

$('a.endorse_this_proposal').live('click',function(){
	$.scrollTo("div.endorsements",2000);
	return false;
});

$('form#talking_point_form a.clear').live('click',
	function(){
		$(this).closest('form').find('textarea').val('');
		return false;
	}
);

$('form.comment_form a.clear').live('click',
	function(){
		$(this).closest('form').find('textarea').val('');
		return false;
	}
);

$('div.cta1 a.cta').die('click').live('click',
	function(){
		$(this).closest('div.question_summary').find('a.display_worksheet').click();
		return false;
	}
);

$('form.signin_form').live('ajax:beforeSend', 
	function(){
		$(this).closest('div.tab_content').find('p.error').remove();
	}
);

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
