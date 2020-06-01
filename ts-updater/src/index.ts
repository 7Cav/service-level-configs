import { resolve } from "dns";

var fs = require("fs");
var path = require("path");
var Mustache = require("mustache");
var fetch = require("node-fetch");

// Get external data with fetch
const data = fetch(
  "https://raw.githubusercontent.com/7Cav/service-level-configs/master/ts-updater/src/testjson.json"
).then((response: { json: () => any }) => response.json());

// Get external template with fetch
const template = fetch(
  "https://raw.githubusercontent.com/7Cav/service-level-configs/master/ts-updater/src/server.cfg"
).then((response: { text: () => any }) => response.text());
// wait for all the data to be received
Promise.all([data, template])
  .then((res) => {
    const resolvedData = res[0].server.configuration;
    console.log(resolvedData);
    const resolvedTemplate = res[1];

    // Cache the template for future uses
    Mustache.parse(resolvedTemplate);

    var output = Mustache.render(resolvedTemplate, resolvedData);

    // Write out the rendered template
    return fs.writeFile("test.cfg", output, (err: any) => {
      if (err) throw err;
      console.log("generated configuration");
    });
  })
  .catch((error) =>
    console.log("Unable to get all template data: ", error.message)
  );
// at this point gotta think where to proceed
