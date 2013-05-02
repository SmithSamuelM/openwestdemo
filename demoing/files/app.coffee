# To compile do
# $ coffee -c app.coffee 
# this creates app.js in same directory
# To automatically compile
# $ coffee -w -c app.coffee &


# angular.module() call registers demo for injection into other angular components
# assign to window.myApp if we want to have a global handle to the module

# Main App Module 
myApp = angular.module("myApp", ['gold', 'teamService', 'playerService'])

myApp.config ["$locationProvider", "$routeProvider",
    ($locationProvider, $routeProvider) ->
        $locationProvider.html5Mode(true)
        
        #using absolute urls here in html5 mode
        base = '/owd' # for use in coffeescript string interpolation #{base}
        $routeProvider.when("#{base}/app",
            templateUrl: "#{base}/static/files/home.html"
            controller: "HomeCtlr"
        ).when("#{base}/app/team",
            templateUrl: "#{base}/static/files/team.html"
            controller: "TeamCtlr"
        ).when("#{base}/app/team/:tid",
            templateUrl: "#{base}/static/files/team.html"
            controller: "TeamCtlr"
        ).when("#{base}/app/player",
            templateUrl: "#{base}/static/files/player.html"
            controller: "PlayerCtlr"
        ).when("#{base}/app/player/:pid",
            templateUrl: "#{base}/static/files/player.html"
            controller: "PlayerCtlr"
        ).otherwise redirectTo: "#{base}/app"
        return true
]

myApp.controller('NavbarCtlr', ['$scope', '$routeParams', '$location', '$route',
    ($scope, $routeParams, $location, $route) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("NavbarCtlr")
        
        $scope.alertMsg = ''
        
        $scope.navActive = 
            'home' : 'inactive'
            'team'  : 'inactive'
            'player'  : 'inactive'
        
        $scope.pathNav ?= 
            "/app$": "home"
            "/app/team": "team"
            "/app/player": "player"
        
        $scope.activateNav = (nav) ->
            $scope.navActive[nav] = 'active'
            for x of $scope.navActive
                if x != nav
                    $scope.navActive[x] = 'inactive'
            return true
        
        $scope.updateNav = (newPath, oldPath) ->
            #only called when value different except first time
            for path, nav of $scope.pathNav
                if newPath.match(path)?
                    $scope.activateNav(nav)
                    return true
            return true
        
        $scope.$watch('location.path()', (newPath, oldPath) ->
            $scope.updateNav(newPath, oldPath)
            return true
        )

        return true
])

myApp.controller('HomeCtlr', ['$scope', '$location', '$route', 
    'TeamService', 'PlayerService',
    ($scope, $location, $route, TeamService, PlayerService) ->
        $scope.$location = $location
        $scope.$route = $route
        $scope.location = window.location
        
        console.log("HomeCtlr")
        $scope.teams = TeamService.query({id: ""})
        $scope.players = PlayerService.query({id: ""})
        
        
        return true
])


myApp.controller('TeamCtlr', ['$scope', '$routeParams', '$location', '$route', 
    'TeamService', 'PlayerService',
    ($scope, $routeParams, $location, $route, TeamService, PlayerService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("TeamCtlr")
        $scope.errorMsg = ''
        $scope.players = []
        $scope.tid = $routeParams.tid
        if not $scope.tid
            $scope.tid = 1
            
        $scope.reloadPlayers = () ->
            # convert hash of players to array of players
            players = []
            for pid, player of $scope.team.players
                players.push(player)
            $scope.players = players
            return true
                
        $scope.team = TeamService.get({id: $scope.tid},
            (data, headers) ->
                console.log("TeamService get success")
                console.log(data)
                console.log(headers())
                console.log($scope.team)
                $scope.tid = $scope.team.tid
                $scope.errorMsg = ''
                $scope.reloadPlayers()
                return true
            ,
            (response) ->
                console.log("TeamService get fail")
                console.log(response)
                console.log(response.data?.error)
                console.log(response.headers())
                $scope.errorMsg=response.data?.error or response.data
                return true
            )
        
        return true
])

myApp.controller('PlayerCtlr', ['$scope', '$routeParams', '$location', '$route', 
    'TeamService', 'PlayerService',
    ($scope, $routeParams, $location, $route, TeamService, PlayerService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("PlayerCtlr")
        
        
        $scope.pid = $routeParams.pid
        if not $scope.pid
            $scope.pid = 1
            
        $scope.kindOptions = ['good','bad']

        $scope.player = PlayerService.get({id: $scope.pid},
            (data, headers) ->
                console.log("PlayerService get success")
                console.log(data)
                console.log(headers())
                console.log($scope.player)
            ,
            (response) ->
                console.log("PlayerService get fail")
                console.log(response)
                console.log(response.headers())
            )
        
        $scope.savePlayer = (pid) -> 
            $scope.errored=false
            $scope.alert=""
            if $scope.playerForm.$invalid
                $scope.playerForm.$dirty = true
                $scope.errored = true
                $scope.alert = "Some values are missing or invalid."
                return
            
            $scope.player.$put({},
                (data,headers)->
                    console.log("PlayerService put success")
                    console.log(data)
                    console.log(headers())
                ,
                (response)->
                    console.log("PlayerService put fail")
                    console.log(response)
                    console.log(response.headers())
            )
        
        return true
])


myApp.controller('DirectiveCtlr', ['$scope', '$location', '$route', 
    'TeamService', 'PlayerService',
    ($scope, $location, $route, TeamService, PlayerService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("DirectiveCtlr")

        
        return true
])

# To compile do
# $ coffee -c jct.coffee 
# this creates jct.js in same directory
# To automatically compile
# $ coffee -w -c jct.coffee &


# angular.module() call registers jct for injection into other angular components
# assign to window.jct if we want to have a global handle to the module

# Main App Module 
jct = angular.module("jct", ['gold', 'statusActionService'])

jct.config ["$provide", "$locationProvider", "$routeProvider",
    ($provide, $locationProvider, $routeProvider) ->
        $locationProvider.html5Mode(true)
        # use absolute urls because in html5 mode
        base = '/jct' 
        #$provide.constant('basePath', base) #constant
        # coffeescript string interpolation #{base}
        $routeProvider.when("#{base}/app",
            templateUrl: "#{base}/static/files/status.html"
            controller: "StatusCtlr"
        ).when("#{base}/app/status",
            templateUrl: "#{base}/static/files/status.html"
            controller: "StatusCtlr"
        ).when("#{base}/app/edit",
            templateUrl: "#{base}/static/files/edit.html"
            controller: "EditCtlr"
        ).when("#{base}/app/edit/:pid",
            templateUrl: "#{base}/static/files/edit.html"
            controller: "EditCtlr"
        ).otherwise redirectTo: "#{base}/app"
        return true
]

jct.controller('NavbarCtlr', ['$scope', '$routeParams', '$location', '$route',
    ($scope, $routeParams, $location, $route) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("NavbarCtlr")
        
        $scope.alert = ''
        
        $scope.navActive = 
            'status'  : 'inactive'
        
        $scope.pathNav ?= 
            "/app$": "status"
            "/app/status": "status"
        
        $scope.activateNav = (nav) ->
            $scope.navActive[nav] = 'active'
            for x of $scope.navActive
                if x != nav
                    $scope.navActive[x] = 'inactive'
            return true
        
        $scope.updateNav = (newPath, oldPath) ->
            #only called when value different except first time
            for path, nav of $scope.pathNav
                if newPath.match(path)?
                    $scope.activateNav(nav)
                    return true
            return true
        
        $scope.$watch('location.path()', (newPath, oldPath) ->
            $scope.updateNav(newPath, oldPath)
            return true
        )

        return true
])


jct.controller('StatusCtlr', ['$scope', '$routeParams', '$location', '$route',
    '$http', 'StatusActionService',
    ($scope, $routeParams, $location, $route, $http, StatusActionService) ->
        $scope.$location = $location
        $scope.$route = $route
        $scope.location = window.location
        
        console.log("StatusCtlr")
        
        $scope.alert = ''
        
        $scope.status = {}
        $scope.tests = []
        
        $scope.failedCls = (test) -> 
            if test?.state == false
                return "error"
            return ""
            
        $scope.updateTests = (status) ->
            tests = []
            for name, state of status
                if state == true
                    state = 'Pass'
                else if state == false
                    state = "Fail"
                else
                    state = 'Unknown'
                name = name.replace(/^test/, "")
                tests.push({name: name, state: state})
            $scope.tests = tests
            return true
                
        $scope.refreshStatus = () -> 
            $scope.actionPromise = StatusActionService.call($scope, 'refresh')
            $scope.actionPromise.success( (data,status, headers, config) ->
                console.log("Edit View Refresh Promise success")
                console.log(config)
                console.log(status)
                console.log(headers())
                console.log(data)
                $scope.status = data
                $scope.updateTests($scope.status)
                return true
            )
            return true
        
        $scope.refreshStatus()
        
        
        return true
])

