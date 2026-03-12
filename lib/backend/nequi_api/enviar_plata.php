<?php
include 'db_config.php';

$emisor_id = $_POST['emisor_id'];
$telefono_receptor = $_POST['telefono_receptor'];
$monto = $_POST['monto'];

// 1. Verificar si el receptor existe
$query_receptor = "SELECT id FROM usuarios WHERE telefono = '$telefono_receptor'";
$res_receptor = mysqli_query($con, $query_receptor);

if (mysqli_num_rows($res_receptor) > 0) {
    $receptor = mysqli_fetch_assoc($res_receptor);
    $receptor_id = $receptor['id'];

    // 2. Verificar saldo del emisor
    $query_saldo = "SELECT saldo_disponible FROM usuarios WHERE id = '$emisor_id'";
    $res_saldo = mysqli_query($con, $query_saldo);
    $emisor = mysqli_fetch_assoc($res_saldo);

    if ($emisor['saldo_disponible'] >= $monto) {
        
        // INICIO DE TRANSACCIÓN (Para que sea seguro)
        mysqli_begin_transaction($con);

        try {
            // Restar al emisor
            mysqli_query($con, "UPDATE usuarios SET saldo_disponible = saldo_disponible - $monto WHERE id = '$emisor_id'");
            
            // Sumar al receptor
            mysqli_query($con, "UPDATE usuarios SET saldo_disponible = saldo_disponible + $monto WHERE id = '$receptor_id'");

            // Registrar el movimiento para el emisor
            mysqli_query($con, "INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES ('$emisor_id', 'envio', $monto, 'Envío a celular $telefono_receptor')");
            
            // Registrar el movimiento para el receptor
            mysqli_query($con, "INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES ('$receptor_id', 'recibo', $monto, 'Recibiste de un amigo')");

            mysqli_commit($con);
            echo json_encode(["status" => "success", "message" => "¡Plata enviada con éxito!"]);
            
        } catch (Exception $e) {
            mysqli_rollback($con);
            echo json_encode(["status" => "error", "message" => "Error procesando el envío"]);
        }

    } else {
        echo json_encode(["status" => "error", "message" => "Saldo insuficiente"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "El número de destino no existe en Nequi"]);
}
?>