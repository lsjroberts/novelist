"use strict";

const Elm = require("../dist/elm.js");

const container = document.getElementById("container");
const novelist = Elm.Main.fullscreen(Math.floor(Math.random() * 0x0fffffff));
