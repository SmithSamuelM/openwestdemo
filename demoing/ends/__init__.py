""" Rest endpoint package """
import bottle

BASE_PATH = '/owd' # application base, proxy forwards anything starting with this
app = bottle.default_app()

#now import ends modules
import erroring
import ending

#app.mount(BASE_PATH, app) #remount app to be behind BASE_PATH for proxy
# http://localhost:8080/demo/test