""" Rest endpoint package """
import bottle

BASE_PATH = '/owd' # application base, proxy forwards anything starting with this
app = bottle.default_app()

#now import ends modules
from . import erroring
from . import ending
from .. import files 

#app.mount(BASE_PATH, app) #remount app to be behind BASE_PATH for proxy
# http://localhost:8080/demo/test

old = bottle.app.pop()
app = bottle.app.push()
app.mount(BASE_PATH, old)