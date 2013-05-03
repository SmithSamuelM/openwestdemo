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
# $scope.actionPromise = TeamActionService.call(tid, 'compete')
# sends post to "/owd/team/2/compete"

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
                    $scope.alert=data?.error or data
                    return true
                )
        }
    ] 

