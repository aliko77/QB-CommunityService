CREATE TABLE `community_service` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`citizenid` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
	`status` VARCHAR(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
	`amount` INT(11) NOT NULL,
	`who` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
	`reason` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
	`type` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci,
	PRIMARY KEY (`id`)
);