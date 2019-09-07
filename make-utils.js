
var ncp = require('child_process');
var path = require('path');
var process = require('process');
var shell = require('shelljs');
var fs = require('fs');

/**
 * 
 * @param {*} message 
 * @param {*} noBracket 
 */
var banner = function (message, noBracket) {
    console.log();
    if (!noBracket) {
        console.log('------------------------------------------------------------');
    }
    console.log(message);
    if (!noBracket) {
        console.log('------------------------------------------------------------');
    }
}
exports.banner = banner;

var ensureTool = function (name, versionArgs, validate) {
    console.log(name + ' tool:');
    var toolPath = which(name);
    if (!toolPath) {
        fail(name + ' not found.  might need to run npm install');
    }

    if (versionArgs) {
        var result = exec(name + ' ' + versionArgs);
        if (typeof validate == 'string') {
            if (result.output.trim() != validate) {
                fail('expected version: ' + validate);
            }
        }
        else {
            validate(result.output.trim());
        }
    }

    console.log(toolPath + '');
}
exports.ensureTool = ensureTool;

/**
 * Prints the error message and exits the process
 * @param {string} message - Error Message
 */
var fail = function (message) {
    console.error('ERROR: ' + message);
    process.exit(1);
}
exports.fail = fail;

var shellAssert = function () {
    var errMsg = shell.error();
    if (errMsg) {
        throw new Error(errMsg);
    }
}

/**
 * Test that path exists
 * @param {string} options - unknown, should be '-f'
 * @param {string} path - Path to test
 */
var test = function (options, path) {
    var result = shell.test(options, path);
    shellAssert();
    return result;
}
exports.test = test;

var rp = function (relPath) {
    return path.join(pwd() + '', relPath);
}
exports.rp = rp;

/**
 * Build Node Task
 * @param {string} taskPath - Path to build
 * @param {string} outDir  - Output folder
 */
var buildNodeTask = function (taskPath, outDir = '') {
    var originalDir = pwd();
    cd(taskPath);
    var packageJsonPath = rp('package.json');
    if (test('-f', packageJsonPath)) {
        // verify no dev dependencies
        var packageJson = JSON.parse(fs.readFileSync(packageJsonPath).toString());
        if (packageJson.devDependencies && Object.keys(packageJson.devDependencies).length != 0) {
            fail('The package.json should not contain dev dependencies. Move the dev dependencies into a package.json file under the Tests sub-folder. Offending package.json: ' + packageJsonPath);
        }

        run('npm install');
    }

    if (test('-f', rp(path.join('Tests', 'package.json')))) {
        cd(rp('Tests'));
        run('npm install');
        cd(taskPath);
    }
    if(outDir == ''){
        run('tsc --rootDir ' + taskPath);
    } else {
        run('tsc --outDir ' + outDir + ' --rootDir ' + taskPath);
    }
    cd(originalDir);
}
exports.buildNodeTask = buildNodeTask;

/**
 * Change directory
 * @param {string} dir - Folder to step in
 */
var cd = function (dir) {
    var cwd = process.cwd();
    if (cwd != dir) {
        console.log('');
        console.log(`> cd ${path.relative(cwd, dir)}`);
        shell.cd(dir);
        shellAssert();
    }
}
exports.cd = cd;

/**
 * Executes the given program
 * @param {*} cl 
 * @param {*} inheritStreams 
 * @param {*} noHeader 
 */
var run = function (cl, inheritStreams, noHeader) {
    if (!noHeader) {
        console.log();
        console.log('> ' + cl);
    }

    var options = {
        stdio: inheritStreams ? 'inherit' : 'pipe'
    };
    var rc = 0;
    var output;
    try {
        output = ncp.execSync(cl, options);
    }
    catch (err) {
        if (!inheritStreams) {
            console.error(err.output ? err.output.toString() : err.message);
        }

        process.exit(1);
    }

    return (output || '').toString().trim();
}
exports.run = run;

/**
 * Checks if a module is build using Node
 * @param {string} taskPath - Module Path to check
 */
var checkNodeBuild = function(taskPath){
    var doBuildNode = false;
        
    var taskJsonPath = path.join(taskPath, 'task.json');

    if(test('-f', taskJsonPath)){
        var taskLoc = JSON.parse(fs.readFileSync(taskJsonPath));
        doBuildNode = taskLoc.execution.hasOwnProperty('Node');
    }

    return doBuildNode;
}
exports.checkNodeBuild = checkNodeBuild;

/**
 * Create Directory
 * @param {string} options Available options:
 * - `-p`: full paths, will create intermediate dirs if necessary
 * @param {string} target - Folder to create
 */
var mkdir = function (options, target) {
    if (target) {
        shell.mkdir(options, target);
    }
    else {
        shell.mkdir(options);
    }

    shellAssert();
}
exports.mkdir = mkdir;
