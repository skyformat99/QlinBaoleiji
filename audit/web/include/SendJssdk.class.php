<?php
/**
 * 中国移动云MAS
 * 用法：$jssdk = new SendJssdk(); $jssdk->sendSms('1826336****,1880633****,1866358****','测试'));
 * author: 豁达于心 QQ:394786996
 * date: 2016-3-24
 */
class SendJssdk {
	private $ecname;
	private $username;
	private $password;
	private $path;
	private $sign;
	private $serial;

	function __construct($ecname, $username, $userpasswd, $sign, $serial) {
		$this->ecname = $ecname;
		$this->username = $username;
		$this->password = $userpasswd;
		$this->sign = $sign;
		$this->serial = $serial;
		$this->path = dirname(__FILE__) . DIRECTORY_SEPARATOR.'../tmp/';
	}

	/**
	 * [getAccessToken 获得 access_token]
	 * @return [string] [access_token]
	 */
	public function getAccessToken() {

		$data = $this->getAuthorize();
		return $data->access_token;
	}

	/**
	 * [getMasUserId 获得 mas_user_id]
	 * @return [string] [mas_user_id]
	 */
	public function getMasUserId() {
		$data = $this->getAuthorize();
		return $data->mas_user_id;
	}

	/**
	 * [sendSms 发送普通短信]
	 * @param  [array] $mobiles [手机号]
	 * @param  [string] $content [内容]
	 * @return [object]          [对象]
	 */
	public function sendSms($mobiles, $content) {
		$url = 'http://mas.ecloud.10086.cn/app/http/sendSms';
		$mas_user_id = $this->getMasUserId();
		$sign = $this->sign;
		$serial = $this->serial;
		$access_token = $this->getAccessToken();
		$macstr = $mas_user_id . $mobiles . $content . $sign . $serial . $access_token;
		$mac = strtoupper(md5($macstr));
		$data = array(
			'mas_user_id' => $mas_user_id,
			'sign' => $sign,
			'mobiles' => $mobiles,
			'content' => $content,
			'serial' => $serial,
			'mac' => $mac,
		);
		$res = json_decode($this->httpGet($url, $data));
		return $res;
	}

	/**
	 * [sendSmsByTemplate 模板短信]
	 * @param  [array] $mobiles      [手机号，数组,如：13112345678,13234567890]
	 * @param  [string] $content     [内容]
	 * @param  [type] $template_id   [模板ID]
	 * @param  [type] $params        [模板参数]
	 * @return [object]              [对象]
	 */
	public function sendSmsByTemplate($mobiles, $content, $template_id, $params) {
		$url = 'http://mas.ecloud.10086.cn/app/http/sendSmsByTemplate';

		$mas_user_id = $this->getMasUserId();
		$sign = $this->sign;
		$serial = $this->serial;
		$access_token = $this->getAccessToken();
		$macstr = $mas_user_id . $template_id . $params . $mobiles . $content . $sign . $serial . $access_token;
		$mac = strtoupper(md5($macstr));

		$data = array(
			'mas_user_id' => $mas_user_id,
			'template_id' => $template_id,
			'params' => $params,
			'mobiles' => $mobiles,
			'content' => $content,
			'sign' => $sign,
			'serial' => $serial,
			'mac' => $mac,
		);
		$res = json_decode($this->httpGet($url, $data));
		return $res;
	}

	/**
	 * [getAuthorize 获得身份验证信息，并存入 authorize.json]
	 * @return [object] [authorize]
	 */
	public function getAuthorize() {
		// access_token 应该全局存储与更新，以下代码以写入到文件中做示例
		$data = json_decode(file_get_contents($this->path . "authorize.json"));
		if ($data->current_time + $data->access_token_expire_seconds - 10 < time()) {
			//http://112.33.1.10/app/http/authorize
			$url = 'http://mas.ecloud.10086.cn/app/http/authorize?ec_name=' . $this->ecname . '&user_name=' . $this->username . '&user_passwd=' . $this->password;
			$res = json_decode($this->httpGet($url));
			if ($res->status == 'Success') {
				$res->current_time = time();var_dump($this->path . "authorize.json");
				$fp = fopen($this->path . "authorize.json", "w");
				fwrite($fp, json_encode($res));
				fclose($fp);
			}
			return $res;
		} else {
			return $data;
		}
	}

	/**
	 * [httpGet 数据读取]
	 * @param  [string] $url  [需要读取的url地址]
	 * @param  [type] $data [data]
	 */
	private function httpGet($url, $data = null) {
		$curl = curl_init();
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_TIMEOUT, 500);
		curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
		curl_setopt($curl, CURLOPT_URL, $url);
		//加入POST支持
		if (!empty($data)) {
			curl_setopt($curl, CURLOPT_POST, true);
			curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
		}

		$res = curl_exec($curl);
		curl_close($curl);
		return $res;
	}
}