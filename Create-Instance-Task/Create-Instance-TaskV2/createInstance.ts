import * as tl from 'azure-pipelines-task-lib/task';
import path = require('path');

const RootKey : string = 'HKLM:SOFTWARE\\Wow6432Node\\LabSystems\\';
const VersionRootKey : string = `${RootKey}SampleManager`;

async function run() {
    try {
        let InstanceName: string = tl.getInput('InstanceName', true);
        let SMVersion: string = tl.getInput('SMVersion', true);
        let DataBaseServer: string = tl.getInput('DataBaseServer', true);
        let DataBase: string = tl.getInput('DataBase', true);
        let CreateDB: boolean = tl.getBoolInput('DBCreate', false);
        let DataBaseSaUser: string = tl.getInput('DataBaseSaUser', false);
        let DataBaseSaPassword: string = tl.getInput('DataBaseSaPassword', false);
        let DBCollation: string = tl.getInput('DBCollation', false);
        let DataBaseUser: string = tl.getInput('DataBaseUser', false);
        let DataBasePassword: string = tl.getInput('DataBasePassword', false);
        let LicenseServer: string = tl.getInput('LicenseServer', false);
        let TrustedConnection: boolean = tl.getBoolInput('TrustedConnection', false);

        let regex = RegExp('(?<major>12).(?<minor>[1-9]).(?<patch>[0-9])?');
        if(regex.test(SMVersion)) {

            let major = RegExp.$1;
            let minor = RegExp.$2;
            let patch = RegExp.$3;
            if (patch == '0') {
                SMVersion = `${major}.${minor}`
            }
            console.debug(SMVersion);

        } else {
            tl.setResult(tl.TaskResult.Failed, `Version ${SMVersion} is not supported`);
            return;            
        }

    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

run();