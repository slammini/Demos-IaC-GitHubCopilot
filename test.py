from flask import Flask, request

app = Flask(__name__)
port = 3000

@app.route('/hello')
def hello():
    name = request.args.get('name', 'World')
    return f'Hello {name}!'

@app.route('/sum')
def sum():
    a = parse_query_int('a')
    b = parse_query_int('b')
    if a is not None and b is not None:
        return f'The sum of {a} and {b} is {a + b}'

def parse_query_int(name):
    value = request.args.get(name)
    if value is None:
        return None
    try:
        return int(value)
    except ValueError:
        return error(f'The value of {name} must be a number')

def error(message):
    return message, 400

if __name__ == '__main__':
    app.run(port=port)



