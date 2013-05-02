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

angular.module("teamService", ["ngResource"]).factory "TeamService", 
    ['$resource', ($resource) -> $resource "#{base}/team/:id", 
        {id: '@id'},
        put: 
            method: 'PUT'
            params: {}
    ]
    
angular.module("playerService", ["ngResource"]).factory "PlayerService", 
    ['$resource', ($resource) -> $resource "#{base}/player/:id", 
        {id: '@id'},
        update: 
            method: 'PUT'
            params: {}
        create:
            method: 'POST'
            params: {id: ''}
    ]



angular.module("orderService", ["ngResource"]).factory "OrderService", 
    ['$resource', ($resource) -> $resource "/japn/backend/order/:id", 
        {id: '@pid'},
        update: 
            method: 'PUT'
            params: {}
        create:
            method: 'POST'
            params: {id: ''}
        refresh:
            method: 'GET'
            params: {refresh: ''}
    ]

angular.module("orderActionService", []).factory "OrderActionService", 
    ['$http', 'OrderService', ($http, OrderService) -> 
        { #object literal
            call: ($scope, pid, action) -> 
                $http.post( "/japn/backend/order/#{pid}/#{action}" )
                .success((data, status, headers, config) ->
                    console.log("OrderActionService #{pid} #{action} success")
                    #console.log(config)
                    #console.log(status)
                    #console.log(headers())
                    #console.log(data)
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log("OrderActionService #{pid} #{action} failure")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    $scope.alert=data?.error or data
                    return true
                )
        }
    ] 

#usage
# pid = 2
# $scope.actionPromise = OrderActionService.call(pid, 'refresh')
# sends post to "/japn/backend/order/2/refresh"

    
angular.module("numberService", ["ngResource"]).factory "NumberService", 
    ['$resource', ($resource) -> $resource "/japn/backend/number/:id", 
        {id: '@id'},
        update: 
            method: 'PUT'
            params: {}
        create:
            method: 'POST'
            params: {id: ''}
        refresh:
            method: 'GET'
            params: {refresh: ''}
    ]


angular.module("statusActionService", []).factory "StatusActionService", 
    ['$http', ($http) -> 
        { #object literal
            call: ($scope, action) -> 
                $http.get( "/jct/status" )
                .success((data, status, headers, config) ->
                    console.log("StatusActionService success")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    return true
                )
                .error((data, status, headers, config) -> 
                    console.log("StatusActionService failure")
                    console.log(config)
                    console.log(status)
                    console.log(headers())
                    console.log(data)
                    $scope.alert=data?.error or data
                    return true
                )
        }
    ] 

#usage
# pid = 2
# $scope.actionPromise = OrderActionService.call(pid, 'refresh')
# sends post to "/japn/backend/order/2/refresh"

