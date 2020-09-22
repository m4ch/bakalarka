
<!DOCTYPE html>
<html><head><script src="https://cdn.jsdelivr.net/npm/chart.js@2.8.0">
</script></head>
<body>

<form action="upload_generic_Json.php" method="post" enctype="multipart/form-data">
    Select *.xls to upload:
    <input type="file" name="fileToUpload" id="fileToUpload">
	<input type="checkbox" value="false" name="debug" id="debug">
    <input type="submit" value="Upload *.xls" name="submit">
</form>
</br>
<form action="index_final_json.php" method="get" enctype="multipart/form-data">
    Select type:
    <input type="text" name="type" id="type">
	Select time:
	    <input type="text" name="time" id="time">
	Select limit:
	    <input type="number" name="lim" id="lim">
    <input type="submit" value="Set" name="submit">
</form>

</body>
</html>

