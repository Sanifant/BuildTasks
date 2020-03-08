
var make = require('shelljs/make');
var util = require('./make-utils');
var semver = require('semver');
var fs = require('fs');
var path = require('path');

var ensureTool = util.ensureTool;
var banner     = util.banner;
var checkNode  = util.checkNodeBuild;
var buildNode  = util.buildNodeTask;
var test       = util.test;
var run        = util.run;
var mkdir      = util.mkdir;
var testFile   = util.testFile;
var testFolder = util.testFolder;
//var fail = util.fail;

target.build = function() {
    ensureTool('tsc', '--version', function (output) {
        var regex = new RegExp('[1-9].[1-9]+.[1-9]+');
        var version = regex.exec(output)[0];
        if (semver.lt(version, '2.3.4')) {
            fail('Expected 2.3.4 or higher. To fix, run: npm install -g npm');
        }
    });
    ensureTool('npm', '--version', function (output) {
        if (semver.lt(output, '5.6.0')) {
            fail('Expected 5.6.0 or higher. To fix, run: npm install -g npm');
        }
    });

    ParseModule(__dirname, function(folder) {
        console.log(folder);
        GetTaskFolder(folder, function(taskPath){
            banner(`Building Module ${GetModuleName(taskPath)}`);

            if(checkNode(taskPath)){
                buildNode(taskPath);
            } else {
                console.log(`Module ${GetModuleName(taskPath)} is a Powershell Module`);
            }
        })
    })
}

target.test = function() {
    ensureTool('tsc', '--version', function (output) {
        var regex = new RegExp('[1-9].[1-9]+.[1-9]+');
        var version = regex.exec(output)[0];
        if (semver.lt(version, '2.3.4')) {
            fail('Expected 2.3.4 or higher. To fix, run: npm install -g npm');
        }
    });
    ensureTool('npm', '--version', function (output) {
        if (semver.lt(output, '5.6.0')) {
            fail('Expected 5.6.0 or higher. To fix, run: npm install -g npm');
        }
    });
    ensureTool('mocha', '--version', function (output) {
        if (semver.lt(output, '2.3.3')) {
            fail('Expected 2.3.3 or higher. To fix, run: npm install -g npm');
        }
    });

    ParseModule(__dirname, function(folder) {
        console.log(folder);
        GetTaskFolder(folder, function(taskPath){
            if(checkNode(taskPath)){
                buildNode(taskPath);
                banner(`Building Module ${GetModuleName(taskPath)}`);
                var testFilePath = path.join(taskPath, 'Tests', '_suite.js');
                var testResultPath = path.join(__dirname, 'TestResults');
                var resultFileName = path.join(testResultPath, GetModuleName(taskPath) + '_results.xml');
                mkdir('-p', testResultPath);
                
            if(testFile(testFilePath)){
                    console.log();
                    run('mocha ' + testFilePath + ' --reporter xunit --reporter-option output=' + resultFileName, false);
                }
            } else {
                console.log(`Module ${GetModuleName(taskPath)} is a Powershell Module`);
            }
        })
    })
}

/**
 * Recursively checka all folders if they are task folders
 * @param {string} folderPath folder to check
 * @param {function} task callback to be executed for every folder
 */
function GetTaskFolder(folderPath, task) {
    if(fs.lstatSync(folderPath).isDirectory()){
        if(path.basename(folderPath) !== 'node_modules'){
            fs.readdirSync(folderPath).map(fileName => {
                var ext = path.extname(fileName);
                if(ext === ''){
                    if (fileName.startsWith('.')){

                    } else {
                        console.log(`GetTaskFolder: ${folderPath}`);
                        var taskPath = path.join(folderPath, fileName);

                        if(IsTaskFolder(taskPath)){
                            task(taskPath);
                        } else {
                            GetTaskFolder(taskPath, task);
                        }
                    }
                }
            })
        }
    }
}

/**
 * Checks if the folder contains a task.json file
 * 
 * @param {string} folderPath folder to be checked
 */
function IsTaskFolder(folderPath) {
    var taskFile = path.join(folderPath, 'task.json'); 
    return testFolder(taskFile);
}

/**
 * Returns the Name of the task.json
 * @param {string} taskFolder folder of the task
 */
function GetModuleName(taskFolder) {
    var moduleName = 'UNDEFINED';
        
    var taskJsonPath = path.join(taskFolder, 'task.json');

    if(testFolder(taskJsonPath)){
        var taskLoc = JSON.parse(fs.readFileSync(taskJsonPath));
        moduleName = taskLoc.name;
    }

    return moduleName;
}

/**
 * Returns the ID of the task.json
 * @param {string} taskFolder folder of the task
 */
function GetModuleId(taskFolder) {
    var moduleName = 'UNDEFINED';
        
    var taskJsonPath = path.join(taskFolder, 'task.json');

    if(testFolder(taskJsonPath)){
        var taskLoc = JSON.parse(fs.readFileSync(taskJsonPath));
        moduleName = taskLoc.id;
    }

    return moduleName;
}

/**
 * Parses the manifest to find the task folders
 * @param {string} folderPath folder of the manifest file
 * @param {function} task callback to be executed per folder
 */
function ParseModule(folderPath, task = '') {
    var manifestPath = path.join(folderPath, 'vss-extension.json');
    var manifest = JSON.parse(fs.readFileSync(manifestPath));

    manifest.files.map(filename => { 
        var taskPath = path.join(folderPath, filename.path);
        task(taskPath);
    });
}