function update_after_signin(){
	setTimeout(function(){
		dispatcher.init_stat_data();
		dispatcher.update_sliders();
		show_default_tooltips();	
		},1000
	);

	$('form.signin_form').closest('div.ui-dialog').dialog('destroy').remove();
	$('div.comment.form, div.endorsement.form').find('img.i36').attr('src',member.photo_url);
	var endorsement = $('div.endorsement[code="' + member.ape_code + '"]');
	if(endorsement.size() > 0){
		var form = templates.endorsement.find('form').clone();
		form.attr('action', form.attr('action').replace(/\d+/,team_id) );
		endorsement.find('span.timeago').after( form );
		$('div.endorsement.form').remove();
	}
	$('body').off('keydown.check_signed_in');
 	
	if( member.active_participant || project_coordinator ){
		$('div.proposal').show();
	}
	if(project_coordinator){
		$('div.question_summary').each(
			function(){
				$.getScript('/idea/' + $(this).attr('id') + '/theme_summary');
			}
		);
	}

	init_tasks();
}

function call_to_action_completed(task){
	//console.log("call_to_action_completed task: " + task);
	task = $('div.cta_block.corner[id="' + task + '"]');
	if(!task.hasClass('completed')){
		task.addClass('completed')
		task.find('h1').html( task.find('h1').html() + '.' );
	}
	$('div.cta_block.hide').each(
		function(){
			if($('div.cta_block:visible').not( $('div.cta_block.completed:visible') ).size()<3){
				var cta = $(this);
				var task_details = cta_tasks[ cta.attr('id') ];
				var show_task = true;
				if(typeof task_details.view_conditions != 'undefined'){
					for(var i=0, cond; (cond=task_details.view_conditions[i]);i++){
						//console.log("test view_condition " + cond + ": " + eval(cond) );
						if(!eval( cond )){
							show_task = false;
							break;
						}
					}
				}
				if(show_task){
					cta.removeClass('hide');
				}
			}
		}
	);
}

function init_tasks(){
	if(typeof template_functions == 'undefined'){
		setTimeout(init_tasks, 300);
		return;
	}
	$('div.right_master div.calls-to-action div.cta_block').remove();
	var num_cta_visible = member.signed_in ? 3 : 4;
	var ctr = 1;
	for(task in cta_tasks){
		//console.log("task: " + task);
		var task_details = cta_tasks[task];
		// all the include_conditions must be true
		var add_task = true;
		for(var i=0, cond; (cond=task_details.include_conditions[i]);i++){
			//console.log("test include_condition " + cond + ": " + eval(cond) );
			if(!eval( cond )){
				add_task = false;
				break;
			}
		}
		if(add_task){
			//console.log("add task " + task);
			var cta = template_functions['call-to-action']({id: task, ctr: ctr, title: task_details.title, link: task_details.link || ''});
			cta = $(cta).appendTo('div.calls-to-action');
			if(ctr > num_cta_visible){
				cta.addClass('hide');
			}
			++ctr;
		}else{
			//console.log("Do not add task " + task);
		}
	}
	if(!member.active_participant){
		$('div.cta_block[id="view our plan"]').show();
	}
	
	Tipped.create('div.cta_block', get_tooltip,
		{ skin: 'yellow', hook: 'leftmiddle', containment: 'viewport'	} );
	
}

$('body').on('click','div.calls-to-action p.link', 
	function(event){
		var task_id = $(this).closest('div.cta_block').attr('id');
		//console.log("clicked on task: " + task_id);
		var task_details = cta_tasks[ task_id ];
		if(task_details.onclick){
			//console.log("task_details.onclick: " + task_details.onclick);
			eval(task_details.onclick);
		}
	}
);

$(function(){
	setTimeout(init_tasks, 200);
});

var cta_tasks = {

	'sign in' : 
		{
			title: 'Sign-in / Sign-up',
			include_conditions: ["!member.signed_in"]
		},


	'read our vision' : 
		{
			title: 'Read our Vision',
			include_conditions: ["$('div.summary_block h4.rating').hasClass('please-rate')","!participant_stats.endorse", "!member.active_participant"]
		},

	'rate our vision' :
		{
			title: 'Rate our Vision',
			include_conditions: ["$('div.summary_block h4.rating').hasClass('please-rate')"]
		},

	'endorse our vision' :
		{
			title: 'Endorse our Vision',
			link: 'Not now',
			onclick: "call_to_action_completed('endorse our vision'); $('div.cta_block[id=\"endorse our vision\"]').addClass('incomplete');",
			include_conditions: ['!participant_stats.endorse']
		},

	'view our plan' :
		{
			title: 'View our plan',
			link: 'Click here to view',
			onclick: "$('div.proposal').show(350, function(){$('html,body').animate( {scrollTop: $('div.proposal').offset().top}, 800); call_to_action_completed('view our plan'); }); Tipped.hideAll();",
			include_conditions: ['!member.active_participant && !project_coordinator']
		},
	
	'rate answers' : 
		{
			title: 'Rate the answers',
			include_conditions: ["$('div.answer_status div.unrated').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'discuss answers' : 
		{
			title: 'Discuss the answers',
			include_conditions: ["$('div.answer_status div.unrated').size()==0","$('ul.themes div.answer').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'rate new ideas' :
		{
			title: 'Rate new ideas',
			include_conditions: ["$('a.view_unrated_ideas:visible').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
			//include_conditions: ["stat_data.idea_counts.total_ideas_unrated.length>0"]
		},
		
	'create answers' :
		{
			title: 'Create answers',
			include_conditions: ['project_coordinator','stat_data.idea_counts.total_themes_all<4'],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'share your ideas' :
		{
			title: 'Share your ideas',
			include_conditions: [],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},
	
	'organize ideas' : 
		{
			title: 'Organize ideas',
			include_conditions: ['project_coordinator','stat_data.idea_counts.total_ideas_all>0'],
			view_conditions: ["$('div.proposal').is(':visible')"]
		},

	'Review post-its' :
		{
			title: 'Review post-its wall',
			include_conditions: ['!project_coordinator',"$('ul.themes div.answer').size()>0"],
			view_conditions: ["$('div.proposal').is(':visible')"]
		}
		
};

// show tool tips

var tooltip_rules = {

	'rate vision' : 
		{
			display_conditions: ["$('div.summary_block h4.rating').hasClass('please-rate')"]
		},

	'rate overall answer'	: 
		{
			display_conditions: ["element.closest('div.answer_block').find('h4.rating').hasClass('please-rate')"]
		},

	'add endorsement'	: 
		{
			display_conditions: ["!participant_stats.endorse"]
		},

	'post-its-wall'	: 
		{
			display_conditions: ["true"]
		},
		
	'li.theme' : 
		{
			display_conditions: ["true"]
		},

	'a.view_unrated_ideas' : 
		{
			display_conditions: ["true"]
		}
		
}

function get_tooltip(element){
	element = $(element);
	var tooltip_id = element.attr('data_tool_tip');
	console.log("get tooltip for " + tooltip_id);
	var tooltip = templates['idea_tooltips'].find('div[id="' + tooltip_id + '"]');
	if(tooltip.size()==0){
		var tooltip_id = (element.prop('tagName') + '.' + element.prop('className')).toLowerCase();
		console.log("No try to get tooltip for " + tooltip_id);
		tooltip = templates['idea_tooltips'].find('div[id="' + tooltip_id + '"]');
	}
	
	// check if the are any rules about when to not show the tooltip
	var display_tooltip = true;
	var rule = tooltip_rules[tooltip_id];
	if(rule && rule.display_conditions){
		for(var i=0, cond; (cond=rule.display_conditions[i]);i++){
			console.log("test include_condition " + cond + ": " + eval(cond) );
			if(!eval( cond )){
				display_tooltip = false;
				break;
			}
		}
	}
	if(display_tooltip){
		return tooltip.html() || 'No tooltip found for ' + element.attr('data_tool_tip');
	}else{
		Tipped.remove(element);
		return false;
	}
		
}	


function init_tooltips(){
	console.log("try to init_tooltips");
	if(typeof templates == 'undefined' ){
		console.log("try to init_tooltips again soon");
		setTimeout( function(){init_tooltips();},300);
		return;
	}
	
	jQuery.extend(Tipped.Skins, {
	  'custom' : {
	    border: { size: 4, color: '#959fa9' },
	    background: '#f7f7f7',
	    radius: { size: 4, position: 'border' },
	    closeButtonSkin: 'light',
			maxWidth: 200,
			radius: 10
	  },
	  'yellow' : {
	    border: { size: 4, color: '#959fa9' },
	    background: '#ffffaa',
    	border: { size: 1, color: '#6d5208', opacity: .4},
	    radius: { size: 4, position: 'border' },
	    closeButtonSkin: 'light',
			maxWidth: 200,
			radius: 10,
			shadow: {
	      blur: 4,
	      offset: { x: 3, y: 3 },
	      opacity: .2
	    }
	  }
	
	});
	
	// set the tooltip data pointer on element as 
	//		data_tool_tip: tool_tip
	Tipped.create('div.answer_block div.rater', get_tooltip, 
		{ skin: 'yellow', hook: 'rightmiddle'	} );

	Tipped.create('div.summary_block div.rater', get_tooltip, 
		{ skin: 'yellow', hook: 'rightmiddle', containment: false	} );

	Tipped.create('div.endorsement.form', get_tooltip, 
		{ skin: 'yellow', hook: 'rightmiddle', containment: false	} );
		
	Tipped.create('div.cta_block', get_tooltip,
		{ skin: 'yellow', hook: 'leftmiddle', containment: 'viewport'	} );

	Tipped.create('div.idea-post-it-instructions li:nth-child(2)', get_tooltip,
		{ skin: 'yellow', hook: 'rightmiddle', containment: 'viewport'	} );
		
	Tipped.create('div.answer_block li.theme:first', get_tooltip,
		{ skin: 'yellow', hook: 'rightmiddle', containment: 'viewport'	} );

	Tipped.create('a.view_unrated_ideas', get_tooltip,
		{ skin: 'yellow', hook: 'rightmiddle', containment: 'viewport'	} );
		
		
	show_default_tooltips();	
	console.log("init_tooltips completed");
}

function show_default_tooltips(){
	if(member.signed_in && $('div.summary_block h4.rating').hasClass('please-rate')){
		Tipped.show('div.summary_block div.rater');
	}

	if( member.signed_in && !participant_stats.endorse ){
		Tipped.show('div.endorsement.form');
	}
	
}