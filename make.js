
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
//var fail = util.fail;

target.build = function() {
    console.debug('@@@ Building make.js @@@')
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

    var folderPath = path.join(__dirname, 'Tasks');
    fs.readdirSync(folderPath).map(fileName => {
        var taskPath = path.join(folderPath, fileName);
        banner(`Building ${fileName}`);

        if(checkNode(taskPath)){
            buildNode(taskPath);
        }
    })
}

target.test = function() {
    console.debug('@@@ Tesing make.js @@@')
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

    target.build();

    var folderPath = path.join(__dirname, 'Tasks');
    fs.readdirSync(folderPath).map(fileName => {
        
        banner(`Testing Module ${fileName}`);
        var testFilePath = path.join(folderPath, fileName, 'Tests', '_suite.js');
        var testResultPath = path.join(__dirname, 'TestResults');
        var resultFileName = path.join(testResultPath, fileName + '_results.xml');
        mkdir('-p', testResultPath);
        
        if(test('-f', testFilePath)){
            console.log();
            run('mocha ' + testFilePath + ' --reporter xunit --reporter-option output=' + resultFileName, true);
        }

    })
}

