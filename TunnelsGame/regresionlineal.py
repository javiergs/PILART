from flask import Flask, request, jsonify
from sklearn.linear_model import LinearRegression
import numpy as np

app = Flask(__name__)

historico = []
modelo = None
promedio_X = None

@app.route('/prediccion', methods=['POST'])
def prediccion():
    global historico
    global modelo
    global promedio_X
    data = request.json
    
    if not isinstance(data, list):
        return jsonify({'error': 'Los datos deben ser una lista de partidas.'}), 400
    
    historico = data
    entrenar_modelo()
    
    resultado_predicho = predecir_resultado()
    
    return jsonify({'resultado_predicho': resultado_predicho})

def entrenar_modelo():
    global modelo
    global promedio_X
    X = []
    y = []
    for partida in historico:
        X.append([partida["velocidadPromedio"], partida["tiempoTotal"], partida["destinosIncorrectos"]])
        y.append(partida["destinosCorrectos"])

    X = np.array(X)
    y = np.array(y)

    modelo = LinearRegression().fit(X, y)
    promedio_X = np.mean(X, axis=0).reshape(1, -1)  # Calcula el promedio de X

def predecir_resultado():
    if modelo is None or promedio_X is None:
        return None

    resultado = modelo.predict(promedio_X)
    
    # Aplicar función de activación sigmoide
    resultado = 1 / (1 + np.exp(-resultado))
    
    return resultado[0]

if __name__ == '__main__':
    app.run(debug=True)
