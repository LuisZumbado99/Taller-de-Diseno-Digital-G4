## Aplicación en la laptop

El objetivo fue buscar, desarrollar o adaptar alguna aplicación de software existente para que utilice de mando de control la Nexys4. Por un tema de facilidad se optó
por hacer uso de Pygame la cual es una biblioteca de Python gratuita y de código abierto que se utiliza principalmente para crear videojuegos 2D y aplicaciones multimedia. Se escogieron 2 interfaces diferentes . A diferencia del ejecutable de ensamblador este paso a paso se ejecuta usando instrucciones DOS y la terminal del CMD de Windows. 

### Paso a paso para ejecutar las interfaces de Pygame:

  1. Verificar la versión de Python instalada (se recomienda Python 3.8 o superior): `python --version`
  2. Verificar que el gestor de paquetes de Python (pip) esté disponible: `pip --version`
  3. Crear el directorio correspondiente (ajusta el nombre según tu estructura): `mkdir Nombre_del_directorio`
  4. Abrir el directorio previamente creado: `cd Nombre_del_directorio`
  5. Agregar el archivo .py del juego que se desea ejecutar al directorio.
  6. Crear un entorno virtual local y limpio: `python -m venv venv`
  7. Forzar la instalación de dependencias usando el instalador local del entorno: `venv\Scripts\pip.exe install pyserial`
  8. Ejecutar la aplicación utilizando el intérprete de Python aislado del entorno: `venv\Scripts\python.exe Nombre_del_juego.py`

### Consideraciones

Los juegos subidos a este repositorio están configurados para operar a 9600 baudios a través del COM4 como se muestra en las primeras líneas del código. Al principio de cada código a ejecutar está una sección que establece la configuración del puerto serial utilizado, antes de ejecutar el paso a paso se debe verificar el puerto COM que está utilizando la computadora para conectar con la FPGA y de ser necesario cambiarlo en el código de los juegos.

