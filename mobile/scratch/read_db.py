import sqlite3

try:
    conn = sqlite3.connect('farm_db.sqlite')
    c = conn.cursor()
    c.execute("SELECT tag_id, species, sex, status, current_reproductive_status FROM local_animals;")
    for row in c.fetchall():
        print(row)
    conn.close()
except Exception as e:
    print(e)
