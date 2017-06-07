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

    // TODO: put this back if I introduce an initial wizard view or similar
    // if (windows.length === 1 && windows[0].projectPath === undefined) {
    //     newWindowIndex = 0;
    //     windows[0].window.close();
    //     windows = [];
    // }

    const [width, height] = windows.length ? windows[newWindowIndex-1].window.getSize() : [800, 600];

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
            },
        ],
    },
    {
      label: 'Edit',
      submenu: [
        { label: "Undo", accelerator: "CmdOrCtrl+Z", selector: "undo:" },
        { label: "Redo", accelerator: "Shift+CmdOrCtrl+Z", selector: "redo:" },
        { type: "separator" },
        { label: "Cut", accelerator: "CmdOrCtrl+X", selector: "cut:" },
        { label: "Copy", accelerator: "CmdOrCtrl+C", selector: "copy:" },
        { label: "Paste", accelerator: "CmdOrCtrl+V", selector: "paste:" },
        { label: "Select All", accelerator: "CmdOrCtrl+A", selector: "selectAll:" }
      ]
    },
    {
      label: 'Compile',
      submenu: [
        {
          label: 'Compile',
          click() {
            compile();
          }
        }
      ]
    }
];

if (process.platform === 'darwin') {
    menuTemplate.unshift({
        label: app.getName(),
        submenu: [
            {
                label: `About ${app.getName()}`,
                role: 'about',
            },
            { type: 'separator' },
            {
              label: 'Preferences...',
              accelerator: 'Command+,',
              click() {
                gotoPreferences();
              }
            },
            { type: 'separator' },
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

function compile() {
  console.log('compile');
}

function gotoPreferences() {
  windows[0].window.webContents.executeJavaScript((
    `novelist.ports.gotoSettings.send("")`
  ), true);
}
