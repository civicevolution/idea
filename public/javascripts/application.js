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
		init_page();
		if(params['video']=='play'){
			setTimeout(function(){ $('a#play_intro_video').click(); },1000);
		}
		if (typeof JSON == 'undefined' || !JSON) { console.log("load json2"); $.getScript('/javascripts/json2-min.js'); }
});

function ajaxDisableElement(el){
	var element = $(el);
	element.data('ujs:enable_with', element.html()); // store enabled state+      
	element.html( element.attr('data-disable-with') || 'Loading...' ); // set to disabled state
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
		var id = $(this).closest('.talking_point_post_it').attr('id');
		if(id==0){
			alert('This is an example of a talking point and you cannot act on it.'); 
		}else{
			$.post('/talking_points/' + id + '/rate', {rating: this.value}, function(){}, "script");
			//$(this).closest('div.radios').find('p.option').html('Saving...');
			$(this).closest('div.my_rating').html('<img src="/images/wait3.gif"/><br/>Saving...')
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

$('div.talking_point_post_it').live('mouseover mouseout', function(event) {
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
			var id = button.closest('.talking_point_post_it').attr('id');
			if(id==0){
				alert('This is an example of a talking point and you cannot act on it.'); 
			}else if( !button.hasClass('saving') ) {
				var new_pref = button.hasClass('fav') ? 'false' : 'true';
				//button.addClass('saving');
				button.closest('.favorite').html('<img src="/images/wait3.gif"/>')
				$.post('/talking_points/' + id + '/prefer', {prefer: new_pref}, function(){}, "script");
			}
		}
	)
	.live('mousedown',
		function(){
			$(this).addClass('mousedown')
		}
	);
	

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

function open_question_worksheet(el){
	el = $(el);
	var question_id = el.closest('div.question_summary').attr('id');
	var order_id = Number(el.html().match(/Q(\d+)/)[1]); 
	var question_text = el.html().replace(/Q\d+: /,'');
	
	$.scrollTo($('div.question_summary[id="' + question_id + '"] p.question'), 600)
	return false;
	
	//if ( !$('h3#curated_list_t').attr('class').match(/active/) ) $('h3#curated_list_t').click();
	
	var q_tabs = $('div.list_tabs');
	
	var get_tab = true;
	while(get_tab){
		q_tabs.tabs("add", '#curated_list_' + order_id, 'Q' + order_id);
		new_tab_close = q_tabs.find('a.close_worksheet:last');
		if(new_tab_close.size() > 0 ) get_tab = false;
	}				
	new_tab_close.attr('id',question_id);
	new_tab_close.attr('href',new_tab_close.attr('href').replace(/\d+/,question_id));
	q_tabs.tabs('select','#curated_list_' + order_id);
	
	$('div#curated_list_' + order_id).addClass('tab_content selected_tp_list');
	
	//move the new tab to the correct position if there is more than one tab
	if(q_tabs.find('a.q_tab').size()>1){
		insert_index = 0;
		q_tabs.find('a.q_tab').each(function(){
			var a = $(this);
			var id = Number(a.html().match(/(\d+)/)[1]);
			if(order_id > id) ++insert_index;
			//console.log("html: " + a.html() + ", id: " + id );
		});
		
		// don't swap the tabs if they are the same
		if (q_tabs.find('ul.list_tabs li').eq(insert_index).find('a.q_tab').html() != 
			q_tabs.find('ul.list_tabs li:last').find('a.q_tab').html() ){
				q_tabs.find('ul.list_tabs li').eq(insert_index).before(q_tabs.find('ul.list_tabs li:last'))
			}
	}
	update_right_panel_context('worksheet');

	var tp_sec = el.closest('div.question_summary').find('div.talking_points_list');
	var ul = el.closest('div.question_summary').find('ul.talking_points');
	
	var curated_tps_exist = ul.attr('curated_tp_ids') && ul.attr('curated_tp_ids') != ''

	var data = {
		question: el.html(),
		id: question_id, 
		//close_href: templates['curated_talking_points'].find('a.close_worksheet').attr('href').replace(/\d+/,question_id),
		hide:{ 
			curated: !am_curator && curated_tps_exist && ul.attr('auto_curated') == 'f' ? '' : ' hide',
			non_curated: !am_curator && curated_tps_exist && ul.attr('auto_curated') == 't' ? '' : ' hide',
			curator: am_curator && curated_tps_exist ? '' : ' hide'
		}
	}
	
	if(!curated_tps_exist) data.hide.non_curator_instr = ' hide'

	var ul_offset = ul.offset();
	
	var list_div = $(template_functions['curated_talking_points'](data)).appendTo('body');
	
	// only replace UL with a curated list
	if( curated_tps_exist ){
		list_div.find('ul.talking_points').replaceWith(ul.clone());
	}else{
		list_div.find('ul.talking_points').attr('id',question_id);
	}
	
	list_div.find('ul div').remove();
	list_div.addClass('selected_tp_list corner')

	list_div.css({top: ul_offset.top, left: ul_offset.left, width: ul.width()});

	$('<div class="msg"><h2>...loading the talking points worksheet</h2></div>').insertAfter(tp_sec);
	tp_sec.hide(1000);

	var new_left = $('div.right_side').position().left;
	var new_top = $('div.list_tabs').position().top + $(window).scrollTop() + 31;
	
	//console.log("XXX 1: " + list_header.position().top + ", 2: " + list_header.outerHeight() + ", 3: " + $('body').scrollTop() )
	//console.log("new_top: " + new_top + ", new_left: " + new_left)

	//list_div.animate({width: '300px', 'font-size': '.9em'},1000,
	list_div.animate({top: new_top + 'px', left: new_left + 'px', width: '300px', 'font-size': '.9em'},600,
		function(){
			//$(this).css( {position: 'fixed', top: '4px'});
			//$('div.curated_list div#tab_curated_q1').append(list_div.find('ul'));
			
			$('div#curated_list_' + order_id).html('<p>' + question_text + '</p>').append(list_div.find('ul') );
			list_div.remove();
			set_inner_tab_content_height();
			// scroll to top of question
			$.scrollTo($('div.question_summary[id="' + question_id + '"] p.question'), 600)
		}
	);

  // if( !am_curator ) return;
	return false;
}


function close_question_worksheet(el){
	el = $(el);
	temp.el = el;
	
	if(el.attr('id')){ 
		// close comes from out of worksheet like curated list
		el = $('div.question_summary[id="' + el.attr('id') + '"] a.close_worksheet');
	}
	var worksheet = el.closest('div.worksheet');
	var question_id = worksheet.attr('id');
	worksheet.slideUp(800, function(){$(this).remove();});
	
	return false;
	
	// scroll to top of question
	$.scrollTo(el.closest('div.question_summary'),1000);
	
	
	
	var q = worksheet.closest('div.question_summary').children('p.question');
	var new_top = q.offset().top + q.height();
	var new_left = q.offset().left;

	var div_list = $('ul.talking_points[id="' + question_id + '"]').closest('div.ui-tabs-panel');
	
	div_list.find('p	').remove();
	var offset = div_list.offset();
	var width = div_list.width();
	
	
	var q_tabs = $('div.list_tabs ul.list_tabs');
	var tab = q_tabs.find('a.close_worksheet[id="' + question_id +'"]').closest('li');

	// get the next tab
		var next_tab = tab.prev('li');
		if(next_tab.size() == 0)next_tab = tab.next('li');
	// remove this tab
	tab.remove();

	if(next_tab.size() == 0){
		// if no more tabs, close this accordion panel and hide the accordion tab
		update_right_panel_context('proposal')
	}else{
		// get the index to the next_tab
		var index = 0;
		q_tabs.find('ul.list_tabs li').each(
			function(){
				if($(this).find('a:first').html() == next_tab.find('a:first').html()){
					return;
				}else{
					++index;
				}
			}
		);
		q_tabs.tabs('select',index);
	
	}
	// put up the verify message
	ul = div_list.find('ul');
	msg = $('<div class="msg"><p>Verifying current talking points</p></div>').appendTo(ul);
	msg.fadeTo(500,.7);
	
	// slide the list back to the summary
					
	div_list.remove();
	div_list.attr('id',question_id);
	div_list.addClass('selected_tp_list')
	$('body').append(div_list);
	div_list.css(offset);
	div_list.css({position: 'absolute', width: width});
	
	div_list.animate({top: new_top+'px', left: new_left + 'px', width: q.width() + 'px', 'font-size': '1.2em'},1000, 
		function(){
			$(this).find('p:first').remove();
		}
	);
}
