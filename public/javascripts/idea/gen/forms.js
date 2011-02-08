//console.log("Loading temp.js");
var temp = temp || {};

$(function(){


	$('a.open_all').die('click').live('click',
		function(){
			//console.log("open_all (form.js)")
			try{
				var a = $(this);
				//var par = a.closest('.ui-tabs-panel');
				//var par = a.closest('.discussion');
				var par = a.closest('div.tab_panel').find('.discussion');
				if(par.size() == 0){
					par = a.closest('div.discussion')
				}
				if( a.html().match(/Open/)){
					$('div.Comment_entry',par).addClass('full_comment_display').removeClass('one_line_comment');
					a.html('Close all comments');
				}else{
					$('div.Comment_entry',par).addClass('one_line_comment').removeClass('full_comment_display');
					a.html('Open all comments');
					ellipsis(par)
				}			
			}catch(e){console.log("open_all error: " + e)}
			return false;
		}
	);


	$('div#proposal, div.left_col').delegate( 'div.one_liner, div.Comment_entry img', 'click', 
		function(){
			console.log("open one liner")
			var $this = $(this);
			//$this.parents('div.Comment').addClass('full_comment_display').removeClass('one_line_comment');
			//$this.closest('div.Comment').addClass('full_comment_display').removeClass('one_line_comment');
			$this.closest('div.Comment_entry').addClass('full_comment_display').removeClass('one_line_comment');
		}
	)

	$('div#proposal').delegate( 'div.close_1com', 'click', 
		function(){
			var $this = $(this);
			$this.css('display','block');
			$this.closest('div.comment').slideUp(500, function(){
				$(this).closest('div.Comment_entry').addClass('one_line_comment').removeClass('full_comment_display');
				$(this).slideDown(200,
					function(){
						ellipsis(this);
						$this.css('display','');
					}
				)
			},'easeOutQuart');

		}
	);

	$('a.edit_com').die('click').live('click',
		function(){
			try{
				//console.log("edit_com v2")
				var a = $(this);
				temp.edit_com_a = a;
				var com_entry = a.closest('div.Comment_entry');
				var id = Number(a.attr('href').match(/\d+$/));
				var mode = 'edit';
				var res_type = 'simple';
				var anon = 'false';
				var form = $( jsonFn.add_comment_form({id : id, mode : mode, anon: anon, resource_type: res_type}) );
				temp.com_form = form
				$('label:first',form).html("Please edit this comment");
				//$('div.control_line',form).css('margin-bottom','40px');
				$(form).css('margin-bottom','60px');
				$('a.clear',form).removeClass('clear').addClass('cancel').html('Cancel');
				form.find('div.add_comment span.char_ctr:last').html(com_criteria + ' characters left');
				form.find('div.add_link span.char_ctr:last').html(res_criteria + ' characters left');
				form.find('div.attach_file span.char_ctr:last').html(res_criteria + ' characters left');

				var com_text = com_entry.find('div.comment_text').clone();
				com_text.find('.one_liner').remove();
				// can I ignore the <br> ?
		 		var com_text = com_text.html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'')
				$('textarea.comment',form).html(com_text);
				if( (res = $('div.link:visible',com_entry)).size() > 0 ){
					$('div.add_link input.title',form).val(
						$('h3.resource_title',res).html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'')
					);
					$('div.add_link textarea.description',form).html(
						$('div.resource_description',res).html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'')
					);
					$('div.add_link input.url',form).val(
						$('a.resource_url',res).html()
					);
					res_type = 'link';
				}else if( (res = $('div.upload:visible',com_entry)).size() > 0 ){
					$('div.attach_file input.title',form).val(
						$('h3.resource_title',res).html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'')
					);
					$('div.attach_file textarea.description',form).html(
						$('div.resource_description',res).html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'')
					);
					$('div.attach_file input#resource_resource',form).after('<span class="file_name">' +
						$('a.resource_upload',res).html()
						+'</span>');
					res_type = 'upload'
				}
				form.hide();
				com_entry.hide(500, 
					function(){
						//console.log("now add the idea form idea.size: " + idea.size())
						com_entry.before( form );
						form.show(500)
					}
				);
				//console.log("activate the form")
				activate_comment_form(form,com_entry);
				//console.log("click the image for res_type: " + res_type)
				temp.com_form = form
				if(res_type == 'link'){
					//$('img.show_add_link', form).click();
					setTimeout(function(){$('img.show_add_link', this).click();}.bind(form),2000)
				}else if(res_type == 'upload'){
					//$('img.show_attach_file', form).click();
					setTimeout(function(){$('img.show_attach_file', this).click();}.bind(form),2000)
				}
			}catch(e){console.log("edit_comment error: " + e)}
			return false;
		}
	);

}) // end of jquery on load




function request_ape_send(){
 //console.log("request_ape_send")
	var id = $(this).parent().find('#ape_item_id').val()
 //console.log("request_ape_send for item: " + id)
	$.get('http://cgg.1civicevolution.org/idea/send_ape/',{id: id}, 
		function(data,status){
			//console.log("request_ape_send data: " + data);
			//console.log("request_ape_send status: " + status);
		 //console.log("saved ape data to temp.send_ape_data")
			temp.send_ape_data = data
			// Now dispatch this data to insert it as a new item
		 //console.log("call dispatchItem with submit_reponse = true for raw " + data[0].params.raw)
			switch(data[0].params.raw){
				case 'com_json':
					dispatchComment(data[0].params.data,true)
					break;
				case 'ans_json':
					dispatchAnswer(data[0].params.data,true)
					break;
				case 'ques_json':
				 //console.log("ques_json dispatch not defined yet")
				case 'bs_idea':
					dispatchBsIdeas(data[0].params,true)
					break;
				default:
				 //console.log("dispatch not defined for " + data[0].params.raw)
			}

		},
		'json')
	return false;
	
}

$('div.answers a.add_answer').die('click').live('click', show_answer_form);

function show_answer_form(){
	temp.answer_link = this
	try{
 //console.log("show_answer_form");

	$this = $(this);
	var par = $this.closest('.item');
	var par_id = Number(par.attr('id').match(/\d+/));
	var mode = 'add';
	var id = par_id;
	//console.log("par_id: " + par_id)
	var form = $( jsonFn.add_answer_form({par_id : par_id, mode : mode, id : id }) );
	$('a.clear',form).removeClass('clear').addClass('cancel').html('Cancel');
	$this.closest('div.answers').append( form );
	activate_answer_form(form);
}catch(e){
	console.log("error: " + e)
	
}
	return false;
}




$('div.comment a.reply').die('click').live('click', show_com_form);

function show_com_form(){
	try{
	console.log("show_com_form v1");
	$this = $(this);
	var par = $this.closest('.item');
	// par should only have one open form
	if(par.find('form.add_comment_form').size()>0){
		par.find('form.add_comment_form textarea').focus();
		return false;
	} 
	var par_id = Number(par.attr('id').match(/\d+/));
	var mode = 'add';
	var id = par_id;
	var resource_type = 'simple';
	//console.log("par_id: " + par_id)
	debugger
	var form = $( jsonFn.add_comment_form({par_id : par_id, mode : mode, id : id, resource_type : resource_type }) );
	form.find('div.add_comment span.char_ctr:last').html(com_criteria + ' characters left');
	form.find('div.add_link span.char_ctr:last').html(res_criteria + ' characters left');
	form.find('div.attach_file span.char_ctr:last').html(res_criteria + ' characters left');
	
	// inserted forms have cancel link instead of clear link
	$('a.clear',form).removeClass('clear').addClass('cancel').html('Cancel');
	// where do I put the form?
	// reply is either a sibling or a child
	// sibling if target doesn't have any siblings
	// child if target already has a sibling
	// Does the target have a sibling?
	// go up to parent item
	// are there any immediate children that are .sibling

	var has_sibling = par.children('.sibling').size() > 0
	if(has_sibling){
		//console.log("has sibling")
		// insert form after the last child of target
		var last_child = par.children('.top_sibling:last');
		if (last_child.size() > 0){
			//console.log("insert form after last child")
			// indent this since it is a child
			last_child.after(form);
			form.css('margin-left','20px')
		}else{
			//console.log("attach form after self, no children")
			//$this.after( form )
		 //console.log("****** Has sibling, but not top_sibling child,  I'm not using this: $this.after( form ) in show_com_form");
			$this.closest('.Comment_entry').after(form)
			form.css('margin-left','20px')
		}
		$('div.add_comment label',form).html('Please reply to this comment');
	}else{
		//console.log("does't have sibling")
		// insert form as last child of parent
		//par.parent().append( form );
		par.append( form );
		$('div.add_comment label',form).html('Please continue this conversation');
	}
	activate_comment_form(form);
	form.find('textarea')[0].focus()
}catch(e){
	console.log("error: " + e)
	
}
	return false;
}

function activate_answer_form(form,orig_ans){
 //console.log("activate_answer_form");
	temp.answer_form = form

	$('div.control_line a.cancel',form).click(
		function(){
			try{
				//console.log("Cancel the answer form");
				var form = $(this).closest('form');
				form.remove();
				// restore a form that may have been faded
				//form.closest('.tab_window').find('form.add_answer_form:last').fadeTo(1000,1)
				if(orig_ans)orig_ans.show(1000)
			}catch(e){
				console.log("answer cancel error: "+ e)
			}
			return false;
		}
	);
	
	$('div.control_line a.clear',form).click(
		function(){
			//console.log("Clear the comment form");
			$(this).closest('form').find('textarea').val('');
			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			return false;
		}
	);
	

	$('div.control_line button',form).click(
		function(){
		 console.log("Submit the answer form");

			var form = $(this).closest('form');
			var btn = $(this);
			btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')

			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/idea/create_answer", 
				dataType: 'json',
			  success: function(data,status){ 
				 	console.log("answer submit success, call dispatchAnswers");
					temp.answer_success_data = data
					dispatchAnswer(data[0].params.data,true)
					var msg = $('<p class="confirmation">Your answer has been saved successfully</p>')
					form.prepend(msg)
					msg.effect('highlight',{},3000, function(){$(this).remove()});	
					// restore a form that may have been faded
					//form.closest('.tab_window').find('form.add_answer_form:last').fadeTo(1000,1)
					// only hide form if no more answers can be given, otherwise clear form
					// if form has a cancel link, remove it
					// otherwise clear it, unless no more answers allowed
					if( $('a.cancel',form).size() > 0 ){
						form.hide(1000,function(){$(this).remove()})
					}else if (data[0].params.data.remaining_ans > 0){
						$('textarea',form).val('');
					}else{
						form.hide(1000,function(){$(this).remove()})
					}
					btn.removeAttr('disabled').next('img').remove();
			  },
				error : function(xhr,errorString,exceptionObj){
					//console.log("Error on answer submit, xhr: " + xhr.responseText)
					try{
						show_form_error(form, xhr.responseText)
						btn.removeAttr('disabled').next('img').remove();
					}catch(e){
						btn.removeAttr('disabled').next('img').remove();
						console.log("Answer idea submit browser error in server error handling: " + e)
						$('<div><p>Sorry, we cannot process your answer idea at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					}
				}
			});
			return false;
		}
	);
	activate_text_counters_grow( $('textarea,input:text',form) )
}


function activate_comment_form(form,orig_com){
	
	var type = 'comment';
	form.find('div.add_comment span.char_ctr:last').html(com_criteria + ' characters left');
	
	$('div.control_line img',form).click(
		function(){
		 //console.log("adjust comment type, " + this.className)
			var form = $(this).closest('form');
			switch(this.className){
				case 'show_add_link':
					$('div.add_comment button, div.add_comment a',form).hide();				
					$('div.add_comment img',form).hide();
					$('div.add_link',form).show();
					form[0].resource_type.value = 'link';
					break;
				case 'show_attach_file':
					$('div.add_comment button, div.add_comment a',form).hide();				
					$('div.add_comment img',form).hide();
					$('div.attach_file',form).show();
					form[0].resource_type.value = 'upload';
					break;
				case 'close_add_link':
					$('div.attach_file',form).find('input.title').val(
						$('div.add_link',form).find('input.title').val() );
					$('div.attach_file',form).find('textarea.description').val(
						$('div.add_link',form).find('textarea.description').val() );
					$('div.add_comment button, div.add_comment a',form).show();				
					$('div.add_comment img',form).show();
					$('div.add_link',form).hide()
					form[0].resource_type.value = 'simple';
					break;
				case 'change_to_attach_file':
					$('div.attach_file',form).find('input.title').val(
						$('div.add_link',form).find('input.title').val() );
					$('div.attach_file',form).find('textarea.description').val(
						$('div.add_link',form).find('textarea.description').val() );
					$('div.add_link',form).hide();
					$('div.attach_file',form).show();
					form[0].resource_type.value = 'upload';
					break;
				case 'change_to_add_link':
					$('div.add_link',form).find('input.title').val(
						$('div.attach_file',form).find('input.title').val() );
					$('div.add_link',form).find('textarea.description').val(
						$('div.attach_file',form).find('textarea.description').val() );
					$('div.add_link',form).show();
					$('div.attach_file',form).hide();
					form[0].resource_type.value = 'link';					
					break;
				case 'close_attach_file':			
					$('div.add_link',form).find('input.title').val(
						$('div.attach_file',form).find('input.title').val() );
					$('div.add_link',form).find('textarea.description').val(
						$('div.attach_file',form).find('textarea.description').val() );
					$('div.add_comment button, div.add_comment a',form).show();				
					$('div.add_comment img',form).show();
					$('div.attach_file',form).hide();
					form[0].resource_type.value = 'simple';
					break;
			}
		}
	)
	
	$('div.control_line button',form).click(
		function(){
		 //console.log("Submit the comment form");

				var form = $(this).closest('form');
				var btn = $(this);
				btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
				
				$(':input',form).removeClass('form_error_border');
				$('p.form_error_text',form).remove();
				
				var com_type = form[0]['resource_type'].value;
				var mode = form[0]['mode'].value;				
			 //console.log("com_type: " + com_type);
				switch(com_type){
					case 'link':
						$('div.attach_file',form).find('input.title').val(
							$('div.add_link',form).find('input.title').val() );
						$('div.attach_file',form).find('textarea.description').val(
							$('div.add_link',form).find('textarea.description').val() );				
						form.find('div.attach_file').find('input[type="text"], textarea, input[type="file"]').attr('disabled','disabled');																					
						break;
					case 'upload':
						$('div.add_link',form).find('input.title').val(
							$('div.attach_file',form).find('input.title').val() );
						$('div.add_link',form).find('textarea.description').val(
							$('div.attach_file',form).find('textarea.description').val() );
						form.find('div.add_link').find('input[type="text"], textarea, input[type="file"]').attr('disabled','disabled');
						break;
					case 'simple':
						form.find('div.add_link').find('input[type="text"], textarea').attr('disabled','disabled');
						form.find('div.attach_file').find('input[type="text"], textarea, input[type="file"]').attr('disabled','disabled');
						break;						
				}
				
				form.ajaxSubmit({ 					
				  type: "POST", 
				  url: "/idea/create_" + type, 
					//dataType: 'json',
					success: function(data,status){ 
					 //console.log("comment submit success, see temp.com_submit")
						temp.com_submit = data;
						try{
							//console.log("do json eval")
							data = eval(data)
							//console.log("json eval ok")
						}catch(e){
							try{
								console.log("try to extract html and convert - if this works, data is from iframe mediated post")
								data = $(data).html()
								data = eval(data)
								console.log("html eval ok, call show_error")
								show_form_error(form, data);
								btn.removeAttr('disabled').next('img').remove();
								return;								
							}catch(e){
								temp.com_submit_error = { data: temp.com_submit, status: status}
								console.log("Comment submit success has an error, see temp.com_submit_error: " + e)
								btn.removeAttr('disabled').next('img').remove();
								return;
							}
						}
						temp.com_submit_data = data
						
					 //console.log("item success, activate_comment_form, form.ajaxSubmit, check temp.data")
						temp.comment_success_data = data				
						
						dispatchComment(data[0].params.data,true)
						
					  var msg = $('<p class="confirmation">Your comment has been saved successfully</p>')
						form.before(msg);
						// reset the form
						form.find('input[type="text"], textarea, input[type="file"]').removeAttr('disabled').val('')
						$('div.add_comment button, div.add_comment a, div.add_comment img',form).show();				
						$('div.add_link, div.attach_file',form).hide()
						form[0].resource_type.value = 'simple';

						msg.effect('highlight',{},3000, function(){$(this).remove()});	
						if(form[0]['comment[target_id]'].value){
							form[0]['comment[text]'].value = '';
							$('button',form)[0].blur()
						}else{
							// restore a form that may have been faded
							form.closest('.tab_window').find('form.add_comment_form:last').fadeTo(1000,1)
							form.hide(1000,function(){$(this).remove()});
						}
						btn.removeAttr('disabled').next('img').remove();
				  },
					error : function(xhr,errorString,exceptionObj){
						//console.log("Error, xhr: " + xhr.responseText)
						try{
							show_form_error(form, xhr.responseText);
							btn.removeAttr('disabled').next('img').remove();
						}catch(e){
							btn.removeAttr('disabled').next('img').remove();
							console.log("Comment submit error: " + e)
							$('<div><p>Sorry, we cannot process your comment at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
						}
					}
				});
				
			return false;
		}
	);
	
	$('div.control_line a.cancel',form).click(
		function(){
			//console.log("Cancel the comment form v2");
			var form = $(this).closest('form');
			form.closest('.tab_window').find('form.add_comment_form:last').fadeTo(1000,1)
			form.remove();
			if(orig_com)orig_com.show(1000)
			return false;
		}
	);

	$('div.control_line a.cancel_embedded',form).click(
		function(){
		 //console.log("Cancel the embedded comment form v2");
			$(this).closest('.tab_window').find('form.add_comment_form:last').fadeTo(1000,1)
			$(this).closest('tr').prev('tr').find('a.com_on_tgt').click();
			return false;
		}
	);
	
	$('div.control_line a.clear',form).click(
		function(){
		 //console.log("Clear the comment form");
			var form = $(this).closest('form');
			form.find('input[type="text"], textarea, input[type="file"]').removeAttr('disabled').val('')
			$('div.add_comment button, div.add_comment a, div.add_comment img',form).show();				
			$('div.add_link, div.attach_file',form).hide()
			form[0].resource_type.value = 'simple';
			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			if( $('div.add_link:visible').size() > 0){
				setTimeout(function(){$('img.close_add_link', this).click();}.bind(form),1000)
				//$('img.close_add_link',form),click();				
			}else if ( $('div.attache_file:visible').size() > 0 ){
				setTimeout(function(){$('img.close_attach_file', this).click();}.bind(form),1000)
				//$('img.close_attach_file',form),click();
			}
			return false;
		}
	);
	
	activate_text_counters_grow( $('textarea,input:text',form) )
}

function activate_report_form(form){
	console.log("activate_report_form")
	//activate_text_counters_grow( $('textarea',form) )

	$('a.cancel',form).click(
		function(){
			try{
				console.log("Cancel the report form");
				$(this).closest('div.ui-dialog').dialog('destroy').remove();
			}catch(e){
				console.log("activate_report_form cancel error: "+ e)
			}
			return false;
		}
	);

	$(':submit', form).click(
		function(){
		 console.log("Submit the report form");

			var form = $(this).closest('form');
			var btn = $(this);
			btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')

			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/idea/post_content_report", 
			  success: function(data,status){ 
					console.log("post_content_report success");
					form.closest('div.ui-dialog').dialog('destroy').remove()
					var dialog = $('<div><p>' + data + '</p></div>').dialog( {title : 'Thank you', modal : true, width: 500 }); 
			  },
				error : function(xhr,errorString,exceptionObj){
					console.log("post_content_report error");
					console.log("Error, xhr: " + xhr.responseText)
					try{
						show_form_error(form, xhr.responseText);
						btn.removeAttr('disabled').next('img').remove();
					}catch(e){
						btn.removeAttr('disabled').next('img').remove();
						console.log("report_content submit error: " + e)
						$('<div><p>Sorry, we cannot process your report at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					}
				}
			});
			return false;
		}
	);
}


function activate_endorsement_form(form,orig_idea){
	console.log("activate_endorsement_form")
	form = $('div#endorsements form');
	activate_text_counters_grow( $('textarea',form) )

	$('div.control_line a.cancel',form).click(
		function(){
			try{
				//console.log("Cancel the idea form");
				var form = $(this).closest('form');
				form.remove();
				// restore a form that may have been faded
				//form.closest('.tab_window').find('form.add_answer_form:last').fadeTo(1000,1)
				if(orig_idea)orig_idea.show(1000)
			}catch(e){
				console.log("answer cancel error: "+ e)
			}
			return false;
		}
	);
	
	$('div.control_line a.clear',form).click(
		function(){
		 //console.log("Clear the idea form");
			$(this).closest('form').find('textarea').val('');
			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			return false;
		}
	);

	$('button', form).unbind('click').click(
		function(){
		 console.log("Submit the endorse_proposal form");
			var form = $(this).closest('form');
			var btn = $(this);
			btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')

			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/idea/endorse_proposal", 
				dataType: 'json',
			  success: function(data,status){ 
				 //console.log("endorse_proposal submit success, call dispatchEndorsement");
				  dispatchEndorsement( data[0].params.data, true );
					var msg = $('<p class="confirmation">Your endorsment has been saved successfully & inserted above</p>')
					form.prepend(msg)
					msg.effect('highlight',{},3000, function(){$(this).remove()});					
					$('textarea',form).val('');
					btn.removeAttr('disabled').next('img').remove();
			  },
				error : function(xhr,errorString,exceptionObj){
					//console.log("Error, xhr: " + xhr.responseText)
					try{
						show_form_error(form, xhr.responseText);
						btn.removeAttr('disabled').next('img').remove();
					}catch(e){
						btn.removeAttr('disabled').next('img').remove();
						console.log("Endorsement submit error: " + e)
						$('<div><p>Sorry, we cannot process your endorsement at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					}
				}
			});
			return false;
		}
	);
}

function activate_submit_form(form){
	console.log("activate_submit_form")
	//activate_text_counters_grow( $('textarea',form) )

	$('a.cancel',form).click(
		function(){
			try{
				console.log("Cancel the report form");
				$(this).closest('div.ui-dialog').dialog('destroy').remove();
			}catch(e){
				console.log("activate_report_form cancel error: "+ e)
			}
			return false;
		}
	);

	$(':submit', form).click(
		function(){
		 console.log("Submit the proposal");

			var form = $(this).closest('form');
			var btn = $(this);
			btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')

			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			 
			var team_id = form.find('input[name="proposal_submit[team_id]"]').val();
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/idea/submit_proposal/" + team_id , 
			  success: function(data,status){ 
					console.log("submit_proposal success");
					form.closest('div.ui-dialog').dialog('destroy').remove()
					var dialog = $('<div><p>' + data + '</p></div>').dialog( {title : 'Thank you', modal : true, width: 500 }); 
			  },
				error : function(xhr,errorString,exceptionObj){
					console.log("post_submit error");
					console.log("Error, xhr: " + xhr.responseText)
					try{
						show_form_error(form, xhr.responseText);
						btn.removeAttr('disabled').next('img').remove();
					}catch(e){
						btn.removeAttr('disabled').next('img').remove();
						console.log("report_content submit error: " + e)
						$('<div><p>Sorry, we cannot process your proposal submission at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					}
				}
			});
			return false;
		}
	);
}


function announceNoChat(){
	console.log("announceNoChat")
	$('td.init_chat').each( function(){this.innerHTML = 'Chat and live page updates are currently unavailable.<br/><br/>Please try to refresh your browser.<br/><br/>We apologise for the inconvenience'});
}
//var ape_watchdog = setTimeout(announceNoChat,60000);

function activateChatWindows(chat_container){
}	

function chat_submit(form){
	var msg = form[0].text.value;
	msg = msg.replace(/^\s+/,'').replace(/\s+$/,'');
	if(msg.length == 0) return false;
	if(msg.match(/::js_cmd::/)){
		process_commands_through_chat(msg);
		form[0].text.value = ''
		return false;
	}
 //console.log('v4: submit form chat form msg: ' + msg + " VIA chat_submit func")
	
	var btn = $('input.chat_submit',form);
	btn.attr('disabled',true);
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
	if(msg!=''){
		form.ajaxSubmit({ 					
		  type: "POST", 
		  url: "/idea/page_chat_message", 
			data: {text : msg, page_id : form[0].page_id.value },
			//dataType: 'json',
		  success: function(data,status){ 
				//console.log("chat submit success, call dispatchPageChatMessage");
				data = eval(data)
				temp.chat_submit_response = data
			  dispatchPageChatMessage( data[0].params, true );
				form[0].text.value = ''
				btn.removeAttr('disabled')
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error, xhr: " + xhr.responseText)
				try{
					show_form_error(form, xhr.responseText);
					btn.removeAttr('disabled')
				}catch(e){
					btn.removeAttr('disabled')
					console.log("Chat submit error: " + e)
					$('<div><p>Sorry, we cannot process your chat message at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
				}
			}
		});
		return false;			
	}
}	

function process_commands_through_chat(cmd){
	console.log("1. process_commands_through_chat cmd: " + cmd)
	try{
		cmd = cmd.match(/::js_cmd::(.*)/)[1]
		console.log("2. process_commands_through_chat cmd: " + cmd)
		eval(cmd)
	}catch(e){console.log("error in process_commands_through_chat e: " + e.message)}
}

function activate_text_counters_grow(els){
	var focused = false;
	els.each(
		function(){
			//console.log("activate text, get span.char_ctr & count");
			var el = $(this);

			var span = el.next().find('span.char_ctr');
			while(span.size() == 0 && el){
				el = el.parent();
				span = el.find('span.char_ctr');
			}
			if(span.size() == 1){
				el = $(this);
				var cnt = Number(span.html().match(/\d+/));
				el.show_char_limit(cnt, {
			    error_element: span,
					status_element: span
			  });
				if(el[0].nodeName == 'TEXTAREA'){
					el.autogrow({
						lineHeight : 16,
						minHeight  : 32,
						maxHeight : 500
					});			
				}
				if(!focused){
					//el.focus();
					focused = true;
				}
			
			}else{
				console.log("Initialize char_ctr failed, no span.char_ctr found")
			}
		}
	)
}

function show_form_error(form, response) {
	// apply the error messages in the form_errors object
	// iterate through each input and look for a match against the error object
	//var js = $(response).find('script').text();
	//console.log("js: " + js)
	//console.log("show_form_error v1")
	var form_errors = eval(response)[0];
	//console.log("form_errors.length: " + form_errors.length)
	// form_errors[name] must have come from evaluating the script text
	for(var i=0,error;(error = form_errors[i]);i++){
		//console.log("error field: " + error[0] + ", message: " + error[1])
		if(error[0] == 'timeout'){
			//console.log("there is a base error: " + error[1])
			$('<div><p>Sorry, your session has expired, you must sign in again to continue.</p></div>').dialog( {title : 'Warning', modal : true } )
		}else	if(error[0] == 'reload_recaptcha'){			
			//Recaptcha.reload();
		}else	if(error[0] == 'base'){
			if(error[1].match(/Captcha/)){
				Recaptcha.reload();
			}else{
				//console.log("there is a base error: " + error[1])
				var inp = $('input:visible:last', form)
				if(inp.size() == 0 ) inp = $('textarea:visible:last', form)
				inp.addClass('form_error_border')
				inp.before('<p class="form_error_text">' + error[1] + '</p>')
			}
		}else{
			//console.log("attach error for fields: " + error[0])
			var inp = $(":input[name='" + error[0] + "']:visible:first",form);
			if(inp.size() == 0) inp = $(":input[name*='[" + error[0] + "']:visible:first",form);
			if(inp.size() == 0) inp = $("." + error[0] + ":visible:first",form);
			inp.addClass('form_error_border')
			inp.before('<p class="form_error_text">' + ( inp.attr('alias') || error[0] ) + ' ' + error[1] + '</p>')
		}
	}
}

function strip_white_space(t){
	return t.replace(/\n/g,'').replace(/<p>/gi,'').replace(/<br[^>]*>/gi,'\n').replace(/<\/p>/gi,'\n\n').replace(/[ ]+/g,' ').replace(/^[ ]+/gm,'').replace(/[ ]+$/gm,'').replace(/\s+$/,'');
}

function inputs_are_empty_or_confirm_close(container, msg){
	//console.log("inputs_are_empty_or_confirm_close container: " + container)
	if(!msg) msg = "Do you want to discard your changes?";
	var is_empty = true;
	var inputs = $(':input',container);
	if(inputs.length == 0 )  inputs = $(container)
	inputs.each(
		function(i){
			//console.log("item " + i + " is " + this.type + " value: " + this.value)
			if( (this.type == 'text' || this.type == 'textarea' || this.type == 'file') && this.value != ''){
				is_empty = false;
				return false;							
			}
		}
	)
	if( is_empty || confirm(msg)) {
		return true;
	}
	return false;
}

function load_templates(templates){
	console.log("load ce_templates.js")
	$.getScript('/javascripts/idea/gen/templates.js',
		function(data){
			console.log("load templates")		
			$.get("/idea/get_templates",
				function(data){ 
					create_templates(data)
				}
			)
		}
	);
	return false;
}

function thumbs_up() {
	try{
		//console.log("thumbs_up")
		var form = $(this.form);
		// Immediately disable the submit buttons to prevent multiple clicks
		var btns = $(':submit', form).attr('disabled', 'disabled').blur();

		// Disable the form and show a spinner
		form.addClass('closed');

		// Collect the POST data to send to the server
		var postdata = {
			thumbsup_id : $("input[name='thumbsup_id']", form).val(),
			thumbsup_rating: $(this).val() };
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/idea/com_rate", 
				data: postdata,
				dataType: 'json',
			  success: function(data,status){ 
					//console.log("com_rate submit success, call dispatchComRating"); with submit = true
					temp.com_rate_success_data = data
				  dispatchComRating( data[0].params, true );
					//form.removeClass('closed');
					//// Update the votes balance
					//$votes_balance.hide().text(((data.results.votes_balance > 0) ? '+' : '')+data.results.votes_balance).fadeIn('slow');
					//$(':submit', form).removeAttr('disabled');
					//dispatchAnswer(data[0].params.data,true)
					btns.removeAttr('disabled')
			  },
				error : function(xhr,errorString,exceptionObj){
					console.log("Error on com_rate submit, xhr: " + xhr.responseText)
					btns.removeAttr('disabled')
					//try{
					//	show_form_error(form, xhr.responseText)
					//	btns.removeAttr('disabled')
					//}catch(e){
					//	btn.removeAttr('disabled')
					//	console.log("Answer idea submit browser error in server error handling: " + e)
					//	$('<div><p>Sorry, we cannot process your answer idea at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					//}
				}
			});
		}catch(e){console.log("thumbs_up error: " + e)}
	// Block normal non-AJAX form submitting
	return false;
}

$('form.mini_thumbs_up input[name=thumbsup_rating]').die('click').live('click',thumbs_up)

function ellipsis(page){
	//console.log("$('div.comment_text:visible',page).size(): " + $('div.comment_text:visible',page).size())
	$('div.comment_text:visible',page).each(
		function(){
			//console.log("ellipsis v3")
			var $this = $(this);
			if( $this.find('div.one_liner').size() > 0 ) return;
			//if(ie7) $this.closest('div.comment').css('margin',0);
			var d = $('<div class="one_liner"><span class="txt"></span></div>')
			$(this).prepend(d)

			var w = d.width();

			var icon;
			// if the next sibling is class resource upload or resource link, add an icon
			var res = $this.next('.resource')
			if(res.size() > 0){
				if(res.attr('className').match(/hide/)){
					// if hide, don't show an icon
				}else if(res.attr('className').match(/link/)){
					icon = 'link';
					w -= 20;
				}else if(res.attr('className').match(/upload/)){
					icon = 'upload';
					w -= 20;
				}
			}			
			w -= 30; // for the ellipsis

			var s = $('span.txt',d)

			var txt = $('p:first',this).html().replace(/<br[^>]*>/gi,' ');
			var num_chars = w / 6;
			txt = txt.substring(0,num_chars);
			//console.log("num_chars: " + num_chars + " raw txt: " + txt)
			var words = txt.split(/\s+/g);
			var words_cnt = words.length
			//console.log("Start words: " + words)
			var ctr = 6, reducing = false, sizing = true;
//			
			//loopctr = 0;

			do{
				s.html( words.slice(0,ctr).join(' ') );			
				//console.log("loop: " + loopctr + ", ctr: " + ctr + " str: " + words.slice(0,ctr).join(' ') + ", width: " + s.width() + ", w: " + w)
				if(s.width() > w){
						reducing = true;
					--ctr;
					//sizing = false;
				}else if(reducing){
					sizing = false;
				}else{
					//console.log("increase ctr")
					//console.log('words: ' + words)
					++ctr;
				}
				//if( ++loopctr > 10 ) break;
			}while(sizing && ctr <= words_cnt)
			// add ellipsis and icons
			if(words_cnt > ctr){
				s.append('&hellip;')
			}

			if(icon){
				d.append('<img src="/images/icon_' + icon + '12.gif"/>');
			}

		}
	)
}

function areArraysEqual(array1, array2) {
   var temp = new Array();
   if ( (!array1[0]) || (!array2[0]) ) { // If either is not an array
      return false;
   }
   if (array1.length != array2.length) {
      return false;
   }
   // Put all the elements from array1 into a "tagged" array
   for (var i=0; i<array1.length; i++) {
      key = (typeof array1[i]) + "~" + array1[i];
   // Use "typeof" so a number 1 isn't equal to a string "1".
      if (temp[key]) { temp[key]++; } else { temp[key] = 1; }
   // temp[key] = # of occurrences of the value (so an element could appear multiple times)
   }
   // Go through array2 - if same tag missing in "tagged" array, not equal
   for (var i=0; i<array2.length; i++) {
      key = (typeof array2[i]) + "~" + array2[i];
      if (temp[key]) {
         if (temp[key] == 0) { return false; } else { temp[key]--; }
      // Subtract to keep track of # of appearances in array2
      } else { // Key didn't appear in array1, arrays are not equal.
         return false;
      }
   }
   // If we get to this point, then every generated key in array1 showed up the exact same
   // number of times in array2, so the arrays are equal.
   return true;
}

function link_disabled(){
	$('<div><p>Sorry, this function is not currently active, we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
	return false;
}

function open_debugger(){
	var debug = $('<form><textarea style="width:300px;height:200px" name="_eval_in"></textarea><br/><button>Eval</button><button>Show log</button><button>Clear log</button><br/><textarea style="width:300px;height:200px" name="_eval_out"></textarea><input name="_show_var" style="width:200px"/> <input type="checkbox" name="_show_funcs"/> Funcs <button>Show var</button></form>').dialog( {title : 'Debug', modal : true, width: 400 } )
	$('button',debug).eq(0).unbind('click').click(
		function(){
			try{
				var instr = this.form._eval_in.value;
				outstr = eval(instr)
				this.form._eval_out.value += '> ' + instr + '\n' + outstr + '\n'
			}catch(e){ 
				//this.form._eval_out.value = e.message 
				this.form._eval_out.value += '> ' + instr + '\n' + e.message + '\n'
			}
			return false
		}
	)
	$('button',debug).eq(1).unbind('click').click(
		function(){
			try{ 
				this.form._eval_out.value = eval('console_log')
			}catch(e){ 
				this.form._eval_out.value = e.message 
			}
			return false
		}
	)
	$('button',debug).eq(2).unbind('click').click(
		function(){
			console_log = ''
			return false
		}
	)
	$.getScript('/javascripts/jquery.debugger.js') 
	$('button',debug).eq(3).unbind('click').click(
		function(){
			try{ 
				$.debug( eval(this.form._show_var.value), {showFunction: this.form._show_funcs.checked ? true : false} )
			}catch(e){ 
				this.form._eval_out.value = e.message 
			}
			return false
		}
	)
	return false;
}
