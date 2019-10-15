"use strict";
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const path = __importStar(require("path"));
const assert = __importStar(require("assert"));
const ttm = __importStar(require("./node_modules/azure-pipelines-task-lib/mock-test"));
describe('Sample task tests', function () {
    before(function () {
    });
    after(() => {
    });
    it('should use Version 12.2', function (done) {
        this.timeout(1000);
        let tp = path.join(__dirname, 'success.js');
        let tr = new ttm.MockTestRunner(tp);
        tr.run();
        assert.equal(tr.succeeded, true, 'should have succeeded');
        assert.equal(tr.warningIssues.length, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 0, "should have no errors");
        console.log(tr.stdout);
        assert.equal(tr.stdout.indexOf('12.2') >= 0, true, "should display 12.2");
        done();
    });
    it('it should fail when wrong version supplied', function (done) {
        this.timeout(1000);
        let tp = path.join(__dirname, 'wrongInstanceFailure.js');
        let tr = new ttm.MockTestRunner(tp);
        tr.run();
        assert.equal(tr.succeeded, false, 'should have failed');
        assert.equal(tr.warningIssues, 0, "should have no warnings");
        assert.equal(tr.errorIssues.length, 1, "should have 1 error issue");
        assert.equal(tr.errorIssues[0], 'Version 12.0.0 is not supported', 'error issue output');
        assert.equal(tr.stdout.indexOf('Hello bad'), -1, "Should not display Hello bad");
        done();
    });
});
//# sourceMappingURL=_suite.js.map