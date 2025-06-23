import requests
import json
from osm2geojson import json2geojson
from datetime import datetime

r = requests.get("https://overpass-api.de/api/interpreter?data=%5Bout%3Ajson%5D%5Btimeout%3A25%5D%3B%0Aarea%5B%22ISO3166-1%22%3D%22CH%22%5D%5Badmin_level%3D2%5D%3B%0Anwr%5B%22shop%22%3D%22farm%22%5D%28area%29%3B%0Aout%20center%3B")
with open("shops.geojson", "w") as f:
    f.write(json.dumps(json2geojson(json.loads(r.text))))

    f.close()

with open("status.txt", "w") as f:
    f.write(f"updated at {datetime.now().isoformat()}")