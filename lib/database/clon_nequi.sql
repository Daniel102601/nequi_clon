-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-03-2026 a las 08:13:10
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `clon_nequi`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos`
--

CREATE TABLE `movimientos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `tipo` enum('envio','recibo','recarga','pago') NOT NULL,
  `monto` decimal(15,2) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `movimientos`
--

INSERT INTO `movimientos` (`id`, `usuario_id`, `tipo`, `monto`, `descripcion`, `fecha`) VALUES
(1, 2, 'envio', 20000.00, 'Envío a celular 3016872575', '2026-03-12 05:40:04'),
(2, 1, 'recibo', 20000.00, 'Recibiste de un amigo', '2026-03-12 05:40:04'),
(3, 1, 'envio', 15000.00, 'Envío a celular 3042727296', '2026-03-12 05:44:47'),
(4, 2, 'recibo', 15000.00, 'Recibiste de un amigo', '2026-03-12 05:44:47'),
(5, 1, 'envio', 15000.00, 'Envío a celular 3042727296', '2026-03-12 06:06:36'),
(6, 2, 'recibo', 15000.00, 'Recibiste de un amigo', '2026-03-12 06:06:36'),
(7, 2, 'pago', 25000.00, 'Pago de solicitud', '2026-03-12 06:38:24'),
(8, 1, 'recibo', 25000.00, 'Cobro recibido', '2026-03-12 06:38:24'),
(9, 2, 'pago', 25000.00, 'Pago de solicitud', '2026-03-12 06:38:25'),
(10, 1, 'recibo', 25000.00, 'Cobro recibido', '2026-03-12 06:38:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitudes`
--

CREATE TABLE `solicitudes` (
  `id` int(11) NOT NULL,
  `solicitante_id` int(11) DEFAULT NULL,
  `pagador_id` int(11) DEFAULT NULL,
  `monto` decimal(15,2) NOT NULL,
  `mensaje` varchar(100) DEFAULT NULL,
  `estado` enum('pendiente','aceptada','rechazada') DEFAULT 'pendiente',
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `solicitudes`
--

INSERT INTO `solicitudes` (`id`, `solicitante_id`, `pagador_id`, `monto`, `mensaje`, `estado`, `fecha`) VALUES
(1, 1, 2, 25000.00, '', 'aceptada', '2026-03-12 06:07:52'),
(2, 1, 2, 25000.00, '', 'aceptada', '2026-03-12 06:19:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tarjeta_digital`
--

CREATE TABLE `tarjeta_digital` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `numero_tarjeta` varchar(19) DEFAULT '4123 5678 9012 3456',
  `cvv` varchar(3) DEFAULT '123',
  `fecha_exp` varchar(5) DEFAULT '12/28',
  `estado` enum('activa','congelada') DEFAULT 'activa',
  `color_hex` varchar(10) DEFAULT '#2C004F',
  `pin` varchar(4) DEFAULT '1234',
  `limite_diario` decimal(15,2) DEFAULT 1000000.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tarjeta_digital`
--

INSERT INTO `tarjeta_digital` (`id`, `usuario_id`, `numero_tarjeta`, `cvv`, `fecha_exp`, `estado`, `color_hex`, `pin`, `limite_diario`) VALUES
(1, 1, '4123 7870 4603 8090', '641', '12/30', 'activa', '#2C004F', '1234', 1000000.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(15) NOT NULL,
  `pin` varchar(4) NOT NULL,
  `saldo_disponible` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `telefono`, `pin`, `saldo_disponible`, `created_at`) VALUES
(1, 'Daniel Gomez', '3016872575', '1026', 90000.00, '2026-03-12 04:56:39'),
(2, 'Devin Rodriguez', '3042727296', '1234', 10000.00, '2026-03-12 05:39:40');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `solicitudes`
--
ALTER TABLE `solicitudes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `solicitante_id` (`solicitante_id`),
  ADD KEY `pagador_id` (`pagador_id`);

--
-- Indices de la tabla `tarjeta_digital`
--
ALTER TABLE `tarjeta_digital`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `telefono` (`telefono`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `solicitudes`
--
ALTER TABLE `solicitudes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tarjeta_digital`
--
ALTER TABLE `tarjeta_digital`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD CONSTRAINT `movimientos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `solicitudes`
--
ALTER TABLE `solicitudes`
  ADD CONSTRAINT `solicitudes_ibfk_1` FOREIGN KEY (`solicitante_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `solicitudes_ibfk_2` FOREIGN KEY (`pagador_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `tarjeta_digital`
--
ALTER TABLE `tarjeta_digital`
  ADD CONSTRAINT `tarjeta_digital_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
