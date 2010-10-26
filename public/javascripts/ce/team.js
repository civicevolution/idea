// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/***********************************************
 Initialization that needs to happen ASAP
************************************************/

var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};

function getUrlParameters() {
	var map = {};
	var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
		map[key] = value;
	});
return map; 
}

var params = getUrlParameters();

var answerHTML
var curPageId;
var targets_array = {};
var target_ctr = 0;
var disable_coms_view = false;
var scroll_temp_disable_mouseenter = false;
var scroll_temp_disable_mouseenter_timer;
var temp_close_com_disable = false;
var temp = {};
var lastWinWidth = lastWinHeight = 0;
var ie7 = false;
	
/***********************************************
	End ASAP initialization
***********************************************/

/***********************************************
	Place all of the application initialization code here
***********************************************/
$(function(){
	console.log("execute jquery on ready")

	if($.browser.msie){
		//alert("MSIE version is " + $.browser.version)
		if($.browser.version.match(/7\./)){
			ie7 = true;
		}
	} 

	var master_debug = false;
	
	var load_ape_client = master_debug ? true : true;
	var convert_stars = master_debug ? true : true;
	var convert_time = master_debug ? false : true;
	var activate_debug = true;
	var do_load_templates = master_debug ? true : true;
	var allow_resize = master_debug ? true : true;
	var chat_container_name = 'page_chat_boxes'; // 'accordion';
	var update_css = true;
	var create_tabs = true;
	
	try{ 
		// this modifies the ajaxSend globally so it will include the auth token with every ajax request
		$(document).ajaxSend(function(event, request, settings) {
		  if (typeof(AUTH_TOKEN) == "undefined") return;
		  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
		  settings.data = settings.data || "";
		  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
		});
		// force resize
		function forceResize(){
			lastWinWidth = lastWinHeight = 0;
			resizeUI()
		}

		if(allow_resize){
			$(window).resize(function(){
		    	resizeUI()
			});
		}	
		if(allow_resize) setTimeout(forceResize,3000)
		if(allow_resize) setTimeout(forceResize,6000)
		if(allow_resize) setTimeout(forceResize,10000)
	
		// call the functions that are stored in activate.js
		
		if(do_load_templates)load_templates()
	
		// do the ux transformations
		if(create_tabs){
			//$('div.team_page div.tabs').tabs()
			//$('div.team_page div.tabs > ul > li').prepend( $('<div class="new_items"></div>'))
			$('ul.qa_tabs > li').prepend( $('<div class="new_items"></div>'))
		}
		
		NOTIFIER.init();
		
		activate_ux_appearance()
	
		activate_ux_pages()
	
		activate_ux_function_calls();
		activate_ux_functions_misc();
		activate_ux_functions_edit();
		activate_ux_functions_discussion();
	
		if (load_ape_client) load_ape(chat_container_name);

		if(activate_debug) activate_debug_functions_extras();
	
	  if(convert_stars){
	  	setTimeout(init_rating_stars, 1000);
	  	setTimeout(init_team_rating, 1000);
	  } 	
		if(convert_time) $("abbr.timeago").timeago();
	}catch(e){console.log("jquery ready function error: " + e.message)}	

});
/***********************************************
	End of application initialization code
***********************************************/
function set_page_tabs_height(page){
	//console.log("set_page_tabs_height v2");
	try{
		page = isNaN(page) ? page : $("div#proposal > div.Team > div.Page[id='i" + page + "']");
		var curWinHeight = $(window).height();
		var tab_top = $('div.tab_window:visible',page).offset().top
		//console.log("tab_top: " + tab_top + " curWinHeight: " + curWinHeight + " new tab_window height: " + (curWinHeight - tab_top - 70))
		$('div.tab_window',page).height(curWinHeight - tab_top - 35);
	}catch(e){console.log("set_page_tabs_height error: " + e)}
}

	function change_page(id){
		try{
			//console.log("change_page")
			id = isNaN(id) ? this.getAttribute('href').match(/\d+$/)[0] : id;
			//console.log("id: " + id)

			var new_page = $("div#proposal > div.Team > div.Page[id='i" + id + "']");
			adjust_page(new_page);
			$("div#nav_chat_col a[href='#page" + curPageId + "']").css('color','').closest('div').removeClass('cur_nav_link');
			$("div#proposal > div.Team > div.Page[id='i" + curPageId + "']").fadeOut(200, 
				function(){
					$("div#nav_chat_col a[href='#page" + id + "']").css('color','white').closest('div').addClass('cur_nav_link');
					// announce new page presence to the team, APE may not be active yet, so I may need to try again
					//console.log("in change_page fadeout function, I will announce myself")
					announce_page_presence(true); // this second one updates the sprite position so it will look correct against the active nav bar
					new_page.fadeIn(200,
						function(){
							set_page_tabs_height($(this));
						},'easeInExpo');
					adjust_page_coms(new_page);
					// only call ellipsis if a discussion tab is open/visible
					if( $('div.tab_window:visible',new_page).hasClass('discussion')) ellipsis(new_page);						
				},'easeOutExpo'
			);	
			var new_chat = $("div#page_chat_boxes > div.nav_chat[id='chat_" + id + "']");	
			$("div#page_chat_boxes > div.nav_chat[id='chat_" + curPageId + "']").fadeOut(200, 
				function(){
					new_chat.fadeIn(200,'easeInExpo');
				},'easeOutExpo'
			
			);
			curPageId = id;
			// announce new page presence to the team, APE may not be active yet, so I may need to try again
			//console.log("in change_page  function, I will announce myself")
			announce_page_presence();
		}catch(e){ console.log("change_page error: " + e)}
		return false;
	}
	function announce_page_presence(no_announce){
		try{
			//console.log("announce_page_presence-call my notifier")
			NOTIFIER.inform( { 
				type: 'presence',
				page_id: curPageId,
				ape_code: member.ape_code
			});
			if(!no_announce) member.client.pipe.send(curPageId + '-' + member.ape_code);
		}catch(e){
			//console.log("announce_page_presence error: " + e.message)
			setTimeout(announce_page_presence,5000);
		}
		
	}
	
	function adjust_page(page){
		//console.log("adjust_page for temp.page")
		// if the page needs to be updated, do it here
		// this should be automated with registered events. but for now it can be simple
		if($('div#team_tab',page).size() > 0) update_proposal();
	}
	
	function update_proposal(){
		$('div#current_proposal_view').html('')
		//var proposal = $('<div id="proposal_view"></div>');
		var proposal = $('<div id="proposal_view"></div>');
		//proposal.append( $('h3.team_title').clone(true) )
		$('div.Page').each(
		  function(){
		    $('div.Question_entry',this).each(
		      function(){
		        question = $(this).find('div.question:first').text();
		        question = $('<div class="question" id="prop_ques_' + $(this).closest('.Question').attr('id') + '"><p class="prop_q">' + question + '</p></div>');
		        proposal.append(question)
		        //console.log("question: " + question)
		        proposal.append( question )
		        var answers =  $('div.answer',this);
		        if(answers.size() > 0){

		          answers.each(
		            function(){
									// console.log("answer: " + $(this).html() )
									answer = $(this).clone()
									answer.attr('id','prop_' + answer.attr('id'));
		             //console.log("answer: " + answer.html())
		             //answer = $('<div class="answer">' + answer + '</div>');
		             question.append(answer)
		            }
		          )
		        }else{
		          //console.log("no answer yet")
		          question.append('<div class="answer no_answers"><p>No answers have been suggested yet</p></div>') 
		        }        

		      }
		    )
		  }
		)
		$('div#current_proposal_view').html('');
		$('div#current_proposal_view').append(proposal);
	}

	function setFormFocusFade(form){
	  form = $(form);
	  temp.form = form
	  //console.log("set focus opacity on this form v1 #: " +  form.closest('Page').find('form.add_comment_form').size());
	  form.closest('.tab_window').find('form.add_comment_form').not(form).fadeTo(1000,.2);
	  form.fadeTo(1000,1)
	}

	function adjust_page_coms(page){
		if(page.data('adjusted') ) return;		
		//console.log("adjust_page_coms")
		var line_height = 30;
		var fixed_height = 10;
		$('.plus_com',page).each(
			function(){
				//debugger
				var total_coms = $('.Comment_entry', this ).size()
				if( total_coms > 1 ){
					var height = $(this).height();
					var dpy_coms = Math.floor( (height - fixed_height) / line_height);	
					if(dpy_coms > 0){
						//$('.Comment_entry:gt(' + (num_coms - 1) + ')', this ).hide();
						$('.Comment_entry:gt(' + (dpy_coms - 1) + ')', this ).addClass('hidden');
						$('.Comment_entry:lt(' + (dpy_coms) + ')', this ).removeClass('hidden');
					}
				//	if(dpy_coms < total_coms){
						//var str = total_coms - dpy_coms > 1 ? total_coms - dpy_coms + ' more comments' : '1 more comment';
						//var str = "Open all comments";
						//$('.coms_inner',this).prepend('<div class="coms_count"><span>' + str + '</span></div>');
						
				//	}
				}else if (total_coms == 0){
					$('.coms_inner',this).prepend('<div class="coms_empty"></div>');
					$('.coms_inner',this).prepend('<div class="coms_count"><span>No comments yet</span></div>');
					
				}				
			}
		)
//		$('.coms form input',page).obscured('.coms').addClass('hidden')
		page.data('adjusted',true);
		
	}	
	
	function show_all_one_liners(el){
		el.css('z-index',2)
		$('.Comment_entry', el ).removeClass('hidden');
		ellipsis(el)
	}
	
	
	
	
function init_rating_stars(obj){
	//console.log("init_rating_stars, activate star_hover v2")
	try{
		if(!obj || !obj.size || obj.size() == 0 ) obj = $(':radio.star');
		//console.log("obj.size(): " + obj.size() );
		obj.rating({
			callback: function (value, link){
				//$(this.form).ajaxSubmit( {beforeSubmit: showUpdatingMsg, dataType: 'script'});
				$(this.form).ajaxSubmit({ 
					type: "POST",
					dataType: 'json',
					success: function(data,status){ 
						//console.log("rating submit success, call dispatchRating");
						temp.rating_submit = data
					  dispatchRating( data[0].params, true );
				  }				
				});
			}, 
			focus: function(value, link){
		    var tip = $('.star_hover',this.form);
		    tip[0].data = tip[0].data || tip.html();
		    tip.html((link.title || 'value: '+value) );
				$('.rating_results',this.form).hide();
		  },
		  blur: function(value, link){
		    var tip = $('.star_hover',this.form);
		    $('.star_hover',this.form).html(tip[0].data || '');
				$('.rating_results',this.form).show();
		  },
			required: true
		});	
	}catch(e){console.log("init_rating_stars error: " + e)}
	$('form.item_rater :submit').hide()
}

function init_team_rating(par){
	try{
		if(!par || !par.size || par.size() == 0 ) par = $('body');
		var bgr = $('<div class="bs_rating_red_bg"></div>');
		var bgg = $('<div class="bs_rating_grey_bg"></div>');
		var cnt = $('<div class="cnt"></div>');
		$('span.team_rating span.avg',par).each(
		  function(){
		    var avg = $(this);
		    var votes = avg.next('span').html();
		    votes = (votes + ' team vote') + (votes == 1 ? '' : 's');
		    //console.log("process bs rating_average: " + avg.html() + ", cnt: " + cnt.html());
		   //avg.parent().prepend( cnt.clone().html( votes )).prepend( bgr.clone().css('width', 80 * avg.html() / 5 )).prepend(bgg.clone())
		   avg.parent().before(bgg.clone()).before( bgr.clone().css('width', 85 * avg.html() / 5 ) ).before( cnt.clone().html( votes ) ).remove();
		  }
		)
	}catch(e){console.log("init_team_rating error: " + e)}
}

function showUpdatingMsg(){
	var jForm = arguments[1]
	//alert(jForm[0])
	$('.rating_results > span',jForm).html("Updating, please wait...")
}


	function showProposalView(old_id, new_id){
		//$('div#i' + old_id).hide(500)
		$('div#i' + old_id).hide("blind", { direction: "vertical" }, 600, function(){
			//console.log("showProposalView hide callback");
			$('div#i' + new_id).show("blind", { direction: "vertical" }, 600)
		})
		//$('div#i' + new_id).show(500)
		//$('div#i' + new_id).show("blind", { direction: "vertical" }, 400)
	}


	function edit_list_item(){
		//console.log("edit_list_items")
		var el = this;
		try{
			var id = $(el).attr('href').match(/(\w+)_list_item\/(\d+)/)
			var mode = id[1];
			id = id[2]
			//console.log("type: " + mode + " id: " + id)
			//debugger
			var text = mode == 'add' ? '' : strip_white_space($(this).closest('li').find('div.list_item').text())

			var html = jsonFn['list_item_input']({id: id, list_id: id, mode: mode, text: text });
			var	edit_div = $(html);
			// insert form
			if(mode == 'add'){
				//console.log(html)
				// append to list
				$(this).closest('div.list').find('ul').append(edit_div)
				$(this).closest('div.list').find('ul').scrollTo(edit_div,800)			
			}else{
				// replace current
				var entry = $(this).closest('li');
				var oldEntry = entry.clone(true);
				entry.replaceWith(edit_div);
				var t = $("div." + mode,oldEntry).html()
		    $.data(edit_div[0],"oldEntry",oldEntry); 
				$(edit_div).closest('div.list').find('ul').scrollTo(edit_div,800)
			}

			// Now I need submit and cancel				
			$('button',edit_div).click( function(e){
				//return false
				var form = $(this).closest('form');
				var btn = $(this)
				btn.attr('disabled',true)
				$(':input',form).removeClass('form_error_border');
				$('p.form_error_text',form).remove();
				form.ajaxSubmit({ 
				  type: "POST", 
				  url: "/team/create_list_item", 
				  success: function(html,status){ 
						//console.log("item success")
						if(mode == 'add'){
							var li = form.closest('li');
							li.hide(1000, function () { 
							  li.remove();
							});
						}
				  },
					error : function(xhr,errorString,exceptionObj){
						//console.log("Error, xhr: " + xhr.responseText)
						try{
							show_form_error(form, xhr.responseText)
							btn.removeAttr('disabled')
						}catch(e){
							btn.removeAttr('disabled')
							console.log("Comment submit error: " + e)
							$('<div><p>Sorry, we cannot process your comment at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
						}
					}
				});
				return false;
			});

			$('a',edit_div).click( function(e){
				//console.log("cancel edit_ite")
				var form = $(this).closest('form');
				var par = form.closest('li');	
				// if this is edit, the par has an oldPar data value, restore it, otherwise close the 
		   	var oldEntry = $.data(par[0], "oldEntry");
				if(inputs_are_empty_or_confirm_close(form)){
					if(oldEntry){
						$.data(par[0], "oldEntry",null);
						par.replaceWith(oldEntry);					
					}else{
						par.remove();
					}
				}
			});		



		}catch(e){
			console.log(e)
		}
		return false;
	}

	function view_history(){
		//console.log("view_history")
		try{
			var a = $(this);
			var id = Number(a.attr('href').match(/\d+$/))
			var url = '/team' + a.attr('href').match(/\/[^\/]*item_history/)

			//console.log('view_history url: ' + url + ' id: ' + id)

			$.get(url, 'id=' + id, function(html) {
				//console.log("html: " + html)
				var dlg = $(html).dialog( {title : 'Answer history', width: '500px'} );
				dlg.css('border','1px solid black');
			}, 'html');

		}catch(err){
			console.log("view_history error: " + err)
		}
		return false;
	}

	function view_chat_transcript(){
		var a = $(this);
		try{
			var id = Number(a.attr('href').match(/\d+$/))
			//console.log("view_chat_transcript id: " + id)

			$.get('/team/page_chat_transcript', 'id=' + id, function(html) {
				var dlg = $(html).dialog( {title : 'Chat transcript', width: '500px'} )
				dlg.css('border','1px solid black');
			}, 'html');

		}catch(err){
			console.log("view_chat_transcript error: " + err)
		}
		return false;
	}



	function delete_item(e){
		var el = this; // for $().live('type',func) or el = e.currentTarget for $().click(func)
		try{
			var id = $(el).attr('href').match(/(delete_\w+)\/(\d+)/)
			var type = id[1]
			id = id[2]
			//console.log('delete ' + type + ' id: ' + id)
			if(confirm('Are you sure you want to delete this item?\n\nDelete cannot be undone!\n\nClick "Yes" to delete now.')){

				$.post('/team/' + type, 'id=' + id, function(data) {
					// Show error message, if any
					if (data.error) {
						alert(data.error);
					}
					//console.log("delete the " + type + " div.item or div.pieces\n" + "delete_mode: " + data.delete_mode)
				}, 'json');
			}
		}catch(err){
			console.log("error: " + err)
		}
		return false;
	}


	//
	// create closure
	//
	(function($) {
	  //
	  // plugin definition
	  //
	  $.fn.obscured = function(parent_selector) {

			return this.filter(
				function(index){
					var	element = $(this),
						elementOffset,
						parent = element.closest(parent_selector),
						parentOffset;

					if (element.is(":visible")){
						elementOffset = element.offset();
						parentOffset = parent.offset();

						return (parentOffset.top  > elementOffset.top  || // top obscured
								parentOffset.left > elementOffset.left || // left obscured
								parentOffset.top  + parent.height() < elementOffset.top  + element.height() || // bottom obscured
								parentOffset.left + parent.width()  < elementOffset.left + element.width());   // right obscured
					}
					return false;				
				}
			)
	  };
	//
	// end of closure
	//
	})(jQuery);
	


	$(function(){
		$('ul.qa_tabs li').hover(tab_over, tab_out).live('click',tab_click)
		$('div.tabs.question_tabs li.discuss').click()
		$('div.team_info_tabs li.propose').click()
	});

function tab_over(){
	//console.log("tab_over");
	var tab = $(this);
	if( !tab.hasClass('active') ){
		tab.addClass('hover');
		temp.tab = tab;
		var tab_class = tab.attr('class').replace(' hover','');
		temp.tab_class = tab_class;
		var par = tab.closest('div.tabs');
		par.children('div.tab_panel:visible').children('div.instr').hide().after(
			par.children('div.' + tab_class + ' > div.instr > p.instr:first').clone(true).addClass('rollover')
		)
	} 
	
}
function tab_out(){
	//console.log("tab_out");
	var tab = $(this)
	tab.removeClass('hover');		
	var par = tab.closest('div.tabs')
	par.children('div.tab_panel:visible').children('div.instr:first').show().siblings('p.rollover').remove()
		
}

function tab_click(){
	//console.log("tab_click");
	var tab = $(this);
	// restore the current active tab
	tab.closest('div.tabs').children('div.tab_panel:visible').children('div.instr:first').show().siblings('p.rollover').remove()
	tab.siblings('li').removeClass('active').end().removeClass('hover');
	var tab_class = tab.attr('class');		
	tab.addClass('active');
	//console.log("activate tab: " + tab_class)
	tab_panel = tab.closest('div.tabs').find('div.' + tab_class);
	tab_panel.show()
	tab_panel.siblings('div.tab_panel').hide()
	tab.closest('div.tabs').trigger('tabsshow', [{tab: tab, panel: tab_panel}])
}
$(function(){
	$('ul.qa_tabs').each( function(){ $(this).find('li:first').click() } )
});

$('a.how').die('click').live('click',
	function(){
		var el = link = $(this)
		// find the first div.how below this
		//console.log("open how")
		while( el && ( el = el.parent() ) ){
			var div = el.find('div.how:first');
			//console.log("div.size(): " + div.size())
			if(div.size() > 0){
				if(div.is(':visible')){
					//console.log("hide")
					div.hide()
					var title = link.attr('title');
					link.html(title || 'How')
				}else{
					//console.log("show")
					div.show();
					var title = link.html()
					link.html('Close').attr('title',title)
				}
				return false;
			}
		}
		return false;
	}
)
