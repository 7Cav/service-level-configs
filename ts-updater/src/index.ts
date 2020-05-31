const fs = require("fs");

var example = "=7cav=";
var path = require("path");

function renderConfig(
  templatePath: string,
  object: { [x: string]: any; hostname?: string }
) {
  const template = fs.readFileSync(
    path.join(__dirname, templatePath + ".cfg"),
    "utf8"
  );
  return template.match(/\{{(.*?)\}}/gi).reduce((acc: any, binding: string) => {
    const property = binding.substring(2, binding.length - 2);
    return `${acc}${template.replace(/\{{(.*?)\}}/, object[property])}`;
  }, "");
}

console.log(renderConfig("server", { hostname: example }));
