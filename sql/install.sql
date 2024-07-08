/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;

/*!40101 SET NAMES utf8 */;

/*!50503 SET NAMES utf8mb4 */;

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE IF NOT EXISTS `overextended` DEFAULT CHARACTER
SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `overextended`;

CREATE TABLE IF NOT EXISTS `users` (
  `userId` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) DEFAULT NULL,
  `license2` VARCHAR(50) DEFAULT NULL,
  `steam` VARCHAR(20) DEFAULT NULL,
  `fivem` VARCHAR(10) DEFAULT NULL,
  `discord` VARCHAR(20) DEFAULT NULL,
  PRIMARY KEY (`userId`)
);

CREATE TABLE IF NOT EXISTS `characters` (
  `charId` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL,
  `stateId` VARCHAR(7) NOT NULL,
  `firstName` VARCHAR(50) NOT NULL,
  `lastName` VARCHAR(50) NOT NULL,
  `gender` VARCHAR(10) NOT NULL,
  `dateOfBirth` DATE NOT NULL,
  `phoneNumber` VARCHAR(20) DEFAULT NULL,
  `lastPlayed` DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP()),
  `isDead` TINYINT(1) NOT NULL DEFAULT 0,
  `x` FLOAT DEFAULT NULL,
  `y` FLOAT DEFAULT NULL,
  `z` FLOAT DEFAULT NULL,
  `heading` FLOAT DEFAULT NULL,
  `health` TINYINT UNSIGNED DEFAULT NULL,
  `armour` TINYINT UNSIGNED DEFAULT NULL,
  `statuses` JSON NOT NULL DEFAULT (JSON_OBJECT()),
  `deleted` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`charId`),
  KEY `characters_userId_key` (`userId`),
  UNIQUE KEY `characters_stateId_unique` (`stateId`),
  CONSTRAINT `characters_userId_fk` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `character_inventory` (
  `charId` INT UNSIGNED NOT NULL,
  `inventory` JSON NULL DEFAULT NULL,
  PRIMARY KEY (`charId`),
  KEY `character_inventory_charId_key` (`charId`),
  CONSTRAINT `character_inventory_charId_fk` FOREIGN KEY (`charId`) REFERENCES `characters` (`charId`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `ox_groups` (
  `name` VARCHAR(20) NOT NULL,
  `label` VARCHAR(50) NOT NULL,
  `type` VARCHAR(50) NULL,
  `colour` TINYINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `ox_group_grades` (
  `group` VARCHAR(20) NOT NULL,
  `grade` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `label` VARCHAR(50) NOT NULL,
  `accountRole` VARCHAR(50) NULL DEFAULT NULL
  PRIMARY KEY (`group`, `grade`),
  CONSTRAINT `ox_group_grades_group_fk` FOREIGN KEY (`group`) REFERENCES `ox_groups` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
  CONSTRAINT `FK_ox_group_grades_account_roles` FOREIGN KEY (`accountRole`) REFERENCES `account_roles` (`name`) ON UPDATE CASCADE ON DELETE CASCADE;
);

CREATE TABLE IF NOT EXISTS `character_groups` (
  `charId` INT UNSIGNED NOT NULL,
  `name` VARCHAR(20) NOT NULL,
  `grade` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `isActive` TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `name` (`name`, `charId`),
  KEY `character_groups_charId_key` (`charId`),
  CONSTRAINT `character_groups_charId_fk` FOREIGN KEY (`charId`) REFERENCES `characters` (`charId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `character_groups_name_fk` FOREIGN KEY (`name`) REFERENCES `ox_groups` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `ox_inventory` (
  `owner` VARCHAR(60) DEFAULT NULL,
  `name` VARCHAR(60) NOT NULL,
  `data` JSON DEFAULT NULL,
  `lastupdated` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `owner` (`owner`, `name`)
);

CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `plate` CHAR(8) NOT NULL DEFAULT '',
  `vin` CHAR(17) NOT NULL,
  `owner` INT UNSIGNED NULL DEFAULT NULL,
  `group` VARCHAR(20) NULL DEFAULT NULL,
  `model` VARCHAR(20) NOT NULL,
  `class` TINYINT UNSIGNED NULL DEFAULT NULL,
  `data` JSON NOT NULL,
  `trunk` JSON NULL DEFAULT NULL,
  `glovebox` JSON NULL DEFAULT NULL,
  `stored` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `plate` (`plate`),
  UNIQUE KEY `vin` (`vin`),
  KEY `vehicles_owner_key` (`owner`),
  CONSTRAINT `vehicles_owner_fk` FOREIGN KEY (`owner`) REFERENCES `characters` (`charId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `vehicles_group_fk` FOREIGN KEY (`group`) REFERENCES `ox_groups` (`name`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `ox_statuses` (
  `name` VARCHAR(20) NOT NULL,
  `default` TINYINT (3) UNSIGNED NOT NULL DEFAULT 0,
  `onTick` DECIMAL(8, 7) DEFAULT 0
);

INSERT INTO `ox_statuses` (`name`, `default`, `onTick`) VALUES
  ('hunger', 0, 0.02),
  ('thirst', 0, 0.05),
  ('stress', 0, -0.10);

CREATE TABLE IF NOT EXISTS `ox_licenses` (
  `name` VARCHAR(20) NOT NULL,
  `label` VARCHAR(50) NOT NULL,
  UNIQUE KEY `name` (`name`)
);

INSERT INTO `ox_licenses` (`name`, `label`) VALUES
  ('weapon', 'Weapon License'),
  ('driver', "Driver's License");

CREATE TABLE IF NOT EXISTS `character_licenses` (
  `charId` INT UNSIGNED NOT NULL,
  `name` VARCHAR(20) DEFAULT NULL,
  `data` JSON NOT NULL DEFAULT (JSON_OBJECT()),
  UNIQUE KEY `name` (`name`, `charId`),
  KEY `character_licenses_charId_key` (`charId`),
  CONSTRAINT `character_licenses_charId_fk` FOREIGN KEY (`charId`) REFERENCES `characters` (`charId`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `accounts` (
  `id` INT UNSIGNED NOT NULL,
  `label` VARCHAR(50) NOT NULL,
  `owner` INT UNSIGNED NULL,
  `group` VARCHAR(20) NULL,
  `balance` INT DEFAULT 0 NOT NULL,
  `isDefault` TINYINT (1) DEFAULT 0 NOT NULL,
  `type` ENUM ('personal', 'shared', 'group', 'inactive') DEFAULT 'personal' NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `accounts_owner_fk` FOREIGN KEY (`owner`) REFERENCES `characters` (`charId`) ON UPDATE SET NULL ON DELETE SET NULL,
  CONSTRAINT `accounts_group_fk` FOREIGN KEY (`group`) REFERENCES `ox_groups` (`name`) ON UPDATE SET NULL ON DELETE SET NULL
);

CREATE TABLE `account_roles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL DEFAULT '',
  `deposit` TINYINT(1) NOT NULL DEFAULT '0',
  `withdraw` TINYINT(1) NOT NULL DEFAULT '0',
  `addUser` TINYINT(1) NOT NULL DEFAULT '0',
  `removeUser` TINYINT(1) NOT NULL DEFAULT '0',
  `manageUser` TINYINT(1) NOT NULL DEFAULT '0',
  `transferOwnership` TINYINT(1) NOT NULL DEFAULT '0',
  `viewHistory` TINYINT(1) NOT NULL DEFAULT '0',
  `manageAccount` TINYINT(1) NOT NULL DEFAULT '0',
  `closeAccount` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name` (`name`)
);

INSERT INTO `account_roles` (`id`, `name`, `deposit`, `withdraw`, `addUser`, `removeUser`, `manageUser`, `transferOwnership`, `viewHistory`, `manageAccount`, `closeAccount`) VALUES
  (1, 'Viewer', 0, 0, 0, 0, 0, 0, 0, 0, 0),
  (2, 'Contributor', 1, 0, 0, 0, 0, 0, 0, 0, 0),
  (3, 'Manager', 1, 1, 1, 1, 1, 0, 1, 1, 0),
  (4, 'Owner', 1, 1, 1, 1, 1, 1, 1, 1, 1);

CREATE TABLE IF NOT EXISTS `accounts_access` (
  `accountId` INT UNSIGNED NOT NULL,
  `charId` INT UNSIGNED NOT NULL,
  `role` VARCHAR(50) NOT NULL DEFAULT 'Viewer',
  PRIMARY KEY (`accountId`, `charId`),
  CONSTRAINT `accounts_access_accountId_fk` FOREIGN KEY (`accountId`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `accounts_access_charId_fk` FOREIGN KEY (`charId`) REFERENCES `characters` (`charId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_accounts_access_account_roles` FOREIGN KEY (`role`) REFERENCES `account_roles` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS `accounts_transactions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `actorId` INT UNSIGNED DEFAULT NULL,
  `fromId` INT UNSIGNED DEFAULT NULL,
  `toId` INT UNSIGNED DEFAULT NULL,
  `amount` INT NOT NULL,
  `message` VARCHAR(255) NOT NULL,
  `note` VARCHAR(255) DEFAULT NULL,
  `fromBalance` INT DEFAULT NULL,
  `toBalance` INT DEFAULT NULL,
  `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `accounts_transactions_actorId_fk` FOREIGN KEY (`actorId`) REFERENCES `characters` (`charId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `accounts_transactions_fromId_fk` FOREIGN KEY (`fromId`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `accounts_transactions_toId_fk` FOREIGN KEY (`toId`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE `ox_group_grades`
  ADD COLUMN `accountRole` VARCHAR(50) NULL DEFAULT NULL AFTER `label`,
  ADD CONSTRAINT `FK_ox_group_grades_account_roles` FOREIGN KEY (`accountRole`) REFERENCES `account_roles` (`name`) ON UPDATE CASCADE ON DELETE CASCADE;


/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;

/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
