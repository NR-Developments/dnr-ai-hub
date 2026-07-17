CREATE TABLE IF NOT EXISTS `dnr_carlifts` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `coords` longtext NOT NULL,
    `heading` float NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
