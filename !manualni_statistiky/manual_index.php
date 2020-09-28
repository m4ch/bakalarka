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
  if(isset(parse_url($_SERVER['REQUEST_URI'])['query']))
    parse_str(parse_url($_SERVER['REQUEST_URI'])['query'], $result);
if(isset($result)){
	$db = new mysqli("statistic1.cukpr0ajmlis.eu-south-1.rds.amazonaws.com","root","bakalarkaheslo","statistic1");
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
		if($result["type"][$i] == "brand_group"){
			$json["brand"] = $obj;
			$json["group"] = $result["secondParam"][$i];
			$json["type"] = "new_brands_groups_of_brand_per_month";
			$name = $json["brand"] . " - " . $json["group"];
		}
		if($result["type"][$i] == "brand_fuel"){
			$json["brand"] = $obj;
			$json["fuel"] = $result["secondParam"][$i];
			$json["type"] = "new_brands_of_brand_fuels_per_month";
			$name = $json["brand"] . " - " . $json["fuel"];
		}
		$res = $db->query("CALL selectNewBrands('".json_encode($json,JSON_UNESCAPED_UNICODE)."')");
			echo $db->error;
		foreach($res as $item){
			$chartData[$name][(int)$item["year"]][(int)$item["month"]] = $item["s"];
		}
		$db->next_result();
		$i++;
	}
	
	$odDate = "01-".date("m",strtotime($_GET["odDate"]))."-".date("Y",strtotime($_GET["odDate"]));
	$doDate = "01-".date("m",strtotime($_GET["doDate"]))."-".date("Y",strtotime($_GET["doDate"]));
}
function printTable($titleArray, $labels, $data){
	echo "<table class=\"styled-table\">";
	echo "<tr>";
	foreach($titleArray as $title){
		echo "<th>".$title."</th>";
	}
	echo "</tr>";
	$row = 0;
	if(!array_key_exists($labels[$row], $data)){
		for($row; $row < count($labels);$row++){
			echo "<tr>";
			echo "<td>".$labels[$row]."</td>"."<td>".$data[$row]."</td>";
			echo "</tr>";
		}
	} else {
		for($row; $row < count($labels);$row++){
			echo "<tr>";
			echo "<td>".$labels[$row]."</td>";
			foreach($data[$labels[$row]] as $years){					
					echo "<td>".$years."</td>";
			}
			echo "</tr>";
		}
	}
	echo "</table>";
}
?><!DOCTYPE html>
<html><head>
<script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0"></script>
<script
  src="https://code.jquery.com/jquery-3.5.1.min.js"
  integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0="
  crossorigin="anonymous"></script>
<meta http-equiv="Content-type" content="text/json; charset=utf-8"/>
</head>
<body>
<style>
.styled-table {
    border-collapse: collapse;
    margin: 25px 0;
    font-size: 0.9em;
    font-family: sans-serif;
    min-width: 400px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
}
.styled-table thead tr {
	background-color: #009879;
	color: #ffffff;
	text-align: left;
	}
.styled-table th,
.styled-table td {
    padding: 12px 15px;
}
.styled-table tbody tr {
    border-bottom: 1px solid #dddddd;
}

.styled-table tbody tr:nth-of-type(even) {
    background-color: #f3f3f3;
}

.styled-table tbody tr:first-of-type {
    background-color: #f8c52e;
}
.styled-table tbody tr:hover {
    color: #4993FF;
}

</style>

<form id="formone" action="manual_index.php" method="GET" enctype="text/json">
	Zvolte datum od:
    <input type="date" name="odDate" id="odDateInput">
	Zvolte datum do:
    <input type="date" name="doDate" id="doDateInput">
	Vstup:(Skoda, Skoda Fabia, Fiat 500, Porsche cayenne)
    <input type="text" name="input" id="input">
	!Typ:(model, brand, model_palivo)
    <input type="text" name="type" id="typeInput" value="">
	!Druhy parameter:(Benzin, Nafta, Plugin BA, OA Paliva za mesic Mini)
    <input type="text" name="secondParam" id="fuelInput" value="">
    <input type="submit" value="Ukaz graf" name="submit">
</form>
</br></br></br>

<form id="formtwo" action="manual_index.php" method="GET" enctype="text/json">
	Vstup:
    <input type="text" name="object" id="input">
	!Typ:
    <input type="text" name="typ" id="typeInput" value="">
	!Druhy oarameter:
    <input type="text" name="secondPara" id="fuelInput" value="">
    <input type="submit" value="Pridej k grafu" name="submit">
</form>

<script>
$("#formone").submit( function() {

	document.location.assign( "https://selfty.000webhostapp.com/!manualni_statistiky/manual_index.php?" + "odDate=" + $("input[name=odDate]").val() + "&doDate=" + $("input[name=doDate]").val() + "&object[]=" + $("input[name=input]").val() + "&type[]=" + $("input[name=type]").val() + "&secondParam[]=" + $("input[name=secondParam]").val() + "&");
	return false;
});
$("#formtwo").submit( function() {

	document.location.assign( document.location.href + "&object[]=" + $("input[name=object]").val() + "&type[]=" + $("input[name=typ]").val() + "&secondParam[]=" + $("input[name=secondPara]").val() + "&");
	return false;
});
</script>

<?php 
if(isset($result))
	echo "Manualni statistika za obdobi ".$json["month_from"]."/".$json["year_from"]." - ".$json["month_to"]."/".$json["year_to"];
?>
<div style="width:530px;height:275px;">
<canvas id="manual_graph"></canvas>
</div>
<?php 
if(isset($result)){
	$start = strtotime($odDate);
	$end = strtotime("+1 month",strtotime($doDate));
	$months = ["Nazev"];
	while($start < $end){
		array_push($months, date("n",$start)."/".date("Y",$start));
		$start = strtotime("+1 month", $start);
	}
	$d = array();
	foreach($chartData as $key=>$dataset){
		$d[$key] = array();
		$start = strtotime($odDate);
		$end = strtotime("+1 month",strtotime($doDate));
		while($start < $end){
			
			if(isset($dataset[date("Y",$start)]) && isset($dataset[date("Y",$start)][date("n",$start)])){
				array_push($d[$key], $dataset[date("Y",$start)][date("n",$start)]);
			} else {
				array_push($d[$key], "0");
			}
			$start = strtotime("+1 month", $start);
		}
	}				
	printTable($months ,array_keys($chartData),$d);
}
?>

<script>
var ctx = document.getElementById('manual_graph').getContext('2d');
var chart = new Chart(ctx, {
	responsive: true,
    type: 'line',
    data: {
        datasets: [ <?php if(isset($chartData)){
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
		} }
					?>
		],
		labels: [
			<?php
			if(isset($chartData)){
				$start = strtotime($result["odDate"]);
				$end = strtotime($result["doDate"]);
				while($start < $end){
						echo "'".$mesic[date("n",$start)]."',";
						$start = strtotime("+1 month", $start);
				} 
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
			text: 'Manualni statistika',
			fontSize: 21,
			fontFamily: 'Nunito Sans'},
		tooltips: {
			bodyFontSize: 17,
			fontFamily: 'Nunito Sans'}
	}
});
</script>
<?php  ?>
</body>
</html>


