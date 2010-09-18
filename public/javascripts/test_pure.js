console.log("Loading test_pure.js...")

$('div.template').remove()

// create a dummy template
var template = $('<div class="template"><a href="x">empty link</a></div>')
//$('body').prepend(template)

//alert("about to use pure")

var data = {'who':'BeeBole!v2', site:'http://beebole.com' }
var directive = {'a':'who','a@href':'site'}
//var directive = {'a':'who','a@href':proc_site_name()}
//debugger


//t = $('<p><a class="edit_item" href="/team/edit"></a></p>')
//di = {'a' : 'site'}
//da = {'site' : 'CivicEvolution'}
//h = t.render(da, di)


$('body').prepend( template.render(data, directive) );


//var directive = {'a':'who','a@href':'site'}
var directive = {'a':function(arg){ return arg.context.who + '-' + arg.context.who},'a@href':'site'}

var template = $('<div class="template"><a href="x">empty link</a></div>')
$('body').prepend( template.render(data, directive) );


function proc_site_name(arg){
	var name = arg.context.who;
	if(name.match(/Civic/)){
		ret = '<b>' + vow_delete(name) + '(Like my site)</b>';
	}else{
		ret = '<b>' + vow_delete(name) + '(not my site)</b>';
	}
	
//	return ret + t2fn({'who' : 'My text'})
		return ret + t2fn(arg.context)
}

function vow_delete(s){
	return s.replace(/[aeiou]/g,'*')
	
}

var template2 = $('<span><i></i></span>');
var directive2 = {'i':'who'};
var t2fn = template2.compile(directive2);



var template = $('<div class="template"><a href="x">empty link</a></div>')
//var directive = {'a':proc_site_name,'a@href':'site'}
//var directive = {'a':proc_site_name,'a@href':'site'}
//var directive = {'a':function(arg){ return arg.context.who + '-' + arg.context.who},'a@href':'site'}

var directive = {'a':function(arg){ return t2fn(arg.context) },'a@href':'site'}


// render with function is working, how about compile with function
//$('body').prepend( template.render(data, directive) );

// now what about compile?
	
	var tfn = template.compile(directive)

	$('body').prepend( tfn({'who' : 'CivicEvolution', 'site' : 'http://civicevolution.org'}) )
	$('body').prepend( tfn({'who' : 'Yahoo', 'site' : 'http://yahoo.com'}) )
	$('body').prepend( tfn({'who' : 'Google', 'site' : 'http://google.com'}) )

// Build template functions
// request common templates as html (this can be a static page)
// iterate through the snippets
// convert each snippet to a template function using directives 
	// Can I store the directives in with the html snippets?
// store the template functions



/*
json_test_data
	data: Object
		answer: Object
			anonymous: 0
			created_at: "2010-01-30T05:24:58Z"
			id: 140
			member_id: 1
			status: "ok"
			text: "Test answer"
			updated_at: "2010-01-30T05:24:58Z"
			ver: 1
		from: Object
		item: Object
			item: Object
				ancestors: "0"
				created_at: "2010-01-30T05:24:58Z"
				id: 578
				o_id: 140
				o_type: 2
				order: 0
				par_id: 439
				sib_id: 0
				team_id: 10000
				updated_at: "2010-01-30T05:24:58Z"
			item_id: 578
			mode: "add"
			par_id: 439
			sib_id: 0
	raw: "item_json"
	time: "1264829098"
*/