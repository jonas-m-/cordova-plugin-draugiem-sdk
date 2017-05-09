var exec = require('cordova/exec');

exports.ERROR_INIT_NOT_CALLED = 1000;
exports.ERROR_UNKNOWN = 1001;
exports.ERROR_JSON = 1002;
exports.ERROR_NO_APP = 1003;

exports.login = function(success, error) {
    exec(success, error, "DraugiemApi", "login");
};

exports.init = function(apiKey, success, error) {
    exec(success, error, "DraugiemApi", "init", [apiKey]);
};
