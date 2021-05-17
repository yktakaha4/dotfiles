const prompts = require("prompts");
const process = require("process");
const { basename } = require("path");

const { argv } = process;

if (process.argv.length < 4) {
    console.error(`usage: ${basename(argv[1])} message [choice...]`);
    process.exitCode = 2;
    return;
}

const message = argv[2];
const choices = argv.slice(3);

prompts({
    type: "select",
    name: "value",
    message,
    choices: choices.map((choice) => ({
        title: choice,
        value: choice,
    })),
})
    .then((result) => {
        const { value } = result;
        if (value) {
            console.log(value);
        }
        process.exitCode = 0;
    })
    .catch((e) => {
        console.error(e);
        process.exitCode = 1;
    });
