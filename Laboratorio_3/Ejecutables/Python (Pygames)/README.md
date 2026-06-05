## Aplicación en la laptop

El objetivo fue buscar, desarrollar o adaptar alguna aplicación de software existente para que utilice de mando de control la Nexys4. Por un tema de facilidad se optó
por hacer uso de Pygame la cual es una biblioteca de Python gratuita y de código abierto que se utiliza principalmente para crear videojuegos 2D y aplicaciones multimedia. Se escogieron 2 interfaces diferentes . A diferencia del ejecutable de ensamblador este paso a paso se ejecuta usando instrucciones DOS y la terminal del CMD de Windows. 

### Paso a paso para ejecutar las interfaces de Pygame:

  1. Verificar la versión de Python instalada (se recomienda Python 3.8 o superior): `python --version`
  2. Verificar que el gestor de paquetes de Python (pip) esté disponible: `pip --version`
  3. Crear el directorio correspondiente (ajusta el nombre según tu estructura): `mkdir Nombre_del_directorio`
  4. Abrir el directorio previamente creado: `cd Nombre_del_directorio`
  5. Actualizar pip a la última versión disponible: `python -m pip install --upgrade pip`
  6. Crear un entorno virtual llamado "venv" en la carpeta actual: `python -m venv venv`
  7. Activar el entorno virtual en la terminal de Windows (CMD): `call venv\Scripts\activate.bat`
  8. Generar automáticamente el documento de texto plano que se utiliza en el ecosistema de Python: `pip freeze > requirements.txt`
  9. Instalar Pygame y cualquier otra librería requerida con sus versiones exactas: `pip install -r requirements.txt`
  10. Ejecutar la aplicación de Pygame: `python Nombre_de_la_aplicacion.py`


