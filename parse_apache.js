var parser = require("./grammar")
var fs = require("fs");

const output = {};

process.on('exit', function exitHandler(exitCode) {
  if (exitCode === 0) {
    try {
      fs.writeFileSync('parsedApache.json', JSON.stringify(output, undefined, 2), 'utf-8')
    } catch (e) {
      console.log(e)
    }
  }
});


fs.readdir("output", function(err, servers) {
  if (err) {
    console.log(err)
    return
  }
  servers.forEach(function (server) {
    const path = "output/" + server + "/apache-sites"
    fs.stat(path, function (err, statInfo) {
      if (err) {
        if (err.errno === -2) {
          // console.log(path + " does not exist");
        } else {
          console.log(err)
        }
        return
      }
      if (!statInfo.isDirectory()) {
        console.log(path + " is not a directory");
        return
      }
      fs.readdir(path, function(err, configs) {
        if (err) {
          console.log(err)
          return
        }
        configs.filter(c => c.endsWith(".conf")).forEach(function (config) {
          const configPath = path + "/" + config
          fs.readFile(configPath, 'utf-8', function (err, content) {
            if (err) {
              console.log(err)
              return
            }
            try {
              let result = parser.parse(content);
              output[server + "/" + config] = result;
            } catch (e) {
              console.log(`error while parsing ${configPath}.`);
              if (e.message && e.location) {
                console.log(e.message);
                console.log(`at line:${e.location.start.line} column:${e.location.start.column}\n`);
              } else {
                console.log(e);
              }
            }
          });
        });
      })
    })
  });
});