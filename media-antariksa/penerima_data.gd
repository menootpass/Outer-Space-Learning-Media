extends Node

var udp := PacketPeerUDP.new()

@onready var matahari = $"../Matahari" 
@onready var kamera = $"../Camera3D"

# --- Variabel Rotasi Hologram ---
var target_rot_x = 0.0
var target_rot_z = 0.0 # Menggunakan Z agar tata surya miring ke kiri/kanan seperti piringan
var rot_smoothness = 8.0 

# --- Variabel Zoom (Menggunakan Sumbu X seperti yang kita sepakati) ---
var target_x = 15.0 
var prev_distance = 0.0
var is_zooming = false
var zoom_sensitivity = 20.0
var zoom_smoothness = 5.0

var jeda_transisi = 0.0 

func _ready():
	udp.bind(5052)
	target_x = kamera.position.x
	target_rot_x = matahari.rotation.x
	target_rot_z = matahari.rotation.z

func _process(delta):
	if jeda_transisi > 0.0:
		jeda_transisi -= delta

	while udp.get_available_packet_count() > 0:
		var teks_data = udp.get_packet().get_string_from_utf8()
		var data_tangan = JSON.parse_string(teks_data)
		
		if data_tangan != null:
			
			# ==========================================
			# KONDISI 1: MODE ZOOM (Dua Tangan) - TETAP SAMA
			# ==========================================
			if data_tangan.has("Left") and data_tangan.has("Right"):
				jeda_transisi = 0.5 
				
				var pos_kiri = Vector2(data_tangan["Left"]["x"], data_tangan["Left"]["y"])
				var pos_kanan = Vector2(data_tangan["Right"]["x"], data_tangan["Right"]["y"])
				var jarak_sekarang = pos_kiri.distance_to(pos_kanan)
				
				if not is_zooming:
					prev_distance = jarak_sekarang
					is_zooming = true
				else:
					var perubahan_jarak = jarak_sekarang - prev_distance
					target_x -= perubahan_jarak * zoom_sensitivity 
					target_x = clamp(target_x, 2.0, 40.0) 
					prev_distance = jarak_sekarang

			# ==========================================
			# KONDISI 2: MODE HOLOGRAM (Satu Tangan Kanan)
			# ==========================================
			elif data_tangan.has("Right"):
				is_zooming = false
				
				if jeda_transisi <= 0.0:
					var tangan = data_tangan["Right"]
					
					# Tata surya HANYA mengikuti jika tangan terbuka (is_open)
					if tangan["is_open"]:
						# Langsung tembakkan sudut dari Python ke target rotasi
						# (Dikali faktor tertentu jika terasa kebalik arahnya)
						target_rot_x = tangan["pitch"]
						target_rot_z = -tangan["roll"] 
			else:
				is_zooming = false

	# 3. PENGHALUSAN (LERP) - Tetap mulus setiap frame!
	kamera.position.x = lerp(kamera.position.x, target_x, zoom_smoothness * delta)
	matahari.rotation.x = lerp_angle(matahari.rotation.x, target_rot_x, rot_smoothness * delta)
	
	# Perhatikan kita menggunakan rotation.z untuk miring kiri-kanan
	matahari.rotation.z = lerp_angle(matahari.rotation.z, target_rot_z, rot_smoothness * delta)
