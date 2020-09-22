<style>
table {
  border-collapse: collapse;
  margin: 10px;
}
 th {
  background: #E3B23C;
}

th, td {
  border: 1px solid #E3B23C;
  padding: 8px;
}

tr:nth-child(even) {
  background: #F9E784;
}

tr:hover {
  background: #C47335;
}
</style>
<?php
require 'vendor/autoload.php';
include_once('SimpleSql.php');

	$db = new SimpleSql("localhost","root","root","statistic1");
	$target_dir = "uploads/";
	$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);
	move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file);
	$importer = new carStatisticImporter($db, null);
	$importer->load($target_file, null);
	$importer->import();

class carStatisticImporter{
	
	private $spreadsheet;
	private $IData;
	private $year;
	private $month;
	private	$sheetsBrands;
	private	$sheetsModels;
	private	$sheetsTypes;
	private	$sheetFuel;
	private	$sheetColorTypes;
	private	$sheetOldBrands;
	private $brands;
	private $FuelTypes;
	private $settings;
	private $tmp_json;
	public $debug = false;

	function __construct($db , $fullPath){
		$this->IData = $db;
		if($fullPath)
			$this->load($fullPath, $db);
	}
	
	function load($fullPath, $db){
		if($db)
			$this->IData = $db;
		set_time_limit(30000);
		$this->debug = isset($_POST["debug"]);
	// Nacteni settings.Json do $this->settings

		$this->settings = json_decode(file_get_contents('settings.json'),true);

	/*	
	*	ziskani data z nazvu dokumentu
	*	prvni 4 char = rok
	*	od '-' po '.' = mesic
	*	pripojeni k db + kontrola, jestli byl sheet zpracovan
	*/

		preg_match_all("/[0-9][0-9]*/", $fullPath, $date);
		$this->year = intval($date[0][0]);
		$this->month = intval($date[0][1]);
		$res = $this->IData->isNew($this->month, $this->year);
		if($res){
			echo "Tabulky jsou jiz zpracovany.</br>";
			exit;
		}
		$this->sheetsBrands = $this->settings["sheetsBrands"];
		$this->sheetsModels = $this->settings["sheetsModels"];
		$this->sheetsTypes = $this->settings["sheetsTypes"];
		$this->sheetFuel = $this->settings["sheetFuel"];
		$this->sheetColorTypes = $this->settings["sheetColorTypes"];
		$this->sheetOldBrands = $this->settings["sheetOldBrands"];

		$reader = new \PhpOffice\PhpSpreadsheet\Reader\Xls();
		$reader->setReadDataOnly(false);
		$sheets = array_merge($this->sheetsBrands,$this->sheetsModels, $this->sheetsTypes, $this->sheetFuel,$this->sheetColorTypes, $this->sheetOldBrands);
		$reader->setLoadSheetsOnly($sheets);
		$this->spreadsheet = $reader->load($fullPath);
	}
	
	function import(){
		$brands = $this->loadBrands();
		$newBrands = $this->storeBrands($brands);
		$groups = $this->loadGroups();
		$newGroups = $this->storeGroups($groups);
		$colors = $this->loadColors();
		$newColors = $this->storeColors($colors);
		$this->storeColorsStatistic();
		$fuelTypes = $this->loadFuelTypes();
		$newFuelTypes = $this->storeFuelTypes($fuelTypes);
		$this->loadAndStoreOldBrands();
		$newModels = $this->loadAndStoreModels();
		$this->loadAndStoreModelStatistics();
	}

	/*
	*
	*	Nalezeni vsech znacek v $this->sheetsBrands	
	*
	*/

	function loadBrands(): array{
		$brands = array();
		foreach($this->sheetsBrands as $sheetName){
			$actualSheet = $this->spreadsheet->getSheetByName($sheetName);
			if(!$actualSheet) {
				echo $sheetName." : Chyba, nenalezen</br>";
				continue;
			}
			$iterator = 1;
			while(!in_array($actualSheet->getCell('A'.$iterator)->getValue(), $this->settings["ModelOrBrandList"]))
			{
				$iterator++;
			}
			$iterator++;
			while($actualSheet->getCell('A'.$iterator)->getValue() == '' or $actualSheet->getStyle('A'.$iterator)->getFill()->getStartColor()->getRGB() == "BBDDFF" or in_array($actualSheet->getCell('A'.$iterator)->getValue(),$this->settings["ModelOrBrandSkipList"])){$iterator++;}
			while($actualSheet->getCell('A'.$iterator)->getValue() != '')
			{
				if($actualSheet->getCell('A'.$iterator)->getValue() == ' ') $iterator++;
				$value = $actualSheet->getCell('A'.$iterator)->getValue();		
				if(!in_array($value, $brands, true)){
				array_push($brands,$value);
				}
				$iterator += 1;
			}
		}
		$this->brands = $brands;
		return $brands;
	}

	function storeBrands($brands): array{
		$newBrands = array();
		$res = $this->IData->insertBrandsJson(json_encode($brands, JSON_UNESCAPED_UNICODE));
			if($this->debug) echo "<table><tr><th>Kategorie</th><th>Vysledek</th></tr>";
		foreach($brands as $brand){

			if(!in_array($brand, $res)){
				if($this->debug) echo "<tr><td>".$brand."</td><td>OK</td></tr>";
			}
			else{
				if($this->debug) echo "<tr><td>".$brand."</td><td>Vlozeno</td></tr>";
				array_push($newBrands, $brand);
			}
		}
		if($this->debug) echo "</table>";
		if($res){
			echo "<table><tr><th>Nove znacky</th></tr>";
			foreach($newBrands as $new){
				echo "<tr><td>".$new."</td></tr>";
			}
			echo "</table>";
		}
		return $newBrands;
	}

	/*
	*
	*	Nalezeni vsech Skupin v $sheetsModels
	*
	*/
	function loadGroups(): array{
		return $this->sheetsModels;
	}
	
	function storeGroups($groups): array{
		$newGroups = array();
		if($this->debug) echo "<table><tr><th>Kategorie</th><th>Vysledek</th></tr>";
		$res = $this->IData->insertGroupsJson(json_encode($groups, JSON_UNESCAPED_UNICODE));
		foreach($groups as $sheetName){
			if(!in_array($sheetName, $res)){
				if($this->debug) echo "<tr><td>".$sheetName."</td><td>OK</td></tr>";
			}
			else{
				if($this->debug) echo "<tr><td>".$sheetName."</td><td>Vlozeno</td></tr>";
				array_push($newGroups, $sheetName);
			}
		}
		if($res){
			echo "<table><tr><th>Nove kategorie</th></tr>";
			foreach($newGroups as $new){
				echo "<tr><td>".$new."</td></tr>";
			}
			echo "</table>";
		}
		return $newGroups;
	}
	/*
	*
	*	Nalezeni vsech barev v $this->sheetColorTypes
	*
	*/
	
	function loadColors(): array{
		$finalColorBrand = array();
		$colorTypes = array();
		foreach($this->sheetColorTypes as $sheetName){
			$colorBrand = array();
			$actualSheet = $this->spreadsheet->getSheetByName($sheetName);
			if(!$actualSheet) {
				echo $sheetName." : Chyba, nenalezen</br>";
				continue;
			}
			$iterator = 1;
			while(!in_array($actualSheet->getCell('A'.$iterator)->getValue() ,$this->settings["ModelOrBrandList"]))
			{
				$iterator++;
			}
			$iterator++;
			while($actualSheet->getCell('A'.$iterator)->getValue() == '' or in_array($actualSheet->getCell('A'.$iterator)->getValue(), $this->settings["ModelOrBrandSkipList"]))$iterator++;
			$iteratorEnd = $iterator;
			while($actualSheet->getCell('A'.$iteratorEnd)->getValue() != '' ) {
				$iteratorEnd++;
			}
			$iteratorEnd--;
			$names = $actualSheet->rangeToArray('A'.$iterator.':A'.$iteratorEnd,NULL,FALSE,FALSE,FALSE);
			$colIterator = 'C';
			while(!in_array($actualSheet->getCell($colIterator.'3')->getValue(),$this->settings["ColoursEndList"]))
			{		
				if(($actualSheet->getCell($colIterator.'3')->getValue() != '')){
					
					$colorBrand[$actualSheet->getCell($colIterator.'3')->getValue()] = $actualSheet->rangeToArray($colIterator.$iterator.':'.$colIterator.$iteratorEnd,NULL,FALSE,FALSE,FALSE);
				}
				$colIterator++;
			}		
			$colIterator++;
			$colorTypes = array_merge($colorTypes,array_keys($colorBrand));
			if($this->debug) echo "<table> <tr><th>Znacka</th><th>Barva</th><th>Pocet</th></tr>";
			$coun = 0;
			$finalColorBrand[$coun++] = $this->year;
			$finalColorBrand[$coun++] = $this->month;
			foreach($colorBrand as $key => $value){
				foreach($value as $k => $v){
					if($v[0] == '-') continue;
						if($this->debug) echo "<tr>";
						$finalColorBrand[$coun++] = $names[$k][0];
						$finalColorBrand[$coun++] = $key;
						if($v[0] == null)	$finalColorBrand[$coun++]= 0;
						else	$finalColorBrand[$coun++]= $v[0];	
						if($this->debug) echo "<td>".$names[$k][0]."</td><td>".$key."</td><td>".$v[0]."</td></tr>";				
				}
			}
			if($this->debug) echo "</table>";
		}
		$this->tmp_json = $finalColorBrand;
		return $colorTypes;
	}
	
	function storeColors($colorTypes):array {
		$newColors = array();
		if($this->tmp_json){	
			$res = $this->IData->insertColoursJson(json_encode($colorTypes, JSON_UNESCAPED_UNICODE));
			if($this->debug) echo "<table> <tr><th>Barva</th><th>Vysledek</th></tr>";
			foreach($colorTypes as $c){
				if(!in_array($c, $res)){
				if($this->debug) echo "<td>".$c."</td><td>OK</td></tr>";
				}
				else{
				if($this->debug) echo "<td>".$c."</td><td>Vlozena</td></tr>";
				array_push($newColors, $c);
				}
			}
			if($this->debug) echo "</table>";
			if($res){
				echo "<table><tr><th>Nove Barvy</th></tr>";
				foreach($newColors as $new){
					echo "<tr><td>".$new."</td></tr>";
				}
				echo "</table>";
			}
		}
		return $newColors;
	}
	
	function storeColorsStatistic(){
		if($this->IData->insertColoursStatisticJson(json_encode($this->tmp_json, JSON_UNESCAPED_UNICODE)))
			echo "Statistika znacek a barev vlozena</br>";
		else
			echo "insertColoursStatisticJson Error: ".$this->IData->connection->error."</br>";
	}
	

	/*
	*
	*	Nalezeni vsech typu paliva v $this->sheetFuel
	*
	*/
	
	function loadFuelTypes(): array{
		$FuelTypes = array();
		foreach($this->sheetFuel as $sheetName){
			$actualSheet = $this->spreadsheet->getSheetByName($sheetName);
			if(!$actualSheet) {
				echo $sheetName." : Chyba, nenalezen</br>";
				continue;
			}
			$iterator = 'C';
			$iteratorF = 1;
			while(!in_array($actualSheet->getCell($iterator.$iteratorF)->getValue(), $this->settings["FuelList"]))
			{		
				++$iteratorF;	
				$iterator = 'C';
				while($iterator < $this->settings["MaxColIndex"] and !in_array($actualSheet->getCell($iterator.$iteratorF)->getValue(), $this->settings["FuelList"])){
					$iterator++;
				}
			}
			$iteratorEnd = $iterator;
			while(!in_array($actualSheet->getCell($iteratorEnd.$iteratorF)->getValue(), $this->settings["FuelListEnd"]) ){$iteratorEnd++;}
			$FuelTypes = array_merge($FuelTypes, array_filter($actualSheet->rangeToArray($iterator.$iteratorF.':'.$iteratorEnd.$iteratorF,NULL,FALSE,FALSE,FALSE)[0], function($value) {return !is_null($value);}));
		}
		$this->FuelTypes = $FuelTypes;
		return $FuelTypes;
	}
	
	function storeFuelTypes($FuelTypes): array{
		$newFuel = array();
		$res = $this->IData->insertFuelTypesJson(json_encode($FuelTypes, JSON_UNESCAPED_UNICODE));
		if($this->debug) echo "<table> <tr><th>Typ paliva</th><th>Vysledek</th></tr>";
		foreach($FuelTypes as $f){
			if(!in_array($f, $res)){
			if($this->debug) echo "<td>".$f."</td><td>OK</td></tr>";
			}
			else{
			if($this->debug) echo "<td>".$f."</td><td>Vlozeno</td></tr>";
			array_push($newFuel, $f);
			}
		}
		if($this->debug) echo "</table>";
		if($res){
			echo "<table><tr><th>Nove typy paliva</th></tr>";
			foreach($newFuel as $new){
				echo "<tr><td>".$new."</td></tr>";
			}
			echo "</table>";
		}
		return $newFuel;
	}
	
	/*
	*
	*	Nalezeni vsech ojetin v $this->sheetOldBrands
	*	vcetne vlozeni do databaze $this->IData->insertOldStatisticJson
	*  
	*/
	
	function loadAndStoreOldBrands(){
		$oldBrands = array();
		foreach($this->sheetOldBrands as $sheetName){
			
			$actualSheet = $this->spreadsheet->getSheetByName($sheetName);
			$oldBrands = [];
			if(!$actualSheet) {
				echo $sheetName." : Chyba, nenalezen</br>";
				continue;
			}
			$iteratorStart = 1;
			while(!in_array($actualSheet->getCell('A'.$iteratorStart)->getValue(), $this->settings["ModelOrBrandList"]))
			{
				$iteratorStart++;
			}
			$iteratorStart++;
			while($actualSheet->getCell('A'.$iteratorStart)->getValue() == '' ){
				$iteratorStart++;
			}
			$iteratorEnd = $iteratorStart;
			while($actualSheet->getCell('A'.$iteratorEnd)->getValue() != '' ) {
				$iteratorEnd++;
			}
			$iteratorEnd--;
			$iteratorF = 1;
			$iterator = 'C';
			while(!in_array($actualSheet->getCell($iterator.$iteratorF)->getValue(), $this->settings["OldBrandsAgeList"]))
			{
				$iteratorF++;	
				$iterator = 'C';
				while($iterator < $this->settings["MaxColIndex"] && !in_array($actualSheet->getCell($iterator.$iteratorF)->getValue(), $this->settings["OldBrandsAgeList"])){
					$iterator++;
				}
			}
			$names = $actualSheet->rangeToArray('A'.$iteratorStart.':A'.$iteratorEnd,NULL,FALSE,FALSE,FALSE);
			$iteratorEndBrands = $iterator;
			while(!($actualSheet->getCell($iteratorEndBrands++.$iteratorF)->getValue() == '' and $actualSheet->getCell($iteratorEndBrands.$iteratorF)->getValue() == ''))
			{
				if($actualSheet->getCell($iteratorEndBrands.$iteratorF)->getValue() != ''){
					$oldBrands[$actualSheet->getCell($iteratorEndBrands.$iteratorF)->getValue()] = $actualSheet->rangeToArray($iteratorEndBrands.$iteratorStart.':'.$iteratorEndBrands.$iteratorEnd,NULL,FALSE,FALSE,FALSE);
				}
			}
			$coun = 0;
			//$oldBrands[$actualSheet->getCell($iteratorEndBrands.$iteratorF)->getValue()] = $actualSheet->rangeToArray($iteratorEndBrands.$iteratorStart.':'.$iteratorEndBrands.$iteratorEnd,NULL,FALSE,FALSE,FALSE);
			if($this->debug) echo "<table><tr><th>Znacka</th><th>Stari</th><th>Pocet</th><th>Rok</th><th>Mesic</th></tr>";
			$finalOldBrands[$coun++] = $this->year;
			$finalOldBrands[$coun++] = $this->month;
			foreach($oldBrands as $key => $value){
				preg_match('/[0-9][0-9]*/',$key, $age);
				
				if(preg_match("/Nad*/i",$key)) $age[0]++;
				foreach($value as $k => $v){
					if($v[0] == '-') continue;
					$finalOldBrands[$coun++] = $names[$k][0];
					$finalOldBrands[$coun++] = $age[0];
					$finalOldBrands[$coun++] = $v[0];
					if($this->debug) echo "<tr><td>".$names[$k][0]."</td><td>".$age[0]."</td><td>".$v[0]."</td><td>".$this->year."</td><td>".$this->month."</td></tr>";			
				}
			}
			if($this->debug) echo "</table>";
			if($this->IData->insertOldStatisticJson(json_encode($finalOldBrands, JSON_UNESCAPED_UNICODE)))
				echo "Statistika ojetin vlozena</br>";
			else
				echo "insertOldStatisticJson Error: ".$this->IData->connection->error."</br>";
		}
	}

	/*
	*
	*	Nalezeni vsech modelu v $this->sheetsModels
	*	vcetne vlozeni do db $this->IData->insertModelGroupJson
	*	vraci nove modely
	*
	*/
	
	function loadAndStoreModels(): array{
		$finalnewModels = array();
		foreach($this->sheetsModels as $sheetName){
			$json = array();
			$actualSheet = $this->spreadsheet->getSheetByName($sheetName);
			if(!$actualSheet){
				echo $sheetName.": Chyba, nenalezen</br>";
				continue;
			}
			$iterator = 1;
			array_push($json, $sheetName);
			while(!in_array($actualSheet->getCell('A'.$iterator)->getValue(), $this->settings["ModelOrBrandList"]))
			{
				$iterator++;
			}
			$iterator++;
			while($actualSheet->getCell('A'.$iterator)->getValue() == ''){
				$iterator++;
			}
			if($this->debug) echo "<table><tr><th>Model</th><th>Znacka</th><th>Kategorie</th></tr>";
			while($actualSheet->getCell('A'.$iterator)->getValue() != '')
			{
			preg_match("/\p{Lu}*\p{Ll}* *-*(\p{Lu}\p{Ll}\p{Ll}*)*/u",$actualSheet->getCell('A'.$iterator)->getValue(), $bb);
				$bra = $bb[0];
				$next = true;
				foreach($this->settings["ExtraPattern"] as $pat){
						if(preg_match("/{$pat[0]}/",$actualSheet->getCell('A'.$iterator)->getValue())){
												array_push($json, $actualSheet->getCell('A'.$iterator)->getValue(), $pat[0]);
							$next = false;
							$iterator++;
						}
					}
				if(!$next) continue;
				foreach($this->brands as $b){ // naplneni modelu do db
					if(preg_match("/{$b}/i", $actualSheet->getCell('A'.$iterator)->getValue())){
						$bra = $b;
						break;
					}
				}
				array_push($json, $actualSheet->getCell('A'.$iterator)->getValue(), $bra);
				if($this->debug) echo "<tr><td>".$actualSheet->getCell('A'.$iterator)->getValue()."</td><td>".ucfirst($bra)."</td><td>".$sheetName."</td></tr>";
				$iterator++;
			}
			$res = $this->IData->insertModelGroupJson(json_encode($json, JSON_UNESCAPED_UNICODE));
			$newModels = $res;
			if($this->debug) echo "</table>";
			if($res){
				echo "<table><tr><th>Nove modely</th><th>Skupina</th></tr>";
				foreach($res as $key => $new){
					if($key == 0) continue;
					echo "<tr><td>".$new."</td><td>".$sheetName."</td></tr>";
				}
				echo "</table>";
			}
			array_merge($finalnewModels, $newModels);
		}
		return $finalnewModels;
	}


	/*
	*
	*	Naplneni $modeFuel2DArray [typ paliva][ID] = pocet  === $names[ID]
	*	pocet '-' == 0
	*	nacte a vlozi statistiku s modely $this->IData->insertModelGroupStatisticsJson
	*
	*/
	
	function loadAndStoreModelStatistics(){
		$modelFuel2DArray = array();
		foreach($this->sheetsModels as $sheetName){
			
			$modelFuel2DArray = [];
			$actualSheet = $this->spreadsheet->getSheetByName($sheetName);
			if(!$actualSheet){ 
				echo $sheetName.": Chyba, nenalezen</br>";
				continue;
			}
			$json = array();
			$iterator = 1;
			while(!in_array($actualSheet->getCell('A'.$iterator)->getValue(), $this->settings["ModelOrBrandList"]))
			{
				$iterator++;
			}
			$iterator++;
			while($actualSheet->getCell('A'.$iterator)->getValue() == ''){
				$iterator++;
				
			}
			$iteratorEnd = $iterator;
			while($actualSheet->getCell('A'.$iteratorEnd)->getValue() != '')
			{
				$iteratorEnd++;
			}
			$iteratorEnd--;
			$colIterator = 'C';
			$iteratorF = 1;
			while(!in_array($actualSheet->getCell($colIterator.$iteratorF)->getValue(), $this->settings["FuelList"]))
			{	
				++$iteratorF;	
				$colIterator = 'C';
				while($colIterator < $this->settings["MaxColIndex"] and !in_array($actualSheet->getCell($colIterator.$iteratorF)->getValue(), $this->settings["FuelList"])){
					$colIterator++;
				}
				
			}
			$iteratorEndFuel = $colIterator;
			while(!($actualSheet->getCell($iteratorEndFuel++.$iteratorF)->getValue() == '' and $actualSheet->getCell($iteratorEndFuel.$iteratorF)->getValue() == ''))
			{	
				if(in_array($actualSheet->getCell($colIterator.$iteratorF)->getValue(), $this->FuelTypes)){
					
					$modelFuel2DArray[$actualSheet->getCell($colIterator.$iteratorF)->getValue()] = $actualSheet->rangeToArray($colIterator.$iterator.':'.$colIterator.$iteratorEnd,NULL,FALSE,FALSE,FALSE);
				}		
				++$colIterator;
			}
			array_push($json, $this->year, $this->month, $sheetName);
			$names = $actualSheet->rangeToArray('A'.$iterator.':A'.$iteratorEnd,NULL,FALSE,FALSE,FALSE);
			if($this->debug) echo "<table><tr><th>Model</th><th>Kategorie</th><th>Pocet</th><th>Palivo</th><th>Rok</th><th>Mesic</th></tr>";
			foreach($modelFuel2DArray as $key => $statArray){
				foreach($statArray as $auto => $pocet){
					
					if($pocet[0] == '-'){continue;}			
					array_push($json, $names[$auto][0], $key, $pocet[0]);
					if($this->debug) echo "<tr><td>".$names[$auto][0] . "</td><td>" . $sheetName. "</td><td>".$pocet[0]."</td><td>".$key."</td><td>".$this->year."</td><td>".$this->month."</td></tr>";
				}
			}
			if($this->debug) echo "</table>";
			if($this->IData->insertModelGroupStatisticsJson(json_encode($json, JSON_UNESCAPED_UNICODE)))
				echo $sheetName." statistika vlozena.</br>";
			else
				echo $sheetName." Chyba.</br>";
		}
	}
}
?>
