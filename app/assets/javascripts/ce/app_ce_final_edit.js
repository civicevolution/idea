function editing_disabled(show_msg_flag){
	show_msg_flag = (typeof show_msg_flag === "undefined") ? true : show_msg_flag;
	if(!theming_auth){
		if(show_msg_flag){
			alert("You are not authorized to theme this project");
		}
		return true;
	}else{
		return false;
	}
  //if(disable_editing){
  //  if(published){
  //    var msg = 'Editing is disabled because themes have been published'
  //  }else{
  //    var msg = 'You do not have editing privileges'
  //  }
	//	var dialog = $('<p class="warn">' + msg + '</p>').dialog( {title : 'Sorry', modal : true, width : '200px', closeOnEscape: true, close: function(){$(this).remove()} });
	//	return true;
	//}else{
	//  return false;
	//}
}

function update_status_report(){}

function make_final_edit_themes_sortable(themes){
	if(editing_disabled(false))return false;
	themes.sortable({
		stop: function(event,ui){
			//console.log("update the theme sort order");
			var ul = ui.item.closest('ul');
			var new_ids = [];
			//var ltr_ctr = 1;
		 	ul.find('li.theme').each( function(){
				var li = $(this);
				new_ids.push( li.attr('theme_id'));
				//li.find('div.controls span.ltr').html( int_to_letters( ltr_ctr++ )  );
			});
			new_ids = new_ids.join(',');
			// compare if the order has changed
			console.log("old order: " + ul.attr('id_order') + " new order: " + new_ids);
			if( ul.attr('id_order') != new_ids ){
				console.log("update the theme sort to: " + new_ids);
				$.post('/idea/' + ul.attr('id') + '/idea_order', 
					{	
						//ordered_ids: $.makeArray(ul.find('li.theme').map(function(){return Number($(this).attr('theme_id'));}))
						ordered_ids: $.makeArray($.map(new_ids.split(','), function(el){return Number(el)}))
					}, 
					"script"
				);
				theme_edit_wait();
			}
	
		}
	});
}
function theme_edit_wait(){
	var dialog = $('<p class="theme_saving_modal">Please wait a moment</p>').dialog( {title : 'Saving...', modal : true, width : '200px', closeOnEscape: true, close: function(){$(this).remove()} });
}
function clear_theme_edit_wait(){
	$('p.theme_saving_modal').closest('div.ui-dialog').dialog('destroy').remove();
}

function int_to_letters(val){
  var str = '';
  var val_floor = Math.floor(val/26);
  var mod = ind = val%26;
  if(mod == 0){
    --val_floor;
    mod = 26;
  }
  if(val_floor>0){
    str += String.fromCharCode('A'.charCodeAt() + val_floor - 1);
  }

  str += String.fromCharCode('A'.charCodeAt() + mod - 1);
  return str;
}

function update_new_theme( act, form_id, theme_json ){
	if(editing_disabled())return false;
	if(act == 'insert'){
		console.log("add_new_theme with text: " + theme_json.live_theme.text);
		var li = $('li.theme.model').clone();
		li.removeClass('model');
		li.attr('theme_id',theme_json.live_theme.id);
		li.find('p.theme').html(theme_json.live_theme.text);
		li.find('p.example').html(theme_json.live_theme.example_ids);
		var ul = $('ul.themes');
		li.find('span.ltr').html( int_to_letters( ul.find('li').size() + 1 ) );
		ul.append(li)
	}else{
		console.log("update_theme with text: " + theme_json.live_theme.text);
		var li = $('li[theme_id="' + theme_json.live_theme.id + '"]');
		li.find('p.theme').html(theme_json.live_theme.text);
		li.find('p.example').html(theme_json.live_theme.example_ids);
	}
	$('input[name="form_id"][value="' + form_id + '"]').closest('div.ui-dialog').dialog('destroy').remove();
}

var form_ctr = 1;
$('body').on('click','div.theme_final_edit div.edit',
  function(){
		if(editing_disabled())return;
    //console.log("edit the theme/example");
		var li = $(this).closest('li');
		if(li.find('form').size() > 0 )return;
		var theme_id = li.attr('theme_id');
		var form = $('div.edit_form').eq(0).clone();
		form.show();
		form.find('form').attr('action', form.find('form').attr('action').replace(/\d+/,theme_id));
		form.find('textarea[name="text"]').val( li.find('p.theme').html().trim() );
		li.find('div.theme').after(form).hide();
		return false;
	}
);

$('body').on('click','div.theme_final_edit div.visibility',
	function(){
		//console.log("adjust visibility");
		if(editing_disabled())return false;
		var li = $(this).closest('li');
		if(li.hasClass('visible')){
			//li.removeClass('visible');
			var visible = false;
		}else{
			//li.addClass('visible');
			var visible = true;
		}
		$.post('/idea/' + li.attr('theme_id') + '/visbility', 
			{	
				visible: visible
			}, 
			"script"
		);
		theme_edit_wait();
	}
);
$('body').on('click','form.theme_edit a.cancel',
	function(){
		$(this).closest('li').find('div.theme').show().end().find('div.edit_form').remove();
		return false;
	}
);
$('body').on('click','div.theme_final_edit a.close',
	function(){
		$(this).closest('div.theme_final_edit').dialog('close');
		return false;
	}
);

$('body').on('click','div.theme_final_edit a.show_ideas',
	function(){
		var link = $(this);
		if(link.html().match(/show/i)){
			link.html( link.html().replace(/Show/, 'Hide'));
			link.closest('li').find('ul.constituent_ideas').show(300);
		}else{
			link.html( link.html().replace(/Hide/, 'Show'));
			link.closest('li').find('ul.constituent_ideas').hide(300);
		}
		return false;
	}
);
