<?php
class ModelExtensionThemeProstorePortfolio extends Model {

	public function addPortfolio($data) {
		// Set default values
		$image = isset($data['image']) ? $this->db->escape($data['image']) : '';
		$sort_order = isset($data['sort_order']) ? (int)$data['sort_order'] : 0;
		$status = isset($data['status']) ? (int)$data['status'] : 1;

		$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio SET
			image = '" . $image . "',
			sort_order = '" . $sort_order . "',
			status = '" . $status . "',
			date_added = NOW()
		");

		$portfolio_id = $this->db->getLastId();

		// Add descriptions for each language
		if (isset($data['portfolio_description'])) {
			foreach ($data['portfolio_description'] as $language_id => $value) {
				$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_description SET
					portfolio_id = '" . (int)$portfolio_id . "',
					language_id = '" . (int)$language_id . "',
					title = '" . $this->db->escape($value['title']) . "',
					description = '" . $this->db->escape($value['description']) . "',
					meta_title = '" . $this->db->escape($value['meta_title']) . "',
					meta_h1 = '" . $this->db->escape($value['meta_h1']) . "',
					meta_description = '" . $this->db->escape($value['meta_description']) . "',
					meta_keyword = '" . $this->db->escape($value['meta_keyword']) . "'
				");
			}
		}

		// Add to stores
		if (isset($data['portfolio_store'])) {
			foreach ($data['portfolio_store'] as $store_id) {
				$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_to_store SET
					portfolio_id = '" . (int)$portfolio_id . "',
					store_id = '" . (int)$store_id . "'
				");
			}
		} else {
			// Default to store 0
			$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_to_store SET
				portfolio_id = '" . (int)$portfolio_id . "',
				store_id = '0'
			");
		}

		// Add layouts
		if (isset($data['portfolio_layout'])) {
			foreach ($data['portfolio_layout'] as $store_id => $layout_id) {
				$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_to_layout SET
					portfolio_id = '" . (int)$portfolio_id . "',
					store_id = '" . (int)$store_id . "',
					layout_id = '" . (int)$layout_id . "'
				");
			}
		}

		// Add SEO URLs
		if (isset($data['portfolio_seo_url'])) {
			foreach ($data['portfolio_seo_url'] as $store_id => $language) {
				foreach ($language as $language_id => $keyword) {
					if (!empty($keyword)) {
						$this->db->query("INSERT INTO " . DB_PREFIX . "seo_url SET
							store_id = '" . (int)$store_id . "',
							language_id = '" . (int)$language_id . "',
							query = 'portfolio_id=" . (int)$portfolio_id . "',
							keyword = '" . $this->db->escape($keyword) . "'
						");
					}
				}
			}
		}

		$this->cache->delete('portfolio');

		return $portfolio_id;
	}

	public function editPortfolio($portfolio_id, $data) {
		// Update main table
		$image = isset($data['image']) ? $this->db->escape($data['image']) : '';
		$sort_order = isset($data['sort_order']) ? (int)$data['sort_order'] : 0;
		$status = isset($data['status']) ? (int)$data['status'] : 1;

		$this->db->query("UPDATE " . DB_PREFIX . "portfolio SET
			image = '" . $image . "',
			sort_order = '" . $sort_order . "',
			status = '" . $status . "'
			WHERE portfolio_id = '" . (int)$portfolio_id . "'
		");

		// Delete and re-add descriptions
		$this->db->query("DELETE FROM " . DB_PREFIX . "portfolio_description WHERE portfolio_id = '" . (int)$portfolio_id . "'");

		if (isset($data['portfolio_description'])) {
			foreach ($data['portfolio_description'] as $language_id => $value) {
				$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_description SET
					portfolio_id = '" . (int)$portfolio_id . "',
					language_id = '" . (int)$language_id . "',
					title = '" . $this->db->escape($value['title']) . "',
					description = '" . $this->db->escape($value['description']) . "',
					meta_title = '" . $this->db->escape($value['meta_title']) . "',
					meta_h1 = '" . $this->db->escape($value['meta_h1']) . "',
					meta_description = '" . $this->db->escape($value['meta_description']) . "',
					meta_keyword = '" . $this->db->escape($value['meta_keyword']) . "'
				");
			}
		}

		// Update stores
		$this->db->query("DELETE FROM " . DB_PREFIX . "portfolio_to_store WHERE portfolio_id = '" . (int)$portfolio_id . "'");

		if (isset($data['portfolio_store'])) {
			foreach ($data['portfolio_store'] as $store_id) {
				$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_to_store SET
					portfolio_id = '" . (int)$portfolio_id . "',
					store_id = '" . (int)$store_id . "'
				");
			}
		} else {
			$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_to_store SET
				portfolio_id = '" . (int)$portfolio_id . "',
				store_id = '0'
			");
		}

		// Update layouts
		$this->db->query("DELETE FROM " . DB_PREFIX . "portfolio_to_layout WHERE portfolio_id = '" . (int)$portfolio_id . "'");

		if (isset($data['portfolio_layout'])) {
			foreach ($data['portfolio_layout'] as $store_id => $layout_id) {
				$this->db->query("INSERT INTO " . DB_PREFIX . "portfolio_to_layout SET
					portfolio_id = '" . (int)$portfolio_id . "',
					store_id = '" . (int)$store_id . "',
					layout_id = '" . (int)$layout_id . "'
				");
			}
		}

		// Update SEO URLs
		$this->db->query("DELETE FROM " . DB_PREFIX . "seo_url WHERE query = 'portfolio_id=" . (int)$portfolio_id . "'");

		if (isset($data['portfolio_seo_url'])) {
			foreach ($data['portfolio_seo_url'] as $store_id => $language) {
				foreach ($language as $language_id => $keyword) {
					if (trim($keyword)) {
						$this->db->query("INSERT INTO " . DB_PREFIX . "seo_url SET
							store_id = '" . (int)$store_id . "',
							language_id = '" . (int)$language_id . "',
							query = 'portfolio_id=" . (int)$portfolio_id . "',
							keyword = '" . $this->db->escape($keyword) . "'
						");
					}
				}
			}
		}

		$this->cache->delete('portfolio');
	}

	public function deletePortfolio($portfolio_id) {
		$this->db->query("DELETE FROM " . DB_PREFIX . "portfolio WHERE portfolio_id = '" . (int)$portfolio_id . "'");
		$this->db->query("DELETE FROM " . DB_PREFIX . "portfolio_description WHERE portfolio_id = '" . (int)$portfolio_id . "'");
		$this->db->query("DELETE FROM " . DB_PREFIX . "portfolio_to_store WHERE portfolio_id = '" . (int)$portfolio_id . "'");
		$this->db->query("DELETE FROM " . DB_PREFIX . "portfolio_to_layout WHERE portfolio_id = '" . (int)$portfolio_id . "'");
		$this->db->query("DELETE FROM " . DB_PREFIX . "seo_url WHERE query = 'portfolio_id=" . (int)$portfolio_id . "'");

		$this->cache->delete('portfolio');
	}

	public function getPortfolio($portfolio_id) {
		$query = $this->db->query("SELECT DISTINCT * FROM " . DB_PREFIX . "portfolio WHERE portfolio_id = '" . (int)$portfolio_id . "'");

		return $query->row;
	}

	public function getPortfolios($data = array()) {
		$this->createTable();

		$sql = "SELECT * FROM " . DB_PREFIX . "portfolio i LEFT JOIN " . DB_PREFIX . "portfolio_description id ON (i.portfolio_id = id.portfolio_id) WHERE id.language_id = '" . (int)$this->config->get('config_language_id') . "'";

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

	public function getTotalPortfolios() {
		$this->createTable();

		$query = $this->db->query("SELECT COUNT(*) AS total FROM " . DB_PREFIX . "portfolio");

		return $query->row['total'];
	}

	public function getPortfolioDescriptions($portfolio_id) {
		$portfolio_description_data = array();

		$query = $this->db->query("SELECT * FROM " . DB_PREFIX . "portfolio_description WHERE portfolio_id = '" . (int)$portfolio_id . "'");

		foreach ($query->rows as $result) {
			$portfolio_description_data[$result['language_id']] = array(
				'title'            => $result['title'],
				'description'      => $result['description'],
				'meta_title'       => $result['meta_title'],
				'meta_h1'          => $result['meta_h1'],
				'meta_description' => $result['meta_description'],
				'meta_keyword'     => $result['meta_keyword']
			);
		}

		return $portfolio_description_data;
	}

	public function getPortfolioStores($portfolio_id) {
		$portfolio_store_data = array();

		$query = $this->db->query("SELECT * FROM " . DB_PREFIX . "portfolio_to_store WHERE portfolio_id = '" . (int)$portfolio_id . "'");

		foreach ($query->rows as $result) {
			$portfolio_store_data[] = $result['store_id'];
		}

		return $portfolio_store_data;
	}

	public function getPortfolioLayouts($portfolio_id) {
		$portfolio_layout_data = array();

		$query = $this->db->query("SELECT * FROM " . DB_PREFIX . "portfolio_to_layout WHERE portfolio_id = '" . (int)$portfolio_id . "'");

		foreach ($query->rows as $result) {
			$portfolio_layout_data[$result['store_id']] = $result['layout_id'];
		}

		return $portfolio_layout_data;
	}

	public function getPortfolioSeoUrls($portfolio_id) {
		$portfolio_seo_url_data = array();

		$query = $this->db->query("SELECT * FROM " . DB_PREFIX . "seo_url WHERE query = 'portfolio_id=" . (int)$portfolio_id . "'");

		foreach ($query->rows as $result) {
			$portfolio_seo_url_data[$result['store_id']][$result['language_id']] = $result['keyword'];
		}

		return $portfolio_seo_url_data;
	}

	public function createTable() {
		// Main portfolio table
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

		// Description table
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

		// Store relation table
		$this->db->query("
			CREATE TABLE IF NOT EXISTS " . DB_PREFIX . "portfolio_to_store (
			  `portfolio_id` int(11) NOT NULL,
			  `store_id` int(11) NOT NULL,
			  PRIMARY KEY (`portfolio_id`, `store_id`)
			) ENGINE=MyISAM DEFAULT CHARSET=utf8;
		");

		// Layout relation table
		$this->db->query("
			CREATE TABLE IF NOT EXISTS " . DB_PREFIX . "portfolio_to_layout (
			  `portfolio_id` int(11) NOT NULL,
			  `store_id` int(11) NOT NULL,
			  `layout_id` int(11) NOT NULL,
			  PRIMARY KEY (`portfolio_id`, `store_id`)
			) ENGINE=MyISAM DEFAULT CHARSET=utf8;
		");
	}

	public function installTables() {
		$this->createTable();
	}

	public function uninstallTables() {
		$this->db->query("DROP TABLE IF EXISTS " . DB_PREFIX . "portfolio");
		$this->db->query("DROP TABLE IF EXISTS " . DB_PREFIX . "portfolio_description");
		$this->db->query("DROP TABLE IF EXISTS " . DB_PREFIX . "portfolio_to_store");
		$this->db->query("DROP TABLE IF EXISTS " . DB_PREFIX . "portfolio_to_layout");
		$this->db->query("DELETE FROM " . DB_PREFIX . "seo_url WHERE query LIKE 'portfolio_id=%'");
	}
}
