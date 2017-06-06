'use strict';

const {
    Menu,
    BrowserWindow,
    app,
    dialog
} = require('electron');
const fs = require('fs-extra');
const path = require('path');

require('electron-debug')({ showDevTools: false });

let windows = [];



// -- GLOBAL

app.setName('Novelist');

app.on('ready', ready);

function ready() {
    Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));
    createWindow();
}

function createWindow(projectPath) {
    let newWindowIndex = windows.length;

    if (windows.length === 1 && windows[0].projectPath === undefined) {
        newWindowIndex = 0;
        windows[0].window.close();
        windows = [];
    }

    const [width, height] = windows.length ? windows[newWindowIndex-1].getSize() : [800, 600];

    let window = new BrowserWindow({
        title: 'Novelist',
        width,
        height,
        frame: true,
    });

    windows.push({
        projectPath,
        window,
    });

    window.loadURL(`file://${__dirname}/index.html?projectPath=${projectPath}`);

    // window.webContents.openDevTools();

    window.on('closed', () => {
        window = null;
    });
}



// -- OSX


app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (mainWindow === null) {
        createWindow();
    }
});




// -- MENU

const menuTemplate = [
    {
        label: 'File',
        submenu: [
            {
                label: 'New Project',
                accelerator: 'CmdOrCtrl+Shift+N',
                click() { console.log('File.New Project'); }
            },
            {
                label: 'New Scene',
                accelerator: 'CmdOrCtrl+N',
                click() { console.log('File.New Scene'); }
            },
            {
                label: 'Open Project...',
                accelerator: 'CmdOrCtrl+O',
                click() {
                    showOpenDialog();
                }
            },
            {
              label: 'Save Project',
              accelerator: 'CmdOrCtrl+S',
              click() {
                saveProject();
              }
            }
        ],
    },
];

if (process.platform === 'darwin') {
    menuTemplate.unshift({
        label: app.getName(),
        submenu: [
            {
                label: `About ${app.getName()}`,
                role: 'about',
            },
            {
                label: 'Quit',
                accelerator: 'Command+Q',
                click() {
                    app.quit();
                },
            },
        ],
    });
}


// -- Actions

function showOpenDialog() {
    dialog.showOpenDialog({
        properties: ['openFile'],
        filters: [{
            name: 'Novelist Projects',
            extensions: ['novl'],
        }]
    }, (files) => {
        if (files === undefined) {

        }

        if (Array.isArray(files) && files.length === 1) {
            const projectDir = files[0];
            const projectName = path.basename(projectDir, '.novl');
            // const metaPath = path.join(projectDir, `${projectName}.novj`);

            createWindow(projectDir);
        }
    });
}

function saveProject() {
  windows[0].window.webContents.executeJavaScript((
    `localStorage.getItem("model")`
  ), true)
    .then((model) => {
      console.log('save', model);
      dialog.showSaveDialog(windows[0].window, {
        title: 'my-story.novl',
        filters: [{
            name: 'Novelist Projects',
            extensions: ['novl'],
        }],
      }, (path) => {
        fs.outputFile(path, JSON.stringify(JSON.parse(model), null, 4));
      });
    })
    .catch((e) => {
      console.error(e);
    });
}
