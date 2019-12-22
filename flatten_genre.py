from pymongo import MongoClient

MONGODB_URL = "mongodb://faveadmin:password@localhost:27017/50043db"
FILE_PATH = "./meta_Kindle_Store.json"

client = MongoClient(MONGODB_URL)
db = client["50043db"]

banned = {"Books", "Kindle eBooks", "Kindle Store", "Kindle (1st Generation) Adapters", "Power Adapters"}

with open(FILE_PATH, 'r') as f:
    line = f.read()

lines = line.split('\n')[:-1]
i = 0
length = len(lines)
for line_i in lines:
    if i%100 == 0:
        print(f"{i} out of {length}")
    entry = eval(line_i)
    cat_set = set()
    i+=1
    try:
        for cat_list in entry["categories"]:
            for cat in cat_list:
                if cat not in banned:
                    cat_set.add(cat)

        e = db.kindle_metadata2.update(
            {
                "asin": entry["asin"]
            },
            {
                "$set": {
                    "genres": list(cat_set)
                }
            }, upsert=False)


    except Exception as ex:
        print(str(ex))
        print(entry["asin"])
        continue


