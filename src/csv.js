const Elm = require('./CSVWorker.elm');

exports.handler = function(event, context, callback) {
  const app = Elm.csvWorker({
    event: event,
    now: Date.now(),
  });

  app.ports.toJS.subscribe(function(data) {
    if (data[0] == 'ok') {
      callback(null, {
        statusCode: 200,
        body: JSON.stringify(data[1]),
      });
    } else {
      callback(null, {
        statusCode: 500,
        body: 'error',
      });
    }
  });
};
