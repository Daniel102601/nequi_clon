<?php
include 'db_config.php';

$nombre = $_POST['nombre'];
$telefono = $_POST['telefono'];
$pin = $_POST['pin'];

// Validar si el teléfono ya existe
$check = "SELECT * FROM usuarios WHERE telefono = '$telefono'";
$res_check = mysqli_query($con, $check);

if (mysqli_num_rows($res_check) > 0) {
    echo json_encode(["status" => "error", "message" => "El número ya está registrado"]);
} else {
    // Insertar nuevo usuario con saldo inicial de regalo (ej. 50.000)
    $query = "INSERT INTO usuarios (nombre, telefono, pin, saldo_disponible) 
              VALUES ('$nombre', '$telefono', '$pin', 50000.00)";
    
    if (mysqli_query($con, $query)) {
        echo json_encode(["status" => "success", "message" => "Usuario creado con éxito"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error al insertar"]);
    }
}
?>