<?php
$host = "localhost";
$user = "root"; // Usuario por defecto de XAMPP
$pass = "";     // Contraseña por defecto (vacía)
$db   = "clon_nequi";

$con = mysqli_connect($host, $user, $pass, $db);

if (!$con) {
    die("Error de conexión: " . mysqli_connect_error());
}
?>