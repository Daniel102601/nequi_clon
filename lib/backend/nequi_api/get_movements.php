<?php
include 'db_config.php';

if (isset($_GET['usuario_id'])) {
    $usuario_id = $_GET['usuario_id'];

    // Consultamos los movimientos ordenados por fecha descendente
    $query = "SELECT tipo, monto, descripcion, fecha 
              FROM movimientos 
              WHERE usuario_id = '$usuario_id' 
              ORDER BY fecha DESC";
              
    $res = mysqli_query($con, $query);
    $movimientos = [];

    while ($row = mysqli_fetch_assoc($res)) {
        $movimientos[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "data" => $movimientos
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Falta el ID del usuario"]);
}
?>