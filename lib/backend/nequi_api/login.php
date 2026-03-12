<?php
include 'db_config.php';

$telefono = $_POST['telefono'];
$pin = $_POST['pin'];

// Buscamos al usuario por su teléfono
$query = "SELECT * FROM usuarios WHERE telefono = '$telefono'";
$res = mysqli_query($con, $query);

if (mysqli_num_rows($res) > 0) {
    $user = mysqli_fetch_assoc($res);
    
    // Verificamos el PIN (aquí podrías usar password_verify si lo hasheas)
    if ($user['pin'] == $pin) {
        echo json_encode([
            "status" => "success",
            "message" => "Bienvenido",
            "data" => [
                "id" => $user['id'],
                "nombre" => $user['nombre'],
                "saldo" => $user['saldo_disponible']
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "PIN incorrecto"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Usuario no encontrado"]);
}
?>