<?php


	$db = new mysqli("localhost","root", "root", "statistic1");
	$json["type"] = "new_models_of_brand";
	$json["brand"] = "Škoda";
	$json["year_from"] = 2008;
	$json["month_from"] = 1;
	$json["year_to"] = 2009;
	$json["month_to"] = 1;
	$json["lim"] = 5;
	$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
	echo $db->error;
	foreach($res as $item){
		$newBrandsChartData[$item['lbl']] = $item['s'];
	}
	while($db->next_result()){
      if($l_result = $db->store_result()){
              $l_result->free();
      }
    }
	$json["type"] = "new_brands_of_brand_fuels";
	$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
	echo $db->error;
	foreach($res as $item){
		$newBrandsChartData2[$item['lbl']] = $item['s'];
	}
	
?>

<html>
<head>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
</head>
<body style="margin: 0px;">

<div style="background-image: url(konkretni_znacka1.jpg);  background-repeat: no-repeat;
  background-size: auto;position: relative;width: 100%;height:3600px; margin: 0 auto;">
<div style="position: absolute;width:530px;height:275px;top: 2500px;left:400px;">
<canvas id="newBrandsChart"></canvas>
</div>
<div style="position: absolute;width:530px;height:275px;top: 2500px;left:1000px;">
<canvas id="newBrandsChart2"></canvas>
</div></div>

<script>
var ctx = document.getElementById('newBrandsChart').getContext('2d');
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
				echo "'".implode("','",array_values($newBrandsChartData))."'";
			?>
			]
        }],
		labels: [
			<?php
				echo "'".implode("','",array_keys($newBrandsChartData))."'";
				
			//foreach($newBrandsChartData as $item)if() echo $item['s'].",";
			//for($i = 0; $i < $lim; $i++){if($i==$lim-1) 
			//{echo "'".$newBrandsChartData[$i]['s']."'";
			//	break;}else{echo "'".$newBrandsChartData[$i]['s']."',";}}
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
			text: 'Top nejprodavanejsi modely',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx2 = document.getElementById('newBrandsChart2').getContext('2d');
var chart2 = new Chart(ctx2, {
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
				echo "'".implode("','",array_values($newBrandsChartData2))."'";
			?>
			]
        }],
		labels: [
			<?php
				echo "'".implode("','",array_keys($newBrandsChartData2))."'";
				
			//foreach($newBrandsChartData as $item)if() echo $item['s'].",";
			//for($i = 0; $i < $lim; $i++){if($i==$lim-1) 
			//{echo "'".$newBrandsChartData[$i]['s']."'";
			//	break;}else{echo "'".$newBrandsChartData[$i]['s']."',";}}
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
			text: 'Top nejprodavanejsi paliva',
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
