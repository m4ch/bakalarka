
<?php
interface IData{
	public function isNew($month,$year): bool;
	public function insertBrandsJson($brands): array;
	public function insertModelGroupJson($models): array;
	public function insertColoursJson($colours): array;
	public function insertColoursStatisticJson($colours): bool;
	public function insertFuelTypesJson($fuels): array;
	public function insertOldStatisticJson($oldBrands): bool;
	public function insertGroupsJson($groups): array;
	public function insertModelGroupStatisticsJson($stat): bool ;

}

class SimpleSql implements IData{
	 var $connection;
	 var $error;
	function __construct($address, $login, $passw, $database){
		$this->connection = new mysqli($address, $login, $passw, $database);
		if(!$this->connection){
			echo $this->connection->error."</br>";
		}
	}
	
	function __destruct(){
		$this->connection->close();

	}
	
	public function isNew($month, $year) : bool {
		$res = $this->connection->query("SELECT 1 FROM st_model_statistics WHERE st_model_statistics_date_month = ".$month." AND st_model_statistics_date_year = ".$year);
			if($res->num_rows > 0){
				return true;
			}else{
				return false;
			}
	}
	
	public function insertModelGroupJson($models): array {
		$res = $this->connection->query("SELECT insertModelGroupJson('".$models."') as 'NEW'");
		if($res){
			$ob = $res->fetch_object();
			$j = json_decode($ob->NEW,true);
			if($j) return $j;
			else return array();
		}
		echo $this->connection->error."</br>";
		return array();
	}
	
	public function insertModelGroupStatisticsJson($stat): bool {
		$res = $this->connection->query("CALL insertModelGroupStatisticsJson('".$stat."')");
		if($res){
			return true;
		}
		echo $this->connection->error."</br>";
		return false;
	}
	
	public function insertBrandsJson($brands): array {
		$res = $this->connection->query("SELECT insertBrandsJson('".$brands."') as 'NEW'");
		if($res){
			$ob = $res->fetch_object();
			$j = json_decode($ob->NEW,true);
			if($j) return $j;
			else return array();
		}
		echo $this->connection->error."</br>";
		return array();
	}
	
	public function insertGroupsJson($groups): array {
		$res = $this->connection->query("SELECT insertGroupsJson('".$groups."') as 'NEW'");
		if($res){
			$ob = $res->fetch_object();
			$j = json_decode($ob->NEW,true);
			if($j) return $j;
			else return array();
		}
		echo $this->connection->error."</br>";
		return array();
	}
	
	public function insertColoursJson($colours): array {
		$res = $this->connection->query("SELECT insertColoursJson('".$colours."') as 'NEW'");
		if($res){
			$ob = $res->fetch_object();
			$j = json_decode($ob->NEW,true);
			if($j) return $j;
			else return array();
		}
		echo $this->connection->error."</br>";
		return array();
	}
	
	public function insertColoursStatisticJson($colours): bool {
		$res = $this->connection->query("CALL insertColoursStatisticJson('".$colours."')");
		if($res){
			return true;
		}
		echo $this->connection->error."</br>";
		return false;
	}

	public function insertFuelTypesJson($types): array {
		$res = $this->connection->query("SELECT insertFuelTypesJson('".$types."') as 'NEW'");
		if($res){
			$ob = $res->fetch_object();
			$j = json_decode($ob->NEW,true);
			if($j) return $j;
			else return array();
		}
		echo $this->connection->error."</br>";
		return array();
	}
	
	public function insertOldStatisticJson($oldBrands): bool {
		$res = $this->connection->query("CALL insertOldStatisticJson('".$oldBrands."')");
		if($res){
			return true;
		}
		echo $this->connection->error."</br>";
		return false;
	}
	
	
}
?>