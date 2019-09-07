"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const tl = __importStar(require("azure-pipelines-task-lib/task"));
const RootKey = 'HKLM:SOFTWARE\\Wow6432Node\\LabSystems\\';
const VersionRootKey = `${RootKey}SampleManager`;
function run() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            let InstanceName = tl.getInput('InstanceName', true);
            let SMVersion = tl.getInput('SMVersion', true);
            let DataBaseServer = tl.getInput('DataBaseServer', true);
            let DataBase = tl.getInput('DataBase', true);
            let CreateDB = tl.getBoolInput('DBCreate', false);
            let DataBaseSaUser = tl.getInput('DataBaseSaUser', false);
            let DataBaseSaPassword = tl.getInput('DataBaseSaPassword', false);
            let DBCollation = tl.getInput('DBCollation', false);
            let DataBaseUser = tl.getInput('DataBaseUser', false);
            let DataBasePassword = tl.getInput('DataBasePassword', false);
            let LicenseServer = tl.getInput('LicenseServer', false);
            let TrustedConnection = tl.getBoolInput('TrustedConnection', false);
            let regex = RegExp('(?<major>12).(?<minor>[1-9]).(?<patch>[0-9])?');
            if (regex.test(SMVersion)) {
                let major = RegExp.$1;
                let minor = RegExp.$2;
                let patch = RegExp.$3;
                if (patch == '0') {
                    SMVersion = `${major}.${minor}`;
                }
                console.debug(SMVersion);
            }
            else {
                tl.setResult(tl.TaskResult.Failed, `Version ${SMVersion} is not supported`);
                return;
            }
        }
        catch (err) {
            tl.setResult(tl.TaskResult.Failed, err.message);
        }
    });
}
run();
