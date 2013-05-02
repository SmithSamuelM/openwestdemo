""" Tests Package """

from demoing.helps import getLogger
from  demoing.means.teaming import teams, players, fetchTeam, fetchPlayer, \
      newTeam, newPlayer

if __name__ == "__main__":
    """ """
    logger = getLogger()
    
    team = newTeam(name="Red")
    newPlayer(name='John', team=team)
    newPlayer(name='Betty', team=team)
    
    team = newTeam(name="Blue")
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