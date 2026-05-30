extends Node

var udp := PacketPeerUDP.new()

# Menggunakan Unique Name (%) agar tidak error jalurnya
@onready var matahari = %Matahari 
@onready var kamera = %Camera3D
@onready var kotak_menu = $"../CanvasLayer/KotakMenu" 
@onready var vbox_menu = $"../CanvasLayer/KotakMenu/VBoxContainer"
@onready var panel_info = $"../CanvasLayer/PanelInfo"
@onready var teks_judul = $"../CanvasLayer/PanelInfo/Judul"
@onready var teks_deskripsi = $"../CanvasLayer/PanelInfo/Deskripsi"

var planet_fokus : Node3D = null 
var posisi_kamera_awal : Vector3
var rotasi_kamera_awal : Quaternion
var indeks_sorot = 0
var jarak_zoom = 5.0 

# --- Variabel Kuis ---
var mode_kuis = false
var soal_sekarang = 0
var skor = 0
var data_kuis = [
	{
		"tanya": "Matahari tersusun terutama dari gas...",
		"opsi": "1. Oksigen & Nitrogen\n2. Hidrogen & Helium\n3. Karbon & Oksigen\n4. Nitrogen & Karbon",
		"benar": 2
	},
	{
		"tanya": "Apa nama badai raksasa di Jupiter?",
		"opsi": "1. Bintik Putih Besar\n2. Bintik Merah Besar\n3. Badai Kutub Utara\n4. Aurora Khatulistiwa",
		"benar": 2
	},
	{
		"tanya": "Berapa kerapatan rata-rata Saturnus?",
		"opsi": "1. 0,667 g/cm3\n2. 0,677 g/cm3\n3. 0,687 g/cm3\n4. 0,647 g/cm3",
		"benar": 3
	},
	{
		"tanya": "Berapa lama Uranus mengelilingi Matahari?",
		"opsi": "1. 1 tahun\n2. 12 tahun\n3. 29 tahun\n4. 84 tahun",
		"benar": 4
	},
	{
		"tanya": "Apa ciri khas utama dari Neptunus?",
		"opsi": "1. Paling panas\n2. Angin sangat kencang\n3. Tanpa satelit\n4. Berwarna merah",
		"benar": 2
	}
]

# Data Akurat dari PDF Fisika Bumi dan Antariksa
var data_materi = {
	"Matahari": "Bintang yang berada di pusat tata surya kita. 
Sumber utama cahaya dan panas bagi Bumi. 
Tampak seperti bola besar yang bercahaya karena menghasilkan energi sangat besar. 
Tersusun dari gas panas, terutama hidrogen dan helium. 
Hampir tidak ada oksigen, sehingga manusia tidak bisa bernapas di Matahari. 
Suhu permukaan 5.500 derajat Celcius. 
Waktu rotasi Matahari 25–27 hari.
Matahari menyumbang sekitar 99,8% massa di seluruh tata surya
Matahari sangat besar, sekitar 1,3 juta Bumi bisa dimasukkan ke dalamnya.
",
	"Merkurius": "Planet terkecil di Tata Surya
Planet yang paling dekat dengan Matahari
Jarak ke Matahari sekitar 57 juta km, sedangkan jarang menuju Bumi sekitar 92 juta km
Tersusun dari 70% logam dan 30% silikat
Suhu permukaan sangat ekstrim mencapai 430°C pada siang hari dan -170°C pada malam hari
Periode revolusi Merkurius sekitar 87,79 hari
Atmosfer Merkurius sangat tipi dan terdiri dari 42% oksigen, 29% Natrium, 22% Hidrogen, 6% Helium, 0,5% Kalium, dan sisanya terdiri dari Argon, Nitrogen, Karbon Dioksida, Uap Air, Xenon, Kripton, serta Neon
",
	"Venus": "Venus adalah planet kedua dari Matahari
Memiliki julukan Bintang Kejora, Bintang Fajar, Bintang Timur, dan Bintang Barat
Menjadi planet terpanas di Sistem Tata Surya
Suhu permukaan Venus mencapai 470°C
Atmosfer Venus tersusun terutama dari karbon dioksida dan awan asam sulfat
Waktu rotasi Venus sekitar 243 hari Bumi dan waktu revolusinya sekitar 225 hari Bumi
Venus memiliki pegunungan terjal dan ribuan gunung berapi besar yang menjadikannya menjadi planet yang aktif secara geologi
",
	"Bumi": "Planet ketiga dari Matahari dan tempat tinggal makhluk hidup.
Memiliki udara yang mengandung oksigen sehingga manusia dapat bernapas.
Sebagian besar permukaan Bumi ditutupi oleh air.
Bumi memiliki satu satelit alami, yaitu Bulan.
Tersusun atas lapisan kerak, mantel, dan inti Bumi.
Suhu rata-rata permukaan sekitar 15 derajat Celcius.
Waktu rotasi Bumi sekitar 24 jam.
Waktu revolusi Bumi mengelilingi Matahari sekitar 365 hari.
Bumi disebut “planet biru” karena banyaknya lautan di permukaannya.
Diameter Bumi sekitar 12.742 km. 
",
	"Mars" : "Planet keempat dari Matahari.
Sering disebut sebagai “planet merah” karena permukaannya mengandung banyak besi oksida (karat).
Memiliki atmosfer yang sangat tipis dan didominasi karbon dioksida.
Mars memiliki dua satelit alami, yaitu Phobos dan Deimos.
Suhu di Mars sangat dingin, rata-rata sekitar -60 derajat Celcius.
Waktu rotasi Mars sekitar 24,6 jam.
Waktu revolusi Mars sekitar 687 hari Bumi.
Di Mars terdapat gunung tertinggi di tata surya bernama Olympus Mons.
Permukaan Mars dipenuhi gurun, batuan, dan kawah.
Manusia belum dapat tinggal di Mars tanpa alat bantu khusus. 
",
	"Jupiter": "Jupiter adalah planet kelima dari Matahari
Jupiter merupakan planet terbesar di Tata Surya dengan diameter sekitar 142.984 km
Komposisi utama Jupiter adalah hidrogen dan helium
Waktu rotasi jupiter sekitar 9 jam 56 menit, sedangkan waktu revolusi Jupiter 11,86 tahun
Memiliki 95 satelit alami yang telah teridentifikasi dan menjadikannya sebagai salah satu planet dengan jumlah satelit terbanyak di Tata Surya
Ciri khas Jupiter adalah Bintik Merah Besar yang merupakan badai antisiklon raksasa. Badai tersebut diperkirakan telah berlangsung lebih dari 350 tahun. Ukuran Bintik Merah Besar lebih besar daripada diameter Bumi.
Jupiter memiliki medan magnet yang sangat kuat dengan besar kekuatannya sekitar 20.000 kali medan magnet Bumi.
",
	"Saturnus": "Saturnus adalah planet keenam dari Matahari
Diameter saturnus sekitar 120.536 km
Termasuk planet gas raksasa dengan komposisi utamanya hidrogen dan helium
Waktu rotasi Saturnus sekitar 10 jam 42 menit dan waktu revolusi Saturnus sekitar 29,46 tahun.
Ciri khas utama Saturnus adalah sistem cincinnya yang membentang luas di sekitar ekuator planet. Tersusun atas partikel es dan debu bebatuan. 
Saturnus memiliki kerapatan rata-rata sekitar 0,687 g/cm³.
Saturnus merupakan satu-satunya planet di Tata Surya yang massa jenisnya lebih kecil dari air. Secara teori, Saturnus dapat mengapung di lautan yang sangat besar.
",
	"Uranus": "Jarak rata-rata ke Matahari sekitar 2,9 miliar kilometer. 
Membutuhkan waktu sekitar 2 jam 40 menit untuk cahaya matahari sampai ke Uranus.
Dikenal sebagai planet raksasa es karena tersusun dari gas dan es, seperti air, amonia, dan metana. 
Berwarna biru kehijauan. 
Suhunya mencapai sekitar -224°C.
Berputar dengan posisi miring seperti “tidur” sekitar 98 derajat yang membuat musimnya menjadi sangat ekstrem.
Waktu yang dibutuhkan untuk mengelilingi matahari adalah sekitar 84 tahun (satu tahun di Uranus).
Satu hari di Uranus berlangsung sekitar 17 jam. 
Memiliki banyak satelit alami, diantaranya yang terkenal adalah Titania, Oberon, Umbriel, Ariel, dan Miranda. 
",
	"Neptunus": "Planet paling jauh dari Matahari di sistem tata surya.
Disebut sebagai “planet biru” karena warna birunya berasal dari gas metana di atmosfer. 
Jarak Neptunus dari Matahari sekitar 4,5 miliar kilometer. 
Cahaya Matahari membutuhkan waktu sekitar 4 jam untuk mencapai Neptunus.
Suhunya mencapai sekitar -214°C.
Memiliki angin paling kencang di tata surya, bisa mencapai lebih dari 2.000 km/jam. 
Satu hari di Neptunus berlangsung sekitar 16 jam
Waktu untuk mengelilingi Matahari sangat lama, yaitu sekitar 165 tahun.
Satelit yang paling terkenal adalah Triton, karena bergerak berlawanan arah dengan rotasi Neptunus. 
Neptunus adalah planet pertama yang ditemukan melalui perhitungan matematika sebelum benar-benar terlihat dengan teleskop.
"
}

var target_quat := Quaternion()
var smoothness = 5.0
var jeda_transisi = 0.0 
var menunggu_soal_berikutnya = false # Variabel baru untuk pengunci

func _ready():
	udp.bind(5052)
	posisi_kamera_awal = kamera.global_position
	rotasi_kamera_awal = kamera.quaternion
	target_quat = matahari.quaternion
	kotak_menu.hide()
	panel_info.hide()

func _process(delta):
	if jeda_transisi > 0.0: 
		jeda_transisi -= delta
		
		# Jika waktu tunggu habis dan kita sedang di mode kuis
		if jeda_transisi <= 0.0 and mode_kuis and menunggu_soal_berikutnya:
			menunggu_soal_berikutnya = false
			soal_sekarang += 1
			tampilkan_soal()

	while udp.get_available_packet_count() > 0:
		var data = JSON.parse_string(udp.get_packet().get_string_from_utf8())
		if data is Dictionary:
			var tangan = data.get("Right", data.get("Left", null))
			if tangan and jeda_transisi <= 0.0:
				proses_input(tangan)

	gerakkan_kamera(delta)

func proses_input(tangan):
	# 1. JIKA SEDANG JEDA, JANGAN PROSES APAPUN
	if jeda_transisi > 0.0: return
	
	var jumlah_jari = tangan.get("fingers", 0)
	var is_fist = tangan.get("is_fist", false)
	var is_open = tangan.get("is_open", false)
	
	if mode_kuis:
		# 2. JIKA MENGEPAL (FIST), JANGAN BISA JAWAB
		if is_fist: return
		# 3. HANYA PROSES JIKA JARI 1-4 DAN TIDAK SEDANG MENUNGGU
		if not menunggu_soal_berikutnya and jumlah_jari >= 1 and jumlah_jari <= 4:
			jawab_kuis(jumlah_jari)
		elif is_open: # Tangan terbuka lebar untuk keluar kuis
			keluar_kuis()
		return
	# Logika Navigasi Normal
	if tangan.get("is_peace", false) and planet_fokus == null:
		kotak_menu.show()
		var tombols = vbox_menu.get_children().filter(func(c): return c is Button)
		indeks_sorot = int(clamp((tangan["y"] - 0.3) / 0.4, 0.0, 0.99) * tombols.size())
		tombols[indeks_sorot].grab_focus()
	
	elif is_fist:
		if kotak_menu.visible:
			var nama = (vbox_menu.get_child(indeks_sorot) as Button).text
			if nama == "Kuis":
				mulai_kuis()
			else:
				pilih_planet(nama)
			
	elif is_open:
		reset_tampilan()
		
	if tangan.get("is_peace", false) and planet_fokus == null:
		kotak_menu.show()
		var tombols = vbox_menu.get_children().filter(func(c): return c is Button)
		indeks_sorot = int(clamp((tangan["y"] - 0.3) / 0.4, 0.0, 0.99) * tombols.size())
		tombols[indeks_sorot].grab_focus()
	
	elif tangan.get("is_fist", false) and kotak_menu.visible:
		var nama = (vbox_menu.get_child(indeks_sorot) as Button).text
		# Mencari node dengan Unique Name %
		var target = get_node_or_null("%" + nama)
		if target:
			planet_fokus = target
			teks_judul.text = nama
			teks_deskripsi.text = data_materi.get(nama, "Materi belum tersedia.")
			kotak_menu.hide()
			panel_info.show()
			jeda_transisi = 0.8
			
	elif tangan.get("is_open", false):
		planet_fokus = null
		panel_info.hide()
		kotak_menu.hide()
		# Update rotasi matahari
		var v_w = Vector3(tangan["w"]["x"], -tangan["w"]["y"], tangan["w"]["z"])
		var v_i = Vector3(tangan["i"]["x"], -tangan["i"]["y"], tangan["i"]["z"])
		var v_p = Vector3(tangan["p"]["x"], -tangan["p"]["y"], tangan["p"]["z"])
		var d_fwd = (v_i - v_w).normalized()
		var d_up = d_fwd.cross((v_p - v_i).normalized()).normalized()
		if d_fwd.length() > 0: target_quat = Basis().looking_at(d_fwd, d_up).get_rotation_quaternion()

# --- Fungsi Pendukung Lainnya (Pilih Planet, Gerakan Kamera, dll tetap sama) ---
func pilih_planet(nama):
	var target = get_node_or_null("%" + nama)
	if target:
		planet_fokus = target
		teks_judul.text = nama
		# Ambil deskripsi materi (bisa ditambah ke dictionary data_materi)
		teks_deskripsi.text = data_materi.get(nama, "Deskripsi untuk " + nama + " belum ditambahkan.")
		kotak_menu.hide()
		panel_info.show()
		jeda_transisi = 0.8
		
func reset_tampilan():
	planet_fokus = null
	panel_info.hide()
	kotak_menu.hide()
	
func mulai_kuis():
	mode_kuis = true
	soal_sekarang = 0
	skor = 0
	menunggu_soal_berikutnya = false
	kotak_menu.hide()
	panel_info.show()
	tampilkan_soal()

func tampilkan_soal():
	if soal_sekarang < data_kuis.size():
		var data = data_kuis[soal_sekarang]
		teks_judul.text = "Soal No. " + str(soal_sekarang + 1)
		teks_deskripsi.text = data["tanya"] + "\n\n" + data["opsi"] + "\n\n[Angkat jari 1-4 untuk menjawab]"
	else:
		teks_judul.text = "Kuis Selesai!"
		teks_deskripsi.text = "Skor Akhir: " + str(skor) + "/" + str(data_kuis.size())
		# Biarkan skor terlihat selama 5 detik lalu tutup kuis
		jeda_transisi = 5.0
		menunggu_soal_berikutnya = false
		await get_tree().create_timer(5.0).timeout
		mode_kuis = false
		panel_info.hide()

func jawab_kuis(pilihan):
	var jawaban_benar = data_kuis[soal_sekarang]["benar"]
	
	if pilihan == jawaban_benar:
		skor += 1
		teks_judul.text = "BENAR!"
	else:
		teks_judul.text = "SALAH!"
	
	teks_deskripsi.text = "Jawaban yang benar adalah nomor: " + str(jawaban_benar) + "\n\nMohon tunggu 5 detik..."
	
	# PASANG PENGUNCI
	menunggu_soal_berikutnya = true
	jeda_transisi = 5.0 # Kunci selama 5 detik

func keluar_kuis():
	mode_kuis = false
	panel_info.hide()
	jeda_transisi = 0.5
	
func gerakkan_kamera(delta):
	if planet_fokus:
		# Kamera mengejar posisi GLOBAL planet agar tetap stabil meskipun planet mengorbit
		var target_pos = planet_fokus.global_position + (kamera.global_position - planet_fokus.global_position).normalized() * jarak_zoom
		kamera.global_position = kamera.global_position.lerp(target_pos, smoothness * delta)
		kamera.look_at(planet_fokus.global_position)
	else:
		kamera.global_position = kamera.global_position.lerp(posisi_kamera_awal, smoothness * delta)
		kamera.quaternion = kamera.quaternion.slerp(rotasi_kamera_awal, smoothness * delta)
		matahari.quaternion = matahari.quaternion.slerp(target_quat, smoothness * delta)
