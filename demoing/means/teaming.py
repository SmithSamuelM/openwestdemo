""" teaming.py  team members

"""
import sys

if sys.version_info[1] < 7: #python 2.6 or earlier
    from  ordereddict import OrderedDict as ODict
else:
    from collections import OrderedDict as  ODict

import brining

nextTID = 1
nextPID = 1


DEFAULT_PLAYER = ODict([('id', None), ('tid', None), ('name', ""),
                        ('kind', "good"), ('strength', 2),('speed', 2),
                        ('health', 5), ('attack', 3), ('defend', 4)])
DEFAULT_TEAM =  ODict([('id', None), ('name', ""), ('players', None)])

def newTeam(name=""):
    global nextTID
    
    team = ODict(DEFAULT_TEAM) #make copy
    team['id'] = nextTID
    nextTID += 1
    if name:
        team['name'] = name
    team['players'] = ODict()
    return team

def newPlayer(name = "", team=None):
    global nextPID
    
    player = ODict(DEFAULT_PLAYER) #make copy
    player['id'] = nextPID
    nextPID += 1
    if name:
        player['name'] =  name    
    if team:
        player['tid'] = team["id"]
    
    return player
        

init = [
        ("red", ("John",  "Betty", "Rich", "Susan")),
        ("blue", ("Peter", "Jenny", "Jack", "Trish")), 
       ]

teams = ODict()
players = ODict()


for tname, pnames in init:
    team = newTeam(name=tname)
    teams[team['id']] = team
    for pname in pnames:
        player = newPlayer(name=pname, team=team)
        players[player['id']] = player
        team['players'][player['id']] = player
        
        
class Player(brining.Brine):
    """ """
    Keys =  ['name', 'kind', 'strength', 'speed', 'health',  'attack', 'defend']
    def __init__(self, name="", kind="good",strength=2, speed=2, health=10,
                 attack=2, defend=2):
        """ """
        self.name = name.strip().replace(" ", '')
        self.kind = kind
        self.strength = strength
        self.speed = speed
        self.health = health
        self.attack =  attack
        self.defend = defend
    

class Team(brining.Brine):
    """   """
    def __init__(self, name="", players=None):
        self.name = name.strip().replace(" ", '')
        self.players = dict(players or {}) #make copy
        
    def addPlayer(self, player):
        """ """
        if not self.players.get(player.name, None):
            self.players[player.name] = player
        return self
    
    def replacePlayer(self, player):
        """ """
        self.players[player.name] = player
        return self
    
    def removePlayer(self, player=None,  name=""):
        """ """
        player = self.players.get(player.name if player else name)
        if player:
            del  self.players[player.name]
        return self


teams = {}
team = Team(name="Red")
for x in [ dict(name="John"),  dict(name="Betty"), dict(name="Rich"),
           dict(name="Susan"), ]:
    team.addPlayer(Player(**x))

teams[team.name] = team

team = Team(name="Blue")
for x in [ dict(name="Peter"),  dict(name="Jenny"), dict(name="Jack"),
           dict(name="Trish"), ]:
    team.addPlayer(Player(**x))

teams[team.name] = team

if __name__ == "__main__":
    """Process command line args """
    print "Teams:"
    for tid, team in teams.items():
        print tid, team
    
    print "Players:"
    for pid, player in players.items():
        print pid, player