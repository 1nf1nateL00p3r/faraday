// Faraday Penetration Test IDE
// Copyright (C) 2013  Infobyte LLC (http://www.infobytesec.com/)
// See the file 'doc/LICENSE' for the license information

angular.module('faradayApp')
    .controller('vulndDbModalEdit',
                ['$scope', '$modalInstance', 'VulnModel', 'model', 'EXPLOITATIONS', 'EASEOFRESOLUTION',
                 function($scope, $modalInstance, VulnModel, model, EXPLOITATIONS, EASEOFRESOLUTION) {

        $scope.data;
        $scope.openedStart;
        $scope.openedEnd;

        var init = function() {
            $scope.exploitations = EXPLOITATIONS;
            $scope.easeofresolution = EASEOFRESOLUTION;
            $scope.data = new VulnModel;
            $scope.data.set(model);
            $scope.impact = angular.copy($scope.data.impact);
            $scope.policyviolations = angular.copy($scope.data.policyviolations);
            $scope.references = angular.copy($scope.data.refs);
        };

        $scope.ok = function() {
            $scope.data.impact = angular.copy($scope.impact);
            $scope.data.policyviolations = angular.copy($scope.policyviolations);
            $scope.data.refs = angular.copy($scope.references);
            $scope.data.references = $scope.data.refs.join(',');
            $modalInstance.close($scope.data);
        };

        $scope.open = function($event, isStart) {
            $event.preventDefault();
            $event.stopPropagation();

            if(isStart) $scope.openedStart = true; else $scope.openedEnd = true;
        };

        $scope.cancel = function() {
            $modalInstance.dismiss('cancel');
        };

        $scope.toggleImpact = function(key) {
            $scope.impact[key] = !$scope.impact[key];
        };

        $scope.newPolicyViolation = function() {
            if ($scope.new_policyviolation !== "") {
                // we need to check if the policy violation already exists
                if ($scope.policyviolations.filter(function(policyviolation) {return policyviolation === $scope.new_policyviolation}).length === 0) {
                    $scope.policyviolations.push($scope.new_policyviolation);
                    $scope.new_policyviolation = "";
                }
            }
        };

         $scope.newReference = function() {
            if ($scope.new_reference !== "") {
                // we need to check if the reference already exists
                if ($scope.references.filter(function(reference) {return reference === $scope.new_reference}).length === 0) {
                    $scope.references.push($scope.new_reference);
                    $scope.new_reference = "";
                }
            }
        };

        init();
    }]);
