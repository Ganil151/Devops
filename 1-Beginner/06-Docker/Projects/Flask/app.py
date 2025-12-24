import os 
from flask import Flask, request
from psycopg_pool import ConnectionPool

def dbConnect():
    """Connect to the database"""
    
    db_host = os.environ.get('DB_HOST')
    db_database = os.environ.get('DB_DATABASE')
    db_user = os.environ.get('DB_USER')
    db_port = os.environ.get('DB_PORT')
    db_password = open('/run/pg_password', 'r').read().strip()

    # Create a connection URL for the database
    url = f'host={db_host} dbname={db_database} user={db_user} port={db_port} password={db_password}'
    
    # Connect to the database
    pool = ConnectionPool(url)
    pool.wait()

    return pool

# Create a connection pool for Post
pool = dbConnect()
    

app = Flask(__name__)

@app.route('/about', methods=['GET'])
def about():
    version = os.environ.get('APP_VERSION', '0.1.0') 
    return {'app_version': version}, 200 
  
@app.route('/secrets', methods=['GET'])
def secrets():
    creds = dict()
    creds['db_password'] = os.environ.get('DB_PASSWORD')
    creds['api_key'] = open('/run/api_key', 'r').read().strip()
    creds['api_key_v2'] = open('/Flask/api_key.txt', 'r').read().strip()
    return creds, 200

@app.route('/config', methods=['GET']) 
def config():
    config = dict()
    config['config_dev'] = open('/config-dev.yaml', 'r').read().strip()
    config['config_dev_v2'] = open('/config-dev-v2.yaml', 'r').read().strip()
    return config, 200
    

@app.route('/volumes', methods=['GET', 'POST'])
def volumes():
    filename = '/data/test.txt'
    if request.method == 'POST':
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        with open(filename, 'w') as f:
            f.write(request.data.decode('utf-8'))
        return 'Saved!', 201
    else:
        with open(filename, 'r') as f:
            return f.read(), 200

# Save an item to the database
def save_item(priority, task, table, pool):
    """Save an item to the database"""

    # Connect to an existing database
    with pool.connection() as conn:
        with conn.cursor() as cur:

            # Prepare the SQL query
            query = f'INSERT INTO {table} (priority, task) VALUES (%s, %s)'
            
            # Send the query to the database
            cur.execute(query, (priority, task))

            # Make the changes to the database
            conn.commit()

# Return the items from the database
def get_items(table, pool):
    """Return the items from the database"""

    # Connect to an existing database
    with pool.connection() as conn:
        with conn.cursor() as cur:
            # Prepare the SQL query
            query = f'SELECT item_id, priority, task FROM {table}'
            
            # Send the query to the database
            cur.execute(query)

            items = []

            for rec in cur:
                item = {'id': rec[0], 'priority': rec[1], 'task': rec[2]}
                items.append(item)
            
            # Return the items from the database
            return items, 200

@app.route('/items', methods=['GET', 'POST'])
def items():
    match request.method:
        case 'POST':
            req = request.get_json()
            save_item(req['priority'], req['task'], 'item', pool)
            return {'message': 'item saved'}, 201
        case 'GET':
            return get_items('item', pool)
        case _:
            return {'message': 'method not allowed'}, 405
        
