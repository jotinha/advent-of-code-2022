<?php

$data = trim(file_get_contents("test"));
$moves = str_split($data);
var_dump($moves);
