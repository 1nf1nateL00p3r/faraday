// Faraday Penetration Test IDE
// Copyright (C) 2013  Infobyte LLC (http://www.infobytesec.com/)
// See the file 'doc/LICENSE' for the license information

angular.module('faradayApp')
    .factory('vulnsManager',
        ['Vuln', 'WebVuln', '$q', 'ServerAPI', 'commonsFact',
        function(Vuln, WebVuln, $q, ServerAPI, commonsFact) {
        var vulnsManager = {};

        vulnsManager.createVuln = function(ws, data) {
            var parents = data.parents,
            promises = [];

            parents.forEach(function(parent) {
                // we iterate parents when creating multiple vulns from new vuln modal.
                data.parent = parent.id;
                data.parent_type = parent.type

                if(data.type == "Vulnerability") {
                    var vuln = new Vuln(ws, data);
                } else {
                    var vuln = new WebVuln(ws, data);
                }

                promises.push(vuln.save());
            });

            return $q.all(promises);
        };

        vulnsManager.deleteVuln = function(vuln) {
            return vuln.remove();
        };

        vulnsManager.getVulns = function(ws, page, page_size, filter, sort, sort_direction) {
            var deferred = $q.defer();
            var options = {page: page, page_size: page_size, sort:sort, sort_dir: sort_direction}
            for( var property in filter ) {
                if (filter.hasOwnProperty(property)) {
                    options[property] = filter[property];
                }
            };
            ServerAPI.getVulns(ws, options)
                .then(function(response) {
                    var result = {
                        vulnerabilities: [],
                        count: 0
                    };

                    for(var i = 0; i < response.data.vulnerabilities.length; i++) {
                        var vulnData = response.data.vulnerabilities[i].value;
                        try {
                            if(vulnData.type == "Vulnerability") {
                                var vuln = new Vuln(ws, vulnData);
                            } else {
                                var vuln = new WebVuln(ws, vulnData);
                            }
                            result.vulnerabilities.push(vuln);
                        } catch(e) {
                            console.log(e.stack);
                        }
                    }

                    result.count = response.data.count
                    deferred.resolve(result);
                }, function(response) {
                    deferred.reject("Unable to retrieve vulnerabilities from server");
                });
            return deferred.promise;
        };

        vulnsManager.updateVuln = function(vuln, data) {
            return vuln.update(data);
        };

        return vulnsManager;

    }]);
