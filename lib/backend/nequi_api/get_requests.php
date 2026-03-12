<?php
include 'db_config.php';

$usuario_id = $_GET['usuario_id'];

// Traemos las solicitudes pendientes y el nombre de quien pide la plata
$query = "SELECT s.*, u.nombre as solicitante_nombre, u.telefono as solicitante_tel 
          FROM solicitudes s 
          JOIN usuarios u ON s.solicitante_id = u.id 
          WHERE s.pagador_id = '$usuario_id' AND s.estado = 'pendiente'
          ORDER BY s.fecha DESC";

$res = mysqli_query($con, $query);
$solicitudes = [];

while($row = mysqli_fetch_assoc($res)) {
    $solicitudes[] = $row;
}

echo json_encode(["status" => "success", "data" => $solicitudes]);
?>