""" Tests Package """
import  couchdb

from demoing.helps import getLogger
from  demoing.means.teaming import teams, players, fetchTeam, fetchPlayer, \
      newTeam, newPlayer

if __name__ == "__main__":
    """ """
    logger = getLogger(name="Test")
    
    team = newTeam(name="White")
    newPlayer(name='John', team=team)
    newPlayer(name='Betty', team=team)
    
    team = newTeam(name="Yellow")
    newPlayer(name='Sally', team=team)
    newPlayer(name='Peter', team=team)
    
    logger.info("Teams:") 
    for tid, team in teams.items():
        logger.info("Team %s %s:" %  (tid, team.name))
        for pid, player in team.players.items():
            logger.info("    Player %s %s:" %  (pid, player.name))
    
    logger.info("Players:")
    for pid, player in players.items():
        logger.info("Player %s %s health %s skill %s team %s" %
             (pid, player.name, player.health, player.skill, player.tid))
    
    fetchPlayer('John').changeTeam(fetchTeam('Blue'))
    fetchPlayer('Sally').changeTeam(fetchTeam("Red"))
    
    logger.info("Teams:") 
    for tid, team in teams.items():
        logger.info("Team %s %s:" %  (tid, team.name))
        for pid, player in team.players.items():
            logger.info("    Player %s %s:" %  (pid, player.name))
    
    couch = couchdb.Server()
    db = couch['openwestdemo']
    logger.info(db)
    ids = [id_ for  id_ in db]
    logger.info(ids)
    if not ids:
        doc = dict(test="Hello World")
        db.save(doc)
        ids = [id_ for  id_ in db]
    latest = ids[-1]
    doc = db[latest]
    logger.info(doc)
    
    #doc1 = dict(test="Hello World")
    #db.save(doc1)
    #logger.info("doc1 = %s" % doc1)
    #doc2 = db[doc1['_id']]
    #logger.info("doc2 = %s" % doc2)
    #for id_ in db:
        #logger.info(id_)
    #ids = [id_ for  id_ in db] #lastest is last
    #logger.info("ids = %s" % ids)
    #doc1['test'] = "Goodbye"
    #db.save(doc1)
    #logger.info("doc1 = %s" % doc1)
    #for id_ in db:
        #doc =  db[id_]
        #db.delete(doc)
        
    