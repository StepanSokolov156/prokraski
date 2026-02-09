<?php
class ControllerExtensionModuleProstorePortfolio extends Controller {

	public function index($settings) {
		$this->load->language('extension/module/prostore_portfolio');

		$this->load->model('extension/module/prostoreportfolio');
		$this->load->model('tool/image');

		$data['portfolios'] = array();

		$limit = isset($settings['limit']) ? (int)$settings['limit'] : 8;
		$width = isset($settings['width']) ? (int)$settings['width'] : 400;
		$height = isset($settings['height']) ? (int)$settings['height'] : 400;

		$filter_data = array(
			'sort'  => 'i.sort_order',
			'order' => 'ASC',
			'start' => 0,
			'limit' => $limit
		);

		$results = $this->model_extension_module_prostoreportfolio->getPortfolios($filter_data);

		foreach ($results as $result) {
			// Get popup image (full size)
			if ($result['image']) {
				$popup = $this->model_tool_image->resize($result['image'], 1200, 1200);
			} else {
				$popup = '';
			}

			// Get thumbnail - use original image for flexible sizing via CSS
			if ($result['image']) {
				$thumb = 'image/' . $result['image'];
			} else {
				$thumb = 'image/placeholder.png';
			}

			// Plain text description for data attribute (strip HTML tags)
			$description_plain = strip_tags(html_entity_decode($result['description'], ENT_QUOTES, 'UTF-8'));

			$data['portfolios'][] = array(
				'portfolio_id'     => $result['portfolio_id'],
				'title'            => $result['title'],
				'description'      => html_entity_decode($result['description'], ENT_QUOTES, 'UTF-8'),
				'description_plain' => $description_plain,
				'thumb'            => $thumb,
				'popup'            => $popup
			);
		}

		$data['heading_title'] = $this->language->get('heading_title');

		return $this->load->view('extension/module/prostore_portfolio', $data);
	}

	public function getPortfoliolist() {
		$this->load->language('extension/module/prostore_portfolio');

		$this->load->model('extension/module/prostoreportfolio');
		$this->load->model('tool/image');

		// SEO data from theme settings
		if ($this->config->get('theme_prostore_portfolio_meta_title' . $this->config->get('config_language_id'))) {
			$this->document->setTitle($this->config->get('theme_prostore_portfolio_meta_title' . $this->config->get('config_language_id')));
		} else {
			$this->document->setTitle($this->language->get('heading_title'));
		}

		if ($this->config->get('theme_prostore_portfolio_meta_description' . $this->config->get('config_language_id'))) {
			$this->document->setDescription($this->config->get('theme_prostore_portfolio_meta_description' . $this->config->get('config_language_id')));
		}

		if ($this->config->get('theme_prostore_portfolio_meta_keyword' . $this->config->get('config_language_id'))) {
			$this->document->setKeywords($this->config->get('theme_prostore_portfolio_meta_keyword' . $this->config->get('config_language_id')));
		}

		$data['heading_title'] = $this->language->get('heading_title');

		// Check if module has items
		if (!$this->model_extension_module_prostoreportfolio->isModuleSet()) {
			$this->response->redirect($this->url->link('error/not_found', '', true));
		}

		// Breadcrumbs
		$data['breadcrumbs'] = array();

		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('text_home'),
			'href' => $this->url->link('common/home')
		);

		$data['breadcrumbs'][] = array(
			'text' => $this->language->get('heading_title'),
			'href' => $this->url->link('extension/module/prostore_portfolio/getPortfoliolist')
		);

		// Pagination
		if (isset($this->request->get['page'])) {
			$page = $this->request->get['page'];
		} else {
			$page = 1;
		}

		$limit = $this->config->get('theme_prostore_portfolio_limit') ? $this->config->get('theme_prostore_portfolio_limit') : 20;

		$filter_data = array(
			'sort'  => 'i.sort_order',
			'order' => 'ASC',
			'start' => ($page - 1) * $limit,
			'limit' => $limit
		);

		$portfolio_total = $this->model_extension_module_prostoreportfolio->getTotalPortfolios();
		$results = $this->model_extension_module_prostoreportfolio->getPortfolios($filter_data);

		$data['portfolios'] = array();

		foreach ($results as $result) {
			// Get popup image (full size)
			if ($result['image']) {
				$popup = $this->model_tool_image->resize($result['image'], 1200, 1200);
			} else {
				$popup = '';
			}

			// Get thumbnail - use original image for flexible sizing via CSS
			if ($result['image']) {
				$thumb = 'image/' . $result['image'];
			} else {
				$thumb = 'image/placeholder.png';
			}

			// Plain text description for data attribute (strip HTML tags)
			$description_plain = strip_tags(html_entity_decode($result['description'], ENT_QUOTES, 'UTF-8'));

			$data['portfolios'][] = array(
				'portfolio_id'       => $result['portfolio_id'],
				'title'              => $result['title'],
				'description'         => utf8_substr(strip_tags(html_entity_decode($result['description'], ENT_QUOTES, 'UTF-8')), 0, 150) . '...',
				'description_plain'   => $description_plain,
				'thumb'              => $thumb,
				'popup'              => $popup
			);
		}

		// Pagination
		$pagination = new Pagination();
		$pagination->total = $portfolio_total;
		$pagination->page = $page;
		$pagination->limit = $limit;
		$pagination->url = $this->url->link('extension/module/prostore_portfolio/getPortfoliolist', 'page={page}', true);

		$data['pagination'] = $pagination->render();

		$data['results'] = sprintf($this->language->get('text_pagination'), ($page - 1) * $limit + 1, (($portfolio_total > $page * $limit) ? $page * $limit : $portfolio_total), $portfolio_total, ceil($portfolio_total / $limit));

		$data['column_left'] = $this->load->controller('common/column_left');
		$data['column_right'] = $this->load->controller('common/column_right');
		$data['content_top'] = $this->load->controller('common/content_top');
		$data['content_bottom'] = $this->load->controller('common/content_bottom');
		$data['footer'] = $this->load->controller('common/footer');
		$data['header'] = $this->load->controller('common/header');

		$this->response->setOutput($this->load->view('extension/module/prostore_portfolio_list', $data));
	}
}
