from flask import Flask, request, jsonify

app = Flask(__name__)

# In-memory storage for notes
notes = {}
note_id_counter = 0

@app.route('/notes', methods=['POST'])
def create_note():
    global note_id_counter
    data = request.get_json()
    note_id = str(note_id_counter)
    notes[note_id] = data
    note_id_counter += 1
    return jsonify({"id": note_id}), 201

@app.route('/notes', methods=['GET'])
def get_notes():
    return jsonify(list(notes.values())), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)