""" Rest endpoints
    
"""
import sys
import os.path as path

import simplejson as json

import bottle
import brining

from ..helps import getLogger
from ..ends import app, BASE_PATH
from ..means import teaming

logger = getLogger()

@app.get('/test') 
def testGet():
    """ Show location of this file"""
    bottle.response.set_header('content-type', 'text/plain')
    content =  "Web app file is located at %s" % path.dirname(path.abspath(__file__))
    siteMap = ""
    from ..ends import app #get app at run time incase remounted
    for route in app.routes:
        siteMap = "%s%s%s %s" %  (siteMap, '\n' if siteMap else '', route.rule, route.method)
        target = route.config.get('mountpoint', {}).get('target')
        if target:
            for way in target.routes:
                siteMap = "%s\n    %s %s" %  (siteMap, way.rule, way.method)
                
    content = "%s\n%s" %  (content, siteMap)
    return content


@app.route('/team') #angular strips trailing slash if no <tid>
def teamQueryGet():
    
    name = bottle.request.query.get('name', '')
    teams =  []
    for team in teaming.teams.values():
        if name: #return list of the teams that matches query
            if team['name'] == name: 
               teams.append(team)
        else: #return list of all teams
            teams.append(team._dumpable(deep=True))
            
    bottle.response.set_header('content-type', 'application/json')
    return json.dumps(teams, default=brining.default, indent=2)

@app.get('/team/create/create') #testing only
@app.post('/team') 
def teamCreate():
    """Create team"""     
    data = bottle.request.json
    if not data:
        bottle.abort(400, "Create data missing.")
    
    name =  data.get('name', None)
    if teaming.fetchTeam(name):
        bottle.abort(400, "Team '%s' already exists." % name)
        
    team = teaming.newTeam(name = name)
    
    bottle.response.set_header('content-type', 'application/json')
    return team._dumps()

@app.route('/team/<tid>') 
def teamRead(tid):
    try:
        tid = int(tid)
    except ValueError:
        bottle.abort(400, "Invalid team id %s" % tid)
        
    team = teaming.teams.get(tid, None)
    if not team:
        bottle.abort(404, "Team '%s' not found." % tid)
    
    bottle.response.set_header('content-type', 'application/json')
    return team._dumps()

@app.get('/team/<tid>/update') #testing only
@app.put('/team/<tid>') 
def teamUpdate(tid):
    """Update team"""
    try:
        tid = int(tid)
    except ValueError:
        bottle.abort(400, "Invalid team id %s" % tid)      
    
    team = teaming.teams.get(tid)
    if not team:
        bottle.abort(404, "Team '%s' not found." % (tid,))     
    
    data = bottle.request.json
    if not data:
        bottle.abort(400, "Update data missing.")
    
    data = scrubTeamData(data)
    
    dtid = data.get('tid')
    if dtid and dtid != tid:
        bottle.abort(400, "Tid in request body not match tid in url.")
    
    name = data.get('name')
    if name:
        otherTeam = teaming.fetchTeam(name)
        if otherTeam and otherTeam.tid != team.tid:
            bottle.abort(400, "Team name '%s' already used." % name)
        team.name = name
    
    bottle.response.set_header('content-type', 'application/json')
    return team._dumps()

@app.get('/team/<tid>/remove') #testing only
@app.delete('/team/<tid>') 
def TeamDelete(tid):
    """Delete team"""
    try:
        tid = int(tid)
    except ValueError:
        bottle.abort(400, "Invalid team id %s" % tid)
        
    team = teaming.teams.get(tid)
    if not team:
        bottle.abort(404, "Team '%s' not found." % (tid,))
    
    for player in team.players.values():
        team.removePlayer(player)
    
    del teaming.teams[team.tid]
    
    return {}

@app.get('/team/compete') #testing
@app.post('/team/compete') 
def teamCompete():
    """ Perform compete """
    tid1 = bottle.request.query.get("tid1")
    tid2 = bottle.request.query.get("tid2")
    try:
        tid1 = int(tid1)
    except ValueError:
        bottle.abort(400, "Invalid team id %s" % tid1)
    
    try:
        tid2 = int(tid2)
    except ValueError:
        bottle.abort(400, "Invalid team id %s" % tid2)
    
    
    team1 =  teaming.teams.get(tid1)
    team2 =  teaming.teams.get(tid2)
    winner = None
    if team1 != team2:
        winner = team1 if team1.score() > team2.score() else team2
        
    return dict(winner= winner.name if winner else None)

@app.get('/team/<tid>/<action>') #testing
@app.post('/team/<tid>/<action>') 
def teamAction(tid, action):
    """ Perform action on team
        
    """
    try:
        tid = int(tid)
    except ValueError as ex:
        bottle.abort(400, "Invalid team id %s" % tid)
        
    team = teaming.teams.get(tid, None)
    if not team:
        bottle.abort(404, "Team '%s' not found." % tid)
    
    return dict(action=action, result=True)

def scrubTeamData(data):
    """ Validate team data"""
    for key in data.keys():
        if key not in ['tid', 'name']:
            del data[key]
            
    name = data.get('name')
    if not name:
        bottle.abort(400, "Name required.")
    
    for key in ['tid']:
        if data[key] is not None:
            try:
                data[key] = int(data[key])
            except ValueError, TypeError:
                bottle.abort(400, "Key %s not an integer." % key)
    
    return data

@app.get('/player') #angular strips trailing slash if no <pid>
def playerQuery():
    name = bottle.request.query.get('name', '')
    players = []
    for player in teaming.players.values():
        if name: #return list of the players that matches query
            if player['name'] == name: 
               players.append(player)
        else: #return list of all teams
            players.append(player)
    
    bottle.response.set_header('content-type', 'application/json')
    return json.dumps(players, default=brining.default, indent=2) 

@app.get('/player/create/create') #testing only
@app.post('/player') 
def playerCreate():
    """Create player"""     
    data = bottle.request.json
    if not data:
        bottle.abort(400, "Create data missing.")
    
    data = scrubPlayerData(data)
    
    tid = data.get('tid')
    team = teaming.teams.get(tid) if tid else None
    
    player = teaming.newPlayer(name = data.get('name'), team=team,
                       health=data.get('health'),  skill=data.get('skill'))
    
    return player._dumpable()

@app.get('/player/<pid>') 
def playerRead(pid):
    try:
        pid = int(pid)
    except ValueError:
        bottle.abort(400, "Invalid player id %s" % pid)    
    
    player = teaming.players.get(pid, None)
    if not player:
        bottle.abort(404, "Player '%s' not found." % (pid,))
    
    return player._dumpable()


@app.get('/player/<pid>/update') #testing only
@app.put('/player/<pid>') 
def playerUpdate(pid):
    """Update player"""
    try:
        pid = int(pid)
    except ValueError:
        bottle.abort(400, "Invalid player id %s" % pid)      
    
    player = teaming.players.get(pid)
    if not player:
        bottle.abort(404, "Player '%s' not found." % (pid,))     
    
    data = bottle.request.json
    if not data:
        bottle.abort(400, "Update data missing.")
    
    data = scrubPlayerData(data)
    
    dpid = data.get('pid')
    if dpid and  dpid != pid:
        bottle.abort(400, "Pid in request body not match pid in url.")
        
    if 'tid' in data:
        team = teaming.teams.get(data['tid'])
        player.changeTeam(team)
    
    for key in ['name', 'health', 'skill']:
        if key in data: #only change exiting fields
            setattr(player, key, data[key])
    
    return player._dumpable()

@app.get('/player/<pid>/remove') #testing only
@app.delete('/player/<pid>') 
def PlayerDelete(pid):
    """Delete player"""
    try:
        pid = int(pid)
    except ValueError:
        bottle.abort(400, "Invalid player id %s" % pid)
        
    player = teaming.players.get(pid)
    if not player:
        bottle.abort(404, "Player '%s' not found." % (pid,))
    
    team = teaming.teams.get(player.tid)
    if team:
        team.removePlayer(player)
    
    del teaming.players[player.pid]
    
    return {}

def scrubPlayerData(data):
    """ Validate player data"""
    for key in data.keys():
        if key not in ['pid', 'name', 'skill', 'health', 'tid']:
            del data[key]
            
    name = data.get('name')
    if not name:
        bottle.abort(400, "Name required.")
    
    for key in ['pid', 'skill', 'health', 'tid']:
        if data[key] is not None:
            try:
                data[key] = int(data[key])
            except ValueError, TypeError:
                bottle.abort(400, "Key %s not an integer." % key)
    
    return data