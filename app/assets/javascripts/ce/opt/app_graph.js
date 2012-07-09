$.getScript('https://www.google.com/jsapi',function(){
	//draw_participant_graph()
	}
);
function draw_participant_graph(){
	console.log("draw_participant_graph")
	google.load("visualization", "1", {packages:["corechart"]});
	google.setOnLoadCallback(drawChart);
}
function drawChart() {
	var data = new google.visualization.DataTable();
	data.addColumn('string', 'Task');
	data.addColumn('number', 'Hours per Day');
	data.addRows(7);
	data.setValue(0, 0, 'Work');
	data.setValue(0, 1, 11);
	data.setValue(1, 0, 'Eat');
	data.setValue(1, 1, 2);
	data.setValue(2, 0, 'Commute');
	data.setValue(2, 1, 2);
	data.setValue(3, 0, 'Watch TV');
	data.setValue(3, 1, 2);
	data.setValue(4, 0, 'Sleep');
	data.setValue(4, 1, 7);
	data.setValue(5, 0, 'Dreaming');
	data.setValue(5, 1, .2);
	data.setValue(6, 0, 'laughing');
	data.setValue(6, 1, .7);

	var chart = new google.visualization.PieChart(document.getElementById('participation_chart_div'));
	chart.draw(data, {width: 450, height: 300, title: 'My Daily Activities'});	

}
