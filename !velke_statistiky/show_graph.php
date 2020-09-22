<?php
if(isset($_GET["submit"])){
	$json = array( 
				"type" => $_GET["type"],
				"month_from" => date("n",strtotime($_GET["odDate"])),
				"year_from" => date("Y",strtotime($_GET["odDate"])),
				"month_to" => date("n",strtotime($_GET["doDate"])),
				"year_to" => date("Y",strtotime($_GET["doDate"])),
				"lim" => 5,
				"model" => $_GET["model"],
				"brand" => $_GET["brand"],
				"fuel" => $_GET["fuel"],
				"group" => $_GET["group"],
	);
	$db = new mysqli("localhost","root","root","statistic1");
	$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
	echo $db->error;
	foreach($res as $item){
		$chartData[$item['lbl']] = $item['s'];
	}
}
?><!DOCTYPE html>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>

</head>
<body>


<div style="position: absolute;width:530px;height:275px;">
<canvas id="myChart"></canvas>
</div>
<script>
var ctx = document.getElementById('myChart').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'doughnut',
    data: {
        datasets: [{	
			backgroundColor: [ 
                'rgba(248, 197, 46, 1)',
                'rgba(203, 71, 85, 1)',
                'rgba(207, 92, 54, 1)',
                'rgba(102, 46, 155, 1)',
                'rgba(67, 188, 205, 1)' ],

            data: [
			<?php
				echo "'".implode("','",array_values($chartData))."'";
			?>
			]
        }],
		labels: [
			<?php
				echo "'".implode("','",array_keys($chartData))."'";
			?>
		]
    },
    options: {
		animation: {
			duration: [3000],
			easing: ['easeOutBounce']
		},
		legend: { 
			labels: {fontSize: 14, fontFamily: 'Nunito Sans'}},
		title: { 
			display: true, 
			text: 'Top 5 nejprodavanejsi modely',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
</script>
</body>
</html>


