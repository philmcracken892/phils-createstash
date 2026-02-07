CREATE TABLE IF NOT EXISTS `custom_stashes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `label` VARCHAR(100) NOT NULL,
    `type` VARCHAR(50) NOT NULL DEFAULT 'stash',
    `slots` INT NOT NULL DEFAULT 50,
    `weight` INT NOT NULL DEFAULT 100000,
    `show_blip` TINYINT(1) NOT NULL DEFAULT 0,
    `job_name` VARCHAR(50) DEFAULT NULL,
    `gang_name` VARCHAR(50) DEFAULT NULL,
    `coords` LONGTEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index for faster lookups
CREATE INDEX idx_stash_type ON custom_stashes(type);
CREATE INDEX idx_stash_job ON custom_stashes(job_name);
CREATE INDEX idx_stash_gang ON custom_stashes(gang_name);