<?php
class ModelExtensionModuleProstoreportfolio extends Model {

	public function getPortfolios($data = array()) {
		$this->createTable();

		$sql = "SELECT * FROM " . DB_PREFIX . "portfolio i LEFT JOIN " . DB_PREFIX . "portfolio_description id ON (i.portfolio_id = id.portfolio_id) WHERE id.language_id = '" . (int)$this->config->get('config_language_id') . "' AND i.status = '1'";

		$sort_data = array(
			'id.title',
			'i.sort_order',
			'i.date_added'
		);

		if (isset($data['sort']) && in_array($data['sort'], $sort_data)) {
			$sql .= " ORDER BY " . $data['sort'];
		} else {
			$sql .= " ORDER BY i.sort_order, i.date_added";
		}

		if (isset($data['order']) && ($data['order'] == 'DESC')) {
			$sql .= " DESC";
		} else {
			$sql .= " ASC";
		}

		if (isset($data['start']) || isset($data['limit'])) {
			if ($data['start'] < 0) {
				$data['start'] = 0;
			}

			if ($data['limit'] < 1) {
				$data['limit'] = 20;
			}

			$sql .= " LIMIT " . (int)$data['start'] . "," . (int)$data['limit'];
		}

		$query = $this->db->query($sql);

		return $query->rows;
	}

	public function getPortfolio($portfolio_id) {
		$this->createTable();

		$sql = "SELECT * FROM " . DB_PREFIX . "portfolio i LEFT JOIN " . DB_PREFIX . "portfolio_description id ON (i.portfolio_id = id.portfolio_id) WHERE i.portfolio_id = '" . (int)$portfolio_id . "' AND id.language_id = '" . (int)$this->config->get('config_language_id') . "' AND i.status = '1'";

		$query = $this->db->query($sql);

		return $query->row;
	}

	public function getTotalPortfolios() {
		$this->createTable();

		$query = $this->db->query("SELECT COUNT(*) AS total FROM " . DB_PREFIX . "portfolio WHERE status = '1'");

		return $query->row['total'];
	}

	public function createTable() {
		// Check if tables exist, create if not
		$query = $this->db->query("SHOW TABLES LIKE '" . DB_PREFIX . "portfolio'");

		if ($query->num_rows == 0) {
			$this->db->query("
				CREATE TABLE IF NOT EXISTS " . DB_PREFIX . "portfolio (
				  `portfolio_id` int(11) NOT NULL AUTO_INCREMENT,
				  `image` varchar(255) DEFAULT NULL,
				  `sort_order` int(3) NOT NULL DEFAULT '0',
				  `status` tinyint(1) NOT NULL DEFAULT '1',
				  `date_added` datetime NOT NULL,
				  PRIMARY KEY (`portfolio_id`)
				) ENGINE=MyISAM DEFAULT CHARSET=utf8;
			");

			$this->db->query("
				CREATE TABLE IF NOT EXISTS " . DB_PREFIX . "portfolio_description (
				  `portfolio_id` int(11) NOT NULL,
				  `language_id` int(11) NOT NULL,
				  `title` varchar(255) NOT NULL,
				  `description` text NOT NULL,
				  `meta_title` varchar(255) NOT NULL,
				  `meta_h1` varchar(255) NOT NULL,
				  `meta_description` varchar(255) NOT NULL,
				  `meta_keyword` varchar(255) NOT NULL,
				  PRIMARY KEY (`portfolio_id`, `language_id`)
				) ENGINE=MyISAM DEFAULT CHARSET=utf8;
			");
		}
	}

	public function isModuleSet() {
		$this->createTable();

		$query = $this->db->query("SELECT COUNT(*) AS total FROM " . DB_PREFIX . "portfolio");

		return $query->row['total'] > 0;
	}
}
