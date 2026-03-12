<?php
include 'db_config.php';
header('Content-Type: application/json');

$usuario_id = $_GET['usuario_id'];

// 1. Buscar si ya existe la tarjeta
$query = "SELECT * FROM tarjeta_digital WHERE usuario_id = '$usuario_id'";
$res = mysqli_query($con, $query);

if (mysqli_num_rows($res) > 0) {
    $card = mysqli_fetch_assoc($res);
    echo json_encode(["status" => "success", "data" => $card]);
} else {
    // 2. Si no existe, generamos una nueva (Simulando la solicitud inicial)
    $num = "4123 " . rand(1000, 9999) . " " . rand(1000, 9999) . " " . rand(1000, 9999);
    $cvv = rand(100, 999);
    $exp = "12/30";
    
    $insert = "INSERT INTO tarjeta_digital (usuario_id, numero_tarjeta, cvv, fecha_exp, estado) 
               VALUES ('$usuario_id', '$num', '$cvv', '$exp', 'activa')";
    
    if (mysqli_query($con, $insert)) {
        $res_new = mysqli_query($con, "SELECT * FROM tarjeta_digital WHERE usuario_id = '$usuario_id'");
        $card_new = mysqli_fetch_assoc($res_new);
        echo json_encode(["status" => "success", "data" => $card_new]);
    } else {
        echo json_encode(["status" => "error", "message" => "No se pudo crear la tarjeta"]);
    }
}
?>