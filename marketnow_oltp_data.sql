========================
-- TABLAS INDEPENDIENTES
-- ========================

-- Vendedores
INSERT INTO vendedor (nombre_tienda, email, ruc, fecha_registro) VALUES
('TechStore Peru', 'ventas@techstore.pe', '20501234561', '2024-01-10'),
('ModaUrbana', 'info@modaurbana.pe', '20501234562', '2024-02-14'),
('HogarIdeal', 'contacto@hogarideal.pe', '20501234563', '2024-03-05'),
('DeporteMax', 'ventas@deportemax.pe', '20501234564', '2024-04-20'),
('LibrosMundo', 'info@librosmundo.pe', '20501234565', '2024-05-01'),
('GamingZone', 'soporte@gamingzone.pe', '20501234566', '2024-06-15'),
('BellezaNatural', 'ventas@bellezanatural.pe', '20501234567', '2024-07-08');

-- Categorias (incluye subcategorias)
INSERT INTO categoria (id_categoria_padre, nombre, descripcion) VALUES
(NULL, 'Electronica', 'Dispositivos y accesorios electronicos'),
(NULL, 'Ropa y Moda', 'Prendas de vestir y accesorios'),
(NULL, 'Hogar y Jardin', 'Articulos para el hogar y decoracion'),
(NULL, 'Deportes', 'Equipos y ropa deportiva'),
(NULL, 'Libros', 'Libros fisicos y materiales educativos'),
(NULL, 'Videojuegos', 'Consolas, juegos y accesorios gaming'),
(NULL, 'Belleza', 'Cuidado personal y cosmeticos'),
(1, 'Smartphones', 'Telefonos inteligentes de todas las marcas'),
(1, 'Laptops', 'Computadoras portatiles'),
(1, 'Accesorios Tech', 'Cables, cargadores y perifericos'),
(2, 'Camisetas', 'Camisetas casuales y deportivas'),
(2, 'Calzado', 'Zapatos, zapatillas y sandalias'),
(4, 'Suplementos', 'Proteinas, vitaminas y suplementos deportivos');

-- Clientes
INSERT INTO cliente (nombre, email, telefono, fecha_registro) VALUES
('Ana Garcia', 'ana.garcia@gmail.com', '987654321', '2024-01-15'),
('Luis Mendoza', 'luis.mendoza@hotmail.com', '912345678', '2024-02-20'),
('Carla Torres', 'carla.torres@gmail.com', '956789012', '2024-03-10'),
('Diego Ramirez', 'diego.ramirez@outlook.com', '934567890', '2024-04-05'),
('Sofia Paredes', 'sofia.paredes@gmail.com', '978901234', '2024-05-18'),
('Marco Quispe', 'marco.quispe@yahoo.com', '945678901', '2024-06-22'),
('Lucia Flores', 'lucia.flores@gmail.com', '923456789', '2024-07-30'),
('Andres Vega', 'andres.vega@hotmail.com', '967890123', '2024-08-14'),
('Valeria Cruz', 'valeria.cruz@gmail.com', '901234567', '2024-09-03'),
('Roberto Silva', 'roberto.silva@outlook.com', '989012345', '2024-10-19');

-- Productos (20 registros distribuidos entre los vendedores)
INSERT INTO producto (id_vendedor, id_categoria, nombre, descripcion, precio, stock, activo) VALUES
(1, 8, 'Samsung Galaxy A55', 'Pantalla AMOLED 6.6 pulgadas 128GB', 1299.90, 45, TRUE),
(1, 8, 'Xiaomi Redmi Note 13', 'Pantalla AMOLED 6.67 pulgadas 256GB', 899.90, 60, TRUE),
(1, 9, 'Laptop HP Pavilion 15', 'Intel Core i5 8GB RAM 512GB SSD', 2899.00, 20, TRUE),
(1, 9, 'Laptop Lenovo IdeaPad 3', 'AMD Ryzen 5 16GB RAM 512GB SSD', 2499.00, 15, TRUE),
(1, 10, 'Cable USB-C 2m', 'Carga rapida 65W nylon trenzado', 49.90, 120, TRUE),
(1, 10, 'Audifonos Bluetooth JBL', 'Sonido bass bateria 32 horas', 299.90, 80, TRUE),
(2, 11, 'Camiseta urbana negra', 'Algodon 100% tallas S hasta XXL', 89.90, 200, TRUE),
(2, 11, 'Polo Oversize blanco', 'Estilo holgado algodon premium', 99.90, 150, TRUE),
(2, 12, 'Zapatillas Nike Air Max', 'Running suela amortiguadora', 459.90, 40, TRUE),
(2, 12, 'Sandalias de cuero marron', 'Suela antideslizante cuero genuino', 129.90, 75, TRUE),
(3, 3, 'Juego de sabanas 2 plazas', 'Algodon 300 hilos variedad de colores', 189.90, 90, TRUE),
(3, 3, 'Olla a presion 6L Tefal', 'Acero inoxidable con valvula de seguridad', 249.90, 35, TRUE),
(4, 4, 'Pesa rusa 16 kg', 'Hierro fundido agarre antiderrapante', 149.90, 50, TRUE),
(4, 13, 'Proteina Whey Gold 2lb', 'Sabor chocolate 25g proteina por servicio', 179.90, 80, TRUE),
(5, 5, 'Libro Clean Code', 'Robert C. Martin edicion en espanol', 89.90, 60, TRUE),
(5, 5, 'Libro SQL para Principiantes', 'Guia practica paso a paso', 59.90, 100, TRUE),
(6, 6, 'Control PS5 DualSense', 'Vibracion haptica gatillos adaptativos', 389.90, 25, TRUE),
(6, 6, 'Headset HyperX Cloud II', 'Surround 7.1 microfono desmontable', 299.90, 30, TRUE),
(7, 7, 'Serum Vitamina C 30ml', 'Iluminador antioxidante natural', 79.90, 120, TRUE),
(7, 7, 'Crema hidratante facial 50ml', 'Con acido hialuronico para todo tipo de piel', 69.90, 150, TRUE);

-- ========================
-- TABLAS DE SOPORTE
-- ========================

-- Direcciones (algunos clientes tienen mas de una)
INSERT INTO direccion (id_cliente, calle, ciudad, pais, codigo_postal, es_principal) VALUES
(1, 'Av. Javier Prado 1250', 'Lima', 'Peru', '15036', TRUE),
(1, 'Calle Los Ficus 340', 'Miraflores', 'Peru', '15074', FALSE),
(2, 'Av. Arequipa 3200', 'Lima', 'Peru', '15046', TRUE),
(3, 'Jr. Ucayali 580', 'Lima', 'Peru', '15001', TRUE),
(3, 'Av. La Marina 2400', 'San Miguel', 'Peru', '15087', FALSE),
(4, 'Calle Las Begonias 740', 'San Isidro', 'Peru', '15073', TRUE),
(5, 'Av. Brasil 1900', 'Jesus Maria', 'Peru', '15072', TRUE),
(5, 'Calle Monte Rosa 180', 'Surco', 'Peru', '15023', FALSE),
(6, 'Av. Universitaria 6500', 'Los Olivos', 'Peru', '15301', TRUE),
(7, 'Jr. Lampa 1120', 'Cercado Lima', 'Peru', '15001', TRUE),
(7, 'Av. Angamos 1540', 'Surquillo', 'Peru', '15048', FALSE),
(8, 'Av. Tupac Amaru 3400', 'Comas', 'Peru', '15311', TRUE),
(9, 'Av. Grau 980', 'Barranco', 'Peru', '15063', TRUE),
(9, 'Calle Los Jazmines 210', 'La Molina', 'Peru', '15026', FALSE),
(10, 'Av. Benavides 5200', 'Miraflores', 'Peru', '15074', TRUE);

-- ========================
-- TABLAS TRANSACCIONALES
-- ========================

-- Pedidos (20 registros con distintos estados)
INSERT INTO pedido (id_cliente, id_direccion, fecha_pedido, estado, total) VALUES
(1, 1, '2025-01-05 10:23:00', 'entregado', 1389.80),
(2, 3, '2025-01-12 14:10:00', 'entregado', 2899.00),
(3, 4, '2025-01-20 09:45:00', 'entregado', 549.80),
(4, 6, '2025-02-03 16:30:00', 'entregado', 389.90),
(5, 7, '2025-02-14 11:05:00', 'entregado', 179.90),
(6, 9, '2025-02-25 13:20:00', 'entregado', 2499.00),
(7, 10, '2025-03-08 08:55:00', 'entregado', 449.80),
(8, 12, '2025-03-15 17:40:00', 'entregado', 299.90),
(9, 13, '2025-03-22 12:15:00', 'entregado', 1389.80),
(10, 15, '2025-04-01 10:00:00', 'entregado', 689.80),
(1, 1, '2025-04-10 15:30:00', 'entregado', 299.90),
(3, 5, '2025-04-18 09:10:00', 'entregado', 459.90),
(5, 8, '2025-05-02 14:50:00', 'enviado', 2899.00),
(2, 3, '2025-05-10 11:30:00', 'enviado', 479.80),
(7, 11, '2025-05-20 16:00:00', 'enviado', 149.90),
(4, 6, '2025-06-01 10:45:00', 'pagado', 349.80),
(6, 9, '2025-06-08 13:15:00', 'pagado', 1299.90),
(9, 14, '2025-06-15 09:30:00', 'pagado', 189.90),
(1, 2, '2025-06-22 17:00:00', 'pendiente', 899.90),
(8, 12, '2025-06-28 11:45:00', 'pendiente', 389.90);

-- Detalle de pedidos (28 registros, pedidos con uno o varios productos)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 1299.90),
(1, 7, 1, 89.90),
(2, 3, 1, 2899.00),
(3, 9, 1, 459.90),
(3, 8, 1, 99.90),
(4, 17, 1, 389.90),
(5, 14, 1, 179.90),
(6, 4, 1, 2499.00),
(7, 6, 1, 299.90),
(7, 10, 1, 129.90),
(8, 18, 1, 299.90),
(9, 1, 1, 1299.90),
(9, 5, 2, 49.90),
(10, 15, 1, 89.90),
(10, 19, 1, 79.90),
(10, 20, 2, 69.90),
(11, 18, 1, 299.90),
(12, 9, 1, 459.90),
(13, 3, 1, 2899.00),
(14, 6, 1, 299.90),
(14, 5, 4, 49.90),
(15, 13, 1, 149.90),
(16, 19, 2, 79.90),
(16, 20, 2, 69.90),
(17, 1, 1, 1299.90),
(18, 11, 1, 189.90),
(19, 2, 1, 899.90),
(20, 17, 1, 389.90);

-- Pagos (20 registros, uno por pedido)
INSERT INTO pago (id_pedido, metodo, monto, estado, fecha_pago) VALUES
(1, 'tarjeta', 1389.80, 'aprobado', '2025-01-05 10:25:00'),
(2, 'transferencia', 2899.00, 'aprobado', '2025-01-12 14:15:00'),
(3, 'billetera_digital', 549.80, 'aprobado', '2025-01-20 09:47:00'),
(4, 'tarjeta', 389.90, 'aprobado', '2025-02-03 16:32:00'),
(5, 'billetera_digital', 179.90, 'aprobado', '2025-02-14 11:07:00'),
(6, 'transferencia', 2499.00, 'aprobado', '2025-02-25 13:22:00'),
(7, 'tarjeta', 449.80, 'aprobado', '2025-03-08 08:57:00'),
(8, 'billetera_digital', 299.90, 'aprobado', '2025-03-15 17:42:00'),
(9, 'tarjeta', 1389.80, 'aprobado', '2025-03-22 12:17:00'),
(10, 'transferencia', 689.80, 'aprobado', '2025-04-01 10:02:00'),
(11, 'tarjeta', 299.90, 'aprobado', '2025-04-10 15:32:00'),
(12, 'billetera_digital', 459.90, 'aprobado', '2025-04-18 09:12:00'),
(13, 'transferencia', 2899.00, 'aprobado', '2025-05-02 14:52:00'),
(14, 'tarjeta', 479.80, 'aprobado', '2025-05-10 11:32:00'),
(15, 'billetera_digital', 149.90, 'aprobado', '2025-05-20 16:02:00'),
(16, 'tarjeta', 349.80, 'aprobado', '2025-06-01 10:47:00'),
(17, 'transferencia', 1299.90, 'aprobado', '2025-06-08 13:17:00'),
(18, 'billetera_digital', 189.90, 'aprobado', '2025-06-15 09:32:00'),
(19, 'tarjeta', 899.90, 'pendiente', '2025-06-22 17:02:00'),
(20, 'billetera_digital', 389.90, 'pendiente', '2025-06-28 11:47:00');

-- Envios (20 registros con distintos estados segun el pedido)
INSERT INTO envio (id_pedido, transportista, numero_guia, fecha_despacho, fecha_entrega_est, estado) VALUES
(1, 'Olva Courier', 'OLV-2025-00101', '2025-01-06', '2025-01-09', 'entregado'),
(2, 'Shalom', 'SHA-2025-00201', '2025-01-13', '2025-01-16', 'entregado'),
(3, 'Olva Courier', 'OLV-2025-00301', '2025-01-21', '2025-01-24', 'entregado'),
(4, 'DHL', 'DHL-2025-00401', '2025-02-04', '2025-02-07', 'entregado'),
(5, 'Olva Courier', 'OLV-2025-00501', '2025-02-15', '2025-02-18', 'entregado'),
(6, 'Shalom', 'SHA-2025-00601', '2025-02-26', '2025-03-01', 'entregado'),
(7, 'DHL', 'DHL-2025-00701', '2025-03-09', '2025-03-12', 'entregado'),
(8, 'Olva Courier', 'OLV-2025-00801', '2025-03-16', '2025-03-19', 'entregado'),
(9, 'Shalom', 'SHA-2025-00901', '2025-03-23', '2025-03-26', 'entregado'),
(10, 'DHL', 'DHL-2025-01001', '2025-04-02', '2025-04-05', 'entregado'),
(11, 'Olva Courier', 'OLV-2025-01101', '2025-04-11', '2025-04-14', 'entregado'),
(12, 'Shalom', 'SHA-2025-01201', '2025-04-19', '2025-04-22', 'entregado'),
(13, 'DHL', 'DHL-2025-01301', '2025-05-03', '2025-05-06', 'en_camino'),
(14, 'Olva Courier', 'OLV-2025-01401', '2025-05-11', '2025-05-14', 'en_camino'),
(15, 'Shalom', 'SHA-2025-01501', '2025-05-21', '2025-05-24', 'despachado'),
(16, 'DHL', 'DHL-2025-01601', '2025-06-02', '2025-06-05', 'despachado'),
(17, 'Olva Courier', 'OLV-2025-01701', '2025-06-09', '2025-06-12', 'preparando'),
(18, 'Shalom', 'SHA-2025-01801', '2025-06-16', '2025-06-19', 'preparando'),
(19, 'DHL', NULL, NULL, NULL, 'preparando'),
(20, 'Olva Courier', NULL, NULL, NULL, 'preparando');

-- Resenas (20 registros, solo de pedidos entregados)
INSERT INTO resena (id_cliente, id_producto, id_pedido, calificacion, comentario, fecha) VALUES
(1, 1, 1, 5, 'Muy buen telefono, la camara saca fotos increibles y la bateria aguanta bien el dia', '2025-01-12 10:00:00'),
(1, 7, 1, 4, 'La camiseta es de buena tela, talle exacto, contento con la compra', '2025-01-12 10:05:00'),
(2, 3, 2, 5, 'La laptop va rapido, la uso para programar y no me da problemas', '2025-01-19 14:00:00'),
(3, 9, 3, 5, 'Las zapatillas Nike son comodisimas, las uso para correr todos los dias', '2025-01-27 09:00:00'),
(3, 8, 3, 3, 'El polo estuvo bien pero el color en persona es un poco diferente al de la foto', '2025-01-27 09:10:00'),
(4, 17, 4, 5, 'El control llego bien embalado, los gatillos se sienten diferentes al PS4', '2025-02-10 16:00:00'),
(5, 14, 5, 4, 'La proteina se mezcla bien y no tiene sabor raro, buen producto', '2025-02-21 11:00:00'),
(6, 4, 6, 5, 'La Lenovo es muy buena para el precio, recomendada si buscas algo economico y potente', '2025-03-04 13:00:00'),
(7, 6, 7, 4, 'Los audifonos suenan muy bien, el bluetooth conecta rapido y la bateria dura bastante', '2025-03-15 09:00:00'),
(7, 10, 7, 4, 'Las sandalias son comodas, el cuero es bueno, nada que reclamar', '2025-03-15 09:15:00'),
(8, 18, 8, 5, 'El headset es lo mejor que he comprado para jugar, el microfono capta bien la voz', '2025-03-22 17:00:00'),
(9, 1, 9, 5, 'Segundo Samsung que compro en esta tienda, siempre llega rapido y en buen estado', '2025-03-29 12:00:00'),
(9, 5, 9, 3, 'El cable carga bien pero siento que podria ser mas resistente en los extremos', '2025-03-29 12:10:00'),
(10, 15, 10, 5, 'Clean Code es un libro que todo programador deberia leer, llego sin dobleces', '2025-04-08 10:00:00'),
(10, 19, 10, 4, 'El serum de vitamina C se nota en la piel despues de unas semanas, buen producto', '2025-04-08 10:10:00'),
(10, 20, 10, 5, 'La crema se absorbe rapido y no deja la cara grasosa, la volveria a comprar', '2025-04-08 10:15:00'),
(1, 18, 11, 4, 'Buen headset, lo uso para trabajar desde casa y cumple bien', '2025-04-17 15:00:00'),
(3, 9, 12, 5, 'Compre las Nike por segunda vez, no hay otra zapatilla igual para salir a trotar', '2025-04-25 09:00:00'),
(2, 3, 2, 4, 'Sigo usando la laptop a diario, sin cuelgues ni problemas de temperatura', '2025-02-01 10:00:00'),
(6, 12, 7, 4, 'Las sandalias de cuero son resistentes, ya las use varias semanas y siguen igual', '2025-03-18 11:00:00');
