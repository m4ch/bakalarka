<?php
// modelTypes: [ { id: 'new_models_of_model_n_concurency', title: 'Top nejprodávanější k modelu' }, { id: 'new_models_of_model_fuels', title: 'Top nejprodávanější typy paliva' }, { id: 'new_models_of_model_category_n_concurency', title: 'Top nejprodávanější ve své třídě' } ],

$types = ["new_models_total_score","new_models_of_model_n_concurency", "new_models_of_model_fuels", "new_models_of_model_category_n_concurency"];
$perMonthTypes = ["new_models_with_concurency_per_month_all","new_models_of_model_fuels_per_month_all"];
$perYearTypes = ["new_models_of_model_fuels_per_year_all","new_models_with_concurency_per_year_all"];

$i = 0;
$chartColors = 	[ 
                'rgba(248, 197, 46, 1)',
                'rgba(203, 71, 85, 1)',
                'rgba(207, 92, 54, 1)',
                'rgba(102, 46, 155, 1)',
                'rgba(67, 188, 205, 1)' ];
  $mesic[1] = "Leden";
  $mesic[2] = "Únor";
  $mesic[3] = "Březen";
  $mesic[4] = "Duben";
  $mesic[5] = "Květen";
  $mesic[6] = "Červen";
  $mesic[7] = "Červenec";
  $mesic[8] = "Srpen";
  $mesic[9] = "Září";
  $mesic[10] = "Říjen";
  $mesic[11] = "Listopad";
  $mesic[12] = "Prosinec";
if(isset($_GET["submit"])){
	$db = new mysqli("localhost","root","root","statistic1");
	foreach($types as $type){
		$json = array( 
			"type" => $type,
			"month_from" => date("n",strtotime($_GET["odDate"])),
			"year_from" => date("Y",strtotime($_GET["odDate"])),
			"month_to" => date("n",strtotime($_GET["doDate"])),
			"year_to" => date("Y",strtotime($_GET["doDate"])),
			"lim" => 5,
			"model" => $_GET["model"]
			);
		$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
		echo $db->error;
			foreach($res as $item){
				$chartData[$type][$item['lbl']] = $item['s'];
			}
		//$res->close();
	    $db->next_result();
	}
	foreach($perMonthTypes as $type){
		$json = array( 
			"type" => $type,
			"month_from" => date("n",strtotime($_GET["odDate"])),
			"year_from" => date("Y",strtotime($_GET["odDate"])),
			"month_to" => date("n",strtotime($_GET["doDate"])),
			"year_to" => date("Y",strtotime($_GET["doDate"])),
			"lim" => 5,
			"model" => $_GET["model"]
			);
		$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
		echo $db->error;
			foreach($res as $item){
				$chartData[$type][$item['lbl']][(int)$item["st_model_statistics_date_year"]][(int)$item["st_model_statistics_date_month"]] = $item['s'];
			}
		//$res->close();
	    $db->next_result();
	}
	foreach($perYearTypes as $type){
		$json = array( 
			"type" => $type,
			"month_from" => date("n",strtotime($_GET["odDate"])),
			"year_from" => date("Y",strtotime($_GET["odDate"])),
			"month_to" => date("n",strtotime($_GET["doDate"])),
			"year_to" => date("Y",strtotime($_GET["doDate"])),
			"lim" => 5,
			"model" => $_GET["model"]
			);
		$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
		echo $db->error;
			foreach($res as $item){
				$chartData[$type][$item['lbl']][(int)$item["st_model_statistics_date_year"]] = $item['s'];
			}
		//$res->close();
	    $db->next_result();
	}
}
?><!DOCTYPE html>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>

</head>
<body>
<?php echo "Statistika pro ".$json["model"]." za období ".$json["month_from"]."/".$json["year_from"]." - ".$json["month_to"]."/".$json["year_to"];?>
<div style="width:530px;height:275px;">
<canvas id="new_models_total_score"></canvas>
</div>
<div style="width:530px;height:275px;">
<canvas id="new_models_of_model_n_concurency"></canvas>
</div>
<div style="width:530px;height:275px;">
<canvas id="new_models_of_model_fuels"></canvas>
</div>
<div style="width:530px;height:275px;">
<canvas id="new_models_of_model_category_n_concurency"></canvas>
</div>
<div style="width:530px;height:275px;">
<canvas id="new_models_with_concurency_per_month_all"></canvas>
</div>
<div style="width:530px;height:275px;">
<canvas id="new_models_of_model_fuels_per_month_all"></canvas>
</div>
<div style="width:530px;height:275px;">
<canvas id="new_models_of_model_fuels_per_year_all"></canvas>
</div>
<div style="width:530px;height:275px;">
<canvas id="new_models_with_concurency_per_year_all"></canvas>
</div>
<script>
var ctx = document.getElementById('new_models_with_concurency_per_year_all').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'line',
    data: {
        datasets: [
					<?php 
					foreach($chartData["new_models_with_concurency_per_year_all"] as $key=>$dataset){ 
					?>
		{
			label:'<?php echo $key;?>',
			borderColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			backgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBackgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBorderColor: <?php echo "'".$chartColors[$i++]."'"; ?>,
			fill: false,
            data: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
					if(isset($dataset[date("Y",$start)]) && isset($dataset[date("Y",$start)])){
						echo "'".$dataset[date("Y",$start)]."',";
					} else {
						echo "'0',";
					}
					$start = strtotime("+1 year", $start);
				}
			?>
			]
        },
					<?php }
					?>
		],
		labels: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
						echo "'".date("Y",$start)."',";
						$start = strtotime("+1 year", $start);
				} 
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
			text: 'Průběh prodeje modelu a konkurence',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx = document.getElementById('new_models_of_model_fuels_per_year_all').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'line',
    data: {
        datasets: [
					<?php
					$i = 0;
					foreach($chartData["new_models_of_model_fuels_per_year_all"] as $key=>$dataset){ 
					?>
		{
			label:'<?php echo $key;?>',
			borderColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			backgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBackgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBorderColor: <?php echo "'".$chartColors[$i++]."'"; ?>,
			fill: false,
            data: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
					if(isset($dataset[date("Y",$start)]) && isset($dataset[date("Y",$start)])){
						echo "'".$dataset[date("Y",$start)]."',";
					} else {
						echo "'0',";
					}
					$start = strtotime("+1 year", $start);
				}
			?>
			]
        },
					<?php }
					?>
		],
		labels: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
						echo "'".date("Y",$start)."',";
						$start = strtotime("+1 year", $start);
				} 
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
			text: 'Průběh prodeje typů paliv',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx = document.getElementById('new_models_total_score').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'bar',
    data: {
        datasets: [
		{
			label: '',
			backgroundColor: [ 
                'rgba(248, 197, 46, 1)',
                'rgba(203, 71, 85, 1)',
                'rgba(207, 92, 54, 1)',
                'rgba(102, 46, 155, 1)',
                'rgba(67, 188, 205, 1)' ],

            data: [
			<?php
				echo "'".implode("','",array_values($chartData["new_models_total_score"]))."'";
			?>
			]
        }],
		labels: [
			<?php
				echo "'".implode("','",array_keys($chartData["new_models_total_score"]))."'";
			?>
		]
    },
    options: {
		animation: {
			duration: [3000],
			easing: ['easeOutBounce']
		},
		legend: { 
			display: false,
			labels: {fontSize: 14, fontFamily: 'Nunito Sans'}},
		title: { 
			display: true, 
			text: 'V celkovem hodnoceni',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx = document.getElementById('new_models_of_model_fuels_per_month_all').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'line',
    data: {
        datasets: [
					<?php 
					$i = 0;
					foreach($chartData["new_models_of_model_fuels_per_month_all"] as $key=>$dataset){ 
					?>
		{
			label:'<?php echo $key;?>',
			borderColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			backgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBackgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBorderColor: <?php echo "'".$chartColors[$i++]."'"; ?>,
			fill: false,
            data: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
					if(isset($dataset[date("Y",$start)]) && isset($dataset[date("Y",$start)][date("n",$start)])){
						echo "'".$dataset[date("Y",$start)][date("n",$start)]."',";
					} else {
						echo "'0',";
					}
					$start = strtotime("+1 month", $start);
				}
			?>
			]
        },
					<?php }
					?>
		],
		labels: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
						echo "'".$mesic[date("n",$start)]."',";
						$start = strtotime("+1 month", $start);
				} 
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
			text: 'Průběh prodeje typů paliv',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx = document.getElementById('new_models_with_concurency_per_month_all').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'line',
    data: {
        datasets: [
					<?php $i = 0;
					foreach($chartData["new_models_with_concurency_per_month_all"] as $key=>$dataset){ 
					?>
		{
			label:'<?php echo $key;?>',
			borderColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			backgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBackgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBorderColor: <?php echo "'".$chartColors[$i++]."'"; ?>,
			fill: false,
            data: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
					if(isset($dataset[date("Y",$start)]) && isset($dataset[date("Y",$start)][date("n",$start)])){
						echo "'".$dataset[date("Y",$start)][date("n",$start)]."',";
					} else {
						echo "'0',";
					}
					$start = strtotime("+1 month", $start);
				}
			?>
			]
        },
					<?php }
					?>
		],
		labels: [
			<?php
				$start = strtotime($_GET["odDate"]);
				$end = strtotime($_GET["doDate"]);
				while($start < $end){
						echo "'".$mesic[date("n",$start)]."',";
						$start = strtotime("+1 month", $start);
				} 
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
			text: 'Průběh prodeje s konkurenty',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx = document.getElementById('new_models_of_model_n_concurency').getContext('2d');
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
				echo "'".implode("','",array_values($chartData["new_models_of_model_n_concurency"]))."'";
			?>
			]
        }],
		labels: [
			<?php
				echo "'".implode("','",array_keys($chartData["new_models_of_model_n_concurency"]))."'";
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
			text: 'Nejprodávanější modely celkem',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx = document.getElementById('new_models_of_model_fuels').getContext('2d');
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
				echo "'".implode("','",array_values($chartData["new_models_of_model_fuels"]))."'";
			?>
			]
        }],
		labels: [
			<?php
				echo "'".implode("','",array_keys($chartData["new_models_of_model_fuels"]))."'";
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
			text: 'Nejprodávanější paliva',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
var ctx = document.getElementById('new_models_of_model_category_n_concurency').getContext('2d');
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
				echo "'".implode("','",array_values($chartData["new_models_of_model_category_n_concurency"]))."'";
			?>
			]
        }],
		labels: [
			<?php
				echo "'".implode("','",array_keys($chartData["new_models_of_model_category_n_concurency"]))."'";
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
			text: 'Nejprodávanější modely ve své třídě',
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


