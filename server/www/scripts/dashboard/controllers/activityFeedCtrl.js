// Faraday Penetration Test IDE
// Copyright (C) 2016  Infobyte LLC (http://www.infobytesec.com/)
// See the file 'doc/LICENSE' for the license information

'use strict';

angular.module('faradayApp')
    .controller('activityFeedCtrl',
        ['$scope', '$routeParams', 'dashboardSrv',
        function($scope, $routeParams, dashboardSrv) {
            
            var vm = this;
            vm.commands = [];

            // Get last 15 commands
            var init = function() {
                if($routeParams.wsId != undefined) {
                    $scope.workspace = $routeParams.wsId;

                    dashboardSrv.getActivityFeed($scope.workspace)
                        .then(function(response) {
                            vm.commands = response.activities;
                        });
                }
            };

            dashboardSrv.registerCallback(init);
            init();
    }]);