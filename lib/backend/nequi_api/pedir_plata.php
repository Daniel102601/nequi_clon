<?php
header('Content-Type: application/json');
include 'db_config.php';

// Validamos que lleguen los datos necesarios
if (!isset($_POST['solicitante_id']) || !isset($_POST['telefono_pagador'])) {
    echo json_encode(["status" => "error", "message" => "Datos incompletos"]);
    exit;
}

$solicitante_id = $_POST['solicitante_id'];
$telefono_pagador = $_POST['telefono_pagador'];
$monto = $_POST['monto'];
$mensaje = $_POST['mensaje'];

// 1. Buscamos al usuario que debe pagar (el destinatario)
$query_user = "SELECT id FROM usuarios WHERE telefono = '$telefono_pagador'";
$res_user = mysqli_query($con, $query_user);

if (mysqli_num_rows($res_user) > 0) {
    $user = mysqli_fetch_assoc($res_user);
    $pagador_id = $user['id'];

    // 2. Insertamos la solicitud en la tabla
    $query_insert = "INSERT INTO solicitudes (solicitante_id, pagador_id, monto, mensaje, estado) 
                    VALUES ('$solicitante_id', '$pagador_id', '$monto', '$mensaje', 'pendiente')";
    
    if (mysqli_query($con, $query_insert)) {
        echo json_encode(["status" => "success", "message" => "Solicitud enviada correctamente"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error al guardar en base de datos"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "El número destino no usa Nequi"]);
}
?>