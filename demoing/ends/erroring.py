""" Error handling
    Error methods do not automatically jsonify dicts so must manually do so.
"""
import simplejson as json

import bottle

from ..ends import app

@app.error(400)
def error400(ex):
    bottle.response.set_header('content-type', 'application/json')
    return json.dumps(dict(error=ex.body))

@app.error(404)
def error404(ex):
    """ Use json 404 if request accepts json otherwise use html"""
    if 'application/json' not in bottle.request.get_header('Accept', ""):
        bottle.response.set_header('content-type', 'text/html')
        return bottle.tonat(bottle.template(bottle.ERROR_PAGE_TEMPLATE, e=ex))
    
    bottle.response.set_header('content-type', 'application/json')    
    return json.dumps(dict(error=ex.body))


@app.error(405)
def error405(ex):
    bottle.response.set_header('content-type', 'application/json')
    return json.dumps(dict(error=ex.body))

@app.error(409)
def error409(ex):
    bottle.response.set_header('content-type', 'application/json')
    return json.dumps(dict(error=ex.body))


