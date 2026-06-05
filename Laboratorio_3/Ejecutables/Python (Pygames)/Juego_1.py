import serial
import tkinter as tk
import sys

# CONFIGURACIÓN SERIAL
PUERTO_COM = 'COM4'
BAUD_RATE = 9600

try:
    ser = serial.Serial(PUERTO_COM, BAUD_RATE, timeout=0.1)
    ser.reset_input_buffer()
    print("✅ ¡Modo Demo Activo! Mueve la FPGA para controlar la burbuja.")
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit()

# INTERFAZ GRÁFICA INTERACTIVA (Mapeo de Control)
ventana = tk.Tk()
ventana.title("Issue #27 — Demo Control por Acelerómetro")
ventana.geometry("600x500")
ventana.configure(bg="#111116")

lbl_titulo = tk.Label(ventana, text="DEMO: CONTROL DE BURBUJA DIGITAL (RISC-V)", 
                      fg="#FFFFFF", bg="#111116", font=("Arial", 14, "bold"))
lbl_titulo.pack(pady=10)

# Área de juego / simulación (Un plano cartesiano)
canvas = tk.Canvas(ventana, width=400, height=350, bg="#1F1F2E", highlightthickness=0)
canvas.pack(pady=10)

# Dibujar cruz de centro de referencia
canvas.create_line(200, 0, 200, 350, fill="#3A3A4A", dash=(4, 4))
canvas.create_line(0, 175, 400, 175, fill="#3A3A4A", dash=(4, 4))

# Crear la burbuja que controlará el acelerómetro
RADIO = 20
burbuja = canvas.create_oval(180, 155, 220, 195, fill="#00E676", outline="#FFFFFF", width=2)

# Variables de posición actuales
pos_x, pos_y = 200, 175

# Texto de estado para pruebas de usuario
lbl_estado = tk.Label(ventana, text="Estado: Placa Horizontal", fg="#00B0FF", bg="#111116", font=("Courier New", 12, "bold"))
lbl_estado.pack(pady=10)

# INTEGRACIÓN Y MAPEO LÓGICO (Checklist #27)
def actualizar_demo():
    global pos_x, pos_y
    try:
        while ser.in_waiting > 0:
            byte_inicio = ser.read(1)
            if byte_inicio == b'$':
                resto = ser.read(3)
                if len(resto) == 3 and resto[2] == 0x0A:
                    eje = chr(resto[0])
                    valor_crudo = resto[1]  # Valor de 0 a 255
                    
                    # MAPEAR MOVIMIENTO (Mapeamos 0-255 del sensor a los píxeles del Canvas)
                    if eje == 'X':
                        # Eje X controla la posición horizontal (Izquierda / Derecha)
                        # Centrado en 128 -> mapea a 200 píxeles
                        desfase_x = (valor_crudo - 128) * 1.5
                        pos_x = 200 + desfase_x
                    elif eje == 'Y':
                        # Eje Y controla la posición vertical (Adelante / Atrás)
                        desfase_y = (valor_crudo - 128) * 1.5
                        pos_y = 175 + desfase_y

        # Limitar la burbuja dentro de los bordes del área gráfica
        pos_x = max(RADIO, min(400 - RADIO, pos_x))
        pos_y = max(RADIO, min(350 - RADIO, pos_y))

        # Mover la burbuja en la pantalla en tiempo real
        canvas.coords(burbuja, pos_x - RADIO, pos_y - RADIO, pos_x + RADIO, pos_y + RADIO)

        # VALIDAR INTERACTION Y PRUEBAS DE USUARIO (Detección de gestos)
        if abs(pos_x - 200) < 25 and abs(pos_y - 175) < 25:
            lbl_estado.config(text="Estado: 🟢 Estable / Horizontal", fg="#00E676")
        elif pos_x > 250:
            lbl_estado.config(text="Estado: 🔴 Inclinado DERECHA", fg="#FF4A76")
        elif pos_x < 150:
            lbl_estado.config(text="Estado: 🔴 Inclinado IZQUIERDA", fg="#FF4A76")
        elif pos_y > 220:
            lbl_estado.config(text="Estado: 🔵 Inclinado ABAJO / ATRÁS", fg="#00B0FF")
        elif pos_y < 130:
            lbl_estado.config(text="Estado: 🔵 Inclinado ARRIBA / ADELANTE", fg="#00B0FF")

    except Exception as e:
        pass

    ventana.after(10, actualizar_demo)

ventana.after(10, actualizar_demo)
ventana.mainloop()
ser.close()
