// Faraday Penetration Test IDE
// Copyright (C) 2018  Infobyte LLC (http://www.infobytesec.com/)
// See the file 'doc/LICENSE' for the license information

angular.module('faradayApp')
    .controller('headerCtrl',
        ['$scope', '$routeParams', '$location', 'dashboardSrv', 'workspacesFact', 'vulnsManager',
        function($scope, $routeParams, $location, dashboardSrv, workspacesFact, vulnsManager) {

            $scope.showSwitcher = function() {
                var noSwitcher = ["", "home", "login", "index", "vulndb", "credentials", "workspaces", "users", "licenses"];
                return noSwitcher.indexOf($scope.component) < 0;
            };
            
            $scope.getVulnsNum = function() {
                return vulnsManager.getVulnsNum();
            };

            init = function(name) {
                $scope.location = $location.path().split('/')[1];
                $scope.workspace = $routeParams.wsId;
                $scope.workspaces = [];

                workspacesFact.list().then(function(wss) {
                    $scope.workspaces = wss;
                });
            };

            init();
    }]);
