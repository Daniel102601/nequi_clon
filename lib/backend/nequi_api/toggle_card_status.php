<?php
include 'db_config.php';
$usuario_id = $_POST['usuario_id'];
$nuevo_estado = $_POST['estado']; // 'activa' o 'congelada'

$query = "UPDATE tarjeta_digital SET estado = '$nuevo_estado' WHERE usuario_id = '$usuario_id'";

if (mysqli_query($con, $query)) {
    echo json_encode(["status" => "success", "message" => "Estado actualizado"]);
} else {
    echo json_encode(["status" => "error"]);
}
?>