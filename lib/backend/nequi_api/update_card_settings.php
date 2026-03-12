<?php
include 'db_config.php';
header('Content-Type: application/json');

$usuario_id = $_POST['usuario_id'];
$accion = $_POST['accion']; // 'pin', 'limite' o 'cancelar'

if ($accion == 'pin') {
    $nuevo_pin = $_POST['valor'];
    $query = "UPDATE tarjeta_digital SET pin = '$nuevo_pin' WHERE usuario_id = '$usuario_id'";
} else if ($accion == 'limite') {
    $nuevo_limite = $_POST['valor'];
    $query = "UPDATE tarjeta_digital SET limite_diario = '$nuevo_limite' WHERE usuario_id = '$usuario_id'";
} else if ($accion == 'cancelar') {
    $query = "DELETE FROM tarjeta_digital WHERE usuario_id = '$usuario_id'";
}

if (mysqli_query($con, $query)) {
    echo json_encode(["status" => "success", "message" => "Actualización exitosa"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error al actualizar"]);
}
?>