'use strict';
const { app, Menu, BrowserWindow } = require('electron');

require('electron-debug')({ showDevTools: false });

let mainWindow;



// -- GLOBAL


app.on('ready', createWindow);

function createWindow() {
    mainWindow = new BrowserWindow({
        // width: 1024,
        // height: 768,
        frame: true,
    });

    Menu.setApplicationMenu(Menu.buildFromTemplate(menuTemplate));

    mainWindow.loadURL(`file://${__dirname}/index.html`);

    // mainWindow.webContents.openDevTools();

    mainWindow.on('closed', () => {
        mainWindow = null;
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
            { label: 'New Story', click() { console.log('File.New Story'); } },
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
