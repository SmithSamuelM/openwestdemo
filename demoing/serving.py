#!/usr/local/bin/python2.7

""" Runs bottle.py wsgi server
    Interface to Bottle application
    To get usage
    
    $ ./serving.py -h
    
    Runs embedded wsgi server when run directly as __main__.
    The server is at http://localhost:port or http://127.0.0.1:port
    The default port is 8080
    The root path is http://localhost:port
    and routes below are relative to this root path so
    "/" is http://localhost:port/
     
"""
import argparse
import signal

import gevent
from gevent import monkey
monkey.patch_all()

import bottle

import demoing
from demoing import helps

if __name__ == "__main__":
    """Process command line args """
    
    levels = demoing.helps.LEVELS #map of strings to logging levels
    
    d = "Runs localhost wsgi service on given host address and port. "
    d += "\nDefault host:port is localhost:8080."
    p = argparse.ArgumentParser(description = d)
    p.add_argument('-d','--debug',
                    action = 'store_const',
                    const = True,
                    default = False,
                    help = "Debug mode.")
    p.add_argument('-l','--level',
                    action='store',
                    default='info',
                    choices=levels.keys(),
                    help="Logging level.")     
    p.add_argument('-r','--reload',
                    action = 'store_const',
                    const = True,
                    default = False,
                    help = "Server reload mode if also in debug mode.")
    p.add_argument('-p','--port', 
                    action = 'store',
                    nargs='?', 
                    const='8080', 
                    default='8080',
                    help = "Wsgi server ip port.")
    p.add_argument('-a','--host', 
                    action = 'store',
                    nargs='?', 
                    const='0.0.0.0', 
                    default='0.0.0.0',
                    help = "Wsgi server ip host address.")
    p.add_argument('-s','--server', 
                    action = 'store',
                    nargs='?', 
                    const='gevent', 
                    default='gevent',
                    help = "Wsgi server type.")

    args = p.parse_args()
    
    logger = helps.getLogger()    
    logger.setLevel(levels[args.level])
    logger.info("Running web application with server %s on %s:%s" %
                (args.server, args.host, args.port))
    if args.debug:
        logger.info("Running in debug mode")
    logger.info("Logger %s at level %s." % (logger.name, args.level))
    
    
    gevent.signal(signal.SIGQUIT, gevent.shutdown)    
    
    from demoing.ends import app
    
    if args.debug:   #default server
        bottle.run(app=app,
                   host=args.host,
                   port=args.port,
                   debug=args.debug, 
                   reloader=args.reload)

    else:
        bottle.run(app=app,
                   server=args.server,
                   host=args.host,
                   port=args.port,
                   debug=args.debug,)
        