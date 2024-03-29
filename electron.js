const { Menu, BrowserWindow, app, dialog } = require('electron');
const path = require('path');
const fs = require('fs-extra');

let windows = [];

const DEFAULT_PROJECT_PATH = '.tmp';
let activeProjectPath = DEFAULT_PROJECT_PATH;

// -- GLOBAL

app.setName('Novelist');

app.on('ready', ready);

function ready() {
    Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));
    createWindow();
}

function createWindow(projectPath = DEFAULT_PROJECT_PATH) {
    activeProjectPath = projectPath;

    const window =
        windows[0] ||
        new BrowserWindow({
            title: 'Novelist',
            width: 1920,
            height: 1080,
            frame: true
        });

    window.loadURL(
        `file://${__dirname}/app.html?projectPath=${activeProjectPath}`
    );

    window.webContents.openDevTools();

    windows[0] = window;
}

// -- OSX

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {});

// -- MENU

const menuTemplate = [
    {
        label: 'File',
        submenu: [
            {
                label: 'New Project',
                accelerator: 'CmdOrCtrl+Shift+N',
                click() {
                    console.log('File.New Project');
                }
            },
            {
                label: 'New Scene',
                accelerator: 'CmdOrCtrl+N',
                click() {
                    console.log('File.New Scene');
                }
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
        ]
    },
    {
        label: 'Edit',
        submenu: [
            { label: 'Undo', accelerator: 'CmdOrCtrl+Z', selector: 'undo:' },
            {
                label: 'Redo',
                accelerator: 'Shift+CmdOrCtrl+Z',
                selector: 'redo:'
            },
            { type: 'separator' },
            { label: 'Cut', accelerator: 'CmdOrCtrl+X', selector: 'cut:' },
            { label: 'Copy', accelerator: 'CmdOrCtrl+C', selector: 'copy:' },
            { label: 'Paste', accelerator: 'CmdOrCtrl+V', selector: 'paste:' },
            {
                label: 'Select All',
                accelerator: 'CmdOrCtrl+A',
                selector: 'selectAll:'
            }
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
                role: 'about'
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
                }
            }
        ]
    });
}

// -- Actions

function showOpenDialog() {
    dialog.showOpenDialog(
        {
            properties: ['openFile'],
            filters: [
                {
                    name: 'Novelist Projects',
                    extensions: ['novl']
                }
            ]
        },
        files => {
            if (files === undefined) {
            }

            if (Array.isArray(files) && files.length === 1) {
                const projectPath = files[0];
                createWindow(projectPath);
            }
        }
    );
}

function saveProject() {
    if (activeProjectPath === DEFAULT_PROJECT_PATH) {
        // open dialog
        dialog.showSaveDialog(
            windows[0].window,
            {
                title: 'my-story.novl',
                filters: [
                    {
                        name: 'Novelist Projects',
                        extensions: ['novl']
                    }
                ]
            },
            path => {
                fs.copy(activeProjectPath, path);
                activeProjectPath = path;
                createWindow(path);
            }
        );
    } else {
        // there is nothing to do
    }
}

function compile() {
    console.log('compile');
}

function gotoPreferences() {
    windows[0].window.webContents.executeJavaScript(
        `novelist.ports.gotoSettings.send("")`,
        true
    );
}
