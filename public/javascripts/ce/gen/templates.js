var json_templates = {}, directives, template_data, jsonFn;
var json_test_data;
function create_templates(data){
	console.log("create_templates")
	template_data = $(data.replace(/src=['"]['"]/g,''))
	// break up the template into sub templates
	//var tmps = json_templates['full'];
	json_templates['full'] = template_data;
	json_templates['answer'] = $('div.answer', template_data).closest('tr');
	json_templates['bs_idea'] = $('div.bs_idea', template_data).closest('tr');
	json_templates['comment'] = $('div.Comment', template_data);
	json_templates['resource'] = $('div.resource', template_data);//.remove();
	json_templates['chat_message'] = $('tr.Chat', template_data);
	json_templates['add_comment_form'] = $('form.add_comment_form', template_data);	
	json_templates['add_answer_form'] = $('form.add_answer_form:last', template_data);
	json_templates['add_bs_idea_form'] = $('form.add_bs_idea_form', template_data);			
	
	//console.log("set the template directives")
	directives = {
		answer : {
			'@uid' : 'uid',
			'@class+' : function(arg){ return (arg.context.item.item.sib_id > 0) ? ' sibling' : ' top_sibling' },
			'@id' : 'i#{item_id}',
			'div.answer @id+' : 'data.answer.id',
			'div.answer' : function(arg){return simple_format(unescape(arg.context.data.answer.text))},
			'a.com_on_tgt @href+' : '/#{data.answer.id}',
			'a.edit_answer @href+' : '/#{data.answer.id}',
			'a.edit_answer @class+' : function(arg){return (arg.context.edit_link != 'on') ? ' hide' : '' },
			'span.version' : function(arg){ return (arg.context.data.answer.ver == 1) ? 'Original version' : 'Version ' + arg.context.data.answer.ver },
			'abbr.timeago @title' : 'data.answer.updated_at',
			'a.view_history @href+' : '/#{data.answer.id}',
			'a.view_history @rel+' : '#{data.answer.id}',
			'a.view_history @class+' : function(arg){ return (arg.context.data.answer.ver == 1) ? ' hide' : '' },
			'span.avg' : 'average',
			'span.cnt' : 'count',
			'input.star @name+' : 'data.answer.id'
		},
		bs_idea : {
		  '@uid' : 'uid',
		  'div.bs_idea @id+' : 'data.bs_idea.id',
		  'div.bs_idea' : function(arg){return simple_format(unescape(arg.context.data.bs_idea.text))},
			'a.com_on_tgt @href+' : '/#{data.bs_idea.id}',
			'a.edit_bs_idea @href+' : '/#{data.bs_idea.id}',
			'a.edit_bs_idea @class+' : function(arg){return (arg.context.edit_link != 'on') ? ' hide' : '' },
			'abbr.timeago @title' : 'data.bs_idea.created_at',
			'span.avg' : 'average',
			'span.cnt' : 'count',
			'input.star @name+' : 'data.bs_idea.id'
		},		
		comment : {
			'@id' : 'i#{item_id}',
		  '@uid' : 'uid',
		  '@item_id' : 'item_id',
		  'div.Comment_entry @id+' : 'data.comment.id',	
		  'div.Comment_entry @target_type' : 'item.item.target_type',	
		  'div.Comment_entry @target_id' : 'item.item.target_id',	
			//'img.i36 @src+' : '#{pic_id}.gif',
			//'img.i36 @src' : 'pic_url',
			'span.author' : function(arg){return unescape(arg.context.author) },
			'abbr.timeago @title' : 'data.comment.created_at',
			'div.comment_text' : function(arg){return simple_format(unescape(arg.context.data.comment.text))},
			'div.resource' : function(arg){return arg.context.resource.resource.id ? jsonFn.resource(arg.context) : '' },
			'div.resource @class+' : function(arg){return arg.context.resource.resource.id ? '' : ' hide' },
			'a.edit_com @href+' : '/#{data.comment.id}',
			'a.edit_com @class+' : function(arg){return (arg.context.edit_link != 'on') ? ' hide' : '' },
			'a.reply @href+' : '/#{data.comment.id}',
			'a.view_target' : function(arg){switch(arg.context.item.item.target_type){ case 2: var title = 'View answer'; break; case 11: var title = 'View idea'; break; default: title = ''; }; return title },
			'a.view_target @href+' : '/#{item.item.target_id}',
			'a.view_target @class+' : function(arg){return (arg.context.edit_link != 'on') ? ' hide' : '' },
			"input[name='thumbsup_id'] @value" : 'data.comment.id',
			'span.votes_up' : function(arg){return (arg.context.up>0) ? arg.context.up : '' },
			'span.votes_down' : function(arg){return (arg.context.down>0) ? arg.context.down : '' }
		},	
		resource : {
			'@class' : 'clear',
			'h3.resource_title' : function(arg){return unescape(arg.context.resource.resource.title) },
			'div.resource_description' : function(arg){return simple_format(unescape(arg.context.resource.resource.description))},
			'p.resource_link' : function(arg){return unescape(arg.context.resource_link) }
		},
		chat_message : {
			'@id' :'chat_#{chat_msg_id}',			
			'p.name' : function(arg){return unescape(arg.context.name) || arg.context.from.properties.name },
			'p.msg' : function(arg){return unescape(arg.context.text)},
			//'span.del @class+' : function(arg){ return unescape(arg.context.name) == member.unique_name ? '' : ' hide'; }, // only show this link if I am the chat message author
			'td.pic' : '<img src="#{pic_url}" />'			
			//'td.pic' : '<img src="/images/36x36/#{pic_id}.gif" />'			
		},
		add_comment_form:{
			"input[name='par_id'] @value" : 'par_id',
			"input[name='mode'] @value" : 'mode',
			"input[name='id'] @value" : 'id',
			"input[name='resource_type'] @value" : 'resource_type',
			"input[name='comment[target_id]'] @value" : 'tgt_id',
			"input[name='comment[target_type]'] @value" : 'tgt_type'
		},
		add_answer_form:{
			"input[name='par_id'] @value" : 'par_id',
			"input[name='mode'] @value" : 'mode',
			"input[name='id'] @value" : 'id'
		},
		add_bs_idea_form : {
			"input[name='mode'] @value" : 'mode',
			"input[name='bs_idea[question_id]'] @value" : 'q_id',
			"input[name='idea_id'] @value" : 'id'
		}
	}	
	
	jsonFn = {
		answer: json_templates.answer.compile(directives.answer),
		bs_idea: json_templates.bs_idea.compile(directives.bs_idea),
		comment: json_templates.comment.compile(directives.comment),
		resource: json_templates.resource.compile(directives.resource),
		chat_message: json_templates.chat_message.compile(directives.chat_message),
		add_comment_form: json_templates.add_comment_form.compile(directives.add_comment_form),
		add_answer_form: json_templates.add_answer_form.compile(directives.add_answer_form),
		add_bs_idea_form : json_templates.add_bs_idea_form.compile(directives.add_bs_idea_form)
	}
	return false;
}
//'input.star @checked' : function(arg){debugger; return false}
//'div.item @class+' : function(arg){ return (arg.context.data.item.item.sib_id > 0) ? ' sibling' : ' top_sibling' }



function simple_format(s){
	var strs = s.split(/\n\n/)
	s = ''
	for(var i=0;str=strs[i];i++) s += '<p>'+str+'</p>'
	return s.replace(/\n/g,'<br/>')
}
