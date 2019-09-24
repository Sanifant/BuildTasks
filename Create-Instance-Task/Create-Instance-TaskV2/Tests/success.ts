import ma = require('./node_modules/azure-pipelines-task-lib/mock-answer');
import tmrm = require('./node_modules/azure-pipelines-task-lib/mock-run');
import path = require('path');

let taskPath = path.join(__dirname, '..', 'createInstance.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tmr.setInput('InstanceName', 'VGSM');
tmr.setInput('SMVersion', '12.2.0');
tmr.setInput('DataBaseServer', 'localhost');
tmr.setInput('DataBase', 'VGSM');

tmr.setInput('CreateDB', 'false');
tmr.setInput('DataBaseSaUser', 'VGSM');
tmr.setInput('DataBaseSaPassword', 'VGSM');
tmr.setInput('DBCollation', 'VGSM');
tmr.setInput('DataBaseUser', 'VGSM');
tmr.setInput('DataBasePassword', 'VGSM');
tmr.setInput('LicenseServer', 'VGSM');
tmr.setInput('TrustedConnection', 'false');

tmr.run();