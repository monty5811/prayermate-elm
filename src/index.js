const { Elm } = require('./Main.elm');

require('./about.md');
require('../node_modules/tailwindcss/dist/tailwind.min.css');
require('./elm-datepicker.css');

const LOCAL_STORAGE_KEY = 'pm-cached-value-v1';

function save2LS(newValue) {
  localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(newValue));
}

function registerSW() {
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker
        .register('/sw.js')
        .then(function(registration) {
          console.log('SW registered: ', registration);
        })
        .catch(function(registrationError) {
          console.log('SW registration failed: ', registrationError);
        });
    });
  }
}

function handleDOMContentLoaded() {
  // setup elm
  const app = Elm.Main.init({
    flags: { cachedData: localStorage.getItem(LOCAL_STORAGE_KEY) || '' },
  });
  app.ports.saveData.subscribe(function(data) {
    save2LS(data);
  });

  app.ports.fileSelected.subscribe(function readFile(id) {
    var node = document.getElementById(id);
    if (node === null) {
      return;
    }
    // only grab one file
    var file = node.files[0];
    var reader = new FileReader();

    reader.onload = function(event) {
      // The event carries the `target`. The `target` is the file
      // that was selected. The result is base64 encoded contents of the file.
      var base64encoded = event.target.result;
      var portData = {
        contents: base64encoded,
        filename: file.name,
        id: id,
      };
      app.ports.fileContentRead.send(portData);
    };

    reader.readAsText(file);
  });

  app.ports.openDropboxChooser.subscribe(function openDb() {
    const options = {
      success: function(files) {
        app.ports.dropboxLinkRead.send(files[0].link);
      },
      linkType: 'direct',
      multiselect: false,
      extensions: ['.json'],
      folderselect: false,
    };
    Dropbox.choose(options);
  });

  registerSW();
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
