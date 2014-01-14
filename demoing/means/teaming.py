""" teaming.py  team members

"""
import sys
import random
from os import path
from  collections import OrderedDict as ODict
import simplejson as json
#import couchdb
import brining

from ..helps import getLogger

logger = getLogger()

DATABASE_NAME = 'openwestdemo'
MAX_SKILL = 9
MAX_HEALTH = 9

teams = ODict()
players = ODict()

class TeamingError(Exception):
    """ Base class module exceptions 
        generic exception 
    """
    def __init__(self, msg=''):
        """Create exception instance with attributes
           msg is description
           args is tuple of (msg,)
        """
        self.msg = msg
        self.args = (self.msg,)
    
    def __str__(self):
        """Return string version of exception"""
        return ("%s." % (self.msg))


def fetchTeam(name=""):
    """ fetch team from teams by name
        returns None if not found
    """
    if not name:
        return None
    
    for team in teams.values():
        if team.name == name:
            return team
    return None

def fetchPlayer(name=""):
    """ fetch player from players by name
        returns None if not found
    """
    if not name:
        return None
    
    for player in players.values():
        if player.name == name:
            return player
    return None

def newTeam(name=None):
    """ Create new team and add to teams
        Team names must be unique
    """
    if name:
        name = name.strip()
    
    if fetchTeam(name):
        raise TeamingError("Team with name '%s' already exists." % name )
    
    team = Team(name=name)
    teams[team.tid] = team
    
    return team

def newPlayer(name="", health=None, skill=None, team=None):
    """ Create player and add to players.
        Also Add to team if given
    """
    name = name.strip()
    if not name:
        raise TeamingError("Player name must not be empty.")
    
    if health is None:
        health = random.randint(1, MAX_HEALTH)
    if skill is  None:
        skill =  random.randint(1, MAX_SKILL)
    
    health = min(MAX_HEALTH, max(3, int(health)))
    skill = min(MAX_SKILL, max(1, int(skill)))
    
    player = Player(name=name, health=health, skill=skill)
    players[player.pid] = player
    
    if team:
        team.addPlayer(player)
    
    return player
        

class Player(brining.Brine):
    """ Player class """
    _Pid = 0 # unique player id class attribute 
    _Keys =  ['pid', 'name', 'health',  'skill', 'tid']
    
    def __init__(self, name="", health=5, skill=2):
        """ Initialize"""
        Player._Pid += 1
        self.pid = "p%03d" % Player._Pid
        while self.pid in players.keys():
            Player._Pid += 1
            self.pid = "p%03d" % Player._Pid
            
        self.name = name.strip()
        self.health = int(health)
        self.skill = int(skill)
        self.tid = None
    
    def changeTeam(self, team):
        """ Change current .team to team"""
        
        if team and self.tid != team.tid or team is None:
            if self.tid and self.tid in teams:
                teams[self.tid].removePlayer(player=self)
            if team:
                team.addPlayer(self)
        
class Team(brining.Brine):
    """ Team class  """
    _Tid = 0 # unique team id class attribute
    _Keys = ['tid', 'name', 'players']
    
    def __init__(self, name=None):
        """ Init team with unique tid"""
        Team._Tid += 1
        self.tid = "t%03d" % Team._Tid
        while self.tid in teams.keys():
            Team._Tid += 1
            self.tid = "t%03d" % Team._Tid
            
        if not name:
            name = "Team%s" % self.tid
            while fetchTeam(name):
                name = "%s%s" % (name,  random.randint(0, 9))
                                 
        self.name = name.strip()
        self.players = ODict() 
        
    def addPlayer(self, player):
        """ Add player if not already on team
        """
        if not self.players.get(player.pid):
            if player.tid:
                raise TeamError("Must first remove player %s from team %s." %
                    (player.pid, player.tid))
            self.players[player.pid] = player
            player.tid = self.tid
        return self
    
    def removePlayer(self, player):
        """ Remove player if already on team"""
        player = self.players.get(player.pid)
        if player:
            player.tid = None
            del self.players[player.pid]
        return self
    
    def score(self):
        " Compute score"
        score = 0
        for player in self.players.values():
            score += player.skill +  player.health +  random.randint(0, 5)
        return score


#def saveCouchdb():
    #doc = dict(players= json.loads(json.dumps(players, default=brining.default, indent=2)),
                #teams=json.loads(json.dumps(teams, default=brining.default, indent=2)))
    #db.save(doc)
    #db.commit()


team = newTeam(name="Red")
newPlayer(name='John', team=team)
newPlayer(name='Betty', team=team)

team = newTeam(name="Blue")
newPlayer(name='Sally', team=team)
newPlayer(name='Peter', team=team)


#couch = couchdb.Server()
#db = couch[DATABASE_NAME]
#logger.info("Using couchdb %s" % db)
#ids = [id_ for  id_ in db]
#if not ids or not (db[ids[-1]].get('players') and db[ids[-1]].get('teams')):
    #team = newTeam(name="Red")
    #newPlayer(name='John', team=team)
    #newPlayer(name='Betty', team=team)
    
    #team = newTeam(name="Blue")
    #newPlayer(name='Sally', team=team)
    #newPlayer(name='Peter', team=team)
    
    #doc = dict(players= json.loads(json.dumps(players, default=brining.default, indent=2)),
                #teams=json.loads(json.dumps(teams, default=brining.default, indent=2)))
    #db.save(doc)

#ids = [id_ for  id_ in db]
#latest = ids[-1]
#doc = db[latest]
#logger.info(doc)

#players = brining.debrines(json.dumps(doc['players'],
                                      #default=brining.default, indent=2),
                           #classes=[Player])
#teams = brining.debrines(json.dumps(doc['teams'],
                                    #default=brining.default, indent=2),
                         #classes=[Player, Team])


for tid, team in teams.items():
    print tid, team.tid, team.name
    for pid, player in team.players.items():
        print pid, player.pid, player.name, player.tid


