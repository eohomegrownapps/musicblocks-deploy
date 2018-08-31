<?php 
if ($_SERVER['HTTP_X_GITHUB_EVENT'] == 'push') {
	error_log("Executed command");
	echo "Executed";
	error_log(shell_exec('sudo /root/script.sh &'));
}
?>