import serial
import tkinter as tk
from tkinter import ttk
import sys

# ==============================================================================
# CONFIGURACIÓN DEL PUERTO SERIAL
# ==============================================================================
PUERTO_COM = 'COM4'
BAUD_RATE  = 9600

try:
    # timeout=0: no bloqueante — lee lo que hay y regresa inmediatamente
    ser = serial.Serial(PUERTO_COM, BAUD_RATE, timeout=0)
    ser.reset_input_buffer()
    print(f"✅ Conectado a {PUERTO_COM} a {BAUD_RATE} baudios.")
except Exception as e:
    print(f"❌ Error al abrir el puerto: {e}")
    sys.exit()

# ==============================================================================
# INTERFAZ GRÁFICA
# ==============================================================================
ventana = tk.Tk()
ventana.title("Telemetría RISC-V — ADXL362")
ventana.geometry("550x380")
ventana.configure(bg="#1A1A24")

ttk.Style().theme_use('default')

tk.Label(ventana, text="TELEMETRÍA DE ACELERÓMETRO EN TIEMPO REAL",
         fg="#F0F0F5", bg="#1A1A24",
         font=("Arial", 13, "bold")).pack(pady=15)

def crear_barra_eje(nombre, color):
    frame = tk.Frame(ventana, bg="#1A1A24")
    frame.pack(pady=12, fill='x', padx=40)
    tk.Label(frame, text=f"Eje {nombre}: ", fg="#F0F0F5", bg="#1A1A24",
             font=("Courier New", 12, "bold"), width=8, anchor="w").pack(side="left")
    s = ttk.Style()
    s.configure(f"{nombre}.Horizontal.TProgressbar",
                foreground=color, background=color, thickness=22)
    bar = ttk.Progressbar(frame, style=f"{nombre}.Horizontal.TProgressbar",
                          orient="horizontal", length=280,
                          mode="determinate", maximum=255)
    bar.pack(side="left", padx=10)
    bar['value'] = 128
    lbl = tk.Label(frame, text="128", fg=color, bg="#1A1A24",
                   font=("Courier New", 12, "bold"), width=6)
    lbl.pack(side="left")
    return bar, lbl

bar_x, val_x = crear_barra_eje("X", "#FF4A76")
bar_y, val_y = crear_barra_eje("Y", "#00E676")
bar_z, val_z = crear_barra_eje("Z", "#00B0FF")

# ==============================================================================
# PARSER CON BUFFER ACUMULATIVO — NO BLOQUEANTE
#
# FIX principal: en lugar de leer byte a byte con bloqueos, acumulamos
# todos los bytes disponibles en rx_buf y procesamos paquetes completos
# (4 bytes: $ + eje + dato + \n) sin bloquear Tkinter en ningún momento.
#
# FIX desalineación: solo aceptamos el paquete si:
#   byte[0] == '$', byte[1] in {X,Y,Z}, byte[3] == '\n'
# Si hay desalineación, descartamos de a un byte hasta re-sincronizar.
# ==============================================================================
rx_buf = bytearray()

def actualizar_telemetria():
    global rx_buf

    # Leer TODOS los bytes disponibles sin bloquear (timeout=0)
    n = ser.in_waiting
    if n > 0:
        rx_buf.extend(ser.read(n))

    # Procesar todos los paquetes completos que haya en el buffer
    while len(rx_buf) >= 4:
        # Buscar el delimitador de inicio '$' en la posición 0
        if rx_buf[0] != ord('$'):
            # Desalineación: descartar un byte y buscar de nuevo
            rx_buf.pop(0)
            continue

        # Tenemos '$' en posición 0 y al menos 4 bytes: intentar parsear
        eje      = chr(rx_buf[1])   # 'X', 'Y' o 'Z'
        dato     = rx_buf[2]        # valor 0–255
        byte_fin = rx_buf[3]        # debe ser 0x0A

        if byte_fin == 0x0A and eje in ('X', 'Y', 'Z'):
            # Paquete válido — actualizar UI
            if eje == 'X':
                bar_x['value'] = dato
                val_x.config(text=f"{dato:03d}")
            elif eje == 'Y':
                bar_y['value'] = dato
                val_y.config(text=f"{dato:03d}")
            elif eje == 'Z':
                bar_z['value'] = dato
                val_z.config(text=f"{dato:03d}")
            # Consumir los 4 bytes del paquete procesado
            del rx_buf[:4]
        else:
            # El paquete no es válido aunque empieza con '$'
            # (dato binario coincidió con delimitador → desalinea)
            # Descartar el '$' y re-sincronizar
            rx_buf.pop(0)

    # Re-programar: cada 10ms es suficiente para 9600 baudios
    # (llegan ~96 bytes/s = ~24 paquetes/s, muy por debajo del límite)
    ventana.after(10, actualizar_telemetria)

ventana.after(10, actualizar_telemetria)

def al_cerrar():
    ser.close()
    ventana.destroy()

ventana.protocol("WM_DELETE_WINDOW", al_cerrar)
ventana.mainloop()