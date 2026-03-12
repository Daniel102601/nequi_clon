<?php
include 'db_config.php';

// Verificamos que el ID llegue por la URL
if (isset($_GET['usuario_id'])) {
    $usuario_id = $_GET['usuario_id'];

    // Agregamos 'saldo_disponible' a la consulta
    $query = "SELECT nombre, telefono, saldo_disponible FROM usuarios WHERE id = '$usuario_id'";
    $res = mysqli_query($con, $query);

    if ($res && mysqli_num_rows($res) > 0) {
        $user = mysqli_fetch_assoc($res);
        
        echo json_encode([
            "status" => "success",
            "nombre" => $user['nombre'],
            "telefono" => $user['telefono'],
            "saldo" => $user['saldo_disponible'] // <-- Nuevo campo enviado a Flutter
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Usuario no encontrado"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Falta el parámetro usuario_id"]);
}
?>