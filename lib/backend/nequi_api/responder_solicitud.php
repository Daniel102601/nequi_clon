<?php
include 'db_config.php';

$solicitud_id = $_POST['solicitud_id'];
$accion = $_POST['accion']; // 'aceptada' o 'rechazada'

if ($accion == 'rechazada') {
    mysqli_query($con, "UPDATE solicitudes SET estado = 'rechazada' WHERE id = '$solicitud_id'");
    echo json_encode(["status" => "success", "message" => "Solicitud rechazada"]);
    exit;
}

// Lógica de Pago (Si es aceptada)
mysqli_begin_transaction($con);
try {
    // 1. Obtener datos de la solicitud
    $res = mysqli_query($con, "SELECT * FROM solicitudes WHERE id = '$solicitud_id'");
    $sol = mysqli_fetch_assoc($res);
    $monto = $sol['monto'];
    $pagador_id = $sol['pagador_id'];
    $solicitante_id = $sol['solicitante_id'];

    // 2. Verificar saldo de quien paga
    $res_p = mysqli_query($con, "SELECT saldo_disponible FROM usuarios WHERE id = '$pagador_id'");
    $pagador = mysqli_fetch_assoc($res_p);

    if ($pagador['saldo_disponible'] >= $monto) {
        // Descontar, Sumar, Registrar Movimientos y Actualizar Solicitud
        mysqli_query($con, "UPDATE usuarios SET saldo_disponible = saldo_disponible - $monto WHERE id = '$pagador_id'");
        mysqli_query($con, "UPDATE usuarios SET saldo_disponible = saldo_disponible + $monto WHERE id = '$solicitante_id'");
        mysqli_query($con, "INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES ('$pagador_id', 'pago', $monto, 'Pago de solicitud')");
        mysqli_query($con, "INSERT INTO movimientos (usuario_id, tipo, monto, descripcion) VALUES ('$solicitante_id', 'recibo', $monto, 'Cobro recibido')");
        mysqli_query($con, "UPDATE solicitudes SET estado = 'aceptada' WHERE id = '$solicitud_id'");

        mysqli_commit($con);
        echo json_encode(["status" => "success", "message" => "¡Pago realizado!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Saldo insuficiente"]);
    }
} catch (Exception $e) {
    mysqli_rollback($con);
    echo json_encode(["status" => "error", "message" => "Error en el proceso"]);
}
?>