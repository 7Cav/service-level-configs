

//libraries
var fs = require("fs");
// passed arguments (node index.js -0 -1 -2)
const { arg1, arg2, arg3 } = cmdlinearg();

function cmdlinearg() {
    const args = process.argv.slice(2);
    const arg1 = args[0];
    const arg2 = args[1];
    const arg3 = args[2];
    return { arg1, arg2, arg3 };
}

console.log(arg1);
console.log(arg2);
console.log(arg3);
//fetching info goes below

console.log('my check after')
