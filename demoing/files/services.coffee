# Services modules
# 
# Angular $resource default methods are:
#  'get':    {method:'GET'},
#  'save':   {method:'POST'},
#  'query':  {method:'GET', isArray:true},
#  'remove': {method:'DELETE'},
#  'delete': {method:'DELETE'}
#

base = '/owd'

#usage
# $scope.teams = TeamService.query({id: ""})
# $scope.team = TeamService.read({id: tid})
# #$scope.team.$update({})
# $scope.team.$delete({})
# $scope.team = TeamService.create({}, {name: "Green"})

angular.module("teamService", ["ngResource"]).factory "TeamService", 
    ['$resource', ($resource) -> $resource "#{base}/team/:id", 
        {id: '@tid'},
        create:
            method: 'POST'
            params: {id: ''}
        read: 
            method: 'GET'
            params: {}
        update: 
            method: 'PUT'
            params: {}
    ]

#usage
# $scope.players = PlayerService.query({id: ""})
# $scope.player = PlayerService.read({id: pid})
# $scope.player.$update({})
# $scope.player.$delete({})
# $scope.player = PlayerService.create({}, {name: "John", health: 2, skill: 3, tid: null})

angular.module("playerService", ["ngResource"]).factory "PlayerService", 
    ['$resource', ($resource) -> $resource "#{base}/player/:id", 
        {id: '@pid'},
        create:
            method: 'POST'
            params: {id: ''}
        read: 
            method: 'GET'
            params: {}
        update: 
            method: 'PUT'
            params: {}
        
    ]



#usage
# tid = 2
# $scope.actionPromise = TeamActionService.call($scope, tid, 'practice')
# sends post to "/owd/team/2/practice"

angular.module("teamActionService", []).factory "TeamActionService", 
    ['$http', ($http) -> 
        { #object literal
            call: ($scope, tid, action) -> 
                $http.get( "#{base}/team/#{tid}/#{action}" )
                .success((data, status, headers, config) ->
                    console.log("TeamActionService #{tid} #{action} success")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log("TeamActionService failure")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    $scope.errorMsg=data?.error or data
                    return true
                )
        }
    ] 

#usage
# tid1 = 2
# tid2 = 3
# $scope.actionPromise = TeamCompleteService.call($scope, {tid1: tid1, tid2,})
# sends post to "/owd/team/compete"

angular.module("teamCompeteService", []).factory "TeamCompeteService", 
    ['$http', ($http) -> 
        { #object literal
            call: ($scope, params) -> 
                $http.get( "#{base}/team/compete", {params: params} )
                .success((data, status, headers, config) ->
                    console.log("TeamCompeteService #{params}")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log("TeamCompeteService failure")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    $scope.errorMsg=data?.error or data
                    return true
                )
        }
    ] 
