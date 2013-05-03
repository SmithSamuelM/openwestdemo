// Generated by CoffeeScript 1.6.2
(function() {
  var base;

  base = '/owd';

  angular.module("teamService", ["ngResource"]).factory("TeamService", [
    '$resource', function($resource) {
      return $resource("" + base + "/team/:id", {
        id: '@tid'
      }, {
        create: {
          method: 'POST',
          params: {
            id: ''
          }
        },
        read: {
          method: 'GET',
          params: {}
        },
        update: {
          method: 'PUT',
          params: {}
        }
      });
    }
  ]);

  angular.module("playerService", ["ngResource"]).factory("PlayerService", [
    '$resource', function($resource) {
      return $resource("" + base + "/player/:id", {
        id: '@pid'
      }, {
        create: {
          method: 'POST',
          params: {
            id: ''
          }
        },
        read: {
          method: 'GET',
          params: {}
        },
        update: {
          method: 'PUT',
          params: {}
        }
      });
    }
  ]);

  angular.module("teamActionService", []).factory("TeamActionService", [
    '$http', function($http) {
      return {
        call: function($scope, tid, action) {
          return $http.get("" + base + "/team/" + tid + "/" + action).success(function(data, status, headers, config) {
            console.log("TeamActionService " + tid + " " + action + " success");
            console.log(config);
            console.log(status);
            console.log(headers());
            console.log(data);
            return true;
          }).error(function(data, status, headers, config) {
            console.log("TeamActionService failure");
            console.log(config);
            console.log(status);
            console.log(headers());
            console.log(data);
            $scope.errorMsg = (data != null ? data.error : void 0) || data;
            return true;
          });
        }
      };
    }
  ]);

  angular.module("teamCompeteService", []).factory("TeamCompeteService", [
    '$http', function($http) {
      return {
        call: function($scope, params) {
          return $http.get("" + base + "/team/compete", {
            params: params
          }).success(function(data, status, headers, config) {
            console.log("TeamCompeteService " + params);
            console.log(config);
            console.log(status);
            console.log(headers());
            console.log(data);
            return true;
          }).error(function(data, status, headers, config) {
            console.log("TeamCompeteService failure");
            console.log(config);
            console.log(status);
            console.log(headers());
            console.log(data);
            $scope.errorMsg = (data != null ? data.error : void 0) || data;
            return true;
          });
        }
      };
    }
  ]);

}).call(this);
