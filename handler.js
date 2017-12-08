const spawn = require('child_process').spawn;

module.exports.crosscurrency = function(event, context, callback) {
  var child  = spawn('./crosscurrency.rb', [JSON.stringify(event)]);
  var stdout = '';
  var stderr = '';

  child.stdout.on('data', function (data) {
    stdout += data.toString();
  });
  child.stderr.on('data', function (data) {
    stderr += data.toString();
  });

  child.on('close', function(code) {
    if (code !== 0) {
      return callback(new Error(`Process exited with non-zero status code: ${code}`));
    }
    if (stderr) {
      console.error(stderr);
    }

    // We expect the child process to output valid JSON with a body
    try {
        var response  = JSON.parse(stdout);
        callback(null, response);
    } catch (error) {
        callback(error);
    }
  });
};
