console.log("Loading app_ce_live_table.js");

$('h3.session_title').after( $('div.request_help'))

function live_resize(){
	// get overall avl height

	var win_height = $(window).height();
	$('body').height( win_height);
		  
	//var tpdi = $('div.incoming_ideas');
	//tpdi.height(ws.height() - 4);
	//var h3_height = tpdi.find('h3').outerHeight(true);
	//var ltp = $('div#live_talking_points');
  //ltp.height(tpdi.height() - h3_height - 10);
  //var inner_padding = 20;
  //ltp.find('div.inner').height( ltp.height() - 4 - inner_padding);
  
  var inner = $('div#groups_live_talking_points div.inner');
	inner.top = inner.offset().top;
	inner.height( win_height - inner.top - 60);
	
	
	  	  
}

setTimeout(live_resize,100);

$(window).resize(function(){
		try{  
			setTimeout(live_resize,800);
		}catch(e){}
	}
);
  
  

var tp_live_form_ctr = 1;

// intercept post and make sure the vote has been set and the count is not too high
$('form.post_live_tp').live('ajax:beforeSend', 
	function(){
	  console.log("check votes and size before submitting the talking point");
	  var $form = $(this);
	  
	  // clear error messages in this form
	  $form.find('ul.errors').remove();
	  
	  var textlength = $form.find('textarea').val().replace(/\s/g,'').length;
	  console.log("textlength: " + textlength);
	  var errors = [];
	  if(textlength < 10 ){
	    errors.push( {selector: 'textarea', msg: 'Your talking point must be more than 10 characters long'});
	  }else if(textlength > 250){
	    errors.push( {selector: 'textarea', msg: 'Your talking point must be less than 250 characters long'});
	  }
	  var votes_for_val = $form.find('input[name="votes_for"]').val();
	  if( votes_for_val == '' || isNaN(votes_for_val)){
	    errors.push( {selector: 'input[name="votes_for"]', msg: 'You must enter the number of YES votes for this talking point, or 0'});
	  }

	  var votes_against_val = $form.find('input[name="votes_against"]').val();
	  if( votes_against_val == '' || isNaN(votes_against_val)){
	    errors.push( {selector: 'input[name="votes_against"]', msg: 'You must enter the number of NO votes for this talking point, or 0'});
	  }
	  
	  if(errors.length > 0){
	    console.log("errors were found");
	    // set the error messages in this form
	    var err_ul = $('<ul class="errors"></ul>');
	    $.each(errors,
	      function(){
	        
	        err_ul.append('<li>' + this.msg + '</li>');
	        
	      }
	    );
	    
	    $form.find('div.form_controls').after(err_ul);
	    
	    
	    // clear waiting icon
	    var btn = $form.find(':submit')
	    btn.show().removeAttr('disabled').end().find('img').remove();
	    btn.html( btn.data('ujs:enableWith') );
	    
	    return false;
	  }
	}
)

$('a.new_live_talking_point').live('click', 
	function(){
		console.log("new_live_talking_point - add another form v1");
		var tp = $('div.talking_point_block'); 
		var tp_clone = tp.eq(0).clone();
		if(tp.size() > 1){
			$('a.new_live_talking_point').hide();
			$('p.new_live_talking_point').show();
		}else{
		
		}
		tp_clone.find(':text').val('');
		
		var cntr = tp_clone.find('span.char_ctr');
		cntr.html( cntr.attr('cnt'));
		var textarea = tp_clone.find('textarea');
		textarea.removeAttr('cols rows style');
		setTimeout(function(){ activate_text_counters_grow( this, 100);}.bind(textarea),100);
		
		//tp_clone.find('form');//.removeClass('orig');
		tp_clone.find('input[name="form_id"]').val(++tp_live_form_ctr);
		//tp_clone.find('h3').html( tp_clone.find('h3').html().replace('Enter a ', 'Start a new ') );
		tp.last().after(tp_clone)
		return false;
	}
)

// overrides because I am using generic code right now
function make_new_ideas_draggable(){};

function update_chat(data){
  var chat = $('div.chat');
  var link = $('a.ask_for_help');
  var offset = link.offset();
  chat.css({display: 'block', top: offset.top + link.outerHeight(), left: offset.left })
  
  var chat_log = chat.find('div.chat_log');
  if(chat_log.find('p:last').attr('node_id') == data.node_id){
    chat_log.append('<p node_id="' + data.node_id + '">' + data.msg + '</p>').scrollTop(99999999);
  }else{
    chat_log.append('<p node_id="' + data.node_id + '">' + data.name + ': ' + data.msg + '</p>').scrollTop(99999999);
  }
}
$('div.chat p.hdr a').live('click',
  function(){
    $(this).closest('div.chat').hide();
    return false;
  }
);

$(function(){
  $('div.join_com').prepend(' /');
  $('div.join_com').prepend( $('<a href="#" class="ask_for_help">Ask for help</a>') );
});
$('a.ask_for_help').live('click',
  function(){
    var chat = $('div.chat');
    var link = $(this);
    var offset = link.offset();
    chat.css({display: 'block', top: offset.top + link.outerHeight(), left: offset.left });
    chat.find('input[type="text"]').focus();
    return false;
  }
);