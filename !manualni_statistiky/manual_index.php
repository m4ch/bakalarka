<?php
 //     brandTypes: [ { id: 'new_brands_of_brand_n_concurency', title: 'Top nejprodávanější podobné značky' }, { id: 'new_brands_of_brand_fuels', title: 'Top nejprodávanější typy paliva' }, { id: 'new_brands_models_of_brand', title: 'Top nejprodávanější modely' }, { id: 'new_brands_groups_of_brand', title: 'Top nejprodávanější třídy značky' } ],

$types = ["new_brands_colors","new_brands_of_brand_n_concurency", "new_brands_of_brand_fuels", "new_brands_models_of_brand","new_brands_groups_of_brand"];
$perMonthTypes = ["new_brands_groups_of_brand_per_month_all","new_brands_with_concurency_per_month_all","new_brands_of_brand_fuels_per_month_all","new_brands_models_of_brand_per_month_all"];
$perYearTypes = ["new_brands_groups_of_brand_per_year_all","new_brands_of_brand_fuels_per_year_all","new_brands_with_concurency_per_year_all","new_brands_models_of_brand_per_year_all"];
$i = 0;
$chartColors = 	[ 
                'rgba(248, 197, 46, 1)',
                'rgba(203, 71, 85, 1)',
                'rgba(207, 92, 54, 1)',
                'rgba(102, 46, 155, 1)',
                'rgba(67, 188, 205, 1)',
			];
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
  parse_str(parse_url($_SERVER['REQUEST_URI'])['query'], $result);
if(isset($result)){
	$db = new mysqli("localhost","root","root","statistic1");
	$name = "";
	$i=0;
	foreach($result["object"] as $obj){
		$json = array( 
				"type" => $result["type"][$i],
				"month_from" => date("n",strtotime($result["odDate"])),
				"year_from" => date("Y",strtotime($result["odDate"])),
				"month_to" => date("n",strtotime($result["doDate"])),
				"year_to" => date("Y",strtotime($result["doDate"])),
				"lim" => 5,
				);
		if($result["type"][$i] == "model"){
			$json["model"] = $obj;
			$json["type"] = "new_models_per_month";
			$name = $json["model"];
		}
		if($result["type"][$i] == "brand"){
			$json["brand"] = $obj;
			$json["type"] = "new_brands_per_month";
			$name = $json["brand"];
		}
		if($result["type"][$i] == "model_palivo"){
			$json["model"] = $obj;
			$json["fuel"] = $result["fuel"][$i];
			$json["type"] = "new_models_of_model_fuels_per_month";
			$name = $json["model"] . " - " . $json["fuel"];
		}
		$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
			echo $db->error;
		foreach($res as $item){
			$chartData[$name][(int)$item["year"]][(int)$item["month"]] = $item["s"];
		}
		$db->next_result();
		$i++;
	}
}
?><!DOCTYPE html>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body>

<form id="formone" action="manual_index.php" method="GET" enctype="multipart/form-data">
	Zvolte datum od:
    <input type="date" name="odDate" id="odDateInput">
	Zvolte datum do:
    <input type="date" name="doDate" id="doDateInput">
	Vstup:
    <input type="text" name="input" id="input">
	!Typ:
    <input type="text" name="type" id="typeInput" value="">
	!palivo:
    <input type="text" name="fuel" id="fuelInput" value="">
    <input type="submit" value="Ukaz graf" name="submit">
</form>
</br>
<form id="formtwo" action="manual_index.php" method="GET" enctype="multipart/form-data">
	Vstup:
    <input type="text" name="object" id="input">
	!Typ:
    <input type="text" name="typ" id="typeInput" value="">
	!palivo:
    <input type="text" name="fue" id="fuelInput" value="">
    <input type="submit" value="Pridej k grafu" name="submit">
</form>

<script>
$("#formone").submit( function() {

document.location.assign( "http://localhost/!manualni_statistiky/manual_index.php?" + "odDate=" + $("input[name=odDate]").val() + "&doDate=" + $("input[name=doDate]").val() + "&object[]=" + $("input[name=input]").val() + "&type[]=" + $("input[name=type]").val() + "&fuel[]=" + $("input[name=fuel]").val() + "&");
return false;
});
</script>
<script>
$("#formtwo").submit( function() {

document.location.assign( document.location.href + "&object[]=" + $("input[name=object]").val() + "&type[]=" + $("input[name=typ]").val() + "&fuel[]=" + $("input[name=fue]").val() + "&");
return false;
});
</script>

<?php 

echo "Manualni statistika za obdobi ".$json["month_from"]."/".$json["year_from"]." - ".$json["month_to"]."/".$json["year_to"];
?>
<div style="width:530px;height:275px;">
<canvas id="manual_graph"></canvas>
</div>

<script>
var ctx = document.getElementById('manual_graph').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'line',
    data: {
        datasets: [ <?php 
			$i=0;
			foreach($chartData as $key=>$dataset) { ?>
		{
			label:'<?php echo $key;?>',
			borderColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			backgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBackgroundColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			pointBorderColor: <?php echo "'".$chartColors[$i]."'"; ?>,
			fill: false,
            data: [
			<?php
				$start = strtotime($result["odDate"]);
				$end = strtotime($result["doDate"]);
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
		<?php 
			$i++;
			}
					?>
		],
		labels: [
			<?php
				$start = strtotime($result["odDate"]);
				$end = strtotime($result["doDate"]);
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
			text: 'Průběh prodeje trid dane znacky',
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


