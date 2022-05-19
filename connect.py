import psycopg2
import os
from readcfg import readcfg

inifile='dbconnect.ini'

def connect():
    
    scriptscfg = readcfg(inifile,'scripts')

    statscriptfname = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            scriptscfg['scripts_subdir'],
            scriptscfg['stats_script'])

    print(statscriptfname)
    
    with open(statscriptfname, mode="r", encoding="utf-8") as qfile:
        query = qfile.read()

    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        dbparams = readcfg(inifile,'postgresql')

        # connect to the PostgreSQL server
        print('Connection params: \n',dbparams,'Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**dbparams)
		
        # create a cursor
        cur = conn.cursor()
        
	# execute a statement
        qpar = {'pstart' : "2022-01-01",
                'pend' : "2022-05-01", 
                'pmanager': '%',
                'dtmask':"yyyy-mm"}

        responce=cur.mogrify(query,("var1","var3","var2","var4",))

        print (responce)
        # display the PostgreSQL database server version
        db_version = cur.fetchall()
        print(db_version)
       
	# close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')


if __name__ == '__main__':
    connect()