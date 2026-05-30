import cv2
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import socket
import json
import time
import math # <--- TAMBAHAN BARU: Untuk menghitung sudut!

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
serverAddressPort = ("127.0.0.1", 5052)

model_path = 'hand_landmarker.task'
base_options = python.BaseOptions(model_asset_path=model_path)
options = vision.HandLandmarkerOptions(
    base_options=base_options,
    num_hands=2,
    min_hand_detection_confidence=0.5, 
    running_mode=vision.RunningMode.IMAGE
)
detector = vision.HandLandmarker.create_from_options(options)

cap = cv2.VideoCapture(0)
cap.set(3, 320)
cap.set(4, 240)

p_time = 0
frame_count = 0

print("Kamera menyala! Mode: HOLOGRAM IRON MAN.")

while True:
    success, img = cap.read()
    if not success:
        break

    img = cv2.flip(img, 1) 
    frame_count += 1
    
    if frame_count % 3 == 0:
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=img_rgb)
        
        results = detector.detect(mp_image)
        data_tangan = {}

        # PASTIKAN kita juga membaca hand_world_landmarks untuk akurasi 3D
        
        if results.hand_landmarks and results.handedness and results.hand_world_landmarks:
            
            for hand_lms, world_lms, handedness in zip(results.hand_landmarks, results.hand_world_landmarks, results.handedness):
                kategori = handedness[0].category_name
                
                # 1. RESET hitungan setiap ganti tangan/frame
                count_fingers = 0 
                
                # 2. Tentukan jari mana saja yang terbuka (Telunjuk, Tengah, Manis, Kelingking)
                jari_buka = [
                    hand_lms[8].y < hand_lms[6].y,   # Telunjuk
                    hand_lms[12].y < hand_lms[10].y, # Tengah
                    hand_lms[16].y < hand_lms[14].y, # Manis
                    hand_lms[20].y < hand_lms[18].y  # Kelingking
                ]
                
                # 3. Hitung 4 jari tersebut
                for j in jari_buka:
                    if j: count_fingers += 1
                
                # 4. Logika Hitung Jempol (Berdasarkan Kanan/Kiri)
                # Jempol terbuka jika ujung (4) lebih jauh ke samping daripada pangkal (2)
                if kategori == "Right":
                    if hand_lms[4].x < hand_lms[2].x: count_fingers += 1
                else:
                    if hand_lms[4].x > hand_lms[2].x: count_fingers += 1

                # 5. Sekarang baru PRINT setelah dihitung
                print(f"Tangan {kategori}: {count_fingers} jari")

                # --- Logika Pose Khusus ---
                is_open = all(jari_buka)
                is_fist = not any(jari_buka)
                is_peace = (jari_buka[0] and jari_buka[1] and not jari_buka[2] and not jari_buka[3])

                # --- Data Posisi & 3D (Tetap sama) ---
                x_pos = hand_lms[9].x
                y_pos = hand_lms[9].y
                wrist = world_lms[0]
                index_mcp = world_lms[5]
                pinky_mcp = world_lms[17]

                # 6. Susun Data untuk dikirim ke Godot
                data_tangan[kategori] = {
                    "x": x_pos, "y": y_pos, 
                    "is_open": is_open,
                    "is_peace": is_peace, 
                    "is_fist": is_fist,
                    "fingers": count_fingers,
                    "w": {"x": wrist.x, "y": wrist.y, "z": wrist.z},
                    "i": {"x": index_mcp.x, "y": index_mcp.y, "z": index_mcp.z},
                    "p": {"x": pinky_mcp.x, "y": pinky_mcp.y, "z": pinky_mcp.z}
                }

                # Gambar dot hijau di layar
                h, w, c = img.shape
                cx, cy = int(x_pos * w), int(y_pos * h)
                cv2.circle(img, (cx, cy), 8, (0, 255, 0), cv2.FILLED)

        data_string = json.dumps(data_tangan)
        sock.sendto(data_string.encode(), serverAddressPort)

    c_time = time.time()
    fps = 1 / (c_time - p_time) if (c_time - p_time) > 0 else 0 
    p_time = c_time
    
    cv2.putText(img, f'FPS: {int(fps)}', (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    cv2.imshow("Hand Tracking", img)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()