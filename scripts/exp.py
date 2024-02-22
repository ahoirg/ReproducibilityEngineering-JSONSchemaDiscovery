import requests
import json
import csv

BASE_URL = "http://localhost:3000/api"

# REGISTER
def register_user():
    url = f"{BASE_URL}/register"
    payload = json.dumps({
        "username": "ali",
        "email": "ali@gmail.com",
        "password": "ali123"
    })
    headers = {
        'Content-Type': 'application/json'
    }
    requests.post(url, headers=headers, data=payload)


# LOGIN
def login_user():
    url = f"{BASE_URL}/login"
    payload = json.dumps({
        "email": "ali@gmail.com",
        "password": "ali123"
    })
    headers = {
        'Content-Type': 'application/json'
    }
    response = requests.post(url, headers=headers, data=payload)
    if response.ok:
        print("LOGIN OK")
        return response.json().get("token")
    else:
        return None

# API request
def send_api_request(token, collection_name):
    url = f"{BASE_URL}/batch/rawschema/steps/all"
    payload = json.dumps({
        "address": "localhost",
        "port": "27017",
        "authentication": {
            "authMechanism": "SCRAM-SHA-1"
        },
        "databaseName": "jsonschemadiscovery",
        "collectionName": collection_name,
        "rawSchemaFormat": "false"
    })
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    response = requests.post(url, headers=headers, data=payload)
    if response.ok:
        response_data = response.json()
        batch_id = response_data.get("batchId")
        
        url = f"{BASE_URL}/batch/{batch_id}"
        headers = {'Authorization': f'Bearer {token}'}
        response = requests.get(url, headers=headers)
        if response.ok:
            details = response.json()
            collection_count = details.get('collectionCount')
            unique_unordered_count = details.get('uniqueUnorderedCount')
            unique_ordered_count = details.get('uniqueOrderedCount')

            # CSV file
            csv_file_name = f"/usr/src/results/{collection_name}.csv"
            with open(csv_file_name, mode='w', newline='') as file:
                writer = csv.writer(file)
                writer.writerow(['CollectionCount', 'UniqueUnorderedCount', 'UniqueOrderedCount'])
                writer.writerow([collection_count, unique_unordered_count, unique_ordered_count])
                print(collection_name +".csv: OK")

    else:
        print(f"API request FALSE")

def main():
    token = login_user()
    if not token:
        register_user()
        token = login_user()
    if token:
        for collection_name in ["drugs", "companies", "movies"]:
            send_api_request(token, collection_name)

if __name__ == "__main__":
    main()