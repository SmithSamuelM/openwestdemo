# To compile do
# $ coffee -c app.coffee 
# this creates app.js in same directory
# To automatically compile
# $ coffee -w -c app.coffee &


# angular.module() call registers demo for injection into other angular components
# assign to window.myApp if we want to have a global handle to the module

# Main App Module 
myApp = angular.module("myApp", ['gold', 'teamService', 'playerService', 'teamCompeteService'])

myApp.config ["$locationProvider", "$routeProvider",
    ($locationProvider, $routeProvider) ->
        $locationProvider.html5Mode(true)
        
        #using absolute urls here in html5 mode
        base = '/owd' # for use in coffeescript string interpolation #{base}
        $routeProvider.when("#{base}/app",
            templateUrl: "#{base}/static/files/home.html"
            controller: "HomeCtlr"
        ).when("#{base}/app/edit",
            templateUrl: "#{base}/static/files/edit.html"
            controller: "EditCtlr"
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

myApp.filter('express', () ->
        suppress = (input, flag) ->
            if !!flag
                output = input
            else
                output = null
            return output
        
        return suppress
)


myApp.controller('NavbarCtlr', ['$scope', '$routeParams', '$location', '$route',
    ($scope, $routeParams, $location, $route) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("NavbarCtlr")
        
        $scope.alertMsg = ''
        
        $scope.navActive = 
            'home' : 'inactive'
            'edit' : 'inactive'
            'team'  : 'inactive'
            'player'  : 'inactive'
        
        $scope.pathNav ?= 
            "/app$": "home"
            "/app/edit": "edit"
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
    'TeamService', 'PlayerService', 'TeamCompeteService',
    ($scope, $location, $route, TeamService, PlayerService, TeamCompeteService) ->
        $scope.$location = $location
        $scope.$route = $route
        $scope.location = window.location
        
        console.log("HomeCtlr")
        $scope.errorMsg = ""
        
        $scope.teamOptions = []
        $scope.updateTeamOptions = () ->
            teamOptions = [{name: "None", tid: null}]
            for team in $scope.teams
                teamOptions.push({name: team.name, tid: team.tid})
            $scope.teamOptions = teamOptions
            return true
            
        $scope.teams = TeamService.query({id: ""},
            (data, headers) ->
                $scope.errorMsg = ''
                $scope.updateTeamOptions()
                return true
            ,
            (response) ->
                $scope.errorMsg=response.data?.error or response.data
                return true
            )
        $scope.players = PlayerService.query({id: ""})
        
        $scope.compete = (tid1, tid2) ->
            if tid1 == tid2 or !tid1 or !tid2
                return false
            
            $scope.competePromise = TeamCompeteService.call($scope, {tid1: tid1, tid2:tid2})
            $scope.competePromise.success( (data,status, headers, config) ->
                console.log("Compete success")
                $scope.winner = data['winner']
                return true
            )
            return true
            
        
        return true
])

myApp.controller('EditCtlr', ['$scope', '$routeParams', '$location', '$route', 
    'TeamService', 'PlayerService',
    ($scope, $routeParams, $location, $route, TeamService, PlayerService) ->
        $scope.location = $location
        $scope.route = $route
        $scope.winLoc = window.location
        
        console.log("EditCtlr")
        
        $scope.errorMsg = ""
        
        $scope.pid = $routeParams.pid
        if not $scope.pid
            $scope.pid = 1
        
        $scope.defaultTeamValues =
            tid: null
            name: null
        
        $scope.invalidTeam = (index) ->
            keys = ['name']
            for key in keys
                error = $scope.teamsForm["teamForm" + index]?[key].$error
                for key, value of error
                    if value
                        return true
            return false    
        
        $scope.teamOptions = []
        $scope.updateTeamOptions = () ->
            teamOptions = [{name: "None", tid: null}]
            for team in $scope.teams
                teamOptions.push({name: team.name, tid: team.tid})
            $scope.teamOptions = teamOptions
            return true
        
        $scope.teams = []
        $scope.refreshTeams = () ->    
            $scope.teamsRefreshed = TeamService.query({id: ""},
                (data, headers) ->
                    console.log("TeamService query success")
                    console.log(data)
                    console.log(headers())
                    #console.log($scope.teamsRefreshed)
                    $scope.teams = $scope.teamsRefreshed # avoids flicker
                    $scope.errorMsg = ''
                    $scope.updateTeamOptions()
                    return true
                ,
                (response) ->
                    console.log("TeamService query fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
        
        $scope.refreshTeams()
        
        $scope.createTeam = () ->
            team = TeamService.create({}, $scope.defaultTeamValues,
                (data, headers) ->
                    console.log("TeamService create success")
                    console.log(data)
                    console.log(headers())
                    $scope.refreshTeams()
                    $scope.errorMsg = ""
                    return true
                ,
                (response) ->
                    console.log("TeamService create fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
                )
            return true
        
        $scope.readTeam = (team) -> 
            team = tream.$read({},
                (data,headers)->
                    console.log("TeamService read success")
                    console.log(data)
                    console.log(headers())
                    $scope.refreshTeams()
                    $scope.errorMsg = ""
                    return true
                ,
                (response)->
                    console.log("TeamService read fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
            return true
        
        $scope.updateTeam = (team, index) -> 
            if $scope.invalidTeam(index)
                return false
                
            team.$update({},
                (data,headers)->
                    console.log("TeamService update success")
                    console.log(data)
                    console.log(headers())
                    #$scope.refreshTeams()
                    $scope.updateTeamOptions()
                    $scope.errorMsg = ""
                    return true
                ,
                (response)->
                    console.log("TeamService update fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
            return true
        
        $scope.deleteTeam = (team) -> 
            team = angular.copy(team) #to avoid flicker
            result = team.$delete({id: team.tid},
                (data,headers)->
                    console.log("TeamService delete success")
                    console.log(data)
                    console.log(headers())
                    $scope.refreshTeams()
                    $scope.errorMsg = ""
                    return true
                ,
                (response)->
                    console.log("TeamService delete fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
            return true
            
        $scope.defaultPlayerValues =
            pid: null
            name: "Nobody"
            health: 4
            skill: 4
            tid: null
        
        $scope.invalidPlayer = (index) ->
            keys = ['name', 'health', 'skill']
            for key in keys
                error = $scope.playersForm["playerForm" + index]?[key].$error
                for key, value of error
                    if value
                        return true
            return false    
            
        $scope.refreshPlayers = () ->
            $scope.playersRefreshed = PlayerService.query({id: ""},
                (data, headers) ->
                    console.log("PlayerService query success")
                    console.log(data)
                    console.log(headers())
                    #console.log($scope.playersRefreshed)
                    $scope.players = $scope.playersRefreshed # avoids flicker
                    $scope.errorMsg = ''
                    return true
                ,
                (response) ->
                    console.log("PlayerService query fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
        
        $scope.players = []
        $scope.refreshPlayers()
        
        $scope.createPlayer = () ->
            player = PlayerService.create({}, $scope.defaultPlayerValues,
                (data, headers) ->
                    console.log("PlayerService create success")
                    console.log(data)
                    console.log(headers())
                    $scope.refreshPlayers()
                    $scope.errorMsg = ""
                    return true
                ,
                (response) ->
                    console.log("PlayerService create fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
                )
            return true
        
        $scope.readPlayer = (player) -> 
            player = player.$read({},
                (data,headers)->
                    console.log("PlayerService read success")
                    console.log(data)
                    console.log(headers())
                    $scope.refreshPlayers()
                    $scope.errorMsg = ""
                    return true
                ,
                (response)->
                    console.log("PlayerService read fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
            return true
        
        $scope.updatePlayer = (player, index) -> 
            if $scope.invalidPlayer(index)
                return false
                
            player.$update({},
                (data,headers)->
                    console.log("PlayerService update success")
                    console.log(data)
                    console.log(headers())
                    #$scope.refreshPlayers()
                    $scope.errorMsg = ""
                    return true
                ,
                (response)->
                    console.log("PlayerService update fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
            return true
        
        $scope.deletePlayer = (player) -> 
            player = angular.copy(player) #to avoid flicker
            result = player.$delete({id: player.pid},
                (data,headers)->
                    console.log("PlayerService delete success")
                    console.log(data)
                    console.log(headers())
                    $scope.refreshPlayers()
                    $scope.errorMsg = ""
                    return true
                ,
                (response)->
                    console.log("PlayerService delete fail")
                    console.log(response)
                    console.log(response.data?.error)
                    console.log(response.headers())
                    $scope.errorMsg=response.data?.error or response.data
                    return true
            )
            return true
        
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
        
        $scope.players = []
        
        $scope.reloadPlayers = () ->
            # convert hash of players to array of players
            players = []
            for pid, player of $scope.team.players
                players.push(player)
            $scope.players = players
            return true
        
        $scope.team = []
        
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
            
        return true
])


