# from TapoP100.PyP100.PyP100 import P100
from flask import Blueprint
from glob import glob
import os
import pandas as pd
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
import numpy as np
from flask import Blueprint, stream_with_context, request, Response, jsonify
import asyncio
from threading import Thread

import os
import requests
from requests import Session

from base64 import b64encode, b64decode
import hashlib
import sys
# import crypto
# sys.modules['Crypto'] = crypto
# sys.path.append('c:\\Users\\Go\\OneDrive - UOS\\allrepos\\hvac_app\\python_server\\TapoP100\\PyP100\\')


from Crypto.PublicKey import RSA
import time
import json
from Crypto.Cipher import AES, PKCS1_OAEP, PKCS1_v1_5
import tp_link_cipher
import ast
import pkgutil
import uuid
import json
from datetime import datetime
import schedule
import pymysql
import time


#Old Functions to get device list from tplinkcloud
def getToken(email, password):
	URL = "https://eu-wap.tplinkcloud.com"
	Payload = {
		"method": "login",
		"params": {
			"appType": "Tapo_Ios",
			"cloudUserName": email,
			"cloudPassword": password,
			"terminalUUID": "0A950402-7224-46EB-A450-7362CDB902A2"
		}
	}

	return requests.post(URL, json=Payload).json()['result']['token']


def getDeviceList(email, password):
	URL = "https://eu-wap.tplinkcloud.com?token=" + getToken(email, password)
	Payload = {
		"method": "getDeviceList",
	}

	return requests.post(URL, json=Payload).json()

ERROR_CODES = {
	"0": "Success",
	"-1010": "Invalid Public Key Length",
	"-1012": "Invalid terminalUUID",
	"-1501": "Invalid Request or Credentials",
	"1002": "Incorrect Request",
	"-1003": "JSON formatting error "
}

class P100():
	def __init__ (self, ipAddress, email, password):
		self.ipAddress = ipAddress
		self.terminalUUID = str(uuid.uuid4())

		self.email = email
		self.password = password
		self.session = Session()

		self.errorCodes = ERROR_CODES

		self.encryptCredentials(email, password)
		self.createKeyPair()

	def encryptCredentials(self, email, password):
		#Password Encoding
		self.encodedPassword = tp_link_cipher.TpLinkCipher.mime_encoder(password.encode("utf-8"))

		#Email Encoding
		self.encodedEmail = self.sha_digest_username(email)
		self.encodedEmail = tp_link_cipher.TpLinkCipher.mime_encoder(self.encodedEmail.encode("utf-8"))

	def createKeyPair(self):
		self.keys = RSA.generate(1024)

		self.privateKey = self.keys.exportKey("PEM")
		self.publicKey  = self.keys.publickey().exportKey("PEM")

	def decode_handshake_key(self, key):
		decode: bytes = b64decode(key.encode("UTF-8"))
		decode2: bytes = self.privateKey

		cipher = PKCS1_v1_5.new(RSA.importKey(decode2))
		do_final = cipher.decrypt(decode, None)
		if do_final is None:
			raise ValueError("Decryption failed!")

		b_arr:bytearray = bytearray()
		b_arr2:bytearray = bytearray()

		for i in range(0, 16):
			b_arr.insert(i, do_final[i])
		for i in range(0, 16):
			b_arr2.insert(i, do_final[i + 16])

		return tp_link_cipher.TpLinkCipher(b_arr, b_arr2)

	def sha_digest_username(self, data):
		b_arr = data.encode("UTF-8")
		digest = hashlib.sha1(b_arr).digest()

		sb = ""
		for i in range(0, len(digest)):
			b = digest[i]
			hex_string = hex(b & 255).replace("0x", "")
			if len(hex_string) == 1:
				sb += "0"
				sb += hex_string
			else:
				sb += hex_string

		return sb

	def handshake(self):
		URL = f"http://{self.ipAddress}/app"
		Payload = {
			"method":"handshake",
			"params":{
				"key": self.publicKey.decode("utf-8"),
				"requestTimeMils": int(round(time.time() * 1000))
			}
		}

		r = self.session.post(URL, json=Payload, timeout=2)

		encryptedKey = r.json()["result"]["key"]
		self.tpLinkCipher = self.decode_handshake_key(encryptedKey)

		try:
			self.cookie = r.headers["Set-Cookie"][:-13]

		except:
			errorCode = r.json()["error_code"]
			errorMessage = self.errorCodes[str(errorCode)]
			raise Exception(f"Error Code: {errorCode}, {errorMessage}")

	def login(self):
		URL = f"http://{self.ipAddress}/app"
		Payload = {
			"method":"login_device",
			"params":{
				"username": self.encodedEmail,
				"password": self.encodedPassword
			},
			"requestTimeMils": int(round(time.time() * 1000)),
		}
		headers = {
			"Cookie": self.cookie
		}

		EncryptedPayload = self.tpLinkCipher.encrypt(json.dumps(Payload))

		SecurePassthroughPayload = {
			"method":"securePassthrough",
			"params":{
				"request": EncryptedPayload
			}
		}

		r = self.session.post(URL, json=SecurePassthroughPayload, headers=headers, timeout=2)

		decryptedResponse = self.tpLinkCipher.decrypt(r.json()["result"]["response"])

		try:
			self.token = ast.literal_eval(decryptedResponse)["result"]["token"]
		except:
			errorCode = ast.literal_eval(decryptedResponse)["error_code"]
			errorMessage = self.errorCodes[str(errorCode)]
			raise Exception(f"Error Code: {errorCode}, {errorMessage}")

	def turnOn(self):
		URL = f"http://{self.ipAddress}/app?token={self.token}"
		Payload = {
			"method": "set_device_info",
			"params":{
				"device_on": True
			},
			"requestTimeMils": int(round(time.time() * 1000)),
			"terminalUUID": self.terminalUUID
		}

		headers = {
			"Cookie": self.cookie
		}

		EncryptedPayload = self.tpLinkCipher.encrypt(json.dumps(Payload))

		SecurePassthroughPayload = {
			"method": "securePassthrough",
			"params": {
				"request": EncryptedPayload
			}
		}

		r = self.session.post(URL, json=SecurePassthroughPayload, headers=headers, timeout=2)

		decryptedResponse = self.tpLinkCipher.decrypt(r.json()["result"]["response"])

		if ast.literal_eval(decryptedResponse)["error_code"] != 0:
			errorCode = ast.literal_eval(decryptedResponse)["error_code"]
			errorMessage = self.errorCodes[str(errorCode)]
			raise Exception(f"Error Code: {errorCode}, {errorMessage}")

	def turnOff(self):
		URL = f"http://{self.ipAddress}/app?token={self.token}"
		Payload = {
			"method": "set_device_info",
			"params":{
				"device_on": False
			},
			"requestTimeMils": int(round(time.time() * 1000)),
			"terminalUUID": self.terminalUUID
		}

		headers = {
			"Cookie": self.cookie
		}

		EncryptedPayload = self.tpLinkCipher.encrypt(json.dumps(Payload))

		SecurePassthroughPayload = {
			"method": "securePassthrough",
			"params":{
				"request": EncryptedPayload
			}
		}

		r = self.session.post(URL, json=SecurePassthroughPayload, headers=headers, timeout=2)

		decryptedResponse = self.tpLinkCipher.decrypt(r.json()["result"]["response"])

		if ast.literal_eval(decryptedResponse)["error_code"] != 0:
			errorCode = ast.literal_eval(decryptedResponse)["error_code"]
			errorMessage = self.errorCodes[str(errorCode)]
			raise Exception(f"Error Code: {errorCode}, {errorMessage}")

	def getDeviceInfo(self):
		URL = f"http://{self.ipAddress}/app?token={self.token}"
		Payload = {
			"method": "get_device_info",
			"requestTimeMils": int(round(time.time() * 1000)),
		}

		headers = {
			"Cookie": self.cookie
		}

		EncryptedPayload = self.tpLinkCipher.encrypt(json.dumps(Payload))

		SecurePassthroughPayload = {
			"method":"securePassthrough",
			"params":{
				"request": EncryptedPayload
			}
		}

		r = self.session.post(URL, json=SecurePassthroughPayload, headers=headers)
		decryptedResponse = self.tpLinkCipher.decrypt(r.json()["result"]["response"])

		return json.loads(decryptedResponse)

	def getDeviceName(self):
		self.handshake()
		self.login()
		data = self.getDeviceInfo()

		if data["error_code"] != 0:
			errorCode = ast.literal_eval(decryptedResponse)["error_code"]
			errorMessage = self.errorCodes[str(errorCode)]
			raise Exception(f"Error Code: {errorCode}, {errorMessage}")
		else:
			encodedName = data["result"]["nickname"]
			name = b64decode(encodedName)
			return name.decode("utf-8")

	def turnOnWithDelay(self, delay):
		URL = f"http://{self.ipAddress}/app?token={self.token}"
		Payload = {
			"method": "add_countdown_rule",
			"params": {
				"delay": int(delay),
				"desired_states": {
					"on": True
				},
				"enable": True,
				"remain": int(delay)
			},
			"terminalUUID": self.terminalUUID
		}

		headers = {
			"Cookie": self.cookie
		}

		EncryptedPayload = self.tpLinkCipher.encrypt(json.dumps(Payload))

		SecurePassthroughPayload = {
			"method": "securePassthrough",
			"params": {
				"request": EncryptedPayload
			}
		}

		r = self.session.post(URL, json=SecurePassthroughPayload, headers=headers)

		decryptedResponse = self.tpLinkCipher.decrypt(r.json()["result"]["response"])

		if ast.literal_eval(decryptedResponse)["error_code"] != 0:
			errorCode = ast.literal_eval(decryptedResponse)["error_code"]
			errorMessage = self.errorCodes[str(errorCode)]
			raise Exception(f"Error Code: {errorCode}, {errorMessage}")

	def turnOffWithDelay(self, delay):
		URL = f"http://{self.ipAddress}/app?token={self.token}"
		Payload = {
			"method": "add_countdown_rule",
			"params": {
				"delay": int(delay),
				"desired_states": {
					"on": False
				},
				"enable": True,
				"remain": int(delay)
			},
			"terminalUUID": self.terminalUUID
		}

		headers = {
			"Cookie": self.cookie
		}

		EncryptedPayload = self.tpLinkCipher.encrypt(json.dumps(Payload))

		SecurePassthroughPayload = {
			"method": "securePassthrough",
			"params": {
				"request": EncryptedPayload
			}
		}

		r = self.session.post(URL, json=SecurePassthroughPayload, headers=headers)

		decryptedResponse = self.tpLinkCipher.decrypt(r.json()["result"]["response"])

		if ast.literal_eval(decryptedResponse)["error_code"] != 0:
			errorCode = ast.literal_eval(decryptedResponse)["error_code"]
			errorMessage = self.errorCodes[str(errorCode)]
			raise Exception(f"Error Code: {errorCode}, {errorMessage}")



bp = Blueprint('main', __name__, url_prefix='/')
@bp.route('/')
def index():
	return 'hi'


# @bp.route('/offline_train')
# def train_offline_data():
#     # query string params  = batch_size, n_updates,name_of_trained_model
#     # http://192.168.0.108:51212/offline_train?batch_size=1024&n_updates=500&name_of_trained_model=test
#     def generate():
#         batch_size = int(request.args.get('batch_size'))
#         n_updates = int(request.args.get('n_updates'))
#         name_of_trained_model = request.args.get('name_of_trained_model')
#         #
#         path = os.getcwd()
#         agent_path = os.path.join(path,"data","agent")
#         save_agent_name = os.path.join(agent_path,f"{name_of_trained_model}.p")
#         #
#         memory = making_offline_dataset()
#         agent = make_agent()


#일단 내 계정으로 설정, 나중에 수정가능하게 할지ㅣ 검토,로그인 시스템 등
email = 'rhqudrjs2@naver.com'
pw = 'qudrjs12#'
# ip = '192.168.0.115'
# ip = '192.168.0.118'

# 스트링파라미터 유저이름까지 받아서 DB에서 스테이트까지 바뀌도록 수정할것
def on_local(ip,user_id):
	p_controller = P100(ip,email,pw)
	p_controller.handshake()
	p_controller.login()
	p_controller.turnOn()

	path = os.getcwd()
	#상태변경
	tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
	tt.loc[tt.ip == ip,['on_state']] = True
	tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
	name_plug = tt.loc[tt.ip == ip,['plug_name']].values[0][0]
	#기록저장
	time_now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
	# dd = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',),encoding='euc-kr')
	dd = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',))
	history_sam = {
		'time':time_now,
		'ip':ip,
		'state':'on',
		'name': name_plug,
		}
	

	dd = dd.append(history_sam,ignore_index=True)
	# dd.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',),index = False,encoding='euc-kr')
	dd.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',),index = False)



# 스트링파라미터 유저이름까지 받아서 DB에서 스테이트까지 바뀌도록 수정할것

def off_local(ip,user_id):
	p_controller = P100(ip,email,pw)
	p_controller.handshake()
	p_controller.login()
	p_controller.turnOff()

	path = os.getcwd()
	#기록저장
	tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
	tt.loc[tt.ip == ip,['on_state']] = False
	tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
	name_plug = tt.loc[tt.ip == ip,['plug_name']].values[0][0]
	#기록저장
	time_now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
	# dd = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',),encoding='euc-kr')
	dd = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',))
	history_sam = {
		'time':time_now,
		'ip':ip,
		'state':'off',
		'name': name_plug,
		}
	
	
	dd = dd.append(history_sam,ignore_index=True)
	# dd.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',),index = False,encoding='euc-kr')
	dd.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',),index = False)




@bp.route('/on')
def on():
	# http://192.168.0.108:9000/on?ip=192.168.0.115
	ip = request.args.get('ip')
	user_id = request.args.get('user_id')
	on_local(ip,user_id)
	return "controller_on"+" "+ip

@bp.route('/off')
def off():
	ip = request.args.get('ip')
	user_id = request.args.get('user_id')

	off_local(ip,user_id)
	return 'controller_off'+" "+ip

@bp.route('/state')
def state():
	ip = request.args.get('ip')

	p_controller = P100(ip,email,pw)
	p_controller.handshake()
	p_controller.login()
	
	state = {}
	state['on_time'] = p_controller.getDeviceInfo()['result']['on_time']
	
	if state['on_time'] == 0:
		state['state'] = 'off'
		return jsonify(state)
	else:
		state['state'] = 'on'
		return jsonify(state)

@bp.route('/delay')
def delay():
	def generate():
		for i in range(100):
			time.sleep(0.5)
			yield str(i)
	return Response(stream_with_context(generate()))

#DB에 플러그 추가, ip중복은 없나 확인하고, 켜져있나 꺼져있나 확인하고 저장, 플러터에서 수정된 정보 ('/road_plug')다시 호출해서 리셋
@bp.route('/add_plug')
def add():
	print('CHECK!!!')
	ip = request.args.get('ip')
	user_id = request.args.get('user_id')
	plug_name = request.args.get('plug_name')
	sensornum = request.args.get('sensornum')
	type_agent = request.args.get('type_agent')
	ruleset = request.args.get('ruleset')


	path = os.getcwd()
	tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
	
	p_controller = P100(ip,email,pw)
	p_controller.handshake()
	p_controller.login()

	if p_controller.getDeviceInfo()['result']['on_time'] == 0:

		on_state = False
	else:
		on_state = True
	
	plug = {
		'ip':ip,
		'user_id':user_id,
		'plug_name':plug_name,
		'on_state':on_state,
		'rulebase':0,
		'ruleset':ruleset,
		'sensornum':sensornum,
		'type_agent':type_agent,
	}
	print(plug)

	if set(tt.ip) == set(tt.append(plug,ignore_index=True).ip):
		print('중복')
		return '중복'
	else:
		tt = tt.append(plug,ignore_index=True)
		tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
		print('플러그추가 성공')
		return 'ok'

#DB에서 해당하는 플러그 지우고 다시 저장, 플러터에서 수정된 정보 ('/road_plug')다시 호출해서 리셋
@bp.route('/remove_plug')
def remove():
	ip = request.args.get('ip')
	user_id = request.args.get('user_id')
	plug_name = request.args.get('plug_name')

	path = os.getcwd()
	tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'))
	tt.drop(tt[tt.ip == ip].index).to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
	print('플러그 제거 성공')
	return 'ok'


#user_id에 맞는 파일 csv에서 찾아서 등록해놓은 플러그정보 반환(플러터 상에서는 이것 받아서 플러그 리스트컬럼 스테이트 리셋, 시작할때 한번 호출)
@bp.route('/road_plug')
def road():
	
	user_id = request.args.get('user_id')
	path = os.getcwd()
	tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'))
	tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
	
	return tt.to_json()


# 플러터에서 온오프할때 여기 데이터셋에서 스테이트 변경되도록하고 플러터에서 온오프할대 road_plug 재호출하도록 수정해야함(o)
@bp.route('/rule_base_on2')
def offline_rule_base_on():
	ip = request.args.get('ip')
	user_id = request.args.get('user_id')

	def loop_agent():
		path = os.getcwd()
		tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
		type_agent = tt.loc[tt.ip == ip,['type_agent']].values

		sensornum = tt.loc[tt.ip == ip,['sensornum']].values[0][0]
		if sensornum != 0:
			sql=f"SELECT * FROM sensor_{sensornum} WHERE 날짜 > now() - INTERVAL 10 MINUTE;"

			if tt.loc[tt.ip == ip,['rulebase']].values[0] == 1:
				print('rulebase_이미 작동중')
			elif tt.loc[tt.ip == ip,['rulebase']].values[0] == 0:
				tt.loc[tt.ip == ip,['rulebase']] = 1
				tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
				while True:
					#
					conn = pymysql.connect(
							user='room_test',
							passwd='ehrnc64581',
							#222.108.71.247(외부주소)
							host='222.108.71.247',
							#7656(외부포트)
							port=7656,
							db='sensor',
							)
					#
					df=pd.read_sql_query(sql,conn)
					conn.close()
					if df.empty:
						tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
						tt.loc[tt.ip == ip,['rulebase']] = 0
						tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
						raise StopIteration
						
					# df.CO2.values[-1]
					if type_agent == 'S' or type_agent == 'V':
						env_val = float(df.CO2.values[-1])
					else:
						env_val = float(df.PM.values[-1])

					#현재 운영 상태
					path = os.getcwd()
					tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
					stat = tt.loc[tt.ip == ip,['on_state']].values[0]
					set_val = tt.loc[tt.ip == ip,['ruleset']].values[0]
					if tt.loc[tt.ip == ip,['rulebase']].values[0] == 0:
						print('rulebase_작동중지')
						break
					else: pass

					#조건부 온오프
					if env_val > int(set_val):
						if stat: pass
						else: on_local(ip,user_id)
						
					else:
						if stat: off_local(ip,user_id)
						else: pass
					# print('작동중: ' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
					#기록저장
					time_now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
					history_sam = {
						'time':time_now,
						'ip':ip,
						'state':'rulebase_on',
						'val':env_val ,
						}
					
					#dd = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history_rulebase'+'.csv',))
					#dd = dd.append(history_sam,ignore_index=True)
					#dd.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history_rulebase'+'.csv',),index = False)
					print(history_sam)
					# file same time error, make another file for save
					time.sleep(10)
		elif sensornum == 0 :
			# sql=f"SELECT * FROM sensor_{sensornum} WHERE 날짜 > now() - INTERVAL 10 MINUTE;"
			sensor_list = [45,46,47,48,49,50,51,53,]

			if tt.loc[tt.ip == ip,['rulebase']].values[0] == 1:
				print('rulebase_이미 작동중')
			elif tt.loc[tt.ip == ip,['rulebase']].values[0] == 0:
				tt.loc[tt.ip == ip,['rulebase']] = 1
				tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
				while True:
					#
					val_list = []
					for i in sensor_list:
						conn = pymysql.connect(
								user='room_test',
								passwd='ehrnc64581',
								#222.108.71.247(외부주소)
								host='222.108.71.247',
								#7656(외부포트)
								port=7656,
								db='sensor',
								)
						#
						sql=f"SELECT * FROM sensor_{i} WHERE 날짜 > now() - INTERVAL 10 MINUTE;"
						df=pd.read_sql_query(sql,conn)
						conn.close()
						
						if df.empty:
							
							tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
							tt.loc[tt.ip == ip,['rulebase']] = 0
							tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
							raise StopIteration
							
						# df.CO2.values[-1]
						if type_agent == 'S' or type_agent == 'V':
							env_val = float(df.CO2.values[-1])
						else:
							env_val = float(df.PM.values[-1])
						val_list.append(env_val)
			
					max_val = max(val_list)
					

					#현재 운영 상태
					path = os.getcwd()
					tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
					stat = tt.loc[tt.ip == ip,['on_state']].values[0]
					set_val = tt.loc[tt.ip == ip,['ruleset']].values[0]
					if tt.loc[tt.ip == ip,['rulebase']].values[0] == 0:
						print('rulebase_작동중지')
						break
					else: pass

					#조건부 온오프
					if max_val > int(set_val):
						if stat: pass
						else: on_local(ip,user_id)
						
					else:
						if stat: off_local(ip,user_id)
						else: pass
					# print('작동중: ' + datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
					#기록저장
					time_now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
					history_sam = {
						'time':time_now,
						'ip':ip,
						'state':'rulebase_on',
						'val':max_val ,
						}
					
					#dd = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history_rulebase'+'.csv',))
					#dd = dd.append(history_sam,ignore_index=True)
					#dd.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history_rulebase'+'.csv',),index = False)
					print(history_sam)
					# file same time error, make another file for save
					time.sleep(10)
	loop_agent()
	return 'ok'


@bp.route('/rule_base_on')
def rule_base_on():
	# http://192.168.0.108:51213/rule_base_on?ip=192.168.0.118&user_id=ehrnc
	ip = request.args.get('ip')
	user_id = request.args.get('user_id')
	def generate(ip,user_id):	
		path = os.getcwd()
		tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
		# tt.loc[tt.ip == ip,['rulebase']] = 1
		type_agent = tt.loc[tt.ip == ip,['type_agent']].values

		# tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
		rulestat = True
		sensornum = tt.loc[tt.ip == ip,['sensornum']].values[0][0]
		if sensornum != 0 :
			sql=f"SELECT * FROM sensor_{sensornum} WHERE 날짜 > now() - INTERVAL 10 MINUTE;"
			# sql="SELECT * FROM sensor_44 WHERE 날짜 > now() - INTERVAL 10 MINUTE;"
			while rulestat:
				#
				conn = pymysql.connect(
						user='room_test',
						passwd='ehrnc64581',
						#222.108.71.247(외부주소)
						host='222.108.71.247',
						#7656(외부포트)
						port=7656,
						db='sensor',
						)
				#
				df=pd.read_sql_query(sql,conn)
				conn.close()
				if df.empty:
					tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
					tt.loc[tt.ip == ip,['rulebase']] = 0
					tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
					raise StopIteration
					
				# df.CO2.values[-1]
				if type_agent == 'S' or type_agent == 'V':
					env_val = float(df.CO2.values[-1])
				else:
					env_val = float(df.PM.values[-1])

				yield str(env_val)
				
				time.sleep(10)
		else:
			sensor_list = [45,46,47,48,49,50,51,53,]

			while rulestat:
				#
				val_list = []
				for i in sensor_list:
					sql=f"SELECT * FROM sensor_{i} WHERE 날짜 > now() - INTERVAL 10 MINUTE;"
					conn = pymysql.connect(
							user='room_test',
							passwd='ehrnc64581',
							#222.108.71.247(외부주소)
							host='222.108.71.247',
							#7656(외부포트)
							port=7656,
							db='sensor',
							)
					#
					df=pd.read_sql_query(sql,conn)
					conn.close()
					if df.empty:
						tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
						tt.loc[tt.ip == ip,['rulebase']] = 0
						tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)
						raise StopIteration
						
					# df.CO2.values[-1]
					if type_agent == 'S' or type_agent == 'V':
						env_val = float(df.CO2.values[-1])
					else:
						env_val = float(df.PM.values[-1])
					val_list.append(env_val)
				max_val = max(val_list)
				yield str(max_val)
				time.sleep(10)
		
	return Response(stream_with_context(generate(ip,user_id)))
	# return Response(stream_with_context(th2.start()))

@bp.route('/rule_base_off')
def rule_base_off():
	# http://192.168.0.108:51213/rule_base_off?ip=192.168.0.118&user_id=ehrnc

	ip = request.args.get('ip')
	user_id = request.args.get('user_id')

	path = os.getcwd()
	tt = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv',))
	tt.loc[tt.ip == ip,['rulebase']] = 0
	tt.to_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'.csv'),index = False)

	return 'ok'


## 역할군 지정해서 co2, pm중 자동으로 할당되도록 설정, 플러터 추가할때 카테고리로 서큘레이터, 환풍기, 공기청정기 3가지
## rule base on에서 ip로 .csv 데이터베이스에서 조회후에 df에서 co2 또는 pm사용할지 서버 수정
## 플러터에서는 agent type에 따라서 CO2 ppm으로 사용할지 pm2.5 ppm으로 사용할지 텍스트 스테이트 바뀌도록 수정
## 에이전트 리스트에도 서큘레이터인지, 공기청정기인지 등 나올 수 있도록 수정하기

@bp.route('/onoff_history')
def onoff_history():
	#"http://222.108.71.247:51213/onoff_history?user_id=ehrnc";

	user_id = request.args.get('user_id')
	path = os.getcwd()
	# history_df = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',),encoding='euc-kr')
	history_df = pd.read_csv(os.path.join(path,'TapoP100',"DB","controller_data",user_id+'_history'+'.csv',))
	dd = history_df.to_json()
	return dd



# pm, co2, 온도 등 전체 방 평균으로 보내주기, 하루정도? or 기간도 스트링파라미터로 받기
# 플러터 앱 시작할때 data안들어가더라도 데이터 미리 받고있기. 빨리볼 수 있도록
# 그후 30번정도 신규데이터 넣어주기?(고려)

@bp.route('/mean_data')
def mean_data():
	#"http://222.108.71.247:51213/mean_data";

	# user_id = request.args.get('user_id')
	sensor_list = ['44','45','46','47','48','49','50','51','53']
	sensor_info = {
		'44': '거실',
		'45': '거실(청정기옆)',
		'46': '안방',
		'47': '안쪽방',
		'48': '중간방',
		'49': '서재(가장아래)',
		'50': '서재(아래)',
		'51': '서재(중간)',
		'53': '서재(맨위)',
		}

	# sensor_list = ['44','45']
	data_list = []
	data_set = {}
	for i in sensor_list:
		conn = pymysql.connect(
		user='room_test',
		passwd='ehrnc64581',
		#222.108.71.247(외부주소)
		host='222.108.71.247',
		#7656(외부포트)
		port=7656,
		db='sensor',
		)

		#
		sql=f"SELECT * FROM sensor_{i} WHERE 날짜 > now() - INTERVAL 3 day;"

		#
		df=pd.read_sql_query(sql,conn)
		conn.close()
		# df['time_index'] = pd.to_datetime(df['날짜']).dt.floor('min')
		df['co2'] = pd.to_numeric(df['CO2'])
		df['pm'] = pd.to_numeric(df['PM'])
		df['temp'] = pd.to_numeric(df['온도'])
		df['hum'] = pd.to_numeric(df['습도'])
		df = df.set_index('날짜').resample('30T',).mean()
		#
		df.index = df.index.strftime('%Y-%m-%d %H:%M:%S')
		data_set[sensor_info[i]] = df.to_json(orient = 'index')
		
		#
		data_list.append(df)
	
	
	data_concated = pd.concat(data_list,axis=0)
	data_final = data_concated.groupby(['날짜'], as_index=True).mean()
	# print(data_final)
	# data_final.index = data_final.index.strftime('%Y-%m-%d %H:%M:%S')
	dd = data_final.to_json(orient = 'index')
	
	#
	data_set['평균'] = dd

	dd_dic = json.dumps(data_set)
	# dd_dic = json.loads(data_set)
	return dd_dic


