const process = require("process");
const prompts = require("prompts");
const yargs = require("yargs");

const { argv } = yargs
    .option("message", {
        alias: "m",
    })
    .option("auto", {
        alias: "a",
        boolean: true,
    });

const message = argv["message"];
const isAuto = !!argv["auto"];
const choices = argv._;

if (choices.length < 1) {
    console.error(`usage: ${argv.$0} [-m message, -a auto] choice...`);
    process.exitCode = 2;
    return;
}

if (isAuto) {
    console.error(choices[0]);
    process.exitCode = 0;
} else {
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
                console.error(value);
                process.exitCode = 0;
            } else {
                process.exitCode = 1;
            }
        })
        .catch((e) => {
            console.error(e);
            process.exitCode = 1;
        });
}
