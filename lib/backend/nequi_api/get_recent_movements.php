<?php
include 'db_config.php';

if (isset($_GET['usuario_id'])) {
    $usuario_id = $_GET['usuario_id'];

    // Consultamos solo los últimos 4 movimientos
    $query = "SELECT tipo, monto, descripcion, fecha 
              FROM movimientos 
              WHERE usuario_id = '$usuario_id' 
              ORDER BY fecha DESC 
              LIMIT 4";
              
    $res = mysqli_query($con, $query);
    $movimientos = [];

    while ($row = mysqli_fetch_assoc($res)) {
        $movimientos[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "data" => $movimientos
    ]);
}
?>